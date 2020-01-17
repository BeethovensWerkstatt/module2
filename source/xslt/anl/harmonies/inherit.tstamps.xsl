<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 17, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>
                This template adds @tstamp and @tstamp2 to notes within chords, by copying it from that chord. 
                This is supposed to help retrieving notes by XPath.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:note[not(@tstamp) and not(@tstamp2) and ancestor::mei:chord[@tstamp and @tstamp2]]" mode="inherit.tstamps">
        <xsl:copy>
            <xsl:apply-templates select="@* | ancestor::mei:chord/@tstamp | ancestor::mei:chord/@tstamp2 | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>