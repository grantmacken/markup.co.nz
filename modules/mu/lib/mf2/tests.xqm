xquery version "3.0";
module namespace st="http://markup.co.nz/#mf2-tests";

import module namespace mf2="http://markup.co.nz/#mf2" at "mf2.xqm";
declare namespace test="http://exist-db.org/xquery/xqsuite";


(:~
: This module provides the functions that test mf2.
:@author Grant MacKenzie
:@version 1.0
:@see https://github.com/microformats/tests/blob/master/h-card.html
:@see https://github.com/microformats/tests/blob/master/h-entry.html
:@see http://waterpigs.co.uk/php-mf2
:@see https://github.com/indieweb/php-mf2/blob/master/tests/Mf2/MicroformatsWikiExamplesTest.php
:)


(:~
:@param  $node a xhtml fragment containing microformat 2 markup
:@return a node  an xml decription of an microformt
:)


declare
    %test:name("entry with implied name")
    %test:args('<p class="h-entry">microformats.org at 7</p>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'entry'")
    %test:assertXPath(" 'name' = local-name($result[1]/*) ")
    %test:assertXPath(" not('quack' = local-name($result[1]/*)) ")
function st:entry-with-just-a-name($node as element()) as element() {
        mf2:dispatch($node)
};

declare
    %test:name("entry with explict name")
    %test:args('<div class="h-entry"><p class="p-name">microformats.org at 7</p></div>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'entry'")
    %test:assertXPath(" 'name' = local-name($result[1]/*) ")
    %test:assertXPath(" not('quack' = local-name($result[1]/*)) ")


function st:entry-with-explict-name($node as element()) as element() {
        mf2:dispatch($node)
};

declare
    %test:name("entry with just a hyperlink")
    %test:args('<a class="h-entry" href="http://microformats.org/2012/06/25/microformats-org-at-7">microformats.org at 7</a>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'entry'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
function st:entry-with-just-a-hyperlink($node as element()) as element() {
        mf2:dispatch($node)
};

declare
    %test:name("entry containing content,summary, url, updated, author")
    %test:args(
'<div class="h-entry">
    <h1><a class="p-name u-url" href="http://microformats.org/2012/06/25/microformats-org-at-7">microformats.org at 7</a></h1>
            <p class="p-summary">Last week the microformats.org community
            celebrated its 7th birthday at a gathering hosted by Mozilla in
            San Francisco and recognized accomplishments, challenges, and
            opportunities.</p>

    <div class="e-content">
        <p>The microformats tagline &#8220;humans first, machines second&#8221;
            forms the basis of many of our
            <a href="http://microformats.org/wiki/principles">principles</a>, and
            in that regard, we&#8217;d like to recognize a few people and
            thank them for their years of volunteer service </p>
    </div>
    <p>Updated
        <time class="dt-updated" datetime="2012-06-25T17:08:26">June 25th, 2012</time> by
        <a class="p-author h-card" href="http://tantek.com/">Tantek</a>
    </p>
</div>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'entry'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'content' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'summary' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'updated' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'author' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")

function st:entry-with-summary-and-content($node as element()) as element() {
        mf2:dispatch($node)
};


declare
    %test:name("entry containing content with nested summary")
    %test:args(
'<div class="h-entry">
    <h1><a class="p-name u-url" href="http://microformats.org/2012/06/25/microformats-org-at-7">microformats.org at 7</a></h1>
    <div class="e-content">
        <p class="p-summary">Last week the microformats.org community
            celebrated its 7th birthday at a gathering hosted by Mozilla in
            San Francisco and recognized accomplishments, challenges, and
            opportunities.</p>

        <p>The microformats tagline &#8220;humans first, machines second&#8221;
            forms the basis of many of our
            <a href="http://microformats.org/wiki/principles">principles</a>, and
            in that regard, we&#8217;d like to recognize a few people and
            thank them for their years of volunteer service </p>
    </div>
    <p>Updated
        <time class="dt-updated" datetime="2012-06-25T17:08:26">June 25th, 2012</time> by
        <a class="p-author h-card" href="http://tantek.com/">Tantek</a>
    </p>
</div>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'entry'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'content' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'summary' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'updated' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'author' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
function st:entry-with-summary-nested-in-content($node as element()) as element() {
        mf2:dispatch($node)
};


declare
    %test:name("entry with name, photo and 8 urls ")
    %test:args(
'<div class="h-entry">
    <p class="p-name">microformats.org at 7</p>

    <!-- value and value-title patterns -->
    <p class="u-url">
      <span class="value-title" title="http://microformats.org/"> </span>
      Article permalink
    </p>
    <p class="u-url">
        <span class="value">http://microformats.org/</span> -
        <span class="value">2012/06/25/microformats-org-at-7</span>
    </p>

    <p><a class="u-url" href="http://microformats.org/2012/06/25/microformats-org-at-7">Article permalink</a></p>

    <img src="images/logo.gif" alt="company logos" usemap="#logomap" />
    <map name="logomap">
        <area class="u-url" shape="rect" coords="0,0,82,126" href="http://microformats.org/" alt="microformats.org"/>
    </map>

    <img class="u-photo" src="images/logo.gif" alt="company logos" />

    <object class="u-url" data="http://microformats.org/wiki/microformats2-parsing"></object>

    <abbr class="u-url" title="http://microformats.org/wiki/value-class-pattern">value-class-pattern</abbr>
    <data class="u-url" value="http://microformats.org/wiki/"></data>
    <p class="u-url">http://microformats.org/discuss</p>
</div>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'entry'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" count( $result[1]/*[local-name(.) = 'url']) eq 8 ")
    %test:assertXPath(" 'photo' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")

function st:entry-with-u-property-parsing-test($node as element()) as element() {
        mf2:dispatch($node)
};



(: card-with-simple-person-reference
   https://github.com/indieweb/php-mf2/blob/master/tests/Mf2/MicroformatsWikiExamplesTest.php
   From http://microformats.org/wiki/microformats-2-implied-properties
:)

declare
    %test:name("simple card with implied name")
    %test:args('<span class="h-card">Frances Berriman</span>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'card'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
function st:card-with-simple-person-reference($node as element()) as element() {
        mf2:dispatch($node)
};

(: card-with-hyperlinked-person
From http://microformats.org/wiki/microformats-2
:)

declare
    %test:name("simple hyperlinked card with implied name and url")
    %test:args('<a class="h-card" href="http://benward.me">Ben Ward</a>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'card'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
function st:card-with-hyperlinked-person($node as element()) as element() {
        mf2:dispatch($node)
};

(: card-with-implied-person-image
From http://microformats.org/wiki/microformats-2
:)

declare
    %test:name("simple image card with implied name and photo")
    %test:args('<img class="h-card" src="http://example.org/pic.jpg" alt="Chris Messina" />')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'card'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'photo' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
function st:card-with-implied-person-image($node as element()) as element() {
        mf2:dispatch($node)
};

declare
    %test:name("hyperlinked card with implied image, name and photo")
    %test:args(
'<a class="h-card" href="http://rohit.khare.org/">
 <img alt="Rohit Khare" src="https://s3.amazonaws.com/twitter_production/profile_images/53307499/180px-Rohit-sq_bigger.jpg" />
</a>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'card'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'photo' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
     %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
function st:card-with-implied-hyperlinked-image-name-and-photo($node as element()) as element() {
        mf2:dispatch($node)
};

declare
    %test:name("card with more details: name, photo, url, note, category")
    %test:args(
'<div class="h-card">
<img class="u-photo" alt="photo of Mitchell" src="https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"/>
<a class="p-name u-url" href="http://blog.lizardwrangler.com/">Mitchell Baker</a>
(<a class="u-url" href="https://twitter.com/MitchellBaker">@MitchellBaker</a>) <span class="p-org">Mozilla Foundation</span>
<p class="p-note">Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities.</p>
<span class="p-category">Strategy</span>
<span class="p-category">Leadership</span>
</div>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'card'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'photo' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'org' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'note' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'category' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")

function st:card-with-more-detailed-person($node as element()) as element() {
        mf2:dispatch($node)
};


(:
  H_CITE
 http://microformats.org/wiki/h-cite
 :)



declare
    %test:name("cite with properties published, url name and author embeded card with nested name")
    %test:args(
'<span class="h-cite">
  <time class="dt-published">YYYY-MM-DD</time>
  <span class="p-author h-card">AUTHOR</span>:
  <cite><a class="u-url p-name" href="URL">TITLE</a></cite>
</span>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'cite'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'published' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'author' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'card' = ( map(function($n) { local-name($n) }, $result[1]/*[local-name(.) eq 'author']/* )  ) ")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*[local-name(.) eq 'author']/*[local-name(.) eq 'card']/* )) ")
function st:cite-simple-minimal-abstract-web-citation-example($node as element()) as element() {
        mf2:dispatch($node)
};

declare
    %test:name("cite with properties published, url name and author embeded card with nested name")
    %test:args(
'<blockquote><p>
  <cite class="h-cite">
    <a class="u-url p-name" href="http://tantek.com/2013/104/t2/urls-readable-speakable-listenable-retypable">
      URLs should be readable, speakable, listenable, and unambiguously
retypable, e.g. from print: tantek.com/w/ShortURLPrintExample #UX
    </a>
   (<abbr class="p-author h-card" title="Tantek Çelik">Çelik</abbr>
    <time class="dt-published">2013-04-14</time>)
  </cite>
</p></blockquote>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'cite'")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'url' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'published' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'author' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'card' = ( map(function($n) { local-name($n) }, $result[1]/*[local-name(.) eq 'author']/*)  ) ")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*[local-name(.) eq 'author']/*[local-name(.) eq 'card']/* )) ")
function st:cite-simple-minimal-actual-web-citation-example($node as element()) as element() {
        mf2:dispatch($node)
};

declare
    %test:name("reply context: entry with  in-reply-to with embeded cite with various properties")
    %test:args(
'<div class="h-entry">
 <div class="p-in-reply-to h-cite">
  <p class="p-author h-card">Emily Smith</p>
  <p class="p-content">Blah blah blah blah</p>
  <a class="u-url" href="permalink"><time class="dt-published">YYYY-MM-DD</time></a>
  <p>Accessed on: <time class="dt-accessed">YYYY-MM-DD</time></p>
 </div>

 <p class="p-author h-card">James Bloggs</p>
 <p class="e-content">Ha ha ha too right emily</p>
</div>')
    %test:assertExists
    %test:assertTrue
    %test:assertXPath("count($result) = 1")
    %test:assertXPath("local-name($result[1]) eq 'entry'")
    %test:assertXPath(" 'in-reply-to' = ( map(function($n) { local-name($n) }, $result[1]/*)  ) ")
    %test:assertXPath(" 'card' = ( map(function($n) { local-name($n) }, $result[1]/*[local-name(.) eq 'author']/*)  ) ")
    %test:assertXPath(" 'name' = ( map(function($n) { local-name($n) }, $result[1]/*[local-name(.) eq 'author']/*[local-name(.) eq 'card']/* )) ")
    %test:assertXPath(" 'cite' = ( map(function($n) { local-name($n) }, $result[1]/*[local-name(.) eq 'in-reply-to']/*)  ) ")
    %test:assertXPath(" 'accessed' = ( map(function($n) { local-name($n) }, $result[1]/*[local-name(.) eq 'in-reply-to']/*[local-name(.) eq 'cite']/* )) ")

function st:reply-context($node as element()) as element() {
        mf2:dispatch($node)
};
