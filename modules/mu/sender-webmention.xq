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
let  $username := $permissions/@user/string()
let  $password := $permissions/@password/string()

let $uri := doc(concat($app-root, "/data/uri.xml"))//@href/string()

let  $local-ip := doc(concat($app-root, "/data/hosts.xml"))//local/string()
let  $remote-ip := doc(concat($app-root, "/data/hosts.xml"))//remote/string()


let $uriSource :=
   'http://' || substring-after(substring-before($uri, '/data/'), '/apps/') ||
   '/' || substring-before(substring-after($uri, '/data/'), '.xml')

(: my URL  Where I might be  mentioning something else :)

(:
http:send-request($reqGet)[2])//atom:content/node()

A post might might a URL

  http://aaronparecki.com/notes/2014/02/17/1/reporter

Get My Document

 server does webmention discovery on Aaron's post to
 find its webmention endpoint (if not found, process stops)

let $urlWebmentionDiscovery := 'http://aaronparecki.com/notes/2014/02/17/1/reporter'

http://markup.co.nz/archive/2014/02/20/134220

http://markup.co.nz/archive/2014/02/20/091049
:)

(: :)

let $reqSource :=
<http:request   href="{ $uriSource }"
                method="get"
                timeout="4"
>
<http:header name = "Connection"
value = "close"/>
</http:request>

let $httpSource := http:send-request($reqSource)//*[@class="h-entry"]//*[@class="e-content"]

let $seqSourceAnchors := $httpSource//a/@href/string()
(:TODO map of for for sequence:)


(:~
1. from our source entry content we discover anchors which may mention other sites
2. we make a request to other site to find if it supports webmentions $getWebmentionEndPoint
3. we post to the webmention endpoint with source and target parameters

~:)

let $urlWebmentionDiscovery := $seqSourceAnchors[1]
let $reqWebmentionDiscovery :=
<http:request   href="{ $urlWebmentionDiscovery }"
                method="get"
                timeout="4"
>
<http:header name = "Connection"
value = "close"/>
</http:request>


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


let $getWebmentionEndPoint := function(){
    let $page := http:send-request($reqWebmentionDiscovery)
    return
    if( not(empty($getWebMentionLinkInHeader($page)))) then $getWebMentionLinkInHeader($page)
    else if( not(empty($getWebMentionLinkInHead($page)))) then $getWebMentionLinkInHead($page)
    else ( )
}

(: return if empty :)



let $uriSendWebmention := function(){
   let $source :=
   'http://' || substring-after(substring-before($uri, '/data/'), '/apps/') ||
   '/' || substring-before(substring-after($uri, '/data/'), '.xml') (: my URL  Where I am mentioning  :)
   let $target := $urlWebmentionDiscovery (: What I am mentioning  :)
   let $webmentionEndPoint := $getWebmentionEndPoint()
    return
        ( concat( $webmentionEndPoint , '?', 'source=',$source  , '&amp;', 'target=',$target  ) )
}


let $reqWebmentionPost :=
    <http:request   href="{ $uriSendWebmention() }"
                    method="get"
                    timeout="4"
    >
    <http:header name = "Connection"
    value = "close"/>
    </http:request>

return
if( empty($getWebmentionEndPoint()) ) then ()
else(
(
'reqWebmentionDiscovery: ' || $urlWebmentionDiscovery ,
'getWebmentionEndPoint: ' || $getWebmentionEndPoint(),
'uriSendWebmention: ' || $uriSendWebmention(),
'SEND TO Webmention endpoint',
http:send-request( $reqWebmentionPost)
)

)
