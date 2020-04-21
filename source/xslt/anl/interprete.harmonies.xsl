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
    <xsl:include href="harmonies/verbalize.chordDefs.xsl"/>
    
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
            
            <!-- we need to extract the scoreDef here, because it's not reachable in the following mode anymore -->
            <xsl:variable name="section" select="(ancestor::mei:section | ancestor::mei:ending)[1]" as="node()"/>
            
            <xsl:variable name="relevant.scoreDef" as="node()">
                <xsl:choose>
                    <xsl:when test="$section/child::mei:scoreDef[@key.sig][count(preceding-sibling::mei:*[not(local-name() = 'annot')]) = 0]">
                        <xsl:sequence select="$section/child::mei:scoreDef[@key.sig][count(preceding-sibling::mei:*[not(local-name() = 'annot')]) = 0]"/>
                    </xsl:when>
                    <xsl:when test="$section/preceding-sibling::mei:*[(local-name() = 'scoreDef' and @key.sig) or (local-name() = ('section','ending') and child::mei:scoreDef[@key.sig])]">
                        <xsl:sequence select="$section/preceding-sibling::mei:*[(local-name() = 'scoreDef' and @key.sig) or (local-name() = ('section','ending') and child::mei:scoreDef[@key.sig])][1]/descendant-or-self::mei:scoreDef[@key.sig][1]"/>
                    </xsl:when>
                    <xsl:when test="$section/ancestor-or-self::mei:*[local-name() = ('section','ending')]/preceding-sibling::mei:scoreDef[@key.sig]">
                        <xsl:sequence select="$section/ancestor-or-self::mei:*[local-name() = ('section','ending')]/preceding-sibling::mei:scoreDef[@key.sig][1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="'ERROR: Unable to find scoreDef at ' || ($section/descendant-or-self::mei:*[@xml:id])[1]/@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:apply-templates select="$inherited.tstamps" mode="resolve.transposing.instruments">
                <xsl:with-param name="relevant.scoreDef" select="$relevant.scoreDef" tunnel="yes" as="node()"/>
            </xsl:apply-templates>
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
        <xsl:variable name="harms.all.chordMembers" as="node()*">
            <xsl:for-each select="$tstamps">
                <xsl:variable name="current.tstamp" select="." as="xs:string"/>
                
                <!-- all notes that are sounding at the current tstamp, no matter when they start or stop -->
                <xsl:variable name="current.notes"
                    select="$events[number(@tstamp) le number($current.tstamp) and number(@tstamp2) gt number($current.tstamp)]/descendant-or-self::mei:note"
                    as="node()*"/>
                
                <xsl:variable name="distinct.pnames" select="distinct-values(for $note in $current.notes/descendant-or-self::mei:note[@pname] return (if($note/@pname.ges) then($note/@pname.ges) else($note/@pname)))" as="xs:string*"/>
                
                <xsl:variable name="distinct.pclasses" select="distinct-values(for $note in $current.notes/descendant-or-self::mei:note[@pclass] return($note/(xs:integer(@pclass) mod 12)))" as="xs:integer+"/>
                
                <!-- interprete harmonies only when there are at least two different pitch names -->
                <xsl:if test="count($distinct.pnames) gt 1 and count($distinct.pclasses) gt 1">
                    <!-- here we have the sequence of harm interpretations, which are constantly revised for different aspects -->
                    <harm xmlns="http://www.music-encoding.org/ns/mei" type="analysis.result" tstamp="{$current.tstamp}" staff="{count($this.measure/mei:staff)}" place="below">
                        
                        <!-- decide whether this is on an "important" tstamp -->
                        <xsl:variable name="tstamp.is.important" select="tools:isAccented($current.tstamp, $meter.count, $meter.unit)" 
                            as="xs:boolean"/>
                        
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
                        
                        <!-- identify passing tones and neighbor tones -->
                        <!--toDo: Übergangslösung; durchgangstöne reparieren-->
                        <xsl:variable name="identified.passingtones.neighbors" as="node()*">
                            <xsl:sequence select="$identified.retardations"/>
                            <!--<xsl:apply-templates select="$identified.retardations" mode="resolve.passingtones.neighbors">
                                <xsl:with-param name="notes" select="$current.notes" tunnel="yes" as="node()+"/>
                            </xsl:apply-templates>-->
                        </xsl:variable>
                        
                        
                        <!-- simplifications finished -->
                        
                        <!-- determine "cheapest" interpretations after all suspensions etc. are found -->
                        <xsl:variable name="least.base.costs" 
                            select="$identified.passingtones.neighbors/descendant-or-self::mei:chordDef[max(.//@temp:cost/number(.)) = min($identified.passingtones.neighbors/descendant-or-self::mei:chordDef/max(.//@temp:cost/number(.)))]"
                            as="node()+"/>
                        
                        <!-- prefer interpretations with longer root notes -->
                        <xsl:variable name="best.root.dur"
                            select="$least.base.costs/descendant-or-self::mei:chordDef[number(mei:chordMember[@inth='P1']/@temp:dur) = max($least.base.costs/descendant-or-self::mei:chordDef/mei:chordMember[@inth='P1']/number(@temp:dur))]"
                            as="node()+"/>
                        
                        <!-- this is the most likely interpretation of the current chord -->
                        <xsl:variable name="best.explanations" select="$best.root.dur" as="node()+"/>
                        
                        <!-- output the best explanation(s) -->
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
                        
                    </harm>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="output.harms" as="node()*">
            <xsl:for-each select="$harms.all.chordMembers">
                <xsl:variable name="current.tstamp" select="@tstamp" as="xs:string"/>
                
                <!-- decide whether this is on an "important" tstamp -->
                <xsl:variable name="tstamp.is.important" select="tools:isAccented($current.tstamp, $meter.count, $meter.unit)" 
                    as="xs:boolean"/>
                
                <xsl:choose>
                    <!-- look for this chord only when the tstamp is either important, or all tstamps shall be looked at (according to $harmonize.important.tstamps.only) -->
                    <xsl:when test="$harmonize.important.tstamps.only and not($tstamp.is.important)"/>
                    
                    <!-- interprete harmonies only when there are at least two different pitch names -->
                    <xsl:otherwise>
                        
                        <!-- select output format -->
                        <xsl:choose>
                            <xsl:when test="$harmonize.output = 'harm.thirds-based-chords.label.plain'">
                                <!-- output the best explanation(s) as plain label for thirds-based chords (default) -->
                                <xsl:copy>
                                    <xsl:apply-templates select="node() | @*" mode="verbalize.chordDefs.thirds-based-chords.plain"/>
                                </xsl:copy>                                                                    
                            </xsl:when>
                            <xsl:when test="$harmonize.output = 'harm.thirds-based-chords.chordDef'">
                                <!-- output the best explanation(s) -->
                                <xsl:copy-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- output the best explanation(s) as plain label for thirds-based chords (default) -->
                                <xsl:copy>
                                    <xsl:apply-templates select="node() | @*" mode="verbalize.chordDefs.thirds-based-chords.plain"/>
                                </xsl:copy>   
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- todo:problem here is that this might be dependent on a sequence of harms
            – maybe we should do that earlier in the pipe -->
        <xsl:variable name="resolved.duplicate.harms" as="node()*">
            <xsl:choose>
                <!-- when chordDef is chosen as parameter, output output.harms without restriction -->
                <xsl:when test="$harmonize.output = 'harm.thirds-based-chords.chordDef'">
                    <xsl:sequence select="$output.harms"/>
                </xsl:when>
                
                <xsl:when test="$harmonize.suppress.duplicates">
                    
                    <xsl:sequence select="$output.harms[mei:rend][1]"/>
                    <xsl:for-each select="(2 to count($output.harms[mei:rend]))">
                        <xsl:variable name="i" select="." as="xs:integer"/>
                        
                        <xsl:variable name="this.rends" select="$output.harms[mei:rend][$i]/mei:rend/text()" as="xs:string*"/>
                        <xsl:variable name="prev.rends" select="$output.harms[mei:rend][$i -1]/mei:rend/text()" as="xs:string*"/>
                        
                        <xsl:choose>
                            <xsl:when test="not(count($this.rends) = count($prev.rends))">
                                <xsl:sequence select="$output.harms[mei:rend][$i]"/>
                            </xsl:when>
                            <xsl:when test="every $i in (1 to count($this.rends)) satisfies ($this.rends[$i] = $prev.rends[$i])">
                                <!-- do nothing -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$output.harms[mei:rend][$i]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>                            
                </xsl:when>
                <xsl:otherwise>
                    <!-- only consider output harms that have a rend-element (=verbalized harms) -->
                    
                    <xsl:sequence select="$output.harms[mei:rend]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:apply-templates select="$resolved.transposing.instruments/node() | $resolved.transposing.instruments/@*" mode="#current">
                <xsl:with-param name="chordDefs" select="$harms.all.chordMembers" tunnel="yes" as="node()*"/>                    
            </xsl:apply-templates>
            <xsl:sequence select="$resolved.duplicate.harms"/>
        </xsl:copy>
        
    </xsl:template>
    
    <!-- add @inth to notes -->
    <xsl:template match="mei:note" mode="interprete.harmonies">
        <xsl:param name="chordDefs" tunnel="yes" as="node()*"/>
        <xsl:variable name="id" select="@xml:id" as="xs:string"/>
        <xsl:variable name="chordMembers" select="$chordDefs//mei:chordMember[$id = tokenize(replace(normalize-space(@corresp),'#',''),' ')]" as="node()*"/>
        <xsl:variable name="inth" select="$chordMembers/@inth" as="xs:string*"/>
        <xsl:variable name="mfunc" as="xs:string">
            <xsl:variable name="raw" as="xs:string*">
                <xsl:for-each select="$chordMembers">
                    <xsl:variable name="chordMember" select="." as="node()"/>
                    <xsl:choose>
                        <xsl:when test="$chordMember/@type">
                            <xsl:value-of select="$chordMember/@type"/>
                        </xsl:when>
                        <xsl:when test="$chordMember/@inth = ('P1','m3','M3','P5')">
                            <xsl:value-of select="'ct'"/>
                        </xsl:when>
                        <xsl:when test="$chordMember/@inth = ('m7','M7')">
                            <xsl:value-of select="'ct7'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="string-join(distinct-values($raw),' or ')"/>
        </xsl:variable>
        <xsl:copy>
            <!--todo: add @mfunc="arp" to arpeggiated notes-->
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:if test="count($inth) gt 0">
                <xsl:attribute name="inth" select="string-join(distinct-values($inth),' or ')"/>
            </xsl:if>
            <xsl:if test="string-length($mfunc) gt 0">
                <xsl:attribute name="mfunc" select="$mfunc"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>