xquery version "3.0";

(:
    getMEI.xql
    $param 'activeStates'
    
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
let $xslPath := '../xslt/' 

let $comparison.id := request:get-parameter('comparisonId','')
let $method := request:get-parameter('method','')
let $mdiv := request:get-parameter('mdiv','')
let $transpose.mode := request:get-parameter('transpose','')

let $comparison := (collection($data.basePath)//mei:meiCorpus[@xml:id = $comparison.id])[1]

let $comparison.path.tokens := tokenize(document-uri($comparison/root()),'/')
let $comparison.path := string-join($comparison.path.tokens[position() lt count($comparison.path.tokens)],'/')

let $doc1.path := ($comparison//mei:source)[1]/data(@target)
let $doc2.path := ($comparison//mei:source)[2]/data(@target)

let $doc1 := doc(concat($comparison.path, '/', $doc1.path))
let $doc2 := doc(concat($comparison.path, '/', $doc2.path))

(: Mode of Analysis:)
let $analysis.mode :=
    if($method = 'plain')
    then('plain')
    else if($method = 'comparison')
    then('comparison')
    else if($method = 'geneticComparison')
    then('comparison')
    else if($method = 'melodicComparison')
    then('melodicComparison')
    else if($method = 'eventDensity')
    then('eventDensity')
    else if($method = 'relativeChroma')
    then('relativeChroma')
    else if($method = 'krumhansl-1')
    then('krumhansl-1')
    else if($method = 'krumhansl-4')
    then('krumhansl-4')
    else('plain')

(: Method for Comparing analyzed files :)
let $comparison.method :=
    if($method = 'plain')
    then('plain')
    else if($method = 'comparison')
    then('comparison')
    else if($method = 'geneticComparison')
    then('comparison')
    else if($method = 'melodicComparison')
    then('melodicComparison')
    else if($method = 'eventDensity')
    then('eventDensity')
    else('plain')

(:let $doc1 := (collection($data.basePath)//mei:mei[@xml:id = $file.id])[1]
let $doc2 := (collection($data.basePath)//mei:mei[@xml:id = $second.file.id])[1]:)

let $doc1.analyzed := transform:transform($doc1,
               doc(concat($xslPath,'analyze.file.xsl')), <parameters>
                   <param name="mode" value="{$analysis.mode}"/>
                   <param name="mdiv" value="{$mdiv}"/>
                   <param name="transpose.mode" value="{$transpose.mode}"/>
               </parameters>)
               
let $doc2.analyzed := transform:transform($doc2,
               doc(concat($xslPath,'analyze.file.xsl')), <parameters>
                   <param name="mode" value="{$analysis.mode}"/>
                   <param name="mdiv" value="{$mdiv}"/>
                   <param name="transpose.mode" value="{$transpose.mode}"/>
               </parameters>)               

let $merged.files := transform:transform(<root>{$doc1.analyzed}{$doc2.analyzed}{$comparison}</root>,
               doc(concat($xslPath,'combine.files.xsl')), <parameters>
                   <param name="method" value="{$comparison.method}"/>
                   <param name="transpose.mode" value="{$transpose.mode}"/>
               </parameters>)

return 
    $merged.files
    (:<root>{$doc1.analyzed}{$doc2.analyzed}{$comparison}</root>:)
    
