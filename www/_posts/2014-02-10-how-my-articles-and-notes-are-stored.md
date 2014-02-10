---
title: How my articles and notes are stored
author: Grant MacKenzie
published: 2014-02-10T13:54:52
id: tag:markup.co.nz,2014-02-10:article:2t13
summary: Its time to look at how the site is fitting together
categories: exist-db
---

Notes and Articles are a **type of** Post.
All 'Posts' archived in a date stamped way.
Posts are stored as Atom entries.
A Post note is stored as 'plain text' in an atom *content* container.
A Post article is stored as an xhtml div in an atom *content* container

As Atom **entries** they

* Must have Titles. Athough a notes title may be semanically irrelevant
* Must have Published and Updated date stamps
* Must have an id. Ours is in the form of a [TagURI](http://www.taguri.org/) The
  id  for this entry<br/>
```id: tag:markup.co.nz,2014-02-07:article:2sy1```
the last part of the taguri contains 2 specific identifiers ```:article:2sy1```
where the first identifier represent the kind of post, article or note etc
* May be categorized (tagged)
* May have summaries.
* May have link relationship items. e.g. a twittet-link-id if posted to twitter

So there we have it. This is the data we have to work with to create our UX HTML
views. This data naturally is stored in the exist-db data archive collection
```/data/archive/``` in a date stamped collection hierachy ```[year]/[month]```
