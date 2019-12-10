xquery version "3.0";

(:
    get_introduction_as_HTML.xql
    
    This xQuery is based on the xql 'get_introduction_as_HTML.xql' from module1. It has as few modifications as possible.
:)

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace response="http://exist-db.org/xquery/response"; 

declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes indent=yes";

let $header-addition := response:set-header("Access-Control-Allow-Origin","*")

let $data.basePath := '/db/apps/bw-module2/'
let $xslPath := '../xslt/' 

let $comparison.id := request:get-parameter('comparisonId','')

let $comparison := (collection($data.basePath)//mei:meiCorpus[@xml:id = $comparison.id])[1]
let $notes := $comparison//mei:meiHead/mei:workList/mei:work/mei:context

let $text := transform:transform($notes,
               doc(concat($xslPath,'tools/mei2html.xsl')), <parameters/>)


return 
    <div class="meiTextView">
        {$text}
    </div>