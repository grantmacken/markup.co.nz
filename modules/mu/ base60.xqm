xquery version "3.0"; module namespace base60="http://markup.co.nz/#base60";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace httpclient = "http://exist-db.org/xquery/httpclient";

(:~
 : auth
 : @author Grant MacKenzie
 : @version 0.01 :
:)


declare function base60:encode($str){
let $seq1 := (0 to 9)
let $seq2 := map(function($x) { codepoints-to-string($x) }, string-to-codepoints('A') to string-to-codepoints('H'))
let $seq3 := map(function($x) { codepoints-to-string($x) }, string-to-codepoints('J') to string-to-codepoints('N'))
let $seq4 := map(function($x) { codepoints-to-string($x) }, string-to-codepoints('P') to string-to-codepoints('Z'))
let $seq5 := ('_')
let $seq6 := map(function($x) { codepoints-to-string($x) }, string-to-codepoints('a') to string-to-codepoints('k'))
let $seq7 := map(function($x) { codepoints-to-string($x) }, string-to-codepoints('m') to string-to-codepoints('z'))
let $seqChars := ($seq1, $seq2, $seq3, $seq4, $seq5 , $seq6, $seq7)
let $base := count($seqChars)

let $getRemainder := function($n){
if($n gt 59 ) then (($n mod xs:integer($base)) + 1)
else($n + 1)
}

let $getChar := function($n){$seqChars[xs:integer($getRemainder($n))]}

let $nextN := function($n){
($n - xs:integer($getRemainder($n))) div xs:integer($base)}

let $seqNth := ( xs:integer($nextN($nextN($n))), xs:integer($nextN($n)) , xs:integer($n) )

let $encode := string-join(map(function($n){$seqChars[xs:integer($getRemainder($n))]}, $seqNth),'')

return  $encode
}


};
