#!/usr/bin/env python
import sys
import os
import markdown2
import argparse
import time
import datetime
import re


try:
    #import elementtree.ElementTree as ET
    from lxml import etree as  ET
    #print("running with lxml.etree")
except ImportError:
    print("Failed to import ElementTree from any known place")
    sys.exit('Error!')

parser = argparse.ArgumentParser(description='Ony one arg')
parser.add_argument('-i','--input', help='Input file name',required=True)
args = parser.parse_args()

ATOM_NAMESPACE = "http://www.w3.org/2005/Atom"
ATOM = "{%s}" % ATOM_NAMESPACE
NSMAP = {None : ATOM_NAMESPACE}

# the front matter metadata we will proccess
L = ['title','subtitle']

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

eEntry = ET.Element("entry", nsmap=NSMAP)

L = ['title','subtitle','summary' ]
for item in L:
    try:
        new_element = metadata[item]
        addElement( item, metadata[item] )
    except KeyError:
            new_title = ''
            pass


myTitle = eEntry.find('title')
if myTitle is None:
    addElement( 'title', titleText.replace('-', ' ') )


ET.SubElement(eEntry, 'updated').text  = modDate
linkAlt = ET.SubElement(eEntry, 'link')
linkAlt.attrib["rel"] = "alternate"
linkAlt.attrib["type"] = "text/html"
linkAlt.attrib["href"] = href

eContentDiv =  """
    <div xmlns="http://www.w3.org/1999/xhtml" >%(content)s</div>
"""
# Fill in the template
divTemplate = eContentDiv % dict(
    content=html
)


eContent = ET.Element("content")
eContent.set("type", "xhtml")

eContent.append(ET.XML(divTemplate))
eEntry.append(eContent)
indent(eEntry, level=0)
# return this to ant
print outfile

tree = ET.ElementTree(eEntry)
tree.write(outfile)
