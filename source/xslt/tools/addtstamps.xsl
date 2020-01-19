<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="java:java.util.UUID" xmlns:ba="none" exclude-result-prefixes="xs math xd mei uuid ba" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 10, 2014</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This stylesheet ensures 
                that all events have tstamps to refer to. It is used in preparation
                of the proofreading of control events.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="mei:measure" mode="add.tstamps">
        <xsl:variable name="meter.count" select="preceding::mei:scoreDef[@meter.count][1]/xs:integer(@meter.count)" as="xs:integer"/>
        <xsl:variable name="meter.unit" select="preceding::mei:scoreDef[@meter.unit][1]/xs:integer(@meter.unit)" as="xs:integer"/>
        <xsl:copy>
            <xsl:attribute name="meter.count" select="$meter.count"/>
            <xsl:attribute name="meter.unit" select="$meter.unit"/>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="meter.count" select="$meter.count" tunnel="yes"/>
                <xsl:with-param name="meter.unit" select="$meter.unit" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:layer" mode="add.tstamps">
        <xsl:param name="meter.count" tunnel="yes"/>
        <xsl:param name="meter.unit" tunnel="yes"/>
        <xsl:variable name="events" select=".//mei:*[(@dur and not((ancestor::mei:*[@dur] or ancestor::mei:bTrem or ancestor::mei:fTrem)) and not(@grace)) or (local-name() = ('bTrem','fTrem','beatRpt','halfmRpt'))]"/>
        <xsl:variable name="durations" as="xs:double*">
            <xsl:for-each select="$events">
                <xsl:value-of select="mei:calculateDuration(.,$meter.count,$meter.unit)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="tstamps">
            <xsl:for-each select="$events">
                <xsl:variable name="pos" select="position()"/>
                <xsl:variable name="onset" select="sum($durations[position() lt $pos])"/>
                <event id="{@xml:id}" onset="{$onset}" offset="{sum($durations[position() le $pos])}"/>
                <xsl:variable name="event" select="." as="node()"/>
                <xsl:for-each select="descendant::mei:*[@dur]">
                    <xsl:variable name="child" select="." as="node()"/>
                    <xsl:if test="not($event/@dur = $child/@dur and $event/@dots = $child/@dots)">
                        <xsl:variable name="child.dur" select="mei:calculateDuration($child,$meter.count,$meter.unit)" as="xs:double"/>
                        <event id="{$child/@xml:id}" onset="{$onset}" offset="{($onset + $child.dur)}"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="tstamps" select="$tstamps" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:layer//mei:*[(@dur and not((ancestor::mei:*[@dur] or ancestor::mei:bTrem or ancestor::mei:fTrem)) and not(@grace)) or (local-name() = ('bTrem','fTrem','beatRpt','halfmRpt'))]" mode="add.tstamps">
        <xsl:param name="tstamps" tunnel="yes"/>
        <xsl:param name="meter.count" tunnel="yes"/>
        <xsl:param name="meter.unit" tunnel="yes"/>
        <xsl:variable name="id" select="@xml:id" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="exists($tstamps//*[@id=$id])">
                <xsl:variable name="onset" select="$tstamps//*[@id=$id]/@onset"/>
                <xsl:variable name="offset" select="$tstamps//*[@id=$id]/@offset"/>
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:choose>
                        <xsl:when test="local-name() = 'bTrem'">
                            <xsl:copy-of select="child::mei:*/@dur | child::mei:*/@dots"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'fTrem'">
                            <xsl:copy-of select="(child::mei:*)[1]/@dur | (child::mei:*)[1]/@dots"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'beatRpt'">
                            <xsl:attribute name="dur" select="$meter.unit"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'halfmRpt'">
                            <xsl:choose>
                                <xsl:when test="$meter.count = 4 and $meter.unit = 4">
                                    <xsl:attribute name="dur" select="2"/>
                                </xsl:when>
                                <xsl:when test="$meter.count = 6 and $meter.unit = 8">
                                    <xsl:attribute name="dur" select="4"/>
                                    <xsl:attribute name="dots" select="1"/>
                                </xsl:when>
                                <xsl:when test="$meter.count = 2 and $meter.unit = 2">
                                    <xsl:attribute name="dur" select="2"/>
                                </xsl:when>
                                <xsl:when test="$meter.count = 2 and $meter.unit = 4">
                                    <xsl:attribute name="dur" select="4"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="dur"/>
                                    <xsl:message>Could not identify the correct duration for halfmRpt</xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="tstamp" select="mei:roundTstamp(($onset * $meter.unit) + 1)"/>
                    <xsl:attribute name="tstamp2" select="mei:roundTstamp(($offset * $meter.unit) + 1)"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
        
        
        
    </xsl:template>
    
    <xsl:template match="mei:layer//mei:note[(@dur and parent::mei:chord[@dur])]" mode="add.tstamps">
        <xsl:param name="tstamps" tunnel="yes"/>
        <xsl:param name="meter.count" tunnel="yes"/>
        <xsl:param name="meter.unit" tunnel="yes"/>
        <xsl:variable name="id" select="@xml:id" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="exists($tstamps//*[@id=$id])">
                <xsl:variable name="onset" select="$tstamps//*[@id=$id]/@onset"/>
                <xsl:variable name="offset" select="$tstamps//*[@id=$id]/@offset"/>
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:choose>
                        <xsl:when test="local-name() = 'bTrem'">
                            <xsl:copy-of select="child::mei:*/@dur | child::mei:*/@dots"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'fTrem'">
                            <xsl:copy-of select="(child::mei:*)[1]/@dur | (child::mei:*)[1]/@dots"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'beatRpt'">
                            <xsl:attribute name="dur" select="$meter.unit"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'halfmRpt'">
                            <xsl:choose>
                                <xsl:when test="$meter.count = 4 and $meter.unit = 4">
                                    <xsl:attribute name="dur" select="2"/>
                                </xsl:when>
                                <xsl:when test="$meter.count = 6 and $meter.unit = 8">
                                    <xsl:attribute name="dur" select="4"/>
                                    <xsl:attribute name="dots" select="1"/>
                                </xsl:when>
                                <xsl:when test="$meter.count = 2 and $meter.unit = 2">
                                    <xsl:attribute name="dur" select="2"/>
                                </xsl:when>
                                <xsl:when test="$meter.count = 2 and $meter.unit = 4">
                                    <xsl:attribute name="dur" select="4"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="dur"/>
                                    <xsl:message>Could not identify the correct duration for halfmRpt</xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="tstamp" select="mei:roundTstamp(($onset * $meter.unit) + 1)"/>
                    <xsl:attribute name="tstamp2" select="mei:roundTstamp(($offset * $meter.unit) + 1)"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mei:mRest" mode="add.tstamps">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="tstamp" select="'1'"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:mSpace" mode="add.tstamps">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="tstamp" select="'1'"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:mRpt" mode="add.tstamps">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="tstamp" select="'1'"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:function name="mei:calculateDuration" as="xs:double">
        <xsl:param name="event" as="node()"/>
        <xsl:param name="meter.count" as="xs:integer"/>
        <xsl:param name="meter.unit" as="xs:integer"/>
        
        <xsl:variable name="dur" as="xs:double">
            <xsl:choose>
                <xsl:when test="$event/@dur">
                    <xsl:value-of select="1 div number($event/@dur)"/>
                </xsl:when>
                <xsl:when test="local-name($event) = 'bTrem'">
                    <xsl:value-of select="1 div ($event/child::mei:*)[1]/number(@dur)"/>
                </xsl:when>
                <xsl:when test="local-name($event) = 'fTrem'">
                    <xsl:value-of select="1 div (($event/child::mei:*)[1]/number(@dur) * 2)"/>
                </xsl:when>
                <xsl:when test="local-name($event) = 'beatRpt'">
                    <xsl:value-of select="1 div $meter.unit"/>
                </xsl:when>
                <xsl:when test="local-name($event) = 'halfmRpt'">
                    <xsl:value-of select="($meter.count div 2) div $meter.unit"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tupletFactor" as="xs:double">
            <xsl:choose>
                <xsl:when test="$event/ancestor::mei:tuplet">
                    <xsl:value-of select="($event/ancestor::mei:tuplet)[1]/number(@numbase) div ($event/ancestor::mei:tuplet)[1]/number(@num)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dots" as="xs:double">
            <xsl:choose>
                <xsl:when test="$event/@dots">
                    <xsl:value-of select="number($event/@dots)"/>
                </xsl:when>
                <xsl:when test="local-name($event) = 'bTrem' and $event/child::mei:*/@dots">
                    <xsl:value-of select="$event/child::mei:*[@dots]/number(@dots)"/>
                </xsl:when>
                <xsl:when test="local-name($event) = 'fTrem' and $event/child::mei:*/@dots">
                    <xsl:value-of select="$event/child::mei:*[@dots][1]/number(@dots)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="(2 * $dur - ($dur div math:pow(2,$dots))) * $tupletFactor"/>
    </xsl:function>
    <xsl:function name="mei:roundTstamp" as="xs:double">
        <xsl:param name="tstamp" as="xs:double"/>
        <xsl:value-of select="round($tstamp,5)"/>
    </xsl:function>
</xsl:stylesheet>