<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:bw="http://www.beethovens-werkstatt.de/ns/bw"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs math xd mei bw xlink" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 23, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p> This file acts as driver for various analytical xslts, to be applied on one or
                more MEI files. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xml"/>
    
    <!-- allowed values for param $mode are:
        'comparison' - files need to be "normalized" for a later check for identity 
        'melodicComparison' -
        'harmonicComparison' -
        'eventDensity' -
    -->
    <xsl:param name="mode"/>

    <xsl:param name="mdiv"/>
    <!-- allowed values for param $transpose.mode are:
        'none'
        'matchFile1'
        'matchFile2'
        'C'
    -->
    <xsl:param name="transpose.mode"/>
    
    <!-- a list of hidden staves (by @n), separated by comma. Empty string if full score shall be shown -->
    <xsl:param name="hidden.staves"/>

    <!-- decide whether potential arpeggios shall be resolved for a harmonic analysis -->
    <xsl:param name="resolve.arpegs" select="true()"/>
    
    <!-- generate harm elements only for accented / important tstamps -->
    <xsl:param name="harmonize.important.tstamps.only" select="true()"/>
    
    <!-- select the intended output of the harmonize functions. Currently allowed values are: 
        'harm.thirds-based-chords.label.plain' (default)
        'harm.thirds-based-chords.chordDef' (mostly for debugging purposes)
    -->
    <xsl:param name="harmonize.output" select="'harm.thirds-based-chords.label.plain'"/>
    
    <!--  -->
    <xsl:param name="harmonize.suppress.duplicates" select="true()"/>
    
    <xsl:include href="tools/pick.mdiv.xsl"/>
    <xsl:include href="tools/rescore.parts.xsl"/>
    <xsl:include href="tools/addid.xsl"/>
    <xsl:include href="tools/addtstamps.xsl"/>
    <xsl:include href="anl/determine.pitch.xsl"/>
    <xsl:include href="anl/determine.pnum.xsl"/>
    <!--<xsl:include href="anl/determine.roman.numerals.xsl"/>-->
    <!--<xsl:include href="anl/examine.roman.base.numerals.xsl"/>-->
    <xsl:include href="anl/determine.key.xsl"/>
    <!--<xsl:include href="anl/krumhansl.schmuckler.xsl"/>-->
    <xsl:include href="anl/determine.event.density.xsl"/>
    <xsl:include href="anl/extract.melodic.lines.xsl"/>
    <xsl:include href="tools/add.next.xsl"/>
    <xsl:include href="tools/add.intm.xsl"/>
    <!--<xsl:include href="anl/insert.harmonies.xsl"/>-->
    <xsl:include href="anl/interprete.harmonies.xsl"/>
    <!--<xsl:include href="anl/determine.chords.xsl"/>-->
    <xsl:include href="tools/disable.staves.xsl"/>
    <!--<xsl:include href="anl/clean.up.xsl"/>-->

    <xsl:include href="data/circleOf5.xsl"/>

    <xsl:template match="/">
        <xsl:variable name="picked.mdiv" as="node()">
            <xsl:apply-templates select="/mei:mei" mode="pick.mdiv">
                <xsl:with-param name="mdiv" select="$mdiv" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="rescored.parts" as="node()">
            <xsl:apply-templates select="$picked.mdiv" mode="rescore.parts"/>
        </xsl:variable>
        <xsl:variable name="disabled.staves" as="node()">
            <xsl:apply-templates select="$rescored.parts" mode="disable.staves">
                <xsl:with-param name="hidden.staves" select="$hidden.staves" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="added.ids" as="node()">
            <xsl:apply-templates select="$disabled.staves" mode="add.id"/>
        </xsl:variable>
        <xsl:variable name="added.tstamps" as="node()">
            <xsl:apply-templates select="$added.ids" mode="add.tstamps"/>
        </xsl:variable>
        <xsl:variable name="output" as="node()">
            <xsl:choose>
                <xsl:when test="$mode = 'comparison'">
                    <xsl:variable name="determined.key" as="node()">
                        <xsl:apply-templates select="$added.tstamps" mode="determine.key"/>
                    </xsl:variable>
                    <xsl:variable name="determined.pitch" as="node()">
                        <xsl:apply-templates select="$determined.key" mode="determine.pitch"/>
                    </xsl:variable>
                    <xsl:copy-of select="$determined.pitch"/>
                </xsl:when>
                <xsl:when test="$mode = 'melodicComparison'">
                    <xsl:variable name="determined.key" as="node()">
                        <xsl:apply-templates select="$added.tstamps" mode="determine.key"/>
                    </xsl:variable>
                    <xsl:variable name="determined.pnum" as="node()">
                        <xsl:apply-templates select="$determined.key" mode="determine.pnum"/>
                    </xsl:variable>
                    <xsl:variable name="extracted.melodic.lines" as="node()">
                        <xsl:apply-templates select="$determined.pnum" mode="extract.melodic.lines"/>
                    </xsl:variable>
                    <xsl:copy-of select="$extracted.melodic.lines"/>
                </xsl:when>
                
                <xsl:when test="$mode = 'eventDensity'">
                    <xsl:variable name="determined.event.density" as="node()">
                        <xsl:apply-templates select="$added.tstamps" mode="determine.event.density"/>
                    </xsl:variable>
                    <xsl:copy-of select="$determined.event.density"/>
                </xsl:when>
                
                <xsl:when test="$mode = 'harmonicComparison'">
                    <xsl:variable name="added.next" as="node()*">
                        <xsl:apply-templates select="$added.tstamps" mode="add.next"/>
                    </xsl:variable>                    
                    <xsl:variable name="added.intm" as="node()*">
                        <xsl:apply-templates select="$added.next" mode="add.intm"/>
                    </xsl:variable>
                    <xsl:variable name="determined.pnum" as="node()">
                        <xsl:apply-templates select="$added.intm" mode="determine.pnum"/>
                    </xsl:variable>
                    <xsl:variable name="interpreted.harmonies" as="node()*">
                        <xsl:apply-templates select="$determined.pnum" mode="interprete.harmonies">
                            <xsl:with-param name="resolve.arpegs" select="$resolve.arpegs" tunnel="yes" as="xs:boolean"/>
                            <xsl:with-param name="harmonize.important.tstamps.only" select="$harmonize.important.tstamps.only" tunnel="yes" as="xs:boolean"/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xsl:copy-of select="$interpreted.harmonies"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <!-- fall-back is the same as 'comparison' -->
                    <xsl:variable name="determined.key" as="node()">
                        <xsl:apply-templates select="$added.tstamps" mode="determine.key"/>
                    </xsl:variable>
                    <xsl:variable name="determined.pitch" as="node()">
                        <xsl:apply-templates select="$determined.key" mode="determine.pitch"/>
                    </xsl:variable>
                    <xsl:copy-of select="$determined.pitch"/>
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
