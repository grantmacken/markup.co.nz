xquery version "3.0";
module namespace trigger = "http://exist-db.org/xquery/trigger";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";
declare namespace repo="http://exist-db.org/xquery/repo";

import module namespace system = "http://exist-db.org/xquery/system";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";

(:http://localhost:8080/exist/apps/doc/triggers.xml:)


declare function trigger:update-remote( $uri as xs:anyURI ) {
util:eval-async(xs:anyURI('local-to-remote.xq'))
};


declare function trigger:after-create-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};
