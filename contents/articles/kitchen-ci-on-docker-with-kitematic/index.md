---
title: Test Kitchen on Docker with Kitematic
author: steve-nolen
date: 2015-04-28
template: article.jade
---

I've had the great opportunity in the past 4 or so months to really get going with chef, and writing automated infrastructure.
It's an incredibly deep world/community filled with loads of wonderful people and tools.  One of the best tools for writing
quality chef cookbooks is [Test Kitchen](http://kitchen.ci). Test Kitchen by default uses a vagrant/virtual box environment to
quickly converge and test a chef cookbook.  But I'm ready to push this forward with docker for speed of convergence! Even better,
I use a mac for my local machine and the docker team released an awesome beta of [Kitematic](https://kitematic.com/) to facilitate docker
containers on Mac OS. Getting them set up together requires very little effort, but I wanted to note it here in case it was helpful! 

---

Kitematic works extremely (hey, I haven't used it so maybe it's identical to) similarly to boot2docker.  Sean (who wrote the [kitchen-docker](https://github.com/portertech/kitchen-docker)  driver) offers an example for getting this working with boot2docker, which I only slightly extended.

First, get kitchen-docker installed via `gem install kitchen-docker`.

Second, export a few environment variables (or put these in your `.bash_profile):
```bash
export DOCKER_HOST=tcp://192.168.99.100:2376
export DOCKER_CERT_PATH=~/.docker/machine/machines/dev
export DOCKER_TLS_VERIFY=1
```

Next, modify the driver in your `.kitchen.yml` file:
```yaml
---
driver:
  name: docker
driver_config:
  require_chef_omnibus: true
  use_sudo: false
[rest of config here]
```

And finally: make sure kitematic is running and get going with your tests: `kitchen test`.

That's it! Thanks!
