xquery version "3.0";
module namespace tag="http://markup.co.nz/#tag";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://exist-db.org/xquery/apps/config"  at "../../modules/config.xqm";
import module namespace note="http://markup.co.nz/#note" at "note.xqm";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

(:~
: Page
:
: @author Grant MacKenzie
: @version 0.01
:
:)declare
function tag:notes($node as node(), $model as map(*)) {

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
<h1>Notes</h1>
{
 for $item  at $i in collection($model('data-posts-path'))//atom:entry[atom:id[contains(.,':note:')] ]
   where $item//atom:category[./@term = $model('data-item') ]
   order by $item/atom:published descending
   return
   <article  class="h-entry">
   <h2 class="p-name">{$item/atom:title/string()}</h2>
   {
  let $input := note:trim($item/atom:content/*/text())
   let $inLines := note:seqLines($input)
   let $outNodes := map(function($line) {
     let $replaced := '<div>' || note:hashTag(note:urlToken($line)) || '<br/></div>'
     let $l := util:parse($replaced )
     return
     ( $l/*/node())
    }, $inLines)
  return
    <div class="e-content">
        {$outNodes}
   </div>
   }

   <p>First published on the {$getPagePublished($item)} and updated {$getPageUpdated($item)}</p>
   <p>Archived at permalink: <a class="u-url" href="{$item/atom:link[@rel="alternate"]/@href/string()}">{$item/atom:title/string()}</a></p>
 </article>
  }
</section>
};
