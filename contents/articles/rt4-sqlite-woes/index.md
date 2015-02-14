---
title: request-tracker4 sqlite woes
author: steve-nolen
date: 2014-02-24
template: article.jade
---

My team has been using RT (or request-tracker4) as a ticketing system to manage incoming requests. As with most new system implementations in a group as small as mine is, we can hit the ground running and just make changes/adjust as needed.  This one made me a bit frustrated, so I figured I'd share in case it helped someone else.  

---

When you install request-tracker4 using the ubuntu 12.04 packages, the packages by default use sqlite (which is fine, yadda yadda, since it's easier to set up). The annoyance here is that RT doesn't readily support version upgrades when using sqlite (only mysql and postgres). 

Well, we ended up with a good 6-8 months of usage on the sqlite db but now I wanted to upgrade to a newer version! Off to migrate the sqlite db to mysql.  While sql is sql, there are some distinct inconsistencies between sqlite and mysql, so dump->import wouldn't work (and, based on some searches, folks were having trouble with this conversion for RT specifically.  I wrote a little bash script to manage the process (so I could test on a clone of my vm, then perform on the live version).  It worked perfectly, so I'll leave it below! 

I used a root account for this (in addition to a mysql root account, since the RT db init process was extremely temperamental), and don't forget to change the RT_SiteConfig.pm file as suggested in the script! Some extra datatype conversions were necessary, since some sqlite columns supported NULL when the mysql equivalent did not.

```bash
#!/bin/bash
#converts a request-tracker 4.0.4 sqlite database to mysql
#run me as root, or adjust accordingly

####BEFORE RUNNING####
##edit /etc/request-tracker4/RT_SiteConfig.pm
##Set($DatabaseType, 'mysql');
##Set($DatabaseHost, 'localhost');
##Set($DatabasePort, '');
##Set($DatabaseUser , 'rt_user');
##Set($DatabasePassword , '{password}');
##Set($DatabaseName , 'rt_dbname');

#best to stop apache before running this, just so we can be sane about data usage.
service apache2 stop

#create table list
export tables="ACL
Articles
Attachments
Attributes
CachedGroupMembers
Classes
CustomFieldValues
CustomFields
GroupMembers
Groups
Links
ObjectClasses
ObjectCustomFieldValues
ObjectCustomFields
ObjectTopics
Principals
Queues
ScripActions
ScripConditions
Scrips
Templates
Tickets
Topics
Transactions
Users"



#init the rt mysql database, remove pre-created data, since we don't want it.
rt-setup-database --action init --dba root
for i in $tables
do
	mysql -urt_user -p{password} rt_dbname -e "delete from $i"
done

#copy existing sqlite database (so we don't overwrite), file location based on installation method
mkdir -p /tmp/rt_sqlite
cp /var/lib/dbconfig-common/sqlite3/request-tracker4/rtdb /tmp/rt_sqlite/rtdb.sqlite


#write our sqlite commands to a temporary file. notice the null commands at the beginning.
echo "update Templates set TranslationOf=0 where TranslationOf is NULL;
update Tickets set IssueStatement=0 where IssueStatement is NULL;
update Tickets set Resolution=0 where Resolution is NULL;
update Transactions set TimeTaken=0 where TimeTaken is NULL;
update Tickets set InitialPriority=0 where InitialPriority is NULL;
update Tickets set FinalPriority=0 where FinalPriority is NULL;
update Tickets set TimeEstimated=0 where TimeEstimated is NULL;
update Tickets set TimeLeft=0 where TimeLeft is NULL;" > /tmp/rt_sqlite/rt_sqlite.transactions

for i in $tables
do
	echo ".output /tmp/rt_sqlite/data_$i" >> /tmp/rt_sqlite/rt_sqlite.transactions
	echo ".mode insert $i" >> /tmp/rt_sqlite/rt_sqlite.transactions
	echo "select * from $i;" >> /tmp/rt_sqlite/rt_sqlite.transactions
done


#export data from sqlite, separate file per table
sqlite3 /tmp/rt_sqlite/rtdb.sqlite < /tmp/rt_sqlite/rt_sqlite.transactions

#finally, import the data to mysql
for i in `ls -1 /tmp/rt_sqlite/data_*`
do 
	mysql -urt_user -p{password} rt_dbname < $i
done

#let's start apache back up and cross our fingers!
service apache2 start
```