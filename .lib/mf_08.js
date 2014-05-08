

/**
 * functions
 * parseP
 * parseU
 * parseDT
 *
 */




/** http://microformats.org/wiki/microformats2-parsing
    parse the element for the value-class-pattern, if a value is found then return it.
    if abbr.p-x[title], then return the title attribute
    else if data.p-x[value] or input.p-x[value], then return the value attribute
    else if img.p-x[alt] or area.p-x[alt], then return the alt attribute
    else return the textContent of the element, replacing any nested <img> elements with their alt attribute if present, or otherwise their src attribute if present.
*/

var parseP = function(doc, node, nsResolver) {
    var rValue = null
    //  parse the element for the value-class-pattern, if a value is found then return it
    contextNode = node
    var exp = './/*[contains(./@class, "value" )]'
    var pValue = doc.evaluate(exp, contextNode, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
    if (pValue.singleNodeValue) {
	var n = pValue.singleNodeValue
	if (n.firstChild) {
	    rValue = n.firstChild.data
	}
    }
    if (!rValue) {
	if (node.nodeName == 'DATA' || node.nodeName == 'INPUT') {
	    rValue = node.getAttribute('value')
	}
    }
    if (!rValue) {
	if (node.nodeName == 'ABBR') {
	    rValue = node.getAttribute('title')
	}
    }

    if (!rValue) {
	if (node.nodeName == 'IMG' || node.nodeName == 'AREA') {
	    rValue = node.getAttribute('alt')
	}
    }
    //else return the textContent of the element
    if (!rValue) {
	if (node.firstChild) {
	    contextNode = node
            var exp = 'normalize-space( ./text() )'
	    rValue = doc.evaluate(exp, contextNode, null, XPathResult.STRING_TYPE, null).stringValue;
	}
    }
    return rValue
}


/*
 parsing a u- property

To parse an element for a u-x property value:

    if a.u-x[href] or area.u-x[href], then get the href attribute
    else if img.u-x[src], then get the src attribute
    else if object.u-x[data], then get the data attribute
    if there is a gotten value, return the normalized absolute URL of it, following the containing document's language's rules for resolving relative URLs (e.g. in HTML, use the current URL context as determined by the page, and first <base> element if any).
    else parse the element for the value-class-pattern, if a value is found then return it.
    else if abbr.u-x[title], then return the title attribute
    else if data.u-x[value] or input.u-x[value], then return the value attribute
    else return the textContent of the element.

*/

var parseU = function(doc, node, nsResolver) {
    var rValue = null
    //if a.u-x[href] or area.u-x[href], then get the href attribute
    if (!rValue) {
	if (node.nodeName == 'A' || node.nodeName == 'AREA') {
	    rValue = node.getAttribute('href')
	}
    }
    // if img.u-x[src], then get the src attribute
    if (!rValue) {
	if (node.nodeName == 'IMG') {
	    rValue = node.getAttribute('src')
	}
    }
    // if object.u-x[data], then get the data attribute
    if (!rValue) {
	if (node.nodeName == 'OBJECT') {
	    rValue = node.getAttribute('data')
	}
    }
	//if there is a gotten value, return the normalized absolute URL of it,
	//following the containing document's language's rules for resolving
	//relative URLs (e.g. in HTML, use the current URL context as determined
	//by the page, and first <base> element if any).

   //else parse the element for the value-class-pattern, if a value is found then return it
    if (!rValue) {
	contextNode = node
	var exp = './/*[contains(./@class, "value" )]'
	var pValue = doc.evaluate(exp, contextNode, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
	if (pValue.singleNodeValue) {
	    var n = pValue.singleNodeValue
	    if (n.firstChild) {
		rValue = n.firstChild.data
	    }
	}
    }
   //if abbr.u-x[title], then return the title attribute
    if (!rValue) {
	if (node.nodeName == 'ABBR') {
	    rValue = node.getAttribute('title')
	}
    }
    //if data.u-x[value] or input.u-x[value], then return the value attribute
    if (!rValue) {
	if (node.nodeName == 'DATA' || node.nodeName == 'INPUT') {
	    rValue = node.getAttribute('value')
	}
    }
    //else return the textContent of the element
    if (!rValue) {
	if (node.firstChild) {
	    contextNode = node
            var exp = 'normalize-space( ./text() )'
	    rValue = doc.evaluate(exp, contextNode, null, XPathResult.STRING_TYPE, null).stringValue;
	}
    }
    return rValue
}


var parseDT = function(doc, node, nsResolver) {
    var rValue = null
    //  parse the element for the value-class-pattern, if a value is found then return it
    contextNode = node
    var exp = './/*[contains(./@class, "value" )]'
    var pValue = doc.evaluate(exp, contextNode, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
    if (pValue.singleNodeValue) {
	var n = pValue.singleNodeValue
	if (n.firstChild) {
	    rValue = n.firstChild.data
	}
    }

    if (!rValue) {
	if (node.nodeName == 'TIME') {
	    rValue = node.getAttribute('datetime')
	}
    }
    if (!rValue) {
	if (node.nodeName == 'ABBR') {
	    rValue = node.getAttribute('title')
	}
    }

    if (!rValue) {
	if (node.nodeName == 'DATA' || node.nodeName == 'INPUT') {
	    rValue = node.getAttribute('value')
	}
    }

    //else return the textContent of the element
    if (!rValue) {
	if (node.firstChild) {
	    rValue = node.firstChild.data
	}

    }
    return rValue
}

var build_hCard = function( obj ){
let xhtml_ns = 'http://www.w3.org/1999/xhtml';
/*some arbitary stuff  */
let icon_size = 48;

var xhtmlDoc = document.implementation.createDocument(xhtml_ns, 'div', null);
    xhtmlDoc.documentElement.setAttribute('class', 'h-card card-as-author' );

var xAuthorURL = document.createElementNS(xhtml_ns, 'a');
    xAuthorURL.setAttribute('href', obj.url)
    xAuthorURL.setAttribute('title', obj.name)
    xAuthorURL.setAttribute('class', 'u-url')
var xAuthorImage = document.createElementNS(xhtml_ns, 'img');
    xAuthorImage.setAttribute('src', obj.photo)
    xAuthorImage.setAttribute('width', icon_size )
    xAuthorImage.setAttribute('height', icon_size )
    xAuthorImage.setAttribute('alt', obj.name)
    xAuthorImage.setAttribute('class', 'u-photo')
    //
var xParagraph = document.createElementNS(xhtml_ns, 'p');
var xLineBreak = document.createElementNS(xhtml_ns, 'br');
var xAuthorName = document.createElementNS(xhtml_ns, 'span');
    xAuthorName.setAttribute('class', 'p-name')
    xAuthorName.appendChild(document.createTextNode(obj.name))

    xParagraph.appendChild(document.createTextNode('authored by'))
    xParagraph.appendChild(xLineBreak)
    xParagraph.appendChild(xAuthorName)

    xAuthorURL.appendChild(xAuthorImage)
    xhtmlDoc.documentElement.appendChild(xAuthorURL)
    xhtmlDoc.documentElement.appendChild(xParagraph)

return  xhtmlDoc
}


/*
var view = ko.views.manager.currentView;
var scimoz = view.scimoz;
var linenum = scimoz.lineFromPosition(scimoz.currentPos);
var basename = view.koDoc.file.baseName;
var dirname = view.koDoc.file.dirName;
var projectName = ko.projects.manager.currentProject.name;

co( 'scimoz: ' + linenum )
co(  'basename: ' + basename )
co ( 'dirname: ' + dirname )
co ( 'projectName: ' + projectName )
*/
//scimoz.searchFlags = scimoz.SCFIND_MATCHCASE | scimoz.SCFIND_WHOLEWORD;

/*
scimoz.searchFlags = scimoz.SCFIND_REGEXP;
scimoz.searchAnchor = 0;
search_reg = '^rel-in-reply-to:.+$'
scimoz.searchNext(scimoz.searchFlags,search_reg )
var found = scimoz.selText
var linkInReplyTo =  ko.stringutils.strip(found.split('to:')[1])
search_reg = '^rel-in-reply-to:.+$'
scimoz.searchNext(scimoz.searchFlags,search_reg )
var found = scimoz.selText
var linkInReplyTo =  ko.stringutils.strip(found.split('to:')[1])
*/



// replace the text
//scimoz.targetStart = scimoz.currentPos;
//scimoz.targetEnd = scimoz.anchor;
//scimoz.replaceTarget(text.length, text);
