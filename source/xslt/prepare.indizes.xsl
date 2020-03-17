<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:tools="no:link"
    xmlns:json="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs math xd mei xlink tools json"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 4, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="indizes/parsons.xsl"/>
    <xsl:include href="indizes/rhythmic.xsl"/>
    <xsl:include href="indizes/pitch.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="input.file" select="//mei:music" as="node()"/>
        
        <xsl:variable name="parts" as="node()*">
            <xsl:for-each select="distinct-values($input.file//mei:staffDef/@n)">
                <xsl:variable name="current.staff.n" select="." as="xs:string"/>
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:variable name="events" select="$input.file//mei:staff[@n = $current.staff.n]//(mei:chord,mei:note[not(ancestor::mei:chord) and not(@grace) and not(@cue)],mei:rest,mei:mRest,mei:space,mei:mSpace)" as="node()*"/>
                    <xsl:variable name="control.events" select="$input.file//mei:measure/mei:*[@staff = $current.staff.n or substring(@startid,2) = $events//@xml:id]" as="node()*"/>
                    
                    <!-- all events -->
                    <xsl:variable name="full" select="tools:prepareIndex($events,$control.events,$input.file)" as="node()*"/>
                    <!-- only rhythmically dominant events, i.e. with integer tstamps -->
                    <xsl:variable name="rdom" select="$full[@dom.r = '0']" as="node()*"/>
                    <!-- all events except rests -->
                    <xsl:variable name="norest" select="$full[@type ne 'rest']" as="node()*"/>
                    <!-- rhytmically dominant events except rests -->
                    <xsl:variable name="rdomNoRest" select="$norest[@dom.r = '0']" as="node()*"/>
                    <!-- all events, tied notes are merged -->
                    <xsl:variable name="tiesMerged" select="tools:mergeTies($full)" as="node()*"/>
                    <!-- tied notes merged, no rests -->
                    <xsl:variable name="tiesMergedNoRest" select="$tiesMerged[@type ne 'rest']" as="node()*"/>
                    
                    <xsl:sequence select="tools:generateIndizes($full,'full')"/>
                    <xsl:sequence select="tools:generateIndizes($rdom,'rdom')"/>
                    <xsl:sequence select="tools:generateIndizes($norest,'norest')"/>
                    <xsl:sequence select="tools:generateIndizes($rdomNoRest,'rdomNoRest')"/>
                    <xsl:sequence select="tools:generateIndizes($tiesMerged,'tiesMerged')"/>
                    <xsl:sequence select="tools:generateIndizes($tiesMergedNoRest,'tiesMergedNoRest')"/>
                    
                </map>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="parts" as="node()">
            <array xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:sequence select="$parts"/>
            </array>
        </xsl:variable>
        
        <xsl:sequence select="json:xml-to-json($parts)"/>
        
        
    </xsl:template>
    
    <xsl:function name="tools:prepareIndex" as="node()*">
        <xsl:param name="events" as="node()*"/>
        <xsl:param name="control.events" as="node()*"/>
        <xsl:param name="file" as="node()"/>
        <xsl:variable name="empty.start" as="node()?"/>
        
        <xsl:sequence select="reverse(fold-right($events,$empty.start,function($current,$sequence) {tools:parseItemForIndex($current,$sequence,$control.events,$file)}))"/>
        
    </xsl:function>
    
    <xsl:function name="tools:parseItemForIndex" as="node()*">
        <xsl:param name="current.item" as="node()"/>
        <xsl:param name="preceding.items" as="node()*"/>
        <xsl:param name="control.events" as="node()*"/>
        <xsl:param name="file" as="node()"/>
        
        <xsl:variable name="type" select="if(local-name($current.item) = ('note')) then('note') else if(local-name($current.item) = 'chord') then('chord') else('rest')" as="xs:string"/>
        <xsl:variable name="pnum" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$type = 'note'"><xsl:value-of select="$current.item/@pnum"/></xsl:when>
                <xsl:when test="$type = 'chord'"><xsl:value-of select="'[' || string-join($current.item//@pnum,',') || ']'"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="'.'"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="intm" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$type = 'note'"><xsl:value-of select="$current.item/@intm"/></xsl:when>
                <xsl:when test="$type = 'chord'"><xsl:value-of select="'[' || string-join($current.item//@intm,',') || ']'"/></xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="dur" as="xs:string">
            <xsl:choose>
                <xsl:when test="not($current.item/@tstamp2)">
                    <xsl:value-of select="$file//mei:measure[.//@xml:id = $current.item/@xml:id]/@meter.count"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="xs:string(round(xs:double($current.item/@tstamp2) - xs:double($current.item/@tstamp),4))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="rhythmic.dominance" as="xs:string">
            <xsl:variable name="tstamp" select="xs:double($current.item/@tstamp)" as="xs:double?"/>
            <xsl:if test="not($tstamp)">
                <xsl:message select="$current.item" terminate="yes"></xsl:message>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="round($tstamp) = $tstamp"><xsl:value-of select="'0'"/></xsl:when>
                <xsl:when test="ends-with($current.item/@tstamp,'.5')"><xsl:value-of select="'1'"/></xsl:when>
                <xsl:when test="ends-with($current.item/@tstamp,'.25')"><xsl:value-of select="'2'"/></xsl:when>
                <xsl:when test="ends-with($current.item/@tstamp,'.75')"><xsl:value-of select="'2'"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="'3'"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="tie.start" as="xs:string?">
            <xsl:variable name="starting.tie" select="$control.events/descendant-or-self::mei:tie[substring(@startid,2) = $current.item//@xml:id]" as="node()?"/>
            <xsl:if test="$starting.tie">
                <xsl:value-of select="substring($starting.tie/@endid,2)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="tie.end" as="xs:string?">
            <xsl:variable name="ending.tie" select="$control.events/descendant-or-self::mei:tie[substring(@endid,2) = $current.item//@xml:id]" as="node()?"/>
            <xsl:if test="$ending.tie">
                <xsl:value-of select="'end'"/>
            </xsl:if>
        </xsl:variable>
        
        
        <xsl:sequence select="$preceding.items"/>
        <item ref="{$current.item/@xml:id}" type="{$type}" dur="{$dur}" dom.r="{$rhythmic.dominance}">
            <xsl:if test="$pnum">
                <xsl:attribute name="pnum" select="$pnum"/>
            </xsl:if>
            <xsl:if test="$intm">
                <xsl:attribute name="intm" select="$intm"/>
            </xsl:if>
            <xsl:if test="$tie.start">
                <xsl:attribute name="tie.start" select="$tie.start"/>
            </xsl:if>
            <xsl:if test="$tie.end">
                <xsl:attribute name="tie.end"/>
            </xsl:if>
        </item>
        <!--
        <map xmlns="http://www.w3.org/2005/xpath-functions">
            <string key="type"><xsl:value-of select="$type"/></string>
            <number key="dur"><xsl:value-of select="$dur"/></number>
            <number key="rdom"><xsl:value-of select="xs:double($rhythmic.dominance)"/></number>
        </map>-->
        
    </xsl:function>
    
    <xsl:function name="tools:generateIndizes" as="node()">
        <xsl:param name="items" as="node()*"/>
        <xsl:param name="groupLabel" as="xs:string"/>
        
        <map key="{$groupLabel}" xmlns="http://www.w3.org/2005/xpath-functions">
            <string key="count"><xsl:value-of select="count($items)"/></string>
            <string key="pitchContour"><xsl:value-of select="tools:getParsonsCode($items)"/></string>
            <string key="refinedPitchContour"><xsl:value-of select="tools:getRefinedParsonsCode($items)"/></string>
            <string key="pclass"><xsl:value-of select="tools:getPclasses($items)"/></string>
            <array key="pitches"><xsl:sequence select="tools:getPnums($items)"/></array>
            <string key="rhythmicContour"><xsl:value-of select="tools:getRhythmicContour($items)"/></string>
            <array key="refinedRhythmicContour"><xsl:sequence select="tools:getRefinedRhythmicContour($items)"/></array>
            <array key="durations"><xsl:sequence select="tools:getDurations($items)"/></array>
            <xsl:sequence select="tools:getIdList($items)"/>
        </map>
    </xsl:function>
    
    <xsl:function name="tools:getIdList" as="node()">
        <xsl:param name="items" as="node()*"/>
        <array key="ids" xmlns="http://www.w3.org/2005/xpath-functions">
            <xsl:for-each select="$items">
                <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="@ref"/></string>
            </xsl:for-each>
        </array>
    </xsl:function>
    
    <xsl:function name="tools:mergeTies" as="node()*">
        <xsl:param name="events" as="node()*"/>
        <xsl:message select="'resolving ' || count($events) || ' events'"></xsl:message>
        <xsl:sequence>
            <xsl:for-each select="$events">
                <xsl:choose>
                    <xsl:when test="@tie.end"/>
                    <xsl:when test="not(@tie.start)">
                        <xsl:sequence select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="notes" select="tools:recurseElementsByAtt($events,.,'ref','tie.start')"/>
                        <xsl:copy>
                            <xsl:copy-of select="@* except (@dur,@dom.r)"/>
                            <xsl:attribute name="dur" select="sum($notes/xs:double(@dur))"/>
                            <xsl:attribute name="dom.r" select="min($notes/xs:double(@dom.r))"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:sequence>
    </xsl:function>
    
    <xsl:function name="tools:recurseElementsByAtt" as="node()*">
        <xsl:param name="all" as="node()+"/>
        <xsl:param name="elem" as="node()?"/>
        <xsl:param name="attId" as="xs:string"/>
        <xsl:param name="attRef" as="xs:string"/>
        
        <xsl:if test="$elem">
            <xsl:sequence select="($elem,tools:recurseElementsByAtt($all,$all[@*[local-name() = $attId] = $elem/@*[local-name() = $attRef]],$attId,$attRef))"/>    
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>