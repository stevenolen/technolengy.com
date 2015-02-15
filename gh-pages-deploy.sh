#!/bin/bash
rm -rf build || exit 0;
( cd build
 git init
 git config user.name "Travis-CI"
 git config user.email "travis@technolengy.com"
 git add .
 git commit -m "Deployed to Github Pages"
 git push --force --quiet "https://${GH_TOKEN}@github.com/stevenolen/technolengy.com" master:gh-pages > /dev/null 2>&1
)