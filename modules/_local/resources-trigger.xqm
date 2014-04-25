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
let $priority := 'info'
let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $collection-uri  :=   $app-root || '/data/jobs'
let $base := substring-before($uri , '/resources/')
let $path := substring-after($uri , '/resources/')
let $tokenizePath := tokenize($path , '/')
let $resourceType := $tokenizePath[1]
let $file := $tokenizePath[count($tokenizePath)]
let $fileName := substring-before($file , '.')
let $extension := substring-after($file , concat($fileName , '.'))
let $ext := translate($extension, '.', '-')
let $resource-name  :=   'upload-link-' || $ext || '.xml'
let $contents  :=   <link href="{$uri}" />
let $mime-type  :=   'application/xml'
let $store := xmldb:store($collection-uri, $resource-name, $contents, $mime-type)
let $uploadXQ := xs:anyURI('upload-' || $ext || '.xq')
return
switch ($ext)
   case "svg" return util:eval-async($uploadXQ)
   (:case "svg-gz" return  util:eval-async($uploadXQ):)
   (:case "css" return   util:eval-async($uploadXQ):)
   default return util:log($priority,'CAN_NOT_HANDLE_YET')
};


declare function trigger:after-create-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};
