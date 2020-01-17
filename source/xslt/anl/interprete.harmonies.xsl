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
                        
                        <choice xmlns="http://www.music-encoding.org/ns/mei" type="analysis.result">
                            
                            <!-- this is the first, plain harm interpretation (purely stack of thirds) -->
                            <xsl:variable name="plain.thirds" select="tools:generateStackOfThirds($current.notes, $tstamp.is.important, true())" as="node()+"/>
                            <!--<xsl:for-each select="$plain.thirds">
                                <reg type="plain.thirds">
                                    <xsl:sequence select="."/>
                                </reg>
                            </xsl:for-each>-->
                            
                            <!-- identify suspensions -->
                            <xsl:variable name="identified.suspensions" as="node()*">
                                <xsl:apply-templates select="$plain.thirds"
                                    mode="resolve.suspensions"/>
                            </xsl:variable>
                            
                            <!-- identify retardations -->
                            <xsl:variable name="identified.retardations" as="node()*">
                                <xsl:apply-templates select="$identified.suspensions"
                                    mode="resolve.retardations"/>
                            </xsl:variable>
                            
                            <!-- identify passing tones -->
                            <xsl:variable name="identified.passingtones" as="node()*">
                                <xsl:apply-templates select="$identified.retardations"
                                    mode="resolve.passingtones"/>
                            </xsl:variable>
                            
                            <!-- identify neighbors -->
                            <xsl:variable name="identified.neighbors" as="node()*">
                                <xsl:apply-templates select="$identified.passingtones"
                                    mode="resolve.neighbors"/>
                            </xsl:variable>
                            
                            
---------                            
         
                            <!-- determine final costs after all suspensions etc. are found -->
                            <xsl:variable name="final.costs" as="node()*">
                                <xsl:choose>
                                    <xsl:when test="$allowSimplification">
                                        <xsl:apply-templates select="$identified.neighbors"
                                            mode="determine.chords.final.costs"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="$potential.chords"
                                            mode="determine.chords.final.costs"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            
                            
                            <xsl:variable name="least.base.costs"
                                select="$final.costs/descendant-or-self::temp:chord[number(@highest.cost) = min($final.costs/descendant-or-self::temp:chord/number(@highest.cost))]"
                                as="node()+"/>
                            
                            <xsl:variable name="best.root.dur"
                                select="$least.base.costs/descendant-or-self::temp:chord[number(@root.dur) = max($least.base.costs/descendant-or-self::temp:chord/number(@root.dur))]"
                                as="node()+"/>
                            
                            <xsl:variable name="best.explanation" select="$best.root.dur" as="node()+"/>
                            
                            <xsl:variable name="identified.root.accid" as="node()+">
                                <xsl:apply-templates select="$best.explanation" mode="identify.root.accid"/>
                            </xsl:variable>
                            
                            <xsl:variable name="identified.intervals" as="node()+">
                                <xsl:apply-templates select="$identified.root.accid" mode="identify.intervals"/>
                            </xsl:variable>
                            
                            
                            <xsl:for-each select="$identified.intervals">
                                <xsl:variable name="current.interpretation" select="." as="node()"/>
                                
                                
                                <!--<xsl:variable name="is.mod" select="some $func in $current.interpretation/temp:tone/@func satisfies (.,'[a-z]+')" as="xs:boolean"/>-->
                                <!-- insert chord symbol with additions of sevenths and/or bass tone after a slash (/) if it is not the root note -->
                                <harm type="mfunc" xmlns="http://www.music-encoding.org/ns/mei">
                                    <xsl:choose>
                                        
                                        <!-- compare root-note with bass tone, when they dont have the same pname, copy root note and add a / with the bass tone after that-->
                                        <xsl:when test="substring($current.interpretation/@root,1,1) ne upper-case($current.interpretation/@bass)">
                                            <rend type="root">
                                                <xsl:value-of select="$current.interpretation/@root"/>
                                            </rend>
                                            
                                            <!--hier die Berechnung von Intervallabständen root->7 und root->9 wie unten?-->
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct7')">
                                                <rend rend="sup" type="ct7">7</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct9')">
                                                <rend rend="sup" type="ct9">9</rend>
                                            </xsl:if>
                                            <rend type="bass">
                                                <xsl:value-of select="concat('/', upper-case($current.interpretation/@bass), $current.interpretation/@bass.accid)"/>
                                            </rend>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '43sus')">
                                                <rend type="mod43sus" rend="sup" fontstyle="italic">43sus</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '65sus')">
                                                <rend type="mod65sus" rend="sup" fontstyle="italic">65sus</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '98sus')">
                                                <rend type="mod98sus" rend="sup" fontstyle="italic">98sus</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '23ret')">
                                                <rend type="mod23ret" rend="sup" fontstyle="italic">23ret</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '78ret')">
                                                <rend type="mod78ret" rend="sup" fontstyle="italic">78ret</rend>
                                            </xsl:if>
                                        </xsl:when>
                                        
                                        
                                        <!-- when root note and bass note are of the same pname and accid/accid.ges, just copy root note -->
                                        <xsl:when test="substring($current.interpretation/@root,1,1) eq upper-case($current.interpretation/@bass)">
                                            <xsl:variable name="is.mod" select="matches(., '[a-z]+')" as="xs:boolean"/>
                                            <rend type="root">
                                                <xsl:value-of select="$current.interpretation/@root"/>
                                            </rend>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct7')">
                                                <rend rend="sup" type="ct7">7</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct9')">
                                                <rend rend="sup" type="ct9">9</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '43sus')">
                                                <rend type="mod43sus" rend="sup" fontstyle="italic">43sus</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '65sus')">
                                                <rend type="mod65sus" rend="sup" fontstyle="italic">65sus</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '98sus')">
                                                <rend type="mod98sus" rend="sup" fontstyle="italic">98sus</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '23ret')">
                                                <rend type="mod23ret" rend="sup" fontstyle="italic">23ret</rend>
                                            </xsl:if>
                                            <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq '78ret')">
                                                <rend type="mod78ret" rend="sup" fontstyle="italic">78ret</rend>
                                            </xsl:if>
                                        </xsl:when>
                                    </xsl:choose>
                                    
                                    
                                    <!--<xsl:for-each select="$current.interpretation/temp:tone/@func">
                                <xsl:variable name="is.bass" select=". = $current.interpretation/@bass.index" as="xs:boolean"/>
                                <xsl:variable name="is.mod" select="matches(.,'[a-z]+')" as="xs:boolean"/>
                                <xsl:choose>
                                  <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct7'">
                                    <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
                                  </xsl:when>
                                    <xsl:when test="$is.bass">
                                        <rend type="bass {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="concat('/', upper-case($current.interpretation/@bass))"/></rend>
                                    </xsl:when>
                                  <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct9'">
                                    <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
                                  </xsl:when>
                                  
                                    <xsl:when test="$is.mod">
                                        <rend type="mod {tools:resolveMFuncByNumber(.)}" fontsize="70%" fontstyle="italic"><xsl:value-of select="."/></rend>
                                    </xsl:when>
                            </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                        
                        <!-\- when root note and bass note are of the same pname and accid/accid.ges, just copy root note -\->
                        <xsl:when test="$current.interpretation/@root ne $current.interpretation/@bass">
                            <rend type="root"><xsl:value-of select="$current.interpretation/@root"/></rend> 
                            <xsl:for-each select="$current.interpretation/temp:tone/@func">
                                <xsl:variable name="is.mod" select="matches(.,'[a-z]+')" as="xs:boolean"/>
                                <xsl:choose>
                                    <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct7'">
                                        <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
                                    </xsl:when>
                                    <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct9'">
                                        <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
                                    </xsl:when>
                                    <xsl:when test="$is.mod">
                                        <rend type="mod {tools:resolveMFuncByNumber(.)}" fontsize="70%" fontstyle="italic"><xsl:value-of select="."/></rend>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>-->
                                    
                                    <!--<xsl:for-each select="$current.interpretation/temp:tone/@func">
                    <!-\-<xsl:sort select="xs:integer(substring(.,1,1))" data-type="number" order="ascending"/>-\->
                    <xsl:variable name="is.bass" select=". = $current.interpretation/@bass.index" as="xs:boolean"/>
                    <xsl:variable name="is.mod" select="matches(.,'[a-z]+')" as="xs:boolean"/>
                    <xsl:choose>
                         <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct7'">
                            <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
                        </xsl:when>
                        <xsl:when test="string(tools:resolveMFuncByNumber(.)) eq 'ct9'">
                            <rend rend="sup" type="mod {tools:resolveMFuncByNumber(.)}"><xsl:value-of select="."/></rend>
                        </xsl:when>
                        <xsl:when test="$is.bass and $is.mod">
                            <rend type="bass mod {tools:resolveMFuncByNumber(.)}" fontsize="70%"><xsl:value-of select="."/></rend>
                        </xsl:when>
                        <xsl:when test="$is.bass">
                            <rend type="bass {tools:resolveMFuncByNumber(.)}" fontsize="70%"><xsl:value-of select="."/></rend>
                        </xsl:when>
                        <xsl:when test="$is.mod">
                            <rend type="mod {tools:resolveMFuncByNumber(.)}" fontsize="70%" fontstyle="italic"><xsl:value-of select="."/></rend>
                        </xsl:when>
                           <xsl:otherwise>
                            <rend type="{tools:resolveMFuncByNumber(.)}" fontsize="70%"><xsl:value-of select="."/></rend>
                        </xsl:otherwise>
                    </xsl:choose>   
                </xsl:for-each>-->
                                    <annot type="mfunc.tonelist" cost="{$current.interpretation/@highest.cost}">
                                        <xsl:for-each select="$current.interpretation/temp:tone">
                                            <annot type="{tools:resolveMFuncByNumber(@func)}"
                                                plist="{string-join(.//mei:note/@xml:id,' ')}"/>
                                        </xsl:for-each>
                                    </annot>
                                </harm>
                            </xsl:for-each>
                            
         
---------         
                            
                        </choice>
                            
                        
                        
                        
                    </xsl:when>
                </xsl:choose>
                
            </xsl:for-each>
        </xsl:variable>
        
        
        <xsl:variable name="determined.chords" as="node()">
            <xsl:apply-templates select="$inherited.tstamps" mode="determine.chords"/>
        </xsl:variable>
        
        <xsl:variable name="resolved.duplicate.harms" as="node()">
            <xsl:apply-templates select="$determined.chords" mode="resolve.duplicate.harms"/>
        </xsl:variable>
        
        <harms>
            <xsl:sequence select="$resolved.duplicate.harms//mei:choice[@type = 'harmInterpretation']"/>    
        </harms>
        <resolvedArpegs><xsl:value-of select="string-join($determined.chords//mei:annot[@type='resolvedArpegs']/@plist,' ')"/></resolvedArpegs>
        
        <xsl:variable name="resolvable.arpeg.notes" as="xs:string*" select="tokenize($harms/descendant-or-self::resolvedArpegs/text(),' ')"/>
        <xsl:if test="count($resolvable.arpeg.notes) gt 0">
            <xsl:message select="'we can resolve some notes: ' || count($resolvable.arpeg.notes)"/>
        </xsl:if>
        <xsl:copy>
            <xsl:attribute name="type" select="string-join($local.keys, ' ')"/>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="unarpeggable.ids" select="$resolvable.arpeg.notes" tunnel="yes" as="xs:string*"/>
            </xsl:apply-templates>
            <xsl:sequence select="$harms/descendant-or-self::harms/child::node()"/>
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