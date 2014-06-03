xquery version "3.0";
(:~
@feature-name muCache

In order to handle 'webmentions', generarate indieweb
'reply contexts', link previews etc

After an initial get, I want to be able access documents that are returned from
requests using expath [http-client]( http://expath.org/spec/http-client)
from a cache store

 get:

 store

 fetch

all function calls return result as node()

if there is a problem it will return a http 'problem' node
if no problem then


@see http://tools.ietf.org/html/draft-nottingham-http-problem-06
@see https://github.com/dret/I-D-1/blob/master/http-problem/http-problem-03.xsd

 @author Grant MacKenzie
 @version 0.01
:)
module namespace muCache="http://markup.co.nz/#muCache";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace system="http://exist-db.org/xquery/system";
import module namespace http = "http://expath.org/ns/http-client";
(:import module namespace err = "http://www.w3.org/2005/xqt-errors";:)
(: import my libs :)
import  module namespace muURL = "http://markup.co.nz/#muURL" at '../muURL/muURL.xqm';
import  module namespace muSan = "http://markup.co.nz/#muSan" at '../muSan/muSan.xqm';

declare variable $muCache:store-path :=
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
	if (starts-with($rawPath, "xmldb:exist://")) then
	    if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
		substring($rawPath, 36)
	    else
	    substring($rawPath, 15)
	else
	    $rawPath
	return
	substring-before($modulePath, "/modules")  || "/data/cache"
	;


(:~
get resource at url using http-client return node

@param $URL URL
@return node as node()

:)
declare
function muCache:get( $url  ) as node() {
let $condition := ''
let $request :=
    <http:request   href="{ xs:anyURI( $url ) }"
		    method="get" />

let $response := try {
    http:send-request( $request )
	} catch * {
	<problem>
	    <title>Failed request</title>
	    <detail>{ string( $err:code ) }</detail>
	    <instance>{$url}</instance>
	</problem>
    }



let $responseHeader :=
    if( $response[1][local-name(.) eq 'problem'] )  then ( $response )
    else (
	if( $response[1][local-name(.) eq 'response']  )  then (
	    if( $response[1]/@status/number()  gt 399 ) then (
	    <problem>
		<title>Failed Request</title>
		<status>{$response[1]/@status/string()}</status>
		<detail>{$response[1]/@message/string()}</detail>
		<instance>{$url}</instance>
	    </problem>
	    )
	    else if( $response[1]/@status/number()  gt 499 ) then (
	    <problem>
		<title>Failed Request: Server generated error</title>
		<detail>{$response[1]/@message/string()}</detail>
		<status>{$response[1]/@status/string()}</status>
		<instance>{$url}</instance>
	    </problem>
	    )
	    else(
		if($response[1]//*/@media-type/string() eq 'text/html') then (
            	<ok>
		   <status>{$response[1]/@status/string()}</status>
		   <media-type>{$response[1]//*/@media-type/string()}</media-type>
		   <accessed>{$response[1]//*[@name="date"]/@value/string()}</accessed>
	        </ok>
		)
		else(
		<problem>
		    <title>Failed Request: Can not handle media type</title>
		    <detail>media type should be 'text/html' got {$response[1]//*/@media-type/string()}</detail>
		    <status>{$response[1]/@status/string()}</status>
		    <instance>{$url}</instance>
		</problem>
		)
	    )
	    )
	else (
	    <problem>
		<title>Failed Request</title>
		<detail>No Response Header</detail>
		<instance>{$url}</instance>
	    </problem>
	    )
    )
let $responseBody :=
    if( $responseHeader[local-name(.) eq 'problem'] )  then ( $responseHeader )
    else(
	let $body := $response[2]/node()
	return
	    if( local-name($body) eq 'html' )  then (
		$body				    )
	    else(
	    <problem>
		<title>Failed Request: no HTML root</title>
		<detail>{local-name($body)}</detail>
		<instance>{$url}</instance>
	    </problem>)
	)

let $baseURL :=
	if(muURL:isBaseInDoc($responseBody))
	    then ( $responseBody//*[local-name(.) eq 'base' ][@href]/@href/string()  )
	else( $url )

return
if( $responseBody[local-name(.) eq 'problem'] )
    then ( $responseBody )
else( muSan:sanitizer( $responseBody, $baseURL ) )
};


(:~
get then store  sanitized  html doc.
hash url to use file name.

@param $URL URL
@return xs:anyURI


:)
declare
function muCache:store( $url )  {
let $responseBody := muCache:get( $url  )
let $resource-name := muURL:urlHash( $url ) || '.xml'
let $collection-uri := $muCache:store-path
let $store :=
	try {
	xmldb:store($collection-uri, $resource-name, $responseBody )
	}
	catch java:org.xmldb.api.base.XMLDBException {
	"Failed to store document"
	}
return $store
};

declare
function muCache:store-content( $url , $content )  {
let $responseBody :=
	if( empty($content)) then (muCache:get( $url  ))
	else($content)

let $baseURL :=
	if(muURL:isBaseInDoc($responseBody))
	    then ( $responseBody//*[local-name(.) eq 'base' ][@href]/@href/string()  )
	else( $url )

let $contents := if( $responseBody[local-name(.) eq 'problem'] )
			then ( $responseBody )
		else( muSan:sanitizer( $responseBody, $baseURL ) )

let $resource-name := muURL:urlHash( $url ) || '.xml'
let $collection-uri := $muCache:store-path
return xmldb:store($collection-uri, $resource-name, $contents )
};


(:~
fetch from cache xhtml doc stored from a http-client request
if doc is not available in cache then get it and store
hash url to use file name.

@param $URL
@return $node as node()
:)
declare
function muCache:fetch( $url ) as node() {
let $resource-name := muURL:urlHash( $url ) || '.xml'
let $document-uri := $muCache:store-path || '/'  || $resource-name
return
    if( doc-available( $document-uri ) )
	then ( doc( $document-uri )/node() )
    else (
	let $location := muCache:store( $url )
	return
	doc( $location )/node()
    )
};
