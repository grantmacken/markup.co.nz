xquery version "3.0"; module namespace auth="http://markup.co.nz/#auth";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://exist-db.org/xquery/apps/config" at "../../modules/config.xqm";
import module namespace sm="http://exist-db.org/xquery/securitymanager";
import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace response="http://exist-db.org/xquery/response";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace httpclient = "http://exist-db.org/xquery/httpclient";

(:~
 : auth
 : @author Grant MacKenzie
 : @version 0.01 :
:)


declare function auth:web-login($node as node(), $model as map(*)){

let $redirect-uri :=  'http://' || $model('site-domain') ||   '/auth'
let $fragment   :=   if($model('session-has-login-attr') ) then (
 <p>TODO: logged in:</p>

)
                     else(
<form action="http://indieauth.com/auth" method="get">
 <label>Web Address:</label>
 <input type="text" name="me" placeholder="my-domain.com" />
 <p><button type="submit">Sign In</button></p>
 <input type="hidden" name="redirect_uri" value="{$redirect-uri}" />
</form>)

return
 $fragment
 };


declare function auth:indie-auth($node as node(),
                                 $model as map(*),
                                 $token as xs:string,
                                 $me as xs:string
                                               ){

let $domain :=  substring-after($me ,'//')
let $URL := "https://indieauth.com/verify?token=" || $token
let $base64:= httpclient:get(xs:anyURI($URL),true(),())/httpclient:body/text()
let $json :=  util:binary-to-string($base64)
let $json-xml :=  xqjson:parse-json($json )
let $isError :=  exists( $json-xml//*[@name="error"])
let $algorithm := 'SHA1'
let $hash :=  util:hash( $domain, 'SHA1' ,true())
let $msg := if( $isError ) then (
                  $json-xml//*[@name="error_description"]/string())
                  else(
                   $json-xml//pair/string()
                  )




let $setCurrentUser := if( $isError ) then ()
                  else(
                   session:set-current-user( $domain , $hash )
                  )

let $currentUser  :=  xmldb:get-current-user()

(:
request:get-remote-addr() as xs:string
response:redirect-to( $msg )
        )
:)
return
<ul>
<li>domain: { $domain }</li>
<li>token: { $token }</li>
<li>base64: { $base64 }</li>
<li>json: { $json }</li>
<li>isError: { $isError }</li>
<li>msg: { $msg }</li>
<li>setCurrentUser: { $setCurrentUser }</li>
<li>currentUser: { $currentUser }</li>
</ul>
 };



(:
https://indieauth.com/#documentation
https://github.com/joewiz/xqjson
There will be a token in a query string parameter, token.

verify the token

 http://indieauth.com/verify?token=gk7n4opsyuUxhvF4

 An example successful json response:

{
  "me": "http://markup.co.nz"
}


At this point you know the domain belonging to the authenticated user. You can
store the domain and/or the token in a secure session and log the user in with
their domain name identity. You don't need to worry about whether they
authenticated with Google, Twitter or Github, their identity is their domain
name! You won't have to worry about merging duplicate accounts or handling error
cases when Twitter is offline.

sm:is-account-enabled($username as xs:string) as xs:boolean
sm:is-account-enabled($username)
:)

declare function auth:token($node as node(), $model as map(*) , $token as
xs:string, $me as
xs:string ) {
let $user-id  :=  string('grant')
let $password  :=  string('ntere37')

let $domain :=  substring-after($me ,'//')

let $name   := 'login'
let $algorithm := 'SHA1'
let $hash :=  util:hash( $domain, 'SHA1' ,true())

let $currentUser  :=  xmldb:get-current-user()
let $sessionExists  :=  session:exists()

let $sessionSetAttribute := session:set-attribute($name , string($domain) )

let $sessionAttributeNames  :=  session:get-attribute-names()
let $sessionMaxInactiveInterval  :=  session:get-max-inactive-interval()
let $sessionGetAttribute  :=  session:get-attribute($name)

(:

session:set-current-user($user-name as xs:string, $password as xs:string)
session:set-max-inactive-interval($interval as xs:int) as item()
let $sessionCreationTime  :=  session:get-creation-time()
let $sessionLastAccessedTime  :=  session:get-last-accessed-time()                                                     session:get-last-accessed-time()
let $sessionID  :=  session:get-id()

:)


let $collection-uri := string('/db/apps/markup.co.nz')
(: let $user-id  :=  string('grant') :)
(: let $password  :=  string('ntere37') :)

let $user-id  :=  $domain
let $password  :=  $hash
let $currentUser  :=  xmldb:get-current-user()
let $canAuthenticate := xmldb:authenticate($collection-uri, $user-id, $password)
let $logon := xmldb:login($collection-uri, $user-id, $password )
let $isAuthenticate := sm:is-authenticated()

let $userExists :=
 if( sm:user-exists( $domain )) then()
 else(
      (:sm:delete-group($domain):)
      sm:create-account( $domain , $hash , 'dba' )
      )


(:
If the account does not exist create
let $createAccount := sm:create-account( $domain , $hash , 'dba' )
let $isAccountEnabled := sm:is-account-enabled( $domain )
let $removeAccount := sm:is-account-enabled( $domain ),
                      sm:delete-group($domain)
sm:passwd($username as xs:string, $password as xs:string) as empty()

:)






(:

let $URL := "https://indieauth.com/verify?token=" || $token
let $base64:= httpclient:get(xs:anyURI($URL),true(),())/httpclient:body/text()
let $json :=  util:binary-to-string($base64)
let $json-xml :=  xqjson:parse-json($json )

let $isError :=  exists( $json-xml//*[@name="error"])
let $message := if( $isError ) then ( $json-xml//*[@name="error_description"]/string()  )
                  else($json-xml//pair/string()  )


<li>isError: { $isError  }</li>
<li>message: { $message  }</li>

:)
(:
  The "eXist-db realm" is the default internal realm.
By default this realm handles the 'SYSTEM', 'admin' and 'guest' users and 'DBA'
and 'guest' groups.
Any additional users or groups created in eXist-db will be
added to this realm.

 Flow
 if someone is not logged in then they are a guest

 check if session exists





 let $isAccountEnabled :=  sm:is-account-enabled($username)
<li>isAccountEnabled { $isAccountEnabled  }</li>
let $username :=  sm:user-exists( $username )
let $isAccountEnabled      :=  sm:is-account-enabled($username)
sm:is-authenticated()

sm:is-dba($username as xs:string)
<li>json { $json  }</li>
<li>base64 { $base64  }</li>
<li>json { $json  }</li>


:)


return
(
<ul>
<li>currentUser { $currentUser }</li>
<li>sessionExists { $sessionExists }</li>
<li>sessionSetAttribute { $sessionSetAttribute }</li>
<li>sessionGetAttribute { $sessionGetAttribute }</li>
<li>sessionMaxInactiveInterval { $sessionMaxInactiveInterval }</li>
<li>domain { $domain }</li>
<li>token { $token }</li>
<li>hash { $hash }</li>
<li>canAuthenticate { $canAuthenticate }</li>
<li>logon { $logon }</li>
<li>isAuthenticated { $isAuthenticate }</li>
<li>userExists { $userExists  }</li>
</ul>
 )
};
