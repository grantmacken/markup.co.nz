xquery version "3.0";
module namespace trigger="http://exist-db.org/xquery/trigger";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace http="http://expath.org/ns/http-client";



(:import module namespace httpclient="http://exist-db.org/xquery/httpclient";:)

(:http://localhost:8080/exist/apps/doc/triggers.xml:)




declare function trigger:update-remote( $uri as xs:anyURI ) {

(: credentials :)
let  $username := 'grant'
let  $password := 'ntere37'
let  $priority := 'info'
let  $local := 'http://localhost:8080'
let  $remote := 'http://120.138.18.126:8080'
let  $rest := '/exist/rest/'
let  $urlLocal := $local || $rest || $uri
let  $urlRemote := $remote || $rest || $uri
(:let  $message := 'mu:update ' || $urlLocal:)
(:let  $sendMsg := util:log($priority,$message):)
(:let  $message := 'mu:update ' || 'send_request_expathClient':)
(:let  $sendMsg := util:log($priority,$message):)
let $reqGet :=   <http:request href="{ $urlLocal }"
                            method="get"
                            username="{ $username }"
                            password="{ $password }"
                            auth-method="basic"
                            send-authorization="true"/>

let $inDoc :=   http:send-request($reqGet)[2]

let $reqPut :=   <http:request href="{ $urlRemote }"
                            method="put"
                            username="{ $username }"
                            password="{ $password }"
                            auth-method="basic"
                            send-authorization="true">
                            <http:body media-type="application/xml"/>
                </http:request>

let $outResult :=  http:send-request($reqPut, (), $inDoc )

 return ()
};


declare function trigger:after-create-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    trigger:update-remote($uri)
};

