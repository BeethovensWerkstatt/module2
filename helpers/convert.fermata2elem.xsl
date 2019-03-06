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
            <xd:p>This XSLT converts @fermata attributes to fermata elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <xd:doc>
        <xd:desc>
            This template starts processing
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="mei:measure[.//@fermata]">
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            
            <xsl:for-each select=".//mei:*[@fermata]">
                <xsl:variable name="start.elem" select="." as="node()"/>
                <xsl:variable name="staff" select="ancestor::mei:staff" as="node()"/>
                
                    <fermata xmlns="http://www.music-encoding.org/ns/mei"
                        xml:id="x{uuid:randomUUID()}"
                        staff="{$staff/@n}"
                        startid="#{$start.elem/@xml:id}"
                        place="{@fermata}"/>
                
            </xsl:for-each>
            
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This template removes the old fermata attribute</xd:desc>
    </xd:doc>
    <xsl:template match="@fermata"/>
    
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