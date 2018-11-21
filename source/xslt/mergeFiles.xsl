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

    <!--
    <xsl:variable name="first.file.path" select="document-uri(root())" as="xs:string"/>
    <xsl:variable name="path.tokens" select="tokenize($first.file.path,'/')" as="xs:string*"/>
    <xsl:variable name="base.path" select="string-join($path.tokens[position() lt count($path.tokens)],'/')" as="xs:string"/>
    <xsl:variable name="second.file" select="(collection($base.path)//mei:mei[@xml:id = $second.file.id])[1]" as="node()"/>-->
    <xsl:variable name="first.file" select="//mei:mei[1]" as="node()"/>
    <xsl:variable name="second.file" select="//mei:mei[2]" as="node()"/>
    <xsl:variable name="first.file.staff.count" select="count(($first.file//mei:scoreDef)[1]//mei:staffDef)" as="xs:integer"/>
    <xsl:variable name="second.file.staff.count" select="count(($second.file//mei:scoreDef)[1]//mei:staffDef)" as="xs:integer"/>

    <!-- start the transformation -->
    <xsl:template match="/">
        <!--<result>
            count
            <xsl:value-of select="count($first.file//mei:measure)"/>
            count
            <xsl:value-of select="count($second.file//mei:measure)"/>
        </result>
        -->
        <xsl:variable name="merged.files" as="node()">
            <xsl:apply-templates select="$first.file" mode="first.pass"/>
        </xsl:variable>
        <xsl:variable name="added.ids" as="node()">
            <xsl:apply-templates select="$merged.files" mode="add.ids"/>
        </xsl:variable>
        <xsl:variable name="added.tstamps" as="node()">
            <xsl:apply-templates select="$added.ids" mode="add.tstamps"/>
        </xsl:variable>
        <xsl:variable name="added.harmonic.rhythm" as="node()">
            <xsl:apply-templates select="$added.tstamps" mode="add.harmonic.rhythm"/>
        </xsl:variable>
        <xsl:variable name="added.invariance" as="node()">
            <xsl:apply-templates select="$added.harmonic.rhythm" mode="add.invariance"/>
        </xsl:variable>
        <xsl:copy-of select="$added.invariance"/>
    </xsl:template>
    <xsl:template match="mei:scoreDef" mode="first.pass">
        <scoreDef xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@meter.count | @meter.unit" mode="#current"/>
            <staffGrp label="" symbol="none" barthru="false">
                <staffGrp label="Op.14,1 Strings" symbol="brace" barthru="true">
                    <xsl:apply-templates select=".//mei:staffDef" mode="first.pass"/>
                </staffGrp>
                <staffGrp label="Op.14,1 Piano" symbol="brace" barthru="true">
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
        <xsl:variable name="pos" select="count(preceding::mei:measure)" as="xs:integer"/>
        <xsl:variable name="corresponding.measure" select="($second.file//mei:measure)[$pos + 1]" as="node()?"/>
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

    <!-- mode add.ids -->
    <xsl:template match="mei:*[not(@xml:id)]" mode="add.ids">
        <xsl:copy>
            <xsl:attribute name="xml:id" select="concat('mergedFile_', generate-id())"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>


    <!-- mode add.tstamps -->

    <!-- this template adds temporary attributes @meter.count and @meter.unit to the measure -->
    <xsl:template match="mei:measure" mode="add.tstamps">
        <xsl:variable name="meter.count" select="preceding::mei:scoreDef[@meter.count][1]/@meter.count cast as xs:integer" as="xs:integer"/>
        <xsl:variable name="meter.unit" select="preceding::mei:scoreDef[@meter.unit][1]/@meter.unit cast as xs:integer" as="xs:integer"/>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="meter.count" select="$meter.count" tunnel="yes"/>
                <xsl:with-param name="meter.unit" select="$meter.unit" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- this template creates a variable with all tstamps, which are then copied to all timed events in the layer -->
    <xsl:template match="mei:layer" mode="add.tstamps">
        <xsl:param name="meter.count" tunnel="yes"/>
        <xsl:param name="meter.unit" tunnel="yes"/>
        <xsl:variable name="events" select=".//mei:*[(@dur and not((ancestor::mei:*[@dur] or ancestor::mei:bTrem or ancestor::mei:fTrem)) and not(@grace)) or (local-name() = ('bTrem', 'fTrem', 'beatRpt', 'halfmRpt'))]"/>
        <xsl:variable name="durations" as="xs:double*">
            <xsl:for-each select="$events">
                <xsl:variable name="dur" as="xs:double">
                    <xsl:choose>
                        <xsl:when test="@dur">
                            <xsl:value-of select="1 div number(@dur)"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'bTrem'">
                            <xsl:value-of select="1 div (child::mei:*)[1]/number(@dur)"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'fTrem'">
                            <xsl:value-of select="1 div ((child::mei:*)[1]/number(@dur) * 2)"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'beatRpt'">
                            <xsl:value-of select="1 div $meter.unit"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'halfmRpt'">
                            <xsl:value-of select="($meter.count div 2) div $meter.unit"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="tupletFactor" as="xs:double">
                    <xsl:choose>
                        <xsl:when test="ancestor::mei:tuplet">
                            <xsl:value-of select="(ancestor::mei:tuplet)[1]/number(@numbase) div (ancestor::mei:tuplet)[1]/number(@num)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="dots" as="xs:double">
                    <xsl:choose>
                        <xsl:when test="@dots">
                            <xsl:value-of select="number(@dots)"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'bTrem' and child::mei:*/@dots">
                            <xsl:value-of select="child::mei:*[@dots]/number(@dots)"/>
                        </xsl:when>
                        <xsl:when test="local-name() = 'fTrem' and child::mei:*/@dots">
                            <xsl:value-of select="child::mei:*[@dots][1]/number(@dots)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="0"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="(2 * $dur - ($dur div math:pow(2, $dots))) * $tupletFactor"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="tstamps">
            <xsl:for-each select="$events">
                <xsl:variable name="pos" select="position()"/>
                <event id="{@xml:id}" onset="{sum($durations[position() lt $pos])}" offset="{sum($durations[position() le $pos])}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="tstamps" select="$tstamps" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- this template adds a @tstamp to each event -->
    <xsl:template match="mei:layer//mei:*[(@dur and not((ancestor::mei:*[@dur] or ancestor::mei:bTrem or ancestor::mei:fTrem)) and not(@grace)) or (local-name() = ('bTrem', 'fTrem', 'beatRpt', 'halfmRpt'))]" mode="add.tstamps">
        <xsl:param name="tstamps" tunnel="yes"/>
        <xsl:param name="meter.count" tunnel="yes"/>
        <xsl:param name="meter.unit" tunnel="yes"/>
        <xsl:variable name="id" select="@xml:id" as="xs:string"/>
        <xsl:variable name="onset" select="$tstamps//*[@id = $id]/@onset"/>
        <xsl:variable name="offset" select="$tstamps//*[@id = $id]/@offset"/>
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
                            <xsl:message terminate="yes">Could not identify the correct duration for
                                halfmRpt</xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
            <xsl:variable name="tstamp" select="($onset * $meter.unit) + 1" as="xs:double"/>
            <xsl:attribute name="tstamp" select="$tstamp"/>
            <xsl:variable name="tstamp2" select="($offset * $meter.unit) + 1" as="xs:double"/>
            <xsl:attribute name="tstamp2" select="$tstamp2"/>

            <!-- check for beamSpans starting at this element -->
            <xsl:variable name="staff.n" select="ancestor::mei:staff/@n" as="xs:string"/>
            <!-- todo: improve on situations with multiple layers! -->
            <xsl:variable name="beamSpans" select="ancestor::mei:measure//mei:beamSpan[@staff = $staff.n]" as="node()*"/>

            <!--todo: is it robust enough?-->
            <xsl:variable name="matching.beamSpan" select="$beamSpans[@tstamp = string($tstamp) or (contains(@tstamp2, 'm+') and substring-after(@tstamp2, 'm+') = string($tstamp)) or @tstamp2 = string($tstamp)][1]" as="node()?"/>
            <xsl:choose>
                <xsl:when test="$matching.beamSpan/@tstamp = string($tstamp)">
                    <xsl:attribute name="beam" select="'i'"/>
                    <xsl:attribute name="beamSpan.id" select="$matching.beamSpan/@xml:id"/>
                </xsl:when>
                <xsl:when test="contains($matching.beamSpan/@tstamp2, 'm+') and substring-after($matching.beamSpan/@tstamp2, 'm+') = string($tstamp)">
                    <xsl:attribute name="beam" select="'t'"/>
                    <xsl:attribute name="beamSpan.id" select="$matching.beamSpan/@xml:id"/>
                </xsl:when>
                <xsl:when test="$matching.beamSpan/@tstamp2 = string($tstamp)">
                    <xsl:attribute name="beam" select="'t'"/>
                    <xsl:attribute name="beamSpan.id" select="$matching.beamSpan/@xml:id"/>
                </xsl:when>
                <xsl:when test="                         some $beamSpan in $beamSpans                             satisfies ($tstamp gt $beamSpan/number(@tstamp) and (if (contains($beamSpan/@tstamp2, 'm+')) then                                 ($tstamp lt number($beamSpan/substring-after(@tstamp2, 'm+')))                             else                                 ($tstamp lt number($beamSpan/@tstamp2))))">
                    <xsl:variable name="relevant.beamSpan" select="                             $beamSpans[$tstamp gt number(@tstamp) and (if (contains(@tstamp2, 'm+')) then                                 ($tstamp lt number(substring-after(@tstamp2, 'm+')))                             else                                 ($tstamp lt number(@tstamp2)))][1]" as="node()"/>
                    <xsl:attribute name="beam" select="'m'"/>
                    <xsl:attribute name="beamSpan.id" select="$relevant.beamSpan/@xml:id"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
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


    <!-- mode add.harmonic.rhythm -->
    <xsl:template match="mei:measure" mode="add.harmonic.rhythm">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:variable name="first.file.staves" select="child::mei:staff[number(@n) le $first.file.staff.count]" as="node()+"/>
            <xsl:variable name="second.file.staves" select="child::mei:staff[number(@n) gt $first.file.staff.count]" as="node()+"/>
            <xsl:variable name="first.file.tstamps" select="distinct-values(.//$first.file.staves//@tstamp)" as="xs:string+"/>
            <xsl:variable name="second.file.tstamps" select="distinct-values(.//$second.file.staves//@tstamp)" as="xs:string+"/>
            <xsl:for-each select="$first.file.tstamps">
                <xsl:sort select="." data-type="number"/>
                <harm xmlns="http://www.music-encoding.org/ns/mei" staff="{$first.file.staff.count}" place="below" tstamp="{.}">
                    <xsl:if test="not(. = $second.file.tstamps)">
                        <xsl:attribute name="type" select="'file1only'"/>
                    </xsl:if>
                    <xsl:text>|</xsl:text>
                </harm>
            </xsl:for-each>
            <xsl:for-each select="$second.file.tstamps">
                <xsl:sort select="." data-type="number"/>
                <harm xmlns="http://www.music-encoding.org/ns/mei" staff="{$first.file.staff.count + 1}" place="above" tstamp="{.}">
                    <xsl:if test="not(. = $first.file.tstamps)">
                        <xsl:attribute name="type" select="'file2only'"/>
                    </xsl:if>
                    <xsl:text>|</xsl:text>
                </harm>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>


    <!-- mode add.invariance -->
    <xsl:template match="mei:measure" mode="add.invariance">
        <xsl:variable name="added.normalized.pitch">
            <xsl:apply-templates select="child::node()" mode="add.normalized.pitch"/>
        </xsl:variable>
        <xsl:variable name="file1.pitches" as="node()*">
            <xsl:for-each select="$added.normalized.pitch//mei:staff[@type = 'file1']//mei:note[@pitch]">
                <bw:pitch id="{@xml:id}" pitch="{@pitch}" rel.oct="{@rel.oct}" tstamp="{if(@tstamp) then(@tstamp) else(ancestor::mei:*[@tstamp]/@tstamp)}" tstamp2="{if(@tstamp2) then(@tstamp2) else(ancestor::mei:*[@tstamp2]/@tstamp2)}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="file2.pitches" as="node()*">
            <xsl:for-each select="$added.normalized.pitch//mei:staff[@type = 'file2']//mei:note[@pitch]">
                <bw:pitch id="{@xml:id}" pitch="{@pitch}" rel.oct="{@rel.oct}" tstamp="{if(@tstamp) then(@tstamp) else(ancestor::mei:*[@tstamp]/@tstamp)}" tstamp2="{if(@tstamp2) then(@tstamp2) else(ancestor::mei:*[@tstamp2]/@tstamp2)}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="$added.normalized.pitch" mode="#current">
                <xsl:with-param name="file1.pitches" select="$file1.pitches" as="node()*" tunnel="yes"/>
                <xsl:with-param name="file2.pitches" select="$file2.pitches" as="node()*" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staff" mode="add.normalized.pitch">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="key" select="                         if (@type = 'file1') then                             ('F')                         else                             ('E')" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:note" mode="add.normalized.pitch">
        <xsl:param name="key" tunnel="yes"/>
        <xsl:copy>
            <xsl:attribute name="pitch" select="bw:qualifyPitch(., $key)"/>
            <xsl:attribute name="rel.oct" select="bw:determineOct(., $key)"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
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
        <xsl:variable name="tstamp" select="                 if (@tstamp) then                     (@tstamp)                 else                     (ancestor::mei:*[@tstamp]/@tstamp)"/>
        <xsl:variable name="tstamp2" select="             if (@tstamp2) then             (@tstamp2)             else             (ancestor::mei:*[@tstamp2]/@tstamp2)"/>
        <xsl:variable name="pitch" select="@pitch"/>
        <xsl:variable name="rel.oct" select="@rel.oct"/>
        <xsl:variable name="hasMatch" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$file = 'file1' and $file2.pitches/descendant-or-self::bw:pitch[@pitch = $pitch and @tstamp = $tstamp and @rel.oct = $rel.oct and @tstamp2 = $tstamp2]">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:when test="$file = 'file2' and $file1.pitches/descendant-or-self::bw:pitch[@pitch = $pitch and @tstamp = $tstamp and @rel.oct = $rel.oct and @tstamp2 = $tstamp2]">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:if test="not($hasMatch)">
                <xsl:attribute name="type" select="'noMatch'"/>
            </xsl:if>
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
    <xsl:function name="bw:qualifyPitch" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="key" as="xs:string" required="yes"/>
        <xsl:choose>
            <xsl:when test="$key = 'E'">
                <xsl:choose>
                    <xsl:when test="$note/@pname = 'e'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">1-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">1</xsl:when>
                            <xsl:when test="$note/@accid = 's'">1+</xsl:when>
                            <xsl:when test="$note/@accid = 'ss'">1++</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">1-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">1</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">1+</xsl:when>
                            <xsl:otherwise>1</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'f'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">2--</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">2-</xsl:when>
                            <xsl:when test="$note/@accid = 's'">2</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">2--</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">2-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">2</xsl:when>
                            <xsl:otherwise>2-</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'g'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">3--</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">3-</xsl:when>
                            <xsl:when test="$note/@accid = 's'">3</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">3--</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">3-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">3</xsl:when>
                            <xsl:otherwise>3-</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'a'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">4-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">4</xsl:when>
                            <xsl:when test="$note/@accid = 's'">4+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">4-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">4</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">4+</xsl:when>
                            <xsl:otherwise>4</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'b'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">5-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">5</xsl:when>
                            <xsl:when test="$note/@accid = 's'">5+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">5-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">5</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">5+</xsl:when>
                            <xsl:otherwise>5</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'c'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">6--</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">6-</xsl:when>
                            <xsl:when test="$note/@accid = 's'">6</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">6--</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">6-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">6</xsl:when>
                            <xsl:otherwise>6-</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'd'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">7--</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">7-</xsl:when>
                            <xsl:when test="$note/@accid = 's'">7</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">7--</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">7-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">7</xsl:when>
                            <xsl:otherwise>7-</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$key = 'F'">
                <xsl:choose>
                    <xsl:when test="$note/@pname = 'f'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">1-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">1</xsl:when>
                            <xsl:when test="$note/@accid = 's'">1+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">1-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">1</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">1+</xsl:when>
                            <xsl:otherwise>1</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'g'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">2-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">2</xsl:when>
                            <xsl:when test="$note/@accid = 's'">2+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">2-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">2</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">2+</xsl:when>
                            <xsl:otherwise>2</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'a'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">3-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">3</xsl:when>
                            <xsl:when test="$note/@accid = 's'">3+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">3-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">3</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">3+</xsl:when>
                            <xsl:otherwise>3</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'b'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">4</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">4+</xsl:when>
                            <xsl:when test="$note/@accid = 's'">4++</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">4</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">4+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">4++</xsl:when>
                            <xsl:otherwise>4+</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'c'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">5-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">5</xsl:when>
                            <xsl:when test="$note/@accid = 's'">5+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">5-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">5</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">5+</xsl:when>
                            <xsl:otherwise>5</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'd'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">6-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">6</xsl:when>
                            <xsl:when test="$note/@accid = 's'">6+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">6-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">6</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">6+</xsl:when>
                            <xsl:otherwise>6</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$note/@pname = 'e'">
                        <xsl:choose>
                            <xsl:when test="$note/@accid = 'f'">7-</xsl:when>
                            <xsl:when test="$note/@accid = 'n'">7</xsl:when>
                            <xsl:when test="$note/@accid = 's'">7+</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'f'">7-</xsl:when>
                            <xsl:when test="$note/@accid.ges = 'n'">7</xsl:when>
                            <xsl:when test="$note/@accid.ges = 's'">7+</xsl:when>
                            <xsl:otherwise>7</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="bw:determineOct" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="key" as="xs:string" required="yes"/>
        <xsl:variable name="pitches" select="('c','d','e','f','g','a','b')" as="xs:string+"/>
        <xsl:variable name="index.of.key" select="index-of($pitches,lower-case(substring($key,1,1)))" as="xs:integer"/>
        <xsl:variable name="index.of.pname" select="index-of($pitches,$note/@pname)" as="xs:integer"/>
        <xsl:variable name="oct.mod" select="if($index.of.pname lt $index.of.key) then(-1) else(0)" as="xs:integer"/>
        <xsl:variable name="output" select="string($note/number(@oct) + $oct.mod)" as="xs:string"/>
        <xsl:value-of select="$output"/>
    </xsl:function>

    <!-- generic copy template -->
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>