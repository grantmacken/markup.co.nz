---
title: test new article
author: Grant MacKenzie
published: 2014-01-10T11:06:55
id: tag:markup.co.nz,2014-01-10:article:test-new-article
---

komodo ux: 'komodo tool' 'new-article'

Creates a md file in the ```www/_posts``` directory: , file writes out some meta
block data to the file and opens in komodo.


* a title from file name
* an author from build.properties
* a published datetime ```2014-01-10T11:06:55 ```
* an id based on [TagUri](http://www.taguri.org/)<br/>
  ```tag:markup.co.nz,2014-01-10:article:test-new-article``` <br/> Note my
  taguri contains the 'post type', *article*.


After creating some content, saving the md 'article' will generate an an *atom
entry* and [post](http://indiewebcamp.com/posts) it to exist-dbs` posts archive
<br/> ```/data/archive/[year]/[month]/[day]/[file-name]``` and can be viewed at
its permaurl ```/archive/[year]/[month]/[day]/[file-name]```

Used for publishing 'Articles' on my website. Articles contain a title, and
marked up html content and are considered a type of 'post'

Note: every 'type' of post will get archived in a similar manner.




