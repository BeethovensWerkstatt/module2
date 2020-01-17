<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 17, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
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
    
</xsl:stylesheet>