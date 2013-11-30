xquery version "3.0";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

(: include my modules in seperate folder:)
import module namespace data-map="http://markup.co.nz/#data-map" at "mu/data-map.xqm";
import module namespace page="http://markup.co.nz/#page" at "mu/page.xqm";
import module namespace post="http://markup.co.nz/#post" at "mu/post.xqm";
import module namespace header="http://markup.co.nz/#header" at "mu/header.xqm";
import module namespace nav="http://markup.co.nz/#nav" at "mu/nav.xqm";
import module namespace nav="http://markup.co.nz/#auth" at "mu/auth.xqm";

declare option exist:serialize "method=html5 media-type=text/html enforce-xhtml=yes";

let $config := map {
    $templates:CONFIG_APP_ROOT := $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR := true()
        }

let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
    function-lookup(xs:QName($functionName), $arity)
        } catch * {()}
    }

let $content := request:get-data()

return
    templates:apply($content, $lookup, (), $config)
