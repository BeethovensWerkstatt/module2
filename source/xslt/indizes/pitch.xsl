<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link"
    exclude-result-prefixes="xs math xd mei tools"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 4, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- gets a string with hex pclasses, chords are coded with all pclasses in an array-like form, i.e. "[8,a]" -->
    <xsl:function name="tools:getPclasses" as="xs:string">
        <xsl:param name="items" as="node()*"/>
        
        <xsl:variable name="pclasses" select="$items/@pnum" as="xs:string*"/>
        
        <xsl:variable name="output" as="xs:string*">
            <xsl:for-each select="$pclasses">
                <xsl:choose>
                    <xsl:when test=". = '.'">
                        <xsl:value-of select="'.'"/>
                    </xsl:when>
                    <xsl:when test="not(starts-with(.,'['))">
                        <xsl:variable name="pclass" select="xs:integer(.) mod 12" as="xs:integer"/>
                        <xsl:value-of select="if($pclass = 11) then('b') else if($pclass = 10) then('a') else(xs:string($pclass))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="curr.pclasses" as="xs:string*">
                            <xsl:for-each select="tokenize(replace(.,'[\[\]]',''),',')">
                                <xsl:variable name="pclass" select="xs:integer(.) mod 12" as="xs:integer"/>
                                <xsl:value-of select="if($pclass = 11) then('b') else if($pclass = 10) then('a') else(xs:string($pclass))"/>
                            </xsl:for-each>    
                        </xsl:variable>
                        <xsl:value-of select="'[' || string-join($curr.pclasses,',') || ']'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($output,'')"/>
    </xsl:function>
    
    <xsl:function name="tools:getPnums" as="node()*">
        <xsl:param name="items" as="node()*"/>
        
        <xsl:for-each select="$items">
            <xsl:variable name="pnum" select="@pnum" as="xs:string"/>
            <array xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:choose>
                    <xsl:when test="$pnum = '.'"/>
                    <xsl:when test="not(starts-with($pnum,'['))">
                        <number><xsl:value-of select="$pnum"/></number>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="tokenize(replace($pnum,'[\[\]]',''),',')">
                            <number><xsl:value-of select="."/></number>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </array>
        </xsl:for-each>
    </xsl:function>
    
    
</xsl:stylesheet>