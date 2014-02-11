---
title: Creating Articles
author: Grant MacKenzie
published: 2014-01-10T11:06:55
id: tag:markup.co.nz,2014-01-10:article:creating-articles
summary: Creating article posts in our Komodo workspace
categories: indieweb
---

The komodo project workspace is used for publishing 'Articles' on my website.
Articles ;contain a title, and marked up html content and are considered a type
of 'post'.

komodo ux: 'komodo tool' 'new-article'

Creates a md file in the ```www/_posts``` directory: , file writes out a
'front matter' block  meta data to the file and opens in komodo.

The 'front matter' contains the following ``key: values``

* a title key with the value derived from the file name
* an author key  with the value derived from build.properties file
* a published key with a datetime value ```2014-01-10T11:06:55 ``` derived from
  some python vodoo
* an id key with the value based on [TagUri](http://www.taguri.org/)<br/>
  ```tag:markup.co.nz,2014-01-10:article:test-new-article``` <br/> Note my
  taguri contains the 'post type', *article*.
* a summary key for index pages. The values to be typed
* a categories key. The values to be typed. Each category space seperated.


The 'front matter' for this page looks like this.

    ---
    title: Creating Articles
    author: Grant MacKenzie
    published: 2014-01-10T11:06:55
    id: tag:markup.co.nz,2014-01-10:article:creating-articles
    summary: Creating article posts in our Komodo workspace
    categories: indieweb
    ---


After creating some *markdown content* , saving the md 'article' will generate an an *atom
entry* and [post](http://indiewebcamp.com/posts) it our exist-dbs` domain data archive
<br/> ```/data/archive/[year]/[month]/[day]/[file-name]``` and can be viewed at
its permalink ```/archive/[year]/[month]/[day]/[file-name]```

Test:  [validate-h-entry](http://indiewebify.me/validate-h-entry/?url=http%3A%2F%2Fmarkup.co.nz%2Farchive%2F2013%2F11%2F13%2Fpages-posts-and-post-types)


Note: every 'type' of post will get archived in a similar manner.
