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
    
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:include href="beforeSplitScore.xsl"/>
    <xsl:include href="splitScore.xsl"/>
    <xsl:include href="afterSplitScore.xsl"/>
    
    <xsl:template match="/">
        
        <xsl:variable name="giveStaffNo" as="node()">
            <xsl:apply-templates select="/mei:mei" mode="giveStaffNo"/>
        </xsl:variable>
        <xsl:variable name="splitScore" as="node()">
            <xsl:apply-templates select="$giveStaffNo" mode="splitScore"/>
        </xsl:variable>
        <xsl:variable name="cleanup" as="node()">
            <xsl:apply-templates select="$splitScore" mode="cleanup"/>
        </xsl:variable>
        <xsl:copy-of select="$cleanup"/>
    </xsl:template>
    
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>