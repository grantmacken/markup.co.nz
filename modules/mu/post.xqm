xquery version "3.0";
module namespace post="http://markup.co.nz/#post";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://exist-db.org/xquery/apps/config"  at "../../modules/config.xqm";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

(:~
: Post
: @author Grant MacKenzie
: @version 0.01
:
:)


declare
function post:feed($node as node(), $model as map(*)) {

 let $getPageUpdated :=  function($item){
   let $updated :=  xs:date( $item/atom:updated/string() )
   let $formated := format-date($updated , "[D1o] [MNn] [Y]", "en", (), ())
   return
    $formated
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
<ul>
{
 for $item  at $i in collection($model('data-posts-path'))//atom:entry
   where $i lt 20
   order by $item/atom:updated descending
   return
   <li>

   <article  class="h-entry">
   <h2 class="p-name">{$item/atom:title/string()}</h2>
   <div class="e-content">
     {$item/atom:content/*/node()}
   </div>
   <p>permalink: <a class="u-url" href="{$item/atom:link[@rel="alternate"]/@href/string()}">{$item/atom:title/string()}</a></p>
 </article>
   </li>
  }
</ul>
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
function post:entry($node as node(), $model as map(*)) {
let $content :=
 <article role="main" class="h-entry">
   <div class="e-content">
     { $model('page-content')/*/node() }
   </div>
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


declare
function post:author($node as node(), $model as map(*)) {
<p>By <span property="author" typeof="Person">
<span property="name">{$model("page-author")}</span>
</span></p>
};
