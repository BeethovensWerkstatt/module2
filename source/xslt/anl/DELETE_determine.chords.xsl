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
                    select="tools:isAccented($current.tstamp, $measure/@meter.count, $measure/@meter.unit, $measure/@meter.sym)" 
                    as="xs:boolean"/>
                
                <!--to Do: nur harm unter Noten, die länger als Sechzehntel sind?-->
                <!--<xsl:variable name="longer.duration" select="number($current.notes//@dur) lt 16" as="xs:boolean"/>-->


                <xsl:if test="(count(distinct-values($current.notes//@pname)) gt 1) and $is.accented">
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

    

    <!-- MODE determine.chords.final.costs -->
    <xsl:template match="temp:chord/@highest.cost" mode="determine.chords.final.costs">
        <xsl:variable name="tone.cost" select="max(parent::temp:chord/temp:tone/number(@cost))"
            as="xs:double"/>
        <xsl:attribute name="highest.cost" select="$tone.cost"/>
    </xsl:template>

    <!-- this function decides if a given tstamp is accented in a given meter -->
    

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

        
        <xsl:choose>
            <!--minor triad:-->
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
            <!--major triads:-->
            <xsl:when test="$third.dist = 4 and $fifth.dist = 7">
                <xsl:attribute name="third" select="'major'"/>
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2)"/>
            </xsl:when>
            <xsl:when test="$third.dist = 4 and not($fifth.note)">
                <xsl:attribute name="third" select="'major'"/>
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2)"/>
            </xsl:when>
            <!-- augmented triads: -->
            <xsl:when test="$third.dist = 4 and $fifth.dist = 8">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || '+'"/>
            </xsl:when>
            <!-- diminished triads = verkürzter Akkord (kein Grundton) -->
            <xsl:when test="$third.dist = 3 and $fifth.dist = 6">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'dim'"/>
            </xsl:when>
            
            <!-- crazy combinations -->
            <!-- only major third and diminished fifth -->
            <xsl:when test="$third.dist = 4 and $fifth.dist = 6 and not($seventh.note) and not($ninth.note)">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || '♭5'"/>
            </xsl:when>
            <!-- only minor third and augmented fifth -->
            <xsl:when test="$third.dist = 3 and $fifth.dist = 8 and not($seventh.note) and not($ninth.note)">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'm♯5'"/>
            </xsl:when>
            
            <!--no third but perfect fifth-->
            <xsl:when test="not($third.note) and $fifth.dist = 7">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || 'no3'"/>
            </xsl:when>
            
            
            <!--Following interval combinations get a "ciao" and will be deleted in a cleanup-->
            <!--only ct1 and ct7 -->
            <xsl:when test="$root.note and $seventh.note and not($third.note) and not($fifth.note)">
                <xsl:attribute name="root" select="'ciao'"/>
            </xsl:when>
            <xsl:when test="$root.note and not($seventh.note) and not($third.note) and not($fifth.note)">
                <xsl:attribute name="root" select="'ciao'"/>
            </xsl:when>
            <xsl:when test="not($third.note) and $fifth.dist = 6">
                <xsl:attribute name="root" select="'ciao'"/>
            </xsl:when>
            <xsl:when test="not($third.note) and $fifth.dist = 8">
                <xsl:attribute name="root" select="'ciao'"/>
            </xsl:when>
            <!-- if there is a diminished third -->
            <xsl:when test="$third.dist = 2">
                <xsl:attribute name="root" select="upper-case(substring(., 1, 1)) || substring(., 2) || 'ciao'"/>
            </xsl:when>
            
           
            <!--<xsl:when test="$third.dist = 4 and $fifth.dist = 7 and $ninth.note">
                <xsl:attribute name="root" select="'ciaoi'"/>
            </xsl:when>-->
            <!-- gr. 3, r. 5, gr. 7 -->
            <!--<xsl:when test="$third.dist = 4 and $fifth.dist = 7 and $seventh.dist = 11">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || ' '"/>
            </xsl:when>-->
            <!-- gr. 3, r. 5, kl. 7 -->
            <!--<xsl:when test="$third.dist = 3 and $fifth.dist = 7 and $seventh.dist = 10">
                <xsl:attribute name="root"
                    select="upper-case(substring(., 1, 1)) || substring(., 2) || ' '"/>
            </xsl:when>-->
            
            <xsl:otherwise>
                <!--<xsl:message
                    select="'Unable to determine interval at ' || ancestor::mei:measure/@n || ' at tstamp ' || $root.note/@tstamp || '. Please help…'"/>-->
                <xsl:attribute name="root"
                    select="'(' || upper-case(substring(., 1, 1)) || substring(., 2) || ')'"/>
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


    

</xsl:stylesheet>
