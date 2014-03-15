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
let $message1 := 'mu:update ' || $uri
let $base := substring-before($uri , '/archive/')
let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $permissions  :=  doc(concat($app-root, "/repo.xml"))/repo:meta/repo:permissions
let $username := $permissions/@user/string()
let $password := $permissions/@password/string()
let $priority := 'info'
let $local := 'http://localhost:8080'
let $rest := '/exist/rest'
let $urlLocal := $local || $rest || $base || '/upload-link-atom.xml'
let $message1 := 'mu:update ' || $urlLocal
let $reqPut :=
    <http:request href="{ $urlLocal }"
                  method="put"
                  username="{ $username }"
                  password="{ $password }"
                  auth-method="basic"
                  send-authorization="true"
                  status-only="true"
                  timeout="2">
       <http:header name = "Connection" value = "close"/>
       <http:body media-type="application/xml"/>
    </http:request>

let $link := <link href="{$uri}" />
let $put := http:send-request( $reqPut , (), $link)
let $message := concat($put/@status/string(), ': ' ,$put/@message/string())
let $log := (util:log($priority,$link), util:log($priority, $message))
(:let $eval := util:eval-async(xs:anyURI('upload-atom.xq')):)
return ()
};


declare function trigger:after-create-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};
