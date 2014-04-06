xquery version "3.0";
module namespace mf2="http://markup.co.nz/#mf2";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(:~
 : mf2
 : This module provide some   microformats 2 helper functions
 :  for parse  xhtml documents that are marked up with microformats 2 syntax.
 :
 :  indieweb
 :
 : @author Grant MacKenzie
 : @version 0.01 :
 :
:)




declare function mf2:has-h-entry( $page ){
exists( $page//*[@class="h-entry"][1] )
};

declare function mf2:get-h-entry-node( $page ){
$page//*[@class="h-entry"][1]/node()
};



declare function mf2:has-in-reply-to-hyperlink( $page ){
  let $node := $page//*[@class="h-entry"][1]//*[contains(@class, 'in-reply-to')][1]
  let $hasHyperLink :=  if(empty($node)) then ( false() )
  else(
   if( not(empty($node//a[@href] ))) then (true())
   else if ( not(empty($node[@href] ))) then (true())
   else(false())
  )
  return
  $hasHyperLink
};

declare function mf2:node-has-h-card( $node ){
   if( not(empty($node//*[contains(@class, 'h-card')][1] ))) then (true())
   else if ( not(empty($node[contains(@class, 'h-card')] ))) then (true())
   else(false())
};

declare function mf2:get-h-card-node( $node ){
   if(exists($node//*[contains(@class, 'h-card')][1] )) then ($node//*[contains(@class, 'h-card')][1])
   else ( $node[contains(@class, 'h-card')])
};



  (:'xPath: look for u-url node in  h-card':)
declare function mf2:h-card-has-u-url( $node ){
  not(empty($node//*[contains(@class, "u-url" ) or @rel="author"] ))
};

declare function mf2: get-u-url-from-h-card( $node ){
   $node//*[contains(@class, "u-url" ) or @rel="author"]
};



declare function mf2:h-entry-has-a-p-author( $page ){
exists(mf2:get-h-entry-node( $page )//*[contains(@class, 'p-author')][1])
};

declare function mf2:get-h-entry-p-author( $page ){
mf2:get-h-entry-node( $page )//*[contains(@class, 'p-author')][1]
};


declare function mf2:parseU( $node ){
(:let $rValue := ():)
(: if a.u-x[href] or area.u-x[href], then get the href attribute:)

let $nodeName  := string(node-name($node))

let $rValue :=
    switch ($nodeName )
       case 'a' return (
			if ($node[@href]) then ( $node/@href/string() )
			else()
			)
       default return ()
return $rValue
};





(:
    var rValue = null
    co('parsing node microfort p- with nodeName: ' + hNode.nodeName)
    //if a.u-x[href] or area.u-x[href], then get the href attribute
    if (!rValue) {
	if (hNode.nodeName == 'A' || hNode.nodeName == 'AREA') {
	    rValue = hNode.getAttribute('href')
	}
    }
    // if img.u-x[src], then get the src attribute
    if (!rValue) {
	if (hNode.nodeName == 'IMG') {
	    rValue = hNode.getAttribute('src')
	}
    }
    // if object.u-x[data], then get the data attribute
    if (!rValue) {
	if (hNode.nodeName == 'OBJECT') {
	    rValue = hNode.getAttribute('data')
	}
    }
	//if there is a gotten value, return the normalized absolute URL of it,
	//following the containing document's language's rules for resolving
	//relative URLs (e.g. in HTML, use the current URL context as determined
	//by the page, and first <base> element if any).

   //else parse the element for the value-class-pattern, if a value is found then return it
    if (!rValue) {
	contextNode = hNode
	var exp = './/*[contains(./@class, "value" )]'
	var pValue = browserDoc.evaluate(exp, contextNode, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
	if (pValue.singleNodeValue) {
	    var n = pValue.singleNodeValue
	    if (n.firstChild) {
		rValue = n.firstChild.data
	    }
	}
    }
   //if abbr.u-x[title], then return the title attribute
    if (!rValue) {
	if (hNode.nodeName == 'ABBR') {
	    rValue = hNode.getAttribute('title')
	}
    }
    //if data.u-x[value] or input.u-x[value], then return the value attribute
    if (!rValue) {
	if (hNode.nodeName == 'DATA' || hNode.nodeName == 'INPUT') {
	    rValue = hNode.getAttribute('value')
	}
    }
    //else return the textContent of the element
    if (!rValue) {
	if (hNode.firstChild) {
	    contextNode = hNode
            var exp = 'normalize-space( ./text() )'
	    rValue = browserDoc.evaluate(exp, contextNode, null, XPathResult.STRING_TYPE, null).stringValue;
	}
    }
    return rValue





:)



(:
  Note Use typeswitch
  http://en.wikibooks.org/wiki/XQuery/Typeswitch_Transformations

  get commenter information to display

  1. if the h-entry has a p-author, use its h-card:
    otherwise get the first* rel-author link on the page,
  2. retrieve the URL it points to, and use its representative h-card:
        logo/photo
        name
        url (of commenter profile/homepage)

    getAuthorName
    getAuthorImage
    getAuthorURL

  use element transform
:)
