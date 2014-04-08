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


import module namespace mf2="http://markup.co.nz/#mf2"  at '../mu/mf2.xqm';
import module namespace note="http://markup.co.nz/#note"  at '../mu/note.xqm';
import module namespace utility = "http://markup.co.nz/#utility"  at '../mu/utility.xqm';

let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $permissions  :=  doc(concat($app-root, "/repo.xml"))/repo:meta/repo:permissions
let  $username := $permissions/@user/string()
let  $password := $permissions/@password/string()

let $getContextPath := request:get-context-path()

(: target Thats ME: you are mentioning my URL as a target :)
let $target := request:get-parameter('target',())

(: $source Thats YOU:  you are mentioning your URL as a source:)
let $source := request:get-parameter('source',())
let $code := 202

let $statusCode := response:set-status-code($code)


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

let $sourcelinksToTarget  := function($wmSource, $target){not(empty($wmSource//*[@class="h-entry"]//a[@href=$target]))}
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

(: What to do with webmentions
http://indiewebcamp.com/comment#Accept_a_comment


when your server receives a webmention URL:

1. concat and hash source and target URL this provides a unique identifier for crud op.
    If we get a mention update we can put to overwrite or delete
2. where to store in db. in archive
    date of mentions target i.e. same same datePath  my resource
    /data/mentions/{year}/{month}/{day}/$idHash

    so from page we can look for mentions in same datePath as the page datePath

2. what mention types  ref: bridgy

     h-entry  h-as-comment
         u-in-reply-to   u-comment-of
         u-like-of u-favorite-of prps
         u-repost-of retweet.



   like citations store a microformated markup.
    http://indiewebcamp.com/comments-presentation

    Parse.

2. what to store

   like citations store a microformated markup.
    http://indiewebcamp.com/comments-presentation

    Parse.


    h-as-repost



:)

(: a unique id :)
let $idHash := utility:urlHash($source || $target)

let $local := 'http://localhost:8080'
let $rest := 'exist/rest/db/apps'
let $domain := substring-after(substring-before( $target, '/archive/' ), 'http://')
let $archivePath := substring-after( $target, '/archive/' )
let $seqPath := tokenize($archivePath, '/')
let $year := $seqPath[1]
let $month := $seqPath[2]
let $day :=  $seqPath[3]

(: we store our mentions in the same dataPath as the archive :)
let $datePath :=  string-join(($year , $month, $day ) , '/')

(:

(:  get commenter information to display

    if the h-entry has a p-author, use its h-card:
    otherwise get the first* rel-author link on the page, retrieve the URL it points to, and use its representative h-card:
        logo/photo
        name
        url (of commenter profile/homepage)

        :)

let $getCommenterAuthorShip := function(){
 ('TODO author')
()
}



(:
if the h-entry has an e-content, and if the text is not too long (per your own site UI preference/design, but note that "too long" may be both by character/word count or by number of lines if the content contains newlines), use that, after filtering out unsafe HTML
    if there is no e-content or it's too long, then
        if the h-entry has a p-summary, and the text is not too long, use that (useful author crafted summary or for longer posts where only a part of it is the comment)
            if the p-summary is too long (per your own site UI preference/design), then truncate the p-summary yourself
        else truncate the e-content (if any) yourself.
    otherwise (no e-content and no p-summary), if it has a p-name, use that
        if the p-name is too long (per your own site UI preference/design)
        then truncate the p-name yourself.
    if the text of the comment is too long (your site, your judgment), abbreviate it with some intelligent ellipsing code (e.g. see POSSEing an abbreviated note to Twitter for some thinking) and provide a "See more" link to the permalink.
:)

let $getMoreCommentInfoToDisplay := function( ){
(:dt-published:)
 ()
}


let $getWhereToAddOnPage := function( ){
 if($srcInReplyToHyperlink) then ( 'main' )
 else( (: http://indiewebcamp.com/posts#Footer_sections:)
 'footer-section'
 )
}

(:
<div class="h-entry">
 <h1 class="p-name">The Main Entry</div>
 <p class="p-author h-card">John Smith</p>
 <p class="e-content">Blah blah blah blah</p>

 <h2>Comments</h2>

 <div class="p-comment h-cite">
  <p class="p-author h-card">Jane Bloggs</p>
  <p class="p-summary">Ha ha ha great article John</p>
 </div>

</div>
:)

let $commenterH-card := $getCommenterAuthorShip()
:)

let $getTextOfTheCommentToDisplay := function( $page ){
let $content :=  $page//*[@class="h-entry"][1]//*[@class="e-content"][1]/node()
return $content
}



let $getEntry := function( $node ){
 if(mf2:has-h-entry( $node ) ) then (
  mf2:get-h-entry-node( $node )
 )
 else ()
}





let $getAuthorCard := function( $node ){
 if(mf2:node-has-h-card( $node ) ) then (
  mf2:get-h-card-node( $node )
 )
 else()
}

let $getAuthorCardURL := function( $node ){
 if(mf2:h-card-has-u-url( $node ) ) then (
  mf2:get-u-url-from-h-card( $node )
 )
 else()
}



let $extractAuthorCardURLValue := function( $node ){
mf2:parseU( $node )
}






let $entryNode := $getEntry( $wmSource[2] )

let $publishedValue := if( not(empty($entryNode)) and mf2:h-entry-has-a-dt-published( $entryNode ) ) then (
                          mf2:get-h-entry-dt-published-value( $entryNode)
                         )
                        else ()


let $authorCard := if(empty($entryNode ))then ()
                   else($getAuthorCard( $entryNode ))




let $authorCardURL := if(empty($authorCard ))then ()
                    else($getAuthorCardURL( $authorCard ))



let $hCardURLValue := if(empty($authorCardURL ))then ()
                      else($extractAuthorCardURLValue( $authorCardURL )
                       )


(: TODO: only a start - more to resolve  ref utility:urlResolve :)
let $resolvedURL :=  if(empty($hCardURLValue ))then ()
                   else(utility:urlResolve($source  , $hCardURLValue ))



(: TODO: work from domain-name :)

let $pathTo-h-card := '/db/apps/'  || $domain || '/data/authors/' || utility:urlHash($resolvedURL ) || '.xml'

let $stored-h-card :=  if(not($resolvedURL ))then ()
                   else(
                     if( doc-available( $pathTo-h-card )) then ( doc($pathTo-h-card)/node() )
                     else()
                   )

let $hasInReplyToHyperlink := mf2:has-in-reply-to-hyperlink($wmSource[2])
let $mentionType :=
  if ($hasInReplyToHyperlink ) then ( 'comment')
  else (
     'mention'
  )

(:
 <div class="p-in-reply-to h-cite">
  <p class="p-author h-card">Emily Smith</p>
  <p class="p-content">Blah blah blah blah</p>
  <a class="u-url" href="permalink"><time class="dt-published">YYYY-MM-DD</time></a>
  <p>Accessed on: <time class="dt-accessed">YYYY-MM-DD</time></p>
 </div>
:)


let $entry :=
    <div class="p-{$mentionType} h-cite">
       {
       if(not(empty($stored-h-card) )) then ($stored-h-card)
       else()
       }
      <div class="e-content">{$getTextOfTheCommentToDisplay($wmSource[2])}</div>
      Comment source <a class="u-url" href="{$source}"><time class="dt-published">{$publishedValue}</time></a>
      <a rel="in-reply-to" href="{$target}"><!--so I can display mentions on the target page --> </a>
     </div>

let $uPut :=  string-join(( $local , $rest , $domain , 'data/mentions'   , $datePath , $idHash || '.xml'), '/')

let $reqPut :=
    <http:request href="{ $uPut}"
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
let $put := http:send-request( $reqPut , (), $entry )

(:



  <p>$hCardURLValue: { $hCardURLValue  }</p>
<p>$resolvedURL: { $resolvedURL  }</p>
<p>$hasStoredHcard: { $stored-h-card  }</p>

<p>sourceHasTextContentType: {$sourceHasTextContentType($wmSource)}</p>
<p>sourcelinksToTarget: {$sourcelinksToTarget($wmSource, $target)}</p>
<p>isTargetValidResource: { $isTargetValidResource($wmTarget)  }</p>

<p>$hCardURLValue: { $hCardURLValue  }</p>
<p>$authorCardURL: { $authorCardURL  }</p>
<p>$authorCard: { $authorCard  }</p>
<p>entryNode{ $entryNode  }</p>
<p>$hasInReplyToHyperlink : </p>






:)
return
if($conditions) then
<div>
<h1>SUCCESS: met conditions for a valid mention</h1>
<p>someone is mentioning my page - target: {$target}</p>
<p>mentioning my page on thier page - source: {$source}</p>
<p>$uPut: {$uPut}</p>
<p>$domain: {$domain}</p>
<p>$source: { $source  }</p>
<div> {$entry} </div>

</div>
else(
<div>
    <h1>FAILURE: failed to met conditions for a valid mention</h1>
    <p>sourceHasTextContentType: {$sourceHasTextContentType($wmSource)}</p>
    <p>sourcelinksToTarget: {$sourcelinksToTarget($wmSource, $target)}</p>
    <p>isTargetValidResource: { $isTargetValidResource($wmTarget)  }</p>
</div>
)
