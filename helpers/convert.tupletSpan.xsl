<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs math xd mei"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 4, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>Where possible, this XSLT translates tupletSpans into tuplet elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <xd:doc>
        <xd:desc>This starts the process</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="identified.potential.tuplets" as="node()*">
            <xsl:apply-templates select="node()" mode="prep"/>    
        </xsl:variable>
        <xsl:variable name="fixed.nesting" as="node()*">
            <xsl:apply-templates select="$identified.potential.tuplets" mode="fix.nesting"/>
        </xsl:variable>
        <xsl:variable name="created.tuplets" as="node()*">
            <xsl:apply-templates select="$fixed.nesting" mode="create.tuplets"/>
        </xsl:variable>
        <xsl:variable name="cleaned.up" as="node()*">
            <xsl:apply-templates select="$created.tuplets" mode="cleanup"/>            
        </xsl:variable>
        
        <xsl:copy-of select="$cleaned.up"/>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            For each measure, we decide which tupletSpans can be resolved into tuplets, and which need to stay tupletSpans.
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:measure" mode="prep">
        <xsl:variable name="this.measure" select="." as="node()"/>
        
        <xsl:variable name="potential.tuplets" as="node()*">
            <xsl:for-each select=".//mei:tupletSpan">
                <xsl:variable name="this.tupletSpan" select="." as="node()"/>
                <xsl:variable name="start" select="$this.measure//mei:layer//mei:*[@xml:id = replace($this.tupletSpan/@startid,'#','')]" as="node()?"/>
                <xsl:variable name="end" select="$this.measure//mei:layer//mei:*[@xml:id = replace($this.tupletSpan/@endid,'#','')]" as="node()?"/>
                <xsl:if test="exists($start) and exists($end) 
                    and $start/ancestor::mei:staff/@n = $end/ancestor::mei:staff/@n  
                    and $start/ancestor::mei:layer/@n = $end/ancestor::mei:layer/@n">
                    <xsl:sequence select="$this.tupletSpan"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="required.tupletSpans" as="node()*">
            <xsl:for-each select=".//mei:tupletSpan">
                <xsl:variable name="this.tupletSpan" select="." as="node()"/>
                <xsl:if test="not($this.tupletSpan/@xml:id = $potential.tuplets/@xml:id)">
                    <xsl:sequence select="$this.tupletSpan"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- DEBUG INFO: How many tupletSpans can be resolved? -->
        <!--<xsl:if test="count(.//mei:tupletSpan) gt 0">
            <xsl:message select="'[INFO] In measure ' || @n || ' (' || @xml:id || ') we may resolve ' || count($potential.tuplets) || ' tupletSpans to tuplets, while ' || count($required.tupletSpans) || ' will stay as tupletSpan.'"/>    
        </xsl:if>-->
        
        <xsl:next-match>
            <xsl:with-param name="potential.tuplets" select="$potential.tuplets" tunnel="yes" as="node()*"/>
            <xsl:with-param name="required.tupletSpans" select="$required.tupletSpans" tunnel="yes" as="node()*"/>
        </xsl:next-match>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            TupletSpan elements will get a @type that indicates whether they will be resolved to tuplets or not later on.
        </xd:desc>
        <xd:param name="potential.tuplets"/>
        <xd:param name="required.tupletSpans"/>
    </xd:doc>
    <xsl:template match="mei:tupletSpan/@xml:id" mode="prep">
        <xsl:param name="potential.tuplets" as="node()*" tunnel="yes"/>
        <xsl:param name="required.tupletSpans" as="node()*" tunnel="yes"/>
        
        <!-- preserve @xml:id -->
        <xsl:next-match/>
        
        <!-- add @type attribute for later use -->
        <xsl:choose>
            <xsl:when test=". = $potential.tuplets/@xml:id">
                <xsl:attribute name="type" select="'tuplet'"/>
            </xsl:when>
            <xsl:when test=". = $required.tupletSpans/@xml:id">
                <xsl:attribute name="type" select="'tupletSpan'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[ERROR] tupletSpan ' || . || ' can neither be resolved to tuplet nor stay?!'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            Everything inside a layer will be checked for potential tuplet starts and ends, 
            and a @tupletStart / @tupletEnd attribute will be added when necessary 
        </xd:desc>
        <xd:param name="potential.tuplets"/>
        <xd:param name="required.tupletSpans"/>
    </xd:doc>
    <xsl:template match="mei:layer//@xml:id" mode="prep">
        <xsl:param name="potential.tuplets" as="node()*" tunnel="yes"/>
        <xsl:param name="required.tupletSpans" as="node()*" tunnel="yes"/>
        
        <!-- preserve xml:id -->
        <xsl:next-match/>
        
        <!-- add hash to @xml:id to match values in @startid and @endid -->
        <xsl:variable name="this.ref" select="'#' || ." as="xs:string"/>
        
        <xsl:if test="$this.ref = $potential.tuplets/@startid">
            <xsl:attribute name="tupletStart" select="$potential.tuplets[$this.ref = @startid]/@xml:id"/>
        </xsl:if>
        <xsl:if test="$this.ref = $potential.tuplets/@endid">
            <xsl:attribute name="tupletEnd" select="$potential.tuplets[$this.ref = @endid]/@xml:id"/>
        </xsl:if>
        
        <xsl:if test="$this.ref = $potential.tuplets/@startid and $this.ref = $potential.tuplets/@endid">
            <xsl:message select="'[ERROR] A single event should not end one tuplet and start another one at the same time (' 
                || local-name(parent::mei:*) || ' ' || . || ')'"/>
        </xsl:if>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            Move tuplet indications to the chord level when necessary
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:chord[.//@tupletStart or .//@tupletEnd]/@xml:id" mode="fix.nesting">
        <xsl:next-match/>
        <xsl:apply-templates select="parent::mei:chord//@tupletStart | parent::mei:chord//@tupletEnd" mode="#default"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Remove @tupletStart on notes inside chords</xd:desc>
    </xd:doc>
    <xsl:template match="mei:chord//@tupletStart" mode="fix.nesting"/>
    <xd:doc>
        <xd:desc>Remove @tupletEnd on notes inside chords</xd:desc>
    </xd:doc>
    <xsl:template match="mei:chord//@tupletEnd" mode="fix.nesting"/>
    
    
    <xd:doc>
        <xd:desc>
            This template seeks to create tuplet elements
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:*[@tupletStart]" priority="1" mode="create.tuplets">
        <xsl:variable name="measure" select="ancestor::mei:measure" as="node()"/>
        <xsl:variable name="start" select="." as="node()"/>
        <xsl:variable name="tupletSpan" select="$measure//mei:tupletSpan[@xml:id = $start/@tupletStart]" as="node()"/>
        
        <xsl:variable name="nicely.nested.end" select="$start/following-sibling::mei:*[@tupletEnd = $tupletSpan/@xml:id]" as="node()?"/>
        
        <xsl:choose>
            <xsl:when test="exists($nicely.nested.end)">
                <!--<xsl:message select="'[INFO] ' || $tupletSpan/@xml:id || ' works nicely'"/>-->
                <tuplet xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:apply-templates select="$tupletSpan/@xml:id | $tupletSpan/@num | $tupletSpan/@numbase | $tupletSpan/@num.visible | $tupletSpan/@num.format" mode="#current"/>
                    <xsl:next-match/>
                    <xsl:apply-templates select="following-sibling::mei:*[following-sibling::mei:*[@xml:id = $nicely.nested.end/@xml:id]]" mode="get.tuplet.content"/>
                    <xsl:apply-templates select="$nicely.nested.end" mode="get.tuplet.content"/>
                </tuplet>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes" select="'[NIGHTMARE] ' || $tupletSpan/@xml:id || ' will be horrible'"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            Determines whether this is handled already or not
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:*[preceding-sibling::mei:*[@tupletStart]]" mode="create.tuplets">
        <xsl:variable name="tupletStart" select="preceding-sibling::mei:*[@tupletStart]/@tupletStart" as="xs:string"/>
        <xsl:variable name="tuplet.ended.already" select="exists(preceding-sibling::mei:*[.//@tupletEnd = $tupletStart])"/>
        <xsl:choose>
            <xsl:when test="$tuplet.ended.already">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <!-- this has been encoded when the tuplet was opened already -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            These tupletSpans have been resolved to tuplets
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:tupletSpan[@type = 'tuplet']" mode="cleanup"/>
    
    <xd:doc>
        <xd:desc>
            Removing conversion artifacts
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:tupletSpan/@type | @tupletStart | @tupletEnd" mode="cleanup"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This is a generic copy template which will copy all content in all modes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>