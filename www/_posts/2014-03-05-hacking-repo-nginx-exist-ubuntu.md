---
title: hacking repo nginx exist ubuntu
author: Grant MacKenzie
published: 2014-03-05T15:01:05
id: tag:markup.co.nz,2014-03-05:article:2tQ2
summary:
categories:
draft: no
---

re. [nginx-eXist-ubuntu](https://github.com/grantmacken/nginx-eXist-ubuntu)


Thanks for the mention Joe.
The scripts set up for 'remote-host  production',  enable  Nginx to act as a reverse proxy and cache server for eXist.
For local-host development  Nginx just acts as a reverse proxy because you want to see your development changes before you deploy.

Its my dog-food, it works for me.  I make no claim to be an expert on caching.

If anyone thinks it useful I'll create a ant file with a properties file to alter variable properties like
the period the cache is valid which is hard coded. Set to one day below.

    proxy_cache_valid  200 301 302 304 1d; to
    proxy_cache_valid  200 301 302 304 ${period.valid};

ref:  [proxy-cache.conf]( https://github.com/grantmacken/nginx-eXist-ubuntu/blob/master/config/prod/proxy-cache.conf )

Also some path stuff is hard-coded ( convention over configuration )
e.g.  '/resources/images'  which need to be altered to work for your paths
ref:  [server-dev-locations.conf](https://github.com/grantmacken/nginx-eXist-ubuntu/blob/master/config/prod/server-production-locations.conf) and server-production-locations.conf

Also the bundle of rewrite regexp are designed to work with my eXist templates

    rewrite "^/?(?:index|index.html)?$" /index.html break;
    rewrite "^/?([0-9A-HJ-NP-Z_a-km-z]{3}[0-9]{1,2})$" /$1.html break;
    rewrite "^/?([\w\-_]+)/?(?:index|index.html)?$" /$1/index.html break;
    rewrite "^/?(((?:[\w\-_]+)/)+(?:[\w\-_]+))(?:\.(html|md))?$"  /$1.html break;

ref: [server-common.conf](https://github.com/grantmacken/nginx-eXist-ubuntu/blob/master/config/common/server-common.conf)

They are pretty generic but the 2nd one is tied to my base60 URLshortner.
Feel free to fork the repo and hack till you get want you want.
