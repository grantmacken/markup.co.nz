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
    if( $model('page-isHome') ) then ( <article id="home-page-article" role="main">{ $model('page-content')/*/node() }</article> )
    else ( <article role="main">{ $model('page-content')/*/node() }</article> )
return
templates:process( $content, $model )
};

declare
function page:article-content($node as node(), $model as map(*)) {
templates:process( $model('page-content')/*/node(), $model )
};


declare
function page:author($node as node(), $model as map(*)) {
<p>By <span property="author" typeof="Person">
<span property="name">{$model("page-author")}</span>
</span></p>
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
