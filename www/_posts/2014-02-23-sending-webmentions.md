---
title: sending webmentions
author: Grant MacKenzie
published: 2014-02-23T10:00:12
id: tag:markup.co.nz,2014-02-23:article:2tE1
summary: Some background notes on sending webmentions.
categories: webmentions
update: no
---

A work in progress

Two parts.

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


My Identifier
-------------

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

Front Matter As A Server Directive.
-----------------------------------

This link relationship is expressed in our markdown front-matter,
```rel-in-reply-to:  URL``
when we create a comment.

This generates a atom entry on the server with contained 'link' markup and the taguri

    xml
    <link rel="in-reply-to" type="text/html" href="http://barryfrost.com/how-to-comment"/>
    <id>tag:markup.co.nz,2014-02-26:comment:2tH1</id>

When we add stuff to the front matter we want the server to do stuff with it.
With his ```rel-in-reply-to``` will we want the link relationship expressed

1. in the head of the document as a **link element**

2. in the **HTTP header field**  when the document in served ref: [rfc5988]( http://tools.ietf.org/html/rfc5988 )

3. in the body of the document as part of the reply context for the entry. Marked up as a h-entry containing an h-cite with an anchor that has an attribute ```class="u-in-reply-to"``` ref: [indiewebcamp](https://indiewebcamp.com/comment)

If we do the above, when we ping the webmention endpoint, then the endpoint should be able to discover who (me) pinged them, and if they have the capability uncover authorship, content, etc. by examining my microformated markup.

Testing 1 2 3
-------------

reference post: <br/>[http://markup.co.nz/archive/2014/02/26/153016](http://markup.co.nz/archive/2014/02/26/153016)

```curl -s -i http://markup.co.nz/archive/2014/02/26/153016 | grep 'in-reply-to'```

    Link: <http://barryfrost.com/how-to-comment>; rel="in-reply-to"
	    <link rel="in-reply-to" href="http://barryfrost.com/how-to-comment" type="text/html" />
		<div class="p-in-reply-to">
     In reply to <a rel="in-reply-to" href="http://barryfrost.com/how-to-comment">http://barryfrost.com/how-to-comment</a>
    grant@grant:~$


Webmention Endpoint
-------------------

We can use the ```rel-in-reply-to:  URL``` to discover the *webmention endpoint* to ping to, so the author of the post I am commenting on will know I am mentioning their post.

When should we ping the endpoint.

1. After my draft goes from yes to no. Draft key value become 'no'  triggers upload from localhost to remote occurs.

2. After an major update ( note: not just typos - this is the meaning of the atom updated element).

What I am thinking of is after the draft stops being a draft the font-matter *draft*  becomes *update* with the default set to no.  Setting to yes, both uploads to remote and pings the webmention endpoint, then the  front-matter *update*  resets back to no. DONE.


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


