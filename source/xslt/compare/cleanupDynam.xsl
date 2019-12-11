<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs math xd"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 11, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> agnesseipelt</xd:p>
            <xd:p>This stylesheet changes (temporarily) all dynam and hairpin elements with their place=between and two staves to the lower staff and place="below"</xd:p>
        </xd:desc>
    </xd:doc>
    
   
    
    
    <xsl:template match="mei:dynam[@place='between'] | mei:hairpin[@place='between']" mode="clean.dynamics">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="staff.information" select="./@staff"/>
            <xsl:attribute name="staff" select="substring-before($staff.information, ' ')"/>
            <xsl:attribute name="place" select="'below'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    
</xsl:stylesheet>