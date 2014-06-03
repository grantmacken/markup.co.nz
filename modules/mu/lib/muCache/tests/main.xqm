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
    %test:name("given URL get sanitized node ")
    %test:args('http://markup.co.nz/archive/2014/03/16/141619')
    %test:assertXPath("$result[1]")
function st:get( $url ) {
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
