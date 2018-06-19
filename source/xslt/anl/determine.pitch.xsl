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
    <xsl:include href="../data/keyMatrix.xsl"/>
    <xsl:template match="mei:measure" mode="determine.pitch">
        <xsl:variable name="added.normalized.pitch" as="node()*">
            <xsl:apply-templates select="child::node()" mode="determine.pitch_add.normalized.pitch"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="$added.normalized.pitch" mode="#current">
                <!--<xsl:with-param name="file1.pitches" select="$file1.pitches" as="node()*"
                    tunnel="yes"/>
                <xsl:with-param name="file2.pitches" select="$file2.pitches" as="node()*"
                    tunnel="yes"/>-->
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:note" mode="determine.pitch_add.normalized.pitch">
        <xsl:variable name="key" select="ancestor::mei:section[@base.key]/@base.key" as="xs:string"/>
        <xsl:copy>
            <xsl:attribute name="pitch" select="custom:qualifyPitch(., $key)"/>
            <xsl:attribute name="rel.oct" select="custom:determineOct(., $key)"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- required only as exist-db doesn't support the regular math:pow function: bug! -->
    <xsl:function name="math:pow">
        <xsl:param name="base"/>
        <xsl:param name="power"/>
        <xsl:choose>
            <xsl:when test="number($base) != $base or number($power) != $power">
                <xsl:value-of select="'NaN'"/>
            </xsl:when>
            <xsl:when test="$power = 0">
                <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$base * math:pow($base, $power - 1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="custom:qualifyPitch" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="key" as="xs:string" required="yes"/>
        <xsl:variable name="mode" as="xs:string">
            <xsl:choose>
                <xsl:when test="matches(substring($key,1,1),'[A-G]')">major</xsl:when>
                <xsl:when test="matches(substring($key,1,1),'[a-g]')">minor</xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'ERROR: Unable to identify key mode'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="base.step" as="xs:double">
            <xsl:choose>
                <xsl:when test="$mode = 'major'">
                    <xsl:value-of select="number($key.matrix//custom:major/custom:base.steps/@*[local-name() = $note/@pname])"/>
                </xsl:when>
                <xsl:when test="$mode = 'minor'">
                    <xsl:value-of select="number($key.matrix//custom:minor/custom:base.steps/@*[local-name() = $note/@pname])"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="relevant.key" as="node()">
            <xsl:choose>
                <xsl:when test="$mode = 'major'">
                    <!-- major -->
                    <xsl:sequence select="$key.matrix//custom:major/custom:key[@base = lower-case(substring($key,1,1))]"/>
                </xsl:when>
                <xsl:when test="$mode = 'minor'">
                    <!-- minor -->
                    <xsl:sequence select="$key.matrix//custom:minor/custom:key[@base = lower-case(substring($key,1,1))]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'ERROR: Unable to identify relevant key'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="key.step.offset" select="number($relevant.key/@step.offset)" as="xs:double"/>
        <xsl:variable name="step" select="if($base.step + $key.step.offset lt 1) then($base.step + $key.step.offset + 7) else($base.step + $key.step.offset)" as="xs:double"/>
        <xsl:variable name="pname.baseAccid" select="number($relevant.key/@*[local-name() = $note/@pname])" as="xs:double"/>
        <xsl:variable name="key.accid.modifier" as="xs:integer">
            <xsl:choose>
                <xsl:when test="string-length($key) = 1">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:when test="substring($key,2) = 'bb'">
                    <xsl:value-of select="-2"/>
                </xsl:when>
                <xsl:when test="substring($key,2) = 'b'">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:when test="substring($key,2) = '##'">
                    <xsl:value-of select="2"/>
                </xsl:when>
                <xsl:when test="substring($key,2) = '#'">
                    <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'Unable to parse key ' || $key"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="accid.value" as="xs:double">
            <xsl:choose>
                <xsl:when test="$note/@accid">
                    <xsl:value-of select="number($key.matrix//custom:accid.mod/@*[local-name() = string($note/@accid)]) + ($pname.baseAccid * -1)"/>
                </xsl:when>
                <xsl:when test="$note/@accid.ges">
                    <xsl:value-of select="number($key.matrix//custom:accid.mod/@*[local-name() = string($note/@accid.ges)]) + ($pname.baseAccid * -1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pname.baseAccid + $key.accid.modifier"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="resulting.mod" as="xs:string">
            <xsl:choose>
                <xsl:when test="$accid.value = -3">
                    <xsl:value-of select="'---'"/>
                </xsl:when>
                <xsl:when test="$accid.value = -2">
                    <xsl:value-of select="'--'"/>
                </xsl:when>
                <xsl:when test="$accid.value = -1">
                    <xsl:value-of select="'-'"/>
                </xsl:when>
                <xsl:when test="$accid.value = 0">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$accid.value = 1">
                    <xsl:value-of select="'+'"/>
                </xsl:when>
                <xsl:when test="$accid.value = 2">
                    <xsl:value-of select="'++'"/>
                </xsl:when>
                <xsl:when test="$accid.value = 3">
                    <xsl:value-of select="'+++'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$accid.value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat(string($step),$resulting.mod)"/>
    </xsl:function>
    <xsl:function name="custom:determineOct" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="key" as="xs:string" required="yes"/>
        <xsl:variable name="pitches" select="('c','d','e','f','g','a','b')" as="xs:string+"/>
        <xsl:variable name="index.of.key" select="index-of($pitches,lower-case(substring($key,1,1)))" as="xs:integer"/>
        <xsl:variable name="index.of.pname" select="index-of($pitches,$note/@pname)" as="xs:integer"/>
        <xsl:variable name="oct.mod" select="if($index.of.pname lt $index.of.key) then(-1) else(0)" as="xs:integer"/>
        <xsl:variable name="output" select="string($note/number(@oct) + $oct.mod)" as="xs:string"/>
        <xsl:value-of select="$output"/>
    </xsl:function>
</xsl:stylesheet>