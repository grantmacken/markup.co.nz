---
title: receiving webmentions
author: Grant MacKenzie
published: 2014-04-24T07:49:56
id: tag:markup.co.nz,2014-04-24:article:2uE1
summary:
categories:
draft: yes
---

My Webmention Endpoint
----------------------

If you mention something I have said in your site you can notify me at my
webmention endpoint. I can receive webmention for any any archive post

```http:markup.co.nz/webmention.xq```

The webmention will be conditionally accepted with a 202 response. If the
conditions are not met you should get a [indication of the
problem](http://www.mnot.net/blog/2013/05/15/http_problem) in the response body.

Conditions For Acceptance.
-------------------------

The request must met certain conditions for acceptance.

For example this request should fail

    bash
    curl "http://markup.co.nz/webmention.xq"

When there is a problem then the response will include the reason for failure

    xml
    <problem xmlns="urn:ietf:rfc:XXXX">
      <title>Missing Required Query Parameter</title>
      <detail>Query parameters must be target and source</detail>
    </problem>

Reasons For Failure.
------------------

1. Missing a required query parameter
2. Target URL does not have HTTP Protocol part
3. Target URL not pointing to my domain
4. Target URL not pointing to an archived post
5. A GET on target URL did not respond with status ```200 OK```
6. A GET on target URL found the target URL does not have a 'webmention' endpoint after looking at both the response 'headers' and the response body document.
7. A GET on source URL did not respond with status ```200 OK```
8. A GET on source URL did not respond with a text Content-Type
8. A GET on source URL found the source does not link to the target after looking at the response body document.


After these conditions are met we make a hash of the target and resource names and store the raw request response data to our ```data/jobs/mentions``` collection, with the hash as the resource name. ```data/jobs/mentions```. The collection has guest write permissions but no guest read permissions.
A public resource may be created in the future so so give the user a
```202 continue``` status response with with a location URL
as a response header and in the response body.

The location URL will actualy be at the target URL appended with a [fragment
identifier](http://en.wikipedia.org/wiki/Fragment_identifier). Someone has
commented on something I wrote in a post to my blog. They sent a webmention. I
receive the webmention. After I verfify that is valid, I add some sort of
acknowlegement on the page they mentioned.

The creation of a new resource in the ```data/jobs/mentions``` collection
[triggers](http://exist-db.org/exist/apps/doc/triggers.xml') a call to an xQuery
script on eXist which will try to do something usefull with the source data.

It will be matter of playing with the script to see what it can generate. If the
source document has microformated content we will end up with a richer mentions
section. If the source document does not have microformated the there will be a
fallback position.

The trick is figuring out the [type of reponse](http://indiewebcamp.com/responses) the webmention source contains so we can display received mentions as ....

1. A Reply ( Comment ). ref  <http://indiewebcamp.com/comments-presentation>
2. A like ( Favourite )
3. A repost ( reshare )
4. A RSVP  invitation

References.
----------

<http://indiewebcamp.com/webmention>

<https://github.com/converspace/webmention>

<http://indiewebcamp.com/comment>

<http://indiewebcamp.com/responses>

<http://indiewebcamp.com/comment-policies>
