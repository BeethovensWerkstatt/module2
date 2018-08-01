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

let $data.basePath := '/db/apps/bw-module2/'
let $xslPath := '../xsl/' 

let $comparisons := 
    for $comparison in collection($data.basePath)//mei:meiCorpus
    let $comparison.id := $comparison/@xml:id
    let $comparison.title := $comparison//mei:fileDesc/mei:titleStmt/mei:title[@type='main']/text()
    let $source1 := doc(document-uri($comparison/root()) || '/../' || $comparison//mei:source[1]/@target)
    let $source2 := doc(document-uri($comparison/root()) || '/../' || $comparison//mei:source[2]/@target)
    
    
    let $movements := 
        for $mdiv at $pos in $source1//mei:mdiv
        let $n := if($mdiv/@n) then($mdiv/@n) else($pos)
        let $label := $mdiv/@label
        let $new.label := $source2//mei:mdiv[@n = $n]/@label
        return
            '{' ||
                '"n":"' || $n || '",' ||
                '"label":"' || $label || '",' ||
                '"newLabel":"' || $new.label || '"' ||
            '}'
    
    return
        '{' ||
            '"id":"' || $comparison.id || '",' ||
            '"title":"' || $comparison.title || '",' ||
            '"movements":[' || 
                string-join($movements,',') ||
            ']' ||
        '}'


return 
    '[' ||
        string-join($comparisons,',') ||
    ']'
