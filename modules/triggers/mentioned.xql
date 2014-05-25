xquery version "3.0";
module namespace trigger = "http://exist-db.org/xquery/trigger";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";
import module namespace util = "http://exist-db.org/xquery/util";


(:
  http://localhost:8080/exist/apps/doc/triggers.xml
  https://www.ibm.com/developerworks/library/x-expath/
:)

declare function trigger:update-mention( $uri as xs:anyURI ) {
let $priority := 'info'
let $message := '[update-mention](' || $uri || ')'
let $log := util:log($priority, $message )

(:let $doc := doc( $uri ):)
(:let $resource-name := util:document-name( $doc ):)
(:let $log := util:log($priority, '[webmention](' || $resource-name || ')' ):)
(::)
(::)
(::)
(:(::):)
(:let $collection-mentions  :=   $app-root || '/data/mentions':):)
(:let $mime-type  :=   'application/xml':)

(:let $resource-name  :=   'upload-link-atom.xml':)
(:let $contents  :=   <link href="{$uri}" />:)
(:let $mime-type  :=   'application/xml':)
(::)
(:let $store := xmldb:store($collection-uri, $resource-name,:)
(:$contents, $mime-type):)
(::)
(:let $logApp := util:log-app($priority, $logger-name, $store ):)
(::)
(:let $eval := util:eval-async(xs:anyURI('upload-atom.xq')):)
:)
return ()
};


declare function trigger:after-create-document($uri as xs:anyURI) {
    trigger:update-mention($uri)
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    trigger:update-mention($uri)
};
