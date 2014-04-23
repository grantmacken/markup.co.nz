xquery version "3.0";

declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";


declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace system = "http://exist-db.org/xquery/system";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace http = "http://expath.org/ns/http-client";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace response="http://exist-db.org/xquery/response";

import module namespace mf2="http://markup.co.nz/#mf2"  at '../mu/mf2.xqm';
import module namespace note="http://markup.co.nz/#note"  at '../mu/note.xqm';
import module namespace utility = "http://markup.co.nz/#utility"  at '../mu/utility.xqm';

let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $getContextPath := request:get-context-path()

(: target Thats ME: you are mentioning my URL as a target :)
let $target := request:get-parameter('target',())

(: $source Thats YOU:  you are mentioning your URL as a source:)
let $source := request:get-parameter('source',())
let $code := 202
let $redirectURL := 'http://markup.co.nz/error'

let $local := 'http://120.138.18.126:8080'
let $rest := 'exist/rest/db/apps'
let $domain := substring-after(substring-before( $target, '/archive/' ), 'http://')

(:
TODO: to make responsive add job to que
set status then async out to carry out job
:)


return

if( empty($target) or  empty($source) ) then (
      response:redirect-to($redirectURL)
      )
    else( response:set-status-code($code)
	)
