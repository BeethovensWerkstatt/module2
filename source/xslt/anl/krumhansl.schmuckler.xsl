<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>
                Algorithm implemented according to http://extras.humdrum.org/man/keycor/
                Attention: Simple profile uses 1, 0 for last two values of minor vector, 
                other than stated on that website!
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <!--<xsl:template match="mei:score" mode="get.krumhansl.schmuckler">
        
        <xsl:variable name="pitch.histogram" select="custom:getKrumhanslSchmucklerHistogram(.//mei:measure[5],true())" as="xs:double*"/>
        
        <!-\-<xsl:variable name="probe" select="(8,0,0,0,2,11,0,5,7,0,5,2)" as="xs:double*"/>-\->
        <histogram>
            <xsl:for-each select="$pitch.histogram">
                <value><xsl:value-of select="."/></value>
            </xsl:for-each>
        </histogram>
        <simple>
            <xsl:copy-of select="custom:getKrumhanslSchmuckler($pitch.histogram,'simple',3)"/>
        </simple>
        <krumhansl>
            <xsl:copy-of select="custom:getKrumhanslSchmuckler($pitch.histogram,'krumhansl',3)"/>
        </krumhansl>
        <aarden>
            <xsl:copy-of select="custom:getKrumhanslSchmuckler($pitch.histogram,'aarden',3)"/>
        </aarden>
        <bellman>
            <xsl:copy-of select="custom:getKrumhanslSchmuckler($pitch.histogram,'bellman',3)"/>
        </bellman>
        <temperley>
            <xsl:copy-of select="custom:getKrumhanslSchmuckler($pitch.histogram,'temperley',3)"/>
        </temperley>
        
    </xsl:template>-->
    
    <!--<xsl:template match="mei:section" mode="get.krumhansl.schmuckler">
        
        <xsl:variable name="histogram" select="custom:getKrumhanslSchmucklerHistogram(.,true())" as="xs:double*"/>
        <xsl:variable name="key" select="custom:getKrumhanslSchmuckler($histogram,'simple',1)" as="node()"/>
        
        <xsl:copy>
            <xsl:attribute name="key" select="$key/@name"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>-->
    <xsl:template match="mei:measure" mode="get.krumhansl.schmuckler">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:choose>
                <xsl:when test="$mode = 'krumhansl-1'">
                    <xsl:variable name="histogram" select="custom:getKrumhanslSchmucklerHistogram(.,true())" as="xs:double*"/>
                    <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="'S:' || custom:getKrumhanslSchmuckler($histogram,'simple',1)/@name"/>
                        <xsl:value-of select="'K:' || custom:getKrumhanslSchmuckler($histogram,'krumhansl',1)/@name"/>
                        <xsl:value-of select="'B:' || custom:getKrumhanslSchmuckler($histogram,'bellman',1)/@name"/>
                        <xsl:value-of select="'A:' || custom:getKrumhanslSchmuckler($histogram,'aarden',1)/@name"/>
                        <xsl:value-of select="'T:' || custom:getKrumhanslSchmuckler($histogram,'temperley',1)/@name"/>
                    </xsl:variable>
                    <dir xmlns="http://www.music-encoding.org/ns/mei" tstamp="1" staff="1" type="key" place="above">
                        <xsl:value-of select="string-join($key,' | ')"/>
                    </dir>
                </xsl:when>
                <xsl:when test="$mode = 'krumhansl-4'">
                    <xsl:variable name="measures" select=". | following-sibling::mei:measure[position() le 3]" as="node()+"/>
                    <xsl:variable name="histogram" select="custom:getKrumhanslSchmucklerHistogram($measures,true())" as="xs:double*"/>
                    <xsl:variable name="key" as="xs:string*">
                        <xsl:for-each select="custom:getKrumhanslSchmuckler($histogram,'simple',3)">
                            <xsl:value-of select="./@name || ' (' || ./@rating || ')'"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <dir xmlns="http://www.music-encoding.org/ns/mei" tstamp="1" staff="1" type="key" place="above">
                        <xsl:value-of select="'S: ' || string-join($key,', ')"/>
                    </dir>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:function name="custom:getKrumhanslSchmuckler">
        <xsl:param name="input" as="xs:double*"/>
        <xsl:param name="profile" as="xs:string"/>
        <xsl:param name="best.n.matches" as="xs:integer"/>
        <xsl:variable name="keys" select="('C','Db','D','Eb','E','F','F#','G','Af','A','Bf','B','Cm','C#m','Dm','Ebm','Em','Fm','F#m','Gm','G#m','Am','Bbm','Bm')" as="xs:string*"/>
        
        <!--  -->
        <xsl:variable name="ks.profile.simple" select="(2,0,1,0,1,1,0,2,0,1,0,1,2,0,1,1,0,1,0,2,1,0,1,0)" as="xs:double*"/>
        <xsl:variable name="ks.profile.krumhansl.kessler" select="(6.35,2.23,3.48,2.33,4.38,4.09,2.52,5.19,2.39,3.66,2.29,2.88,6.33,2.68,3.52,5.38,2.60,3.53,2.54,4.75,3.98,2.69,3.34,3.17)" as="xs:double*"/>
        <xsl:variable name="ks.profile.aarden.essen" select="(17.7661,0.145624,14.9265,0.160186,19.8049,11.3587,0.291248,22.062,0.145624,8.15494,0.232998,4.95122,18.2648,0.737619,14.0499,16.8599,0.702494,14.4362,0.702494,18.6161,4.56621,1.93186,7.37619,1.75623)" as="xs:double*"/>
        <xsl:variable name="ks.profile.bellman.budge" select="(16.8,0.86,12.95,1.41,13.49,11.93,1.25,20.28,1.8,8.04,0.62,10.57,18.16,0.69,12.99,13.34,1.07,11.15,1.38,21.07,7.49,1.53,0.92,10.21)" as="xs:double*"/>
        <xsl:variable name="ks.profile.temperley.kostka.payne" select="(0.748,0.06,0.488,0.082,0.067,0.46,0.096,0.715,0.104,0.366,0.057,0.4,0.712,0.084,0.474,0.618,0.049,0.460,0.105,0.747,0.404,0.067,0.133,0.33)" as="xs:double*"/>
        <xsl:variable name="comparison" as="xs:double*">
            <xsl:choose>
                <xsl:when test="$profile = 'simple'">
                    <xsl:sequence select="$ks.profile.simple"/>
                </xsl:when>
                <xsl:when test="$profile = 'krumhansl'">
                    <xsl:sequence select="$ks.profile.krumhansl.kessler"/>
                </xsl:when>
                <xsl:when test="$profile = 'aarden'">
                    <xsl:sequence select="$ks.profile.aarden.essen"/>
                </xsl:when>
                <xsl:when test="$profile = 'bellman'">
                    <xsl:sequence select="$ks.profile.bellman.budge"/>
                </xsl:when>
                <xsl:when test="$profile = 'temperley'">
                    <xsl:sequence select="$ks.profile.temperley.kostka.payne"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$ks.profile.simple"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="major" select="$comparison[position() lt 13]" as="xs:double*"/>
        <xsl:variable name="minor" select="$comparison[position() gt 12]" as="xs:double*"/>
        <xsl:variable name="results" as="node()*">
            <xsl:for-each select="1 to count($comparison)">
                <xsl:variable name="key.pos" select="position()" as="xs:integer"/><!-- 1 to 24 -->
                <xsl:variable name="this.comparison" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pitch.pos" select="." as="xs:integer"/><!-- 1 to 12 -->
                        <xsl:choose>
                            <!-- major mode -->
                            <xsl:when test="$key.pos lt 13">
                                <xsl:variable name="required.pos" select="(13 - $key.pos + $pitch.pos) mod 12" as="xs:integer"/>
                                <!-- don't ask, we've tested this properly ;-) -->
                                <xsl:value-of select="if($required.pos = 0) then($major[12]) else($major[$required.pos])"/>
                            </xsl:when>
                            <!-- minor mode -->
                            <xsl:otherwise>
                                <xsl:variable name="required.pos" select="(13 - ($key.pos mod 12) + $pitch.pos) mod 12" as="xs:integer"/>
                                <!-- don't ask, we've tested this properly ;-) -->
                                <xsl:value-of select="if($required.pos = 0) then($minor[12]) else($minor[$required.pos])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="input.sum" select="sum($input) div count($input)" as="xs:double"/>
                <xsl:variable name="comparison.sum" select="sum($this.comparison) div count($this.comparison)" as="xs:double"/>
                <xsl:variable name="x.values" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="$input[$pos] - $input.sum"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="y.values" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="$this.comparison[$pos] - $comparison.sum"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="x.times.y" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="$x.values[$pos] * $y.values[$pos]"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="x.times2" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="math:pow($x.values[$pos],2)"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="y.times2" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="math:pow($y.values[$pos],2)"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="ratio" select="sum($x.times.y) div (math:sqrt((sum($x.times2) * sum($y.times2))))" as="xs:double"/>
                <key xmlns="none" profile="{$profile}" name="{$keys[$key.pos]}" rating="{round($ratio,3)}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$results">
            <xsl:sort select="@rating" data-type="number" order="descending"/>
            <xsl:if test="position() le $best.n.matches">
                <xsl:copy-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="custom:getKrumhanslSchmucklerHistogram" as="xs:double*">
        <xsl:param name="input" as="node()*"/>
        <xsl:param name="weighted.by.duration" as="xs:boolean"/>
        <xsl:variable name="identified.pitches">
            <xsl:apply-templates select="$input" mode="ks.add.chroma"/>
        </xsl:variable>
        <xsl:for-each select="1 to 12">
            <xsl:variable name="i" select="." as="xs:integer"/>
            <xsl:variable name="relevant.notes" select="$identified.pitches//mei:note[@chroma = $i]" as="node()*"/>
            <xsl:choose>
                <xsl:when test="$weighted.by.duration">
                    <xsl:variable name="relevant.durations" as="xs:double*">
                        <xsl:for-each select="$relevant.notes">
                            <xsl:value-of select="number(ancestor-or-self::mei:*/@tstamp2) - number(ancestor-or-self::mei:*/@tstamp)"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="sum($relevant.durations)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count($relevant.notes)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    <xsl:template match="mei:note" mode="ks.add.chroma">
        <xsl:variable name="base.num" as="xs:integer">
            <xsl:choose>
                <xsl:when test="@pname='c'">1</xsl:when>
                <xsl:when test="@pname='d'">3</xsl:when>
                <xsl:when test="@pname='e'">5</xsl:when>
                <xsl:when test="@pname='f'">6</xsl:when>
                <xsl:when test="@pname='g'">8</xsl:when>
                <xsl:when test="@pname='a'">10</xsl:when>
                <xsl:when test="@pname='b'">12</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="accid.num" as="xs:integer">
            <xsl:choose>
                <xsl:when test="@accid = 'ff'">-2</xsl:when>
                <xsl:when test="@accid = 'f'">-1</xsl:when>
                <xsl:when test="@accid = 'n'">0</xsl:when>
                <xsl:when test="@accid = 's'">1</xsl:when>
                <xsl:when test="@accid = 'ss'">2</xsl:when>
                <xsl:when test="@accid = 'x'">2</xsl:when>
                <xsl:when test="@accid.ges = 'ff'">-2</xsl:when>
                <xsl:when test="@accid.ges = 'f'">-1</xsl:when>
                <xsl:when test="@accid.ges = 'n'">0</xsl:when>
                <xsl:when test="@accid.ges = 's'">1</xsl:when>
                <xsl:when test="@accid.ges = 'ss'">2</xsl:when>
                <xsl:when test="@accid.ges = 'x'">2</xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- TODO: Factor in transposing instruments!! -->
        <xsl:variable name="chroma" select="$base.num + $accid.num" as="xs:integer"/>
        <xsl:copy>
            <xsl:attribute name="chroma" select="$chroma"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>