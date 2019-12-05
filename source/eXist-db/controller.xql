xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(: returns all comparisons available in the DB :)    
if(ends-with($exist:path,'/comparisons.json')) then (
    response:set-header("Access-Control-Allow-Origin", "*"),
    
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/xql/getComparisonListing.xql"/>
    </dispatch>
    
(: retrieves the MEI for a basic comparion (used for plain, single-note and genetic comparison) :)    
) else if(matches($exist:path,'/data/[\da-zA-Z-_\.]+/mdiv/[\d]+/transpose/[\da-zA-Z-_\.]+/basic.xml')) then (
    
    response:set-header("Access-Control-Allow-Origin", "*"),
    
    let $hiddenStaves := request:get-parameter('hideStaves', '')
    return
    
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/xql/getAnalysis.xql">
            <add-parameter name="comparisonId" value="{tokenize($exist:path,'/')[last() - 5]}"/>
            <add-parameter name="method" value="comparison"/>
            <add-parameter name="mdiv" value="{tokenize($exist:path,'/')[last() - 3]}"/>
            <add-parameter name="transpose" value="{tokenize($exist:path,'/')[last() - 1]}"/>
            <add-parameter name="hiddenStaves" value="{$hiddenStaves}"/>
        </forward>
    </dispatch>

(: retrieves the MEI for an event density comparison :)
) else if(matches($exist:path,'/data/[\da-zA-Z-_\.]+/mdiv/[\d]+/transpose/[\da-zA-Z-_\.]+/eventDensity.xml$')) then (
    
    response:set-header("Access-Control-Allow-Origin", "*"),
    
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/xql/getAnalysis.xql">
            <add-parameter name="comparisonId" value="{tokenize($exist:path,'/')[last() - 5]}"/>
            <add-parameter name="method" value="eventDensity"/>
            <add-parameter name="mdiv" value="{tokenize($exist:path,'/')[last() - 3]}"/>
            <add-parameter name="transpose" value="{tokenize($exist:path,'/')[last() - 1]}"/>
        </forward>
    </dispatch>

(: retrieves the MEI for a melodic contour comparison :)
) else if(matches($exist:path,'/data/[\da-zA-Z-_\.]+/mdiv/[\d]+/transpose/[\da-zA-Z-_\.]+/melodicComparison.xml$')) then (
    
    response:set-header("Access-Control-Allow-Origin", "*"),
    
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/xql/getAnalysis.xql">
            <add-parameter name="comparisonId" value="{tokenize($exist:path,'/')[last() - 5]}"/>
            <add-parameter name="method" value="melodicComparison"/>
            <add-parameter name="mdiv" value="{tokenize($exist:path,'/')[last() - 3]}"/>
            <add-parameter name="transpose" value="{tokenize($exist:path,'/')[last() - 1]}"/>
        </forward>
    </dispatch>

(: retrieves the MEI for a harmonic comparison :)
) else if(matches($exist:path,'/data/[\da-zA-Z-_\.]+/mdiv/[\d]+/transpose/[\da-zA-Z-_\.]+/harmonicComparison.xml$')) then (
    
    response:set-header("Access-Control-Allow-Origin", "*"),
    
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/xql/getAnalysis.xql">
            <add-parameter name="comparisonId" value="{tokenize($exist:path,'/')[last() - 5]}"/>
            <add-parameter name="method" value="harmonicComparison"/>
            <add-parameter name="mdiv" value="{tokenize($exist:path,'/')[last() - 3]}"/>
            <add-parameter name="transpose" value="{tokenize($exist:path,'/')[last() - 1]}"/>
        </forward>
    </dispatch>

) else if ($exist:path eq '') then (
    
    response:set-header("Access-Control-Allow-Origin", "*"),
    
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
)    
else if ($exist:path eq "/") then (
    (: forward root path to index.xql :)
    response:set-header("Access-Control-Allow-Origin", "*"),
    
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
)
else (
    (: everything else is passed through :)
    
    response:set-header("Access-Control-Allow-Origin", "*"),
    
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
)