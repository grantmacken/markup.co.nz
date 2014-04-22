---
title: generating a reply context
author: Grant MacKenzie
published: 2014-03-15T07:58:07
id: tag:markup.co.nz,2014-03-15:article:2t_1
summary: Outlining my system for generating a reply context for replies
categories: indieweb replies komodo xPath comments
update: no
---

The reply context
-----------------

A 'comment' is always about another 'post' so to understand what the comment is
in reply to, its helpful to provide some reply context.

This reply context stuff becomes a section in our permalink page marked up as a microformat h-cite container. Its not part of our content, but is there to give the reader some understanding of the origin of the content. I might 'cite' this page in another post so it might be best to store a collection of citations with the unique resource identifier being a
hash of the URL

Sugggest [Citations](http://en.wikipedia.org/wiki/Citations) items for a website via wikipedia
>Web site: author(s), article and publication title where appropriate, as well as a URL, and a date when the site was accessed.

As a minimum a line  on the webpage  'In reply to  hyperlinked URL'  should do.

What we are looking for in the cited page.

* URL
* Title. The document Title or if document microformated  look for  h-entry then for p-name
* TODO: Author.  If document microformated  look for  h-entry then for p-author and or h-card. If this fails  the page author maybe in the page head as meta element. If this fails then look up homepage we might find a h-card there. If we do find an h-card add to collection of hcards.
* TODO: Published date and or maybe a date when the site was accessed.
* TODO: Summary:  If the Page content is in a short note form like a tweet the whole note otherwise look for summary. If no summary then empty.


Hack notes:

* Reply contexts as a collection of citatations. ```/data/citations```.
These citations stored as  xhtml fragments marked up in [microformats 2](http://tantek.com/presentations/2012/07/html5-microformats2/).

* The unique filename is created by a md5 hash of the URL.
