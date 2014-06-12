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

@see http://timezra.blogspot.co.nz/2010/05/regex-to-validate-uris.html
@see http://greenbytes.de/tech/tc/uris/
@see http://greenbytes.de/tech/webdav/rfc3986.html#examples
@see http://greenbytes.de/tech/webdav/draft-reschke-ref-parsing-latest.xml
@see http://rxr.whitequark.org/mri/source/lib/uri/common.rb

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
function muURL:urlHash( $url as xs:string ) as xs:string {
let $base64flag := true()
let $alogo := 'md5'
let $hash := replace(util:hash( $url , $alogo, $base64flag), '(=+$)', '')
return
translate( $hash, '+/', '-_')
};




(:
  before storing a  html doc we want to be able to resolve links in the doc

 to do this we need to get the base URL for the doc

@see http://www.ietf.org/rfc/rfc2396.txt
    5.1.3. Base URI from the Retrieval URI

   If no base URI is embedded and the document is not encapsulated
   within some other entity (e.g., the top level of a composite entity),
   then, look for base in html doc

    if a URI was used to retrieve the base document, that URI shall
   be considered the base URI.  Note that if the retrieval was the
   result of a redirected request, the last URI used (i.e., that which
   resulted in the actual retrieval of the document) is the base URI.
:)

declare
function muURL:isBaseInDoc( $documentElement  as element() ) as xs:boolean {
exists( $documentElement//*[local-name(.) eq 'base' ][@href] )
};

declare
function muURL:getBase($url) {
  let $node := muCache:fetch( $url )
  return
  if(muURL:isBaseInDoc($node)) then ( $node//*[local-name(.) eq 'base' ][@href]/@href/string()  )
  else( $url )
};

(:
The 'lexical space' of anyURI is finite-length character sequences
which, when the algorithm defined in Section 5.4 of [XML Linking
Language] is applied to them, result in strings which are legal URIs
according to [RFC 2396], as amended by [RFC 2732]
:)
declare
function muURL:canCaste( $url as xs:string ) as xs:boolean{
let $u :=
    try {
	$url cast as xs:anyURI
    } catch * {()}

return
    if( empty( $u )  )
       then ( false() )
    else( true() )
};


(:
A string that may or may not be a valid URI scheme component according to
Section 3.1 of [RFC3986].
3.1. Scheme Component

scheme = alpha *( alpha | digit | "+" | "-" | "." )
:)

declare
function muURL:getScheme( $u  ) {

let $input :=
	if( not( contains( $u, ':')) )
	    then (
		fn:error(fn:QName('http://markup.co.nz/#muURL',
				  'urlHasNoScheme'),
				  'url has no scheme component')
		)
	else(substring-before( $u, ':' ))

let $pattern := '^([a-zA-Z][a-zA-Z0-9\+\-\.]+)$'
let $flags := ''

return
    if( matches(  $input, $pattern ))
       then ( $input )
    else(
	fn:error(fn:QName('http://markup.co.nz/#muURL',
			  'urlHasBadScheme'),
			  'url has bad scheme component')
    )
};


declare
function muURL:hasHttpScheme( $u  as xs:string ) as xs:boolean{
  try{
  matches( muURL:getScheme( $u ) ,'^https?$')
    } catch * {
	false()
    }
};


declare
function muURL:url-hier_part( $u   ) {
substring-after( $u, ':' )
};


(:
The authority component is preceded by a double slash "//" and is
terminated by the next slash "/", question-mark "?", or by the end of
the URI.  Within the authority component, the characters ";", ":",
"@", "?", and "/" are reserved.

 authority   = [ userinfo "@" ] host [ ":" port ]

we are after  the host part and will drop  'userinfo' and 'port'

:)

declare
function muURL:getAuthority( $u  as xs:string ) {
let $start :=
	if( not( contains( $u, '//')) )
	    then (
		fn:error(fn:QName('http://markup.co.nz/#muURL',
				  'urlHasNoAuthority'),
				  'url has no authority component: the authority component is preceded by a double slash "//" ')
		)
	else( substring-after( $u, '//' ) )

let $input :=
    if( matches($start,'^.+/') ) then ( substring-before(  $start , '/' ))
    else if( matches($start,'^.+\?') ) then ( substring-before(  $start , '?' ))
    else($start)

let $IPv4address := '[0-9]+((\.[0-9]+){3})'
let $toplabel    := '[a-zA-Z](([a-zA-Z0-9\-])*[a-zA-Z0-9])?'
let $domainlabel := '[a-zA-Z0-9](([a-zA-Z0-9\-])*[a-zA-Z0-9])?'
let $pattern := $domainlabel || '(\.' || $toplabel || '){1,2}'

let $flags := ''

return
    if( matches(  $input, $pattern))
       then ( $input )
    else(
	fn:error(fn:QName('http://markup.co.nz/#muURL',
			  'urlHasBadAuthority'),
			  'url has bad authority component')
    )
};

(:
/(?:\\@[_a-zA-Z0-9]{1,17})|(?:(?:(?:(?:http|https|irc)?:\\/\\/(?:(?:[!$&-.0-9;=?A-Z_a-z]|(?:\\%[a-fA-F0-9]{2}))+(?:\\:(?:[!$&-.0-9;=?A-Z_a-z]|(?:\\%[a-fA-F0-9]{2}))+)?\\@)?)?(?:(?:(?:[a-zA-Z0-9][-a-zA-Z0-9]*\\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|j[emop]|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|museum|m[acdeghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\\:\\d{1,5})?)(?:\\/(?:(?:[!#&-;=?-Z_a-z~])|(?:\\%[a-fA-F0-9]{2}))*)?)(?=\\b|\\s|$)/

accept a registered domain name
not sure about this, what about subdomains
:)
declare
function muURL:hasAcceptableAuthority( $u  as xs:string ) as xs:boolean {
let $input := 	muURL:getAuthority( $u )
let $toplabel    := '[a-zA-Z](([a-zA-Z0-9\-])*[a-zA-Z0-9])?'
let $domainlabel := '[a-zA-Z0-9](([a-zA-Z0-9\-])*[a-zA-Z0-9])?'
let $pattern :=  '^' || $domainlabel || '(\.' || $toplabel || '){1,3}'	 || '$'
return
  try{
  matches( $input , $pattern)
    } catch * {
	false()
    }
};


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
    muURL:getScheme( $base ) ||
    '://'   ||
    muURL:getAuthority($base ) ||
    muURL:urlAbsolutePath( $base   )


return

resolve-uri($relative, $normalized-url)
};
