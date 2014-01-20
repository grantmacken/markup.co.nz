---
title:  pages and posts
---

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

