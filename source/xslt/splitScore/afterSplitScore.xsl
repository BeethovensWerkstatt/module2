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
                <xd:b>Created on:</xd:b>Jan 14 2020</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> </xd:p>
            <xd:p>This XSL converts score into parts</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" method="xml"/>
    
    <!--<xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>-->
  
  
    <xsl:template match="mei:scoreDef/@xml:id | /mei:staffGrp/@xml:id | mei:section/@xml:id | mei:measure/@xml:id" mode="cleanup">
        <xsl:attribute name="xml:id" select="'x'||uuid:randomUUID()"/>
    </xsl:template>
  
  <xsl:template match="@staff" mode="cleanup">
      <xsl:attribute name="staff" select="xs:integer(1)"/>
  </xsl:template>
    
    <xsl:template match="//mei:staff/@n" mode="cleanup">
        <xsl:attribute name="n" select="xs:integer(1)"/>
    </xsl:template>
    
    
    <!-- copies xml nodes -->
    <!--<xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>-->
    
    
</xsl:stylesheet>