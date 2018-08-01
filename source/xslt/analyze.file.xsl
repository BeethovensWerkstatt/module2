<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:bw="http://www.beethovens-werkstatt.de/ns/bw" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs math xd mei bw" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 23, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>
                This file acts as driver for various analytical xslts, to be applied on one or more MEI files.
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xml"/>
    <xsl:param name="mode"/>
    <!-- allowed values for param $mode are:
        'plain' - no special treatment
        'identity' - files need to be "normalized" for a later check for identity 
        'krumhansl' - mei:harm with krumhansl schmuckler values are generated for each measure
    
    -->
    
    <xsl:param name="mdiv"/>
    
    <xsl:include href="tools/pick.mdiv.xsl"/>
    <xsl:include href="tools/rescore.parts.xsl"/>
    <xsl:include href="tools/addid.xsl"/>
    <xsl:include href="tools/addtstamps.xsl"/>
    <xsl:include href="anl/determine.pitch.xsl"/>
    <xsl:include href="anl/determine.roman.numerals.xsl"/>
    <xsl:include href="anl/examine.roman.base.numerals.xsl"/>
    <xsl:include href="anl/determine.key.xsl"/>
    <xsl:include href="anl/krumhansl.schmuckler.xsl"/>
    <xsl:include href="anl/determine.event.density.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="picked.mdiv" as="node()">
            <xsl:apply-templates select="/mei:mei" mode="pick.mdiv">
                <xsl:with-param name="mdiv" select="$mdiv" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="rescored.parts" as="node()">
            <xsl:apply-templates select="$picked.mdiv" mode="rescore.parts"/>
        </xsl:variable>
        <xsl:variable name="added.ids" as="node()">
            <xsl:apply-templates select="$rescored.parts" mode="add.id"/>
        </xsl:variable>
        <xsl:variable name="added.tstamps" as="node()">
            <xsl:apply-templates select="$added.ids" mode="add.tstamps"/>
        </xsl:variable>
        <xsl:variable name="output" as="node()">
            <xsl:choose>
                <xsl:when test="$mode ='plain'">
                    <xsl:copy-of select="$added.tstamps"/>
                </xsl:when>
                <xsl:when test="$mode = 'identity'">
                    <xsl:variable name="determined.key" as="node()">
                        <xsl:apply-templates select="$added.tstamps" mode="determine.key"/>
                    </xsl:variable>
                    <xsl:variable name="determined.pitch" as="node()">
                        <xsl:apply-templates select="$determined.key" mode="determine.pitch"/>
                    </xsl:variable>
                    <xsl:copy-of select="$determined.pitch"/>
                </xsl:when>
                <xsl:when test="$mode = 'eventDensity'">
                    <xsl:variable name="determined.event.density" as="node()">
                        <xsl:apply-templates select="$added.tstamps" mode="determine.event.density"/>
                    </xsl:variable>
                    <xsl:copy-of select="$determined.event.density"/>
                </xsl:when>
                <xsl:when test="$mode = 'relativeChroma'">
                    <xsl:variable name="determined.key" as="node()">
                        <xsl:apply-templates select="$added.tstamps" mode="determine.key"/>
                    </xsl:variable>
                    <xsl:variable name="determined.pitch" as="node()">
                        <xsl:apply-templates select="$determined.key" mode="determine.pitch"/>
                    </xsl:variable>
                    <xsl:variable name="determined.roman.base.numerals" as="node()">
                        <xsl:apply-templates select="$determined.pitch" mode="determine.roman.numerals"/>
                    </xsl:variable>
                    <xsl:copy-of select="$determined.roman.base.numerals"/>
                </xsl:when>
                <xsl:when test="$mode = ('krumhansl-1','krumhansl-4')">
                    <xsl:variable name="determined.key" as="node()">
                        <xsl:apply-templates select="$added.tstamps" mode="determine.key"/>
                    </xsl:variable>
                    <xsl:variable name="determined.pitch" as="node()">
                        <xsl:apply-templates select="$determined.key" mode="determine.pitch"/>
                    </xsl:variable>
                    <xsl:variable name="got.krumhansl.schmuckler" as="node()">
                        <xsl:apply-templates select="$determined.pitch" mode="get.krumhansl.schmuckler"/>
                    </xsl:variable>
                    <xsl:copy-of select="$got.krumhansl.schmuckler"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$added.tstamps"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="$output"/>
    </xsl:template>
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