xquery version "3.0";
module namespace auth="http://markup.co.nz/#auth";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://exist-db.org/xquery/apps/config"  at "../../modules/config.xqm";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

(:~
: auth
:
: @author Grant MacKenzie
: @version 0.01
:
:)

declare
function auth:token($node as node(), $model as map(*)) {
<p{ string('token') }</p>
};

