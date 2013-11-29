xquery version "3.0";
module namespace data-map="http://markup.co.nz/#data-map";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://exist-db.org/xquery/apps/config"  at "../../modules/config.xqm";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

(:~
 : Maps are efficient in-memory structures implimented using a hash tables
 : ( key:value pairs ) Key Values stored in the Map can be used later on.
 : Like JavaScript these values can be functions.
 : Our Model as Map is used to pass information between templating instructions
 :
 : @param $node  	the sequence of nodes which will be processed
 : @param $model
 : @return Map  a sequence of items which will be passed to all called template
 : functions. Use this to pass information between templating instructions.
 : http://atomic.exist-db.org/blogs/eXist/XQueryMap
:)

declare
   %templates:wrap
function data-map:loadModel($node as node(), $model as map(*)) {
(:  some usefull functions :)


    let $app-root :=  templates:get-app-root($model)
    let $site-title :=  config:app-title($node, $model)
    let $site-domain :=  substring-after( $app-root, 'apps/' )
    let $app-root :=  templates:get-app-root($model)
    let $app-data :=  $config:data-root

    let $data-pages-path :=  $config:data-root || '/pages'
    let $data-posts-path :=  $config:data-root || '/archive'

    let $request-path := request:get-parameter('exist-path','_contentStamp')
    let $request-resource := request:get-parameter('exist-resource','contentStamp')

(:
a 'collection' is going to be either a 'data/pages' subfolder or a
'' subfolder ( for posts )

POSTS  data/archive/[YEAR]/[MONTH]/[resource-item]
posts are date archived blog posts
posts organised by categories and tags

PAGES data/pages/[COLLECTION-NAME]/[resource-item]
Pages are organised by collection hierarchy and the top-level collections
become part of the top-level navigation (pages-nav) for website
Unlike posts pages are static and are not listed by date nor do they use
tags or categories.
:)



    let $data-collection-path :=
        if( matches($request-path ,'^/index.html$')) then ( 'home' )
        else if (matches($request-path ,'^/archive/index.html$')) then ( 'archive' )
        else if (contains($request-path ,'/archive/')) then (
            substring-before( substring-after($request-path , '/archive/') , concat( '/', $request-resource) ) )
        else(  substring-before( substring-after($request-path , '/') , concat( '/', $request-resource) ) )


(:
a 'data-item' is going to be a resource without an extension
:)
    let $data-item := substring-before( request:get-parameter('exist-resource','contentStamp'), '.html')

(:
 SOME PATHS
:)
    let $includesPath := $app-root  ||  '/templates/includes'
    let $categoriesPath := $app-root  ||  '/data/categories'
    let $data-hasCategories := xmldb:collection-available($categoriesPath)

    let $data-isPage := not(
           (contains( $request-path , '/archive/'))
        or (contains( $request-path , '/category/'))
        or (contains( $request-path , '/tag/')))
    let $data-isPost := contains( $request-path , '/archive/') (:/archive/{year}/{month}/{day}/{slug-title}:)
    let $data-isMainFeed :=  $request-path eq '/archive/index.html'
    let $data-isCategory :=  contains( $request-path , '/category/') (:/category/{id}:)
    let $data-isTag :=  contains( $request-path , '/tag/')  (:/tag/{id}:)

    let $contentPath :=
        if( $data-isPage )
            then (
               $data-pages-path ||  '/' || $data-collection-path ||  '/'  || $data-item || '.xml'
            )
        else(
            $data-posts-path ||  '/' || $data-collection-path ||  '/'  || $data-item || '.xml'
             )


    let $homePath :=  $data-pages-path  ||  '/' || 'home' ||  '/index.xml'
    let $page-isIndex := $data-item  eq 'index'
    let $page-isHome :=  $data-collection-path   eq 'home'
    let $page-author := $config:repo-descriptor/repo:author/text()

    let $docAvailable := doc-available($contentPath)

    let $docEntry :=
        if( $docAvailable ) then (doc($contentPath))
        else()

    let $get-page-content :=  function(){
        if ($data-isMainFeed ) then( )
        else($docEntry//atom:content)
    }

   let $get-page-title :=  function(){
       if(empty( $docEntry//atom:title/text()  ) )   then (
        if( not(empty( $get-page-content() )) ) then (
         if( $page-isIndex ) then  (
          if( $page-isHome ) then  ( $site-title )
          else(
           $data-collection-path
          )
         )
         else( $data-item )
        )
        else if( $data-isMainFeed ) then  ( $site-title  || ' blog' )
        else( '[ page-title ]'  )
       )
       else(
       $docEntry//atom:title/string()
      )
     }

(:~
: FEATURE:
: We want to look for the subtitle by looking at the {collection}/index page
: and looking for title attribute for the reference anchor
:
:)

 let $get-page-subtitle :=  function(){
  if(empty( $docEntry//atom:subtitle/text()) and $data-isPage  )   then (
     let $indexPath :=  $data-pages-path  ||  '/' || $data-collection-path ||  '/index.xml'
     let $subT :=
         if( doc-available( $indexPath )  and not( $page-isHome )  and not( $page-isIndex)  )
          then ( doc($indexPath)//*[contains(@href/string(),$data-item )][@title][1]/@title/string() )
         else if( not( $page-isHome )  and $page-isIndex )
          then (doc($homePath)//*[contains(@href/string(), $data-item )][@title][1]/@title/string() )
         else if ($page-isHome )
          then (
          $config:repo-descriptor/repo:description/text()
         )
         else('xx')
     return  $subT
    )
    else if( $data-isMainFeed ) then  ( 'authored by ' ||  $page-author)
    else(
       $docEntry//atom:subtitle/string()
      )
  }

  let $get-page-updated :=  function(){
   let $updated :=  $docEntry//atom:updated/string()
   return $updated
  }


 return
       map {
       'site-title' := $site-title,
       'site-domain' := $site-domain,
       'request-path' := $request-path,
       'request-resource' := $request-resource,
       'app-root' := $app-root,
       'app-data' := $app-data,
       'data-pages-path' := $data-pages-path,
       'data-posts-path' := $data-posts-path,
       'data-collection-path' := $data-collection-path,
       'data-content-path' := $contentPath,
       'data-isPage' := $data-isPage,
       'data-isPost' := $data-isPost,
       'data-isMainFeed' := $data-isMainFeed,
       'data-isCategory'  := $data-isCategory,
       'data-isTag'  := $data-isTag,
       'data-isDocAvailable' := $docAvailable,
       'data-hasCategories' := $data-hasCategories,
       'data-item':= $data-item,
       'page-isIndex' := $page-isIndex,
       'page-isHome' := $page-isHome,
       'page-title' := $get-page-title(),
       'page-subtitle' := $get-page-subtitle(),
       'page-content' := $get-page-content(),
       'page-author' := $page-author,
       'page-updated' :=   $get-page-updated(),
       'path-includes' :=   $includesPath
       }
};
