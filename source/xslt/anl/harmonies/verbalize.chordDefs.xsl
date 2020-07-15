<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tools="no:link" xmlns:temp="no:link" xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei tools temp custom" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 19, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:chordDef" mode="verbalize.chordDefs.thirds-based-chords.plain">
        <xsl:variable name="chordDef" select="." as="node()"/>
        <xsl:variable name="root.chordMember" select="mei:chordMember[@inth = 'P1' and @temp:cost = '0']" as="node()"/>
        <xsl:variable name="bass.chordMember" select="mei:chordMember[@pname = $chordDef/@temp:bass and @temp:pclass = $chordDef/@temp:bass.pclass][1]" as="node()?"/>
        
        <xsl:if test="count($bass.chordMember) = 0">
            <xsl:message select="'Anfang Problem ' || ancestor::mei:measure/@n"/>
            <xsl:message select="$chordDef" terminate="yes"/>
        </xsl:if>
        
        <xsl:if test="count($bass.chordMember) gt 1">
            <xsl:message select="'Anfang Problem ' || ancestor::mei:measure/@n"/>
            <xsl:message select="$chordDef" terminate="yes"/>
        </xsl:if>
        
        <xsl:variable name="root.accid" select=" if($root.chordMember/@accid.ges = 'f') then('♭') else if ($root.chordMember/@accid.ges = 's') then ('♯') else ('')"/>
        <xsl:variable name="root" select="upper-case($root.chordMember/@pname) || $root.accid" as="xs:string"/>
        
        <xsl:variable name="bass.accid" select=" if($bass.chordMember/@accid.ges = 'f') then('♭') else if ($bass.chordMember/@accid.ges = 's') then ('♯') else ('')"/>
        <xsl:variable name="bass" select="upper-case($bass.chordMember/@pname) || $bass.accid" as="xs:string"/>
        
        <!-- decides if root and bass are the same -->
        <xsl:variable name="different.bass" select="xs:boolean($root != $bass)" as="xs:boolean"/>
        
        <xsl:variable name="can.be.omitted" as="xs:boolean">
            <xsl:choose>
                <!-- when we have only two different pitches, which are further away than a fifth, skip this harm -->
                <xsl:when test="count(mei:chordMember) = 2 and max(mei:chordMember/xs:double(@temp:cost)) gt 2">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- decide if this shall we written out or not -->
        
        <xsl:if test="not($can.be.omitted)">
            <!-- generates the actual output -->
            <rend xmlns="http://www.music-encoding.org/ns/mei" type="root"><xsl:value-of select="$root"/></rend>
            
            <!--everything else than major triads:-->
            
            <!--minor chords-->
            <xsl:if test="mei:chordMember[@inth='m3'] and not(mei:chordMember[@inth=('A5', 'd5')])">
                <rend xmlns="http://www.music-encoding.org/ns/mei" type="minor">m</rend>
            </xsl:if>
            <!--no third but perfect fifth-->
            <xsl:if test="not(mei:chordMember[@temp:cost='1']) and mei:chordMember[@inth='P5']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" type="noThird" fontsize="small">no3</rend>
            </xsl:if>
            <!--diminished chord-->
            <xsl:if test="mei:chordMember[@inth = 'm3'] and mei:chordMember[@inth = 'd5']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" type="dim" fontsize="small">dim</rend>
            </xsl:if>
            <!--augmented chord-->
            <xsl:if test="mei:chordMember[@inth = 'M3'] and mei:chordMember[@inth = 'A5']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" type="aug">+</rend>
            </xsl:if>
            
            
            <!--7th chord-->
            <xsl:if test="mei:chordMember[@inth='m7' and not(@type='78ret')] and not(mei:chordMember[@temp:cost='4']) and not(mei:chordMember[@inth='d5'])">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct7">7</rend>
            </xsl:if>
            <!--major-7th chord-->
            <xsl:if test="mei:chordMember[@inth='M7' and not(@type='78ret')] and not(mei:chordMember[@temp:cost='4'])">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct7">maj7</rend>
            </xsl:if>
            <!--7th chord + dim 5th-->
            <xsl:if test="mei:chordMember[@inth='m7' and not(@type='78ret')] and mei:chordMember[@inth='d5']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct7dim5">7♭5</rend>
            </xsl:if>
            <!--7th chord + aug 5th-->
            <xsl:if test="mei:chordMember[@inth='m7' and not(@type='78ret')] and mei:chordMember[@inth='A5']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct7aug5">7♯5</rend>
            </xsl:if>
            <!-- major 9th chord-->
            <xsl:if test="mei:chordMember[@inth='m7' and not(@type='78ret')] and mei:chordMember[@inth='M2' and not(@type='98sus') and not(@type='23ret')]">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct9">9</rend>
            </xsl:if>
            <!--major 7th and maj 9th chord-->
            <xsl:if test="mei:chordMember[@inth='M7' and not(@type='78ret')] and mei:chordMember[@inth='M2' and not(@type='98sus')]">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct9">maj9</rend>
            </xsl:if>
            <!--7th and minor-9th chord-->
            <xsl:if test="mei:chordMember[@inth='m7'] and mei:chordMember[@inth='m2']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct9">♭9</rend>
            </xsl:if>
            <!--7th and augmented 9th chord-->
            <xsl:if test="mei:chordMember[@inth='m7' and not(@type='78ret')] and mei:chordMember[@inth='A2' and not(@type='98sus')]">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct9">♯9</rend>
            </xsl:if>
            <!--9 added to a triad without 7th-->
            <xsl:if test="not(mei:chordMember[@temp:cost='3']) and mei:chordMember[@inth='M2'] and not(mei:chordMember[@type='98sus']) and not(mei:chordMember[@type='23ret'])">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct9">add9</rend>
            </xsl:if>
            <!--chord with 7th, 9th and 11th-->
            <xsl:if test="mei:chordMember[@inth='m7' and not(@type='78ret')] and mei:chordMember[@inth='M2' and not(@type='98sus')] and mei:chordMember[@inth='P4']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="ct9">11</rend>
            </xsl:if>
            
            
            <xsl:if test="count(mei:chordMember[contains(@type,'sus') or contains(@type,'ret')]) = 1">
                <xsl:variable name="rends">
                    <xsl:if test="mei:chordMember[@type='43sus']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod43sus">4-3</rend>
                    </xsl:if>
                    <xsl:if test="mei:chordMember[@type='65sus']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod65sus">6-5</rend>
                    </xsl:if>
                    <xsl:if test="mei:chordMember[@type='98sus']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod98sus">9-8</rend>
                    </xsl:if>
                    <xsl:if test="mei:chordMember[@type='23ret']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod23ret">2-3</rend>
                    </xsl:if>
                    <xsl:if test="mei:chordMember[@type='78ret']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod78ret">7-8</rend>
                    </xsl:if>
                </xsl:variable>
                <xsl:sequence select="$rends"/>
            </xsl:if>
            
            <xsl:if test="count(mei:chordMember[contains(@type,'sus') or contains(@type,'ret')]) gt 1"> 
                <xsl:variable name="many_rends">
                    <xsl:if test="mei:chordMember[@type='43sus']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod43sus">4-3</rend>
                    </xsl:if>
                    <xsl:if test="mei:chordMember[@type='65sus']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod65sus">6-5</rend>
                    </xsl:if>
                    <xsl:if test="mei:chordMember[@type='98sus']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod98sus">9-8</rend>
                    </xsl:if>
                    <xsl:if test="mei:chordMember[@type='23ret']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod23ret">2-3</rend>
                    </xsl:if>
                    <xsl:if test="mei:chordMember[@type='78ret']">
                        <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod78ret">7-8</rend>
                    </xsl:if>
                </xsl:variable>
                
                <xsl:if test="$many_rends/mei:rend[position() eq 1]">
                    <xsl:sequence select="$many_rends/mei:rend[position() eq 1]"/>
                </xsl:if>
                
                <xsl:if test="$many_rends/mei:rend[position() eq 2]">
                    <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup">|</rend>
                    <xsl:sequence select="$many_rends/mei:rend[position() eq 2]"/>
                </xsl:if>
                <xsl:if test="$many_rends/mei:rend[position() eq 3]">
                    <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup">|</rend>
                    <xsl:sequence select="$many_rends/mei:rend[position() eq 3]"/>
                </xsl:if>
                
                <xsl:if test="$many_rends/mei:rend[position() eq 4]">
                    <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup">|</rend>
                    <xsl:sequence select="$many_rends/mei:rend[position() eq 4]"/>
                </xsl:if>
                <xsl:if test="$many_rends/mei:rend[position() eq 5]">
                    <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup">|</rend>
                    <xsl:sequence select="$many_rends/mei:rend[position() eq 5]"/>
                </xsl:if>
            </xsl:if>
            
            
            <xsl:if test="mei:chordMember[@type='2upt']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod2upt">2upt</rend>
            </xsl:if>
            <xsl:if test="mei:chordMember[@type='4upt']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod4upt">4upt</rend>
            </xsl:if>
            <xsl:if test="mei:chordMember[@type='6upt']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod6upt">6upt</rend>
            </xsl:if>
            <xsl:if test="mei:chordMember[@type='2un']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod2un">2un</rend>
            </xsl:if>
            <xsl:if test="mei:chordMember[@type='4un']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod4un">4un</rend>
            </xsl:if>
            <xsl:if test="mei:chordMember[@type='6un']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod6un">6un</rend>
            </xsl:if>
            <xsl:if test="mei:chordMember[@type='2ln']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod2ln">2ln</rend>
            </xsl:if>
            <xsl:if test="mei:chordMember[@type='4ln']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod4ln">4ln</rend>
            </xsl:if>
            <xsl:if test="mei:chordMember[@type='6ln']">
                <rend xmlns="http://www.music-encoding.org/ns/mei" rend="sup" type="mod6ln">6ln</rend>
            </xsl:if>
            <xsl:if test="$different.bass">
                <rend xmlns="http://www.music-encoding.org/ns/mei" type="bass">/<xsl:value-of select="$bass"/></rend>
            </xsl:if> 
            
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>