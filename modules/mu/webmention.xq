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
import module namespace response="http://exist-db.org/xquery/response";


let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $permissions  :=  doc(concat($app-root, "/repo.xml"))/repo:meta/repo:permissions
let  $username := $permissions/@user/string()
let  $password := $permissions/@password/string()

let $getContextPath := request:get-context-path()
let $target := request:get-parameter('target',())
let $source := request:get-parameter('source',())
let $code := 202

let $statusCode :=response:set-status-code($code)


let $isTargetWebMentionLinkInHeader := function( $page ){
  let $string := $page//http:header[@name='link'][contains(./@value/string() , 'rel="webmention"')]/@value/string()
  return
  if (empty($string)) then ( not(empty($string)))
  else(
   not(empty(substring-after( substring-before($string , '>'), '<')))
  )
}

let $isTargetWebMentionLinkInHead := function( $page ){
  not(empty($page//xhtml:link[@rel="webmention"]/@href/string()))
}




(:NOTE Async out for que and verification :)
(: Verification

The receiver SHOULD check that target is a valid resource belonging to it
and that it accepts webmentions.

The receiver SHOULD perform a HTTP GET
request on source to confirm that it actually links to target (note that the
receiver will need to check the Content-Type of the entity returned by
source to make sure it is a textual response)

:)


let $reqTarget :=
    <http:request href="{ $target }" method="get" timeout="2">
	<http:header name="Connection" value="close" />
    </http:request>

let $reqSource :=
    <http:request href="{ $source }" method="get" timeout="2">
	<http:header name="Connection" value="close" />
    </http:request>

let $wmTarget := http:send-request( $reqTarget )

let $isTargetValidResource := function($wmTarget){
    if($isTargetWebMentionLinkInHeader($wmTarget)) then (true())
    else if ($isTargetWebMentionLinkInHead($wmTarget)) then (true())
    else (false())
    }

let $wmSource := http:send-request( $reqSource )

let $sourceHasTextContentType := function( $page ){
  let $string := $page//http:header[@name="content-type"][contains(./@value/string() , 'text/html')]/@value/string()
  return
  not(empty($string))
}

let $sourcelinksToTarget  := function($wmSource, $target){not(empty($wmSource//*[@class="h-entry"]//*[@class="e-content"]//a[@href=$target]))}

let $conditions :=
    if( not($isTargetValidResource( $wmTarget )) ) then ( false() )
    else if( not($isTargetValidResource( $wmTarget )) )  then ( false() )
    else if( not($sourceHasTextContentType($wmSource)) )  then ( false() )
    else if( not($sourcelinksToTarget($wmSource, $target)) )  then ( false() )
    else(true())
(:
   What to do with webmentions
   use markup as atom  with an entry content  h-cite
   <id>tag:markup.co.nz,2014-02-20:cite:xxxx</id>
   <link rel="mention" href="target" />
   place in archive collection

:)

let $entry :=
    <entry xmlns="http://www.w3.org/2005/Atom">
	<title>134220</title>
	<author>
	    <name>Grant MacKenzie</name>
      </author>
	<published>2014-02-20T13:42:25</published>
	<id>tag:markup.co.nz,2014-02-20:cite:2tB2</id>
	<summary/>
	<updated>2014-02-20</updated>
	<link rel="mention" type="text/html" href="{$target}"/>
	<content type="xhtml">
	 <div xmlns="http://www.w3.org/1999/xhtml">
	  [x] mentioned this [note article]
	 </div>
        </content>
    </entry>

return
if($conditions) then
<div>
<p>sourceHasTextContentType: {$sourceHasTextContentType($wmSource)}</p>
<p>sourcelinksToTarget: {$sourcelinksToTarget($wmSource, $target)}</p>

<p>isTargetValidResource: {$sourceHasTextContentType($wmTarget)}</p>
<p>isTargetValidResource: { $isTargetValidResource($wmTarget)  }</p>
{$wmSource}
</div>
else()
