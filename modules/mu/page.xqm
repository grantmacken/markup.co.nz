xquery version "3.0";
module namespace page="http://markup.co.nz/#page";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://exist-db.org/xquery/apps/config"  at "../../modules/config.xqm";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

(:~
: Page
:
: @author Grant MacKenzie
: @version 0.01
:
:)

declare
function page:head-title($node as node(), $model as map(*)) {
<title>{ $model('page-title') }</title>
};

declare
function page:article($node as node(), $model as map(*)) {
let $content :=
    if( $model('page-isHome') ) then (
     <article id="home-page-article" role="main" class="h-entry" >{
     $model('page-content')/*/node()}</article>)
    else (
     <article role="main" class="h-entry" >{
     $model('page-content')/*/node()}</article>)
return
templates:process( $content, $model )
};

(: indieweb sem markup as h-entry :)

declare
function page:article-content($node as node(), $model as map(*)) {
templates:process( $model('page-content')/*/node(), $model )
};

(:
indieweb sem markup
as h-entry - 'author' of the posted entry

:)

declare
function page:authored-by($node as node(), $model as map(*)) {
<p>Authored by <span property="author" typeof="Person">
<a rel="author"
   class="p-author h-card"
   property="name"
   href="http://{$model('site-domain')}"
   >{$model("page-author")}</a>
</span></p>
};

declare
function page:permalink-url($node as node(), $model as map(*)) {
<p>Permalink: <a class="u-url" href="http://{concat($model('site-domain'), $model('request-path'))}">{$model('data-item')}</a></p>
};



declare function page:model-info($node as node(), $model as map(*)) {
let $data-items := ''
 return
 <table class="app-info"><caption>model info</caption>{
 for $data-item in map:keys($model)
 let $sequenceType := util:get-sequence-type( $model($data-item) )
 let $isDocumentNode := string($sequenceType) eq 'element()'
 order by  $data-item
 return
 <tr>
  <td>{$data-item}</td>
  <td>{if( not($isDocumentNode)) then ($model($data-item))
       else($sequenceType)}</td>
  <td>{$sequenceType}</td>
 </tr>
 }
 </table>
};
