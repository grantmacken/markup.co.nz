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
let  $priority := 'info'

let $app-root  :=  $uri

let  $message := 'mu:update ' || $app-root

let  $sendMsg := util:log($priority,$message)

(:let $permissions  :=  doc(concat($trigger:app-root, "/repo.xml"))/repo:meta/repo:permissions;:)
(:let  $username := $permissions/@user/string():)
(:let  $password := $permissions/@password/string():)
(::)
(:let $req  := function($uri, $username, $password ){:)
(:    let  $priority := 'info':)
(:    let  $local := 'http://localhost:8080':)
(:    let  $remote := 'http://120.138.18.126:8080':)
(:    let  $rest := '/exist/rest':)
(:    let  $urlLocal := $local || $rest || $uri:)
(:    let  $urlRemote := $remote || $rest || $uri:)
(::)
(::)
(:    let $reqGet :=   <http:request href="{ $urlLocal }":)
(:                            method="get":)
(:                            username="{ $username }":)
(:                            password="{ $password }":)
(:                            auth-method="basic":)
(:                            send-authorization="true":)
(:                            timeout="2":)
(:                            >:)
(:                            <http:header    name = "Connection":)
(:                                            value = "close"/>:)
(:            </http:request>:)
(::)
(:    let $inDoc := http:send-request($reqGet)[2]:)
(:    let  $message := 'mu:update ' || $urlLocal:)
(:    let  $sendMsg := util:log($priority,$message):)
(:    let  $message := 'mu:update ' || 'send_request_expathClient':)
(:    let $reqPut :=   <http:request href="{ $urlRemote }":)
(:                            method="put":)
(:                            username="{ $username }":)
(:                            password="{ $password }":)
(:                            auth-method="basic":)
(:                            send-authorization="true":)
(:                            timeout="2":)
(:                            >:)
(:                           <http:header    name = "Connection":)
(:                                            value = "close"/>:)
(:                            <http:body media-type="application/xml"/>:)
(:                </http:request>:)
(:    let $outDoc := http:send-request($reqPut, (), $inDoc )[2]:)
(:    return  ():)
(:    }:)

(:util:eval-async($expression as item()):)
(:return   util:eval-inline($uri , "$req($uri)"):)
(:return util:eval-async("$req($uri, $username, $password)"):)
return ()
};


declare function trigger:after-create-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};
