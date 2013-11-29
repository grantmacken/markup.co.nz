xquery version "3.0";
module namespace header="http://markup.co.nz/#header";

(:~
 HEADER
 content driven by model
:)

declare
function header:site-title( $node as node(),$model as map(*)) {
        <h1 id="site-title" >{upper-case(replace( $model('site-title'), '-', ' '))}</h1>
};


declare
function header:title( $node as node(),$model as map(*)) {
    if( $model('page-isHome') ) then (
        <h1 id="page-title" >{upper-case(replace( $model('page-title'), '-', ' '))}</h1>
    )
        else(
        <h1 id="site-title" >{upper-case(replace( $model('site-title'), '-', ' '))}</h1>
         )
};

declare
function header:subtitle( $node as node(),$model as map(*)) {
 if ( $model('page-subtitle') eq '') then (
  <p id="page-subtitle" style="visibility: hidden">{$model('page-subtitle')}</p>
 )
 else (
 <p id="page-subtitle">{$model('page-subtitle')}</p>
 )
};
