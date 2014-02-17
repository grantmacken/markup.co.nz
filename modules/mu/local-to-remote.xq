xquery version "3.0";


declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace system = "http://exist-db.org/xquery/system";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";

(:http://localhost:8080/exist/apps/doc/triggers.xml:)

let $uri := '/db/apps/markup.co.nz/data/archive/2014/02/15/082225.xml'
let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $permissions  :=  doc(concat($app-root, "/repo.xml"))/repo:meta/repo:permissions
let  $username := $permissions/@user/string()
let  $password := $permissions/@password/string()
let  $priority := 'info'
let  $local := 'http://localhost:8080'
let  $remote := 'http://120.138.18.126:8080'
let  $rest := '/exist/rest'
let  $urlLocal := $local || $rest || $uri
let  $urlRemote := $remote || $rest || $uri
let  $message := 'mu:update ' || $urlLocal
let $reqGet := <http:request href="{ $urlLocal }"
method="get"
username="{ $username }"
password="{ $password }"
auth-method="basic"
send-authorization="true"
timeout="4"
>
<http:header name = "Connection"
value = "close"/>
</http:request>



let $reqPut := <http:request href="{ $urlRemote }"
method="put"
username="{ $username }"
password="{ $password }"
auth-method="basic"
send-authorization="true"
timeout="10"
>
<http:header name = "Connection"
value = "close"/>
<http:body media-type="application/xml"/>
</http:request>

let $reqGetRemote := <http:request href="{ $urlRemote }"
method="get"
username="{ $username }"
password="{ $password }"
auth-method="basic"
send-authorization="false"
timeout="4"
>
<http:header name = "Connection"
value = "close"/>
</http:request>

(:TEST  $username, $password, $urlLocal, http:send-request($reqGet) ,  http:send-request($reqGetRemote) :)

let $inDoc := http:send-request($reqGet)[2]

return http:send-request( $reqPut , (), $inDoc)
