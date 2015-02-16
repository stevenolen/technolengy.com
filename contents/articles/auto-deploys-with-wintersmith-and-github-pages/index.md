---
title: Auto Deploys using wintersmith, travisci and github pages
author: steve-nolen
date: 2015-02-16
template: article.jade
---

My latest attempt at a blog has been dead for nearly a year. Why run a wordpress install for a few posts from a year back, right?
So I moved the content to a [wintersmith](http://wintersmith.io) template and hooked into a [TravisCI](https://travis-ci.org/) build to send the compiled
static content back to github for hosting on github pages. Here's how I did it!

---

Unsuprisingly, I didn't come up with this process on my own. However, while searching I couldn't find anyone who had used TravisCI and wintersmith in particular, so maybe this will be helpful to someone, somewhere! My goal was to use only one github repository to host the wintersmith (jade assets and plugins) and the compiled code to be served on github pages.  First, I grabbed
wintersmith from npm with `npm install -g wintersmith` and initiated a default blog template: `wintersmith new technolengy.com`. After modifying the content to my pleasing (as you can likely tell, I didn't even bother changing the CSS one bit. If it were socially acceptable I'd probably just serve unstyled text) I commited this to master on a github repo and set up the TravisCI integration. 

  * Grab an account from [TravisCI](https://travis-ci.org/).
  * create a new github token for public repos from [here](https://github.com/settings/applications)
  * encrypt that token using the travis ruby gem (`gem install travis`)
    * `travis encrypt -r gh_user/gh_repo "GH_TOKEN=new_token_here"` (you'll need this output soon)
  * check out and commit an orphan branch to your repo
    * `git checkout --orphan gh-pages`
    * `git rm -rf .`
    * `touch .nojekyll` (since we don't need github trying to use jekyll on this repo)
    * `git add .`
    * `git commit -m 'some message about gh-pages'`
    * `git push origin gh-pages`
  * add a .travis.yml TravisCI config file to this repository (see the file contents below)
  * add a simple bash script to send the build contents back to github pages (again see below)

 And that's it! Once you've hooked your builds into TravisCI, you should have viewable content on github pages! You may also want to add a `CNAME` file to your wintersmith 'contents' dir to serve these pages from an apex domain.  And one last thing: make sure to turn off "build on pull request" on travis for this repository, don't want someone else offering a pull request and changing your blog!

 Here are the files (but you can see my latest up-to-date versions by visiting this blog's source [here](https://github.com/stevenolen/technolengy.com)):

h2 .travis.yml
```yml
language: node_js
node_js:
  - "0.10"
before_install:
  - npm install wintersmith
script:
  - wintersmith build
after_success: 
  - bash gh-pages-deploy.sh
branches:
  only:
    master
env: 
  global:
    secure: "secure_token_here_quoted"
```

h2 gh-pages-deploy.sh
```bash
#!/bin/bash
cd build
git init
git config user.name "Travis-CI"
git config user.email "travis@email.com"
git add .
git commit -m "Deployed to Github Pages"
git push --force --quiet "https://${GH_TOKEN}@github.com/gh_user/gh_repo" master:gh-pages > /dev/null 2>&1
```