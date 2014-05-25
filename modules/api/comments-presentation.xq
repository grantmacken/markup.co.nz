xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:encoding "UTF-8";

import module namespace http = "http://expath.org/ns/http-client";

(:~

@see http://indiewebcamp.com/comment#Accept_a_comment
@see http://indiewebcamp.com/comments#Display_received_comments
@see http://indiewebcamp.com/comments-presentation

After Accepting a Webmention ( which is a reaction to a URL on my site )
we look at a way to handle and  display these responses as either
a reply (comment),
like (favorite),
repost (reshare),
RSVP, invitation
or
a generic mention

@see http://indiewebcamp.com/responses


webmention-source = wrapped http-client request @ /data/jobs/mentions/{hash}

Handling webmention-source
- to generate 'entries' and 'cards'

mf2 library
1. mf2 parser
    parse for h-entry

2. sanitizer/cleaner
    sanitize  entry e-content
    http://indiewebcamp.com/sanitize
    http://indiewebcamp.com/plaintext
    http://wpbtips.wordpress.com/2010/05/23/html-allowed-in-comments-2/
    https://www.npmjs.org/package/sanitize-html


3. url resolver
   resolve URLS
   https://github.com/indieweb/rel-me

4. truncator


Displaying Resopnses in a footers collection:

* Displaying Comments as citations

  http://indiewebcamp.com/comments-presentation

<div class="h-entry">
 <h1 class="p-name">The Main Entry</div>
 <p class="p-author h-card">John Smith</p>
 <p class="e-content">Blah blah blah blah</p>

 <h2>Comments</h2>

 <div class="p-comment h-cite">
  <p class="p-author h-card">Jane Bloggs</p>
  <p class="p-summary">Ha ha ha great article John</p>
 </div>
 •
 •
 •
</div>



* Displaying likes:  http://indiewebcamp.com/like

* Displaying reposts
    card + url  : http://indiewebcamp.com/repost




@see http://indiewebcamp.com/comment
@see https://github.com/indieweb/php-comments

@see http://indiewebcamp.com/webmention#Handling
@see https://github.com/converspace/webmention
@see http://indiewebcamp.com/original-post-discovery



:)


import module namespace system = "http://exist-db.org/xquery/system";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace response="http://exist-db.org/xquery/response";

import module namespace dbutil="http://exist-db.org/xquery/dbutil";

import module namespace utility = "http://markup.co.nz/#utility"  at '../mu/utility.xqm';
import module namespace mf2="http://markup.co.nz/#mf2"  at '../mu/lib/mf2/mf2.xqm';

let $app-root  :=   substring-before( system:get-module-load-path() ,'/module')
let $app-path  :=   substring-after( $app-root ,'//')
let $domain  :=   substring-after( $app-root ,'/apps/')
let $serverName := request:get-server-name()
let $remotePort := request:get-remote-port()
let $remoteAddr := request:get-remote-addr()
let $remoteHost := request:get-remote-host()

let $uri := request:get-parameter(
'source',
'/db/apps/markup.co.nz/data/jobs/mentions/mP-Bx6I7KMg91fHiBkajKQ.xml')

let  $user-id := 'grant'
let  $password := 'ntere37'
let  $login := xmldb:login($app-root, $user-id , $password )

let $doc-mention   := doc( $uri )

let $collection-name := util:collection-name($uri )
let $app-path := substring-before( $collection-name, '/data/' )


let $target   := $doc-mention/mention/@target/string()
let $source   := $doc-mention/mention/@source/string()
let $archived   := substring-after( $target, '/archive/' )
let $seq-path   :=  tokenize( $archived, '/' )
let $seq-archive-path   :=  remove( $seq-path, count($seq-path)  )

let $archive-path   :=  string-join( $seq-archive-path  , '/')



let $html   := $doc-mention//*[local-name(.) eq 'html' ]



let $mf :=  <source>{mf2:dispatch($html)}</source>






(:http://indiewebcamp.com/comments-presentation:)

(: Inferring post kinds from properties

    a post with just plain text content -> note
    with an explicit post name (title) -> article
    with an embedded image (via h-media?) -> photo
    with one or more rel-in-reply-to links -> reply
    with a p-location venue -> checkin
    an h-event event -> event (how is a post an event vs a post discussing an event?)


http://indiewebcamp.com/responses
    http://indiewebcamp.com/like
:)





let $has-entry   := function( $n ){ exists($n/entry[1]) }
let $get-entry   := function( $n ){
			     $n/entry[1]
			    }

let $has-author   := function( $entry ){ exists($entry/author[1]) }
let $get-author   := function( $entry ){
			     $entry/author[1]
			    }

let $has-content   := function( $n ){ exists($n/entry[1]/content ) }
let $get-content   := function( $n ){
			     $n/entry[1]/content
			    }

let $has-summary   := function( $n ){ exists($n/entry[1]/summary ) }
let $get-summary  := function( $n ){
			     $n/entry[1]/summary
			    }

let $get-author   :=
    function( $n ){
	if( $has-entry($n) ) then(
	let $e := $get-entry($n)
	return
	    if( $has-author($e) ) then(
	    $get-author($e)
	    )
	    else()
	)
	else()
    }

(:
http://indiewebcamp.com/responses
    http://indiewebcamp.com/like
    http://indiewebcamp.com/repost
:)
let $get-response-type   := function( $n ){
	     if( exists($n/entry[1]/in-reply-to )) then( 'comment' )
	else if( exists($n/entry[1]/u-like-of )) then( 'like' ) (: :)
	else if( exists($n/entry[1]/u-repost-of )) then( 'repost' )
	else('mention')
    }

let $is-to-long := function( $n ){
			    let $cNode := $get-content($n)/string()
                            return (
				(  count( tokenize( $cNode, ' ' ) ) ||  ': ' || $cNode )

			    )

			    }


let $get-text-of-the-comment-to-display := function($n){
	if( $has-content($n) ) then(
	let $node := $get-content($n)
	let $contenType :=
	    if( $node[node()] ) then( 'content-node')
	    else if($node[text()]) then( 'content-text')
	    else()
	let $is-to-long  :=  count( tokenize( $node, ' ' ) )

	return
	 ( $contenType || ": " || $is-to-long )
	)
	else if( exists($n/entry[1]/summary) ) then(
         'content-text'
	)
	else if( exists($n/entry[1]/name )) then(
         'name-text'
	)
	else(
	)
}


let $path-mentions :=  $app-path || '/data/mentions'
let $path-year := $path-mentions || '/' || $seq-archive-path[1]
let $path-month := $path-year    || '/' || $seq-archive-path[2]
let $path-day :=  $path-month    || '/' || $seq-archive-path[3]

(:
h-cite properties (inside class h-cite)
    p-name - name of the work
    dt-published - date (and optionally time) of publication
    p-author - author of publication, with optional nested h-card
    u-url - a URL to access the cited work
    u-uid - a URL/URI that uniquely/canonically identifies the cited work, canonical permalink.
    p-publication - for citing articles in publications with more than one author, or perhaps when the author has a specific publication vehicle for the cited work. Also works when the publication is known, but the authorship information is either unknown, ambiguous, unclear, or collaboratively complex enough to be unable to list explicit author(s), e.g. like with many wiki pages.
    dt-accessed - date the cited work was accessed for whatever reason it is being cited. Useful in case online work changes and it's possible to access the dt-accessed datetimestamped version in particular, e.g. via the Internet Archive.
    p-content for when the citation includes the content itself, like when citing short text notes (e.g. tweets).
 :)


let $model :=
<page>
    <comment>
	<cite>
	   <author>
	       <card><name>Jane Bloggs</name></card>
	   </author>

	   <summary>Ha ha ha great article John</summary>
	   <url>$source</url>
	</cite>
    </comment>
    <link rel="in-reply-to" href="$target" type="comment"/>
</page>



let $collection-uri   :=  $app-path || '/data/mentions/' || $archive-path
let $document-name := util:document-name($uri )
let $contents  :=    <mention rel="{$get-response-type($mf)}" target="{$target}" >
 <div class="p-comment h-cite">
  <p class="p-author h-card">Jane Bloggs</p>
  <p class="p-summary">Ha ha ha great article John</p>
 </div>
</mention>
let $mime-type  :=   'application/xml'


let $mkYear := if( xmldb:collection-available( $path-year ))then ()
	       else(xmldb:create-collection($path-mentions, $seq-archive-path[1] ))

let $mkMonth := if( xmldb:collection-available( $path-month ))then ()
	       else(xmldb:create-collection($path-year, $seq-archive-path[2] ))

let $mkMonth := if( xmldb:collection-available( $path-day ))then ()
	       else(xmldb:create-collection($path-month, $seq-archive-path[3] ))


let $store := xmldb:store($collection-uri,
			  $document-name,
			  $contents,
			  $mime-type)

(:
$html-comment,


$get-text-of-the-comment-to-display($mf),
'
',
'is-to-long: ' || $is-to-long($mf),'
',

'has-entry: ' || $has-entry($mf),'
',
'response-type: ' || $get-response-type($mf),'
',
$get-text-of-the-comment-to-display($mf),'
',
$get-author( $mf ),'
',
$get-entry( $mf )


:)

let $result := (
( $store )

)


return
<textarea cols="240" rows="480" >{$result}</textarea>
