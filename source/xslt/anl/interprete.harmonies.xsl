<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei tools temp custom" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 17, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Agnes Seipelt</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This stylesheet is a wrapper for all steps related to interpreting harmonies.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:include href="harmonies/inherit.tstamps.xsl"/>
    <xsl:include href="harmonies/resolve.arpegs.xsl"/>
    <xsl:include href="harmonies/resolve.transposing.instruments.xsl"/>
    <xsl:include href="harmonies/qualify.tstamp.as.important.xsl"/>
    <xsl:include href="harmonies/generate.stacks.of.thirds.xsl"/>
    <xsl:include href="harmonies/resolve.suspensions.etc.xsl"/>
    
    <xsl:template match="mei:measure" mode="interprete.harmonies">
        <xsl:param name="resolve.arpegs" tunnel="yes" as="xs:boolean"/>
        <xsl:param name="harmonize.important.tstamps.only" tunnel="yes" as="xs:boolean"/>
        
        <!-- This preserves the measure as it stands. The results of the interpretation
            will be inserted into a clean copy of $this.measure -->
        <xsl:variable name="this.measure" select="." as="node()"/>
        
        <xsl:variable name="meter.count" select="preceding::mei:scoreDef[@meter.count][1]/xs:integer(@meter.count)" as="xs:integer?"/>
        <xsl:variable name="meter.unit" select="preceding::mei:scoreDef[@meter.unit][1]/xs:integer(@meter.unit)" as="xs:integer?"/>
        
        <!-- flow of steps from here on -->
        
        <!-- add @tstamp and @tstamp2 to all chord notes, as this simplifies processing -->
        <xsl:variable name="inherited.tstamps" as="node()">
            <xsl:apply-templates select="." mode="inherit.tstamps"/>
        </xsl:variable>
        
        <!-- transposing instruments are resolved to their sounding pitches -->
        <xsl:variable name="resolved.transposing.instruments" as="node()">
            <xsl:apply-templates select="$inherited.tstamps" mode="resolve.transposing.instruments"/>
        </xsl:variable>
        
        <!-- if $resolve.arpegs, arpeggios are treated as chords -->
        <xsl:variable name="resolved.arpegs" as="node()">
            <xsl:choose>
                <xsl:when test="not($resolve.arpegs)">
                    <xsl:sequence select="$resolved.transposing.instruments"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$resolved.transposing.instruments" mode="resolve.arpegs"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- retrieve all events and their relevant timestamps within the current measure -->
        <xsl:variable name="events"
            select="$resolved.arpegs//mei:layer//mei:*[@tstamp and @tstamp2 and local-name() = ('note', 'chord')]"
            as="node()*"/>
        <xsl:variable name="tstamps"
            select="distinct-values($resolved.arpegs//mei:layer//@tstamp)" as="xs:string*"/>
        
        <!-- $harms collects harms from all tstamps -->
        <xsl:variable name="harms" as="node()*">
            <xsl:for-each select="$tstamps">
                <xsl:variable name="current.tstamp" select="." as="xs:string"/>
                
                <!-- decide whether this is on an "important" tstamp -->
                <xsl:variable name="tstamp.is.important" select="tools:isAccented($current.tstamp, $meter.count, $meter.unit)" 
                    as="xs:boolean"/>
                
                <!-- all notes that are sounding at the current tstamp, no matter when they start or stop -->
                <xsl:variable name="current.notes"
                    select="$events[number(@tstamp) le number($current.tstamp) and number(@tstamp2) gt number($current.tstamp)]/descendant-or-self::mei:note"
                    as="node()*"/>
                
                <xsl:choose>
                    <!-- look for this chord only when the tstamp is either important, or all tstamps shall be looked at (according to $harmonize.important.tstamps.only) -->
                    <xsl:when test="$harmonize.important.tstamps.only and not($tstamp.is.important)"/>
                    
                    <!-- interprete harmonies only when there are at least two different pitch names -->
                    <xsl:when test="count(distinct-values($current.notes//@pname)) gt 1">
                        
                        <!-- here we have the sequence of harm interpretations, which are constantly revised for different aspects -->
                        
                        <harm xmlns="http://www.music-encoding.org/ns/mei" type="analysis.result" tstamp="{$current.tstamp}" staff="{count($this.measure/mei:staff)}" place="below">
                            
                                
                            <!-- this is the first, plain harm interpretation (purely stack of thirds) -->
                            <xsl:variable name="plain.thirds" select="tools:generateStackOfThirds($current.notes, $tstamp.is.important, true())" as="node()+"/>
                            
                            <!-- simplifications start here -->
                            
                            <!-- identify suspensions -->
                            <xsl:variable name="identified.suspensions" as="node()*">
                                <xsl:apply-templates select="$plain.thirds" mode="resolve.suspensions">
                                    <xsl:with-param name="notes" select="$current.notes" tunnel="yes" as="node()+"/>
                                </xsl:apply-templates>
                            </xsl:variable>
                            
                            <!-- identify retardations -->
                            <xsl:variable name="identified.retardations" as="node()*">
                                <xsl:apply-templates select="$identified.suspensions" mode="resolve.retardations">
                                    <xsl:with-param name="notes" select="$current.notes" tunnel="yes" as="node()+"/>
                                </xsl:apply-templates>
                            </xsl:variable>
                            
                            <!-- identify passing tones -->
                            <xsl:variable name="identified.passingtones" as="node()*">
                                <xsl:apply-templates select="$identified.retardations" mode="resolve.passingtones">
                                    <xsl:with-param name="notes" select="$current.notes" tunnel="yes" as="node()+"/>
                                </xsl:apply-templates>
                            </xsl:variable>
                            
                            <!-- identify neighbors -->
                            <xsl:variable name="identified.neighbors" as="node()*">
                                <xsl:apply-templates select="$identified.passingtones" mode="resolve.neighbors">
                                    <xsl:with-param name="notes" select="$current.notes" tunnel="yes" as="node()+"/>
                                </xsl:apply-templates>
                            </xsl:variable>
                            
                            <!-- simplifications finished -->
                            
                            <!-- determine "cheapest" interpretations after all suspensions etc. are found -->
                            <xsl:variable name="least.base.costs" 
                                select="$identified.neighbors/descendant-or-self::mei:chordDef[max(.//@temp:cost/number(.)) = min($identified.neighbors/descendant-or-self::mei:chordDef/max(.//@temp:cost/number(.)))]"
                                as="node()+"/>
                            
                            <!-- prefer interpretations with longer root notes -->
                            <xsl:variable name="best.root.dur"
                                select="$least.base.costs/descendant-or-self::mei:chordDef[number(mei:chordMember[@inth='P1']/@temp:dur) = max($least.base.costs/descendant-or-self::mei:chordDef/mei:chordMember[@inth='P1']/number(@temp:dur))]"
                                as="node()+"/>
                            
                            <!-- this is the most likely interpretation of the current chord -->
                            <xsl:variable name="best.explanations" select="$best.root.dur" as="node()+"/>
                            
                            <!-- output the best explanation -->
                            <xsl:choose>
                                <xsl:when test="count($best.explanations) gt 1">
                                    <choice>
                                        <xsl:for-each select="$best.explanations">
                                            <reg type="best.explanation">
                                                <xsl:sequence select="."/>
                                            </reg>
                                        </xsl:for-each>
                                    </choice>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="$best.explanations"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <!-- instead of outputting as chordDefs, translate to formatted strings inside harm -->
                            <xsl:choose>
                                <xsl:when test="count($best.explanations) gt 1">
                                    <choice>
                                        <xsl:for-each select="$best.explanations">
                                            <reg type="best.explanation">
                                                <xsl:apply-templates select="." mode="verbalize.chordDefs"/>
                                            </reg>
                                        </xsl:for-each>
                                    </choice>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$best.explanations" mode="verbalize.chordDefs"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </harm>
                        
                    </xsl:when>
                </xsl:choose>
                
            </xsl:for-each>
        </xsl:variable>
        
        <!-- todo:problem here is that this might be dependent on a sequence of harms
            – maybe we should do that earlier in the pipe -->
        <!--<xsl:variable name="resolved.duplicate.harms" as="node()">
            <xsl:apply-templates select="$harms" mode="resolve.duplicate.harms"/>
        </xsl:variable>-->
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:sequence select="$harms"/>
        </xsl:copy>
        
    </xsl:template>
    
    
    <xsl:template match="mei:note" mode="insert.harmonies">
        <xsl:param name="unarpeggable.ids" tunnel="yes" as="xs:string*"/>
        
        <xsl:choose>
            <xsl:when test="@xml:id = $unarpeggable.ids">
                <xsl:copy>
                    <xsl:apply-templates select="@* except @type" mode="#current"/>
                    <xsl:attribute name="type" select="'Arpeg' || (if(@type) then(' ' || @type) else())"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>