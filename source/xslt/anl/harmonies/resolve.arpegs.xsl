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
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- MODE resolve.arpegs -->
    <xsl:template
        match="mei:beam[count(descendant::mei:note[not(@grace) and not(@cue) and @tstamp]) gt 2]"
        mode="resolve.arpegs">
        <xsl:variable name="has.chords" select="exists(descendant::mei:chord)" as="xs:boolean"/>
        <!-- gracenotes and cue-notes are ignored -->
        <xsl:variable name="notes"
            select="descendant::mei:note[not(@grace) and not(@cue) and @tstamp]" as="node()*"/>
        <xsl:variable name="start.tstamp"
            select="($notes[1]/number(@tstamp) mod 1 eq 0) or ($notes[1]/number(@tstamp) mod 1 eq 0.5)"
            as="xs:boolean"/>
        <!-- use the function interpreteChord that stacks all notes and calculates the costs (one third above the root = 1, two = 2 etc.) -->
        <xsl:variable name="potential.chords"
            select="tools:generateStackOfThirds($notes, true(), false())" as="node()+"/>
        <!-- take the least costs of thirds -->
        <xsl:variable name="minimal.cost.of.thirds"
            select="min($potential.chords/descendant-or-self::mei:chordDef/max(.//number(@temp:cost)))"
            as="xs:double"/>
        <!-- collect the durations of all notes within the beam -->
        <xsl:variable name="notes.dur" select="$notes/@dur" as="xs:string*"/>
        
        <!--<xsl:variable name="chords.dur" select="$notes/parent::mei:chord/@dur" as="xs:string+"/>-->
        
        <xsl:choose>
            <!-- ignore when there is a chord within the beam -->
            <xsl:when test="$has.chords">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="count($notes.dur) = 0 and not($has.chords)">
                <xsl:message select="$notes" terminate="yes"/>
            </xsl:when>
            
            <!-- ignore when the beam does not start on a full or 0.5-tstamp -->
            <xsl:when test="not($start.tstamp)">
                <xsl:next-match/>
            </xsl:when>
            
            <!-- ignore when there are less than 3 notes within the beam -> discuss! -->
            <xsl:when test="count($notes) lt 3">
                <xsl:next-match/>
            </xsl:when>
            
            <!-- ignore when there are different durations within the beam -->
            <xsl:when test="count(distinct-values($notes.dur)) gt 1">
                <xsl:next-match/>
            </xsl:when>
            
            <!-- ignore when there is only one single pitch name – can be kept do reduce number of onsets -->
            <!--<xsl:when test="$minimal.cost.of.thirds eq 0">
                <xsl:next-match/>
            </xsl:when>-->
            
            
            <!--toDo: add @mfunc="arp" to all notes that fit to these conditions-->
            
            <!-- lest.thirds less than 3 means only third, fifth and seventh above the root are allowed -->
            <xsl:when test="$minimal.cost.of.thirds le 3">
                <xsl:variable name="start" select="$notes[1]/@tstamp" as="xs:string"/>
                <xsl:variable name="end" select="$notes[last()]/@tstamp2" as="xs:string"/>
                <chord xmlns="http://www.music-encoding.org/ns/mei" type="resolved.arpeggio">
                    <xsl:attribute name="tstamp" select="$start"/>
                    <xsl:attribute name="tstamp2" select="$end"/>
                    <xsl:apply-templates select="$notes" mode="resolve.arpegs.change.tstamps">
                        <xsl:with-param name="start" tunnel="yes" select="$start"/>
                        <xsl:with-param name="end" tunnel="yes" select="$end"/>
                    </xsl:apply-templates>
                </chord>
            </xsl:when>
            <!--  A seventh above the root must be accompanied by a third and/or a fifth -->
            <xsl:when
                test="$minimal.cost.of.thirds eq 3 and $potential.chords/descendant-or-self::*[.//mei:annot[@type = 'mfunc.tonelist']/@cost = '3' and .//mei:annot[@type = ('ct ct3', 'ct ct5')]]">
                <xsl:variable name="start" select="$notes[1]/@tstamp" as="xs:string"/>
                <xsl:variable name="end" select="$notes[last()]/@tstamp2" as="xs:string"/>
                <chord xmlns="http://www.music-encoding.org/ns/mei" type="resolved.arpeggio">
                    <xsl:attribute name="tstamp" select="$start"/>
                    <xsl:attribute name="tstamp2" select="$end"/>
                    <xsl:apply-templates select="$notes" mode="resolve.arpegs.change.tstamps">
                        <xsl:with-param name="start" tunnel="yes" select="$start"/>
                        <xsl:with-param name="end" tunnel="yes" select="$end"/>
                    </xsl:apply-templates>
                </chord>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
        
            </xsl:template>
    
    <!-- change tstamps of the notes that took part of the arpeggio and are now in a chord-element -->
    <xsl:template match="@tstamp" mode="resolve.arpegs.change.tstamps">
        <xsl:param name="start" tunnel="yes"/>
        <xsl:attribute name="tstamp" select="$start"/>
    </xsl:template>
    
    <xsl:template match="@tstamp2" mode="resolve.arpegs.change.tstamps">
        <xsl:param name="end" tunnel="yes"/>
        <xsl:attribute name="tstamp2" select="$end"/>
    </xsl:template>
    
</xsl:stylesheet>