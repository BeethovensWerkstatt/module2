xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then (
    
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
