<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs math xd mei uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 6, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This XSLT converts @tie attributes to tie elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <xd:doc>
        <xd:desc>
            This template starts processing
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="prep" as="node()*">
            <xsl:apply-templates select="node()" mode="prep"/>    
        </xsl:variable>
        <xsl:apply-templates select="$prep" mode="cleanup"/>
    </xsl:template>
    
    <xsl:template match="mei:measure[.//@tie[. = ('i','m')]]" mode="prep">
        <xsl:variable name="start.measure" select="." as="node()"/>
        <xsl:variable name="next.measure" select="following::mei:measure[1]" as="node()?"/>
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            
            <xsl:for-each select=".//mei:*[@tie[. = ('i','m')]]">
                <xsl:variable name="start.elem" select="." as="node()"/>
                <xsl:variable name="staff" select="ancestor::mei:staff" as="node()"/>
                <xsl:variable name="layer" select="ancestor::mei:layer" as="node()"/>
                
                <xsl:variable name="search.start" select="$start.elem/ancestor-or-self::mei:*[parent::mei:layer][1]" as="node()"/>
                
                <xsl:variable name="end.within.measure" select="$search.start/following-sibling::mei:*[descendant-or-self::mei:*[@tie = ('m','t')]][1]/descendant-or-self::mei:*[@tie = ('m','t')][1]" as="node()?"/>
                
                <xsl:variable name="end.elem" as="node()?">
                    <xsl:choose>
                        <xsl:when test="$end.within.measure">
                            <xsl:sequence select="$end.within.measure"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="next.layer" select="$next.measure/mei:staff[@n = $staff/@n]/mei:layer[not(@n) or @n = $layer/@n]" as="node()?"/>
                            <xsl:sequence select="($next.layer//mei:*[@tie = ('m','t')])[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="exists($end.elem)">
                        <tie xmlns="http://www.music-encoding.org/ns/mei"
                            xml:id="x{uuid:randomUUID()}"
                            staff="{$staff/@n}"
                            startid="#{$start.elem/@xml:id}"
                            endid="#{$end.elem/@xml:id}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <brokenTie xmlns="http://www.music-encoding.org/ns/mei" startid="{$start.elem/@xml:id}"/>
                        <xsl:message select="'[ERROR] mdiv ' || ancestor::mei:mdiv/@n || ', measure ' || $start.measure/@n || ': Unable to determine end for tie starting at ' || local-name($start.elem) || ' ' || $start.elem/@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:for-each>
            
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This template removes conversion artifacts</xd:desc>
    </xd:doc>
    <xsl:template match="mei:brokenTie" mode="cleanup"/>
    
    <xd:doc>
        <xd:desc>This template ensures that no information is duplicated</xd:desc>
    </xd:doc>
    <xsl:template match="@tie" mode="cleanup">
        <xsl:variable name="tied.elem.ref" select="'#' || parent::mei:*/@xml:id" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test=". = 'i'">
                <xsl:choose>
                    <xsl:when test="ancestor::mei:mdiv//mei:tie[@startid = $tied.elem.ref]"/>
                    <xsl:otherwise>
                        <xsl:next-match/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test=". = 'm'">
                <xsl:choose>
                    <xsl:when test="ancestor::mei:mdiv//mei:tie[@startid = $tied.elem.ref] and ancestor::mei:mdiv//mei:tie[@endid = $tied.elem.ref]"/>
                    <xsl:otherwise>
                        <xsl:next-match/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test=". = 't'">
                <xsl:choose>
                    <xsl:when test="ancestor::mei:mdiv//mei:tie[@endid = $tied.elem.ref]"/>
                    <xsl:otherwise>
                        <xsl:next-match/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>    
        
    </xsl:template>
    
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