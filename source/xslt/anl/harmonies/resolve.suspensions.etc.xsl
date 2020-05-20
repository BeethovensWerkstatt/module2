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
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p><xd:b>Author:</xd:b> Agnes Seipelt</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- Quartvorhalt / 43suspension -->
    <xsl:template match="mei:chordMember[@temp:cost = '5' and @inth = 'P4']" mode="resolve.suspensions">
        <!-- a @cost of 5 is a quarter above the root, it could be suspended to an effective cost of 1 -->
        <xsl:param name="notes" tunnel="yes" as="node()+"/>
        <xsl:variable name="chordMember" select="." as="node()"/>
        <xsl:variable name="relevant.notes" select="$notes[@xml:id = tokenize(replace($chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        
        <xsl:variable name="root.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth = 'P1']" as="node()"/>
        <xsl:variable name="fifth.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth='P5']" as="node()?"/>
        
        <xsl:variable name="root.notes" select="$notes[@xml:id = tokenize(replace($root.chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        <xsl:variable name="fifth.notes" select="if($fifth.chordMember) then($notes[@xml:id = tokenize(replace($fifth.chordMember/@corresp,'#',''), '\s+')]) else()" as="node()*"/>
        
        <!-- conditions outside of the current notes // unused -->
        <!--<xsl:variable name="root.continued"
            select="
            some $note in $root.notes
            satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>
        <xsl:variable name="fifth.continued"
            select="
            some $note in $fifth.notes
            satisfies ($note/@next.intm = ('P1', '+P8', '-P8'))"
            as="xs:boolean"/>-->
        
        <!-- conditions on individual notes -->
        <xsl:variable name="affected.notes" as="node()*">
            <xsl:for-each select="$relevant.notes">
                <xsl:variable name="current.note" select="." as="node()"/>
                <!--<xsl:variable name="comes.down" select="@intm and matches(@intm, '\-[mM]2')" as="xs:boolean"/>-->
                <xsl:variable name="goes.down" select="@next.intm and matches(@next.intm, '\-[mM]2')" as="xs:boolean"/>
                <xsl:variable name="this.dur" select="number(@tstamp2) - number(@tstamp)" as="xs:double"/>
                <xsl:variable name="root.longer.dur" select="$root.chordMember/number(@temp:dur) gt $this.dur" as="xs:boolean"/>
                <!--<xsl:variable name="fifth.longer.dur" select="if($fifth.chordMember) then($fifth.chordMember/number(@temp:dur) gt $this.dur) else(false())" as="xs:boolean"/>-->
                
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
                <!--<xsl:message select="'only some notes qualify as 43sus'"></xsl:message>-->
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($affected.notes/@xml:id,' #')"/>
                    <xsl:attribute name="temp:cost" select="1"/>
                    <xsl:attribute name="type" select="'43sus'"/>
                </xsl:copy>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @corresp" mode="#current"/>
                    <xsl:variable name="remaining.notes" select="$relevant.notes[not(@xml:id = $affected.notes/@xml:id)]" as="node()+"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($remaining.notes/@xml:id,' #')"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <!-- Sextvorhalt / 65suspension -->
    <xsl:template match="mei:chordMember[@temp:cost = '6' and @inth = ('m6','M6') ]" mode="resolve.suspensions">
        <!-- a @cost of 6 is a sixth above the root, it could be suspended to an effective cost of 2 -->
        <xsl:param name="notes" tunnel="yes" as="node()+"/>
        <xsl:variable name="chordMember" select="." as="node()"/>
        <xsl:variable name="relevant.notes" select="$notes[@xml:id = tokenize(replace($chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        
        <xsl:variable name="root.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth = 'P1']" as="node()"/>
        <xsl:variable name="fifth.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth='P5']" as="node()?"/>
        
        <xsl:variable name="root.notes" select="$notes[@xml:id = tokenize(replace($root.chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        <xsl:variable name="fifth.notes" select="if($fifth.chordMember) then($notes[@xml:id = tokenize(replace($fifth.chordMember/@corresp,'#',''), '\s+')]) else()" as="node()*"/>
        
        
        <xsl:variable name="affected.notes" as="node()*">
            <xsl:for-each select="$relevant.notes">
                <xsl:variable name="current.note" select="." as="node()"/>
                <xsl:variable name="goes.down" select="@next.intm and matches(@next.intm, '\-[mM]2')" as="xs:boolean"/>
                <xsl:variable name="this.dur" select="number(@tstamp2) - number(@tstamp)" as="xs:double"/>
                <xsl:variable name="root.longer.dur" select="$root.chordMember/number(@temp:dur) gt $this.dur" as="xs:boolean"/>
                
                <xsl:if test="$goes.down and $root.longer.dur">
                    <xsl:sequence select="."/>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <!-- 65sus may only occur on accented timestamps -->
            <xsl:when test="not(xs:boolean($chordMember/ancestor::mei:chordDef/@temp:accented))">
                <xsl:next-match/>
            </xsl:when>
            <!-- no notes qualify as 65sus -->
            <xsl:when test="count($affected.notes) = 0">
                <xsl:next-match/>
            </xsl:when>
            <!-- all notes qualify as 65sus -->
            <xsl:when test="count($affected.notes) = count($relevant.notes)">
                <xsl:copy>
                    <xsl:apply-templates select="@* except @temp:cost" mode="#current"/>
                    <xsl:attribute name="temp:cost" select="2"/>
                    <xsl:attribute name="type" select="'65sus'"/>
                </xsl:copy>
            </xsl:when>
            <!-- some notes qualify as 65sus, some don't -->
            <xsl:otherwise>
                <!--<xsl:message select="'only some notes qualify as 65sus'"></xsl:message>-->
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($affected.notes/@xml:id,' #')"/>
                    <xsl:attribute name="temp:cost" select="2"/>
                    <xsl:attribute name="type" select="'65sus'"/>
                </xsl:copy>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @corresp" mode="#current"/>
                    <xsl:variable name="remaining.notes" select="$relevant.notes[not(@xml:id = $affected.notes/@xml:id)]" as="node()+"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($remaining.notes/@xml:id,' #')"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
       

    <!-- Nonvorhalt / 98suspension -->
    <xsl:template match="mei:chordMember[@temp:cost = '4']" mode="resolve.suspensions">
        <!-- a @cost of 4 is a ninth above the root, it could be suspended to an effective cost of 0 (octave) -->
        <xsl:param name="notes" tunnel="yes" as="node()+"/>
        <xsl:variable name="chordMember" select="." as="node()"/>
        <xsl:variable name="relevant.notes" select="$notes[@xml:id = tokenize(replace($chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        <xsl:variable name="root.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth = 'P1']" as="node()"/>
        <xsl:variable name="root.notes" select="$notes[@xml:id = tokenize(replace($root.chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        
        
        <xsl:variable name="affected.notes" as="node()*">
            <xsl:for-each select="$relevant.notes">
                <xsl:variable name="current.note" select="." as="node()"/>
                <xsl:variable name="goes.down" select="@next.intm and matches(@next.intm, '\-[mM]2')" as="xs:boolean"/>
                <xsl:variable name="this.dur" select="number(@tstamp2) - number(@tstamp)" as="xs:double"/>
                <xsl:variable name="root.longer.dur" select="$root.chordMember/number(@temp:dur) gt $this.dur" as="xs:boolean"/>
                
                <xsl:if test="$goes.down and $root.longer.dur">
                    <xsl:sequence select="."/>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <!-- 98sus may only occur on accented timestamps -->
            <xsl:when test="not(xs:boolean($chordMember/ancestor::mei:chordDef/@temp:accented))">
                <xsl:next-match/>
            </xsl:when>
            <!-- no notes qualify as 98sus -->
            <xsl:when test="count($affected.notes) = 0">
                <xsl:next-match/>
            </xsl:when>
            <!-- all notes qualify as 98sus -->
            <xsl:when test="count($affected.notes) = count($relevant.notes)">
                <xsl:copy>
                    <xsl:apply-templates select="@* except @temp:cost" mode="#current"/>
                    <xsl:attribute name="temp:cost" select="0"/>
                    <xsl:attribute name="type" select="'98sus'"/>
                </xsl:copy>
            </xsl:when>
            <!-- some notes qualify as 98sus, some don't -->
            <xsl:otherwise>
                <!--<xsl:message select="'only some notes qualify as 98sus'"></xsl:message>-->
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($affected.notes/@xml:id,' #')"/>
                    <xsl:attribute name="temp:cost" select="0"/>
                    <xsl:attribute name="type" select="'98sus'"/>
                </xsl:copy>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @corresp" mode="#current"/>
                    <xsl:variable name="remaining.notes" select="$relevant.notes[not(@xml:id = $affected.notes/@xml:id)]" as="node()+"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($remaining.notes/@xml:id,' #')"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 23Vorhalt | 23retardation -->
    <xsl:template match="mei:chordMember[@temp:cost = '4']" mode="resolve.retardations">
        <!-- a @cost of 4 is a major/minor2 above the root, it could be suspended to an effective cost of 1 (third) -->
        <xsl:param name="notes" tunnel="yes" as="node()+"/>
        <xsl:variable name="chordMember" select="." as="node()"/>
        <xsl:variable name="relevant.notes" select="$notes[@xml:id = tokenize(replace($chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        <xsl:variable name="root.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth = 'P1']" as="node()"/>
        <xsl:variable name="root.notes" select="$notes[@xml:id = tokenize(replace($root.chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
                
        <xsl:variable name="affected.notes" as="node()*">
            <xsl:for-each select="$relevant.notes">
                <xsl:variable name="current.note" select="." as="node()"/>
                <xsl:variable name="goes.up" select="@next.intm and matches(@next.intm, '\+[mM]2')" as="xs:boolean"/>
                <xsl:variable name="this.dur" select="number(@tstamp2) - number(@tstamp)" as="xs:double"/>
                <xsl:variable name="root.longer.dur" select="$root.chordMember/number(@temp:dur) gt $this.dur" as="xs:boolean"/>
                
                <xsl:if test="$goes.up and $root.longer.dur">
                    <xsl:sequence select="."/>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <!-- 23ret may only occur on accented timestamps -->
            <xsl:when test="not(xs:boolean($chordMember/ancestor::mei:chordDef/@temp:accented))">
                <xsl:next-match/>
            </xsl:when>
            <!-- no notes qualify as 23ret -->
            <xsl:when test="count($affected.notes) = 0">
                <xsl:next-match/>
            </xsl:when>
            <!-- all notes qualify as 23ret -->
            <xsl:when test="count($affected.notes) = count($relevant.notes)">
                <xsl:copy>
                    <xsl:apply-templates select="@* except @temp:cost" mode="#current"/>
                    <xsl:attribute name="temp:cost" select="1"/>
                    <xsl:attribute name="type" select="'23ret'"/>
                </xsl:copy>
            </xsl:when>
            <!-- some notes qualify as 23ret, some don't -->
            <xsl:otherwise>
                <!--<xsl:message select="'only some notes qualify as 23ret'"></xsl:message>-->
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($affected.notes/@xml:id,' #')"/>
                    <xsl:attribute name="temp:cost" select="1"/>
                    <xsl:attribute name="type" select="'23ret'"/>
                </xsl:copy>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @corresp" mode="#current"/>
                    <xsl:variable name="remaining.notes" select="$relevant.notes[not(@xml:id = $affected.notes/@xml:id)]" as="node()+"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($remaining.notes/@xml:id,' #')"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <!-- 78Vorhalt | 78retardation -->
    <xsl:template match="mei:chordMember[@temp:cost = '3' and @inth = 'M7']" mode="resolve.retardations">
        <!-- a @cost of 3 is a seventh above the root, it could be suspended to an effective cost of 0 (octave) -->
        <xsl:param name="notes" tunnel="yes" as="node()+"/>
        <xsl:variable name="chordMember" select="." as="node()"/>
        <xsl:variable name="relevant.notes" select="$notes[@xml:id = tokenize(replace($chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        <xsl:variable name="root.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth = 'P1']" as="node()"/>
        <xsl:variable name="root.notes" select="$notes[@xml:id = tokenize(replace($root.chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        
        <xsl:variable name="affected.notes" as="node()*">
            <xsl:for-each select="$relevant.notes">
                <xsl:variable name="current.note" select="." as="node()"/>
                <xsl:variable name="goes.up" select="exists(@next.intm) and @next.intm = '+m2'" as="xs:boolean"/>
                <xsl:variable name="this.dur" select="number(@tstamp2) - number(@tstamp)" as="xs:double"/>
                <xsl:variable name="root.longer.dur" select="$root.chordMember/number(@temp:dur) gt $this.dur" as="xs:boolean"/>
                
                <xsl:if test="$goes.up and $root.longer.dur">
                    <xsl:sequence select="."/>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <!-- 78ret may only occur on accented timestamps -->
            <xsl:when test="not(xs:boolean($chordMember/ancestor::mei:chordDef/@temp:accented))">
                <xsl:next-match/>
            </xsl:when>
            <!-- no notes qualify as 78ret -->
            <xsl:when test="count($affected.notes) = 0">
                <xsl:next-match/>
            </xsl:when>
            <!-- all notes qualify as 78ret -->
            <xsl:when test="count($affected.notes) = count($relevant.notes)">
                <xsl:copy>
                    <xsl:apply-templates select="@* except @temp:cost" mode="#current"/>
                    <xsl:attribute name="temp:cost" select="0"/>
                    <xsl:attribute name="type" select="'78ret'"/>
                </xsl:copy>
            </xsl:when>
            <!-- some notes qualify as 23ret, some don't -->
            <xsl:otherwise>
                <!--<xsl:message select="'only some notes qualify as 78ret'"></xsl:message>-->
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($affected.notes/@xml:id,' #')"/>
                    <xsl:attribute name="temp:cost" select="0"/>
                    <xsl:attribute name="type" select="'78ret'"/>
                </xsl:copy>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @corresp" mode="#current"/>
                    <xsl:variable name="remaining.notes" select="$relevant.notes[not(@xml:id = $affected.notes/@xml:id)]" as="node()+"/>
                    <xsl:attribute name="corresp" select="'#' || string-join($remaining.notes/@xml:id,' #')"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




     <!-- WARNUNG: alter Code! -->
    <!-- Durchgangsnote (unaccented passing tone (upt)) and Wechselnoten (upper/lower neighbor)-->
    <!-- todo:handle the case of two passingtones -->
    <xsl:template match="mei:chordMember[@temp:cost = '4', '5', '6']" mode="resolve.passingtones.neighbors">
        <!--passingtones are non-chord tones that bridge two chord tones going up or down-->
        <xsl:param name="notes" tunnel="yes" as="node()+"/>
        <xsl:variable name="chordMember" select="." as="node()"/>
        <xsl:variable name="relevant.notes" select="$notes[@xml:id = tokenize(replace($chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        <xsl:variable name="root.chordMember" select="ancestor::mei:chordDef/mei:chordMember[@inth = 'P1']" as="node()"/>
        <xsl:variable name="root.notes" select="$notes[@xml:id = tokenize(replace($root.chordMember/@corresp,'#',''), '\s+')]" as="node()+"/>
        
        <xsl:variable name="qualified.notes" as="node()*">
            <xsl:for-each select="$relevant.notes">
                <xsl:variable name="current.note" select="." as="node()"/>
                <xsl:variable name="goes.up" select="@next.intm and matches(@next.intm, '\+[mM]2')" as="xs:boolean"/>
                <xsl:variable name="comes.up" select="@intm and matches(@intm, '\+[mM]2')" as="xs:boolean"/>
                <xsl:variable name="goes.down" select="@next.intm and matches(@next.intm, '\-[mM]2')" as="xs:boolean"/>
                <xsl:variable name="comes.down" select="@intm and matches(@intm, '\-[mM]2')" as="xs:boolean"/>
                <xsl:variable name="this.dur" select="number(@tstamp2) - number(@tstamp)" as="xs:double"/>
                <xsl:variable name="root.longer.dur" select="$root.chordMember/number(@temp:dur) gt $this.dur" as="xs:boolean"/>
                
                <xsl:copy>
                    <xsl:choose>
                        <xsl:when test="$goes.up and $comes.up and $root.longer.dur">
                            <xsl:attribute name="temp:type" select="'upwards.upt'"/>
                        </xsl:when>
                        <xsl:when test="$goes.down and $comes.down and $root.longer.dur">
                            <xsl:attribute name="temp:type" select="'downwards.upt'"/>
                        </xsl:when>
                        <xsl:when test="$comes.down and $goes.up and $root.longer.dur">
                            <xsl:attribute name="temp:type" select="'lower.neighbor'"/>
                        </xsl:when>
                        <xsl:when test="$comes.up and $goes.down and $root.longer.dur">
                            <xsl:attribute name="temp:type" select="'upper.neighbor'"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates select="node() | *" mode="#current"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="upwards.upt" select="$qualified.notes[@temp:type='upwards.pt']" as="node()*"/>
        <xsl:variable name="downwards.upt" select="$qualified.notes[@temp:type='downwards.upt']" as="node()*"/>
        <xsl:variable name="lower.neighbor" select="$qualified.notes[@temp:type='lower.neighbor']" as="node()*"/>
        <xsl:variable name="upper.neighbor" select="$qualified.notes[@temp:type='upper.neighbor']" as="node()*"/>
        
        <xsl:variable name="unaffected.notes" select="$qualified.notes[not(@temp:type)]" as="node()*"/>
        
       
        <xsl:choose>
            <!-- upt and un/ln may only occur on unaccented timestamps -->
            <xsl:when test="not(xs:boolean($chordMember/ancestor::mei:chordDef/@temp:accented))">
                <xsl:next-match/>
            </xsl:when>
            <!-- no notes qualify as upt/ ln/un -->
            <!--<xsl:when test="count($affected.notes.upwards) = 0 and count($affected.notes.downwards) = 0">
                <xsl:next-match/>
            </xsl:when>-->
            <!-- some notes qualify as upt or ln/un, some don't -->
            <xsl:otherwise>
                <!--<xsl:message select="'only some notes qualify as 78ret'"></xsl:message>-->
                <xsl:if test="count($unaffected.notes) gt 0">
                    <xsl:copy>
                        <xsl:apply-templates select="@* except @corresp" mode="#current"/>
                        <xsl:attribute name="corresp" select="'#' || string-join($unaffected.notes/@xml:id,' #')"/>
                    </xsl:copy>
                </xsl:if>
                <xsl:if test="count($downwards.upt) gt 0">
                    <xsl:copy>
                        <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                        <xsl:attribute name="corresp" select="'#' || string-join($downwards.upt/@xml:id,' #')"/>
                        <xsl:variable name="new.cost" select="number(@temp:cost) - 4"/>
                        <xsl:attribute name="temp:cost" select="$new.cost"/>
                        <xsl:attribute name="type" select="($new.cost * 2 + 2) || 'upt'"/>
                    </xsl:copy>
                </xsl:if>
                <xsl:if test="count($upwards.upt) gt 0">
                    <xsl:copy>
                        <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                        <xsl:attribute name="corresp" select="'#' || string-join($upwards.upt/@xml:id,' #')"/>
                        <xsl:variable name="new.cost" select="number(@temp:cost) - 3"/>
                        <xsl:attribute name="temp:cost" select="$new.cost"/>
                        <xsl:attribute name="type" select="($new.cost * 2) || 'upt'"/>
                    </xsl:copy>
                </xsl:if>
                <xsl:if test="count($lower.neighbor) gt 0">
                    <xsl:copy>
                        <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                        <xsl:attribute name="corresp" select="'#' || string-join($lower.neighbor/@xml:id,' #')"/>
                        <xsl:variable name="new.cost">
                            <xsl:choose>
                                <xsl:when test="@temp:cost = 4">
                                    <xsl:value-of select="1"/>
                                </xsl:when>
                                <xsl:when test="@temp:cost = 5">
                                    <xsl:value-of select="2"/>
                                </xsl:when>
                                <xsl:when test="@temp:cost = 6">
                                    <xsl:value-of select="3"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:attribute name="temp:cost" select="$new.cost"/>
                        <xsl:attribute name="type" select="($new.cost * 2) || 'un'"/>
                    </xsl:copy>
                </xsl:if>
                <xsl:if test="count($upper.neighbor) gt 0">
                    <xsl:copy>
                        <xsl:apply-templates select="@* except (@corresp, @temp:cost)" mode="#current"/>
                        <xsl:attribute name="corresp" select="'#' || string-join($upper.neighbor/@xml:id,' #')"/>
                        <xsl:variable name="new.cost">
                            <xsl:choose>
                                <xsl:when test="@temp:cost = 4">
                                   <xsl:value-of select="0"/>
                                </xsl:when>
                                <xsl:when test="@temp:cost = 5">
                                    <xsl:value-of select="1"/>
                                </xsl:when>
                                <xsl:when test="@temp:cost = 6">
                                    <xsl:value-of select="2"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:attribute name="temp:cost" select="$new.cost"/>
                        <xsl:attribute name="type" select="($new.cost * 2 + 2) || 'un'"/>
                    </xsl:copy>
                </xsl:if>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    
</xsl:stylesheet>