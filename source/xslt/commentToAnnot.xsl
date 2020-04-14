<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs mei uuid xd math"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b>Jan 23 2020</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Johannes Kepper, Ran Mo</xd:p>
            <xd:p>This XSL converts comment into annot element</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>convert comment into annot-element</xd:desc>
    </xd:doc>
<xsl:template match="mei:music//comment()">
    <xsl:variable name="text" select="normalize-space(xs:string(.))" as="xs:string"/>
    
    <xsl:choose>
        <xsl:when test="starts-with($text, 'annot')">
          
            <xsl:element name="annot" xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id" select="'x' || uuid:randomUUID()"/>
                <xsl:attribute name="type" select="'sic'"/>
                <xsl:attribute name="resp" select="'#BW'"/>
                <xsl:value-of select="normalize-space(replace($text, 'annot', ''))"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:next-match/>
        </xsl:otherwise>
    </xsl:choose>
    
</xsl:template>



    
    <!-- copies xml nodes -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>