---
title: publishing drafts
author: Grant MacKenzie
published: 2014-02-28T08:20:06
id: tag:markup.co.nz,2014-02-28:article:2tK1
summary:
categories: atom
draft: no
---

Now I have a local to remote trigger, I don't want every save to appear live on
the remote production server. So I have included a
[draft publishing control](https://tools.ietf.org/html/rfc5023#section-13.1.1)
to be included in the front matter.

    ---
    title: publishing drafts
    author: Grant MacKenzie
    published: 2014-02-28T08:20:06
    id: tag:markup.co.nz,2014-02-28:article:2tK1
    summary:
    categories:
    draft: yes
    ---

The draft value, either 'yes' or 'no' TODO: maybe add true false
If there is no `draft key` in the front matter then the default is to publish to
remote.

This value md front matter value is converted to a atomPub control when saved to our data store. The control element is in its own namespace. ```http://www.w3.org/2007/app```

I don't know why it has its own namespace but it does so I'll add it

    python
    APP_NAMESPACE = "http://www.w3.org/2007/app"
    #.... etc
    elif new_element == 'draft':
	elControl = ET.SubElement(eEntry, '{%s}control' % (APP_NAMESPACE))
	elDraft = ET.SubElement(elControl, "{%s}draft" % (APP_NAMESPACE))
	elDraft.text = metadata[item]

In our stored atom entry

    xml
    <app:control>
	    <app:draft>yes</app:draft>
    </app:control>

Since the upload to the remote server occurs as a trigger we can alter
'local-to-remote.xq' so it does not send only if a draft.

    xquery
    let $isDraft :=
	if($inDoc//app:control/app:draft/string() eq 'yes') then ( true() )
	else ( false() )
    (: ... etc :)
    return
    if($isDraft ) then ()
    else ( http:send-request( $reqPut , (), $inDoc))

The last thing we need to do is add the ```draft: yes``` when we create a new post.


OK, that should do it.
