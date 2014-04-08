xquery version "3.0";
module namespace pageHead="http://markup.co.nz/#pageHead";

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



declare
function pageHead:link-webebmention($node as node(), $model as map(*)) {
let $docEntry := $model('doc-entry')/node()
let  $href := 'http://' || $model('site-domain') || '/webmention'
(:let $href := $docEntry/atom:link[@rel='webmention']/@href/string():)
let $link := (<link rel="webmention" href="{$href}" /> )

let $addHeader :=
   if (not(empty($link) )) then (
      let $href :=  $href
      let $linkValue := '<'  ||  $href || '>; rel="webmention"'
      return response:set-header("Link",  $linkValue)                                            )
   else()

return
$link
};


(:~
: head
: @author Grant MacKenzie
: @version 0.01
:
: function calls from template: /templates/includes/head/archive-entry.html
:)