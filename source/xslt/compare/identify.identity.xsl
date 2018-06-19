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
                <custom:pitch id="{@xml:id}" pitch="{@pitch}" rel.oct="{@rel.oct}" tstamp="{if(@tstamp) then(@tstamp) else(ancestor::mei:*[@tstamp]/@tstamp)}" tstamp2="{if(@tstamp2) then(@tstamp2) else(ancestor::mei:*[@tstamp2]/@tstamp2)}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="file2.pitches" as="node()*">
            <xsl:for-each select=".//mei:staff[@type = 'file2']//mei:note[@pitch]">
                <custom:pitch id="{@xml:id}" pitch="{@pitch}" rel.oct="{@rel.oct}" tstamp="{if(@tstamp) then(@tstamp) else(ancestor::mei:*[@tstamp]/@tstamp)}" tstamp2="{if(@tstamp2) then(@tstamp2) else(ancestor::mei:*[@tstamp2]/@tstamp2)}"/>
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
        <xsl:variable name="tstamp" select="             if (@tstamp) then             (@tstamp)             else             (ancestor::mei:*[@tstamp]/@tstamp)"/>
        <xsl:variable name="tstamp2" select="             if (@tstamp2) then             (@tstamp2)             else             (ancestor::mei:*[@tstamp2]/@tstamp2)"/>
        <xsl:variable name="pitch" select="@pitch"/>
        <xsl:variable name="rel.oct" select="@rel.oct"/>
        <xsl:variable name="hasMatch" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$method = 'strictIdentity'">
                    <xsl:choose>
                        <xsl:when test="$file = 'file1' and $file2.pitches/descendant-or-self::custom:pitch[@pitch = $pitch and @tstamp = $tstamp and @rel.oct = $rel.oct and @tstamp2 = $tstamp2]">
                            <xsl:value-of select="true()"/>
                        </xsl:when>
                        <xsl:when test="$file = 'file2' and $file1.pitches/descendant-or-self::custom:pitch[@pitch = $pitch and @tstamp = $tstamp and @rel.oct = $rel.oct and @tstamp2 = $tstamp2]">
                            <xsl:value-of select="true()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$method = 'noOctIdentity'">
                    <xsl:choose>
                        <xsl:when test="$file = 'file1' and $file2.pitches/descendant-or-self::custom:pitch[@pitch = $pitch and @tstamp = $tstamp and @tstamp2 = $tstamp2]">
                            <xsl:value-of select="true()"/>
                        </xsl:when>
                        <xsl:when test="$file = 'file2' and $file1.pitches/descendant-or-self::custom:pitch[@pitch = $pitch and @tstamp = $tstamp and @tstamp2 = $tstamp2]">
                            <xsl:value-of select="true()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:if test="not($hasMatch)">
                <xsl:attribute name="type" select="'noMatch'"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>