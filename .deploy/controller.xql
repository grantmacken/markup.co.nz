xquery version "3.0";
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

let $shortURL := '2sm'


if (ends-with($exist:resource, ".html")) then
let $template-pages := '/templates/pages/'
let $template-posts := '/templates/posts/'
let $collection :=
  if( matches($exist:path ,'^/index.html$'))then ('home')
  else(tokenize($exist:path, '/')[2])


let $colURL :=
  if( matches( $exist:path , '^/archive/index.html$')) then (
      $exist:controller ||  $template-posts ||  'feed' || '.html'
      )
  else if( contains( $exist:path , 'archive/' )) then (
     $exist:controller ||  $template-posts ||  'entry' || '.html'
    )
  else(
    $exist:controller ||  $template-pages ||  $collection || '.html'
    )

let $errorURL := $exist:controller ||  $template-pages || 'error.html'
let $viewURL := $exist:controller ||  '/modules/view.xql'
return
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
  <forward method="get" url="{$colURL}" />
  <view>
    <forward url="{$viewURL}">
      <add-parameter name="exist-root" value="{$exist:root}" />
      <add-parameter name="exist-prefix" value="{$exist:prefix}" />
      <add-parameter name="exist-controller" value="{$exist:controller}" />
      <add-parameter name="exist-resource" value="{$exist:resource}" />
      <add-parameter name="exist-path" value="{$exist:path}" />
    </forward>
  </view>
  <error-handler>
    <forward method="get" url="{$errorURL}" />
    <forward url="{$viewURL}" />
  </error-handler>
</dispatch>
)
else
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
  <cache-control cache="yes" />
</dispatch>
