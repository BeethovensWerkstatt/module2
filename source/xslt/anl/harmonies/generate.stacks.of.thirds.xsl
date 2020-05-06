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

        <!-- here is the problem of pname and pname.ges that transposing instruments should have -->
        <!--<xsl:variable name="pnames" select="distinct-values($notes//@pname)" as="xs:string+"/>-->
        
        <xsl:variable name="pnames" select="distinct-values(for $note in $notes/descendant-or-self::mei:note[@pname] return (if($note/@pname.ges) then($note/@pname.ges) else($note/@pname)))" as="xs:string+"/>
        
        
        <!-- this addresses the problem of a 'c' and a 'c#' in the same chord… -->
        <xsl:variable name="pname.pclass.combined" as="xs:string+">
            <xsl:for-each select="$pnames">
                <xsl:variable name="current.pname" select="." as="xs:string"/>
                <xsl:variable name="current.pclasses" select="distinct-values($notes[(not(@pname.ges) and @pname = $current.pname) or @pname.ges = $current.pname]/@pclass)" as="xs:string+"/>
                <xsl:for-each select="$current.pclasses">
                    <xsl:value-of select="$current.pname || '-' ||."/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="bass.notes" as="node()+">
            <xsl:variable name="pnames.indizes" select="('c', 'd', 'e', 'f', 'g', 'a', 'b')" as="xs:string+"/>
            <xsl:variable name="lowest.pnum.notes" select="$notes[@pnum = string(min($notes/number(@pnum)))]" as="node()+"/>
            <xsl:variable name="lowest.oct.notes" select="$lowest.pnum.notes[@oct = string(min($lowest.pnum.notes/number(@oct)))]" as="node()+"/>
            <xsl:variable name="used.pnames" select="distinct-values($lowest.oct.notes/(if(@pname.ges) then(@pname.ges) else(@pname)))" as="xs:string+"/>
            <xsl:variable name="lowest.index" select="min(for $pname in $used.pnames return index-of($pnames.indizes,$pname))" as="xs:integer"/>
            <xsl:variable name="lowest.notes" select="$lowest.oct.notes[(not(@pname.ges) and @pname = $pnames.indizes[$lowest.index]) or @pname.ges = $pnames.indizes[$lowest.index]]" as="node()+"/>
            <xsl:sequence select="$lowest.notes"/>
        </xsl:variable>


        <xsl:for-each select="$pname.pclass.combined">
            <xsl:variable name="root.pname" select="substring-before(.,'-')" as="xs:string"/>
            <xsl:variable name="root.pclass" select="substring-after(.,'-')" as="xs:string"/>
            <xsl:variable name="root.int" select="xs:integer($root.pclass)" as="xs:integer"/>
            <xsl:variable name="bass.pname" select="if($bass.notes[1]/@pname.ges) then($bass.notes[1]/@pname.ges) else($bass.notes[1]/@pname)" as="xs:string"/>
            <xsl:variable name="current.row" select="$third.rows/descendant-or-self::row[@pname = $root.pname]" as="node()"/>
            
            <xsl:variable name="ct1" select="$notes[((not(.//@pname.ges) and .//@pname = $current.row/@*[. = '0']/local-name()) or (.//@pname.ges = $current.row/@*[. = '0']/local-name())) and .//@pclass = $root.pclass]" as="node()+"/>
            
            <xsl:variable name="ct1.alt" select="$notes[((not(.//@pname.ges) and .//@pname = $current.row/@*[. = '0']/local-name()) or (.//@pname.ges = $current.row/@*[. = '0']/local-name())) and .//@pclass != $root.pclass]" as="node()*"/>
                        
            <xsl:variable name="ct3" select="$notes[((not(.//@pname.ges) and .//@pname = $current.row/@*[. = '1']/local-name()) or (.//@pname.ges = $current.row/@*[. = '1']/local-name())) and .//@pclass != $root.pclass]" as="node()*"/>
            
            <xsl:variable name="ct5" select="$notes[((not(.//@pname.ges) and .//@pname = $current.row/@*[. = '2']/local-name()) or (.//@pname.ges = $current.row/@*[. = '2']/local-name())) and .//@pclass != $root.pclass]" as="node()*"/>
            
            <xsl:variable name="ct7" select="$notes[((not(.//@pname.ges) and .//@pname = $current.row/@*[. = '3']/local-name()) or (.//@pname.ges = $current.row/@*[. = '3']/local-name())) and .//@pclass != $root.pclass]" as="node()*"/>
            
            <xsl:variable name="ct9" select="$notes[((not(.//@pname.ges) and .//@pname = $current.row/@*[. = '4']/local-name()) or (.//@pname.ges = $current.row/@*[. = '4']/local-name())) and .//@pclass != $root.pclass]" as="node()*"/>
            
            <xsl:variable name="ct11" select="$notes[((not(.//@pname.ges) and .//@pname = $current.row/@*[. = '5']/local-name()) or (.//@pname.ges = $current.row/@*[. = '5']/local-name())) and .//@pclass != $root.pclass]" as="node()*"/>
            
            <xsl:variable name="ct13" select="$notes[((not(.//@pname.ges) and .//@pname = $current.row/@*[. = '6']/local-name()) or (.//@pname.ges = $current.row/@*[. = '6']/local-name())) and .//@pclass != $root.pclass]" as="node()*"/>
            

            <xsl:variable name="chordDef">
               
                <chordDef xmlns="http://www.music-encoding.org/ns/mei" temp:root="{$root.pname}" temp:root.pclass="{$root.pclass}" temp:bass="{$bass.pname}" temp:bass.pclass="{$bass.notes[1]/@pclass}" temp:accented="{$isAccented}">
                
                <!-- these are all root notes -->
                <xsl:sequence select="tools:generateChordMember($ct1,0,'P1')"/>
                
                <!-- these are notes of the same pname as the root, but with different pclasses (e.g. "G" and "G#") -->
                <xsl:for-each select="distinct-values($ct1.alt//@pclass)">
                    <xsl:variable name="current.pclass" select="." as="xs:string"/>
                    <xsl:variable name="current.notes" select="$ct1.alt[.//@pclass=$current.pclass]" as="node()+"/>
                    <xsl:variable name="interval" select="if((xs:integer($current.pclass) + 15) gt (xs:integer($root.pclass) + 15)) then('A8') else('d8')" as="xs:string"/>
                    
                    <xsl:sequence select="tools:generateChordMember($current.notes,7,$interval)"/>
                </xsl:for-each>
                
                <!-- these are thirds -->
                <xsl:for-each select="distinct-values($ct3//@pclass)">
                    <xsl:variable name="current.pclass" select="." as="xs:string"/>
                    <xsl:variable name="current.notes" select="$ct3[.//@pclass=$current.pclass]" as="node()+"/>
                    <xsl:variable name="pclass.int" select="xs:integer($current.pclass)" as="xs:integer"/>
                    <xsl:variable name="dist" select="if($root.int lt $pclass.int) then($pclass.int - $root.int) else($pclass.int + 12 - $root.int)" as="xs:integer"/>
                    <xsl:variable name="interval" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$dist lt 3"><xsl:value-of select="'d3'"/></xsl:when>
                            <xsl:when test="$dist = 3"><xsl:value-of select="'m3'"/></xsl:when>
                            <xsl:when test="$dist = 4"><xsl:value-of select="'M3'"/></xsl:when>
                            <xsl:when test="$dist gt 4"><xsl:value-of select="'A3'"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:sequence select="tools:generateChordMember($current.notes,1,$interval)"/>
                </xsl:for-each>
                
                <!-- these are fifths -->
                <xsl:for-each select="distinct-values($ct5//@pclass)">
                    <xsl:variable name="current.pclass" select="." as="xs:string"/>
                    <xsl:variable name="current.notes" select="$ct5[.//@pclass=$current.pclass]" as="node()+"/>
                    <xsl:variable name="pclass.int" select="xs:integer($current.pclass)" as="xs:integer"/>
                    <xsl:variable name="dist" select="if($root.int lt $pclass.int) then($pclass.int - $root.int) else($pclass.int + 12 - $root.int)" as="xs:integer"/>
                    <xsl:variable name="interval" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$dist lt 7"><xsl:value-of select="'d5'"/></xsl:when>
                            <xsl:when test="$dist = 7"><xsl:value-of select="'P5'"/></xsl:when>
                            <xsl:when test="$dist gt 7"><xsl:value-of select="'A5'"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:sequence select="tools:generateChordMember($current.notes,2,$interval)"/>
                </xsl:for-each>
                
                <!-- these are sevenths -->
                <xsl:for-each select="distinct-values($ct7//@pclass)">
                    <xsl:variable name="current.pclass" select="." as="xs:string"/>
                    <xsl:variable name="current.notes" select="$ct7[.//@pclass=$current.pclass]" as="node()+"/>
                    <xsl:variable name="pclass.int" select="xs:integer($current.pclass)" as="xs:integer"/>
                    <xsl:variable name="dist" select="if($root.int lt $pclass.int) then($pclass.int - $root.int) else($pclass.int + 12 - $root.int)" as="xs:integer"/>
                    <xsl:variable name="interval" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$dist lt 10"><xsl:value-of select="'d7'"/></xsl:when>
                            <xsl:when test="$dist = 10"><xsl:value-of select="'m7'"/></xsl:when>
                            <xsl:when test="$dist = 11"><xsl:value-of select="'M7'"/></xsl:when>
                            <xsl:when test="$dist gt 11"><xsl:value-of select="'A7'"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:sequence select="tools:generateChordMember($current.notes,3,$interval)"/>
                </xsl:for-each>
                
                <!-- these are ninths / seconds -->
                <xsl:for-each select="distinct-values($ct9//@pclass)">
                    <xsl:variable name="current.pclass" select="." as="xs:string"/>
                    <xsl:variable name="current.notes" select="$ct9[.//@pclass=$current.pclass]" as="node()+"/>
                    <xsl:variable name="pclass.int" select="xs:integer($current.pclass)" as="xs:integer"/>
                    <xsl:variable name="dist" select="if($root.int lt $pclass.int) then($pclass.int - $root.int) else($pclass.int + 12 - $root.int)" as="xs:integer"/>
                    <xsl:variable name="interval" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$dist = 1"><xsl:value-of select="'m2'"/></xsl:when>
                            <xsl:when test="$dist = 2"><xsl:value-of select="'M2'"/></xsl:when>
                            <xsl:when test="$dist gt 2"><xsl:value-of select="'A2'"/></xsl:when>
                            <xsl:otherwise>
                                <xsl:message select="'$pclass.int:' || $pclass.int || ', $root.int:' || $root.int" terminate="yes"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:sequence select="tools:generateChordMember($current.notes,4,$interval)"/>
                </xsl:for-each>
                
                <!-- these are elevenths / quarters -->
                <xsl:for-each select="distinct-values($ct11//@pclass)">
                    <xsl:variable name="current.pclass" select="." as="xs:string"/>
                    <xsl:variable name="current.notes" select="$ct11[.//@pclass=$current.pclass]" as="node()+"/>
                    <xsl:variable name="pclass.int" select="xs:integer($current.pclass)" as="xs:integer"/>
                    <xsl:variable name="dist" select="if($root.int lt $pclass.int) then($pclass.int - $root.int) else($pclass.int + 12 - $root.int)" as="xs:integer"/>
                    <xsl:variable name="interval" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$dist lt 5"><xsl:value-of select="'d4'"/></xsl:when>
                            <xsl:when test="$dist = 5"><xsl:value-of select="'P4'"/></xsl:when>
                            <xsl:when test="$dist gt 5"><xsl:value-of select="'A4'"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:sequence select="tools:generateChordMember($current.notes,5,$interval)"/>
                </xsl:for-each>
                
                <!-- these are thirteenths / sixths -->
                <xsl:for-each select="distinct-values($ct13//@pclass)">
                    <xsl:variable name="current.pclass" select="." as="xs:string"/>
                    <xsl:variable name="current.notes" select="$ct13[.//@pclass=$current.pclass]" as="node()+"/>
                    <xsl:variable name="pclass.int" select="xs:integer($current.pclass)" as="xs:integer"/>
                    <xsl:variable name="dist" select="if($root.int lt $pclass.int) then($pclass.int - $root.int) else($pclass.int + 12 - $root.int)" as="xs:integer"/>
                    <xsl:variable name="interval" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$dist lt 8"><xsl:value-of select="'d6'"/></xsl:when>
                            <xsl:when test="$dist = 8"><xsl:value-of select="'m6'"/></xsl:when>
                            <xsl:when test="$dist = 9"><xsl:value-of select="'M6'"/></xsl:when>
                            <xsl:when test="$dist gt 9"><xsl:value-of select="'A6'"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:sequence select="tools:generateChordMember($current.notes,6,$interval)"/>
                </xsl:for-each>
            </chordDef></xsl:variable>
            <xsl:sequence select="$chordDef"/>
            
        </xsl:for-each>

    </xsl:function>
    
    <xsl:function name="tools:generateChordMember" as="node()">
        <xsl:param name="notes" as="node()+"/>
        <xsl:param name="cost" as="xs:integer"/>
        <xsl:param name="interval" as="xs:string"/>
        
        <xsl:variable name="dur" select="max($notes/(max(.//@tstamp2/number(.)) - min(.//@tstamp/number(.))))" as="xs:double"/>
        
        
        
        <chordMember xmlns="http://www.music-encoding.org/ns/mei" 
            inth="{$interval}" 
            temp:cost="{xs:string($cost)}" 
            corresp="#{string-join($notes/@xml:id,' #')}" 
            pname="{if($notes[1]/@pname.ges) then ($notes[1]/@pname.ges) else ($notes[1]/@pname)}" 
            accid.ges="{if($notes[1]/@accid.ges) then($notes[1]/@accid.ges) else if($notes[1]/@accid) then($notes[1]/@accid) else('')}" 
            temp:pclass="{$notes[1]/@pclass}"
            temp:dur="{$dur}"/>
    </xsl:function>

</xsl:stylesheet>
