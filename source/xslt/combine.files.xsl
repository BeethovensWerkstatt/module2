<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:bw="http://www.beethovens-werkstatt.de/ns/bw" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd math mei bw" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 06, 2018</xd:p>
            <xd:p>
                <xd:ul>
                    <xd:li>
                        <xd:b>Author:</xd:b> Johannes Kepper</xd:li>
                </xd:ul>
            </xd:p>
            <xd:p> </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="method"/>
    <!-- allowed values for param $method are:
        'plain' - no special treatment
        'strictIdentity' - files will be checked for identity in all criteria 
    
    -->
    <xsl:include href="compare/identify.identity.xsl"/>
    <xsl:include href="compare/compare.event.density.xsl"/>
    <xsl:variable name="first.file" select="//mei:mei[1]" as="node()"/>
    <xsl:variable name="second.file" select="//mei:mei[2]" as="node()"/>
    <xsl:variable name="comparison.file" select="//mei:meiCorpus[1]" as="node()"/>
    <xsl:variable name="first.file.staff.count" select="count(($first.file//mei:scoreDef)[1]//mei:staffDef)" as="xs:integer"/>
    <xsl:variable name="second.file.staff.count" select="count(($second.file//mei:scoreDef)[1]//mei:staffDef)" as="xs:integer"/>
    <xsl:template match="/">
        <xsl:variable name="merged.files" as="node()">
            <xsl:apply-templates select="$first.file" mode="first.pass"/>
        </xsl:variable>
        <xsl:variable name="output" as="node()">
            <xsl:choose>
                <xsl:when test="$method = 'plain'">
                    <xsl:copy-of select="$merged.files"/>
                </xsl:when>
                <xsl:when test="$method = ('strictIdentity','noOctIdentity')">
                    <xsl:variable name="identified.identity" as="node()">
                        <xsl:apply-templates select="$merged.files" mode="add.invariance"/>
                    </xsl:variable>
                    <xsl:copy-of select="$identified.identity"/>
                </xsl:when>
                <xsl:when test="$method = 'eventDensity'">
                    <xsl:variable name="compared.event.density" as="node()">
                        <xsl:apply-templates select="$merged.files" mode="compare.event.density"/>
                    </xsl:variable>
                    <xsl:copy-of select="$compared.event.density"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$merged.files"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="$output"/>
    </xsl:template>
    <xsl:template match="mei:scoreDef" mode="first.pass">
        <scoreDef xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@meter.count | @meter.unit" mode="#current"/>
            <staffGrp label="" symbol="none" barthru="false">
                <staffGrp symbol="brace" barthru="true">
                    <xsl:apply-templates select=".//mei:staffDef" mode="first.pass"/>
                </staffGrp>
                <staffGrp symbol="brace" barthru="true">
                    <xsl:apply-templates select="($second.file//mei:scoreDef)[1]//mei:staffDef" mode="first.pass.file.2"/>
                </staffGrp>
            </staffGrp>
        </scoreDef>
    </xsl:template>
    <xsl:template match="mei:staffDef" mode="first.pass">
        <xsl:copy>
            <xsl:apply-templates select="ancestor::mei:scoreDef/@key.sig" mode="#current"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staffDef" mode="first.pass.file.2">
        <xsl:copy>
            <xsl:apply-templates select="ancestor::mei:scoreDef/@key.sig" mode="#current"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:measure" mode="first.pass">
        <xsl:variable name="this.measure" select="." as="node()"/>
        <xsl:variable name="pos" select="count(preceding::mei:measure)" as="xs:integer"/>
        
        <!-- TODO: remove dirty hack! -->
        <xsl:variable name="off" select="if($comparison.file/@xml:id = 'x68ad7295-58c5-48a0-a321-fcf8a779551f') then(3) else(0)" as="xs:integer"/>
        <xsl:variable name="corresponding.measure" select="($second.file//mei:measure)[$pos + 1 + $off]" as="node()?"/>
        
        <!--<xsl:choose>
            <!-\- this measure has been added -\->
            <xsl:when test="$comparison.file//mei:annot[@type = 'additional.measures' and $this.measure/@xml:id = tokenize(replace(@plist,'[a-zA-Z_\.\d/]*#',''),' ')]">
                <xsl:comment>This is added</xsl:comment>
            </xsl:when>
            <!-\- the corresponding measure has been added -\->
            <xsl:when test="$comparison.file//mei:annot[@type = 'additional.measures' and $corresponding.measure/@xml:id = tokenize(replace(@plist,'[a-zA-Z_\.\d/]*#',''),' ')]">
                <xsl:comment>Corresponding is added</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$comparison.file"></xsl:copy-of>
                <xsl:comment select="'annots: ' || count($comparison.file//mei:annot[@type = 'additional.measures'])"></xsl:comment>
            </xsl:otherwise>
        </xsl:choose>-->
        
        <!-- TODO: remove dirty hack! -->
        <xsl:if test="$comparison.file/@xml:id = 'x68ad7295-58c5-48a0-a321-fcf8a779551f' and count(preceding::mei:measure) = 0">
            <measure xmlns="http://www.music-encoding.org/ns/mei" n="0">
                <staff type="file1" n="1">
                    <layer>
                        <space dur="8"/>
                    </layer>
                </staff>
                <staff type="file1" n="2">
                    <layer>
                        <space dur="8"/>
                    </layer>
                </staff>
                <staff type="file1" n="3">
                    <layer>
                        <space dur="8"/>
                    </layer>
                </staff>
                <staff type="file1" n="4">
                    <layer>
                        <space dur="8"/>
                    </layer>
                </staff>
                <xsl:apply-templates select="($second.file//mei:measure)[1]/child::node()" mode="first.pass.file.2"/>
            </measure>
            <measure xmlns="http://www.music-encoding.org/ns/mei" n="1">
                <staff type="file1" n="1">
                    <layer>
                        <space dur="2" dots="1"/>
                    </layer>
                </staff>
                <staff type="file1" n="2">
                    <layer>
                        <space dur="2" dots="1"/>
                    </layer>
                </staff>
                <staff type="file1" n="3">
                    <layer>
                        <space dur="2" dots="1"/>
                    </layer>
                </staff>
                <staff type="file1" n="4">
                    <layer>
                        <space dur="2" dots="1"/>
                    </layer>
                </staff>
                <xsl:apply-templates select="($second.file//mei:measure)[2]/child::node()" mode="first.pass.file.2"/>
            </measure>
            <measure xmlns="http://www.music-encoding.org/ns/mei" n="2">
                <staff type="file1" n="1">
                    <layer>
                        <space dur="2" dots="1"/>
                    </layer>
                </staff>
                <staff type="file1" n="2">
                    <layer>
                        <space dur="2" dots="1"/>
                    </layer>
                </staff>
                <staff type="file1" n="3">
                    <layer>
                        <space dur="2" dots="1"/>
                    </layer>
                </staff>
                <staff type="file1" n="4">
                    <layer>
                        <space dur="2" dots="1"/>
                    </layer>
                </staff>
                <xsl:apply-templates select="($second.file//mei:measure)[3]/child::node()" mode="first.pass.file.2"/>
            </measure>
        </xsl:if>
        <xsl:copy>
            <xsl:attribute name="found" select="count($corresponding.measure)"/>
            <xsl:apply-templates select="mei:staff | @*" mode="#current"/>
            <xsl:apply-templates select="$corresponding.measure/mei:staff" mode="first.pass.file.2"/>
            <xsl:apply-templates select="child::mei:*[not(local-name() = 'staff')]" mode="#current"/>
            <xsl:apply-templates select="$corresponding.measure/mei:*[not(local-name() = 'staff')]" mode="first.pass.file.2"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staffDef/@n" mode="first.pass.file.2">
        <xsl:variable name="current.n" select="number(.)" as="xs:double"/>
        <xsl:attribute name="n" select="$current.n + $first.file.staff.count"/>
    </xsl:template>
    <xsl:template match="mei:staff/@n" mode="first.pass">
        <xsl:next-match/>
        <xsl:attribute name="type" select="'file1'"/>
    </xsl:template>
    <xsl:template match="mei:staff/@n" mode="first.pass.file.2">
        <xsl:variable name="current.n" select="number(.)" as="xs:double"/>
        <xsl:attribute name="n" select="$current.n + $first.file.staff.count"/>
        <xsl:attribute name="type" select="'file2'"/>
    </xsl:template>
    <xsl:template match="@staff" mode="first.pass.file.2">
        <xsl:variable name="current.n" select="number(.)" as="xs:double"/>
        <xsl:attribute name="staff" select="$current.n + $first.file.staff.count"/>
    </xsl:template>
    
    
    <!-- generic copy template -->
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>