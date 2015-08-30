---
layout: post
title: backup of linux vps using gautil
date: 2015-08-30
categories: backup google gsutil
---

Backing up linux servers to google clound storage with gsutil using the storage option nearline. 

start by configuring gsutil
{% highlight bash %}
$ gsutil config
{% endhighlight bash %}

create a nearline bucket on google clound storage. the mb flag means create bucket. the -l flag means location options is ASIA, EU, US. for more options look on [gsutil mb doc](https://cloud.google.com/storage/docs/gsutil/commands/mb)
{% highlight bash %}
$ gsutil mb -l EU -c nearline gs://<bucket>
{% endhighlight bash %}

set up the backup to run ones every day by placing this script in /etc/cron.daily/
{% highlight bash %}
#!/bin/bash
gsutil -qm rsync -x '.<exclude-file>|<exclude-file>' -r /<src-directory>  gs://<bucket>
{% endhighlight bash %}
