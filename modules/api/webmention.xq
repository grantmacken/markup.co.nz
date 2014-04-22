xquery version "3.0";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";


declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace system = "http://exist-db.org/xquery/system";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace response="http://exist-db.org/xquery/response";

import module namespace mf2="http://markup.co.nz/#mf2"  at '../mu/mf2.xqm';
import module namespace note="http://markup.co.nz/#note"  at '../mu/note.xqm';
import module namespace utility = "http://markup.co.nz/#utility"  at '../mu/utility.xqm';

let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $getContextPath := request:get-context-path()

(: target Thats ME: you are mentioning my URL as a target :)
let $target := request:get-parameter('target',())

(: $source Thats YOU:  you are mentioning your URL as a source:)
let $source := request:get-parameter('source',())
let $code := 202
let $redirectURL := 'http://markup.co.nz/error'

let $local := 'http://120.138.18.126:8080'
let $rest := 'exist/rest/db/apps'
let $domain := substring-after(substring-before( $target, '/archive/' ), 'http://')

(:
TODO: to make responsive add job to que
set status then async out to carry out job
:)

let $continue := if( empty($target) or  empty($source) ) then (
      response:redirect-to($redirectURL)
      )
    else( response:set-status-code($code) )


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
    <http:request href="{ $target }" method="get" timeout="5">
	<http:header name="Connection" value="close" />
    </http:request>

let $reqSource :=
    <http:request href="{ $source }" method="get" timeout="5">
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

let $sourcelinksToTarget  := function($wmSource, $target){not(empty($wmSource//*[@class="h-entry"]//xhtml:a[@href=$target]))}
let $sourceTitle  := function($wmSource){$wmSource//xhtml:title/string()}

(:wrong I'm the target:)
let $sourceID := function($wmSource){
    let $id :=  $wmSource//xhtml:meta[@name="taguri" ]/@content/string()
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

(: a unique id :)
let $idHash := utility:urlHash( $source || $target)

let $uTemp :=  string-join(( $local , $rest , $domain , 'data/temp'  , $idHash || '.xml'), '/')
let $reqPut:=  <http:request href="{$uTemp}"
                  method="put"
                  username="grant"
                  password="ntere37"
                  auth-method="basic"
                  send-authorization="true"
                  status-only="false"
                  timeout="5">
       <http:header name = "Connection" value = "close"/>
       <http:body media-type="application/xml"/>
    </http:request>

let $mention := <mention target="{$target}" source="{$source}">
{$wmSource}
</mention>
(:
http:send-request( $req, () ,  $mention   )
let $put := http:send-request( $reqPut , (), $mention )


:)

let $putTemp := if($conditions) then(
  )else()

return
if($conditions) then
<div>
<h1>REMOTE SUCCESS: met conditions for a valid mention</h1>
<p>someone is mentioning my page - target: {$target}</p>
<p>mentioning my page on thier page - source: {$source}</p>
<p>Created this mention in date stamped mentions folder</p>
<p>URL: { $uTemp }</p>
<div>
<h2>PUT mention </h2>
    {$mention}
</div>
<div>
 <h2>PUT response</h2>
    { http:send-request( $reqPut , (), $mention ) }
</div>
</div>
else(
<div>
    <h1>FAILURE: failed to met conditions for a valid mention</h1>
    <p>sourceHasTextContentType: {$sourceHasTextContentType($wmSource)}</p>
    <p>sourcelinksToTarget: {$sourcelinksToTarget($wmSource, $target)}</p>
    <p>isTargetValidResource: { $isTargetValidResource($wmTarget)  }</p>
</div>
)
