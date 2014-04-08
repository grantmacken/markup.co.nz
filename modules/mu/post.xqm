xquery version "3.0";
module namespace post="http://markup.co.nz/#post";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace response="http://exist-db.org/xquery/response";

import module namespace config="http://exist-db.org/xquery/apps/config"  at "../../modules/config.xqm";
import module namespace note="http://markup.co.nz/#note" at "note.xqm";
import module namespace mf2="http://markup.co.nz/#mf2" at "mf2.xqm";
import module namespace utility="http://markup.co.nz/#utility" at "utility.xqm";

declare namespace  xhtml = "http://www.w3.org/1999/xhtml";
declare namespace  atom = "http://www.w3.org/2005/Atom";
declare namespace  xlink = "http://www.w3.org/1999/xlink";



(:~
: Post
: @author Grant MacKenzie
: @version 0.01
: response:set-header
:)

(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(:  ENTRY Publish and Updated Dates :)


declare
function  post:getDivPublishDates($item) {
 let $updated :=  xs:date( $item/atom:updated/string())
 let $updatedFormated := format-date($updated , "[D1o]  [MNn] [Y]", "en", (), ())
 let $published :=  xs:dateTime( $item/atom:published/string() )
 let $publishedFormated := format-date($published , "[D1o] of [MNn] [Y]", "en", (), ())
 let $publishedTime := <time class="dt-published" datetime="{$published}">{$publishedFormated}</time>
 let $updatedTime := <time class="dt-updated" datetime="{$updated}">{$updatedFormated}</time>
 return
   <div>
    {post:getPermalink($item)}
    first published on the { $publishedTime } and updated { $updatedTime }
   </div>
};

declare
function  post:getDivPublishedDate($item) {

 let $published :=  xs:dateTime( $item/atom:published/string() )
 let $publishedFormated := format-date($published , "[D1o] of [MNn] [Y]", "en", (), ())
 let $publishedTime := <time class="dt-published" datetime="{$published}">{$publishedFormated}</time>
 return
   <div>
    { ( post:getPermalink2($item),  string(' - ' ) , $publishedTime )}
   </div>
};


(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(: ENTRY POSSE  Links   :)

declare
function  post:getDivSyndicated($item) {
 let $twitterLink :=   $item/atom:link[starts-with(@href/string() , 'https://twitter.com' )]/@href/string()
 return
   if( empty($twitterLink)) then ()
   else(<div>
     <svg viewBox="0 0 32 32" class="im">
     <use xlink:href="#link"></use>
    </svg>
        also posted on <a class="u-syndication" href="{$twitterLink}">
   <svg viewBox="0 0 32 32" class="im">
     <use xlink:href="#twitter-chicken"></use>
    </svg>
    twitter
    </a>
    </div>)
};


(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(:  ENTRY authorship card
    http://indiewebcamp.com/authorship
<a rel="author" class="p-author h-card" href="">Your Name</a>

:)

declare
function  post:getDivAuthorshipCard($item){
let $authorName :=
    if( empty($item/atom:author/atom:name/string())) then  (
        $config:repo-descriptor/repo:author/text()
    )
    else(
        $item/atom:author/atom:name/string()
    )

return
<div class="h-card p-author card-as-author">
   <img class="u-photo p-name" src="/resources/images/me.png" alt="{$authorName}" width="48" height="48"/>
   <p>authored by <br/><a rel="author" href="/cards/me">{$authorName}</a></p>
</div>
};

(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

declare
function post:getTitle($item) {
switch (post:getPostType($item))
   case "article" return <h2 class="p-name">{$item/atom:title/string()}</h2>
   default return  ()
};

declare
function post:getPermalink($item) {
    <a class="u-url"
    href="{$item/atom:link[@rel="alternate"]/@href/string()}"
    title="{$item/atom:title/string()}">
    <svg viewBox="0 0 32 32" class="im">
     <use xlink:href="#calendar"></use>
    </svg>{post:getPostType($item)}</a>
};


declare
function post:getPermalink2($item) {
    <a class="u-url"
    href="{$item/atom:link[@rel="alternate"]/@href/string()}"
    title="{$item/atom:title/string()}">
    <svg viewBox="0 0 32 32" class="im-medium">
     <use xlink:href="#{post:getPostType($item)}"></use>
    </svg>{post:getPostType($item)}</a>
};


declare
function post:getSummary($item) {
  switch (post:getPostType($item))
   case "note"
   case "comment"
     return post:getNoteFirstLine($item/atom:content/text())
   default return $item/atom:summary/string()
};


declare
function post:getPostType($item) {
 let $flags := ''
 let $input := $item/atom:id/string()
 let $pattern := "(:)"
 let $seqIdentifier := tokenize($input, $pattern)
 return  $seqIdentifier[3]
};

(:
   Content displayed depends upon post-type
note | article
:)

declare
function post:getSomeArticleBlockElements($item) {
 let $n := $item/atom:content/*/*
 let $nodesWithText  :=    ($n[./text()])
 let $seqCount  :=    count($nodesWithText)
 return
     if ( $seqCount gt 5 ) then (
                                 $nodesWithText[1, 2, 3, 4 , 5 ] ,
                                 <span>... continue to read  {post:getPermalink($item)} </span> )
     else( $nodesWithText )
};

declare
function post:getNote($text) {
   let $input := note:trim($text)
   let $inLines := note:seqLines($input)
   let $outNodes := map(function($line) {
     let $replaced := '<div>' || note:hashTag(note:urlToken($line)) || '<br/>' || '</div>'
     let $l := util:parse($replaced )
     return
     ( $l/*/node())
    }, $inLines)
  return
        $outNodes
};

declare
function post:getNoteFirstLine($text) {
   let $input := note:trim($text)
   let $line := note:seqLines($input)[1]
   let $replaced := '<div>' || note:hashTag(note:urlToken($line)) || '<br/>' || '</div>'

   return util:parse($replaced )/*/node()
};




declare
function post:getAbbevContent($item) {
let $r := switch (post:getPostType($item))
   case "note" return  post:getNote($item/atom:content/text())
   case "comment" return  post:getNote($item/atom:content/text())
   default return
   ($item/atom:summary/string(),
   <hr/> ,
    post:getSomeArticleBlockElements($item )
   )
 return $r
};


declare
function post:getFullContent($item) {
let $r := switch (post:getPostType($item))
   case "note" return  post:getNote($item/atom:content/text())
   case "comment" return  post:getNote($item/atom:content/text())
   default return (
    $item/atom:content/node()
   )
 return $r
};


declare
function post:getIcon($item, $size) {
   <div class="{$size}">
    <svg viewBox="0 0 32 32">
     <use xlink:href="#{post:getPostType($item)}"></use>
    </svg>
   </div>
};


declare
function post:getCategories($item) {
 if (empty($item/atom:category/@term/string())) then ()
 else(
   <div>
    <svg viewBox="0 0 32 32" class="im">
     <use xlink:href="#tag1"></use>
    </svg> tagged
      {
       map(function($term) {
       (' - ', <a class="p-category" href="/tag/{$term}" title="items tagged as {$term}">{$term}</a>)
      }, $item/atom:category/@term/string())
    }
 </div>
 )
};

declare
function post:getReplyToLink($item) {
<a rel="in-reply-to" href="{$item/atom:link[@rel='in-reply-to']/@href/string()}">{$item/atom:link[@rel='in-reply-to']/@href/string()}</a>
};

declare
function post:getReplyContext( $model ) {
let $item := $model('doc-entry')/node()
let $href := $item/atom:link[@rel='in-reply-to']/@href/string()
let $citeFileName :=   utility:urlHash( $href )
let $documentUri  :=   $model('data-citations-path') || '/' || $citeFileName || '.xml'
let $docAvailable  := doc-available($documentUri)
(:  As a miniumim display permalink of origin URL

<div class="p-in-reply-to">
{($documentUri, $docAvailable)}
 In reply to {post:getReplyToLink($item)}
</div>

:)
return
if( $docAvailable ) then ( doc($documentUri )/node() )
else(
 <div class="p-in-reply-to">

 <p>{$href}</p>


 In reply to {post:getReplyToLink($item) }
   <p>Can not find citation: {$citeFileName } <br/>

   </p>

</div>

)
};

declare
function post:getHeadLinkRelInReplyTo( $docEntry ){
let $href := $docEntry/atom:link[@rel='in-reply-to']/@href/string()

return
(<link rel="in-reply-to" href="{$href}" type="text/html" /> )
};



(: ~~~~~     FEEDs      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(: main-feed  Main feed how on home page :)

declare
function post:main-feed($node as node(), $model as map(*)) {
<section id="main" role="main">
{
 let $seq := for $item in collection($model('data-posts-path'))//atom:entry
             order by xs:dateTime($item/atom:published) descending
             return $item

 return for $item  at $i in $seq
   where $i lt 20
   return
   <article  class="h-entry h-as-{post:getPostType($item)}">
   {post:getIcon($item, "iconmelon")}
   {post:getTitle($item)}
   <div class="e-content">
    {post:getAbbevContent($item)}
   </div>
   {(
    post:getDivPublishDates($item),
    post:getCategories($item),
    post:getDivSyndicated ($item)
                      )
    }
 </article>
  }
</section>
};

(: ~~~~~  ARCHIVE-FEED      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(: archive-feed   archive page :)

(:~
 : archive-feed
 : uri Template /archive   >> archive.html
 : generate a list of notes
:)

declare
function post:archive-feed($node as node(), $model as map(*)) {

let $itemCount :=  function( $seq ){
                            if( count( $seq ) eq 1 )
                            then(  string(count( $seq )) ||  ' post')
                            else( string(count( $seq )) ||  ' posts') }
let $getMonth :=  function( $month ){
 ('January', 'February', 'March', 'April', 'May', 'June','July', 'August', '
  September', 'October', 'November', 'December')[$month]
                           }

let $seqItem := for $item in collection($model('data-posts-path'))//atom:entry
             group by $year := year-from-dateTime($item/atom:published)
             order by $year descending
             return  <div><strong>{$year}</strong>: {count($item)} posts
                 <div>{
                  for $itm in $item
                     group by $month := month-from-dateTime($itm/atom:published)
                     order by $month descending
                  return
                  <div>  <strong>{$getMonth($month)}</strong>: {$itemCount($itm)}
                   {
                    for $i in $itm
                    order by day-from-dateTime($i/atom:published) descending
                    return
                   <article  class="h-entry h-as-{post:getPostType($i)}">
                     <div>
                         {post:getTitle($i)}
                        </div>
                        {post:getDivPublishedDate($i)}
                     <div class="e-summary">
                      {post:getSummary($i) }
                     </div>
                   </article>
                   }
                  </div>
                  }</div>
             </div>
return
<section id="main" role="main">
{$seqItem}
</section>

};



declare
function post:search-host($node as node(), $model as map(*)) {
<input data-template="post:search-host" type="hidden" name="as_sitesearch" value="{$model('site-domain')}"/>
};

(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)
(:

                                     <article  class="h-entry h-as-{post:getPostType($itm)}">
                  <div>
                      {post:getTitle($itm)}
                     </div>
                     {post:getDivPublishedDate($itm)}
                  <div class="e-summary">
                   {post:getSummary($itm) }
                  </div>
                </article>

                  <article  class="h-entry h-as-{post:getPostType($itm)}">
                  <div>
                      {post:getTitle($itm)}
                     </div>
                     {post:getDivPublishedDate($itm)}
                  <div class="e-summary">
                   {post:getSummary($itm) }
                  </div>
                </article>



                <div>
                    {post:getTitle($item)}
                   </div>
                   {post:getDivPublishedDate($item)}
                <div class="e-summary">
                 {post:getSummary($item) }
                </div>



             let $published := xs:dateTime($item/atom:published)
             let $year := year-from-dateTime($published)

 let $seq := for $item in collection($model('data-posts-path'))//atom:entry
             order by xs:dateTime($item/atom:published) descending
             return $item

 return for $item  at $i in $seq
    group by year-from-dateTime(xs:dateTime($item/atom:published))
    order by count($item) descending
   return
   <div>Year: {$year} has {count($item)} posts
     {()





     }

   </div>

  }
</section>
   <article  class="h-entry h-as-{post:getPostType($item)}">
   <div>
       {post:getTitle($item)}
      </div>
      {post:getDivPublishedDate($item)}
   <div class="e-summary">
    {post:getSummary($item) }
   </div>
   {()
    }
 </article>

:)
(: ~~~  TAGS  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(:~
 : tagged-with-feed
 : uri Template /tag/{tagName}  where  {tagName} == $model('data-item')
 : generate a list of article that have been tagged with name
:)

declare
function post:tagged-with-feed($node as node(), $model as map(*)) {
 for $item  at $i in collection($model('data-posts-path'))//atom:entry[atom:category[./@term = $model('data-item') ]]
   order by $item/atom:published descending
   return
   <article  class="h-entry h-as-{post:getPostType($item)}">
   {post:getIcon($item, "iconmelon")}
   {post:getTitle($item)}
   <div class="e-content">
    {post:getAbbevContent($item)}
   </div>
   {(
    post:getDivPublishDates($item),
    post:getCategories($item),
    post:getDivSyndicated ($item)
                      )}
 </article>
};


(: ~~~  CARDS  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(:
  uri Template /card/{cardName} where  {cardName} == $model('data-item')
  template 'card.html'

http://microformats.org/wiki/h-card

Properties
h-card properties, inside an element with class h-card:
    p-name - The full/formatted name of the person or organisation
    p-honorific-prefix - e.g. Mrs., Mr. or Dr.
    p-given-name - given (often first) name
    p-additional-name - other/middle name
    p-family-name - family (often last) name
    p-sort-string - string to sort by
    p-honorific-suffix - e.g. Ph.D, Esq.
    p-nickname - nickname/alias/handle
    u-email - email address
    u-logo
    u-photo
    u-url - home page
    u-uid - unique identifier
    p-category - category/tag
    p-adr - postal address, optionally embed an h-adr
    Main article: h-adr
    p-post-office-box
    p-extended-address
    p-street-address - street number + name
    p-locality - city/town/village
    p-region - state/county/province
    p-postal-code - postal code, e.g. US ZIP
    p-country-name - country name
    p-label
    p-geo or u-geo, optionally embed an h-geo
    p-latitude - decimal latitude
    p-longitude - decimal longitude
    p-altitude - decimal altitude
    p-tel - telephone number
    p-note - additional notes
    dt-bday - birth date
    u-key - cryptographic public key e.g. SSH or GPG
    p-org - affiliated organization, optionally embed an h-card
    p-job-title - job title, previously 'title' in hCard, disambiguated.
    p-role - description of role
    u-impp per RFC 4770, new in vCard4 (RFC6350)
    p-sex - biological sex, new in vCard4 (RFC6350)
    p-gender-identity - gender identity, new in vCard4 (RFC6350)
    dt-anniversary

  function calls below

  h-card on home-page rel me

:)

(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

declare
function post:card($node as node(), $model as map(*)) {
 if( $model('data-item')  eq  'me') then(

    (: representative  h-card on home-page 'rel me'
    doc($model('path-includes') || '/' || 'h-card.html')/node()
     :)

    doc('http://markup.co.nz')//xhtml:footer/*[@class='h-card']
 )
 else()
};







(: ~~~ POST ENTRY ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

(:
  Every Post Entry
  uri Template /archive/{year}/{month}/{name}
  template 'entry.html'

 http://microformats.org/wiki/h-entry


 h-entry properties, inside an element with class h-entry:
     p-name - entry name/title
     p-summary - short entry summary
     e-content - full content of the entry
     dt-published - when the entry was published
     dt-updated - when the entry was updated
     p-author - who wrote the entry, optionally embedded h-card(s)
     p-category - entry categories/tags
     u-url - entry permalink URL
     u-uid - unique entry ID
     p-location - location the entry was posted from, optionally embed h-card, h-adr, or h-geo


 example
  <article class="h-entry">
    <h1 class="p-name">Microformats are amazing</h1>
    <p>Published by <a class="p-author h-card">W. Developer</a>
       on <time class="dt-published" datetime="2013-06-13 12:00:00">13<sup>th</sup> June 2013</time>
    </p>
    <p class="p-summary">In which I extoll the virtues of using microformats.</p>
    <div class="e-content">
      <p>Blah blah blah</p>
    </div>
  </article>



  function calls below
:)

(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :)

declare
function post:name($node as node(), $model as map(*)) {
  switch (post:getPostType( $model('doc-entry')/node() ) )
   case "article" return  (<h1 class="p-name">{$model('page-title')}</h1>)
  default return   ()
};

declare
function post:author($node as node(), $model as map(*)) {
<div class="h-card minicard">
   <img class="u-photo" src="/resources/images/me.png" alt="{$model("page-author")}" width="48" height="48"/>
   <p>authored by <br/><a class="p-name u-url" href="/about/me" rel="author">{$model("page-author")}</a></p>
</div>
};


declare
function post:summary($node as node(), $model as map(*)) {
  if(  $model("page-summary") eq '' ) then ()
  else(<p class="p-summary">{$model("page-summary")}</p>)
};


declare
function post:permalink($node as node(), $model as map(*)) {
 let $permalink := 'http://' || $model('site-domain') || substring-before($model('request-path'), '.html')
 return
 <a class="u-url" href="{$permalink}">permalink</a>
};


declare
function post:author($node as node(), $model as map(*)) {
 post:getDivAuthorshipCard($model('doc-entry')/node())
};

(:http://microformats.org/wiki/rel-syndication:)

declare
function post:syndicated($node as node(), $model as map(*)) {
  post:getDivSyndicated($model('doc-entry')/node())
};


declare
function post:published($node as node(), $model as map(*)) {
post:getDivPublishDates($model('doc-entry')/node())
};

declare
function post:categories($node as node(), $model as map(*)) {
 post:getCategories($model('doc-entry')/node())
};

declare
function post:entry-content($node as node(), $model as map(*)) {
let $content :=
 (<div class="e-content">
      {post:getFullContent($model('doc-entry')/node()) }
 </div>)
   return
templates:process( $content, $model )
};


(:
http://markup.co.nz/archive/2014/02/23/sending-webmentions

:)

declare
function post:reply-context($node as node(), $model as map(*)) {
let $docEntry := $model('doc-entry')/node()
        (: simple check if a reply-to link before we get post type :)
let $postType :=
          if( empty($docEntry/atom:link[@rel='in-reply-to']) ) then ''
          else( post:getPostType( $docEntry ))

let $reply-context :=
  switch ($postType)
   case "comment" return (
    post:getReplyContext( $model )
    )
  default return  ()

(: If we have a :)
return
$reply-context

};

declare
function post:mentioned($node as node(), $model as map(*)) {
let $docEntry := $model('doc-entry')/node()
let $href := $docEntry/atom:link[@rel="alternate" and @type="text/html"]/@href/string()
let $domain := $model('site-domain')
let $archivePath := substring-after( $href, '/archive/' )
let $seqPath := tokenize($archivePath, '/')
let $year := $seqPath[1]
let $month := $seqPath[2]
let $day :=  $seqPath[3]
let $datePath :=  string-join(($year , $month, $day ) , '/')
let $path :=  string-join(($model('app-data'), 'mentions' ,$year , $month, $day ) , '/')

let $seqNodes := for $node in xmldb:xcollection($path)
      where $node/*[*[@rel="in-reply-to"][@href = $href]]
      group by $rel := $node/*[*[@rel]]//@rel/string()
       order by $rel descending
        return  <div><strong>{$rel}</strong>: {count($node)} mention
        {
         for $itm in $node
                  return
                  $itm
        }


        </div>


return $seqNodes

(:
let $seqItem := for $item in xmldb:xcollection($path)
             group by $year := year-from-dateTime($item/atom:published)
             order by $year descending
             return  <div><strong>{$year}</strong>: {count($item)} posts
                 <div>{
                  for $itm in $item
                     group by $month := month-from-dateTime($itm/atom:published)
                     order by $month descending
                  return
                  <div>  <strong>{$getMonth($month)}</strong>: {$itemCount($itm)}
                   {
                    for $i in $itm
                    order by day-from-dateTime($i/atom:published) descending
                    return
                   <article  class="h-entry h-as-{post:getPostType($i)}">
                     <div>
                         {post:getTitle($i)}
                        </div>
                        {post:getDivPublishedDate($i)}
                     <div class="e-summary">
                      {post:getSummary($i) }
                     </div>
                   </article>
                   }
                  </div>
                  }</div>
             </div>

:)


};



declare
function post:head-link-rel-in-reply-to($node as node(), $model as map(*)) {
let $docEntry := $model('doc-entry')/node()
        (: simple check if a reply-to link before we get post type :)
let $postType :=
          if( empty($docEntry/atom:link[@rel='in-reply-to']) ) then ''
          else( post:getPostType( $docEntry ))

let $link :=
  switch ($postType)
   case "comment" return (
    post:getHeadLinkRelInReplyTo( $docEntry )

    )
  default return ()

(: should I use link 'Title' with  "in reply to ":)
let $addHeader :=
   if (not(empty($link) )) then (
      let $href :=  $docEntry/atom:link[@rel='in-reply-to']/@href/string()
      let $linkValue := '<'  ||  $href || '>; rel="in-reply-to"'
      return response:set-header("Link",  $linkValue)                                            )
   else()

(: If we have a :)
return
$link
};


(:


:)
