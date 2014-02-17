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

OK this seems to work now, but the Komodo interface is greying out.
No we try to figure out whats blocking a quick response..

Try to add

* set timeout to 10
* get connection to close
* get the put to return status only


So I try an  ```util:eval-inline($uri , "$req()")```

Now  try an  ```util:eval-async(("$req($uri)")```

Create gist <https://gist.github.com/grantmacken/8950792>

Later figured out this is not working. Couldn't figure out 'why not'

Try another tack. async with url
```util:eval-async(xs:anyURI('local-to-remote.xq'))```
with  'local-to-remote.xq' in same dir  'archive-trigger.xqm'  add an extra step to
'archive-trigger.xqm' which put link data to the root of the data collection and
'local-to-remote.xq' reads the link data.

    xquery
    let $local := 'http://localhost:8080'
    let $base := substring-before($uri , '/archive/')
    let $rest := '/exist/rest'
    let $urlLocal := $local || $rest || $base || '/uri.xml'
    let $message1 := 'mu:update ' || $urlLocal
    let $reqPut :=
	<http:request href="{ $urlLocal }"
		      method="put"
		      username="{ $username }"
		      password="{ $password }"
		      auth-method="basic"
		      send-authorization="true"
		      status-only="true"
		      timeout="2">
	   <http:header name = "Connection" value = "close"/>
	   <http:body media-type="application/xml"/>
	</http:request>

    let $link := <link href="{$uri}" />
    let $link := <link href="{$uri}" />
    let $put := http:send-request( $reqPut , (), $link)
    let $eval := util:eval-async(xs:anyURI('local-to-remote.xq'))

OK This works. We now have more responsive non-blocking io for the hard work is done by an
[async call](http://en.wikipedia.org/wiki/Asynchronous_I/O)
to 'local-to-remote.xq'.

The only thing I have to do now is remove host related
['hard-coded references'](http://en.wikipedia.org/wiki/Hard_coding)
 Our build proccess reads from a properties file which contain our host IPs

    host.local=127.0.0.1
    host.remote=120.138.18.126

 so when we deploy we will create a  'hosts.xml' resource write this info to the data collection
