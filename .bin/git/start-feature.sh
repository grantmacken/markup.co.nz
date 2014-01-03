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

git flow feature list -v

echo 'add FEATURE NAME _____________'
read -p "FEATURE?" FEATURE

echo "FEATURE $FEATURE Continue (y/n)"
read -p "Continue (y/n)?" choice
case "$choice" in
    y|Y )
        echo "Adding FEATURE BRANCH: $FEATURE";;
    n|N )
        echo "no"
        exit;;
    * )
        echo "invalid"
        exit;;
esac

git flow feature start $FEATURE
bumpversion patch --commit
VERSION=$(cat sem.version)

git flow feature publish  $FEATURE
#git flow feature track  $FEATURE



