---
title:  pages and posts
---


<!--

Testing Webmentions
-------------------

DONE: Create an webmention endpoint on localhost ```/modules_local/webmention.xq```

DONE: Create a test note [ I am going to try comment on this note](http://markup.co.nz/archive/2014/03/16/083751)

```curl -s -i http://markup.co.nz/archive/2014/03/16/083751 | grep 'rel="webmention"'```

We should see our own webmention endpoint in both the response header and a link in the document head

	Link: <http://localhost:8080/exist/rest/db/apps/markup.co.nz/modules/_local/webmention.xq>; rel="webmention"
	    <link rel="webmention" href="http://localhost:8080/exist/rest/db/apps/markup.co.nz/modules/_local/webmention.xq" />
    grant@grant:~$

With this in place we can make on our own page

Create a comment  with macro ```new comment`` which comments on the note.

[comment created] ( http://markup.co.nz/archive/2014/03/16/141619 )

Create reply context with macro ```reply-context``` which generates and stores citation
-->



Pages and  Posts
-----------------

![wading bird](/resources/images/wading-bird.png)

It is a common pattern for blog aware static-site generators and content
management systems to differentiate between *posts* and *pages*.

**Pages** are generated from markdown content organised in hierarchical folders
under the www folder. Any markdown pages under a folder will utilise the
template page for the folder. Markdown files under ```/www/about``` will have a
template page found in ```/templates/pages/about.html```. The exception is the
home page ```/www/index.md``` which has its own home template
```/templates/pages/home.html```

**Posts** are generated from markdown content organised in the &#95;posts
directory. Unlike pages, posts are *date driven* and can be organised by
*categories* and *tags*. A post has a specific file naming pattern.
```{year}-{month}-{day}-{title}.md```. YEAR is a four-digit number, MONTH and
DAY are both two-digit numbers. e.g. ```2013-09-03-my-tile.md```. A post is
placed under the &#95;posts directory. The created permalink entry will be
```/{archive}/{year}/{month}/{day}/title```.


Reference Links:

* [blogger: posts-vs-pages](http://www.mybloggerlab.com/2013/02/what-is-the-difference-between-posts-vs-pages-in-blogger.html)
* [wordpress: post-vs-page](http://en.support.wordpress.com/post-vs-page/)
* [semiologic: posts-vs-pages](http://www.semiologic.com/resources/blogging/posts-vs-pages/)
