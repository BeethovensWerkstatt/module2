<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs math xd mei"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Febr 4, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> agnesseipelt ranmo</xd:p>
            <xd:p>This stylesheet changes all tie-elements to slur-elements in the case of op. 134 when tied notes are in one measure. This is a special pianistic issue.</xd:p>
            <xd:p>match mei:tie, dessen werte von startid und endid zu noten gehören, die die gleiche Tonhöhe habe und in einem Takt stehen. gleicher pname und gleiche oct und wenn Wert von accid und/oder accid.ges gleich</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    
    <xsl:template match="mei:tie">
        <xsl:variable name="start.id" select="replace(@startid, '#', '')"/>
        <xsl:variable name="end.id" select="replace(@endid, '#', '')"/>
        
        <xsl:variable name="start.note" select="ancestor::mei:measure//mei:*[@xml:id =$start.id]"/>
        <xsl:variable name="end.note" select="ancestor::mei:measure//mei:*[@xml:id = $end.id]"/>
        
        <xsl:variable name="start.m" select="ancestor::mei:measure[//$start.note]/@n"/>
        <xsl:variable name="end.m" select="ancestor::mei:measure[//$end.note]/@n"/>
        
        <xsl:variable name="start.beam" select="preceding::mei:note[@xml:id = $start.id]/ancestor::mei:beam/@xml:id"/>
        <xsl:variable name="end.beam" select="preceding::mei:note[@xml:id = $end.id]/ancestor::mei:beam/@xml:id"/>
        
        
        <xsl:if test="($start.m eq $end.m) and ($start.beam eq $end.beam)">
            <xsl:message select="'m:' || ancestor::mei:measure/@n || ': startnote: ' || $start.id || ' /endnote: ' || $end.id || ' /beam: ' || $start.beam "  terminate="no"></xsl:message>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="($start.m eq $end.m) and ($start.beam eq $end.beam)">
                <xsl:element name="slur" xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:copy-of select="@*"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
        
        
        
    </xsl:template>
    
    
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>