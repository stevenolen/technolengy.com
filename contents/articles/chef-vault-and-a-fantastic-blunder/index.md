---
title: Chef-Vault and a Fantastic Blunder
author: steve-nolen
date: 2015-04-29
template: article.jade
---

This morning, like some other mornings, I really screwed one up! It's never fun to admit, but it is a part of life and in the spirit of openness I'll just do my best to embrace it!
Some background: I really, really love [chef-vault](https://github.com/Nordstrom/chef-vault). Apparently this morning I also really forgot how it works when I stupidly reset my chef
private key. In case you ever make this amazing mistake, here's how I went about resolving it!

---

I love having my chef cookbooks as open as possible, so in turn I really love using chef-vault to quickly and effectively privatize any (even potentially) private content! 
It's a breath of fresh air to anyone who has tried to manage encrypted databags on their own, or even just tried to manually set node attributes from the chef web manager for private content. Very briefly, it works by using the existing chef certificate method to encrypt a data bag such that your chef private key, the chef private keys of your other admins and any node that matches a search query is able to decrypt the data bag. It, in my opinion, is far superior to the traditional shared-secret approach of chef encrypted data bags.

Unfortunately, I really goofed this morning. I made a new organization on my chef server and for some unknown reason I decided to grab the 'starter kit' instead of setting the validation key for the new org (resulting in the regeneration of my chef user private key). Hey! Bad news! chef-vault uses that private key to decrypt my vaults! So when I went to edit a vault item, I was met with this wonderful exception:

```
ERROR: ChefVault::Exceptions::SecretDecryption: vault/item is encrypted for you, but your private key failed to decrypt the contents.  (if you regenerated your client key, have an administrator of the vault run 'knife vault refresh')
```

Well certainly that's no problem I'll just have a vault admin run the comm...oh. my only other vault administrator hasn't set up their keys yet. Great. Now what? I can go through the lengthy process of getting all of the private content from each host where it's been dropped and piece the bags back together -- but i've got loads of pieces in different places, and their format on disk is slightly different than the data bag storage. Thankfully, I still had this old key around that I could use!

The real fun starts! I wanted to use `knife vault show` or `knife vault edit` to get the current state of the bags, but now I have two keys: 1) gets me authenticated with chef, but wont decrypt the bags, 2) decrypts the bags but wont authenticate me with chef! So I dug down into the chef-vault code to see how they were handling this and did a one-line patch to [this file](https://github.com/Nordstrom/chef-vault/blob/17385e5610ff17be848f6848942658abe863bb17/lib/chef-vault/item.rb#L103) (note I've used a git commit ref in case the line number changes in the future!) to:

```ruby
private_key = OpenSSL::PKey::RSA.new(open('/path/to/old/key.pem').read())
```

Which allowed knife to use the normal chef key to grab the data bag, but chef-vault to use my old key to decrypt! A total hack, but a fun way to fix a stupid problem caused by yours truly. 
