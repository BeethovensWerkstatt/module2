<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Apr 11, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSL converts parts into a score, with no further adjustments</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:mdiv" mode="rescore.parts">
        <xsl:choose>
            <xsl:when test="exists(mei:parts) and not(mei:score)">
                <xsl:variable name="parts" as="node()+">
                    <xsl:for-each select=".//mei:part">
                        <xsl:apply-templates select="." mode="rescore.parts.prep"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:comment>merged parts</xsl:comment>
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <score xmlns="http://www.music-encoding.org/ns/mei">
                        <scoreDef>
                            <xsl:apply-templates select="($parts[1]/mei:scoreDef)[1]/@*" mode="#current"/>
                            <staffGrp barthru="false">
                                <xsl:for-each select="$parts">
                                    <xsl:variable name="n" select="position()" as="xs:integer"/>
                                    <xsl:apply-templates select="child::mei:scoreDef[1]//mei:staffDef" mode="#current">
                                        <xsl:with-param name="new.n" select="$n" tunnel="yes"/>
                                    </xsl:apply-templates>
                                </xsl:for-each>
                            </staffGrp>
                        </scoreDef>
                        <xsl:apply-templates select="$parts[1]/(mei:section | mei:ending)" mode="#current">
                            <xsl:with-param name="parts" select="$parts" tunnel="yes" as="node()*"/>
                        </xsl:apply-templates>
                    </score>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>nothing to merge</xsl:comment>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mei:measure[.//mei:multiRest]" mode="rescore.parts.prep">
        <xsl:variable name="this.measure" select="." as="node()"/>
        <xsl:variable name="measure.count" select="number((.//mei:multiRest)[1]/@num) cast as xs:integer" as="xs:integer"/>
        <xsl:next-match/>
        <xsl:if test="$measure.count gt 1">
            <xsl:for-each select="2 to $measure.count">
                <xsl:variable name="number.mod" select=". - 1" as="xs:integer"/>
                <xsl:apply-templates select="$this.measure" mode="rescore.parts.clone">
                    <xsl:with-param name="number.mod" select="$number.mod" tunnel="yes"/>
                    <xsl:with-param name="rescore.parts.remove.controlevents" select="true()" as="xs:boolean" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="mei:measure/@n" mode="rescore.parts.clone">
        <xsl:param name="number.mod" tunnel="yes"/>
        <xsl:variable name="current.n" select="number(.)" as="xs:double"/>
        <xsl:attribute name="n" select="$current.n + $number.mod"/>
    </xsl:template>
    <xsl:template match="@xml:id" mode="rescore.parts.clone"/>
    <xsl:template match="mei:multiRest" mode="rescore.parts.prep rescore.parts.clone">
        <mRest xmlns="http://www.music-encoding.org/ns/mei"/>
    </xsl:template>
    <xsl:template match="mei:measure/mei:*[not(local-name() = 'staff')]" mode="rescore.parts.clone">
        <xsl:param name="rescore.parts.remove.controlevents" as="xs:boolean" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$rescore.parts.remove.controlevents"/>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- actual merging -->
    <xsl:template match="mei:staffDef/@n" mode="rescore.parts">
        <xsl:param name="new.n" tunnel="yes"/>
        <xsl:attribute name="n" select="$new.n"/>
    </xsl:template>
    <xsl:template match="mei:measure" mode="rescore.parts">
        <xsl:param name="parts" tunnel="yes" as="node()*"/>
        <xsl:variable name="measure.n" select="@n" as="xs:string"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:for-each select="1 to count($parts)">
                <xsl:variable name="new.n" select="." as="xs:integer"/>
                <xsl:variable name="current.part" select="$parts[$new.n]"/>
                <xsl:variable name="matching.measure" select="($current.part//mei:measure[@n = $measure.n])[1]" as="node()?"/>
                <xsl:choose>
                    <xsl:when test="$matching.measure">
                        <xsl:apply-templates select="$matching.measure/mei:staff" mode="rescore.parts">
                            <xsl:with-param name="new.n" select="$new.n" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <staff xmlns="http://www.music-encoding.org/ns/mei" n="{$new.n}">
                            <layer n="1">
                                <mSpace/>
                            </layer>
                        </staff>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="1 to count($parts)">
                <xsl:variable name="new.n" select="." as="xs:integer"/>
                <xsl:variable name="current.part" select="$parts[$new.n]"/>
                <xsl:variable name="matching.measure" select="($current.part//mei:measure[@n = $measure.n])[1]" as="node()?"/>
                <xsl:choose>
                    <xsl:when test="$matching.measure">
                        <xsl:apply-templates select="$matching.measure/mei:*[local-name() != 'staff']" mode="rescore.parts">
                            <xsl:with-param name="new.n" select="$new.n" tunnel="yes"/>
                            <xsl:with-param name="remove.tempo" select="xs:boolean($new.n != 1)" tunnel="yes" as="xs:boolean"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staff/@n" mode="rescore.parts">
        <xsl:param name="new.n" tunnel="yes"/>
        <xsl:attribute name="n" select="$new.n"/>
    </xsl:template>
    <xsl:template match="@staff" mode="rescore.parts">
        <xsl:param name="new.n" tunnel="yes"/>
        <xsl:attribute name="staff" select="$new.n"/>
    </xsl:template>
    <xsl:template match="mei:tempo" mode="rescore.parts">
        <xsl:param name="remove.tempo" tunnel="yes" as="xs:boolean?"/>
        <xsl:choose>
            <xsl:when test="exists($remove.tempo) and $remove.tempo = true()"/>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>