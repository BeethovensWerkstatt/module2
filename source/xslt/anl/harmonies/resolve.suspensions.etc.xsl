<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei tools temp custom"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 17, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- Quartvorhalt / 43suspension -->
    <xsl:template match="mei:chordMember[@temp:cost = '5']" mode="resolve.suspensions">
        <!-- a @cost of 5 is a quarter above the root, it could be suspended to an effective cost of 1 -->
        <xsl:param name="notes" tunnel="yes" as="node()+"/>
        <xsl:variable name="chordMember" select="." as="node()"/>
        <xsl:variable name="relevant.notes" select="$notes[@xml:id = tokenize(replace($chordMember/@corresp,'#',''))]" as="node()+"/>
        
        <xsl:variable name="root.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth = 'P1']" as="node()"/>
        <xsl:variable name="fifth.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth='P5']" as="node()?"/>
        
        <xsl:variable name="root.notes" select="$notes[@xml:id = tokenize(replace($root.chordMember/@corresp,'#',''))]" as="node()+"/>
        <xsl:variable name="fifth.notes" select="if($fifth.chordMember) then($notes[@xml:id = tokenize(replace($fifth.chordMember/@corresp,'#',''))]) else()" as="node()*"/>
        
        <!-- conditions outside of the current notes  -->
        <xsl:variable name="root.continued"
            select="
            some $note in $root.notes
            satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="fifth.continued"
            select="
            some $note in $fifth.notes
            satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        
        <!-- conditions on individual notes -->
        <xsl:variable name="affected.notes" as="node()*">
            <xsl:for-each select="$relevant.notes">
                <xsl:variable name="current.note" select="." as="node()"/>
                <xsl:variable name="comes.down" select="@intm and matches(@intm, '\-[mM]2')" as="xs:boolean"/>
                <xsl:variable name="goes.down" select="@next.intm and matches(@next.intm, '\-[mM]2')" as="xs:boolean"/>
                <xsl:variable name="this.dur" select="number(@tstamp2) - number(@tstamp)" as="xs:double"/>
                <xsl:variable name="root.longer.dur" select="$root.chordMember/number(@temp:dur) gt $this.dur" as="xs:boolean"/>
                <xsl:variable name="fifth.longer.dur" select="if($fifth.chordMember) then($fifth.chordMember/number(@temp:dur) gt $this.dur) else(false())" as="xs:boolean"/>
                
                <xsl:if test="$goes.down and $root.longer.dur">
                    <xsl:sequence select="."/>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <!-- 43sus may only occur on accented timestamps -->
            <xsl:when test="not(xs:boolean($chordMember/ancestor::mei:chordDef/@temp:accented))">
                <xsl:next-match/>
            </xsl:when>
            <!-- no notes qualify as 43sus -->
            <xsl:when test="count($affected.notes) = 0">
                <xsl:next-match/>
            </xsl:when>
            <!-- all notes qualify as 43sus -->
            <xsl:when test="count($affected.notes) = count($relevant.notes)">
                <xsl:copy>
                    <xsl:apply-templates select="@* except @temp:cost" mode="#current"/>
                    <xsl:attribute name="temp:cost" select="1"/>
                    <xsl:attribute name="type" select="'43sus'"/>
                </xsl:copy>
            </xsl:when>
            <!-- some notes qualify as 43sus, some don't -->
            <xsl:otherwise>
                <xsl:message select="'only some notes qualify as 43sus'"></xsl:message>
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($affected.notes/@xml:id,' #')"/>
                    <xsl:attribute name="temp:cost" select="1"/>
                    <xsl:attribute name="type" select="'43sus'"/>
                </xsl:copy>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @corresp" mode="#current"/>
                    <xsl:variable name="remaining.notes" select="$relevant.notes[not(@xml:id) = $affected.notes/@xml:id]" as="node()+"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($remaining.notes/@xml:id,' #')"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <!-- Sextvorhalt | 65suspension -->
    <xsl:template match="temp:tone[@cost = '6']" mode="resolve.suspensions">
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
    <xsl:template match="temp:tone[@cost = '4']" mode="resolve.suspensions">
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
    <xsl:template match="temp:tone[@cost = '4']" mode="resolve.retardations">
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
    <xsl:template match="temp:tone[@cost = '3']" mode="resolve.retardations">
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
        mode="resolve.passingtones">
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
        mode="resolve.neighbors">
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

    
    
</xsl:stylesheet>