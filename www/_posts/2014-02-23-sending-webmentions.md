---
title: sending webmentions
author: Grant MacKenzie
published: 2014-02-23T10:00:12
id: tag:markup.co.nz,2014-02-23:article:2tE1
summary: Some background notes on sending webmentions.
categories: webmention
---

A work in progress

Two parts


1. This article: a  'publishing client' which can send webmentions
2. Next article: my servers capability of receiving webmentions an doing
something useful with the received mention.

A Webmentions Publishing Client.
-------------------------------

I write markdown in a text editor (Komodo) publishing environment. The markdown
text 'on save' is preprocessed and published to localhost server which in turn
publishes to my remote server. My publishing environment pretty much behaves like a
'static site generator'.  Meta data is provided via markdown front-matter block.

To implement webmentions what a 'Publishing Client' should be able to do is **respond to a 'URL**  by
sending a **Response Post** to the **web mention endpoint**. The web mention endpoint is discovered by looking up the URL to see if the endpoint is referenced in either the URLs header on in the head of the URLs document.


Identifier
----------

A set of 'types of  *Response Posts* '

1. TODO [reply](https://indiewebcamp.com/reply) (comment)  markup as   rel=in-reply-to on post permalink pages
2. TODO [like](https://indiewebcamp.com/like) (favorite)  markup h-entry  with  u-like property
3. TODO [repost](https://indiewebcamp.com/repost) (share) 'This entire post is interesting'
4. TODO [RSVP](https://indiewebcamp.com/rsvp) (invitation)

Each type of 'response post' is marked up differently via micro formats When I
ping the endpoint, the receiver can discover and differentiate the type of
*response post* I have sent ( a comment or a like or a repost or a RSVP) by
looking up my URL and parsing my markup.


From a 'Publishing Client' perspective the 'response types' will occur in as an
identifier in my taguri something like

```id: tag:markup.co.nz,2014-02-23:like:2tE1```

link-relations
-------------

Indieweb conversations are URL to URL. *My URL in reply to  Your URL* or vice-versa, *Your
URL in reply to  My URL*.  *My response note to your note* is shorthand
for saying: '*My response post from my URL*' in reply to  *'your original post at your URL*'.
So what we have is a
[relationship between links]( http://www.iana.org/assignments/link-relations/link-relations.xhtml )
 where the link relationship value is in [in reply to]( http://micro formats.org/wiki/rel-in-reply-to ).

This link relationship will be expressed in our markdown front-matter.

```rel-in-reply-to:  URL```

We can use the url to discover the 'webmention' endpoint to ping to, so the
author of the post I am commenting on will know I am mentioning their post

The reply context
-----------------

A 'comment' is always about another 'post' so to understand what the comment is
in reply to, its helpful to provide some reply context.

This reply context stuff becomes a section in our permalink page marked up as a microformat h-cite container. Its not part of our content, but is there to reader some understanding of the origin of the content. I might 'cite' this page in another post so it might be best to store a collection of Citations with the unique identifier being a
taguri or the URL


Web site: author(s), article and publication title where appropriate, as well as a URL, and a date when the site was accessed.

As a minimum a line  on the webpage  'In reply to  hyperlinked URL'  should do.


What we are looking for in the cited page.

* URL
* Title. The document Title or if document microformated  look for  h-entry then for p-name
* TODO: Author.  If document microformated  look for  h-entry then for p-author and or h-card. If this fails  the page author maybe in the page head as meta element. If this fails then look up homepage we might find a h-card there. If we do find an h-card add to collection of hcards.
* TODO: Published date and or maybe a date when the site was accessed.
* TODO: Summary:  If the Page content is in a short note form like a tweet the whole note otherwise look for summary. If no summary then empty.



TODO


Hack notes:
