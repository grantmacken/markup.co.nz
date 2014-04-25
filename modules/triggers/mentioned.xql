xquery version "3.0";
module namespace trigger = "http://exist-db.org/xquery/trigger";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";
declare namespace repo="http://exist-db.org/xquery/repo";

import module namespace system = "http://exist-db.org/xquery/system";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";

(:
  http://localhost:8080/exist/apps/doc/triggers.xml
  https://www.ibm.com/developerworks/library/x-expath/
:)

declare function trigger:update-remote( $uri as xs:anyURI ) {
let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $app-path  :=   substring-after( $app-root ,'//')
let $domain  :=   substring-after( $app-root ,'/apps/')
let $logger-name := $domain || '.log'
let $priority := 'info'
let $message :=  $resource-name || ': '  || $uri
let $logApp := util:log-app($priority, $logger-name, $message )
(:
let $collection-uri  :=   $app-root || '/data/jobs'
let $resource-name  :=   'upload-link-atom.xml'
let $contents  :=   <link href="{$uri}" />
let $mime-type  :=   'application/xml'

let $store := xmldb:store($collection-uri, $resource-name,
$contents, $mime-type)

let $logApp := util:log-app($priority, $logger-name, $store )

let $eval := util:eval-async(xs:anyURI('upload-atom.xq'))
:)
return ()
};


declare function trigger:after-create-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};
