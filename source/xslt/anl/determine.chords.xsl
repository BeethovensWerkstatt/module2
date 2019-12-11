<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei tools temp custom" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 21, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:template match="mei:measure" mode="determine.chords">
        <xsl:param name="current.key" tunnel="yes"/>
        <xsl:param name="current.pos" tunnel="yes"/>

        <xsl:variable name="measure" select="." as="node()"/>

        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:variable name="resolved.transpositions" as="node()*">
                <xsl:apply-templates select="mei:staff" mode="resolve.transposing.instruments"/>
            </xsl:variable>
            <xsl:variable name="resolved.arpeggios" as="node()*">
                <xsl:apply-templates select="$resolved.transpositions" mode="resolve.arpeggios"/>
            </xsl:variable>

            <xsl:if test="$resolved.arpeggios//mei:chord[@type = 'resolved.arpeggio']">
                <!-- debug -->
                <!--<xsl:message select="'[INFO] resolved an arpeggio in measure ' || @n || ' in staves ' || string-join($resolved.arpeggios/descendant-or-self::mei:staff[.//mei:chord[@type='resolved.arpeggio']]/@n,', ')"/>-->
                <!--<xsl:message select="'    IDs affected: ' || string-join($resolved.arpeggios//mei:chord[@type='resolved.arpeggio']//mei:note/@xml:id,', ')"/>-->
                <annot xmlns="http://www.music-encoding.org/ns/mei" type="resolvedArpegs"
                    plist="{string-join($resolved.arpeggios//mei:chord[@type='resolved.arpeggio']//mei:note/@xml:id,' ')}"
                />
            </xsl:if>

            <xsl:variable name="events"
                select="$resolved.arpeggios//mei:layer//mei:*[@tstamp and @tstamp2 and local-name() = ('note', 'chord')]"
                as="node()*"/>
            <xsl:variable name="tstamps"
                select="distinct-values($resolved.arpeggios//mei:layer//@tstamp)" as="xs:string*"/>

            <xsl:for-each select="$tstamps">
                <xsl:sort select="." data-type="number"/>
                <xsl:variable name="current.tstamp" select="." as="xs:string"/>
                <xsl:variable name="current.notes"
                    select="$events[number(@tstamp) le number($current.tstamp) and number(@tstamp2) gt number($current.tstamp)]/descendant-or-self::mei:note"
                    as="node()*"/>

                <xsl:variable name="is.accented"
                    select="tools:isAccented($current.tstamp, $measure/@meter.count, $measure/@meter.unit)"
                    as="xs:boolean"/>

                <xsl:if test="count(distinct-values($current.notes//@pname)) gt 1">
                    <xsl:variable name="harm"
                        select="tools:interpreteChord($current.notes, $is.accented, true())"
                        as="node()+"/>
                    <choice type="harmInterpretation"
                        measure="{count($measure/preceding::mei:measure)}" key="{$current.key}"
                        tstamp="{$current.tstamp}" xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:for-each select="$harm">

                            <xsl:copy>
                                <xsl:attribute name="xml:id" select="generate-id(.)"/>
                                <xsl:attribute name="tstamp" select="$current.tstamp"/>
                                <xsl:attribute name="n" select="$current.pos"/>
                                <xsl:attribute name="staff"
                                    select="max($measure/mei:staff/number(@n))"/>
                                <xsl:attribute name="place" select="'below'"/>
                                <xsl:apply-templates select="node() | @*" mode="#current"/>
                            </xsl:copy>

                        </xsl:for-each>
                    </choice>
                </xsl:if>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="tools:interpreteChord" as="node()+">
        <xsl:param name="notes" as="node()+"/>
        <xsl:param name="isAccented" as="xs:boolean"/>
        <xsl:param name="allowSimplification" as="xs:boolean"/>

        <!-- static: how many thirds does it take to get somewhere -->
        <xsl:variable name="third.rows" as="node()+">
            <temp:row pname="c" c="0" d="4" e="1" f="5" g="2" a="6" b="3"/>
            <temp:row pname="d" c="3" d="0" e="4" f="1" g="5" a="2" b="6"/>
            <temp:row pname="e" c="6" d="3" e="0" f="4" g="1" a="5" b="2"/>
            <temp:row pname="f" c="2" d="6" e="3" f="0" g="4" a="1" b="5"/>
            <temp:row pname="g" c="5" d="2" e="6" f="3" g="0" a="4" b="1"/>
            <temp:row pname="a" c="1" d="5" e="2" f="6" g="3" a="0" b="4"/>
            <temp:row pname="b" c="4" d="1" e="5" f="2" g="6" a="3" b="0"/>
        </xsl:variable>

        <xsl:variable name="pnames" select="distinct-values($notes//@pname)" as="xs:string+"/>

        <xsl:variable name="potential.chords" as="node()*">

            <xsl:variable name="bass.tone" as="xs:string">
                <xsl:variable name="pnames.indizes" select="('c', 'd', 'e', 'f', 'g', 'a', 'b')"
                    as="xs:string+"/>
                <xsl:variable name="lowest.octave.notes"
                    select="$notes[@oct = string(min($notes/number(@oct)))]" as="node()+"/>
                <xsl:variable name="lowest.note"
                    select="$pnames.indizes[min(for $note in $lowest.octave.notes return (index-of($pnames.indizes, $note/@pname)))]"
                    as="xs:string"/>
                <xsl:value-of select="$lowest.note"/>
            </xsl:variable>

            <xsl:for-each select="$pnames">
                <xsl:variable name="current.pname" select="." as="xs:string"/>
                <xsl:variable name="current.row"
                    select="$third.rows/descendant-or-self::temp:row[@pname = $current.pname]"
                    as="node()"/>

                <xsl:variable name="notes" as="node()+">
                    <temp:tone func="1" cost="0" name="root">
                        <xsl:sequence
                            select="$notes[.//@pname = $current.row/@*[. = '0']/local-name()]"/>
                    </temp:tone>
                    <xsl:if test="$current.row/@*[. = '3']/local-name() = $pnames">
                        <temp:tone func="7" cost="3" name="seventh">
                            <xsl:sequence
                                select="$notes[.//@pname = $current.row/@*[. = '3']/local-name()]"/>
                        </temp:tone>
                    </xsl:if>
                    <xsl:if test="$current.row/@*[. = '1']/local-name() = $pnames">
                        <temp:tone func="3" cost="1" name="third">
                            <xsl:sequence
                                select="$notes[.//@pname = $current.row/@*[. = '1']/local-name()]"/>
                        </temp:tone>
                    </xsl:if>
                    <xsl:if test="$current.row/@*[. = '2']/local-name() = $pnames">
                        <temp:tone func="5" cost="2" name="fifth">
                            <xsl:sequence
                                select="$notes[.//@pname = $current.row/@*[. = '2']/local-name()]"/>
                        </temp:tone>
                    </xsl:if>
                    <xsl:if test="$current.row/@*[. = '4']/local-name() = $pnames">
                        <temp:tone func="9" cost="4" name="ninth">
                            <xsl:sequence
                                select="$notes[.//@pname = $current.row/@*[. = '4']/local-name()]"/>
                        </temp:tone>
                    </xsl:if>
                    <xsl:if test="$current.row/@*[. = '5']/local-name() = $pnames">
                        <temp:tone func="11" cost="5" name="eleventh">
                            <xsl:sequence
                                select="$notes[.//@pname = $current.row/@*[. = '5']/local-name()]"/>
                        </temp:tone>
                    </xsl:if>
                    <xsl:if test="$current.row/@*[. = '6']/local-name() = $pnames">
                        <temp:tone func="13" cost="6" name="thirteenth">
                            <xsl:sequence
                                select="$notes[.//@pname = $current.row/@*[. = '6']/local-name()]"/>
                        </temp:tone>
                    </xsl:if>
                </xsl:variable>

                <xsl:variable name="inversion"
                    select="xs:integer($current.row/@*[local-name() = $bass.tone])" as="xs:integer"/>
                <xsl:variable name="root.dur"
                    select="max($notes[.//@pname = $current.row/@*[. = '0']/local-name()]/(max(.//@tstamp2/number(.)) - min(.//@tstamp/number(.))))"
                    as="xs:double?"/>
                <xsl:variable name="bass.accid" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$notes//mei:note[@pname = $bass.tone]//mei:accid/@accid.ges">
                            <xsl:value-of select="$notes//mei:note[@pname = $bass.tone]//mei:accid/@accid.ges"/>
                        </xsl:when>
                        <xsl:when test="$notes//mei:note[@pname = $bass.tone]//mei:accid/@accid">
                            <xsl:value-of select="$notes//mei:note[@pname = $bass.tone]//mei:accid/@accid"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'n'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <temp:chord root="{$current.pname}" bass="{$bass.tone}" bass.accid="{$bass.accid}"
                    bass.index="{$notes//mei:note[@pname = $bass.tone]/ancestor::temp:tone/@func}"
                    inversion="{$inversion}" accented.tstamp="{string($isAccented)}"
                    highest.cost="{max($notes/xs:integer(@cost))}" root.dur="{$root.dur}">
                    <xsl:sequence select="$notes"/>
                </temp:chord>

            </xsl:for-each>
        </xsl:variable>

        <!-- identify suspensions -->
        <xsl:variable name="identified.suspensions" as="node()*">
            <xsl:apply-templates select="$potential.chords"
                mode="determine.chords.identify.suspensions"/>
        </xsl:variable>

        <!-- identify retardations -->
        <xsl:variable name="identified.retardations" as="node()*">
            <xsl:apply-templates select="$identified.suspensions"
                mode="determine.chords.identify.retardations"/>
        </xsl:variable>

        <!-- identify passing tones -->
        <xsl:variable name="identified.passingtones" as="node()*">
            <xsl:apply-templates select="$identified.retardations"
                mode="determine.chords.identify.passingtones"/>
        </xsl:variable>

        <!-- identify neighbors -->
        <xsl:variable name="identified.neighbors" as="node()*">
            <xsl:apply-templates select="$identified.passingtones"
                mode="determine.chords.identify.neighbors"/>
        </xsl:variable>

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
                        <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct7')">
                            <rend rend="sup" type="ct7">7</rend>
                        </xsl:if>
                        <xsl:if test="some $func in $current.interpretation/temp:tone/@func satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct9')">
                            <rend rend="sup" type="ct9">9</rend>
                        </xsl:if>
                        <rend type="bass">
                            <xsl:value-of select="concat('/', upper-case($current.interpretation/@bass))"/>
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
                        <xsl:if
                            test="
                                some $func in $current.interpretation/temp:tone/@func
                                    satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct7')">
                            <rend rend="sup" type="ct7">7</rend>
                        </xsl:if>
                        <xsl:if
                            test="
                                some $func in $current.interpretation/temp:tone/@func
                                    satisfies (string(tools:resolveMFuncByNumber($func)) eq 'ct9')">
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

    </xsl:function>

    <xsl:function name="tools:resolveMFuncByNumber" as="xs:string">
        <xsl:param name="number" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="$number = '1'">
                <xsl:value-of select="'ct ct1'"/>
            </xsl:when>
            <xsl:when test="$number = '3'">
                <xsl:value-of select="'ct ct3'"/>
            </xsl:when>
            <xsl:when test="$number = '5'">
                <xsl:value-of select="'ct ct5'"/>
            </xsl:when>
            <xsl:when test="$number = '7'">
                <xsl:value-of select="'ct7'"/>
            </xsl:when>
            <xsl:when test="$number = '9'">
                <xsl:value-of select="'ct9'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$number"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- MODE determine.chords.identify.suspensions -->

    <!-- Quartvorhalt / 43suspension -->
    <xsl:template match="temp:tone[@cost = '5']" mode="determine.chords.identify.suspensions">
        <!-- a @cost of 5 is a quarter above the root, it could be suspended to an effective cost of 1 -->
        <xsl:variable name="comes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\-[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\-[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="fourth.durations"
            select="
                for $note in .//mei:note
                return
                    (number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))"
            as="xs:double+"/>

        <xsl:variable name="root.notes" select="parent::temp:chord/temp:tone[@cost = '0']/mei:note"
            as="node()*"/>
        <xsl:variable name="fifth.notes" select="parent::temp:chord/temp:tone[@cost = '2']/mei:note"
            as="node()*"/>

        <xsl:variable name="root.longer.dur"
            select="
                some $note in $root.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($fourth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="root.continued"
            select="
                some $note in $root.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="fifth.longer.dur"
            select="
                some $note in $fifth.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($fourth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="fifth.continued"
            select="
                some $note in $fifth.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>

        <xsl:variable name="is.accented" select="xs:boolean(parent::temp:chord/@accented.tstamp)"
            as="xs:boolean"/>

        <xsl:variable name="test.id" select="''" as="xs:string"/>
        <xsl:if test="$test.id != '' and $test.id = .//mei:note/@xml:id">
            <xsl:message select="'testing for 43sus at ' || $test.id"/>
            <xsl:message
                select="'    $comes.down: ' || $comes.down || ', $goes.down: ' || $goes.down || ', $is.accented: ' || $is.accented"/>
            <xsl:message
                select="'    $root.notes: ' || count($root.notes) || ', $fifth.notes: ' || count($fifth.notes)"/>
            <xsl:message
                select="'    $root.longer.dur: ' || $root.longer.dur || ', $root.continued: ' || $root.continued"/>
            <xsl:message
                select="'    $fifth.longer.dur: ' || $fifth.longer.dur || ', $fifth.continued: ' || $fifth.continued"
            />
        </xsl:if>

        <xsl:choose>
            <xsl:when
                test="
                    ($is.accented)
                    and ($comes.down or true())
                    and $goes.down
                    and ($root.longer.dur or $root.continued)
                    and ($fifth.longer.dur or $fifth.continued or true())">
                <!-- ignoring fifths duration for now -->
                <!--<xsl:message select="'[DETERMINE.CHORDS] Found a 43sus on note ' || string-join(.//mei:note/@xml:id,', ')"/>-->
                <temp:tone func="43sus" cost="1" name="Quartvorhalt">
                    <xsl:for-each select=".//mei:note">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="mfunc" select="'43sus'"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:for-each>
                </temp:tone>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Sextvorhalt | 65suspension -->
    <xsl:template match="temp:tone[@cost = '6']" mode="determine.chords.identify.suspensions">
        <!-- a @cost of 6 is a sixth above the root, it could be suspended to an effective cost of 2 -->
        <xsl:variable name="comes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\-[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\-[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="sixth.durations"
            select="
                for $note in .//mei:note
                return
                    (number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))"
            as="xs:double+"/>

        <xsl:variable name="root.notes" select="parent::temp:chord/temp:tone[@cost = '0']/mei:note"
            as="node()*"/>
        <xsl:variable name="third.notes" select="parent::temp:chord/temp:tone[@cost = '1']/mei:note"
            as="node()*"/>

        <xsl:variable name="root.longer.dur"
            select="
                some $note in $root.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($sixth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="root.continued"
            select="
                some $note in $root.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="third.longer.dur"
            select="
                some $note in $third.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($sixth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="third.continued"
            select="
                some $note in $third.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>

        <xsl:variable name="is.accented" select="xs:boolean(parent::temp:chord/@accented.tstamp)"
            as="xs:boolean"/>

        <!-- kitzler_061_m-90 -->
        <xsl:variable name="test.id" select="''" as="xs:string"/>
        <xsl:if test="$test.id != '' and $test.id = .//mei:note/@xml:id">
            <xsl:message select="'testing for 65sus at ' || $test.id"/>
            <xsl:message
                select="'    $comes.down: ' || $comes.down || ', $goes.down: ' || $goes.down || ', $is.accented: ' || $is.accented"/>
            <xsl:message
                select="'    $root.notes: ' || count($root.notes) || ', $third.notes: ' || count($third.notes)"/>
            <xsl:message
                select="'    $root.longer.dur: ' || $root.longer.dur || ', $root.continued: ' || $root.continued"/>
            <xsl:message
                select="'    $third.longer.dur: ' || $third.longer.dur || ', $third.continued: ' || $third.continued"
            />
        </xsl:if>

        <xsl:choose>
            <xsl:when
                test="
                    ($is.accented)
                    and $goes.down
                    and ($root.longer.dur or $root.continued or true())
                    and ($third.longer.dur or $third.continued or true())">
                <!-- ignoring thirds duration for now -->
                <!--<xsl:message select="'[DETERMINE.CHORDS] Found a 65sus on note ' || string-join(.//mei:note/@xml:id,', ')"/>-->
                <temp:tone func="65sus" cost="2" name="Sextvorhalt">
                    <xsl:for-each select=".//mei:note">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="mfunc" select="'65sus'"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:for-each>
                </temp:tone>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Nonvorhalt | 98suspension -->
    <xsl:template match="temp:tone[@cost = '4']" mode="determine.chords.identify.suspensions">
        <!-- a @cost of 4 is a ninth above the root, it could be suspended to an effective cost of 0 (octave) -->
        <xsl:variable name="comes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\-[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\-[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="ninth.durations"
            select="
                for $note in .//mei:note
                return
                    (number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))"
            as="xs:double+"/>

        <xsl:variable name="root.notes" select="parent::temp:chord/temp:tone[@cost = '0']/mei:note"
            as="node()*"/>
        <xsl:variable name="third.notes" select="parent::temp:chord/temp:tone[@cost = '1']/mei:note"
            as="node()*"/>

        <xsl:variable name="root.longer.dur"
            select="
                some $note in $root.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($ninth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="root.continued"
            select="
                some $note in $root.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="third.longer.dur"
            select="
                some $note in $third.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($ninth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="third.continued"
            select="
                some $note in $third.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>

        <xsl:variable name="is.accented" select="xs:boolean(parent::temp:chord/@accented.tstamp)"
            as="xs:boolean"/>

        <!-- kitzler_061_m-90 -->
        <xsl:variable name="test.id" select="''" as="xs:string"/>
        <xsl:if test="$test.id != '' and $test.id = .//mei:note/@xml:id">
            <xsl:message select="'testing for 98sus at ' || $test.id"/>
            <xsl:message
                select="'    $comes.down: ' || $comes.down || ', $goes.down: ' || $goes.down || ', $is.accented: ' || $is.accented"/>
            <xsl:message
                select="'    $root.notes: ' || count($root.notes) || ', $third.notes: ' || count($third.notes)"/>
            <xsl:message
                select="'    $root.longer.dur: ' || $root.longer.dur || ', $root.continued: ' || $root.continued"/>
            <xsl:message
                select="'    $third.longer.dur: ' || $third.longer.dur || ', $third.continued: ' || $third.continued"
            />
        </xsl:if>

        <xsl:choose>
            <xsl:when
                test="
                    ($is.accented)
                    and $goes.down
                    and ($root.longer.dur or $root.continued or true())
                    and ($third.longer.dur or $third.continued or true())">
                <!-- ignoring thirds duration for now -->
                <!--<xsl:message select="'[DETERMINE.CHORDS] Found a 98sus on note ' || string-join(.//mei:note/@xml:id,', ')"/>-->
                <temp:tone func="98sus" cost="0" name="Nonvorhalt">
                    <xsl:for-each select=".//mei:note">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="mfunc" select="'98sus'"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:for-each>
                </temp:tone>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 23Vorhalt | 23retardation -->
    <!--Problem: 2 ist wie die None cost=4-->
    <xsl:template match="temp:tone[@cost = '4']" mode="determine.chords.identify.retardations">
        <!-- a @cost of 4 is a major/minor2(?) above the root, it could be suspended to an effective cost of 1 (third) -->
        <xsl:variable name="comes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\-[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\-[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="goes.up"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\+[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="second.durations"
            select="
                for $note in .//mei:note
                return
                    (number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))"
            as="xs:double+"/>

        <xsl:variable name="root.notes" select="parent::temp:chord/temp:tone[@cost = '0']/mei:note"
            as="node()*"/>
        <xsl:variable name="third.notes" select="parent::temp:chord/temp:tone[@cost = '1']/mei:note"
            as="node()*"/>

        <xsl:variable name="root.longer.dur"
            select="
                some $note in $root.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($second.durations)"
            as="xs:boolean"/>
        <xsl:variable name="root.continued"
            select="
                some $note in $root.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="third.longer.dur"
            select="
                some $note in $third.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($second.durations)"
            as="xs:boolean"/>
        <xsl:variable name="third.continued"
            select="
                some $note in $third.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>

        <xsl:variable name="is.accented" select="xs:boolean(parent::temp:chord/@accented.tstamp)"
            as="xs:boolean"/>

        <!-- kitzler_061_m-90 -->
        <xsl:variable name="test.id" select="''" as="xs:string"/>
        <xsl:if test="$test.id != '' and $test.id = .//mei:note/@xml:id">
            <xsl:message select="'testing for 98sus at ' || $test.id"/>
            <xsl:message
                select="'    $comes.down: ' || $comes.down || ', $goes.down: ' || $goes.down || ', $is.accented: ' || $is.accented"/>
            <xsl:message
                select="'    $root.notes: ' || count($root.notes) || ', $third.notes: ' || count($third.notes)"/>
            <xsl:message
                select="'    $root.longer.dur: ' || $root.longer.dur || ', $root.continued: ' || $root.continued"/>
            <xsl:message
                select="'    $third.longer.dur: ' || $third.longer.dur || ', $third.continued: ' || $third.continued"
            />
        </xsl:if>

        <xsl:choose>
            <xsl:when
                test="
                    ($is.accented)
                    and $goes.up
                    and ($root.longer.dur or $root.continued or true())
                    and ($third.longer.dur or $third.continued or true())">
                <!-- ignoring thirds duration for now -->
                <!--<xsl:message select="'[DETERMINE.CHORDS] Found a 23ret on note ' || string-join(.//mei:note/@xml:id,', ')"/>-->
                <temp:tone func="23ret" cost="1" name="Sekundvorhalt">
                    <xsl:for-each select=".//mei:note">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="mfunc" select="'23ret'"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:for-each>
                </temp:tone>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 78Vorhalt | 78retardation -->
    <xsl:template match="temp:tone[@cost = '3']" mode="determine.chords.identify.retardations">
        <!-- a @cost of 3 is a seventh above the root, it could be suspended to an effective cost of 0 (ocatve) -->
        <xsl:variable name="comes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\-[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\-[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="goes.up"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\+[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="seventh.durations"
            select="
                for $note in .//mei:note
                return
                    (number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))"
            as="xs:double+"/>

        <xsl:variable name="root.notes" select="parent::temp:chord/temp:tone[@cost = '0']/mei:note"
            as="node()*"/>
        <xsl:variable name="third.notes" select="parent::temp:chord/temp:tone[@cost = '1']/mei:note"
            as="node()*"/>

        <xsl:variable name="root.longer.dur"
            select="
                some $note in $root.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($seventh.durations)"
            as="xs:boolean"/>
        <xsl:variable name="root.continued"
            select="
                some $note in $root.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="third.longer.dur"
            select="
                some $note in $third.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($seventh.durations)"
            as="xs:boolean"/>
        <xsl:variable name="third.continued"
            select="
                some $note in $third.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>

        <xsl:variable name="is.accented" select="xs:boolean(parent::temp:chord/@accented.tstamp)"
            as="xs:boolean"/>

        <!-- kitzler_061_m-90 -->
        <xsl:variable name="test.id" select="''" as="xs:string"/>
        <xsl:if test="$test.id != '' and $test.id = .//mei:note/@xml:id">
            <xsl:message select="'testing for 98sus at ' || $test.id"/>
            <xsl:message
                select="'    $comes.down: ' || $comes.down || ', $goes.down: ' || $goes.down || ', $is.accented: ' || $is.accented"/>
            <xsl:message
                select="'    $root.notes: ' || count($root.notes) || ', $third.notes: ' || count($third.notes)"/>
            <xsl:message
                select="'    $root.longer.dur: ' || $root.longer.dur || ', $root.continued: ' || $root.continued"/>
            <xsl:message
                select="'    $third.longer.dur: ' || $third.longer.dur || ', $third.continued: ' || $third.continued"
            />
        </xsl:if>

        <xsl:choose>
            <xsl:when
                test="
                    ($is.accented)
                    and $goes.up
                    and ($root.longer.dur or $root.continued or true())
                    and ($third.longer.dur or $third.continued or true())">
                <!-- ignoring thirds duration for now -->
                <!--<xsl:message select="'[DETERMINE.CHORDS] Found a 78ret on note ' || string-join(.//mei:note/@xml:id,', ')"/>-->
                <temp:tone func="78ret" cost="0" name="Septimvorhalt">
                    <xsl:for-each select=".//mei:note">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="mfunc" select="'78ret'"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:for-each>
                </temp:tone>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Durchgangsnote / upt -->
    <xsl:template match="temp:tone[@cost = ('4', '5', '6')]"
        mode="determine.chords.identify.passingtones">
        <!-- a @cost of 5 is a quarter above the root, it could be suspended to an effective cost of 1 -->
        <xsl:variable name="comes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\-[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\-[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="comes.up"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\+[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.up"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\+[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="fourth.durations"
            select="
                for $note in .//mei:note
                return
                    (number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))"
            as="xs:double+"/>

        <xsl:variable name="root.notes" select="parent::temp:chord/temp:tone[@cost = '0']/mei:note"
            as="node()*"/>
        <xsl:variable name="fifth.notes" select="parent::temp:chord/temp:tone[@cost = '2']/mei:note"
            as="node()*"/>

        <xsl:variable name="root.longer.dur"
            select="
                some $note in $root.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($fourth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="root.continued"
            select="
                some $note in $root.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="fifth.longer.dur"
            select="
                some $note in $fifth.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($fourth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="fifth.continued"
            select="
                some $note in $fifth.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>

        <xsl:variable name="is.accented" select="xs:boolean(parent::temp:chord/@accented.tstamp)"
            as="xs:boolean"/>

        <xsl:variable name="test.id" select="''" as="xs:string"/>
        <xsl:if test="$test.id != '' and $test.id = .//mei:note/@xml:id">
            <xsl:message select="'testing for upt at ' || $test.id"/>
            <xsl:message
                select="'    $comes.down: ' || $comes.down || ', $goes.down: ' || $goes.down || ', $is.accented: ' || $is.accented"/>
            <xsl:message
                select="'    $root.notes: ' || count($root.notes) || ', $fifth.notes: ' || count($fifth.notes)"/>
            <xsl:message
                select="'    $root.longer.dur: ' || $root.longer.dur || ', $root.continued: ' || $root.continued"/>
            <xsl:message
                select="'    $fifth.longer.dur: ' || $fifth.longer.dur || ', $fifth.continued: ' || $fifth.continued"
            />
        </xsl:if>

        <xsl:choose>
            <xsl:when
                test="
                    (not($is.accented))
                    and (($comes.down and $goes.down) or ($comes.up and $goes.up))">
                <!--<xsl:message select="'[DETERMINE.CHORDS] Found a upt on note ' || string-join(.//mei:note/@xml:id,', ')"/>-->
                <xsl:variable name="new.cost"
                    select="
                        number(@cost) - (if ($goes.up) then
                            (3)
                        else
                            (4))"/>
                <xsl:variable name="new.func"/>
                <temp:tone func="{($new.cost * 2 + 1 + (if($goes.down) then(+1) else(-1)))}upt"
                    cost="{$new.cost}" name="Durchgangston">
                    <xsl:for-each select=".//mei:note">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="mfunc" select="'upt'"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:for-each>
                </temp:tone>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Wechselnote / ln / un -->
    <xsl:template match="temp:tone[@cost = ('4', '5', '6')]"
        mode="determine.chords.identify.neighbors">
        <!-- a @cost of 5 is a quarter above the root, it could be suspended to an effective cost of 1 -->
        <xsl:variable name="comes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\-[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.down"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\-[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="comes.up"
            select="
                every $note in .//mei:note
                    satisfies ($note/@intm and matches($note/@intm, '\+[mM]2'))"
            as="xs:boolean"/>
        <xsl:variable name="goes.up"
            select="
                every $note in .//mei:note
                    satisfies ($note/@next.intm and matches($note/@next.intm, '\+[mM]2'))"
            as="xs:boolean"/>

        <xsl:variable name="different.intervals"
            select="count(distinct-values(.//note/(@intm, @next.intm)))" as="xs:integer"/>

        <xsl:variable name="fourth.durations"
            select="
                for $note in .//mei:note
                return
                    (number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))"
            as="xs:double+"/>

        <xsl:variable name="root.notes" select="parent::temp:chord/temp:tone[@cost = '0']/mei:note"
            as="node()*"/>
        <xsl:variable name="fifth.notes" select="parent::temp:chord/temp:tone[@cost = '2']/mei:note"
            as="node()*"/>

        <xsl:variable name="root.longer.dur"
            select="
                some $note in $root.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($fourth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="root.continued"
            select="
                some $note in $root.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="fifth.longer.dur"
            select="
                some $note in $fifth.notes
                    satisfies ((number($note/ancestor-or-self::mei:*/@tstamp2) - number($note/ancestor-or-self::mei:*/@tstamp))) gt max($fourth.durations)"
            as="xs:boolean"/>
        <xsl:variable name="fifth.continued"
            select="
                some $note in $fifth.notes
                    satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>

        <xsl:variable name="is.accented" select="xs:boolean(parent::temp:chord/@accented.tstamp)"
            as="xs:boolean"/>

        <xsl:choose>
            <xsl:when
                test="
                    not($is.accented)
                    and (($comes.down and $goes.up)
                    or ($comes.up and $goes.down))
                    and count($different.intervals) = 1">
                <!--<xsl:message select="'[DETERMINE.CHORDS] Found a un / ln on note ' || string-join(.//mei:note/@xml:id,', ')"/>-->
                <xsl:variable name="new.func"
                    select="
                        if ($goes.up) then
                            ('ln')
                        else
                            ('un')"
                    as="xs:string"/>
                <xsl:variable name="new.cost" as="xs:integer">
                    <xsl:choose>
                        <xsl:when test="@cost = '4' and $new.func = 'un'">
                            <xsl:value-of select="0"/>
                        </xsl:when>
                        <xsl:when test="@cost = '4' and $new.func = 'ln'">
                            <xsl:value-of select="1"/>
                        </xsl:when>
                        <xsl:when test="@cost = '5' and $new.func = 'un'">
                            <xsl:value-of select="1"/>
                        </xsl:when>
                        <xsl:when test="@cost = '5' and $new.func = 'ln'">
                            <xsl:value-of select="2"/>
                        </xsl:when>
                        <xsl:when test="@cost = '6' and $new.func = 'un'">
                            <xsl:value-of select="2"/>
                        </xsl:when>
                        <xsl:when test="@cost = '6' and $new.func = 'ln'">
                            <xsl:value-of select="3"/>
                            <!-- DEBUG -->
                            <!--<xsl:message select="'Wechselnote von der 7 zu 6 und zurück an: ' || string-join(.//mei:note/@xml:id)"/>-->
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <temp:tone
                    func="{($new.cost * 2 + 1 + (if($new.func = 'un') then(+1) else(-1)))}{$new.func}"
                    cost="{$new.cost}" name="Wechselnote">
                    <xsl:for-each select=".//mei:note">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="mfunc" select="$new.func"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:for-each>
                </temp:tone>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- MODE determine.chords.final.costs -->
    <xsl:template match="temp:chord/@highest.cost" mode="determine.chords.final.costs">
        <xsl:variable name="tone.cost" select="max(parent::temp:chord/temp:tone/number(@cost))"
            as="xs:double"/>
        <xsl:attribute name="highest.cost" select="$tone.cost"/>
    </xsl:template>

    <!-- this function decides if a given tstamp is accented in a given meter -->
    <xsl:function name="tools:isAccented" as="xs:boolean">
        <xsl:param name="tstamp" as="xs:string"/>
        <xsl:param name="meter.count" as="xs:string"/>
        <xsl:param name="meter.unit" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="$meter.count = '2' and $meter.unit = '2' and $tstamp = ('1', '2')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = '2' and $meter.unit = '4' and $tstamp = ('1', '2')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = '3' and $meter.unit = '4' and $tstamp = ('1', '2', '3')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when
                test="$meter.count = '4' and $meter.unit = '4' and $tstamp = ('1', '2', '3', '4')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = '3' and $meter.unit = '8' and $tstamp = ('1')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = '6' and $meter.unit = '8' and $tstamp = ('1', '4')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$meter.count = '9' and $meter.unit = '8' and $tstamp = ('1', '4', '7')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- determine if chord root has an accidental -->
    <xsl:template match="temp:chord/@root" mode="identify.root.accid">
        <xsl:variable name="note" select="parent::temp:chord/temp:tone[@func = '1']/mei:note[1]" as="node()"/>
        <xsl:variable name="accid"
            select="if ($note/@accid) then ($note/@accid) else if ($note/@accid.ges) then ($note/@accid.ges) else ('')"
            as="xs:string"/>
        <xsl:variable name="i18n.accid"
            select=" if ($accid = 'f') then('♭') else if ($accid = 's') then ('♯') else ('')"
            as="xs:string"/>
        <xsl:attribute name="root" select=". || $i18n.accid"/>
    </xsl:template>


    <xsl:template match="temp:chord/@root" mode="identify.intervals">
        <xsl:variable name="root.note"
            select="parent::temp:chord/temp:tone[@func = '1']/mei:note[1]" as="node()"/>
        <xsl:variable name="root.pnum" select="xs:integer(custom:getPnum($root.note, 0)) mod 12"
            as="xs:integer"/>

        <xsl:variable name="third.note"
            select="parent::temp:chord/temp:tone[@func = '3']/mei:note[1]" as="node()?"/>
        <xsl:variable name="third.dist" as="xs:integer?">
            <xsl:if test="exists($third.note)">
                <xsl:variable name="third.pnum"
                    select="xs:integer(custom:getPnum($third.note, 0)) mod 12" as="xs:integer"/>
                <xsl:variable name="fixed.third"
                    select="if ($root.pnum gt $third.pnum) then ($third.pnum + 12) else($third.pnum)" as="xs:integer"/>
                <xsl:value-of select="$fixed.third - $root.pnum"/>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="fifth.note"
            select="parent::temp:chord/temp:tone[@func = '5']/mei:note[1]" as="node()?"/>
        <xsl:variable name="fifth.dist" as="xs:integer?">
            <xsl:if test="exists($fifth.note)">
                <xsl:variable name="fifth.pnum"
                    select="xs:integer(custom:getPnum($fifth.note, 0)) mod 12" as="xs:integer"/>
                <xsl:variable name="fixed.fifth" select="if ($root.pnum gt $fifth.pnum) then ($fifth.pnum + 12) else($fifth.pnum)" as="xs:integer"/>
                <xsl:value-of select="$fixed.fifth - $root.pnum"/>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="seventh.note"
            select="parent::temp:chord/temp:tone[@func = '7']/mei:note[1]" as="node()?"/>
        <xsl:variable name="seventh.dist" as="xs:integer?">
            <xsl:if test="exists($seventh.note)">
                <xsl:variable name="seventh.pnum" select="xs:integer(custom:getPnum($seventh.note, 0)) mod 12" as="xs:integer"/>
                <xsl:variable name="fixed.seventh" select="if ($root.pnum gt $seventh.pnum) then ($seventh.pnum + 12) else($seventh.pnum)" as="xs:integer"/>
                <xsl:value-of select="$fixed.seventh - $root.pnum"/>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="ninth.note"
            select="parent::temp:chord/temp:tone[@func = '9']/mei:note[1]" as="node()?"/>
        <xsl:variable name="ninth.dist" as="xs:integer?">
            <xsl:if test="exists($ninth.note)">
                <xsl:variable name="ninth.pnum"
                    select="xs:integer(custom:getPnum($ninth.note, 0)) mod 12" as="xs:integer"/>
                <xsl:variable name="fixed.ninth"
                    select="
                        if ($root.pnum gt $ninth.pnum) then
                            ($ninth.pnum + 12)
                        else
                            ($ninth.pnum)"
                    as="xs:integer"/>
                <xsl:value-of select="$fixed.ninth - $root.pnum"/>
            </xsl:if>
        </xsl:variable>

        <!-- determine classic triads -->
        <xsl:choose>
            <!--major triad-->
            <xsl:when test="$third.dist = 3 and $fifth.dist = 7">
                <xsl:variable name="is.minorThird" select="." as="xs:boolean"/>
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'm'"/>
            </xsl:when>
            <xsl:when test="$third.dist = 3 and not($fifth.note)">
                <xsl:variable name="is.minorThird" select="." as="xs:boolean"/>
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'm'"/>
            </xsl:when>
            <!--minor triad-->
            <xsl:when test="$third.dist = 4 and $fifth.dist = 7">
                <xsl:attribute name="third" select="'major'"/>
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2)"/>
                <!--toDO: move root-modification elsewhere -->
            </xsl:when>
            <xsl:when test="$third.dist = 4 and not($fifth.note)">
                <xsl:attribute name="third" select="'major'"/>
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2)"/>
                <!--toDO: move root-modification elsewhere -->
            </xsl:when>
            <xsl:when test="$third.dist = 4 and $fifth.dist = 8">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || '+'"/>
            </xsl:when>
            <xsl:when test="$third.dist = 3 and $fifth.dist = 6">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'dim'"/>
                <!--toDO: move root-modification elsewhere -->
            </xsl:when>
            <!--no third but perfect fifth-->
            <xsl:when test="not($third.note) and $fifth.dist = 7">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'no3'"/>
            </xsl:when>
            <!--only ct1 and ct7: should be deleted later in a cleanup-xslt-->
            <xsl:when test="$root.note and $seventh.note and not($third.note) and not($fifth.note)">
                <xsl:attribute name="root" select="'ciao'"/>
            </xsl:when>
            
           
            <!--<xsl:when test="$third.dist = 4 and $fifth.dist = 7 and $ninth.note">
                <xsl:attribute name="root" select="'ciaoi'"/>
            </xsl:when>-->
            <!-- gr. 3, r. 5, gr. 7 -->
            <!--<xsl:when test="$third.dist = 4 and $fifth.dist = 7 and $seventh.dist = 11">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'pups'"/>
            </xsl:when>-->
            <!-- gr. 3, r. 5, kl. 7 -->
            <!--<xsl:when test="$third.dist = 3 and $fifth.dist = 7 and $seventh.dist = 10">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'oops'"/>
            </xsl:when>-->
            
            <xsl:otherwise>
                <xsl:message
                    select="'Unable to determine third at ' || ancestor::mei:measure/@n || ' at tstamp ' || $root.note/@tstamp || '. Please help…'"/>
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'Hurz'"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- toDo: handle the case when there are both minor and major thirds -->


        <!-- determine distance between root and seventh -->
        <!--<xsl:if test="exists($seventh.note)">
                <xsl:when test="$distance = 10">
                    <xsl:attribute name="seventh" select="'minor'"/>
                </xsl:when>
                <xsl:when test="$distance = 11">
                    <xsl:attribute name="seventh" select="'major'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="'Unable to determine seventh at ' || ancestor::mei:measure/@n || ' at tstamp ' || $root.note/@tstamp || '. Please help…'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>-->


        <!-- determine distance between root and ninth -->
        <!--<xsl:if test="exists($ninth.note)">
        <xsl:choose>
            <xsl:when test="$distance = 1">
                <xsl:attribute name="ninth" select="'minor'"/>
            </xsl:when>
            <xsl:when test="$distance = 2">
                <xsl:attribute name="ninth" select="'major'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'Unable to determine ninth at ' || ancestor::mei:measure/@n || ' at tstamp ' || $root.note/@tstamp || '. Please help…'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>-->
        
        
    </xsl:template>




    <!-- MODE resolve.transposing.instruments -->
    <xsl:template match="mei:note[ancestor::mei:staff[@trans.semi and @trans.diat]]"
        mode="resolve.transposing.instruments">
        <xsl:copy>
            <xsl:variable name="this" select="." as="node()"/>
            <xsl:variable name="trans.diat" select="xs:integer(ancestor::mei:staff/@trans.diat)"
                as="xs:integer"/>
            <xsl:variable name="trans.semi" select="xs:integer(ancestor::mei:staff/@trans.semi)"
                as="xs:integer"/>

            <xsl:variable name="diat.pitches" select="('c', 'd', 'e', 'f', 'g', 'a', 'b')"
                as="xs:string+"/>
            <xsl:variable name="diat.index" select="index-of($diat.pitches, $this/@pname)"
                as="xs:integer"/>
            <xsl:variable name="new.diat" select="(7 + $diat.index + $trans.diat) mod 7"
                as="xs:integer"/>
            <xsl:variable name="new.pname"
                select="
                    $diat.pitches[if ($new.diat = 0) then
                        (7)
                    else
                        ($new.diat)]"
                as="xs:string"/>

            <xsl:attribute name="pname" select="$new.pname"/>

            <xsl:variable name="semi.pitches" select="(1, 3, 5, 6, 8, 10, 12)" as="xs:integer+"/>
            <xsl:variable name="semi.base.value" select="$semi.pitches[$diat.index]" as="xs:integer"/>
            <xsl:variable name="accid.offset" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="$this/@accid = 's'">
                        <xsl:value-of select="1"/>
                    </xsl:when>
                    <xsl:when test="$this/@accid.ges = 's'">
                        <xsl:value-of select="1"/>
                    </xsl:when>
                    <xsl:when test="$this/@accid = 'f'">
                        <xsl:value-of select="-1"/>
                    </xsl:when>
                    <xsl:when test="$this/@accid.ges = 'f'">
                        <xsl:value-of select="-1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="new.semi.base.value"
                select="
                    $semi.pitches[if ($new.diat = 0) then
                        (7)
                    else
                        ($new.diat)]"
                as="xs:integer"/>
            <xsl:variable name="new.semi.real.value"
                select="(12 + $semi.base.value + $accid.offset + $trans.semi) mod 12"
                as="xs:integer"/>
            <xsl:variable name="semi.dist" select="$new.semi.real.value - $new.semi.base.value"
                as="xs:integer"/>
            <xsl:variable name="new.accid" as="xs:string?">
                <xsl:choose>
                    <xsl:when test="$semi.dist = -1">
                        <xsl:value-of select="'f'"/>
                    </xsl:when>
                    <xsl:when test="$semi.dist = 1">
                        <xsl:value-of select="'s'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$new.accid">
                <xsl:attribute name="accid.ges" select="$new.accid"/>
            </xsl:if>

            <!-- debug -->
            <!--<xsl:message select="'transposing ' || $this/@xml:id || ' from ' || $this/@pname || $this/@accid || $this/@accid.ges || ' to ' || $new.pname || $new.accid || ' (trans.diat:' || $trans.diat || ', trans.semi:' || $trans.semi || ')'"/>-->

            <!-- todo: if time permits, we should adjust @oct and @oct.ges as well… -->

            <xsl:apply-templates select="node() | (@* except (@pname, @accid, @accid.ges))"
                mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- MODE resolve.arpeggios -->
    <xsl:template
        match="mei:beam[count(descendant::mei:note[not(@grace) and not(@cue) and @tstamp]) gt 2]"
        mode="resolve.arpeggios">
        <xsl:variable name="has.chords" select="exists(child::mei:chord)" as="xs:boolean"/>
        <!-- gracenotes and cue-notes are ignored -->
        <xsl:variable name="notes"
            select="descendant::mei:note[not(@grace) and not(@cue) and @tstamp]" as="node()*"/>
        <xsl:variable name="start.tstamp"
            select="($notes[1]/number(@tstamp) mod 1 eq 0) or ($notes[1]/number(@tstamp) mod 1 eq 0.5)"
            as="xs:boolean"/>
        <!-- use the function interpreteChord that stacks all notes and calculates the costs (one third above the root = 1, two = 2 etc.) -->
        <xsl:variable name="potential.chords"
            select="tools:interpreteChord($notes, true(), false())" as="node()+"/>
        <!-- take the least costs of thirds -->
        <xsl:variable name="minimal.cost.of.thirds"
            select="min($potential.chords//mei:annot[@type = 'mfunc.tonelist']/number(@cost))"
            as="xs:double"/>
        <!-- collect the durations of all nots within the beam -->
        <xsl:variable name="notes.dur" select="$notes/@dur" as="xs:string+"/>
        <!--<xsl:variable name="chords.dur" select="$notes/parent::mei:chord/@dur" as="xs:string+"/>-->

        <xsl:choose>
            <!-- ignore when there is a chord within the beam -->
            <xsl:when test="$has.chords">
                <xsl:next-match/>
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

            <xsl:when test="count(distinct-values($notes.dur)) gt 1">
                <xsl:next-match/>
            </xsl:when>

            <!-- ignore when there is only one single pitch name – can be kept do reduce number of onsets -->
            <!--<xsl:when test="$minimal.cost.of.thirds eq 0">
                <xsl:next-match/>
            </xsl:when>-->

            <!-- lest.thirds less than 3 means only third, fifth and seventh above the root are allowed -->
            <xsl:when test="$minimal.cost.of.thirds le 2">
                <xsl:variable name="start" select="$notes[1]/@tstamp" as="xs:string"/>
                <xsl:variable name="end" select="$notes[last()]/@tstamp2" as="xs:string"/>
                <chord xmlns="http://www.music-encoding.org/ns/mei" type="resolved.arpeggio">
                    <xsl:attribute name="tstamp" select="$start"/>
                    <xsl:attribute name="tstamp2" select="$end"/>
                    <xsl:apply-templates select="$notes" mode="resolve.arpeggios.change.tstamps">
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
                    <xsl:apply-templates select="$notes" mode="resolve.arpeggios.change.tstamps">
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
    <xsl:template match="@tstamp" mode="resolve.arpeggios.change.tstamps">
        <xsl:param name="start" tunnel="yes"/>
        <xsl:attribute name="tstamp" select="$start"/>
    </xsl:template>

    <xsl:template match="@tstamp2" mode="resolve.arpeggios.change.tstamps">
        <xsl:param name="end" tunnel="yes"/>
        <xsl:attribute name="tstamp2" select="$end"/>
    </xsl:template>

    <!-- MODE inherit.tstamps -->
    <!-- this is a helper to avoid problems later on -->
    <xsl:template
        match="mei:note[not(@tstamp) and not(@tstamp2) and ancestor::mei:chord[@tstamp and @tstamp2]]"
        mode="inherit.tstamps">
        <xsl:copy>
            <xsl:apply-templates
                select="@* | ancestor::mei:chord/@tstamp | ancestor::mei:chord/@tstamp2 | node()"
                mode="#current"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>