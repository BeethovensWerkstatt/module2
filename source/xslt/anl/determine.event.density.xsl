<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>
                This file determines the event density
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:measure" mode="determine.event.density">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:variable name="staff.count" select="count(.//mei:staff)" as="xs:integer"/>
            <xsl:variable name="tstamps" select="distinct-values(.//mei:staff//@tstamp)" as="xs:string+"/>
            <xsl:for-each select="$tstamps">
                <xsl:sort select="." data-type="number"/>
                <harm xmlns="http://www.music-encoding.org/ns/mei" staff="{$staff.count}" place="below" tstamp="{.}" type="eventDensity">
                    <xsl:text>|</xsl:text>
                </harm>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>