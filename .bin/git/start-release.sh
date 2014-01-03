#!/bin/sh +x
#Semantic Versioning 2.0.0
#MAJOR.MINOR.PATCH,
# Patch when you fix something   Hotfix
# Minor add new feature         Feature -- Staging Development
# Major                         Release -- Production Release
# https://github.com/nvie/gitflow/wiki/Command-Line-Arguments
# http://danielkummer.github.io/git-flow-cheatsheet/

cd ../../
echo $PWD
REF=$(git symbolic-ref HEAD 2> /dev/null) || exit 0
CURRENT="${REF#refs/heads/}"
echo ${CURRENT}
bumpversion minor --commit
#

VERSION=$(cat sem.version)
RELEASE="v${VERSION}"
#RELEASE="v0.6.0"

MSG="Minor Release $RELEASE"

git flow release list
#
#

echo $RELEASE
#
git flow release start $RELEASE
git flow release publish  $RELEASE
#git flow release track $RELEASE
git flow release finish -F -m 'fin' -p $RELEASE



exit

#echo 'add FEATURE NAME _____________'
#read -p "FEATURE?" FEATURE
#
#echo "FEATURE $FEATURE Continue (y/n)"
#read -p "Continue (y/n)?" choice
#case "$choice" in
#    y|Y )
#        echo "Adding FEATURE BRANCH: $FEATURE";;
#    n|N )
#        echo "no"
#        exit;;
#    * )
#        echo "invalid"
#        exit;;
#esac



