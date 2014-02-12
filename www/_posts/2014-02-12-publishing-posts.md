---
title: publishing posts
author: Grant MacKenzie
published: 2014-02-12T10:53:32
id: tag:markup.co.nz,2014-02-12:article:2t31
summary:
categories:
---

From localhost to remote
------------------------

When I save a Markdown file from komodo this get stored as an atom entry
in the existdb. This event triggers a call to ```archive-trigger.xqm```.


What I want to do is from our localhost server, call a function to upload the created or updated document  to the remote server.

First I get the ```archive-trigger.xqm``` function to log

    xquery
    declare function trigger:update-remote( $uri as xs:anyURI ) {
     let  $priority := 'info'
     let  $message := 'mu:update ' || $uri
     return util:log($priority,$message)
    };

I open the terminal and use tail to track the existdb log

    bash
    tail -f -n 1 /usr/local/eXist/webapp/WEB-INF/logs/exist.log | awk \
    '/LogFunction/{ print $11 " "  $12 }'```

Now I can watch what is going on in the terminal as I update Markdown docs

    mu:update /db/apps/markup.co.nz/data/archive/2014/02/12/publishing-posts.xml

Existdb has a 'Rest Interface' and a 'http-client module' so we will try to use these


    let $reqGet :=   <http:request href="{ $urlLocal }"
				method="get"
				username="{ $username }"
				password="{ $password }"
				auth-method="basic"
				send-authorization="true"
				timeout="2"
				/>

    let $inDoc :=   http:send-request($reqGet)[2]
    let $reqPut :=   <http:request href="{ $urlRemote }"
				method="put"
				username="{ $username }"
				password="{ $password }"
				auth-method="basic"
				send-authorization="true">
				<http:body media-type="application/xml"/>
		    </http:request>

    let $outResult :=  http:send-request($reqPut, (), $inDoc

OK this seems to work now, but the Komodo interface is greying out blocking.

So I try an  ```util:eval-inline($uri , "$req()")```

Try to add timeout and connection close.

Now  try an  ```util:eval-async(("$req($uri)")```

OK Create gist <https://gist.github.com/grantmacken/8950792>



