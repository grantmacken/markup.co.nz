---
title: svg workflow
author: Grant MacKenzie
published: 2014-03-08T08:30:20
id: tag:markup.co.nz,2014-03-08:article:2tT1
summary: About pre-proccessing SVG with Scour, then Gziping, then storing in existdb, then serving the SVG gzipped file via Nginx
categories: svg scour existdb nginx
draft: no
---

When we save our svg in our ```www/resources/images/svg``` dir  in our editor
we trigger a call to an ant target named ```store-svg``` which does our grunt work.
Before we store the SVG we want to pre-proccess the file.

1. to create a smaller file size

2. and generate a gzipped version of the file.

In our pre-proccess stage we run [scour]( https://github.com/oberstet/scour ) an SVG scrubber.

    <echo>Run Scour</echo>
    <exec executable="/bin/sh">
	<arg line='-c "scour -i ${srcfile} -o ${outfile} --strip-xml-prolog --indent=none"' />
	<redirector outputproperty="scour-out" />
    </exec>

We should see some improvement in size, however we can reduce the file size even
further by gziping. We could also gzip with scour however, we won't,
as we have compiled Nginx ```-with-http_gzip_static_module```, and with the
[http_gzip_static_module](http://nginx.org/en/docs/http/ngx_http_gzip_static_module.html)
we have [no support for .svgz files. ](http://trac.nginx.org/nginx/ticket/372).
So instead we create gzip the file upload to eXistdb and allow Nginx to send the
compressed file with the “.gz” file name extension instead of the regular svg
file.

    xml
    <exec executable="/bin/sh">
	<arg line='-c "gzip -v -9 &lt; ${deployFile} &gt; ${deployGzipFile}"' />
	<redirector outputproperty="gzip-out" />
    </exec>

These 2 files get uploaded to existdb

    xml
    <echo>Storing ${deployFile} to  ${exist.uri}</echo>
    <xdb:store uri="${exist.uri}"
               createcollection="false"
               srcfile="${deployFile}"
               user="${exist.username}"
               password="${exist.password}"
               />

When these files arrive at our localhost they trigger an upload to remote.

Nginx and eXist-db
------------------

Our eXist-db is proxied behind Ngnix. As mentioned before we have compiled
Nginx ```-with-http_gzip_static_module```, and this allows Nginx to send static
compressed files instead of our regular uncompressed ones if it can find one
with a gz extension.

    location ~* ^(/resources/images/svg.+)$ {
      gzip_static  on;
      expires epoch;
      add_header Pragma no-cache;
      try_files  $uri $uri.svg.gz $uri.svg  @proxy;
      log_not_found off;
    }

The idea of having a proxy is to take the load off the application server.
According to the [ngnix pitfalls](http://wiki.nginx.org/Pitfalls) doc its a bad
idea to proxy everything.

> The try_files directive tries files in a specific order.
> This means that Nginx can  first look for a number of static files to serve and if not found move on to a user defined fallback.
> This way PHP doesn't get involved unless an actual PHP file is requested and you save resources, especially if you're serving a 1MB image over PHP a few thousand times versus serving it directly.

Forget about PHP , we apply the same principles to existdb and use the ```try-files``` directive

    nginx
    try_files  $uri $uri.svg.gz $uri.svg  @proxy;

Nginx knows where to look because we have set the root directive
to eXist filesystem.

    nginx
    listen 80 default deferred;
    server_name  ~^(www\.)?(?<domain>.+)$;
    charset utf-8;
    # root set to eXist data file system
    root   /usr/local/eXist/webapp/WEB-INF/data/fs/db/apps/$domain;

So only if Ngnix can not find the files it will look at the proxy and pull the
data from eXist.

    nginx
    location @proxy {
      include       proxy_cache.conf;
      rewrite ^/?(.*)$ /exist/apps/$domain/$1 break;
      proxy_pass http://localhost:8080;
      }

eXist will store binary files in the filesystem directory but not xml files,
so you will find in the fs directory  'icons.svg.gz' but not 'icons.svg'.
Now because we have the Ngnix directive ``` gzip_static  on; ``` for the
 ```location ~* ^(/resources/images/svg.+)$``` Nginx will serve 'icons.svg.gz' as
'icons.svg'.  Clear as mud.

Checking serving of SVG gzipped  data
------------------------------------

    sh
    [echo]  Tests: are we serving gzipped svg?
    [echo] curl  -s -o /dev/null  -w "size_download=%{size_download}" http://www.markup.co.nz/resources/images/svg/icons.svg
    [echo] curl  -s -o /dev/null  -H "Accept-Encoding: gzip,deflate" -w "size_download=%{size_download}"  http://www.markup.co.nz/resources/images/svg/icons.svg
    [echo] curl -s -I -H "Accept-Encoding: gzip,deflate"  http://www.markup.co.nz/resources/images/svg/icons.svg  | grep -i "Content-Encoding:"
