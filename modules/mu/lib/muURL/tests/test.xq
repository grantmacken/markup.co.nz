
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
import module namespace muURL="http://markup.co.nz/#muURL" at "../muURL.xqm";

let $module-name := 'muURL'
let $module-path := xs:anyURI( '../' || $module-name  || '.xqm' )

let $test-name := request:get-parameter('test', 'main')
let $test-path :=  xs:anyURI( $test-name || ".xqm" )


let $inspectModule :=  inspect:inspect-module( $module-path  )
let $funcs-out :=  inspect:inspect-module( $test-path )
let $test-out := test:suite( inspect:module-functions( $test-path ))

(:~
test functions when developing a xquery library

 given args passed to a function
 when the function returns  a 'result'
 then  returned 'result' should pass our assertion tests

We want live testing of tests found in the tests collection


NAMING CONVENTIONS

if we are testing the url lib.
then the test for a function should be the same as the function
with an underscore after the function name if we have more
than one test for the named function

e.g.

in our 'url' lib module

  function url:get($url){};

will have a test named

  function st:get($url){
    url:get($url)
  };

if we need more than one test then

 function st:get_1($url){
  url:get($url)
 }

  function st:get_2($url){
    url:get($url)
  }



@see http://localhost:8080/exist/apps/doc/xqsuite.xml#D1.2.7
@see https://github.com/wolfgangmm/xqsuite
@see http://en.wikibooks.org/wiki/XQuery/XUnit_Annotations


* %test:name("description")
* %test:args()

* %test:assertEmpty() - returns true if the result is an empty string.
* %test:assertExists - returns true if the result exists.
* %test:assertTrue - returns true if the result is true
* %test:assertFalse - returns true if the result is false

* %test:assertEquals('value')

* %test:assertError("error code") - Excepts the function to fail with an error. If an error code is given (optional), it should be contained in the error message or the test will fail.

* %test:assertXPath("count($result) = 8") - This is the most powerful assertion. It checks the result against an arbitrary XPath expression. The assertion is true if

* %test:setUp
* %test:tearDown
:)



let $outCases :=
    for $node at $i in  $test-out//testcase

        let $testFunctionName := $node/@class/string()
        let $id := substring-after($testFunctionName, 'st:')
	let $testFunc := if(contains($id, '_')) then (substring-before($id, '_') )
			else ( $id )

        let $testOK := 	if( $node/failure[@message]  )then( 'failure' )
			else if( $node/error[@message]  )then( 'error' )
			else('success')

        let $functionNode := $funcs-out/function[@name = $testFunctionName]
	let $heading :=  <h3><a href="#t_{$i}">{$i || ':  ' ||  $testFunc  || ' [ ' || $testOK   || ' ]' } </a></h3>
	let $paragraph :=  <p><strong>description: </strong>{$node[@name]/@name/string() }</p>



(: $functionNode lists function calls made by the test
   we are only interested in the last function call
   as this is what returns our result

:)
        let $countFunctionCalls := count($functionNode/calls/* )
        let $functionCall :=
	  if($countFunctionCalls gt 1)
	     then ( $functionNode/calls/*[contains( @name/string(), $testFunc )]/@name/string())
	  else($functionNode/calls/*[$countFunctionCalls]/@name/string())




(:
  TODO: more types
  we are going to call  'util:eval( $functionCallString )'
  with the function calls args
  we need create a string for each type for eval to work
:)

	let $args :=
	    for $item at $i in $functionNode/argument
	      let $type := $item/@type/string()
	      let $value := $functionNode//annotation[@name="test:args"]/value[$i]/node()
	      let $arg :=
	       if( $type eq 'element()' ) then (  $value/string() )
	       else( "'"  || $value/string()  || "'" )
	      return $arg

(:

        let $priorFunctionCall :=
	  if($countFunctionCalls gt 1)
	     then (
		let  $priorCallName :=   $functionNode/calls/*[not(contains( @name/string(), $testFunc ))]/@name/string()
		let  $priorCallString := $priorCallName  || " ( " ||  string-join($args, ",") ||  " )"
		let $priorCallResult :=  util:eval( $priorCallString )
		return 	$priorCallResult
		)
	  else()
:)

	let $functionCallString := $functionCall || " ( " ||  string-join($args, ",") ||  " )"



	let $displayfunctionCall := if( 'element()' = $functionNode/argument/@type )
				      then (  $functionCall || " ()")
				    else ( $functionCall || " ( " ||  string-join($args, ",") ||  " )")



(:
  TODO: more return types
  we are going to call  'util:eval( $functionCallString )'
  with the function calls args
  we need create a string for each type for eval to work
:)
	let $functionCallResult :=  util:eval( $functionCallString )
	let $returnType := if( $functionCallResult instance of xs:string ) then 'string'
			   else if ($functionCallResult instance of node() )  then 'node'
			   else if ($functionCallResult instance of  xs:boolean )  then 'boolean'
			    else if ($functionCallResult instance of  xs:anyURI )  then 'URI'
			   else if ($functionCallResult instance of item() )  then 'item'
                           else  ('string')


	let $getLineCount := function( $str ){ count( tokenize( $str, '(\r\n?|\n\r?)') )}
	let  $rows := switch ($returnType)
		case "boolean" return (1)
		case "URI"  return (1)
		case "string"
		case "item" return (count( tokenize( $functionCallResult , '(\r\n?|\n\r?)')) )
		case "node" return (
		    let $outNodes :=  $functionCallResult//*[count(child::text()) eq 0]
		    let $outNodesCount := count( ( $functionCallResult/* , $outNodes ) )
		    let $textNodes :=  $functionCallResult//*[./text()]
		    let $textNodesCount := sum( map(function($n) { $getLineCount( $n/node()) }, $textNodes ))
		    let $summed := sum( ( 1 ,  $outNodesCount , $textNodesCount ) )
		    return if ( $summed gt 20 ) then (20)
			else ( $summed )
		    )
		default return ()


	let  $cols := switch ($returnType)
		case "boolean" return (6)
		case "URI" return string-length( string($functionCallResult) )
		case "string"
		case "item" return (
				      max(
				      for $line in  tokenize( $functionCallResult , '(\r\n?|\n\r?)')
				      return string-length($line)) )
		case "node" return ( 80 )
		default return ()

	let $resultDD := (
	  <dt>Result Returned</dt>,
	  <dd>Number of function calls:  {$countFunctionCalls}</dd>,
	  <dd>Returned instance of: { $returnType  } </dd>,
	  <dd><textarea cols="{$cols}" rows="{$rows}">{$functionCallResult}</textarea></dd>
	  )

      let $defList :=
	<dl>
	  <dt>function call</dt>
	  <dd>{$displayfunctionCall}</dd>
	  <dt>function arguments</dt>
            {
	    for $item at $i in $functionNode/argument
	    let $type := $item/@type/string()
	    let $value := $functionNode//annotation[@name="test:args"]/value[$i]/node()

	    let $arg :=
	     if( $type eq 'element()' ) then (util:parse( $value/string() ) )
	     else( $value/string()  )

	    let $rows := count( tokenize( $value , '(\r\n?|\n\r?)'))
	    let $cols :=  max(
		  for $line in  tokenize( $value , '(\r\n?|\n\r?)')
		  return string-length($line))
	     return
	      ( <dd>{$i || ': '|| $type}</dd>,
		<dd><textarea cols="{$cols}" rows="{$rows}">{$arg}</textarea></dd>
	       )
	    }
	    { $resultDD }
	</dl>


      let $message := switch ($testOK)
      case "success" return ( $heading , $paragraph, $defList  )
      case "error" return ($heading , $paragraph,$defList,<p>{  $node/error/@message/string() } </p>)
      case "failure" return ($heading, $paragraph , $defList, <p>{   ' [ ' || $node/failure/@message/string() ||  ' ] ' || $node/failure/string() } </p>)
      default return ()


    return (
    <div class="{$testOK}"  id="{$id }" >
     {$message}
    </div>
    )
(:

	let $functionCallResult :=  util:eval( $functionCallString )

	let $returnType := $functionCallResult instance of xs:string
	let $mayBeNode := (starts-with($functionCallResult, '<') and ends-with($functionCallResult, '>'))
	let $loadXML :=  if( $mayBeNode ) then ( util:parse( $functionCallResult ))
			 else()

	let $rows := count( tokenize( $functionCallResult , '(\r\n?|\n\r?)'))
	let $cols :=  max(
	      for $line in  tokenize( $functionCallResult , '(\r\n?|\n\r?)')
	      return string-length($line))

        let $heading :=  <h3><a href="#t_{$i}">{$i || ': '|| $testOK} </a></h3>
	let $paragraph :=  <p>{$node/@name/string()}</p>
	let $defList :=
	<dl>
	  <dt>function call</dt>
	  <dd>{$functionCallString}</dd>
	  <dt>function call result </dt>
	  <dd><textarea cols="{$cols}" rows="{$rows}">{$functionCallResult}</textarea></dd>
	</dl>

	let $message := switch ($testOK)
		case "success" return ( $heading , $paragraph, $defList  )
		case "error" return ($heading , $paragraph,$defList,<p>{  $node/error/@message/string() } </p>)
		case "failure" return ($heading, $paragraph , $defList, <p>{   ' [ ' || $node/failure/@message/string() ||  ' ] ' || $node/failure/string() } </p>)
		default return ()

    return (
    <div class="{$testOK}"  id="{$id }" >
     { $message  }
    </div>
    )
:)

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
<h2>MU: Test module at { $inspectModule/@location/string() } </h2>
<blockquote><pre>{$inspectModule/description/string() }</pre></blockquote>
<h2>MU: running tests at { $funcs-out/@location/string() } </h2>
{$summary}
</header>

let $table  :=  <table>{$testCases}</table>
let $style  := <style><![CDATA[

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
<head>{$style}</head>
    <body>{$header}
    <section id="main" role="main">
        <h2>Test Result</h2>

        { ($table , $outCases)}

  </section>

  <footer>
     <textarea cols="300" rows="40">{$funcs-out }</textarea>
      <textarea cols="300" rows="40">{$test-out }</textarea>
  </footer>

    </body>
</html>)
