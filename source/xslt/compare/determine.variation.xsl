<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Aug 16, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This file calculates the level of difference for each measure, and
            adds that as additional attributes to measure</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    
    <xsl:template match="mei:measure" mode="determine.variation">
        
        <xsl:variable name="all.durations" as="xs:double*">
            <xsl:for-each select=".//mei:*[local-name() = ('note') and ancestor-or-self::mei:*/@tstamp and ancestor-or-self::mei:*/@tstamp2]">
                <xsl:variable name="dur" select="number(ancestor-or-self::mei:*[@tstamp2][1]/@tstamp2) - number(ancestor-or-self::mei:*[@tstamp][1]/@tstamp)" as="xs:double"/>
                <xsl:value-of select="$dur"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="all.identical.durations" as="xs:double*">
            <xsl:for-each select=".//mei:note['id' = tokenize(@type,' ') and ancestor-or-self::mei:*/@tstamp and ancestor-or-self::mei:*/@tstamp2]">
                <xsl:variable name="dur" select="number(ancestor-or-self::mei:*[@tstamp2][1]/@tstamp2[1]) - number(ancestor-or-self::mei:*[@tstamp][1]/@tstamp[1])" as="xs:double"/>
                <xsl:value-of select="$dur"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="all.similar.durations" as="xs:double*">
            <xsl:for-each select=".//mei:note[@type and not('id' = tokenize(@type,' ')) and not(@type = 'noMatch') and ancestor-or-self::mei:*/@tstamp and ancestor-or-self::mei:*/@tstamp2]">
                <xsl:variable name="dur" select="number(ancestor-or-self::mei:*[@tstamp2][1]/@tstamp2[1]) - number(ancestor-or-self::mei:*[@tstamp][1]/@tstamp[1])" as="xs:double"/>
                <xsl:value-of select="$dur"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="all.diff.durations" as="xs:double*">
            <xsl:for-each select=".//mei:note[@type = 'noMatch' and ancestor-or-self::mei:*/@tstamp and ancestor-or-self::mei:*/@tstamp2]">
                <xsl:variable name="dur" select="number(ancestor-or-self::mei:*[@tstamp2][1]/@tstamp2[1]) - number(ancestor-or-self::mei:*[@tstamp][1]/@tstamp[1])" as="xs:double"/>
                <xsl:value-of select="$dur"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="total.duration" select="sum($all.durations)" as="xs:double"/>
        <xsl:variable name="total.identity" select="sum($all.identical.durations)" as="xs:double"/>
        <xsl:variable name="total.similarity" select="sum($all.similar.durations)" as="xs:double"/>
        <xsl:variable name="total.difference" select="sum($all.diff.durations)" as="xs:double"/>
        
        <xsl:copy>
            <xsl:attribute name="differenceLevel" select="round((1 div $total.duration * $total.difference),2)"/>
            <xsl:attribute name="similarityLevel" select="round((1 div $total.duration * $total.similarity),2)"/>
            <xsl:attribute name="identityLevel" select="round((1 div $total.duration * $total.identity),2)"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>