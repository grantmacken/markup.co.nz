---
title: My Visiting Card
author: Grant MacKenzie
published: 2014-01-18T11:29:45
id: tag:markup.co.nz,2014-01-18:article:my-visiting-card
summary: Adding my  microformated h-card to this site and including h-cards contacts
categories: indieweb microformats contacts
---

My URL therefore I am.
Who's there? Its me at my URL!
If my indieweb home-page provides my identity, I need to
place my [representative h-card]() right there on my homepage.

How I did it.
-------------

Under my templates folder I create a h-card include. The root element will
contains the microformat class-name h-card. Under the root element are flat marked
up data *properties* which provide profile and or contact info for the card.

These properties will be generated maybe from the build.properties file or
alternatively imported from a silo profile like twitter but at
the mo are hard coded in the template.


Test: [Validate-h-card](http://indiewebify.me/validate-h-card/?url=http%3A%2F%2Fmarkup.co.nz)


Authentication and Links to other Profiles.
------------------------------------------

My h-card on my home page has links to other profiles which allow me to
[sign in](https://indieauth.com/)
to other sites with my domain name and also log-on to my own site. The
Authentication process is offloaded to third party authentication providers like
twitter. An [indieauth](https://indieauth.com/) setup is simple to implement.

A collection of h-cards
------------------------

People, organizations, or places orgaised as a collection of h-cards.

A possible Uri template: ```/hcards/{id}```

The  people, organizations, or places who are represented/profiled in a h-card may have some
relationship with me or my site. The relationships can be expressed as link
based relationships and organised into lists.
A list of contacts, friends etc.

References
----------

* [h-card](http://microformats.org/wiki/h-card)
* [representative-hcard](http://microformats.org/wiki/representative-hcard)
* [Why_web_sign-in](http://indiewebcamp.com/Why_web_sign-in)
* [best-practices-for-author-profile-pages](http://www.seoskeptic.com/best-practices-for-author-profile-pages/)
* [structured-data-for-author-pages-and-linked-snippets](http://www.seoskeptic.com/structured-data-for-author-pages-and-linked-snippets/)
* [google+ authorship](https://plus.google.com/authorship)
* [getting-semantic-with-microformats](http://ablognotlimited.com/articles/getting-semantic-with-microformats-part-2-xfn/)
