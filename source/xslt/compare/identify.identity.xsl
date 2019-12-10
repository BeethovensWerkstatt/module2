<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <!-- mode add.invariance -->
    <xsl:template match="mei:measure" mode="add.invariance">
        <xsl:variable name="file1.pitches" as="node()*">
            <xsl:for-each select=".//mei:staff[@type = 'file1']//mei:note[@pitch]">
                <custom:pitch id="{@xml:id}" pitch="{@pitch}" rel.oct="{@rel.oct}" tstamp="{if(@tstamp) then(@tstamp) else(ancestor::mei:*[@tstamp][1]/@tstamp)}" tstamp2="{if(@tstamp2) then(@tstamp2) else(ancestor::mei:*[@tstamp2][1]/@tstamp2)}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="file2.pitches" as="node()*">
            <xsl:for-each select=".//mei:staff[@type = 'file2']//mei:note[@pitch]">
                <custom:pitch id="{@xml:id}" pitch="{@pitch}" rel.oct="{@rel.oct}" tstamp="{if(@tstamp) then(@tstamp) else(ancestor::mei:*[@tstamp][1]/@tstamp)}" tstamp2="{if(@tstamp2) then(@tstamp2) else(ancestor::mei:*[@tstamp2][1]/@tstamp2)}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current">
                <xsl:with-param name="file1.pitches" select="$file1.pitches" as="node()*" tunnel="yes"/>
                <xsl:with-param name="file2.pitches" select="$file2.pitches" as="node()*" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staff" mode="add.invariance">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="file" select="string(@type)" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:note" mode="add.invariance">
        <xsl:param name="file" tunnel="yes"/>
        <xsl:param name="file1.pitches" tunnel="yes"/>
        <xsl:param name="file2.pitches" tunnel="yes"/>
        <xsl:variable name="tstamp" select="
            if (@tstamp) 
            then (@tstamp)
            else (ancestor::mei:*[@tstamp][1]/@tstamp)"/>
        <xsl:variable name="tstamp2" select="             
            if (@tstamp2) 
            then (@tstamp2)
            else (ancestor::mei:*[@tstamp2][1]/@tstamp2)"/>
        <xsl:variable name="pitch" select="@pitch"/>
        <xsl:variable name="rel.oct" select="@rel.oct"/>
        
        <!-- this variable holds the notes that need to be compared -->
        <xsl:variable name="others" select="if($file = 'file1') then($file2.pitches) else($file1.pitches)" as="node()*"/>
        
        <!-- this variable decides which notes are identical / similar to the current note and keeps there IDs -->
        <xsl:variable name="matches" as="xs:string*">
            
            <!-- identical notes -->
            <!-- Invarianz: Tonbuchstabe, Oktavlage und Tondauer identisch -->
            <xsl:for-each select="$others/descendant-or-self::custom:pitch[@pitch = $pitch and @rel.oct = $rel.oct and @tstamp = $tstamp and @tstamp2 = $tstamp2]">
                <xsl:value-of select="'id:' || @id"/>
                <xsl:value-of select="'id'"/>
            </xsl:for-each>
            
            <!-- different octave, same rhythm -->
            <!-- Oktav-Varianz: Oktavlage weicht ab, Tonbuchstabe und Tondauer identisch -->
            <xsl:for-each select="$others/descendant-or-self::custom:pitch[@pitch = $pitch and not(@rel.oct = $rel.oct) and @tstamp = $tstamp and @tstamp2 = $tstamp2]">
                <xsl:value-of select="'os:' || @id"/>
                <xsl:value-of select="'os'"/>
            </xsl:for-each>
            
            <!-- same octave, different rhythm -->
            <!-- Tondauer-Varianz: Tonbuchstabe und Oktavlage identisch, Tondauer weicht ab -->
            <xsl:for-each select="$others/descendant-or-self::custom:pitch[@pitch = $pitch and @rel.oct = $rel.oct and number(@tstamp) lt number($tstamp2) and number(@tstamp2) gt number($tstamp)]">
                <xsl:value-of select="'sd:' || @id"/>
                <xsl:value-of select="'sd'"/>
            </xsl:for-each>
            
            <!-- different octave, different rhythm -->
            <!-- Tondauer-Oktav-Varianz: Tonbuchstabe identisch, Oktavlage und Tondauer weichen ab -->
            <xsl:for-each select="$others/descendant-or-self::custom:pitch[@pitch = $pitch and not(@rel.oct = $rel.oct) and number(@tstamp) lt number($tstamp2) and number(@tstamp2) gt number($tstamp)]">
                <xsl:value-of select="'od:' || @id"/>
                <xsl:value-of select="'od'"/>
            </xsl:for-each>
            
            <!-- different pitch, same rhythm -->
            <!-- Tonhöhen-Varianz: Tondauer identisch, Tonbuchstabe weicht ab, Oktavlage beliebig -->
            <xsl:for-each select="$others/descendant-or-self::custom:pitch[not(@pitch = $pitch) and @tstamp = $tstamp and @tstamp2 = $tstamp2]"><!-- contained same @rel.oct condition, which is nonsense -->
                <xsl:value-of select="'ts:' || @id"/>
                <xsl:value-of select="'ts'"/>
            </xsl:for-each>
            
        </xsl:variable>
        
        <!-- Differenz -->
        <xsl:variable name="hasMatch" select="count($matches) gt 0" as="xs:boolean"/>
        
        <xsl:copy>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::mei:*/@grace">
                        <xsl:value-of select="'grace'"/>
                    </xsl:when>
                    <xsl:when test="$hasMatch">
                        <xsl:value-of select="string-join($matches,' ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'noMatch'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>