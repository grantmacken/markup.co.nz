xquery version "3.0";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";
declare namespace  app =  "http://www.w3.org/2007/app";

declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace system = "http://exist-db.org/xquery/system";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session = "http://exist-db.org/xquery/session";

(: this is happening async yea yea yea :)

let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $permissions  :=  doc(concat($app-root, "/repo.xml"))/repo:meta/repo:permissions
let  $username := $permissions/@user/string()
let  $password := $permissions/@password/string()

let $uri := doc(concat($app-root, "/data/upload-link-atom.xml"))//@href/string()
let  $local-ip := doc(concat($app-root, "/data/hosts.xml"))//local/string()
let  $remote-ip := doc(concat($app-root, "/data/hosts.xml"))//remote/string()

let  $local := 'http://'  || $local-ip  || ':8080'
let  $remote := 'http://' || $remote-ip || ':8080'
let  $rest := '/exist/rest'
let  $urlLocal := $local || $rest || $uri
let  $urlRemote := $remote || $rest || $uri

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

let $reqPut :=
    <http:request
      href="{ $urlRemote }"
      method="put"
      username="{ $username }"
      password="{ $password }"
      auth-method="basic"
      send-authorization="true"
      timeout="10">
      <http:header
         name = "Connection"
         value = "close"/>
      <http:body
         media-type="application/xml"/>
    </http:request>

let $inDoc := http:send-request($reqGet)[2]

let $isDraft :=
    if($inDoc//app:control/app:draft/string() eq 'yes') then ( true() )
    else ( false() )

let $reqGetRemote   :=
    <http:request
        href="{ $urlRemote }"
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


return
if($isDraft ) then ()
else ( http:send-request( $reqPut , (), $inDoc))
