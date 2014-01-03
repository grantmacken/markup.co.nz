#!/bin/sh +x
#Semantic Versioning 2.0.0
#MAJOR.MINOR.PATCH,
# Patch when you fix something   Hotfix
# Minor add new feature         Feature -- Staging Development
# Major                         Release -- Production Release
# https://github.com/nvie/gitflow/wiki/Command-Line-Arguments
# http://danielkummer.github.io/git-flow-cheatsheet/
#http://blogs.endjin.com/2013/04/a-step-by-step-guide-to-using-gitflow-with-teamcity-part-3-gitflow-commands/

cd ../../
echo $PWD
REF=$(git symbolic-ref HEAD 2> /dev/null) || exit 0
CURRENT="${REF#refs/heads/}"
echo ${CURRENT}

git flow feature list -v

#git checkout featurekomodo-toolbox

#git checkout feature/komodo-toolbox
#exit

echo 'FEATURE NAME _____________'
read -p "FEATURE?" FEATURE

echo "FEATURE $FEATURE Continue (y/n)"
read -p "Continue (y/n)?" choice
case "$choice" in
    y|Y )
        echo "Finish FEATURE BRANCH: $FEATURE";;
    n|N )
        echo "no"
        exit;;
    * )
        echo "invalid"
        exit;;
esac

bumpversion patch --commit
VERSION=$(cat sem.version)

git flow feature finish $FEATURE
