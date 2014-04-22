---
title: from url to unique resource name
author: Grant MacKenzie
published: 2014-03-16T16:04:10
id: tag:markup.co.nz,2014-03-16:article:2ta3
summary: On creating on way hashes of URLS to be used as file names
categories:xquery existdb
draft: no
---
To get a unique file name for my citations collection I needed to create a
oneway hash of URLs. I do so with a base64 flag. To make hashed base64 string
safe to use as a *file name* or a *existdb resource name* I use the xPath
translate function to replace the bad chars with the good.

Posted as a gist on github [9577957](https://gist.github.com/grantmacken/9577957)

    xquery version "3.0";
    import module namespace util="http://exist-db.org/xquery/util";
    let $href  := "${url}"
    let $base64flag := true()
    let $alogo := 'md5'
    let $hash := replace(util:hash($href, $alogo, $base64flag), '(=+$)', '')
    return
    translate( $hash, '+/', '-_')


Modified to remove end ```=``` at end of string ref. line 6
