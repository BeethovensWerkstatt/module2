<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link"
    exclude-result-prefixes="xs math xd mei tools"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 4, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- this outputs a simple parsons code, with a new value "m" when chords allow to go both up and down -->
    <xsl:function name="tools:getParsonsCode" as="xs:string">
        <xsl:param name="items" as="node()*"/>
        
        <xsl:variable name="pnums" select="$items/@pnum" as="xs:string*"/>
        
        <xsl:variable name="pc.string" as="xs:string*">
            <xsl:value-of select="'.'"/>
            <xsl:for-each select="(2 to count($pnums))">
                <xsl:variable name="i" select="." as="xs:integer"/>
                <xsl:variable name="current.pnum" select="$pnums[$i]" as="xs:string"/>
                <xsl:variable name="prev.pnum" select="$pnums[$i - 1]" as="xs:string"/>
                <xsl:variable name="from.chord" select="contains($prev.pnum,'[')" as="xs:boolean"/>
                <xsl:variable name="to.chord" select="contains($current.pnum,'[')" as="xs:boolean"/>
                <xsl:choose>
                    <!-- the first item in a sequence always starts with a dot -->
                    <xsl:when test="$prev.pnum = '.'"><xsl:value-of select="'.'"/></xsl:when>
                    <!-- rests will always be represented by a dot -->
                    <xsl:when test="$current.pnum = '.'"><xsl:value-of select="'.'"/></xsl:when>
                    <!-- simple note to note -->
                    <xsl:when test="not($from.chord) and not($to.chord)">
                        <xsl:choose>
                            <xsl:when test="xs:integer($current.pnum) = xs:integer($prev.pnum)"><xsl:value-of select="'s'"/></xsl:when>
                            <xsl:when test="xs:integer($current.pnum) lt xs:integer($prev.pnum)"><xsl:value-of select="'d'"/></xsl:when>
                            <xsl:when test="xs:integer($current.pnum) gt xs:integer($prev.pnum)"><xsl:value-of select="'u'"/></xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <!-- from note to chord -->
                    <xsl:when test="not($from.chord) and $to.chord">
                        <xsl:variable name="prev.pnum.int" select="xs:integer($prev.pnum)" as="xs:integer"/>
                        <xsl:variable name="current.pnum.int" select="for $pnum in tokenize(replace($current.pnum,'[\[\]]',''),',') return xs:integer($pnum)" as="xs:integer*"/>
                        <xsl:choose>
                            <xsl:when test="every $pnum in $current.pnum.int satisfies $pnum = $prev.pnum.int"><xsl:value-of select="'s'"/></xsl:when>
                            <xsl:when test="every $pnum in $current.pnum.int satisfies $pnum lt $prev.pnum.int"><xsl:value-of select="'d'"/></xsl:when>
                            <xsl:when test="every $pnum in $current.pnum.int satisfies $pnum gt $prev.pnum.int"><xsl:value-of select="'u'"/></xsl:when>
                            <!-- introducing a "mixed" value -->
                            <xsl:otherwise><xsl:value-of select="'m'"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- from chord to note -->
                    <xsl:when test="$from.chord and not($to.chord)">
                        <xsl:variable name="prev.pnum.int" select="for $pnum in tokenize(replace($prev.pnum,'[\[\]]',''),',') return xs:integer($pnum)" as="xs:integer*"/>
                        <xsl:variable name="current.pnum.int" select="xs:integer($current.pnum)" as="xs:integer"/>
                        <xsl:choose>
                            <xsl:when test="every $pnum in $prev.pnum.int satisfies $pnum = $current.pnum.int"><xsl:value-of select="'s'"/></xsl:when>
                            <xsl:when test="every $pnum in $prev.pnum.int satisfies $pnum lt $current.pnum.int"><xsl:value-of select="'u'"/></xsl:when>
                            <xsl:when test="every $pnum in $prev.pnum.int satisfies $pnum gt $current.pnum.int"><xsl:value-of select="'d'"/></xsl:when>
                            <!-- introducing a "mixed" value -->
                            <xsl:otherwise><xsl:value-of select="'m'"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- from chord to chord -->
                    <xsl:when test="$from.chord and $to.chord">
                        <xsl:variable name="prev.pnum.int" select="for $pnum in tokenize(replace($prev.pnum,'[\[\]]',''),',') return xs:integer($pnum)" as="xs:integer*"/>
                        <xsl:variable name="current.pnum.int" select="for $pnum in tokenize(replace($current.pnum,'[\[\]]',''),',') return xs:integer($pnum)" as="xs:integer*"/>
                        <xsl:choose>
                            <xsl:when test="every $old.pnum in $prev.pnum.int satisfies (every $new.pnum in $current.pnum.int satisfies $old.pnum = $new.pnum)"><xsl:value-of select="'s'"/></xsl:when>
                            <xsl:when test="every $old.pnum in $prev.pnum.int satisfies (every $new.pnum in $current.pnum.int satisfies $old.pnum lt $new.pnum)"><xsl:value-of select="'u'"/></xsl:when>
                            <xsl:when test="every $old.pnum in $prev.pnum.int satisfies (every $new.pnum in $current.pnum.int satisfies $old.pnum gt $new.pnum)"><xsl:value-of select="'d'"/></xsl:when>
                            <!-- introducing a "mixed" value -->
                            <xsl:otherwise><xsl:value-of select="'m'"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>   
        </xsl:variable>
             
        <xsl:sequence select="string-join($pc.string,'')"/>
    </xsl:function>
    
    <!-- this outputs a "refined contour" parsons code, with UPPER-CASE when things move by more than a second
        a value of "t" stands for both "d" and "D" due to chords
        a value of "v" stands for both "u" and "U" due to chords
    -->
    <xsl:function name="tools:getRefinedParsonsCode" as="xs:string">
        <xsl:param name="items" as="node()*"/>
        
        <xsl:variable name="pnums" select="$items/@pnum" as="xs:string*"/>
        
        <xsl:variable name="pc.string" as="xs:string*">
            <xsl:value-of select="'.'"/>
            <xsl:for-each select="(2 to count($pnums))">
                <xsl:variable name="i" select="." as="xs:integer"/>
                <xsl:variable name="current.item" select="$items[$i]" as="node()"/>
                <xsl:variable name="current.pnum" select="$pnums[$i]" as="xs:string"/>
                <xsl:variable name="prev.pnum" select="$pnums[$i - 1]" as="xs:string"/>
                <xsl:variable name="from.chord" select="contains($prev.pnum,'[')" as="xs:boolean"/>
                <xsl:variable name="to.chord" select="contains($current.pnum,'[')" as="xs:boolean"/>
                <xsl:choose>
                    <!-- the first item in a sequence always starts with a dot -->
                    <xsl:when test="$prev.pnum = '.'"><xsl:value-of select="'.'"/></xsl:when>
                    <!-- rests will always be represented by a dot -->
                    <xsl:when test="$current.pnum = '.'"><xsl:value-of select="'.'"/></xsl:when>
                    <!-- simple note to note -->
                    <xsl:when test="not($from.chord) and not($to.chord)">
                        <xsl:variable name="interval" select="if($current.item/@intm and replace($current.item/@intm,'[\[\]]','') != '') then(xs:integer(replace($current.item/@intm,'\D',''))) else(0)" as="xs:integer"/>
                        <xsl:choose>
                            <xsl:when test="xs:integer($current.pnum) = xs:integer($prev.pnum)"><xsl:value-of select="'s'"/></xsl:when>
                            <xsl:when test="xs:integer($current.pnum) lt xs:integer($prev.pnum) and $interval gt 2"><xsl:value-of select="'D'"/></xsl:when>
                            <xsl:when test="xs:integer($current.pnum) lt xs:integer($prev.pnum)"><xsl:value-of select="'d'"/></xsl:when>
                            <xsl:when test="xs:integer($current.pnum) gt xs:integer($prev.pnum) and $interval gt 2"><xsl:value-of select="'U'"/></xsl:when>
                            <xsl:when test="xs:integer($current.pnum) gt xs:integer($prev.pnum)"><xsl:value-of select="'u'"/></xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <!-- from note to chord -->
                    <xsl:when test="not($from.chord) and $to.chord">
                        <xsl:variable name="prev.pnum.int" select="xs:integer($prev.pnum)" as="xs:integer"/>
                        <xsl:variable name="current.pnum.int" select="for $pnum in tokenize(replace($current.pnum,'[\[\]]',''),',') return xs:integer($pnum)" as="xs:integer*"/>
                        <xsl:variable name="intervals" select="for $intm in tokenize(replace($current.item/@intm,'[\[\]]',''),',') return xs:integer(replace($intm,'\D',''))" as="xs:integer*"/>
                        <xsl:choose>
                            <xsl:when test="every $pnum in $current.pnum.int satisfies $pnum = $prev.pnum.int">
                                <xsl:value-of select="'s'"/>
                            </xsl:when>
                            <xsl:when test="every $pnum in $current.pnum.int satisfies $pnum lt $prev.pnum.int">
                                <xsl:choose>
                                    <xsl:when test="every $interval in $intervals satisfies $interval gt 2">
                                        <xsl:value-of select="'D'"/>
                                    </xsl:when>
                                    <xsl:when test="some $interval in $intervals satisfies $interval gt 2">
                                        <xsl:value-of select="'t'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'d'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="every $pnum in $current.pnum.int satisfies $pnum gt $prev.pnum.int">
                                <xsl:choose>
                                    <xsl:when test="every $interval in $intervals satisfies $interval gt 2">
                                        <xsl:value-of select="'U'"/>
                                    </xsl:when>
                                    <xsl:when test="some $interval in $intervals satisfies $interval gt 2">
                                        <xsl:value-of select="'v'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'u'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <!-- introducing a "mixed" value -->
                            <xsl:otherwise><xsl:value-of select="'m'"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    
                    <!-- from chord to note -->
                    <xsl:when test="$from.chord and not($to.chord)">
                        <xsl:variable name="prev.pnum.int" select="for $pnum in tokenize(replace($prev.pnum,'[\[\]]',''),',') return xs:integer($pnum)" as="xs:integer*"/>
                        <xsl:variable name="current.pnum.int" select="xs:integer($current.pnum)" as="xs:integer"/>
                        
                        <xsl:choose>
                            <xsl:when test="every $pnum in $prev.pnum.int satisfies $pnum = $current.pnum.int"><xsl:value-of select="'s'"/></xsl:when>
                            <xsl:when test="every $pnum in $prev.pnum.int satisfies $pnum lt ($current.pnum.int - 3)"><xsl:value-of select="'U'"/></xsl:when>
                            <xsl:when test="every $pnum in $prev.pnum.int satisfies $pnum lt $current.pnum.int"><xsl:value-of select="'u'"/></xsl:when>
                            <xsl:when test="every $pnum in $prev.pnum.int satisfies $pnum gt ($current.pnum.int + 3)"><xsl:value-of select="'D'"/></xsl:when>
                            <xsl:when test="every $pnum in $prev.pnum.int satisfies $pnum gt $current.pnum.int"><xsl:value-of select="'d'"/></xsl:when>
                            <!-- introducing a "mixed" value -->
                            <xsl:otherwise><xsl:value-of select="'m'"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- from chord to chord -->
                    <xsl:when test="$from.chord and $to.chord">
                        <xsl:variable name="prev.pnum.int" select="for $pnum in tokenize(replace($prev.pnum,'[\[\]]',''),',') return xs:integer($pnum)" as="xs:integer*"/>
                        <xsl:variable name="current.pnum.int" select="for $pnum in tokenize(replace($current.pnum,'[\[\]]',''),',') return xs:integer($pnum)" as="xs:integer*"/>
                        <xsl:choose>
                            <xsl:when test="every $old.pnum in $prev.pnum.int satisfies (every $new.pnum in $current.pnum.int satisfies $old.pnum = $new.pnum)"><xsl:value-of select="'s'"/></xsl:when>
                            <xsl:when test="every $old.pnum in $prev.pnum.int satisfies (every $new.pnum in $current.pnum.int satisfies ($old.pnum lt $new.pnum -3))"><xsl:value-of select="'U'"/></xsl:when>
                            <xsl:when test="every $old.pnum in $prev.pnum.int satisfies (every $new.pnum in $current.pnum.int satisfies $old.pnum lt $new.pnum)"><xsl:value-of select="'u'"/></xsl:when>
                            <xsl:when test="every $old.pnum in $prev.pnum.int satisfies (every $new.pnum in $current.pnum.int satisfies ($old.pnum gt $new.pnum + 3))"><xsl:value-of select="'D'"/></xsl:when>
                            <xsl:when test="every $old.pnum in $prev.pnum.int satisfies (every $new.pnum in $current.pnum.int satisfies $old.pnum gt $new.pnum)"><xsl:value-of select="'d'"/></xsl:when>
                            <!-- introducing a "mixed" value -->
                            <xsl:otherwise><xsl:value-of select="'m'"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>   
        </xsl:variable>
        
        <xsl:sequence select="string-join($pc.string,'')"/>
    </xsl:function>
    
</xsl:stylesheet>