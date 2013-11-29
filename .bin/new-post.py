#!/usr/bin/env python
import sys
import os
import argparse
import time
import datetime
import re



parser = argparse.ArgumentParser(description='Ony one arg')
parser.add_argument('-i','--input', help='Input file name',required=True)
args = parser.parse_args()


try:
    atime = time.localtime()
    year = time.strftime('%Y',atime)
    month = time.strftime('%m',atime)
    day = time.strftime('%d',atime)
    outFile = os.path.join( 'www' ,'_posts' , year + '-' + month + '-' + day + '-' +  args.input + '.md' )
except ValueError:
    raise

print outFile

try:
    if not os.path.exists(outFile):
        open(outFile, 'w').close()
        #os.utime(outFile, (now, now))
except OSError:
    if os.path.exists(outFile):
        # We are nearly safe
        pass
    else:
        # There was an error on creation, so make sure we know about it
        raise
