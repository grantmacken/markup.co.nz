
xquery version "3.0";

declare boundary-space preserve;

declare namespace xhtml = "http://www.w3.org/1999/xhtml";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:encoding "UTF-8";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace mf2="http://markup.co.nz/#mf2" at "mf2.xqm";
import module namespace http = "http://expath.org/ns/http-client";

let $doc := doc('/db/apps/markup.co.nz/data/jobs/mentions/mP-Bx6I7KMg91fHiBkajKQ.xml')

let $current-test-example := ($doc//xhtml:html)


let $current-test-out := mf2:dispatch($current-test-example)

	(:<div style="width:100%; clear:both" >:)
	(:    <textarea cols="240" rows="20">{$current-test-example}</textarea>:)
	(:</div>:)




return (
<html>
<head></head>
    <body>
    <section id="main" role="main">




	 <div style="width:100%; clear:both" >
	    <textarea cols="240" rows="20">{$current-test-out}</textarea>
	</div>


        </section>

    </body>


</html>)
