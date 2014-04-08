xquery version "3.0";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace system = "http://exist-db.org/xquery/system";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session = "http://exist-db.org/xquery/session";

let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $permissions  :=  doc(concat($app-root, "/repo.xml"))/repo:meta/repo:permissions
let $username := $permissions/@user/string()
let $password := $permissions/@password/string()
let $link := doc(concat($app-root, "/data/upload-link-atom.xml"))//@href/string()
let $sourceURL := doc($link)//atom:link[@rel="alternate" ]/@href/string()
let $targetURL := doc($link)//atom:link[@rel="in-reply-to" ]/@href/string()

let $getWebMentionLinkInHeader := function( $page ){
  let $string := $page//http:header[@name='link'][contains(./@value/string() , 'rel="webmention"')]/@value/string()
  return
  if (empty($string)) then ()
  else(
   substring-after( substring-before($string , '>'), '<')
  )
}

let $getWebMentionLinkInHead := function( $page ){
  $page//xhtml:link[@rel="webmention"]/@href/string()
}

let $wmEndPoint :=
    let $page := http:send-request(<http:request   href="{ $targetURL }"
                method="get"
                timeout="4"
                    >
                    <http:header name = "Connection"
                    value = "close"/>
                    </http:request>)
    return
    if( not(empty($getWebMentionLinkInHeader($page)))) then $getWebMentionLinkInHeader($page)
    else if( not(empty($getWebMentionLinkInHead($page)))) then $getWebMentionLinkInHead($page)
    else ( )

let $wmPOST := if( not(empty($wmEndPoint) ) ) then (
                concat( $wmEndPoint , '?', 'source=',$sourceURL  , '&amp;', 'target=',$targetURL  )
                )
               else()

let $reqWebmentionPost :=
    <http:request   href="{ $wmPOST }"
                    method="get"
                    timeout="4"
    >
    <http:header name = "Connection"
    value = "close"/>
    </http:request>

return
 if(not(empty($wmPOST))) then(
http:send-request( $reqWebmentionPost ))
else ()
