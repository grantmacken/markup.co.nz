xquery version "3.0";
module namespace utility="http://markup.co.nz/#utility";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";


declare namespace  xhtml =  "http://www.w3.org/1999/xhtml";
declare namespace  atom =  "http://www.w3.org/2005/Atom";

(:~   Utility
: a grab bag of stand alone useful stuff
: that can be pulled in from elsewhere.
:
: @author Grant MacKenzie
: @version 0.01
: import module namespace utility="http://markup.co.nz/#utility" at "utility.xqm";
:)


declare
function utility:urlHash( $url ) {
let $base64flag := true()
let $alogo := 'md5'
let $hash := replace(util:hash($url, $alogo, $base64flag), '(=+$)', '')
return
translate( $hash, '+/', '-_')
};


declare
function utility:urlResolve( $base ,  $url  ) {
if ( starts-with( $url, '/' ) and  matches($base,'^[a-z]+://') ) then resolve-uri( substring-after($url, '/') ,  substring-before($base, substring-after(substring-after($base, '://' ), '/') ))
else()
};
