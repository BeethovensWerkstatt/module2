<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs math xd mei"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 4, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> agnesseipelt</xd:p>
            <xd:p>This stylesheet cleans up the result of determine.chords.xsl</xd:p>
            <xd:p>By deleting all harmonies consisting of only the root and a seventh (ciao) and deleting the wrapping choice-element</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    
    
    
    <!-- delete all wrapping choice-elements -->
    <xsl:template match="mei:choice[@type='harmInterpretation']" mode="clean.harmonies">
        <xsl:copy-of select="mei:harm"/>
    </xsl:template>
    
    
    <!--delete all choice-elements that have a rend elements that contains the word "ciao"-->
    <xsl:template match="mei:choice[descendant::mei:rend[@type='root' and text()='ciao']]" mode="clean.harmonies"/>
    
   
    
    <!--<xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>-->
    
    
</xsl:stylesheet>