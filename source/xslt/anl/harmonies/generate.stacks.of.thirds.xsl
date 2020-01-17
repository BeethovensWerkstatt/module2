<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei tools temp custom" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 17, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:function name="tools:generateStackOfThirds" as="node()+">
        <xsl:param name="notes" as="node()+"/>
        <xsl:param name="isAccented" as="xs:boolean"/>
        <xsl:param name="allowSimplification" as="xs:boolean"/>

        <!-- static: how many thirds does it take to get somewhere -->
        <xsl:variable name="third.rows" as="node()+">
            <row pname="c" c="0" d="4" e="1" f="5" g="2" a="6" b="3"/>
            <row pname="d" c="3" d="0" e="4" f="1" g="5" a="2" b="6"/>
            <row pname="e" c="6" d="3" e="0" f="4" g="1" a="5" b="2"/>
            <row pname="f" c="2" d="6" e="3" f="0" g="4" a="1" b="5"/>
            <row pname="g" c="5" d="2" e="6" f="3" g="0" a="4" b="1"/>
            <row pname="a" c="1" d="5" e="2" f="6" g="3" a="0" b="4"/>
            <row pname="b" c="4" d="1" e="5" f="2" g="6" a="3" b="0"/>
        </xsl:variable>

        <xsl:variable name="pnames" select="distinct-values($notes//@pname)" as="xs:string+"/>
        <xsl:variable name="pnums" select="distinct-values($notes/@pnum/xs:integer(.))" as="xs:integer+"/>
        <xsl:variable name="pclasses" select="distinct-values((for $pnum in $pnums return ($pnum mod 12)))" as="xs:integer+"/>
        
        <!-- this addresses the problem of a 'c' and a 'c#' in the same chord… -->
        <xsl:variable name="pname.pclass.combined" as="xs:string+">
            <xsl:for-each select="$pnames">
                <xsl:variable name="current.pname" select="." as="xs:string"/>
                <xsl:variable name="current.pclasses" select="for $pnum in $notes[@pname = $current.pname]/@pnum return xs:string(xs:integer($pnum) mod 12)" as="xs:string+"/>
                <xsl:for-each select="distinct-values($current.pclasses)">
                    <xsl:value-of select="$current.pname || '-' ||."/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="bass.tone" as="xs:string">
            <xsl:variable name="pnames.indizes" select="('c', 'd', 'e', 'f', 'g', 'a', 'b')" as="xs:string+"/>
            <xsl:variable name="lowest.octave.notes" select="$notes[@oct = string(min($notes/number(@oct)))]" as="node()+"/>
            <xsl:variable name="lowest.note"
                select="
                    $pnames.indizes[min(for $note in $lowest.octave.notes
                    return
                        (index-of($pnames.indizes, $note/@pname)))]"
                as="xs:string"/>
            <xsl:value-of select="$lowest.note"/>
        </xsl:variable>

        <xsl:for-each select="$pname.pclass.combined">
            <xsl:variable name="current.pname" select="substring-before(.,'-')" as="xs:string"/>
            <xsl:variable name="current.pclass" select="substring-after(.,'-')" as="xs:string"/>
            <xsl:variable name="current.row" select="$third.rows/descendant-or-self::row[@pname = $current.pname]"
                as="node()"/>
            
            <xsl:variable name="ct1" select="$notes[.//@pname = $current.row/@*[. = '0']/local-name()]" as="node()+"/>
            <xsl:variable name="ct3" select="$notes[.//@pname = $current.row/@*[. = '1']/local-name()]" as="node()*"/>
            <xsl:variable name="ct5" select="$notes[.//@pname = $current.row/@*[. = '2']/local-name()]" as="node()*"/>
            <xsl:variable name="ct7" select="$notes[.//@pname = $current.row/@*[. = '3']/local-name()]" as="node()*"/>
            <xsl:variable name="ct9" select="$notes[.//@pname = $current.row/@*[. = '4']/local-name()]" as="node()*"/>
            <xsl:variable name="ct11" select="$notes[.//@pname = $current.row/@*[. = '5']/local-name()]" as="node()*"/>
            <xsl:variable name="ct13" select="$notes[.//@pname = $current.row/@*[. = '6']/local-name()]" as="node()*"/>

            <xsl:variable name="notes" as="node()+">
                <chordMember xmlns="http://www.music-encoding.org/ns/mei" 
                    inth="P1" 
                    temp:cost="0" 
                    corresp="#{string-join($ct1/@xml:id,' #')}" 
                    pname="{$ct1[1]/@pname}" 
                    accid.ges="f" 
                    temp:dur=""/>
                <xsl:if test="$current.row/@*[. = '1']/local-name() = $pnames">
                    <annot xmlns="http://www.music-encoding.org/ns/mei" class="ct ct3" label="third" plist="{$notes[.//@pname = $current.row/@*[. = '1']/local-name()]}">
                        <num type="cost">1</num>
                    </annot>
                </xsl:if>
                <xsl:if test="$current.row/@*[. = '2']/local-name() = $pnames">
                    <annot xmlns="http://www.music-encoding.org/ns/mei" class="ct ct5" label="fifth" plist="{$notes[.//@pname = $current.row/@*[. = '2']/local-name()]}">
                        <num type="cost">2</num>
                    </annot>
                </xsl:if>
                <xsl:if test="$current.row/@*[. = '3']/local-name() = $pnames">
                    <annot xmlns="http://www.music-encoding.org/ns/mei" class="ct ct7" label="seventh" plist="{$notes[.//@pname = $current.row/@*[. = '3']/local-name()]}">
                        <num type="cost">3</num>
                    </annot>
                </xsl:if>
                <xsl:if test="$current.row/@*[. = '4']/local-name() = $pnames">
                    <annot xmlns="http://www.music-encoding.org/ns/mei" class="ct ct9" label="ninth" plist="{$notes[.//@pname = $current.row/@*[. = '4']/local-name()]}">
                        <num type="cost">4</num>
                    </annot>
                </xsl:if>
                <xsl:if test="$current.row/@*[. = '5']/local-name() = $pnames">
                    <annot xmlns="http://www.music-encoding.org/ns/mei" class="ct ct11" label="eleventh" plist="{$notes[.//@pname = $current.row/@*[. = '5']/local-name()]}">
                        <num type="cost">5</num>
                    </annot>
                </xsl:if>
                <xsl:if test="$current.row/@*[. = '6']/local-name() = $pnames">
                    <annot xmlns="http://www.music-encoding.org/ns/mei" class="ct ct13" label="thirteenth" plist="{$notes[.//@pname = $current.row/@*[. = '6']/local-name()]}">
                        <num type="cost">6</num>
                    </annot>
                </xsl:if>
            </xsl:variable>

            <xsl:variable name="inversion" select="xs:integer($current.row/@*[local-name() = $bass.tone])" as="xs:integer"/>
            <xsl:variable name="root.dur"
                select="max($notes[.//@pname = $current.row/@*[. = '0']/local-name()]/(max(.//@tstamp2/number(.)) - min(.//@tstamp/number(.))))"
                as="xs:double?"/>

            <xsl:variable name="bass.accid" as="xs:string">
                <xsl:choose>
                    <xsl:when test="$notes//mei:note[@pname = $bass.tone][@accid.ges = 'f']">
                        <xsl:value-of select="'♭'"/>
                    </xsl:when>
                    <xsl:when test="$notes//mei:note[@pname = $bass.tone][@accid = 'f']">
                        <xsl:value-of select="'♭'"/>
                    </xsl:when>
                    <xsl:when test="$notes//mei:note[@pname = $bass.tone][@accid.ges = 's']">
                        <xsl:value-of select="'♯'"/>
                    </xsl:when>
                    <xsl:when test="$notes//mei:note[@pname = $bass.tone][@accid = 's']">
                        <xsl:value-of select="'♯'"/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:value-of select="''"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <chord bass="{$bass.tone}" bass.accid="{$bass.accid}"
                highest.cost="{max($notes/xs:integer(@cost))}"
                >
                <xsl:sequence select="$notes"/>
            </chord>

            <chordDef xmlns="http://www.music-encoding.org/ns/mei">
                <chordMember inth="P1" temp:cost="0" corresp="ids…" pname="c" accid.ges="f" temp:dur=""/>
                <chordMember inth="M3" temp:cost="1" corresp="ids…" pname="e" accid.ges="f" type="bass"/>
                <chordMember inth="d5" corresp="ids…"/>
                
                <annot >
                    <num type="cost">6</num>
                </annot>
            </chordDef>

        </xsl:for-each>

    </xsl:function>

</xsl:stylesheet>
