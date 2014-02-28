#!/usr/bin/env python
import sys
import os
import time
import datetime
import re
import markdown2
import argparse
import pygments
import pygments.formatters

from configobj import ConfigObj

try:
    from lxml import etree as  ET
    from lxml.html import tostring, fromstring, html5parser
    from pygments import highlight
    from pygments.formatters import HtmlFormatter
    from pygments.lexers import guess_lexer, get_lexer_by_name
    from pygments.filters import VisibleWhitespaceFilter

    #print("running with lxml.etree")
except ImportError:
    print("not running with lxml.etree")
    sys.exit('Error!')

config = ConfigObj('build.properties')

parser = argparse.ArgumentParser(description='Ony one arg')
parser.add_argument('-i','--input', help='Input file name',required=True)
args = parser.parse_args()


ATOM_NAMESPACE = "http://www.w3.org/2005/Atom"
ATOM = "{%s}" % ATOM_NAMESPACE

APP_NAMESPACE = "http://www.w3.org/2007/app"
APP = "{%s}" % APP_NAMESPACE

NSMAP = {None : ATOM_NAMESPACE,  'app' : APP_NAMESPACE }

# http://www.diveintopython3.net/xml.html
#2 types of md entries pages and posts
# POSTS date driven organised by categories and tags
# Pages are static and are not listed by date. Pages do not use tags or categories.
#

statinfo = os.stat(args.input)
modTime = time.localtime(statinfo.st_mtime)
modYear = time.strftime('%Y',modTime)
modMonth = time.strftime('%m',modTime)
modDay = time.strftime('%d',modTime)
modDate = modYear + '-' + modMonth  + '-' + modDay

#if not args.output:
    # rigmarole to get outfile if ref: proccess md

domain = os.path.basename(os.getcwd())
relPath =  os.path.relpath( args.input, 'www' )
dirName =  os.path.dirname(relPath)
splitDir = os.path.split(relPath)[0]
baseName = os.path.basename(relPath)
fName =    os.path.splitext(baseName)[0]
href = ''
titleText = ''

if not dirName:
    outfile = os.path.join( '.deploy' ,'data' , 'pages' , 'home' , fName +
    '.xml' )
else:
    if splitDir == '_posts':
        match=re.search(r'(\d{4}-\d{2}-\d{2})(-)(.+)', fName)
        if match:
            titleText = match.group(3)
            datestring = match.group(1)
            try:
                atime = time.strptime(datestring, '%Y-%m-%d')
                year = time.strftime('%Y',atime)
                month = time.strftime('%m',atime)
                day = time.strftime('%d',atime)
                outfile = os.path.join( '.deploy' ,'data' , 'archive', year , month , day, titleText + '.xml' )
                href = 'http://' + os.path.join( domain, 'archive', year , month ,day, titleText  )
            except ValueError:
                raise

        else:
           # return this to ant
           print 'FAIL'
           sys.exit('Error!')
    else:
        titleText = fName
        outfile = os.path.join( '.deploy' ,'data' , 'pages', splitDir, titleText +
        '.xml' )
        href = os.path.join( splitDir, fName  )

outDir = os.path.dirname(outfile)

try:
    if not os.path.isdir(outDir):
        os.makedirs(outDir)
except OSError:
    if os.path.exists(outDir):
        # We are nearly safe
        pass
    else:
        # There was an error on creation, so make sure we know about it
        raise


#MARKDOWN

source_file_content = open(args.input, 'r').read()
html = markdown2.markdown(source_file_content , extras=["metadata",
"code-friendly", "cuddled-lists", "header-ids" ,
"smarty-pants"])
metadata =  html.metadata

def addElement( key ,  data ):
    ET.SubElement(eEntry, key).text = data

def indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def flatten(elem, include_tail=0):
    text = elem.text or ""
    for e in elem:
        text += flatten(e, 1)
    if include_tail and elem.tail: text += elem.tail
    return text

def createXhtmlContent( ):
    indent(eEntry, level=0)
    eContent = ET.Element("content")
    eContent.set("type", "xhtml")
    eDiv = fromstring( '<div xmlns="http://www.w3.org/1999/xhtml" >' + html + '</div>', parser=parser)
    # test
    #http://modular.math.washington.edu/home/wstein/www/home/shumow/winspkg/Pygments-1.0/docs/build/index.html
    # https://djangosnippets.org/snippets/1213/
    # https://djangosnippets.org/snippets/119/
    # http://iboris.com/page/add-source-code-syntax-highlighting-your-django-content-pygments.html
    #linenos='table'
    # lineseparator="<br/>"
    # cssclass='codehilite'
    #

    formatter = HtmlFormatter(lineseparator="<br/>",cssclass='highlight', linenos='inline')
    #http://modular.math.washington.edu/home/wstein/www/home/shumow/winspkg/Pygments-1.0/docs/build/formatters.html

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


    eContent.append(eDiv)
    eEntry.append(eContent)
    #indent(eEntry, level=0)

def createTextContent( ):
    frontMatterSub = re.compile("-{3}[\s\S]+-{3}", re.M)
    eContent = ET.SubElement(eEntry, 'content')
    eContent.attrib["type"] = 'text'
    eContent.text = frontMatterSub.sub('', source_file_content)
    indent(eEntry, level=0)

parser = ET.HTMLParser()
eEntry = ET.Element("entry", nsmap=NSMAP)
eEntry.set("{http://www.w3.org/XML/1998/namespace}space", "preserve")

#Elements of <entry>
#http://atomenabled.org/developers/syndication/#requiredEntryElements

# TODO

#L = [ 'title', 'author' ,  'published' , 'id' ,'summary', 'categories' , 'link-tweet-id',  'draft']
for item in metadata:
    try:
        new_element = item
        if new_element == 'author':
            eAuthor = ET.SubElement(eEntry, new_element)
            eAuthorName =  ET.SubElement(eAuthor, 'name').text = metadata[item]
        elif new_element == 'categories':
            lCategories = metadata[item].split()
            for lCat in lCategories:
                eCategory = ET.SubElement(eEntry, 'category')
                eCategory.attrib["term"] = lCat
        elif new_element == 'link-tweet-id':
            linkTweetHref = 'https://twitter.com/' + config.get('twitter.name') + '/status/' + metadata[item]
            linkTweet = ET.SubElement(eEntry, 'link')
            linkTweet.attrib["rel"] = "syndication"
            linkTweet.attrib["type"] = "text/html"
            linkTweet.attrib["href"] = linkTweetHref
        elif new_element == 'rel-in-reply-to':
            linkRelReplyTo = ET.SubElement(eEntry, 'link')
            linkRelReplyTo.attrib["rel"] = "in-reply-to"
            linkRelReplyTo.attrib["type"] = "text/html"
            linkRelReplyTo.attrib["href"] = metadata[item]
        elif new_element == 'draft':
            elControl = ET.SubElement(eEntry, '{%s}control' % (APP_NAMESPACE))
            elDraft = ET.SubElement(elControl, "{%s}draft" % (APP_NAMESPACE))
            elDraft.text = metadata[item]
        else:
            addElement( item, metadata[item] )
    except KeyError:
            new_title = ''
            pass

# add a title if not in meta

myTitle = eEntry.find('title')
if myTitle is None:
    addElement( 'title', titleText.replace('-', ' ') )

# add updated from time modified if not in meta
# todo of if not set
ET.SubElement(eEntry, 'updated').text  = modDate
# add permalink
linkAlt = ET.SubElement(eEntry, 'link')
linkAlt.attrib["rel"] = "alternate"
linkAlt.attrib["type"] = "text/html"
linkAlt.attrib["href"] = href


# add a id if not in meta


# find if article or note etc
idArticleMatch = re.compile("^tag:.+:(article):.+$")
idNoteMatch = re.compile("^tag:.+:(note):.+$")
idCommentMatch = re.compile("^tag:.+:(comment):.+$")

myID = eEntry.find('id')
if myID is None:
    createXhtmlContent()
else:
    myIDText = myID.text
    if idArticleMatch.match(myIDText):
        createXhtmlContent()
    elif  idNoteMatch.match(myIDText):
       createTextContent()
    elif  idCommentMatch.match(myIDText):
       createTextContent()
    else:
        createXhtmlContent()

## return this to ant
print outfile
#
tree = ET.ElementTree(eEntry)
#test
tree.write('test.xml')
tree.write(outfile)
# http://lxml.de/html5parser.html
