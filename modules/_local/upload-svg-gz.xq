xquery version "3.0";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";
declare namespace  app =  "http://www.w3.org/2007/app";

declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace system = "http://exist-db.org/xquery/system";
import module namespace http = "http://expath.org/ns/http-client";

let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $app-path  :=   substring-after( $app-root ,'//')
let $domain  :=   substring-after( $app-root ,'/apps/')
let $hosts := 	doc(concat($app-root, "/data/hosts.xml"))
let  $username := $hosts/hosts/@user/string()
let  $password := $hosts/hosts/@password/string()
let  $local-ip := $hosts/hosts/local/string()
let  $remote-ip := $hosts/hosts/remote/string()
(:let $fileRoot := /usr/local/eXist/webapp/WEB-INF/data/fs/db/apps/ || $domain:)

let $uri := doc(concat($app-root, "/data/jobs/upload-link-svg-gz.xml"))//@href/string()
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

let $in := http:send-request($reqGet)
let $inMediaType := $in[1]//*[@media-type]/@media-type/string()
let $inBin := $in[2]
let $reqPut :=
    <http:request
      href="{ $urlRemote }"
      method="put"
      username="{ $username }"
      password="{ $password }"
      auth-method="basic"
      send-authorization="true"
      timeout="20">
      <http:header
         name = "Connection"
         value = "close"/>
      <http:body
         media-type="{$inMediaType}"
    	 method="binary"
    	 src="{$uri}"
	 />
    </http:request>

return
http:send-request( $reqPut )
