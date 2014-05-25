
xquery version "3.0";

declare boundary-space preserve;

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:encoding "UTF-8";

import module namespace inspect = "http://exist-db.org/xquery/inspection";
import module namespace request="http://exist-db.org/xquery/request";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace mf2="http://markup.co.nz/#mf2" at "mf2.xqm";


let $test-name := request:get-parameter('test', 'cite')
let $test-url :=  xs:anyURI( 'tests/' || $test-name || ".xqm" )

let $funcs-out :=  inspect:inspect-module( $test-url )
let $test-out := test:suite( inspect:module-functions( $test-url ))

let $outCases :=
    for $node at $i in  $test-out//testcase
        let $id := substring-after($node/@class/string(), 'st:')
        let $testOK := 	if( $node/failure[@message]  )then( 'failure' )
			else if( $node/error[@message]  )then( 'error' )
			else('success')

        let $heading :=  <h3><a href="#t_{$i}">{$i || ': '|| $testOK} </a></h3>
	let $paragraph :=  <p>{$node/@name/string()}</p>
	let $message := switch ($testOK)
		case "success" return ( $heading , $paragraph  )
		case "error" return ($heading , $paragraph,<p>{  $node/error/@message/string() } </p>)
		case "failure" return ($heading, $paragraph ,<p>{   ' [ ' || $node/failure/@message/string() ||  ' ] ' || $node/failure/string() } </p>)
		default return ()


	let $functionNode := $funcs-out//function[@name = $node/@class/string()]
	let $input := 	$functionNode//annotation[@name="test:args"]/value/node()
	let $getLineCount := function( $str ){ count( tokenize( $str, '(\r\n?|\n\r?)') )}

	let $inputLines := $getLineCount($input)

	let $output := 	mf2:dispatch( util:parse( $input ) )
	let $outNodes :=  $output//*[count(child::text()) eq 0]
	let $outNodesCount := count( ( $output/* , $outNodes ) )

	let $textNodes :=  $output//*[./text()]
	let $textNodesCount := sum( map(function($n) { $getLineCount( $n/node()) }, $textNodes ))

        let $outLines := sum( ( 1 ,  $outNodesCount , $textNodesCount ) )

    return (
    <div class="{$testOK}"  id="{$id }" >
     { $message  }
      <p> test input args </p>
          <textarea cols="240" rows="{$inputLines }">{$input}</textarea>
       <p>test against result output </p>
	  <textarea cols="240" rows="{$outLines}">{$output}</textarea>
    </div>
    )

let $testCases :=
    for $node at $i in  $test-out//testcase
        let $id := substring-after($node/@class/string(), 'st:')
        let $success := not($node[failure])
        let $testOK := 	if( $node/failure[@message]  )then( 'failure' )
			else if( $node/error[@message]  )then( 'error' )
			else('success')

	let $message := switch ($testOK)
		case "success" return ( $node/@name/string()   )
		case "error" return ($node/@name/string())
		case "failure" return (
			$node/@name/string(), ' [',
                        $node/failure/@message/string(), ' ]  ' ,
                        $node/failure/string())
		default return ()

    return (
    <tr id="t_{$i}" class="{$testOK}">
        <td><a href="#{$id}">{$i}</a></td>
        <td>{$testOK}</td>
        <td>{$message}</td>
    </tr>
    )

let $countCases := count($test-out//testcase )
let $countFailures := count($test-out//testcase/failure[@message] )
let $countErrors :=  count($test-out//testcase/error[@message])
let $sumFailed :=  sum( ($countFailures, $countErrors ) )
let $summary := <p>{$countCases } testcases - ( {$sumFailed} / {$countCases} )   [ {$countFailures}  fail ] [ {$countErrors}  error ] </p>

let $header :=
<header  role="banner" >
<h1>MU: running tests at { $funcs-out/@location/string() }</h1>
<blockquote>{$funcs-out/description/string() }</blockquote>
{$summary}
</header>

let $table  :=  <table>{$testCases}</table>
let $style  := <link href="../../../resources/styles/style.css" rel="Stylesheet" type="text/css"/>
let $style2  := <style><![CDATA[

.failure, .error{
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

        { ($table,  $outCases)}

  </section>
    </body>
</html>)
