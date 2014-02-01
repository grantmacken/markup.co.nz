#!/usr/bin/env python

import re
import sys
import datetime
import math

import argparse
import fileinput
import markdown2

from configobj import ConfigObj
from twython import Twython

config = ConfigObj('build.properties')

parser = argparse.ArgumentParser(description='Ony one arg')
parser.add_argument('-i','--input', help='Input file name',required=True)
args = parser.parse_args()

m = re.match("(.+.md)", args.input )
if m:
    print args.input
else:
   # return this to ant
   print 'INPUT MUST be a md file'
   sys.exit('Error!')

source_file_content = open(args.input, 'r').read()
html = markdown2.markdown(source_file_content , extras=["metadata",
"code-friendly", "cuddled-lists", "fenced-code-blocks", "header-ids" ,
"smarty-pants"])
metadata =  html.metadata
print metadata

print metadata['id']
#tag:markup.co.nz,2014-01-22:note:102623
idNoteMatch = re.compile("^tag:.+:(note):.+$")
idDateMatch = re.compile("^tag:.+,(\d{4}-\d{2}-\d{2}):(note):(.+)$")
match = idDateMatch.match(metadata['id'])
#match=re.search(r'"^tag:.+,(\d{4}-\d{2}-\d{2}):.+$"', metadata['id'])
if match:
    print 'match found'
    dateString = match.group(1)
    postTypeString = match.group(2)
    identifierString = match.group(3)
    print 'id date: ' + str(dateString)
    print 'id post type: ' + postTypeString
    print 'id identifier: ' + identifierString
else:
    print 'no dateString'

print 'Get the text to post'

frontMatterSub = re.compile("-{3}[\s\S]+-{3}", re.M)
status_content = frontMatterSub.sub('', source_file_content).strip()

print status_content
#
# a list if #hashtags in status_content
lHashMatch=re.findall('#([\w]+)', status_content)

# a list if categories in front-matter
lCategories = metadata['categories'].split()
lnewCatergories = []

for lCat in lCategories:
    if lCat in lHashMatch:
        print 'Category in text'
        print lCat
    else:
        print 'No category in text so will append  to text #' + lCat
        status_content += ' #'
        status_content += lCat

print 'number of chars so  far: ' + str(len(status_content))

#
#status_content +=  ' ('
#status_content +=  config.get('project.domain')
#status_content +=  ' '
#status_content +=  identifierString
#status_content +=  ')'
#
print 'number of chars so far: ' + str(len(status_content))
print status_content
##
if lHashMatch:
    for iHashMatch in lHashMatch:
        if iHashMatch in lCategories:
            print 'the HashTag in text IS in front matter categories'
        else:
            print 'the HashTag in text NOT front matter categories'
            metadata['categories'] += ' '
            metadata['categories'] += iHashMatch
#
APP_KEY = config.get('twitter.app.key')
APP_SECRET = config.get('twitter.app.secret')

OAUTH_TOKEN = config.get('twitter.oauth.token')
OAUTH_TOKEN_SECRET = config.get('twitter.oauth.token_secret')

twitter = Twython(APP_KEY, APP_SECRET,
                  OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

jsonResult = twitter.update_status(status=status_content)
jsonResultID = jsonResult['id']

catLine = 'categories: ' + metadata['categories']

try:
    metaDataLinkTweetID = metadata['link-tweet-id']
except KeyError, e:
    print 'I got a KeyError - reason "%s"' % str(e)
    catLine += '\n'
    catLine += 'link-tweet-id: '
    catLine += str(jsonResultID)
except:
    print 'I got another exception, but I should re-raise'
    sys.exit('Error!')
    raise


for line in fileinput.input(args.input , inplace=1):
    if line.startswith('categories:'):
        print catLine
    else:
        print line,
