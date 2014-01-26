#!/usr/bin/env python
import sys
import os
import argparse
import time
import datetime
import re
import httplib
import subprocess
import distutils.util

from configobj import ConfigObj
config = ConfigObj('build.properties')

# python .bin/new-post.py  -p %(ask:POST_TYPE:article) -i %(ask:TITLE:%date:%y%j%M%S)
# http://sharats.me/the-ever-useful-and-neat-subprocess-module.html

parser = argparse.ArgumentParser(description='Ony one arg')
parser.add_argument('-i','--input', help='Input file name',required=True)
parser.add_argument('-p','--post_type', help='Post Type',required=True)
args = parser.parse_args()


match=re.search(r'(article|note)', args.post_type)
if match:
    postType = args.post_type
else:
   # return this to ant
   print 'FAIL. Post type must be (article or note)'
   sys.exit('Error!')

try:
    atime = time.localtime()
    year = time.strftime('%Y',atime)
    month = time.strftime('%m',atime)
    day = time.strftime('%d',atime)
    hour = time.strftime('%H',atime)
    minute = time.strftime('%M',atime)
    second = time.strftime('%S',atime)
    sDate = year + '-' + month + '-' + day
    shortYear = time.strftime('%y',atime)
    dayOfYear = time.strftime('%j',atime)
    #shortTime =  hour + minute + second
    iShortDate = int(shortYear + dayOfYear)
    print iShortDate
    sAntCall = ''
    sAntCall += "ant get-short-link -q -Dn="
    sAntCall += str(iShortDate)

    print sAntCall
    out1 = subprocess.check_output([sAntCall,"debug"],shell=True)
    outFirstLine2 = str(out1).splitlines()[0].strip()
    b60Encoded = outFirstLine2.split(' ')[1]
    print b60Encoded

    sAntCall2 = ''
    sAntCall2 += "ant collection-available -q -Dymd='"
    sAntCall2 +=  year
    sAntCall2 += '/'
    sAntCall2 +=  month
    sAntCall2 += '/'
    sAntCall2 +=  day
    sAntCall2 +=  "'"
    print sAntCall2
    out2 = subprocess.check_output([sAntCall2,"debug"],shell=True)
    outFirstLine2 = str(out2).splitlines()[0].strip()
    isCollection  =   distutils.util.strtobool(outFirstLine2.split(' ')[1])
    #print
    itemCount = 0
    if isCollection:
       print 'If we have a collection find out how many items'
    else:
        print 'We do NOT have a collection itemCount will be 1'
        itemCount += 1
    print itemCount
    tagUriIdentifier = b60Encoded
    tagUriIdentifier += str(itemCount)
    print tagUriIdentifier
    sTitle  = 'title: ' + args.input.replace('-', ' ')   + '\n'
    sPublished = 'published: ' + sDate + 'T' + hour + ':' + minute + ':' + \
                 second + '\n'
    sAuthor = 'author: ' +  config.get('project.author') + '\n'
    sID =  'id: tag:' +  config.get('project.domain') + ',' + sDate + ':' + \
        postType +':' + tagUriIdentifier +'\n'
    outFile = os.path.join( 'www' ,'_posts' , year + '-' + month + '-' + \
                           day + '-' +  args.input + '.md' )
except ValueError:
    raise

print outFile

try:
    if not os.path.exists(outFile):
        f = open(outFile, 'w')
        f.write('---\n')
        f.write(sTitle)
        f.write(sAuthor)
        f.write(sPublished)
        f.write(sID)
        f.write('summary: \n')
        f.write('categories: \n')
        f.write('---\n \n')
        f.close()
        cmd = "komodo " + outFile
        os.system(cmd)
except OSError:
    if os.path.exists(outFile):
        # We are nearly safe
        pass
    else:
        # There was an error on creation, so make sure we know about it
        raise
