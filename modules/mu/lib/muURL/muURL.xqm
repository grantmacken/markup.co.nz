xquery version "3.0";
(:~
This module contains helper functions for dealing with URLs.

When dealing with 'response' documents that are returned from requests
using expath [http-client](The http-clent http://expath.org/spec/http-client)
we want to be able to.

* extract the base url for the document
* resolve any relative or absolute URLs contained in document to the base url
* hash the url to get a unique identifier that can be ued as a file name




 @author Grant MacKenzie
 @version 0.01

:)
(:
User Story
@feature-name  [name] to be used with git
@user-story    As a [Role] I want [Feature] So that I receive [Value]

@feature background: Short descriptive context

scenarios.
@senario [name]     each senario has a test
@senario outline
given,
when and
then
:)

module namespace muURL="http://markup.co.nz/#muURL";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace system="http://exist-db.org/xquery/system";
import module namespace http = "http://expath.org/ns/http-client";
(: DEPENDENCIES:  import my libs :)
import  module namespace muCache = "http://markup.co.nz/#muCache" at '../muCache/muCache.xqm';

(:import module namespace err = "http://expath.org/ns/error";:)

(:~
hash the url to get a unique identifier
@param $URL URL
@return string()
:)
declare
function muURL:urlHash( $url ) as xs:string {
let $base64flag := true()
let $alogo := 'md5'
let $hash := replace(util:hash( $url , $alogo, $base64flag), '(=+$)', '')
return
translate( $hash, '+/', '-_')
};

declare
function muURL:isBaseInDoc( $doc  ) as xs:boolean {
exists($doc//*[local-name(.) eq 'base' ][@href])
};


declare
function muURL:getBase($url) {
  let $node := muCache:fetch( $url )
  return
  if(muURL:isBaseInDoc($node)) then ( $node//*[local-name(.) eq 'base' ][@href]/@href/string()  )
  else( $url )
};



(:
http://www.ietf.org/rfc/rfc2396.txt
5.1.3. Base URI from the Retrieval URI


TODO:
   If no base URI is embedded and the document is not encapsulated
   within some other entity (e.g., the top level of a composite entity),
   then,

look for base in html doc



if a URI was used to retrieve the base document, that URI shall
   be considered the base URI.  Note that if the retrieval was the
   result of a redirected request, the last URI used (i.e., that which
   resulted in the actual retrieval of the document) is the base URI.



5.2. Resolving Relative References to Absolute Form


};


:)
(:3.1. Scheme Component:)

declare
function muURL:urlScheme( $base   ) {
substring-before( $base, ':' )
};

declare
function muURL:url-hier_part( $base   ) {
substring-after( $base, ':' )
};


(:
The authority component is preceded by a double slash "//" and is
terminated by the next slash "/", question-mark "?", or by the end of
the URI.  Within the authority component, the characters ";", ":",
"@", "?", and "/" are reserved.
:)

declare
function muURL:urlAuthority( $base   ) {
let $start := substring-after( $base, '//' )
return
if( matches($start,'^.+/') ) then ( substring-before(  $start , '/' ))
else if( matches($start,'^.+\?') ) then ( substring-before(  $start , '?' ))
else($start)
};


declare
function muURL:urlAbsolutePath( $base   ) {
let $start := substring-after( $base, '//' )
return
    if (  matches($start,'^.+\?')  ) then (
    substring-before(substring-after( $base, '//' || muURL:urlAuthority( $base  )  ) , '?')
    )
    else if (  matches($start,'^.+/')  ) then (
     substring-after( $base,  '//' || muURL:urlAuthority( $base  )  )
    )
    else('/')

};

declare
function muURL:urlQuery( $base   ) {
    if ( contains( $base , '?') ) then (
    substring-after($base, '?')
    )
    else()
};

(:~
Detirmine if url is relative: A relative reference that does not begin with a scheme name or a slash character is termed a relative-path reference.
@see http://www.ietf.org/rfc/rfc2396.txt
@param $path path component of a URL
@return bool

:)
declare
function muURL:isRelative( $path ) {
 not( starts-with( $path ,'/') )
};

(:

if ( starts-with( $relative , '/' ) and  matches($base,'^[a-z]+://') ) then resolve-uri( substring-after($relative , '/') ,  substring-before($base, substring-after(substring-after($base, '://' ), '/') ))
else( )
:)

declare
function muURL:resolve( $base ,  $relative  ) {
let $normalized-url :=
    muURL:urlScheme( $base ) ||
    '://'   ||
    muURL:urlAuthority($base ) ||
    muURL:urlAbsolutePath( $base   )


return

resolve-uri($relative, $normalized-url)
};
