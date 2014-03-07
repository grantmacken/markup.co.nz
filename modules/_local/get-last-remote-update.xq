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

let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $permissions  :=  doc(concat($app-root, "/repo.xml"))/repo:meta/repo:permissions
let  $username := $permissions/@user/string()
let  $password := $permissions/@password/string()
let $hosts :=  doc(concat($app-root, "/data/hosts.xml"))

let $uri := doc(concat($app-root, "/data/uri.xml"))//@href/string()

return
  if( empty($uri) ) then ( 'no last update file' )
  else(
    let  $local-ip := $hosts//local/string()
    let  $remote-ip := $hosts//remote/string()

    let  $remote := 'http://' || $remote-ip || ':8080'
    let  $rest := '/exist/rest'

    let  $urlRemote := $remote || $rest || $uri

    return( $urlRemote )

    (:

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

	let $reply := http:send-request( $reqGetRemote )
	return
	(concat($reply/@status/string(), ': ', $reply/@message/string() ), $reply//atom:content/node(),  $urlRemote  )

 :)
    )
