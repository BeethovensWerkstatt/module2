<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei tools temp custom"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 17, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:function name="tools:isAccented" as="xs:boolean">
        <xsl:param name="tstamp" as="xs:string"/>
        <xsl:param name="meter.count" as="xs:integer"/>
        <xsl:param name="meter.unit" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="$meter.count = 2 and $meter.unit = 2 and $tstamp = ('1', '1.5', '2', '2.5')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = 2 and $meter.unit = 4 and $tstamp = ('1', '2')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = 3 and $meter.unit = 4 and $tstamp = ('1', '2', '3')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when
                test="$meter.count = 4 and $meter.unit = 4 and $tstamp = ('1', '2', '3', '4')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = 3 and $meter.unit = 8 and $tstamp = ('1')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = 6 and $meter.unit = 8 and $tstamp = ('1', '4')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = 9 and $meter.unit = 8 and $tstamp = ('1', '4', '7')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>