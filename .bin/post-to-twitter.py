# -*- coding: utf-8 -*-

import re
import sys
import datetime
import math
import codecs
import argparse
import fileinput
import markdown2

from configobj import ConfigObj
from twython import Twython

ELLIPSIS = '...'

def setCategories( statusContent , lCategories):
    lHashMatch=re.findall('#([\w]+)', statusContent)
    for lCat in lCategories:
        if lCat in lHashMatch:
            print 'Category in text'
            print lCat
        else:
            print 'No category in text so will append  to text #' + lCat
            statusContent += ' #'
            statusContent += lCat
    return statusContent



def postToTwitter( statusContent):
    APP_KEY = config.get('twitter.app.key')
    APP_SECRET = config.get('twitter.app.secret')
    OAUTH_TOKEN = config.get('twitter.oauth.token')
    OAUTH_TOKEN_SECRET = config.get('twitter.oauth.token_secret')
    twitter = Twython(APP_KEY, APP_SECRET,
                      OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
    jsonResult = twitter.update_status(status=status_content)
    return jsonResult


def updateFrontMatter( jsonResultID ):
    catLine = 'categories: ' + metadata['categories']
    try:
        metaDataLinkTweetID = metadata['link-tweet-id']
    except KeyError, e:
        print 'OK: a KeyError here means we have no meta link-tweet-id'
        print 'so we will add it to catline'
        catLine += '\n'
        catLine += 'link-tweet-id: '
        catLine += str(jsonResultID)
    except:
        print 'Opps. should not happen'
        sys.exit('Error!')
        raise
    for line in fileinput.input(args.input , inplace=1):
        if line.startswith('categories:'):
            print catLine
        else:
            print line,
    return 'OK'

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


try:
    source_file_content = open(args.input, 'r').read()
    html = markdown2.markdown(source_file_content , extras=["metadata"])
    metadata = html.metadata
    print 'metadata fetched from front-matter in markdown file'
    idNoteMatch = re.compile("^tag:.+:(note):.+$")
    idDateMatch = re.compile("^tag:.+,(\d{4}-\d{2}-\d{2}):(note|article):(.+)$")
    match = idDateMatch.match(metadata['id'])
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
        sys.exit('ERROR!')
except KeyError, e:
        print 'I got a KeyError - reason "%s"' % str(e)
        sys.exit('Error!')
except:
    print "Unexpected error:", sys.exc_info()[0]
    sys.exit('Error!')
    raise

if postTypeString == 'note':
    try:
        print 'Get the text to post'
        print '--------------------'
        frontMatterSub = re.compile("-{3}[\s\S]+-{3}", re.M)
        status_content = frontMatterSub.sub('', source_file_content).strip()
        lCategories = metadata['categories'].split()
        status_content = setCategories(status_content, lCategories)
        print status_content
        print '--------------------'
        print 'number of chars so  far: ' + str(len(status_content))
    except KeyError, e:
            print 'I got a KeyError - reason "%s"' % str(e)
            sys.exit('Error!')
    except:
        print "Unexpected error:", sys.exc_info()[0]
        sys.exit('Error!')
        raise

    if len(status_content) > 140:
        isAbbrevNote = True
        print ( postTypeString + " will now be abbreviated note ")
        print ( " abbreviated note will use summary")
        try:
            status_content = metadata['summary']
            if ( len(status_content) == 0 ):
                print  str(len(status_content))
                print 'add summary'
                sys.exit('ERROR!')
            else:
                print 'OK'
                status_content = setCategories(status_content, lCategories)
                status_content += ELLIPSIS
                status_content += ' '
                status_content += config.get('project.domain')
                status_content += '/'
                status_content += identifierString
                print status_content
        except KeyError, e:
            print 'I got a KeyError - reason "%s"' % str(e)
            sys.exit('Error!')
        except:
            print 'I got another exception, but I should re-raise'
            sys.exit('Error!')
            raise
    else:
        isAbbrevNote = False

    print 'number of chars so far: ' + str(len(status_content))
    print status_content

    APP_KEY = config.get('twitter.app.key')
    APP_SECRET = config.get('twitter.app.secret')

    OAUTH_TOKEN = config.get('twitter.oauth.token')
    OAUTH_TOKEN_SECRET = config.get('twitter.oauth.token_secret')

    twitter = Twython(APP_KEY, APP_SECRET,
                      OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

    jsonResult = twitter.update_status(status=status_content)
    jsonResultID = jsonResult['id']

    # For every hashtag
    # if the HashTag is NOT front matter categories'
    # then add to metadata['categories']
    lHashMatch=re.findall('#([\w]+)', status_content)
    if lHashMatch:
        for iHashMatch in lHashMatch:
            if iHashMatch in lCategories:
                print 'the HashTag in text IS in front matter categories'
            else:
                print 'the HashTag in text NOT front matter categories'
                metadata['categories'] += ' '
                metadata['categories'] += iHashMatch

    catLine = 'categories: ' + metadata['categories']

    try:
        metaDataLinkTweetID = metadata['link-tweet-id']
    except KeyError, e:
        print 'OK: a KeyError here means we have no meta link-tweet-id'
        print 'so we will add it to catline'
        catLine += '\n'
        catLine += 'link-tweet-id: '
        catLine += str(jsonResultID)
    except:
        print 'Opps. should not happen'
        sys.exit('Error!')
        raise


    for line in fileinput.input(args.input , inplace=1):
        if line.startswith('categories:'):
            print catLine
        else:
            print line,

else:
    print ( postTypeString + " will now be abbreviated note ")
    print ( " abbreviated note will use summary")
    try:
        lCategories = metadata['categories'].split()
        status_content = metadata['title']
        status_content = setCategories(status_content, lCategories)
        status_content += ' - \n'
        status_content += metadata['summary']
        status_content += ELLIPSIS
        status_content += '\n'
        status_content += config.get('project.domain')
        status_content += '/'
        status_content += identifierString
        print status_content

        if ( len(status_content) > 14 ):
            print 'number of characters: ' + str(len(status_content))
            print 'Oh No GREATER THAN the Twitter 140 Character limit!'
            sys.exit('ERROR!')
        else:
            jsonResult = postToTwitter(status_content)
            print  updateFrontMatter( jsonResult['id'] )
    except KeyError, e:
        print 'I got a KeyError - reason "%s"' % str(e)
        sys.exit('Error!')
    except:
        print 'I got another exception, but I should re-raise'
        sys.exit('Error!')
        raise



#
#status_content +=  ' ('
#status_content +=  config.get('project.domain')
#status_content +=  ' '
#status_content +=  identifierString
#status_content +=  ')'
#
