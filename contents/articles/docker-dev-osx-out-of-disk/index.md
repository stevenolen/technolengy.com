---
title: "Docker \"Development\" on OSX: out of space!"
author: steve-nolen
date: 2016-01-21
template: article.jade
---

Using docker-machine/docker-toolbox to do some hefty container lifting? Constantly running out of disk space? A quick resolution to your problem!

---

If you're anything like me, you've been creating and toying with docker containers (and maybe docker-compose and the enormous ecosystem of docker tools) in a development environment (hopefully in production too!). If you're doing dev stuff on OSX with the [docker-toolbox](https://www.docker.com/docker-toolbox), kitematic etc etc you've likely found that you if you debug/iterate on the same container builds you've filled up that measely 20GB of space that `docker-machine` gives you in virtualbox really quickly.  The quickest way to regain some space is to remove those pesky dangling images (courtesy of [this](http://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images) stackoverflow q):

```bash
docker rm $(docker ps -qa --no-trunc --filter "status=exited")
```

or one even better (as the helpful VonC mentions) is to make an alias to do this (name it however you want, i used the keyword 'docker' so I could remind myself with tab completion):

```bash
Steves-MacBook-Pro:~ steve$ cat ~/.bash_profile | grep none
alias docker-rm-dangling='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
```

At some point, you'll still end up hitting a wall.  Bloated container sizes or just *many, many* containers -- you're going to need some more space. Thankfully docker-machine makes that exceedingly simple.  I'll assume you don't need to save any data (it's just dev, afterall). You can quickly swap from 20G to 50G with this:

```bash
docker-machine rm default
docker-machine create --driver virtualbox --virtualbox-disk-size "50000" --virtualbox-memory "2048" default
```

This should get me out of that bind for a good long while!

