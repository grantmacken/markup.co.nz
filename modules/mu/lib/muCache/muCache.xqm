xquery version "3.0";
(:~
In order to handle 'webmentions', generarate indieweb
'reply contexts', link previews etc

After an initial get, I want to be able access documents that are returned from
requests using expath [http-client]( http://expath.org/spec/http-client)
from a cache store

 get:

 store:

 fetch:

all function calls return result as element()

@see http://stackoverflow.com/questions/8554543/element-vs-node-in-xquery

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
given URL get sanitised html that can be stored in db.

if there is a problem with the GET then root node (the documentElement ) will
have the tag name 'problem' if GET is successful then the documentElement name
will be 'html' and the document content will be sanitised and any 'links' in the
document will be resolved to the base URL

A GET will return a problem documentElement if the following criteria are not met.
    * url must look like a registed domain name
    * text resources only with media type text/html


NOTE:
   $response[1] is instance of element
   $response[2] is instance of document-node



@param $URL as xs:string
@return element()

@see http://hc.apache.org/httpclient-3.x/exception-handling.html

$res[2]//*[local-name(.) eq 'html']  treat as element()

:)
declare
%private
function muCache:getSequenceType( $item ) as xs:string{
    if ($item instance of element()) then 'element'
    else if ( $item instance of attribute()) then 'attribute'
    else if ( $item instance of text()) then 'text'
    else if ( $item  instance of document-node()) then 'document-node'
    else if ( $item instance of comment()) then 'comment'
    else if ( $item instance of processing-instruction())
	    then 'processing-instruction'
    else if ( $item instance of empty())
	    then 'empty'
    else 'unknown'
};


declare
%private
function muCache:isProblem ( $item ) as xs:boolean{
    if(  muCache:getSequenceType( $item )  eq  'element' )
	then( local-name( $item ) eq 'problem' )
    else( false()
	 )
};



declare
function muCache:get( $url as xs:string ) as element() {


let $checkURL := function( $u as xs:string ) as element(){
    try {
     let $hasAcceptableScheme :=
       if( muURL:hasHttpScheme( $u ) )
	    then (
	    <ok>
	       <status>Check URL SUCCESS: has acceptable Scheme</status>
	       <detail>{muURL:getScheme( $u )  || ' : ' || muURL:hasHttpScheme( $u )}</detail>
	    </ok>
	    )
        else(
	    <problem>
		<title>Check URL FAILED: not  acceptable Scheme</title>
		<detail>{muURL:getScheme( $u )  || ' : ' || muURL:hasHttpScheme( $u )}</detail>
		<instance>{$u}</instance>
	    </problem>
	    )

    let $hasAcceptableAuthority :=
	if( muCache:isProblem( $hasAcceptableScheme ) )
	    then ( $hasAcceptableScheme )
	else(
	 if( muURL:hasAcceptableAuthority( $u ) )
	    then (
	    <ok>
	       <status>Check URL SUCCESS: has acceptable Authority</status>
	       <detail>{muURL:urlAuthority($u)  || ' : ' || muURL:hasHttpScheme( $u )}</detail>
	    </ok>
	    )
        else(
	    <problem>
		<title>Check URL FAILED: not acceptable Authority</title>
		<detail>{muURL:getScheme( $u )  || ' : ' || muURL:hasAcceptableAuthority( $u )}</detail>
		<instance>{$u}</instance>
	    </problem>
	    )
	)

	return  $hasAcceptableAuthority
    }  catch * {
	<problem>
	    <title>Failed to check URL</title>
	    <detail>{ string( $err:description ) }</detail>
	    <instance>{$u}</instance>
	</problem>
    }
}


let $setRequest := function( $u as xs:string ) as element(){
    if( muCache:isProblem( $checkURL($u) ) )
	then ( $checkURL($u)  )
    else(
	try {
	    <http:request
		href="{ xs:anyURI( $u ) }"
		method="get"
		send-authorization="false"
		timeout="4"
		>
		<http:header
		    name = "Connection"
		    value = "close"/>
		</http:request>

	}  catch * {
		<problem>
		    <title>Failed to set request</title>
		    <detail>{ string( $err:description ) }</detail>
		    <instance>{$u}</instance>
		</problem>
	}
    )
}

let $getResponse := function($req  as element() , $u  as xs:string ){
    if( muCache:isProblem( $req ) )
	then ( $req )
    else(
    try {
    http:send-request( $req )
	} catch * {
	if( $err:code eq 'java:org.expath.httpclient.HttpClientException')
	   then (
	    <problem>
		<title>Failed request:  Http Client Exception</title>
		<detail>{ string( $err:description ) }</detail>
		<instance>{$u}</instance>
	    </problem>
	   )
	else(
	<problem>
	    <title>Failed request: </title>
	    <instance>{$u}</instance>
	</problem>
	)
    }
    )
}

let $getResponseHeader := function( $res, $u  as xs:string) as element() {
    if( muCache:isProblem( $res ) )
	then ( $res )
    else(
	try {
	 if( muCache:getSequenceType( $res[1] ) eq 'element' )
	    then ( $res[1]  treat as element() )
	 else(
	    <problem>
	       <title>Failed to get response header: </title>
	       <instance>{$u}</instance>
	    </problem>
	    )
	} catch * {
	<problem>
	    <title>Failed to get response header: </title>
	    <detail>{ string( $err:description ) }</detail>
	    <instance>{$u}</instance>
	</problem>
	}
    )
}

let $checkHeaderResponse := function( $e as element(), $u as xs:string) as element(){
    if( muCache:isProblem( $e ) )
	then ( $e )
    else(
	try {
	    if( $e/@status/number()  gt 399 ) then (
	    <problem>
		<title>Failed Request</title>
		<status>{$e/@status/string()}</status>
		<detail>{$e/@message/string()}</detail>
		<instance>{$u}</instance>
	    </problem>
	    )
	    else if( $e/@status/number()  gt 499 ) then (
	    <problem>
		<title>Failed Request: Server generated error</title>
		<detail>{$e/@message/string()}</detail>
		<status>{$e/@status/string()}</status>
		<instance>{$u}</instance>
	    </problem>
	    )
	    else(
		if($e//*/@media-type/string() eq 'text/html') then (
		<ok>
		   <status>{$e/@status/string()}</status>
		   <media-type>{$e//*/@media-type/string()}</media-type>
		   <accessed>{$e//*[@name="date"]/@value/string()}</accessed>
		</ok>
		)
		else(
		<problem>
		    <title>Failed Request: Can not handle media type</title>
		    <detail>media type should be 'text/html' got
		    {$e//*/@media-type/string()}</detail>
		    <status>{$e/@status/string()}</status>
		    <instance>{$u}</instance>
		</problem>
		)
	    )
    	} catch * {
	<problem>
	    <title>Failed to get check header response </title>
	    <detail>{ string( $err:description ) }</detail>
	    <instance>{$u}</instance>
	</problem>
	}
    )
}

let $getResponseBody := function( $res, $u   as xs:string) as element(){
    if( muCache:isProblem( $checkHeaderResponse( $getResponseHeader($res, $u), $u) ) )
	then ( $checkHeaderResponse( $getResponseHeader($res, $u), $u)  )
    else(
	if( muCache:getSequenceType( $res[2] ) eq 'document-node')
	    then(
		if( muCache:getSequenceType( $res[2]/* ) eq 'element')
		    then(
		    $res[2]/element()   treat as element()
		    )
		else(
		<problem>
		    <title>Failed to get response body: element</title>
		    <instance>{$u}</instance>
		</problem>
		)
	    )
	else(
	    <problem>
		<title>Failed to get response body: document-node</title>
		<instance>{$u}</instance>
	    </problem>
	)
    )
}

let $getBaseURL := function( $e as element(), $u as xs:string) as xs:string{
	if( $e//*[local-name(.) eq 'base' ][@href] )
	    then ( $e//*[local-name(.) eq 'base' ][@href]/@href/string() )
	else( $u )
    }



let $getCleanHTML := function( $e as element() , $u as xs:string ){
    if( muCache:isProblem( $e ))
	then ( $e )
    else(
	try { muSan:sanitizer( $e, $u ) }
	    catch * {
	     <problem>
		<title>Failed to sanitize: element</title>
		<detail>{ string( $err:description ) }</detail>
		<instance>{$u}</instance>
	    </problem>
	}
    )
}

(: proccess :)

let $request := $setRequest( $url )
let $response := $getResponse( $request , $url )
let $responseHeader := $getResponseHeader( $response , $url )
let $responseBody := $getResponseBody( $response , $url )
let $baseURL := $getBaseURL( $responseBody , $url )
let $cleanedHTML := $getCleanHTML( $responseBody , $baseURL )

return
$cleanedHTML
};


(:~
get then store  sanitized  html doc.
hash url to use file name.

@param $URL URL
@return xs:anyURI


:)
declare
function muCache:store( $url as xs:string ) as xs:string  {
let $contents := muCache:get( $url  )
let $resource-name := muURL:urlHash( $url ) || '.xml'
let $collection-uri := $muCache:store-path
let $store :=
	try {
	xmldb:store($collection-uri, $resource-name, $contents )
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

let $store :=
	try {
	xmldb:store($collection-uri, $resource-name, $contents )
	}
	catch java:org.xmldb.api.base.XMLDBException {
	"Failed to store document"
	}

return $store
};


(:~
give URL fetch from cache xhtml doc stored from a http-client request
if doc is not available in cache then get it and store
hash url to use file name.

@param $URL
@return element()
:)
declare
function muCache:fetch( $url as xs:string) as element() {
let $resource-name := muURL:urlHash( $url ) || '.xml'
let $document-uri := $muCache:store-path || '/'  || $resource-name
return
    if( doc-available( $document-uri ) )
	then (
	      doc( $document-uri )/*  treat as element()
	    )
    else (
	let $location := muCache:store( $url )
	return doc( $location )/* treat as element()
    )
};







declare
function muCache:getRawHTML( $url as xs:string ) as element() {

let $getSequenceType := function( $item ){
    if ($item instance of element()) then 'element'
    else if ( $item instance of attribute()) then 'attribute'
    else if ( $item instance of text()) then 'text'
    else if ( $item  instance of document-node()) then 'document-node'
    else if ( $item instance of comment()) then 'comment'
    else if ( $item instance of processing-instruction())
	    then 'processing-instruction'
    else if ( $item instance of empty())
	    then 'empty'
    else 'unknown'
}

let $isProblem := function( $e ) as xs:boolean {
    if( $getSequenceType( $e )  eq  'element' )
	then( local-name( $e ) eq 'problem' )
    else( false()
	 )
}

let $checkURL := function( $u as xs:string ) as element(){
    	<ok/>
(:
    try {
     let $hasAcceptableScheme :=
       if( muURL:hasHttpScheme( $u ) )
	    then (
	    <ok>
	       <status>Check URL SUCCESS: has acceptable Scheme</status>
	       <detail>{muURL:getScheme( $u )  || ' : ' || muURL:hasHttpScheme( $u )}</detail>
	    </ok>
	    )
        else(
	    <problem>
		<title>Check URL FAILED: not  acceptable Scheme</title>
		<detail>{muURL:getScheme( $u )  || ' : ' || muURL:hasHttpScheme( $u )}</detail>
		<instance>{$u}</instance>
	    </problem>
	    )

    let $hasAcceptableAuthority :=
	if( $isProblem( $hasAcceptableScheme ) )
	    then ( $hasAcceptableScheme )
	else(
	 if( muURL:hasAcceptableAuthority( $u ) )
	    then (
	    <ok>
	       <status>Check URL SUCCESS: has acceptable Authority</status>
	       <detail>{muURL:urlAuthority($u)  || ' : ' || muURL:hasHttpScheme( $u )}</detail>
	    </ok>
	    )
        else(
	    <problem>
		<title>Check URL FAILED: not acceptable Authority</title>
		<detail>{muURL:getScheme( $u )  || ' : ' || muURL:hasAcceptableAuthority( $u )}</detail>
		<instance>{$u}</instance>
	    </problem>
	    )
	)

	return  $hasAcceptableAuthority
    }  catch * {
	<problem>
	    <title>Failed to check URL</title>
	    <detail>{ string( $err:description ) }</detail>
	    <instance>{$u}</instance>
	</problem>
    }
:)
}


let $setRequest := function( $u as xs:string ) as element(){
    if( $isProblem( $checkURL($u) ) )
	then ( $checkURL($u)  )
    else(
	try {
	    <http:request
		href="{ xs:anyURI( $u ) }"
		method="get"
		send-authorization="false"
		timeout="4"
		>
		<http:header
		    name = "Connection"
		    value = "close"/>
		</http:request>

	}  catch * {
		<problem>
		    <title>Failed to set request</title>
		    <detail>{ string( $err:description ) }</detail>
		    <instance>{$u}</instance>
		</problem>
	}
    )
}

let $getResponse := function($req  as element() , $u  as xs:string ){
    if( $isProblem( $req ) )
	then ( $req )
    else(
    try {
    http:send-request( $req )
	} catch * {
	if( $err:code eq 'java:org.expath.httpclient.HttpClientException')
	   then (
	    <problem>
		<title>Failed request:  Http Client Exception</title>
		<detail>{ string( $err:description ) }</detail>
		<instance>{$u}</instance>
	    </problem>
	   )
	else(
	<problem>
	    <title>Failed request: </title>
	    <instance>{$u}</instance>
	</problem>
	)
    }
    )
}

let $getResponseHeader := function( $res, $u  as xs:string) as element() {
    if( $isProblem( $res ) )
	then ( $res )
    else(
	try {
	 if( $getSequenceType( $res[1] ) eq 'element' )
	    then ( $res[1]  treat as element() )
	 else(
	    <problem>
	       <title>Failed to get response header: </title>
	       <instance>{$u}</instance>
	    </problem>
	    )
	} catch * {
	<problem>
	    <title>Failed to get response header: </title>
	    <detail>{ string( $err:description ) }</detail>
	    <instance>{$u}</instance>
	</problem>
	}
    )
}

let $checkHeaderResponse := function( $e as element(), $u as xs:string) as element(){
    if( $isProblem( $e ) )
	then ( $e )
    else(
	try {
	    if( $e/@status/number()  gt 399 ) then (
	    <problem>
		<title>Failed Request</title>
		<status>{$e/@status/string()}</status>
		<detail>{$e/@message/string()}</detail>
		<instance>{$u}</instance>
	    </problem>
	    )
	    else if( $e/@status/number()  gt 499 ) then (
	    <problem>
		<title>Failed Request: Server generated error</title>
		<detail>{$e/@message/string()}</detail>
		<status>{$e/@status/string()}</status>
		<instance>{$u}</instance>
	    </problem>
	    )
	    else(
		if($e//*/@media-type/string() eq 'text/html') then (
		<ok>
		   <status>{$e/@status/string()}</status>
		   <media-type>{$e//*/@media-type/string()}</media-type>
		   <accessed>{$e//*[@name="date"]/@value/string()}</accessed>
		</ok>
		)
		else(
		<problem>
		    <title>Failed Request: Can not handle media type</title>
		    <detail>media type should be 'text/html' got
		    {$e//*/@media-type/string()}</detail>
		    <status>{$e/@status/string()}</status>
		    <instance>{$u}</instance>
		</problem>
		)
	    )
    	} catch * {
	<problem>
	    <title>Failed to get check header response </title>
	    <detail>{ string( $err:description ) }</detail>
	    <instance>{$u}</instance>
	</problem>
	}
    )
}

let $getResponseBody := function( $res, $u   as xs:string) as element(){
    if( $isProblem( $checkHeaderResponse( $getResponseHeader($res, $u), $u) ) )
	then ( $checkHeaderResponse( $getResponseHeader($res, $u), $u)  )
    else(
	if( $getSequenceType( $res[2] ) eq 'document-node')
	    then(
		if( $getSequenceType( $res[2]/* ) eq 'element')
		    then(
		    $res[2]/element()   treat as element()
		    )
		else(
		<problem>
		    <title>Failed to get response body: element</title>
		    <instance>{$u}</instance>
		</problem>
		)
	    )
	else(
	    <problem>
		<title>Failed to get response body: document-node</title>
		<instance>{$u}</instance>
	    </problem>
	)
    )
}

let $request := $setRequest( $url )

(: proccess

let $request := $setRequest( $url )
let $response := $getResponse( $request , $url )
let $responseHeader := $getResponseHeader( $response , $url )
let $rawHTML := $getResponseBody( $response , $url )


:)
return
$request
};


declare
function muCache:getCleanHTML( $url as xs:string ) as element() {


let $getBaseURL := function( $e as element(), $u as xs:string) as xs:string{
	if( $e//*[local-name(.) eq 'base' ][@href] )
	    then ( $e//*[local-name(.) eq 'base' ][@href]/@href/string() )
	else( $u )
    }



let $getCleanHTML := function( $e as element() , $u as xs:string ){
    if( $isProblem( $e ))
	then ( $e )
    else(
	try { muSan:sanitizer( $e, $u ) }
	    catch * {
	     <problem>
		<title>Failed to sanitize: element</title>
		<detail>{ string( $err:description ) }</detail>
		<instance>{$u}</instance>
	    </problem>
	}
    )
}

(: proccess :)


let $responseBody := muCache:getCleanHTML( $url  )
let $baseURL := $getBaseURL( $responseBody , $url )
let $cleanedHTML := $getCleanHTML( $responseBody , $baseURL )

return
$cleanedHTML
};
