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
            <xd:p><xd:b>Created on:</xd:b> Sep 11, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> Agnes Seipelt</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This stylesheet removes harmonies that haven't changed</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:choice[@type = 'harmInterpretation']" mode="resolve.duplicate.harms">
        <xsl:variable name="this.harm" select="." as="node()"/>
        <xsl:variable name="prev.harm" select="preceding-sibling::mei:choice[@type = 'harmInterpretation'][1]" as="node()?"/>
        <xsl:choose>
            <xsl:when test="not($prev.harm)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="this.rends" select="$this.harm//mei:rend/text()" as="xs:string*"/>
                <xsl:variable name="prev.rends" select="$prev.harm//mei:rend/text()" as="xs:string*"/>
                
                <xsl:choose>
                    <xsl:when test="(every $rend in $this.rends satisfies ($rend = $prev.rends)) and (every $rend in $prev.rends satisfies ($rend = $this.rends))">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:next-match/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>