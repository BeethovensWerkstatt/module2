<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:bw="http://www.beethovens-werkstatt.de/ns/bw" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xs xd math mei bw xlink" version="3.0">
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
        'comparison' - files will be checked for identity in all criteria 
    
    -->
    
    <xsl:param name="transpose.mode"/>
    <!-- allowed values for param $transpose.mode are:
        'none' - both files are kept as they are
        'matchFile1' - transpose second file to key of first file 
        'matchFile2' - transpose first file to key of second file
        'C' - transpose both files to the key of C for easier reading
    
    -->
    
    <xsl:include href="tools/transpose.xsl"/>
    <xsl:include href="data/circleOf5.xsl"/>
    <xsl:include href="data/keyMatrix.xsl"/>
    
    <xsl:include href="compare/identify.identity.xsl"/>
    <xsl:include href="compare/compare.event.density.xsl"/>
    <xsl:include href="compare/compare.harmonics.xsl"/>
    
    <xsl:include href="compare/determine.variation.xsl"/>
    
    <xsl:include href="compare/adjust.rel.oct.xsl"/>
    
    <xsl:include href="compare/cleanupDynam.xsl"/>
    
    <xsl:variable name="first.file" as="node()">
        
        <xsl:choose>
            <!-- no transposing for melodicComparison on file 1 (this is a hack!) -->
            <xsl:when test="$method = 'melodicComparison'">
                <xsl:sequence select="//mei:mei[1]"/>
            </xsl:when>
            <!-- no file shall be transposed -->
            <xsl:when test="$transpose.mode = 'none'">
                <xsl:sequence select="//mei:mei[1]"/>
            </xsl:when>
            <!-- the other file shall be transposed, not this one -->
            <xsl:when test="$transpose.mode = 'matchFile1'">
                <xsl:sequence select="//mei:mei[1]"/>
            </xsl:when>
            <!-- this file needs to be transposed to match file 2 -->
            <xsl:when test="$transpose.mode = 'matchFile2'">
                
                <!-- determine other file's key -->
                <xsl:variable name="target.key" select="(//mei:mei[2]//mei:section)[1]/@base.key" as="xs:string"/>
                
                <xsl:apply-templates select="//mei:mei[1]" mode="transpose">
                    <xsl:with-param name="target.key.name" select="$target.key" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- this file shall be transposed to avoid accidentals as much as possible -->
            <xsl:when test="$transpose.mode = 'C'">
                <xsl:apply-templates select="//mei:mei[1]" mode="transpose">
                    <xsl:with-param name="target.key.name" select="'C'" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="//mei:mei[1]"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:variable>
    <xsl:variable name="second.file" as="node()">
        
        <xsl:choose>
            <!-- no transposing for melodicComparison on file 1 (this is a hack!) -->
            <xsl:when test="$method = 'melodicComparison'">
                <xsl:choose>
                    <xsl:when test="$comparison.file/@xml:id = 'x418650e0-d899-4e3d-bff3-f7d459e1d5d7'">
                        <xsl:apply-templates select="//mei:mei[2]" mode="special.transpose"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="//mei:mei[2]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- no file shall be transposed -->
            <xsl:when test="$transpose.mode = 'none'">
                <xsl:sequence select="//mei:mei[2]"/>
            </xsl:when>
            <!-- the other file shall be transposed, not this one -->
            <xsl:when test="$transpose.mode = 'matchFile1'">
                
                <!-- determine other file's key first -->
                <xsl:variable name="target.key" select="(//mei:mei[1]//mei:section)[1]/@base.key" as="xs:string"/>
                
                <xsl:apply-templates select="//mei:mei[2]" mode="transpose">
                    <xsl:with-param name="target.key.name" select="$target.key" tunnel="yes"/>
                </xsl:apply-templates>
                
            </xsl:when>
            <!-- this file needs to be transposed to match file 2 -->
            <xsl:when test="$transpose.mode = 'matchFile2'">
                
                <xsl:sequence select="//mei:mei[2]"/>
                
            </xsl:when>
            <!-- this file shall be transposed to avoid accidentals as much as possible -->
            <xsl:when test="$transpose.mode = 'C'">
                <xsl:apply-templates select="//mei:mei[2]" mode="transpose">
                    <xsl:with-param name="target.key.name" select="'C'" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="//mei:mei[2]"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:variable>
    <xsl:variable name="comparison.file" select="//mei:meiCorpus[1]" as="node()"/>
    <xsl:variable name="first.file.staff.count" select="count(($first.file//mei:scoreDef)[1]//mei:staffDef)" as="xs:integer"/>
    <xsl:variable name="second.file.staff.count" select="count(($second.file//mei:scoreDef)[1]//mei:staffDef)" as="xs:integer"/>
    
    <xsl:template match="/">
        <xsl:variable name="output" as="node()">
            <xsl:choose>
                <xsl:when test="$method = 'plain'">
                    <xsl:variable name="merged.files" as="node()">
                        <xsl:apply-templates select="$first.file" mode="first.pass"/>
                    </xsl:variable>
                    <xsl:copy-of select="$merged.files"/>
                </xsl:when>
                <xsl:when test="$method = ('comparison','geneticComparison')">
                    <xsl:variable name="merged.files" as="node()">
                        <xsl:apply-templates select="$first.file" mode="first.pass"/>
                    </xsl:variable>
                    <xsl:variable name="adjusted.rel.oct" as="node()">
                        <xsl:apply-templates select="$merged.files" mode="adjust.rel.oct"/>
                    </xsl:variable>
                    <xsl:variable name="identified.identity" as="node()">
                        <xsl:apply-templates select="$adjusted.rel.oct" mode="add.invariance"/>
                    </xsl:variable>
                    <xsl:variable name="determined.variation" as="node()">
                        <xsl:apply-templates select="$identified.identity" mode="determine.variation"/>
                    </xsl:variable>
                    <xsl:copy-of select="$determined.variation"/>
                </xsl:when>
                <xsl:when test="$method = 'melodicComparison'">
                    
                    <results>
                            
                        <file n="1">
                            <xsl:apply-templates select="$first.file//mdiv/@*" mode="#current"/>
                            <xsl:choose>
                                <xsl:when test="$comparison.file/@xml:id = 'x68ad7295-58c5-48a0-a321-fcf8a779551f'">
                                    <xsl:copy-of select="$second.file//mdiv/measure[position() lt 4]"/>
                                    <xsl:variable name="offset" select="1.625" as="xs:double"/>
                                    <xsl:apply-templates select="$first.file//mdiv/measure" mode="special.pushing">
                                        <xsl:with-param name="offset" select="$offset" tunnel="yes"/>
                                    </xsl:apply-templates>
                                    <xsl:apply-templates select="$first.file//mdiv/staff" mode="special.pushing">
                                        <xsl:with-param name="offset" select="$offset" tunnel="yes"/>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy-of select="$first.file//mdiv/measure"/>
                                    <xsl:copy-of select="$first.file//mdiv/staff"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </file>
                        <file n="2">
                            <xsl:apply-templates select="$second.file//mdiv/@*" mode="#current"/>
                            <xsl:copy-of select="$second.file//mdiv/measure"/>
                            <xsl:copy-of select="$second.file//mdiv/staff"/>
                        </file>
                        
                    </results>
                    
                </xsl:when>
                <xsl:when test="$method = 'eventDensity'">
                    <xsl:variable name="merged.files" as="node()">
                        <xsl:apply-templates select="$first.file" mode="first.pass"/>
                    </xsl:variable>
                    <xsl:variable name="compared.event.density" as="node()">
                        <xsl:apply-templates select="$merged.files" mode="compare.event.density"/>
                    </xsl:variable>
                    <xsl:copy-of select="$compared.event.density"/>
                </xsl:when>
                <xsl:when test="$method = 'harmonicComparison'">
                    <xsl:variable name="merged.files" as="node()">
                        <xsl:apply-templates select="$first.file" mode="first.pass"/>
                    </xsl:variable>
                    <xsl:variable name="compared.harmonics" as="node()">
                        <xsl:apply-templates select="$merged.files" mode="compare.harmonics"/>
                    </xsl:variable>
                    <xsl:copy-of select="$compared.harmonics"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="merged.files" as="node()">
                        <xsl:apply-templates select="$first.file" mode="first.pass"/>
                    </xsl:variable>
                    <xsl:copy-of select="$merged.files"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="cleanedup.dynamics" as="node()">
            <xsl:apply-templates select="$output" mode="clean.dynamics"/>
        </xsl:variable>
        <xsl:copy-of select="$cleanedup.dynamics"/>
    </xsl:template>
    
    <xsl:template match="mei:score/mei:scoreDef" mode="first.pass">
        <xsl:variable name="pos" select="count(preceding::mei:scoreDef) + 1" as="xs:integer"/>
        
        <scoreDef xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@meter.count | @meter.unit | @meter.sym" mode="#current"/>
            <staffGrp label="" symbol="none" bar.thru="false">
                <staffGrp symbol="bracket" bar.thru="true">
                    <xsl:apply-templates select="mei:staffGrp/node()" mode="first.pass"/>
                </staffGrp>
                <staffGrp symbol="bracket" bar.thru="true">
                    <xsl:variable name="second.file.staffDefs" select="($second.file//mei:scoreDef)[$pos]//mei:staffDef" as="node()+"/>
                    <xsl:apply-templates select="($second.file//mei:scoreDef)[$pos]/mei:staffGrp/node()" mode="first.pass.file.2"/>
                </staffGrp>
            </staffGrp>
        </scoreDef>
    </xsl:template>
    <xsl:template match="mei:section/mei:scoreDef" mode="first.pass"/>
    
    <xsl:template match="mei:staffDef" mode="first.pass">
        <xsl:copy>
            <xsl:apply-templates select="ancestor::mei:scoreDef/@key.sig" mode="#current"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:staffDef" mode="first.pass.file.2">
        <xsl:copy>
            <xsl:if test="@n = '1'">
                <xsl:attribute name="spacing" select="'40vu'"/>
            </xsl:if>
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
        
        
        <!-- check for scoreDefs in one of the files -->
        
        
        <!--<xsl:template match="mei:scoreDef" mode="first.pass">
            <xsl:variable name="pos" select="count(preceding::mei:scoreDef) + 1" as="xs:integer"/>
            
            <scoreDef xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:apply-templates select="@meter.count | @meter.unit" mode="#current"/>
                <staffGrp label="" symbol="none" bar.thru="false">
                    <staffGrp symbol="brace" bar.thru="true">
                        <xsl:apply-templates select=".//mei:staffDef" mode="first.pass"/>
                    </staffGrp>
                    <staffGrp symbol="brace" bar.thru="true">
                        <xsl:apply-templates select="($second.file//mei:scoreDef)[$pos]//mei:staffDef" mode="first.pass.file.2"/>
                    </staffGrp>
                </staffGrp>
            </scoreDef>
        </xsl:template>-->
        <xsl:sequence select="bw:combineFiles-evaluatePrecedingScoreDef($this.measure,$corresponding.measure)"/>
        
        <xsl:copy>
            <xsl:apply-templates select="mei:staff | @*" mode="#current"/>
            <xsl:apply-templates select="$corresponding.measure/mei:staff" mode="first.pass.file.2"/>
            <xsl:apply-templates select="child::mei:*[not(local-name() = 'staff')]" mode="#current"/>
            <xsl:apply-templates select="$corresponding.measure/mei:*[not(local-name() = 'staff')]" mode="first.pass.file.2"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staffDef/@n" mode="first.pass.file.2">
        <xsl:variable name="current.n" select="xs:integer(.)" as="xs:integer"/>
        <xsl:attribute name="n" select="$current.n + $first.file.staff.count"/>        
    </xsl:template>
    <xsl:template match="mei:staff/@n" mode="first.pass">
        <xsl:next-match/>
        <xsl:attribute name="type" select="'file1'"/>
    </xsl:template>
    <xsl:template match="mei:staff/@n" mode="first.pass.file.2">
        <xsl:variable name="current.n" select="xs:integer(.)" as="xs:integer"/>
        <xsl:attribute name="n" select="$current.n + $first.file.staff.count"/>
        <xsl:attribute name="type" select="'file2'"/>
    </xsl:template>
    <xsl:template match="@staff" mode="first.pass.file.2">
        <xsl:choose>
            <xsl:when test="not(contains(.,' '))">
                <xsl:variable name="current.n" select="xs:integer(.)" as="xs:integer"/>
                <xsl:attribute name="staff" select="$current.n + $first.file.staff.count"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="tokens" select="for $token in tokenize(normalize-space(.), ' ') return (xs:string(xs:integer($token) + $first.file.staff.count))" as="xs:string+"/>
                <xsl:attribute name="staff" select="string-join($tokens, ' ')"/>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
    <xsl:template match="@start" mode="special.pushing">
        <xsl:param name="offset" tunnel="yes"/>
        <xsl:attribute name="start" select="if(string(number(.)) != 'NaN') then(number(.) + $offset) else(.)"/>
    </xsl:template>
    
    <xsl:template match="@end" mode="special.pushing">
        <xsl:param name="offset" tunnel="yes"/>
        <xsl:attribute name="end" select="if(string(number(.)) != 'NaN') then(number(.) + $offset) else(.)"/>
    </xsl:template>
    
    <xsl:template match="*:measure/@n" mode="special.pushing">
        <xsl:attribute name="n" select="number(.) + 2"/>
    </xsl:template>
    
    
    
    <xsl:function name="bw:combineFiles-evaluatePrecedingScoreDef" as="node()?">
        <xsl:param name="measure.1" as="node()"/>
        <xsl:param name="measure.2" as="node()"/>
        
        <xsl:variable name="scoreDef.1" select="$measure.1/preceding-sibling::mei:*[1][local-name() = 'scoreDef']" as="node()?"/>
        <xsl:variable name="scoreDef.2" select="$measure.2/preceding-sibling::mei:*[1][local-name() = 'scoreDef']" as="node()?"/>
        
        <xsl:if test="exists($scoreDef.1) or exists($scoreDef.2)">
            <scoreDef xmlns="http://www.music-encoding.org/ns/mei">
                
                <staffGrp symbol="none" bar.thru="false">
                    <staffGrp symbol="brace" bar.thru="true">
                        <xsl:choose>
                            <xsl:when test="exists($scoreDef.1)">
                                <xsl:apply-templates select="$scoreDef.1" mode="condenseScoreDef"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="(1 to $first.file.staff.count)">
                                    <xsl:variable name="current.pos" select="." as="xs:integer"/>
                                    <staffDef xmlns="http://www.music-encoding.org/ns/mei" type="unchanged" n="{$current.pos}"/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </staffGrp>
                    <staffGrp symbol="brace" bar.thru="true">
                        <xsl:choose>
                            <xsl:when test="exists($scoreDef.2)">
                                <xsl:apply-templates select="$scoreDef.2" mode="condenseScoreDef.file2"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="(1 to $second.file.staff.count)">
                                    <xsl:variable name="current.pos" select="." as="xs:integer"/>
                                    <staffDef xmlns="http://www.music-encoding.org/ns/mei" type="unchanged" n="{string($current.pos + $first.file.staff.count)}"/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </staffGrp>
                </staffGrp>
            </scoreDef>
        </xsl:if>
            
    </xsl:function>
    
    <xsl:template match="mei:scoreDef" mode="condenseScoreDef">
        <xsl:variable name="current.scoreDef" select="." as="node()"/>
        <xsl:variable name="available.staffDef.n" select="distinct-values(.//mei:staffDef/xs:integer(@n))" as="xs:integer*"/>
        <xsl:for-each select="(1 to $first.file.staff.count)">
            <xsl:variable name="current.n" select="." as="xs:integer"/>
            <xsl:choose>
                <xsl:when test="$current.scoreDef//mei:staffDef[xs:integer(@n) = $current.n]">
                    <staffDef xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:apply-templates select="$current.scoreDef/(@* except @xml:id)" mode="#current"/>
                        <xsl:apply-templates select="$current.scoreDef//mei:staffDef[xs:integer(@n) = $current.n]/(@* except @xml:id)" mode="first.pass"/>
                        <xsl:attribute name="n" select="$current.n"/>
                    </staffDef>        
                </xsl:when>
                <xsl:otherwise>
                    <staffDef xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:apply-templates select="$current.scoreDef/(@* except @xml:id)" mode="#current"/>
                        <xsl:attribute name="n" select="$current.n"/>
                    </staffDef>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="mei:scoreDef" mode="condenseScoreDef.file2">
        <xsl:variable name="current.scoreDef" select="." as="node()"/>
        <xsl:variable name="available.staffDef.n" select="distinct-values(.//mei:staffDef/xs:integer(@n))" as="xs:integer*"/>
        <xsl:for-each select="(1 to $second.file.staff.count)">
            <xsl:variable name="current.n" select="." as="xs:integer"/>
            <xsl:choose>
                <xsl:when test="$current.scoreDef//mei:staffDef[xs:integer(@n) = $current.n]">
                    <staffDef xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:apply-templates select="$current.scoreDef/(@* except @xml:id)" mode="#current"/>
                        <xsl:apply-templates select="$current.scoreDef//mei:staffDef[xs:integer(@n) = $current.n]/(@* except @xml:id)" mode="first.pass"/>
                        <xsl:attribute name="n" select="($current.n + $first.file.staff.count)"/>
                    </staffDef>        
                </xsl:when>
                <xsl:otherwise>
                    <staffDef xmlns="http://www.music-encoding.org/ns/mei" n="">
                        <xsl:apply-templates select="$current.scoreDef/(@* except @xml:id)" mode="#current"/>
                        <xsl:attribute name="n" select="($current.n + $first.file.staff.count)"/>
                    </staffDef>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- generic copy template -->
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>