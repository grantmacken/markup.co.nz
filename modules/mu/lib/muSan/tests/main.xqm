xquery version "3.0";

(:~
This module provides the functions that test my cache functions

@author Grant MacKenzie
@version 1.0

:)
module namespace st="http://markup.co.nz/#st";
import module namespace http = "http://expath.org/ns/http-client";
import module namespace muSan = "http://markup.co.nz/#muSan" at "../muSan.xqm";
import module namespace muCache = "http://markup.co.nz/#muCache" at "../../muCache/muCache.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare function test:setup(){
()
};

declare function test:testdown(){
()
};


(:

declare
    %test:name("given URL with unkown domain")
    %test:args('http://xmarkupx.co.nz' )
    %test:assertXPath("$result[1][local-name(.) eq 'html']")
function st:get_0( $url ){
 muCache:get( $url  )
};

:)

declare
    %test:name("given URL ( on my site) get doc ")
    %test:args( 'http://markup.co.nz/archive/2014/04/24/receiving-webmentions')
    %test:assertExists
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("$result[1][local-name(.) eq 'html']")
function st:fake-fetch($url){
muSan:fake-fetch($url)
};

declare
    %test:name("given URL ( on my site) is base in doc ")
    %test:args( 'http://markup.co.nz/archive/2014/04/24/receiving-webmentions')
    %test:assertExists
function st:fake-isBaseInDoc($url){
muSan:fake-isBaseInDoc($url)
};

declare
    %test:name("given URL ( on my site) get base URL")
    %test:args( 'http://markup.co.nz/archive/2014/04/24/receiving-webmentions')
    %test:assertExists
function st:fake-getBase($url){
muSan:fake-getBase($url)
};

declare
    %test:name("given URL ( on my site) sanitize markup ")
    %test:args( 'http://markup.co.nz/archive/2014/04/24/receiving-webmentions')
    %test:assertExists
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result) eq 'html'")
    %test:assertXPath("$result/head/title[text()]")
    (:%test:assertXPath("$result/meta"):)
function st:sanitizer_0($url){
muSan:fake-sanitizer($url)
};

declare
    %test:name("given URL ( on bridgy ) sanitize markup ")
    %test:args( 'https://brid-gy.appspot.com/like/twitter/chloeweil/470602560886161408/221429335')
    %test:assertExists
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result) eq 'html'")
    %test:assertXPath("$result/head/title[text()]")
function st:sanitizer_1($url){
muSan:fake-sanitizer($url)
};

declare
    %test:name("given URL ( on mdn ) sanitize markup ")
    %test:args( 'https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Content_categories')
    %test:assertExists
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result) eq 'html'")
    %test:assertXPath("$result/head/title[text()]")
function st:sanitizer_2($url){
muSan:fake-sanitizer($url)
};

declare
    %test:name("given URL ( on html5 doctor ins-del ) sanitize markup ")
    %test:args( 'http://html5doctor.com/ins-del-s')
    %test:assertExists
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result) eq 'html'")
    %test:assertXPath("$result/body//del[1]")
function st:sanitizer_3($url){
muSan:fake-sanitizer($url)
};
