xquery version "3.0";

(:
    getComparisonListing.xql
    
    This xQuery …
:)

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes indent=yes";

let $config := doc('/db/apps/mod2/config.xml')
let $data.basePath := $config//basePath/@url
let $xslPath := '../xsl/' 

let $comparisons := 
    for $comparison in collection($data.basePath)//mei:meiCorpus
    let $comparison.id := $comparison/@xml:id
    let $comparison.title := $comparison//mei:fileDesc/mei:titleStmt/mei:title/text()
    
    return
        '{' ||
            '"id":"' || $comparison.id || '",' ||
            '"title":"' || $comparison.title || '"' ||
        '}'


return 
    '[' ||
        string-join($comparisons,',') ||
    ']'
