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
            <xd:p>This stylesheet inserts harmonies</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:measure" mode="insert.harmonies">
        <xsl:variable name="this.measure" select="." as="node()"/>
        <xsl:variable name="local.keys" select="'C'" as="xs:string+"/>
        
        <xsl:variable name="meter.count" select="preceding::mei:scoreDef[@meter.count][1]/xs:integer(@meter.count)" as="xs:integer?"/>
        <xsl:variable name="meter.unit" select="preceding::mei:scoreDef[@meter.unit][1]/xs:integer(@meter.unit)" as="xs:integer?"/>
        
        <xsl:variable name="lookup.keys" select="distinct-values((for $key in $local.keys return substring($key,1,1)))" as="xs:string*"/>
        
        <!--<xsl:message select="'Looking for ' || count($lookup.keys) || ' (' || count($local.keys) || ') keys in measure ' || $this.measure/@n || ': ' || string-join($lookup.keys,' – ') || ' (' || string-join($local.keys,' – ') || ')'"/>-->
        
        <xsl:variable name="harms" as="node()*">
            <xsl:for-each select="$lookup.keys">
                <xsl:variable name="local.key" select="." as="xs:string"/>
                <xsl:variable name="key.pos" select="position()" as="xs:integer"/>
                
                <xsl:variable name="determined.pitch" as="node()">
                    <xsl:apply-templates select="$this.measure" mode="determine.pitch">
                        <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                
                <!-- this will add @tstamp and @tstamp2 to notes within chords to avoid problems with the recognition later on -->
                <xsl:variable name="inherited.tstamps" as="node()">
                    <xsl:apply-templates select="$determined.pitch" mode="inherit.tstamps"/>
                </xsl:variable>
                
                <xsl:variable name="determined.chords" as="node()">
                    <xsl:apply-templates select="$inherited.tstamps" mode="determine.chords">
                        <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                        <xsl:with-param name="current.pos" select="$key.pos" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                
                <!--<xsl:variable name="based.harmonies.on.key" as="node()">
                    <xsl:apply-templates select="$determined.chords" mode="base.harmonies.on.key">
                        <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                        <xsl:with-param name="current.pos" select="$key.pos" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>-->
                
                <!--<xsl:variable name="events.added.tstamp2" as="node()">
                    <xsl:apply-templates select="$based.harmonies.on.key" mode="events.add.tstamp2">
                        <xsl:with-param name="meter.count" select="$meter.count" tunnel="yes"/>
                        <xsl:with-param name="meter.unit" select="$meter.unit" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>-->
                
                <!--<xsl:variable name="determined.numerals" as="node()">
                    <xsl:apply-templates select="$events.added.tstamp2" mode="determine.roman.numerals">
                        <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>-->
                <!--<xsl:sequence select="$determined.numerals//mei:harm"/>-->
                
                <xsl:sequence select="$determined.chords//mei:choice[@type = 'harmInterpretation']"/>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:attribute name="type" select="string-join($local.keys, ' ')"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:sequence select="$harms"/>
        </xsl:copy>
        
    </xsl:template>
    
</xsl:stylesheet>