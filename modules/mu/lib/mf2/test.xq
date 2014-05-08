
xquery version "3.0";

declare boundary-space preserve;

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:encoding "UTF-8";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace mf2="http://markup.co.nz/#mf2" at "mf2.xqm";
(:
https://github.com/wolfgangmm/xqsuite/blob/master/tests/xqsuite-tests.xql
http://localhost:8080/exist/rest/db/apps/markup.co.nz/modules/mu/process/test.xq
:)

let $current-test-example :=
(
<div class="h-entry">
 <div class="p-in-reply-to h-cite">
  <p class="p-author h-card">Emily Smith</p>
  <p class="p-content">Blah blah blah blah</p>
  <a class="u-url" href="permalink"><time class="dt-published">YYYY-MM-DD</time></a>
  <p>Accessed on: <time class="dt-accessed">YYYY-MM-DD</time></p>
 </div>
 <p class="p-author h-card">James Bloggs</p>
 <p class="e-content">Ha ha ha too right emily</p>
</div>
)

let $current-test-out := mf2:dispatch($current-test-example)


let $test-out :=
            test:suite(
                inspect:module-functions(xs:anyURI("tests.xqm"))
            )

let $testCases :=
    for $node at $i in  $test-out//testcase
        let $success := not($node[failure])
        let $testOK := if($success)then('success')else('failure')
        let $message := if($success)then( $node/@name/string() )
                        else(
                        $node/@name/string(), ' [',
                        $node/failure/@message/string(), ' ]  ' ,
                        $node/failure/string()
                        )
    return (
    <tr class="{$testOK}">
        <td>{$i}</td>
        <td>{$testOK}</td>
        <td>{$message}</td>
    </tr>
    )

let $header :=  <header  role="banner" ><h1>MU</h1> </header>
let $table  :=  <table>{$testCases}</table>
let $style  := <link href="../../../resources/styles/style.css" rel="Stylesheet" type="text/css"/>
let $style2  := <style><![CDATA[

.failure {
    color: #9F6000;
    background-color: #FEEFB3;
}

.success {
    color: #4F8A10;
    background-color: #DFF2BF;
}

]]></style>
return (
<html>
<head>{$style, $style2}</head>
    <body>{$header}
    <section id="main" role="main">
        <h2>Test Result</h2>

        <p>{count( $test-out//testcase)} testcases - ( {count($test-out//testcase/failure)} / {count($test-out//testcase[not(failure)])} ) </p>
        {$table}
	<div  style="width: 100%">
	{$current-test-example}
	</div>

	<div  style="float:left;width: 48%">
	    <textarea  cols="120" rows="{ sum((2, count( $current-test-example//* ) ))}">{$current-test-example}</textarea>
	</div>

        <div style="float:right;width: 48%" >
	    <textarea cols="120" rows="{ sum((  4, count($current-test-out//* ))) }">{$current-test-out}</textarea>
	</div>
        <div style="width:100%; clear:both" >
	    <textarea cols="240" rows="{ sum( (  3,  count($test-out//testsuite), count( $test-out//testcase)) )}">{$test-out}</textarea>
	</div>
        </section>
      <footer role="contentinfo"><p>Package: {$test-out//testsuite/@package/string()}</p></footer>

    </body>
</html>)
