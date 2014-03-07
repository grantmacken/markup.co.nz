---
title: storing scalable vector graphics
author: Grant MacKenzie
published: 2014-03-06T11:02:49
id: tag:markup.co.nz,2014-03-06:article:2tR1
summary:
categories: svg
draft: yes
---

I have included some svg icons in my pages on this site, however they are loaded  with the page. I want to add them to the images/svg and then dymamically load them and insert into the dom.

First make sure svg 'on save' is uploaded to localhost.

    Check if extension "svg" is one we can handle: true
    Check if dir "www/resources/images/svg" is one we can handle: true

Then add the store-md target to the build file.

    xml
    <target name="store-svg">
	<echo>${relativePath}</echo>
	<echo>${fileName}</echo>
	<loadresource property="path">
	    <propertyresource name="relativePath" />
	    <filterchain>
		<tokenfilter>
		    <filetokenizer />
		    <replacestring from="www/" to="" />
		</tokenfilter>
	    </filterchain>
	</loadresource>
	<echo>${path}</echo>
	<property name="exist.domain">xmldb:exist://${host.local}:8080/exist/xmlrpc/db/apps/${project.domain}</property>
	<echo>${exist.uri}</echo>
	<xdb:create uri="${exist.domain}" collection="${path}" user="${exist.username}" password="${exist.password}" />
	<echo>${svg-collection-exists}</echo>
	<property name="exist.uri">${exist.domain}/${path}</property>
	<property name="srcfile">${relativePath}/${fileName}.svg</property>
	<echo>${exist.uri}</echo>
	<xdb:store uri="${exist.uri}" createcollection="false" srcfile="${srcfile}" user="${exist.username}" password="${exist.password}" />
    </target>

Note we remove ```www``` from the path with a filterchain.
We add the collection path
Then store the file. 	curl to check if we can fetch it and its returning the right content type

    curl -v http://markup.co.nz/resources/images/svg/icons.svg

Ok. lets go to our templates/includes  folder open up head.html and add

    html
    <script type="text/javascript" src="/resources/scripts/lib/sarissa.js"> </script>
    <script type="text/javascript" src="/resources/scripts/main.js"> </script>

sarissa.js is a cross browser httprequest library I like to use...

main.js loads the icons svg file

    document.addEventListener('DOMContentLoaded', function() {
	var xmlhttp = new XMLHttpRequest();
	var url = '/resources/images/svg/icons.svg'
	xmlhttp.open('GET', url, false);
	xmlhttp.send();
	document.body.insertBefore(xmlhttp.responseXML.firstChild, document.body.firstChild)
    });

RightO,so there we have it, my html looks much cleaner.
