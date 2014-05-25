xquery version "3.0";
(:~
This module contains helper functions for dealing with URLs.

When dealing with 'response' documents that are returned from requests
using expath [http-client](The http-clent http://expath.org/spec/http-client)
we want to be able to.

* extract the base url for the document
* resolve any relative or absolute URLs contained in document to the base url
* hash the url to get a unique identifier

 @author Grant MacKenzie
 @version 0.01

:)


module namespace url="http://markup.co.nz/#url";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";


(:~
hash the url to get a unique identifier
@param $URL URL
@return string()
:)
declare
function url:urlHash( $url as xs:string ) as xs:string {
let $base64flag := true()
let $alogo := 'md5'
let $hash := replace(util:hash( $url, $alogo, $base64flag), '(=+$)', '')
return
translate( $hash, '+/', '-_')
};



(:~
simple get using http-client
@param $URL URL
@return node()
:)
declare
function url:get( $url  )  as node() {
let $req := <http:request href="{ xs:anyURI( $url ) }"
                            method="get" />
return
http:send-request($req)[2]
};



(:~
get then store  xhtml doc.
hash url to use file name.

@param $URL URL
@return xs:anyURI
:)
declare
function url:store( $url ) {
()
};

(:~
fetch xhtml doc from store
@param $URL URL
@return xs:anyURI
:)
declare
function url:fetch( $url ) {
()
};

(:~
establish a Base URI

@see http://www.cs.tut.fi/~jkorpela/rfc/2396/full.html#5.1
:)
declare
function url:getBaseURL( $node ) as  xs:anyURI{
	
 xs:anyURI( $node )
};


declare
function url:isBaseInDoc( $doc as element() ) as xs:boolean {
exists($doc//*[local-name(.) eq 'base' ][@href])
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

if ( starts-with( $url, '/' ) and  matches($base,'^[a-z]+://') ) then resolve-uri( substring-after($url, '/') ,  substring-before($base, substring-after(substring-after($base, '://' ), '/') ))
else()


5.2. Resolving Relative References to Absolute Form


};


:)
(:3.1. Scheme Component:)

declare
function url:urlScheme( $base   ) {
substring-before( $base, ':' )
};

declare
function url:url-hier_part( $base   ) {
substring-after( $base, ':' )
};


(:
The authority component is preceded by a double slash "//" and is
terminated by the next slash "/", question-mark "?", or by the end of
the URI.  Within the authority component, the characters ";", ":",
"@", "?", and "/" are reserved.
:)

declare
function url:urlAuthority( $base   ) {
let $start := substring-after( $base, '//' )
return
if( matches($start,'^.+/') ) then ( substring-before(  $start , '/' ))
else if( matches($start,'^.+\?') ) then ( substring-before(  $start , '?' ))
else($start)
};


declare
function url:urlAbsolutePath( $base   ) {
let $start := substring-after( $base, '//' )
return
    if (  matches($start,'^.+\?')  ) then (
    substring-before(substring-after( $base, '//' || url:urlAuthority( $base  )  ) , '?')
    )
    else if (  matches($start,'^.+/')  ) then (
     substring-after( $base,  '//' || url:urlAuthority( $base  )  )
    )
    else('/')

};

declare
function url:urlQuery( $base   ) {
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
function url:isRelative( $path ) {
 not( starts-with( $path ,'/') )
};

(:

if ( starts-with( $relative , '/' ) and  matches($base,'^[a-z]+://') ) then resolve-uri( substring-after($relative , '/') ,  substring-before($base, substring-after(substring-after($base, '://' ), '/') ))
else( )
:)

declare
function url:urlResolve( $base ,  $relative  ) {
let $normalized-url :=
    url:urlScheme( $base ) ||
    '://'   ||
    url:urlAuthority($base ) ||
    url:urlAbsolutePath( $base   )


return

resolve-uri($relative, $normalized-url)
};
