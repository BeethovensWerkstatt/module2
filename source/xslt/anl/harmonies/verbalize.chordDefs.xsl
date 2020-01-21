<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei tools temp custom" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 19, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:chordDef" mode="verbalize.chordDefs.thirds-based-chords.plain">
        <xsl:variable name="chordDef" select="." as="node()"/>
        <xsl:variable name="root.chordMember" select="mei:chordMember[@inth = 'P1' and @temp:cost = '0']" as="node()"/>
        <xsl:variable name="bass.chordMember" select="mei:chordMember[@pname = $chordDef/@temp:bass and @temp:pclass = $chordDef/@temp:bass.pclass]" as="node()"/>
        
        <xsl:variable name="root.accid" select=" if($root.chordMember/@accid.ges = 'f') then('♭') else if ($root.chordMember/@accid.ges = 's') then ('♯') else ('')"/>
        <xsl:variable name="root" select="upper-case($root.chordMember/@pname) || $root.accid" as="xs:string"/>
        
        <xsl:variable name="bass.accid" select=" if($bass.chordMember/@accid.ges = 'f') then('♭') else if ($bass.chordMember/@accid.ges = 's') then ('♯') else ('')"/>
        <xsl:variable name="bass" select="upper-case($bass.chordMember/@pname) || $bass.accid" as="xs:string"/>
        
        <!-- decides if root and bass are the same -->
        <xsl:variable name="different.bass" select="xs:boolean($root != $bass)" as="xs:boolean"/>
        
        <!-- generates the actual output -->
        <rend xmlns="http://www.music-encoding.org/ns/mei" type="root"><xsl:value-of select="$root"/></rend>
        <xsl:if test="not(mei:chordMember[@temp:cost='1'])">
            <rend xmlns="http://www.music-encoding.org/ns/mei" type="noThird">no3</rend>
        </xsl:if>
        <xsl:if test="mei:chordMember[@inth = 'm3'] and mei:chordMember[@inth = 'd5']">
            <rend xmlns="http://www.music-encoding.org/ns/mei" type="dim">dim</rend>
        </xsl:if>
        <xsl:if test="mei:chordMember[@type='43sus']">
            <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod43sus">43sus</rend>
        </xsl:if>
        <xsl:if test="mei:chordMember[@inth='m7']">
            <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct7">7</rend>
        </xsl:if>
        <xsl:if test="mei:chordMember[@inth='M7']">
            <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct7">7+</rend>
        </xsl:if>
        <xsl:if test="$different.bass">
            <rend xmlns="http://www.music-encoding.org/ns/mei" type="bass">/<xsl:value-of select="$bass"/></rend>
        </xsl:if>
        
    </xsl:template>
    
   
    
</xsl:stylesheet>