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
														let $sourceTitle  := function($wmSource){$wmSource//title/string()}

let $sourceID := function($wmSource){
    let $id :=  $wmSource//meta[@name="taguri" ]/@content/string()
    let $seqID :=  tokenize($id , ':')

    return   map {
       'postType' := $seqID[3],
       'identifier' := $seqID[4]
       }
    }


let $conditions :=
    if( not($isTargetValidResource( $wmTarget )) ) then ( false() )
    else if( not($sourceHasTextContentType($wmSource)) )  then ( false() )
    else if( not($sourcelinksToTarget($wmSource, $target)) )  then ( false() )
    else(true())

let $local := 'http://localhost:8080'
let $rest := '/exist/rest/db/apps/'
let $domain := substring-after(substring-before( $source, '/archive/' ), 'http://')
let $seqPath := tokenize($source, '/')

let $file:= $seqPath[8]
let $path :=  string-join(
    ($seqPath[3] , $seqPath[4], $seqPath[5] , $seqPath[6] , $seqPath[7] ), '/')

let $mappedTagUri := $sourceID($wmSource)

(:  TODO PUT URL etc:)
let $uPut := $local || $rest || $path || '/xxxx' || $mappedTagUri('identifier')

let $entry :=
    <entry xmlns="http://www.w3.org/2005/Atom">
	<title>recieved mention for {$sourceTitle($wmSource) }</title>
	<author>
	    <name>TODO  Try h-entry - Domain Name Author find mention author</name>
        </author>
	<published>{ current-dateTime()}</published>
	<id>tag:{$seqPath[3]},{current-date()}:mention:2tB2</id>
	<summary/>
	<updated>{current-date()}</updated>
	<link rel="mention" type="text/html" href="{$target}"/>
	<content type="xhtml">
	 <div xmlns="http://www.w3.org/1999/xhtml">
	  [x] mentioned this [note article] {$sourceTitle($wmSource)}
	 </div>
        </content>
    </entry>




(:
   http://markup.co.nz/archive/2014/02/20/134220
   What to do with webmentions
   use markup as atom  with an entry content  h-cite
   <id>tag:markup.co.nz,2014-02-20:cite:xxxx</id>
   <link rel="mention" href="target" />
   place in archive collection



let $reqPut :=
    <http:request href="{ $urlLocal }"
                  method="put"
                  username="{ $username }"
                  password="{ $password }"
                  auth-method="basic"
                  send-authorization="true"
                  status-only="true"
                  timeout="2">
       <http:header name = "Connection" value = "close"/>
       <http:body media-type="application/xml"/>
    </http:request>



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

let $base := substring-before($target , '/archive/')
let $local := 'http://localhost:8080'
let $rest := '/exist/rest'
let $urlLocal := $local || $rest || $base || '/uri.xml'

let $put := http:send-request( $reqPut , (), $entry)


<title>134220</title>
:)
return
if($conditions) then
<div>

<p>target: {$target}</p>
<p>source: {$source}</p>
<p>$uPut: {$uPut}</p>
<p>sourceHasTextContentType: {$sourceHasTextContentType($wmSource)}</p>
<p>sourcelinksToTarget: {$sourcelinksToTarget($wmSource, $target)}</p>

<p>isTargetValidResource: { $isTargetValidResource($wmTarget)  }</p>

{$entry}

{$wmSource}
</div>
else()
