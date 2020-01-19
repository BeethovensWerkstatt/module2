<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei tools temp custom" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 19, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- this contains the rules for verbalizing chordDefs as strings inside harm -->
    
    
    <!--<xsl:for-each select="$identified.intervals">
    <xsl:variable name="current.interpretation" select="." as="node()"/>
    
    
    <!-\-<xsl:variable name="is.mod" select="some $func in $current.interpretation/temp:tone/@func satisfies (.,'[a-z]+')" as="xs:boolean"/>-\->
    <!-\- insert chord symbol with additions of sevenths and/or bass tone after a slash (/) if it is not the root note -\->
    <harm type="mfunc" xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:choose>
            
            <!-\- compare root-note with bass tone, when they dont have the same pname, copy root note and add a / with the bass tone after that-\->
            <xsl:when test="substring($current.interpretation/@root,1,1) ne upper-case($current.interpretation/@bass)">
                <rend type="root">
                    <xsl:value-of select="$current.interpretation/@root"/>
                </rend>
                
                <!-\-hier die Berechnung von Intervallabständen root->7 und root->9 wie unten?-\->
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct7')">
                    <rend rend="sup" type="ct7">7</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct9')">
                    <rend rend="sup" type="ct9">9</rend>
                </xsl:if>
                <rend type="bass">
                    <xsl:value-of select="concat('/', upper-case($current.interpretation/@bass), $current.interpretation/@bass.accid)"/>
                </rend>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '43sus')">
                    <rend type="mod43sus" rend="sup" fontstyle="italic">43sus</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '65sus')">
                    <rend type="mod65sus" rend="sup" fontstyle="italic">65sus</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '98sus')">
                    <rend type="mod98sus" rend="sup" fontstyle="italic">98sus</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '23ret')">
                    <rend type="mod23ret" rend="sup" fontstyle="italic">23ret</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '78ret')">
                    <rend type="mod78ret" rend="sup" fontstyle="italic">78ret</rend>
                </xsl:if>
            </xsl:when>
            
            
            <!-\- when root note and bass note are of the same pname and accid/accid.ges, just copy root note -\->
            <xsl:when test="substring($current.interpretation/@root,1,1) eq upper-case($current.interpretation/@bass)">
                <xsl:variable name="is.mod" select="matches(., '[a-z]+')" as="xs:boolean"/>
                <rend type="root">
                    <xsl:value-of select="$current.interpretation/@root"/>
                </rend>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct7')">
                    <rend rend="sup" type="ct7">7</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct9')">
                    <rend rend="sup" type="ct9">9</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '43sus')">
                    <rend type="mod43sus" rend="sup" fontstyle="italic">43sus</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '65sus')">
                    <rend type="mod65sus" rend="sup" fontstyle="italic">65sus</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '98sus')">
                    <rend type="mod98sus" rend="sup" fontstyle="italic">98sus</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '23ret')">
                    <rend type="mod23ret" rend="sup" fontstyle="italic">23ret</rend>
                </xsl:if>
                <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '78ret')">
                    <rend type="mod78ret" rend="sup" fontstyle="italic">78ret</rend>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
        
        
        <!-\-<xsl:for-each select="$current.interpretation/temp:tone/@func">
    <xsl:variable name="is.bass" select=". = $current.interpretation/@bass.index" as="xs:boolean"/>
    <xsl:variable name="is.mod" select="matches(.,'[a-z]+')" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct7'">
        <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
      </xsl:when>
        <xsl:when test="$is.bass">
            <rend type="bass {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="concat('/', upper-case($current.interpretation/@bass))"/></rend>
        </xsl:when>
      <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct9'">
        <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
      </xsl:when>
      
        <xsl:when test="$is.mod">
            <rend type="mod {tools:resolveMFuncByNumber(.)}" fontsize="70%" fontstyle="italic"><xsl:value-of select="."/></rend>
        </xsl:when>
</xsl:choose>
</xsl:for-each>
</xsl:when>

<!-\\- when root note and bass note are of the same pname and accid/accid.ges, just copy root note -\\->
<xsl:when test="$current.interpretation/@root ne $current.interpretation/@bass">
<rend type="root"><xsl:value-of select="$current.interpretation/@root"/></rend> 
<xsl:for-each select="$current.interpretation/temp:tone/@func">
    <xsl:variable name="is.mod" select="matches(.,'[a-z]+')" as="xs:boolean"/>
    <xsl:choose>
        <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct7'">
            <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
        </xsl:when>
        <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct9'">
            <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
        </xsl:when>
        <xsl:when test="$is.mod">
            <rend type="mod {tools:resolveMFuncByNumber(.)}" fontsize="70%" fontstyle="italic"><xsl:value-of select="."/></rend>
        </xsl:when>
    </xsl:choose>
</xsl:for-each>
</xsl:when>
</xsl:choose>-\->
        
        <!-\-<xsl:for-each select="$current.interpretation/temp:tone/@func">
<!-\\-<xsl:sort select="xs:integer(substring(.,1,1))" data-type="number" order="ascending"/>-\\->
<xsl:variable name="is.bass" select=". = $current.interpretation/@bass.index" as="xs:boolean"/>
<xsl:variable name="is.mod" select="matches(.,'[a-z]+')" as="xs:boolean"/>
<xsl:choose>
<xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct7'">
<rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
</xsl:when>
<xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct9'">
<rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
</xsl:when>
<xsl:when test="$is.bass and $is.mod">
<rend type="bass mod {tools:resolveMFuncByNumber(.)}" fontsize="70%"><xsl:value-of select="."/></rend>
</xsl:when>
<xsl:when test="$is.bass">
<rend type="bass {tools:resolveMFuncByNumber(.)}" fontsize="70%"><xsl:value-of select="."/></rend>
</xsl:when>
<xsl:when test="$is.mod">
<rend type="mod {tools:resolveMFuncByNumber(.)}" fontsize="70%" fontstyle="italic"><xsl:value-of select="."/></rend>
</xsl:when>
<xsl:otherwise>
<rend type="{tools:resolveMFuncByNumber(.)}" fontsize="70%"><xsl:value-of select="."/></rend>
</xsl:otherwise>
</xsl:choose>   
</xsl:for-each>-\->
        <annot type="mfunc.tonelist" cost="{$current.interpretation/@highest.cost}">
            <xsl:for-each select="$current.interpretation/temp:tone">
                <annot type="{tools:resolveMFuncByNumber(@func)}"
                    plist="{string-join(.//mei:note/@xml:id,' ')}"/>
            </xsl:for-each>
        </annot>
    </harm>
</xsl:for-each>-->
    
</xsl:stylesheet>