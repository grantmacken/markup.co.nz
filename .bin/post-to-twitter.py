#!/usr/bin/env python

import re
import datetime
import math

import argparse
import fileinput
import markdown2

from configobj import ConfigObj
from twython import Twython

def base_n_encoder(alphabet):
    """Return a encoder for a base-n encoded string
   """
    base = len(alphabet)
    def f(num):
        if (num == 0):
            return alphabet[0]
        parts = []
        while num:
            remainder = num % base
            num //= base
            parts.append(alphabet[remainder])
        parts.reverse()
        return ''.join(parts)
    return f

alpha = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ_abcdefghijkmnopqrstuvwxyz"
print len(alpha)
encode = base_n_encoder(alpha)
decode = base_n_decoder(alpha)

#for v in (0, 4, 10, 60, 100, 481, 3881, 98839, 189238, 583832, 1039848):
#    s = encode(v)
#    d = decode(s)
#    print v, s, d
#    assert v==d, "Decoded value doesn't match"

#
config = ConfigObj('build.properties')

parser = argparse.ArgumentParser(description='Ony one arg')
parser.add_argument('-i','--input', help='Input file name',required=True)
args = parser.parse_args()

source_file_content = open(args.input, 'r').read()
html = markdown2.markdown(source_file_content , extras=["metadata",
"code-friendly", "cuddled-lists", "fenced-code-blocks", "header-ids" ,
"smarty-pants"])
metadata =  html.metadata

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
    print dateString
    print postTypeString
    print identifierString
else:
    print 'no dateString'

l = dateString.split('-')
l.append(str(identifierString))
uHash = "".join(l)
print int(uHash)
shortLink = encode(int(uHash))
d = decode(shortLink)
print shortLink, d

print 'url shortened to ' + shortLink



#frontMatterSub = re.compile("-{3}[\s\S]+-{3}", re.M)
#status_content = frontMatterSub.sub('', source_file_content).strip()
#
## a list if #hashtags in status_content
#lHashMatch=re.findall('#([\w]+)', status_content)
#
## a list if categories in front-matter
#lCategories = metadata['categories'].split()
#lnewCatergories = []
#
#for lCat in lCategories:
#    if lCat in lHashMatch:
#        print 'Category in text'
#        print lCat
#    else:
#        print 'No category in text so will append  to text #' + lCat
#        status_content += ' #'
#        status_content += lCat
#
#print 'number of chars: ' + str(len(status_content))
#
#status_content +=  ' ('
#status_content +=  config.get('project.domain')
#status_content +=  ' '
#status_content +=  shortLink
#status_content +=  ')'
#
#print 'number of chars: ' + str(len(status_content))
#print status_content
##
#if lHashMatch:
#    for iHashMatch in lHashMatch:
#        if iHashMatch in lCategories:
#            print 'the HashTag in text IS in front matter categories'
#        else:
#            print 'the HashTag in text NOT front matter categories'
#            metadata['categories'] += ' '
#            metadata['categories'] += iHashMatch
#
#
#print 'number of chars: ' + str(len(status_content))
#print status_content
#print metadata['categories']
#
#APP_KEY = config.get('twitter.app.key')
#APP_SECRET = config.get('twitter.app.secret')
#
#OAUTH_TOKEN = config.get('twitter.oauth.token')
#OAUTH_TOKEN_SECRET = config.get('twitter.oauth.token_secret')
#
#twitter = Twython(APP_KEY, APP_SECRET,
#                  OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
#
#jsonResult = twitter.update_status(status=status_content)
#
#for line in fileinput.input(args.input , inplace=1):
#    if line.startswith('categories:'):
#        print 'categories: ' + metadata['categories']
#        if metadata['link-tweet-id'] is None:
#            print 'link-tweet-id: ' + str(jsonResult['id']),
#        if metadata['link-shortened'] is None:
#            print 'link-shortened: ' + shortLink
#    else:
#        print line,
