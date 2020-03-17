<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:json="http://www.w3.org/2005/xpath-functions"
    xmlns:tools="no:link"
    exclude-result-prefixes="xs math xd mei tools json"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 4, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- this outputs a simple sequence similar to Parsons Code, indicating the change of durations -->
    <xsl:function name="tools:getRhythmicContour" as="xs:string">
        <xsl:param name="items" as="node()*"/>
        
        <xsl:variable name="durs" select="$items/@dur" as="xs:string*"/>
        
        <xsl:variable name="pc.string" as="xs:string*">
            <xsl:value-of select="'.'"/>
            <xsl:for-each select="(2 to count($durs))">
                <xsl:variable name="i" select="." as="xs:integer"/>
                <xsl:variable name="current.dur" select="xs:double($durs[$i])" as="xs:double"/>
                <xsl:variable name="prev.dur" select="xs:double($durs[$i - 1])" as="xs:double"/>
                <xsl:choose>
                    <xsl:when test="$current.dur = $prev.dur"><xsl:value-of select="'s'"/></xsl:when>
                    <xsl:when test="$current.dur lt $prev.dur"><xsl:value-of select="'d'"/></xsl:when>
                    <xsl:when test="$current.dur gt $prev.dur"><xsl:value-of select="'u'"/></xsl:when>
                </xsl:choose>
            </xsl:for-each>   
        </xsl:variable>
        
        <xsl:sequence select="string-join($pc.string,'')"/>
    </xsl:function>
    
    <!-- this gets the exact durations of events -->
    <xsl:function name="tools:getDurations" as="node()*">
        <xsl:param name="items" as="node()*"/>
        
        <xsl:for-each select="$items">
            <xsl:variable name="dur" select="@dur" as="xs:string"/>
            <!--<xsl:value-of select="string-join(for $i in (1 to (6 - string-length($dur))) return '0') || $dur"/>-->
            <number xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$dur"/></number>
        </xsl:for-each>
    </xsl:function>
    
    <!-- this gets factors of how rhythms change, i.e. a half preceded by a quarter will get a "2", 
        while the opposite order will result in a ".5" -->
    <xsl:function name="tools:getRefinedRhythmicContour" as="node()*">
        <xsl:param name="items" as="node()*"/>
        
        <number xmlns="http://www.w3.org/2005/xpath-functions">1</number>
        <xsl:for-each select="(2 to count($items))">
            <xsl:variable name="pos" select="." as="xs:integer"/>
            <xsl:variable name="prec.item" select="$items[$pos - 1]" as="node()"/>
            <xsl:variable name="current.item" select="$items[$pos]" as="node()"/>
            <xsl:variable name="prec.dur" select="xs:double($prec.item/@dur)" as="xs:double"/>
            <xsl:variable name="current.dur" select="xs:double($current.item/@dur)" as="xs:double"/>
            <number xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="round($current.dur div $prec.dur,3)"/></number>
        </xsl:for-each>
    </xsl:function>
    
</xsl:stylesheet>