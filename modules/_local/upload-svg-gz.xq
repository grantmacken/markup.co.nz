xquery version "3.0";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";
declare namespace  app =  "http://www.w3.org/2007/app";

declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace system = "http://exist-db.org/xquery/system";
import module namespace http = "http://expath.org/ns/http-client";


let $file-root := /usr/local/eXist/webapp/WEB-INF/data/fs/db/apps/


let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $repoDoc  :=  doc(concat($app-root, "/repo.xml"))
let $target  :=  $repoDoc/repo:meta/repo:target/string()
let $permissions  :=  $repoDoc/repo:meta/repo:permissions
let  $username := $permissions/@user/string()
let  $password := $permissions/@password/string()

let $fileRoot := /usr/local/eXist/webapp/WEB-INF/data/fs/db/apps/ ||$target


let $uri := doc(concat($app-root, "/data/upload-link-svg-gz.xml"))//@href/string()
let  $local-ip := doc(concat($app-root, "/data/hosts.xml"))//local/string()
let  $remote-ip := doc(concat($app-root, "/data/hosts.xml"))//remote/string()

let  $local := 'http://'  || $local-ip  || ':8080'
let  $remote := 'http://' || $remote-ip || ':8080'
let  $rest := '/exist/rest'
let  $urlLocal := $local || $rest || $uri
let  $urlRemote := $remote || $rest || $uri


(: http:send-request( $reqPut , (), $inDoc) :)
return
($fileRoot)
