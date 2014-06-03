xquery version "3.0";

(:~
This module provides the functions that test my url functions

@author Grant MacKenzie
@version 1.0

:)
module namespace st="http://markup.co.nz/#st";

import module namespace muURL="http://markup.co.nz/#muURL" at "../muURL.xqm";
declare namespace test="http://exist-db.org/xquery/xqsuite";


declare function test:setup(){
()
};

declare function test:testdown(){
()
};


declare
    %test:name("given 'base url' resolve 'url' (  base ends with /,   url is absolute)  ")
    %test:args('http://waterpigs.co.uk/notes/1083/' ,'/mentions/webmention/' )
    %test:assertEquals('http://waterpigs.co.uk/mentions/webmention/')
function st:url-resolve_0($url ,  $absolute  ){
 muURL:resolve( $url , $absolute  )
};


(:declare:)
(:    %test:name("given URL should return base URI"):)
(:    %test:args( 'http://markup.co.nz' ):)
(:    %test:assertExists:)
(:    %test:assertXPath("count($result) = 1"):)
(:function st:getBaseURL( $url  as xs:anyURI){:)
(:     muURL:getBaseURL($url):)
(:};:)


declare
    %test:name("given URL get a url safe hash that can stored as a file name")
    %test:args('http://markup.co.nz')
    %test:assertEquals('QqMFMuqvFRbgiL97n4Km_A')
function st:urlHash($url as xs:anyURI){
 muURL:urlHash($url )
};

declare
    %test:name("check is 'Base' In Doc given document node with no base element")
     %test:args('<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>markup.co.nz</title>
    <link href="/resources/styles/style.css" rel="Stylesheet" type="text/css" />
    <meta name="author" content="Grant MacKenzie" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script type="text/javascript" src="/resources/scripts/lib/sarissa.js"></script>
    <script type="text/javascript" src="/resources/scripts/main.js"></script>
</head>' )
   %test:assertFalse
function st:isBaseInDoc_1($node as element()) as xs:boolean{
    muURL:isBaseInDoc(  $node )
};


declare
    %test:name("check is 'Base' In Doc given document node  with base element ")
     %test:args('<head>
    <base href="http://markup.co.nz"/>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>markup.co.nz</title>
    <link href="/resources/styles/style.css" rel="Stylesheet" type="text/css" />
    <meta name="author" content="Grant MacKenzie" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script type="text/javascript" src="/resources/scripts/lib/sarissa.js"></script>
    <script type="text/javascript" src="/resources/scripts/main.js"></script>
</head>' )
  %test:assertTrue
function st:isBaseInDoc_2($node as element()) as xs:boolean{
    muURL:isBaseInDoc(  $node )
};





(: URL parts
http://www.ietf.org/rfc/rfc2396.txt


"generic URI" syntax consists of a sequence of four main components:
<scheme>://<authority><path>?<query>
:)


declare
    %test:name(" get 'scheme' component given base URL")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619')
    %test:assertEquals('http')
function st:url-scheme($base ){
 muURL:urlScheme(  xs:anyURI( $base )  )
};

declare
    %test:name(" get 'authority' component given base URL (with path and query  ) ")
    %test:args('http://markup.co.nz/webmention?target=http://markup.co.nz')
    %test:assertEquals('markup.co.nz')
function st:url-authority_1($base ){
 muURL:urlAuthority( $base  )
};


declare
    %test:name("get 'authority' component given base URL ( with / )  ")
    %test:args('http://markup.co.nz/')
    %test:assertEquals('markup.co.nz')
function st:url-authority_2($base ){
 muURL:urlAuthority(  $base )
};


declare
    %test:name("get 'authority' component given base URL base URL (scheme + authority only) should ")
    %test:args('http://markup.co.nz')
    %test:assertEquals('markup.co.nz')
function st:url-authority_3($base ){
 muURL:urlAuthority( $base  )
};

declare
    %test:name("get 'authority' component given base URL (scheme + authority + query)")
    %test:args('http://markup.co.nz?login=joe')
    %test:assertEquals('markup.co.nz')
function st:url-authority_4($base ){
 muURL:urlAuthority( $base  )
};

declare
    %test:name("get 'absolute path' component given base URL (without query)")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619')
    %test:assertEquals('/archive/2014/03/16/141619')
function st:url-abs_path_1($base ){
 muURL:urlAbsolutePath( $base  )
};

declare
    %test:name("get 'absolute path' component given base URL (with query)")
    %test:args('http://markup.co.nz/webmention?target=http://markup.co.nz')
    %test:assertEquals('/webmention')
function st:url-abs_path_2($base ){
 muURL:urlAbsolutePath( $base  )
};

declare
    %test:name("get 'absolute path' given  base URL (no path)")
    %test:args('http://markup.co.nz')
    %test:assertEquals('/')
function st:url-abs_path_3($base ){
 muURL:urlAbsolutePath( $base  )
};


declare
    %test:name("get 'query' component given base URL (with query)")
    %test:args('http://markup.co.nz/webmention?target=http://markup.co.nz')
    %test:assertEquals('target=http://markup.co.nz')
function st:url-query($base ){
 muURL:urlQuery( $base  )
};

declare
    %test:name("check url-is-relative should be false given absolute path ")
    %test:args('/archive/2014/03/16/141619')
    %test:assertFalse
function st:url-is-relative_1($path ){
 muURL:isRelative( $path )
};

declare
    %test:name("check url-is-relative should be true given relative path")
    %test:args('archive/2014/03/16/141619')
    %test:assertTrue
function st:url-is-relative_2($path ){
 muURL:isRelative( $path )
};




declare
    %test:name("given 'base' resolve 'url' (  base ends with path,   url is absolute)  ")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619' ,'/cards/me' )
    %test:assertEquals('http://markup.co.nz/cards/me')
function st:url-resolve_1($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};


declare
    %test:name("given 'base' resolve 'url' ( base ends with '/'  , url is absolute )")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619/' ,'/cards/me' )
    %test:assertEquals('http://markup.co.nz/cards/me')
function st:url-resolve_2($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};


declare
    %test:name("given 'base' resolve 'url' ( 'base' ends with 'authority' component, url is 'absolute' )")
    %test:args('http://markup.co.nz' ,'/cards/me' )
    %test:assertEquals('http://markup.co.nz/cards/me')
function st:url-resolve_3($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};

declare
    %test:name("given 'base' resolve 'url' ( url has scheme and authority so base is ignored ) ")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619' ,'http://markup.co.nz/cards/me' )
    %test:assertEquals('http://markup.co.nz/cards/me')
function st:url-resolve_4($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};

declare
    %test:name("given 'base' resolve 'url' ( base path only a /,    url is absolute)"  )
    %test:args('http://markup.co.nz/' ,'/cards/me' )
    %test:assertEquals('http://markup.co.nz/cards/me')
function st:url-resolve_5($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};

declare
    %test:name("given 'base' resolve 'url' ( base with path,  url is relative path with parent steps ../../ ) ")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619' ,'../../../../resources/images' )
    %test:assertEquals('http://markup.co.nz/resources/images')
function st:url-resolve_6($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};

declare
    %test:name("given 'base' resolve 'url' ( base with path,  url is relative)")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619' ,'141620' )
    %test:assertEquals('http://markup.co.nz/archive/2014/03/16/141620')
function st:url-resolve_7($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};

declare
    %test:name("given 'base' resolve 'url' ( base with path,  url is relative with current context './' ")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619' ,'./141620' )
    %test:assertEquals('http://markup.co.nz/archive/2014/03/16/141620')
function st:url-resolve_8($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};


declare
    %test:name("given 'base' resolve 'url' ( base,  url is only current context '.' ")
    %test:args('http://markup.co.nz' ,'.' )
    %test:assertEquals('http://markup.co.nz/')
function st:url-resolve_8($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};

declare
    %test:name("given 'base' resolve 'url' ( base no path,  url is  current context './'  with path ")
    %test:args('http://markup.co.nz' ,'./cards/me' )
    %test:assertEquals('http://markup.co.nz/cards/me')
function st:url-resolve_10($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};

declare
    %test:name("given 'base' resolve 'url' ( base no path,  url is relative ")
    %test:args('http://markup.co.nz' ,'cards/me' )
    %test:assertEquals('http://markup.co.nz/cards/me')
function st:url-resolve_11($base ,  $relative  ){
 muURL:resolve( $base , $relative  )
};
