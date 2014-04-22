---
title: establishing authorship
author: Grant MacKenzie
published: 2014-03-22T09:54:34
id: tag:markup.co.nz,2014-03-22:article:2tg1
summary: On creating a Komodo macro for establishing authorship of a indieweb post.
categories: komodo
update: no
---

Usecase:
 As part of displaying comments on my post pages, I need to be able to convey/display the author of a the comment.

I am looking at the  indiewebcamp [Authorship Algorithm]( https://indiewebcamp.com/authorship )


The aim of komodo macro is to for authorship of post and if authorship established then the macro creates and stores a mini h-card by using the existing authors h-card credentials

* the stored mini h-card can  be pulled from the store whenever we need to display authorship in our [post comments section](https://indiewebcamp.com/comments-presentation#How_to_display) or in the posts e-content section.

* The mini h-card is built for visual hyperlinked 'inline display' in our html posts page. It
 displays the persons name, their avator, and online hyperlinked identity.

* The mini [h-card](http://microformats.org/wiki/h-card) is a h-card with base subset of h-card properties
    1. logo/photo/avator  as either u-logo or u-photo
    2. name as p-name and or p-nickname
    3. url (of author which will be thier profile/homepage)

*  Establishing a p-nickname (nickname/alias/handle) might be useful so we can go ```@handle``` in our markdown text and the handle will get auto replaced with hyperlinked mini h-card version.


* The h-card URL establishes uniqueness so the filename could be be a hash of the URL because the authors representative h-card should be at this URL. However with the basis of the indieweb is owning your own personal-domain to create online identity, then we just need to store a hash of the domain name.

Tests
-----

[Sandeep Shetty](http://sandeep.shetty.in/p/about.html) has provided some [testcases](https://github.com/sandeepshetty/authorship-test-cases)
which I will use to test the macro

 I had trouble accessing rawgithub.com so I decided to copy and pasts the test-cases into my site, under a ```_tests```
 collection

[Test Cases index](http://markup.co.nz/_tests/index)


Some real world tests

[http://barryfrost.com/posts/89](http://barryfrost.com/posts/89)

* [seeking-an-indieweb-alternative-to-google-voice](http://werd.io/2014/seeking-an-indieweb-alternative-to-google-voice)

* [there-was-a-dude-at-the-uk-indieweb-camp-last](https://mapkyca.com/2014/there-was-a-dude-at-the-uk-indieweb-camp-last)

* [aaronparecki geoloqi](http://aaronparecki.com/notes/2014/03/21/1/geoloqi)
