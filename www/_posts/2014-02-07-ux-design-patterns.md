---
title: ux design patterns
author: Grant MacKenzie
published: 2014-02-07T10:26:56
id: tag:markup.co.nz,2014-02-07:article:2sy1
summary:
categories:
---

Its time to look at how the site is fitting together.

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
* May have link relationship items. e.g.

So there we have it. This is the data we have to work with to create our UX HTML
views. This data naturally is stored in exist-dbs data archive collection
```/data/archive/``` in a date stamped collection hierachy ```[year]/[month]```


The Home Page
-------------

The home page will be a  *posts feed* consisting of *'post listings'*.

At the moment

1. This *activity stream* of my latest Articles and Notes and other 'post items' are in reverse
chonological order
2. **post listings**:  these will not be seperated out by post-type i.e. articles vs
notes vs images but clumped together in one listing. ( TODO )
3. Article will be shortened




ref:
http://indiewebcamp.com/feeds
http://indiewebcamp.com/syndication_formats#Formatting_Content_for_Syndication
http://indiewebcamp.com/ActivityStreams
http://ui-patterns.com/patterns/activitystream
http://www.slideshare.net/factoryjoe/activity-streams-973210
http://usersarehumans.wordpress.com/2009/04/14/brief-thoughts-activity-stream-scanning-affordances/
http://corvusconsulting.ca/2009/11/activity-streams-ephemeral-data-and-the-short-list-pattern/
http://activitystrea.ms/specs/atom/1.0/
http://www.deaneckles.com/blog/77_activity-streams-personalization-and-beliefs-about-our-social-neighborhood/
https://github.com/snarfed/activitystreams-unofficial
http://microformats.org/wiki/activity-streams#activity_object_brainstorm


Archives
--------



Posts Listing


Yearly/monthly Archives

Categories Highlights


Search




http://www.sitepoint.com/beautiful-web-site-archives/
http://www.mintblogger.com/2009/02/how-to-create-high-performing-blog.html



Notes List
-----------



Articles List
-------------

    Title the article
    Short description
    Publication date
    Call out to action (read more, continue reading, see more, etc.)





http://ui-patterns.com/blog/Design-considerations-for-article-lists
http://www.webdesigndev.com/web-development/layout-examples-of-how-blogs-list-their-posts
http://uxdesign.smashingmagazine.com/2013/05/03/infinite-scrolling-get-bottom/


Archives
--------





 [^note-id] hi
