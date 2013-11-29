xquery version "3.0";
module namespace config="http://exist-db.org/xquery/apps/config";
declare namespace templates="http://exist-db.org/xquery/templates";
declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";
declare variable $config:app-root := 
let $rawPath := system:get-module-load-path()
let $modulePath :=
    if (starts-with($rawPath, "xmldb:exist://")) then
        if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
            substring($rawPath, 36)
        else
        substring($rawPath, 15)
    else
        $rawPath
    
    return
    substring-before($modulePath, "/modules")
    ;

declare variable $config:data-root := $config:app-root || "/data";
declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;
declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;
declare function config:resolve($relPath as xs:string) {
if (starts-with($config:app-root, "/db")) then
    doc(concat($config:app-root, "/", $relPath))
else
    doc(concat("file://", $config:app-root, "/", $relPath))
    };


declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
    };


declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
    };

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-descriptor/expath:title/text()
    };

declare function config:app-meta($node as node(), $model as map(*)) as element()* {
<meta content="{$config:repo-descriptor/repo:description/text()}" name="description" xmlns="http://www.w3.org/1999/xhtml" />
,
    for $author in $config:repo-descriptor/repo:author
    return
<meta content="{$author/text()}" name="creator" xmlns="http://www.w3.org/1999/xhtml" />

    };
        
declare function config:app-info($node as node(), $model as map(*)) {
    let $expath := config:expath-descriptor()
    let $repo := config:repo-descriptor()
    return
<table xmlns="http://www.w3.org/1999/xhtml" class="app-info">
    <tr>
        <td>app collection:</td>
        <td>{$config:app-root}</td>
    </tr>
    {
    for $attr in ($expath/@*, $expath/*, $repo/*)
    return
    <tr>
    <td>{node-name($attr)}:</td>
    <td>{$attr/string()}</td>
    </tr>
    }
</table>
 }; 
    
