---
title: too much byobu!
author: steve-nolen
date: 2013-09-19
template: article.jade
---

For the past few years, I've been using a screen/tmux replacement that I really like, called [byobu](http://byobu.co/). 
It's an absolutely fantastic tool, and one that should be looked at, if you're not at least using screen or tmux (and 
perhaps even if you are using screen or tmux!) Here's the thing though, byobu in byobu can be a real pain. 

---

At $job recently, I was finally able to realize a long-planned situation: 
a single home directory per user on all of our servers (done via LDAP and NFS). After my first couple hours in this 
environment I noticed that byobu would try to launch itself each time I logged into a server (and often make my brain 
explode, when byobu runs in byobu, yadda yadda).

It turns out there are a few ways to handle this.  The first (per [this](https://help.ubuntu.com/community/Byobu) 
ubuntu community help page) is to run this parameter when logging in to each host:


```bash
ssh -t remotehost bash
```

But seriously...that's a pain.  It's likely the best way to prevent byobu from running on most hosts is just to add 
a simple bash if statement to your .profile:

```bash
export HOSTNAME=`hostname`
if [ "$HOSTNAME" = "host_where_byobu_should_run" ]; then
_byobu_sourced=1 . /usr/bin/byobu-launch
fi
```

One thing to note is that this will probably break `byobu-enable`... but who really needs that anyway!