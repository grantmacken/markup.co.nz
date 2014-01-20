#!/usr/bin/env python
import sys
import os
import argparse
import time
import datetime
import re

from configobj import ConfigObj
config = ConfigObj('build.properties')


parser = argparse.ArgumentParser(description='Ony one arg')
parser.add_argument('-i','--input', help='Input file name',required=True)
args = parser.parse_args()


try:
    atime = time.localtime()
    year = time.strftime('%Y',atime)
    month = time.strftime('%m',atime)
    day = time.strftime('%d',atime)
    hour = time.strftime('%H',atime)
    minute = time.strftime('%M',atime)
    second = time.strftime('%S',atime)
    sDate = year + '-' + month + '-' + day
    sTitle  = 'title: ' + args.input.replace('-', ' ')   + '\n'
    sPublished = 'published: ' + sDate + 'T' + hour + \
                ':' + minute + ':' + second + '\n'
    sAuthor = 'author: ' +  config.get('project.author') + '\n'
    sID =  'id: tag:' +  config.get('project.domain') + ',' + sDate + ':' + \
    'article' +':' + args.input +'\n'

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
        f.write('summary: my summary \n')
        f.write('categories: myCategory \n')
        f.write('---\n \n')
        f.close()
        cmd = "komodo " + outFile
        os.system(cmd)
        #os.utime(outFile, (now, now))

        os.system("some_command with args")
except OSError:
    if os.path.exists(outFile):
        # We are nearly safe
        pass
    else:
        # There was an error on creation, so make sure we know about it
        raise
