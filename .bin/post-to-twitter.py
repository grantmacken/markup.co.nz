#!/usr/bin/env python
import argparse
import re
import fileinput

from configobj import ConfigObj
from twython import Twython

config = ConfigObj('build.properties')


parser = argparse.ArgumentParser(description='Ony one arg')
parser.add_argument('-i','--input', help='Input file name',required=True)
args = parser.parse_args()

source_file_content = open(args.input, 'r').read()
frontMatterSub = re.compile("-{3}[\s\S]+-{3}", re.M)
status_content = frontMatterSub.sub('', source_file_content).strip()

print 'number of chars: ' + str(len(status_content))

APP_KEY = config.get('twitter.app.key')
APP_SECRET = config.get('twitter.app.secret')

OAUTH_TOKEN = config.get('twitter.oauth.token')
OAUTH_TOKEN_SECRET = config.get('twitter.oauth.token_secret')

twitter = Twython(APP_KEY, APP_SECRET,
                  OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

jsonResult = twitter.update_status(status=status_content)
print jsonResult['id']

for line in fileinput.input(args.input , inplace=1):
 print line,
 if line.startswith('categories:'):
     print 'link-tweet-id: ' + str(jsonResult['id'])
