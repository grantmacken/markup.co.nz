xquery version "3.0";

module namespace nav="http://markup.co.nz/#nav";
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~
A nav element containing a list of navigation items.
The navigation items contain anchors apart from the
'[You are here](http://www.w3.org/wiki/Creating_multiple_pages_with_navigation_menus#Site_navigation)'
item which tells the visitor the they are at the location.
:)

declare
function nav:pages($node as node(), $model as map(*)) {
let $seqCollections := distinct-values(xmldb:get-child-collections( $model('data-pages-path' ))[not(.=(('home','_drafts', '_tests')))])
let $seqCollectionsCount := count($seqCollections)
let $listItems :=
    for $menu-item at $i in  $seqCollections
      let $liChild :=
            if( $model('page-isHome') ) then (  (: eveything else a link:)
                   <a href="{/$menu-item}">{$menu-item}</a>
             )
             else if( $model('page-isIndex') ) then (
                  if($model('data-collection-path') eq   $menu-item ) then(
                    <strong>{$menu-item}</strong>
                  )
                  else(<a href="{/$menu-item}">{$menu-item}</a>)
             )
             else(
                  if($model('data-collection-path') eq   $menu-item ) then(
                    <a class="at-location" href="{/$menu-item}">{$menu-item}</a>)
                  else(<a href="{/$menu-item}">{$menu-item}</a>)
             )

       let $li :=
             if($seqCollectionsCount ne $i) then (
            <li>{$liChild}</li>
             )
            else( <li class="last">{$liChild}</li> )

        where not( starts-with($menu-item  , '_') )
           return
           $li

let $blogItem :=
 if( $model('data-isMainFeed') ) then
    <li><strong>archive</strong></li>
 else(
      if( $model('data-isPost') ) then
      <li class="at-location"><a href="/archive">archive</a></li>
      else(
      <li><a href="/archive">archive</a></li>
       )
  )


let $homeItem :=
 if( $model('page-isHome') ) then
    <li><strong>home</strong></li>
 else(
    <li><a href="/">home</a></li>
  )
return
<nav id="nav-pages" role="navigation" >
      <h1>main top-level web site navigation </h1>
                <ul>
                {$homeItem, $blogItem, $listItems}
                </ul>
    </nav>
};

(:~
nav:collection.
The navigation items in a collection
 uri absolute path from base

@param $node  template node
@param $model template  map
@return XHTML.
:)


declare
function nav:collection($node as node(), $model as map(*)) {
let $seqResources := xmldb:get-child-resources( $model('data-pages-path') || '/' || $model('data-collection-path') )

let $listItems :=
    for $menu-item in  $seqResources
        let $list-item := substring-before($menu-item , '.')
        where not(  $list-item  eq 'index' ) and (substring-after($menu-item , '.') eq 'xml')
        return
            if( $list-item eq $model('data-item') ) then (
               <li><strong class="is-u-r-here">{ replace( $list-item , '-' ,  ' ') }</strong></li>
               )
            else(
              <li><a href="/{$model('data-collection-path')}/{$list-item}">{ replace( $list-item , '-' ,  ' ') }</a></li>
              )
 return
   <nav id="nav-collection">
    <h1>related pages navigation</h1>
                <ul>
                    {
                    $listItems
                    }
                </ul>
    </nav>
};
