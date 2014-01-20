---
title: Pages, Posts and Post Types
author: Grant MacKenzie
published: 2013-11-13T08:40:01
id: tag:markup.co.nz,2013-11-13:article:pages-posts-and-post-types
summary: the difference between Pages and Posts and the Types of Posts
categories: indieweb
---

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

**Types of Posts:** All types posts will get put in the archive apart
from media-resources e.g. images. Following the Atom protocol pattern. The
'binary media' will have location under the 'resources' directory and the markup
entry about the media will get put in the archive.

Post types are differentiated because both the 'editing - publishing' workspace
and the published html display of the post varies by type.

**Articles**. An [article](http://indiewebcamp.com/article) post always has a 'title' and may contain html
markup. Therefore our komodo *publishing workspace* has way to enter the title
(front matter in an md file ) and a way to generate stuctured markup like
paragraphs from the markdown file (markdown2) and publish the resulting markup
to our domain. The view of the post data dependes on 'the post type'. A article
post is displayed in full at it's permalink page. The article summaries with
links are displayed on 'index pages' like 'a recent articles page' or
'articles category page'.

Test:  [validate-h-entry](http://indiewebify.me/validate-h-entry/?url=http%3A%2F%2Fmarkup.co.nz%2Farchive%2F2013%2F11%2F13%2Fpages-posts-and-post-types)

**Notes**. An [note](http://indiewebcamp.com/note) post does not have 'title' and consists of short piece of
plain text.




Reference Links:

* [blogger: posts-vs-pages](http://www.mybloggerlab.com/2013/02/what-is-the-difference-between-posts-vs-pages-in-blogger.html)
* [wordpress: post-vs-page](http://en.support.wordpress.com/post-vs-page/)
* [semiologic: posts-vs-pages](http://www.semiologic.com/resources/blogging/posts-vs-pages/)
