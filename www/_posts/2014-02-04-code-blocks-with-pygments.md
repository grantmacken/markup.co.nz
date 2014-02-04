---
title: code blocks with pygments
author: Grant MacKenzie
published: 2014-02-04T08:35:41
id: tag:markup.co.nz,2014-02-04:article:2sv1
summary: Some Notes On Working with Markdown2 and Pygments
categories:
---

Markdown2 and Pygments Out Of The Box
-------------------------------------

Out of the I box I just couldn't get it work.
So I don't use fenced blocks and hacked my own solution.

1. use 'lxml.html to parse markdown2 generated 'html' ```fromstring()```
2. use lxml iterator to work thru the md created 'pre' element blocks
3. with each pre 'element' get the 'flattened text'
4. Use try blocks to establish the lexer 'language'. First check if we can get
language from first word in 'flattened text' then ...
5. add the lexer filter 'VisibleWhitespaceFilter' otherwise our
whitespace is collapsed.
6. call pygments ```highlight()``` and parse the result with 'lxml.html ```fromstring()```
7. replace the original pre element with the parsed pygmented result

Pygments and xquery 3
-----------------------

The xquery language lexer does not recognise xquery 3 tokens.
ref: git hub issue [XQuery 3.0](https://github.com/spig/pygments-xquery-lexer/issues/1)

Github also uses Python Pygments <br/>

>'we use the Python Pygments for syntax highlighting'<br/>
> -- [github-git-repository-hosting](http://www.infoq.com/news/2008/03/github-git-repository-hosting)

so it might be worthwhile forking the project and updating the lexer.

Examples
========


Hi python
---------

    python
    from lxml.html import tostring, fromstring, html5parser
    from pygments import highlight
    from pygments.formatters import HtmlFormatter
    from pygments.lexers import guess_lexer, get_lexer_by_name
    from pygments.filters import VisibleWhitespaceFilter
    # hack hack ...
    # ignore code contained in pre. I just want the text in the pre
    def flatten(elem, include_tail=0):
        text = elem.text or ""
        for e in elem:
            text += flatten(e, 1)
        if include_tail and elem.tail: text += elem.tail
        return text
    # hack hack ...
    eDiv = fromstring( '<div xmlns="http://www.w3.org/1999/xhtml" >' + html + '</div>', parser=parser)
    formatter = HtmlFormatter(lineseparator="<br/>",cssclass='codehilite')
    for element in eDiv.iter("pre"):
        language = ''
        mdPre = ''
        element.text = flatten(element); del element[:]
        match=re.search(r'^(\w+)\s', element.text)
        if match:
            language +=  match.group(1)
        try:
            lexer = get_lexer_by_name(language, tabsize="1", stripnl=True, encoding='UTF-8')
            mdPre += re.sub(r'^\w+', '', element.text)
        except ValueError, e:
            try:
                # Guess a lexer by the contents of the block.
                mdPre += element.text
                lexer = guess_lexer(mdPre)
            except ValueError, e:
                # Just make it plain text.
                language = 'text'
                mdPre += element.text
                lexer = get_lexer_by_name(language, tabsize="1", stripnl=True, encoding='UTF-8')

        lexer.add_filter(VisibleWhitespaceFilter(spaces=True, newlines=True, tabs=True, wstokentype=True ))
        pygmented = fromstring(highlight(mdPre, lexer, formatter))
        element.getparent().replace(element, pygmented)



hi xquery
---------

    xquery
    (: Hello with XQuery :)
    let $i := concat( "Hello", " " , "World!")

    return $i



hi xquery 3
-----------

    xquery
    xquery version "3.0";
    (: Hello with XQuery 3 :)
    let $i := "Hello" || "World!"

    return $i


hi html
------

    html
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>Hello</title>
        </head>
        <body>
            <p>Hello, World!</p>
        </body>
    </html>

hi xml + svg
------

    xml
    <?xml version="1.0" encoding="utf-8" standalone="no"?>
    <svg width="240" height="100" viewBox="0 0 240 100" zoomAndPan="disable" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <title>Hello World</title>
        <g>
            <text x="10" y="50">Hello World</text>
            <animate attributeName='opacity' values='0;1' dur='4s' fill='freeze' begin="0s" />
        </g>
    </svg>


hi xslt
------

    xslt
    <?xml version='1.0'  encoding="ISO-8859-1"?>
    <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0' >
      <xsl:output method="text"/>
      <xsl:template match="/">
        <xsl:text>Hello World
    </xsl:text>
      </xsl:template>
    </xsl:stylesheet>
