xquery version "3.0";
module namespace post="http://markup.co.nz/#post";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://exist-db.org/xquery/apps/config"  at "../../modules/config.xqm";
import module namespace note="http://markup.co.nz/#note" at "note.xqm";

declare namespace  xhtml = "http://www.w3.org/1999/xhtml";
declare namespace  atom = "http://www.w3.org/2005/Atom";
declare namespace  xlink = "http://www.w3.org/1999/xlink";

(:~
: Post
: @author Grant MacKenzie
: @version 0.01
:
:)



declare
function post:getUpdated($item) {
 let $updated :=  xs:date( $item/atom:updated/string() )
 let $formated := format-date($updated , "[D1o]  [MNn] [Y]", "en", (), ())
 return
 $formated
};


declare
function post:getPublished($item) {
   let $published :=  xs:dateTime( $item/atom:published/string() )
   let $published-formated := format-date($published , "[D1o] of [MNn] [Y]", "en", (), ())
   return
    $published-formated
};

declare
function post:getTitle($item) {
switch (post:getPostType($item))
   case "note" return ()
   default return   <h2 class="p-name">{$item/atom:title/string()}</h2>
};

declare
function post:getPermalink($item) {
 <a class="u-url" href="{$item/atom:link[@rel="alternate"]/@href/string()}">{$item/atom:title/string()}</a>
};

declare
function post:getSummary($item) {
 $item/atom:summary/string()
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
function post:getContent($item) {
let $r := switch (post:getPostType($item))
   case "note" return  post:getNote($item/atom:content/text())
   default return
   ($item/atom:summary/string(),
   <hr/> ,
    post:getSomeArticleBlockElements($item )
   )
 return $r
};


declare
function post:getIcon($item) {
let $r := switch (post:getPostType($item))
   case "note" return
   <div class="iconmelon">
    <svg viewBox="0 0 32 32">
     <use xlink:href="#todo-list"></use>
    </svg>
   </div>
   default return
   <div class="iconmelon">
    <svg viewBox="0 0 32 32">
     <use xlink:href="#document"></use>
    </svg>
   </div>
 return $r
};




declare
function post:main-feed($node as node(), $model as map(*)) {
<section id="main" role="main">
{
 for $item  at $i in collection($model('data-posts-path'))//atom:entry
   where $i lt 20
   order by $item/atom:published descending
   return
   <article  class="h-entry h-as-{post:getPostType($item)}">
   {post:getIcon($item)}
   {post:getTitle($item)}
   <div class="e-content">
    {post:getContent($item)}
   </div>
   <p>{post:getPostType($item) } first published on the { post:getPublished( $item ) } and updated { post:getUpdated( $item )}</p>
 </article>
  }
</section>
};


declare
function post:articles-feed($node as node(), $model as map(*)) {

 let $getPageUpdated :=  function($item){
   let $updated :=  xs:date( $item/atom:updated/string() )
   let $formated := format-date($updated , "[D1o]  [MNn] [Y]", "en", (), ())
   return
    $formated
  }

  let $getPagePublished :=  function($item){
   let $published :=  xs:dateTime( $item/atom:published/string() )
   let $published-formated := format-date($published , "[D1o] of [MNn] [Y]", "en", (), ())
   return
    $published-formated
  }




 let $getAuthor :=  function(){
   $model('page-author')
  }

 let $getPermalink :=  function($item){
  $item/atom:link[@rel='alternate']/@href/string()
  }

 let $getTitle :=  function($item){
   $item/atom:title/string()
  }

return
<section id="main" role="main">
<h1>Last 20 articles</h1>
{
 for $item  at $i in collection($model('data-posts-path'))//atom:entry[atom:id[contains(.,':article:')] ]
   where $i lt 20
   order by $item/atom:published descending
   return
   <article  class="h-entry">
   <h2 class="p-name">{$item/atom:title/string()}</h2>
   <div class="e-content">
     {$item/atom:content/*/node()}
   </div>
   <p>First published on the {$getPagePublished($item)} and updated {$getPageUpdated($item)}</p>
   <p>Archived at permalink: <a class="u-url" href="{$item/atom:link[@rel="alternate"]/@href/string()}">{$item/atom:title/string()}</a></p>
 </article>
  }
</section>
};



(:
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

:)

declare
function post:name($node as node(), $model as map(*)) {
if($model('page-content-isNote')) then ()
else (<h1 class="p-name">{$model('page-title')}</h1>)
};

declare
function post:author($node as node(), $model as map(*)) {
<a class="p-author h-card"  href="http://{$model("site-domain")}" >{$model("page-author")}</a>
};


declare
function post:summary($node as node(), $model as map(*)) {
<p class="p-summary">{$model("page-summary")}</p>
};

declare
function post:published($node as node(), $model as map(*)) {
 let $formatedDateTime := format-dateTime(xs:dateTime($model("page-published")), " [FNn], [D1o] [MNn] [Y]", "en", (), ())
return
<time class="dt-published" datetime="{$model("page-published")}">{$formatedDateTime}</time>
};

declare
function post:permalink($node as node(), $model as map(*)) {
 let $permalink := 'http://' || $model('site-domain') || substring-before($model('request-path'), '.html')
 return
 <a class="u-url" href="{$permalink}">permalink</a>
};


(:http://microformats.org/wiki/rel-syndication:)

declare
function post:syndicated($node as node(), $model as map(*)) {
   if( empty($model('link-syndicated-tweet'))) then ()
   else(<span>  page may also be viewed on <a class="u-syndication" href="{$model('link-syndicated-tweet')}">twitter</a>  </span>)
};


declare
function post:content($node as node(), $model as map(*)) {
(:                                                     :)


let $content :=
 if($model('page-content-isNote')) then (
   let $input := note:trim($model('page-content')/text())
   let $inLines := note:seqLines($input)
   let $outNodes := map(function($line) {
     let $replaced := '<div>' || note:hashTag(note:urlToken($line)) || '<br/>' || '</div>'
     let $l := util:parse($replaced )
     return
     ( $l/*/node())
    }, $inLines)
  return
    <div class="e-content">
        {$outNodes}
   </div>
 )
 else (
 <div class="e-content">
      { $model('page-content')/*/node() }
 </div>)

   return
templates:process( $content, $model )
};


declare
function post:entry($node as node(), $model as map(*)) {
let $content :=
 <article role="main" class="h-entry">
   <div class="e-content">
     { $model('page-content')/*/node() }
   </div>

<hr/>
<p data-template="page:authored-by"/>
<p data-template="page:permalink-url"/>
<hr/>
 </article>
return
templates:process( $content, $model )
};


declare
function post:head-title($node as node(), $model as map(*)) {
<title>{ $model('page-title') }</title>
};

declare
function post:article($node as node(), $model as map(*)) {
let $content :=
    if( $model('page-isHome') ) then ( <article id="home-page-article" role="main">{ $model('page-content')/*/node() }</article> )
    else ( <article role="main">{ $model('page-content')/*/node() }</article> )
return
templates:process( $content, $model )
};
