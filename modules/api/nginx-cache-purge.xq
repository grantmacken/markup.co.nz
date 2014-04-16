xquery version "3.0";

import module namespace process="http://exist-db.org/xquery/process" at "java:org.exist.xquery.modules.process.ProcessModule";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace response="http://exist-db.org/xquery/response";

let $target := request:get-parameter('target', 'archive')


let $options := <options>
		    <workingDir>~/src/nginx-cache-purge</workingDir>
		    <stdin><line>nginx-cache-purge '{$target}' /usr/local/nginx/cache</line></stdin>
		</options>

let $cmd :=  '/bin/sh'

return
<results>
  {process:execute($cmd, <options/>}
</results>
