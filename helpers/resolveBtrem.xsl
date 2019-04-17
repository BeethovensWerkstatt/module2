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
            <xd:p><xd:b>Created on:</xd:b> Apr 16, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="mei:bTrem">
        
        <xsl:variable name="dur" select="1 div xs:integer(@dur)" as="xs:double"/>
        <xsl:variable name="unitdur" select="1 div xs:integer(@unitdur)" as="xs:double"/>
        <xsl:variable name="repeats" select="xs:integer($dur div $unitdur)" as="xs:integer"/>
        
        <xsl:variable name="child" select="element()" as="node()"/>
        
        <xsl:choose>
            <xsl:when test="not(@dots)">
                <xsl:apply-templates select="$child" mode="keep.id">
                    <xsl:with-param name="dur" select="$unitdur" tunnel="yes"/>
                </xsl:apply-templates>
                
                <xsl:for-each select="(2 to $repeats)">
                    <xsl:apply-templates select="$child" mode="adjust.id">
                        <xsl:with-param name="dur" select="$unitdur" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:for-each>
                
            </xsl:when>
            <xsl:otherwise>
                <tuplet xmlns="http://www.music-encoding.org/ns/mei" xml:id="t{uuid:randomUUID()}" num="3" numbase="2" num.visible="false">
                    <xsl:apply-templates select="$child">
                        <xsl:with-param name="dur" select="$unitdur" tunnel="yes"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="$child" mode="adjust.id">
                        <xsl:with-param name="dur" select="$unitdur" tunnel="yes"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="$child" mode="adjust.id">
                        <xsl:with-param name="dur" select="$unitdur" tunnel="yes"/>
                    </xsl:apply-templates>
                </tuplet>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="@xml:id" mode="adjust.id">
        <xsl:attribute name="xml:id" select="'n' || uuid:randomUUID()"/>
    </xsl:template>
    
    <xsl:template match="@dur" mode="keep.id adjust.id">
        <xsl:param name="dur" tunnel="yes"/>
        <xsl:attribute name="dur" select="xs:integer(1 div $dur)"/>
    </xsl:template>
    
    <xsl:template match="@stem.mod" mode="keep.id adjust.id"/>
    
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