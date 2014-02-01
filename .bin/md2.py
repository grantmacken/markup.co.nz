#!/usr/bin/env python
import sys
import os
import time
import datetime
import re
import markdown2
import argparse
from configobj import ConfigObj

try:
    from lxml import etree as  ET
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
NSMAP = {None : ATOM_NAMESPACE}


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

#link_patterns = [
#    # Match a wiki page link LikeThis.
#    (re.compile(r"\s#([A-Za-z]+)\s"), r"/markup.co.nz/tags/\1")
#]
#html = markdown2.markdown(source_file_content , extras=["link-patterns","metadata",
#"code-friendly", "cuddled-lists", "fenced-code-blocks", "header-ids" ,
#"smarty-pants"],link_patterns=link_patterns)

source_file_content = open(args.input, 'r').read()
html = markdown2.markdown(source_file_content , extras=["metadata",
"code-friendly", "cuddled-lists", "fenced-code-blocks", "header-ids" ,
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

def createXhtmlContent( ):
    eContentDiv =  """
    <div xmlns="http://www.w3.org/1999/xhtml" >%(content)s</div>
    """
    # Fill in the template
    divTemplate = eContentDiv % dict(
        content=html
    )
    #
    eContent = ET.Element("content")
    eContent.set("type", "xhtml")
    eContent.append(ET.XML(divTemplate))
    eEntry.append(eContent)
    indent(eEntry, level=0)

def createTextContent( ):
    frontMatterSub = re.compile("-{3}[\s\S]+-{3}", re.M)
    pre_content = frontMatterSub.sub('', source_file_content)
    eContentDiv =  """
    <pre xmlns="http://www.w3.org/1999/xhtml" >%(content)s</pre>
    """
    # Fill in the template
    divTemplate = eContentDiv % dict(
        content=pre_content
    )
    #
    eContent = ET.Element("content")
    eContent.set("type", "text")
    eContent.append(ET.XML(divTemplate))
    eEntry.append(eContent)
    indent(eEntry, level=0)


eEntry = ET.Element("entry", nsmap=NSMAP)

#Elements of <entry>
#http://atomenabled.org/developers/syndication/#requiredEntryElements

L = [ 'title', 'author' ,  'published' , 'id' ,'summary', 'categories' , 'link-tweet-id']
for item in L:
    try:
        new_element = item
        if new_element == 'author':
            eAuthor = ET.SubElement(eEntry, new_element)
            eAuthorName =  ET.SubElement(eAuthor, 'name').text = metadata[item]
        elif new_element == 'categories':
            lCategories = metadata[item].split()
            for lCat in lCategories:
                eCategory = ET.SubElement(eEntry, 'category')
                eCategory.attrib["term"] = metadata[item]
        elif new_element == 'link-tweet-id':
            linkTweetHref = 'https://twitter.com/' + config.get('twitter.name') + '/status/' + metadata[item]
            linkTweet = ET.SubElement(eEntry, 'link')
            linkTweet.attrib["rel"] = "syndication"
            linkTweet.attrib["type"] = "text/html"
            linkTweet.attrib["href"] = linkTweetHref
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


myID = eEntry.find('id')
if myID is None:
    createXhtmlContent()
else:
    myIDText = myID.text
    if idArticleMatch.match(myIDText):
        createXhtmlContent()
    elif  idNoteMatch.match(myIDText):
       createTextContent()
    else:
        createXhtmlContent()

## return this to ant
print outfile
#
tree = ET.ElementTree(eEntry)
tree.write(outfile)
