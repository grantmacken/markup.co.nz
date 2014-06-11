xquery version "3.0";

(:~
This module provides the functions that test my muCache functions

@author Grant MacKenzie
@version 1.0
http://markup.co.nz/archive/2014/03/16/141619
:)
module namespace st="http://markup.co.nz/#st";
import module namespace http = "http://expath.org/ns/http-client";
import module namespace muCache = "http://markup.co.nz/#muCache" at "../muCache.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";



declare function test:setup(){
()
};

declare function test:testdown(){
()
};


declare
    %test:name("given good URL( http://markup.co.nz/archive/2014/03/16/141619 )  get sanitized node ")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619')
    %test:assertXPath("$result[1]")
    %test:assertXPath(" local-name( $result[1] ) eq 'html'")
function st:get_1( $url as xs:string ) {
    try {  muCache:get( $url ) }
    catch * {()}
};

(:

declare
    %test:name("given good URL(http://www.example.com) get sanitized node ")
    %test:args('http://www.example.com')
    %test:assertXPath("$result[1]")
    %test:assertXPath(" local-name( $result[1] ) eq 'html'")
function st:get_2( $url as xs:string ) {
    try {  muCache:get( $url ) }
    catch * {()}
};
:)

declare
    %test:name("given bad URL (.com ) get problem ")
    %test:args('.com')
    %test:assertXPath("$result[1]")
    %test:assertXPath(" local-name( $result[1] ) eq 'problem'")
function st:get_3( $url as xs:string ) {
    try {  muCache:get( $url ) }
    catch * {()}
};



declare
    %test:name("given URL(http://markup.co.nz/xxx) get problem")
    %test:args('http://markup.co.nz/xxx/2014/03/16')
    %test:assertXPath("$result[1]")
    %test:assertXPath("$result[1]//status/number() eq 404")
function st:get_4( $url as xs:string ) {
    try {  muCache:get( $url ) }
    catch * {()}
};

declare
    %test:name("given URL ( httpstat.us/404 )  get problem")
    %test:args('http://httpstat.us/404')
    %test:assertXPath("$result[1]")
    %test:assertXPath("$result[1]//status/number() eq 404")
function st:get_5( $url as xs:string ) {
    try {  muCache:get( $url ) }
    catch * {()}
};

declare
    %test:name("given URL ( httpstat.us/500 )  get problem")
    %test:args('http://httpstat.us/500')
    %test:assertXPath("$result[1]")
    %test:assertXPath("$result[1]//status/number() eq 500")
function st:get_6( $url as xs:string ) {
    try {  muCache:get( $url ) }
    catch * {()}
};

declare
    %test:name("given unregistered URL (http://xmarkup.co.nz)  get problem")
    %test:args('http://xmarkup.co.nz/archive/2014/03/16/141619')
    %test:assertXPath("$result[1]")
    %test:assertXPath(" local-name( $result[1] ) eq 'problem'")
function st:get_7( $url as xs:string ) {
    try {  muCache:get( $url ) }
    catch * {()}
};


declare
    %test:name("given URL fetch stored doc")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619')
    %test:assertXPath("$result[1]")
function st:fetch( $url ) {
    try {  muCache:fetch( $url ) }
    catch * {()}
};

declare
    %test:name("given URL get and store sanitized node")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619')
    %test:assertXPath("$result[1]")
    %test:assertXPath("doc-available(string($result[1]))")
    %test:assertEquals("/db/apps/markup.co.nz/data/cache/mNDHZ5vca-NYcwoWxWg4fw.xml")
function st:store( $url ) {
    try {  muCache:store( $url ) }
    catch * {()}
};

