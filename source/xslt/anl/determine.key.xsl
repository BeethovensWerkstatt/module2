<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:ba="none" exclude-result-prefixes="xs math xd mei ba" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Feb 23, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> agnesseipelt und Johannes Kepper</xd:p>
            <xd:p>Mit diesem stylesheet kann die Tonart des Stückes festgelegt werden.</xd:p>
            <xd:p>Es wird eine Variable erstellt, die an die mei:sections ein Attribut @base.key anhängt. Hier ist zu Testzwecken die Tonart auf F festgelegt. Ziel ist aber, dass die Tonart automatisch erkannt werden kann, z.B. dass der letzte und tiefste Ton als Tonart herangezogen wird. Ist noch zu diskutieren</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    <!-- 
        Ziel: //mei:section/@base.key
        Format: C-Dur = C; C-moll = c; eb Eb G#  
    
    
    -->
    <xsl:template match="mei:meiHead" mode="determine.key">
        <xsl:comment>killed the head</xsl:comment>
    </xsl:template>
    <xsl:template match="mei:section" mode="determine.key">
        <xsl:variable name="relevant.scoreDef" as="node()">
            <xsl:choose>
                <xsl:when test="child::mei:scoreDef[@key.sig][count(preceding-sibling::mei:*[not(local-name() = 'annot')]) = 0]">
                    <xsl:sequence select="child::mei:scoreDef[@key.sig][count(preceding-sibling::mei:*[not(local-name() = 'annot')]) = 0]"/>
                </xsl:when>
                <xsl:when test="preceding-sibling::mei:scoreDef[@key.sig]">
                    <xsl:sequence select="preceding-sibling::mei:scoreDef[@key.sig][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'ERROR: Unable to find scoreDef at ' || (descendant-or-self::mei:*[@xml:id])[1]/@xml:id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="circle.5" as="node()">
            <ba:circle>
                <ba:key.sig value="0">
                    <ba:major>C</ba:major>
                    <ba:minor>a</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="1s">
                    <ba:major>G</ba:major>
                    <ba:minor>e</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="2s">
                    <ba:major>D</ba:major>
                    <ba:minor>b</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="3s">
                    <ba:major>A</ba:major>
                    <ba:minor>f#</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="4s">
                    <ba:major>E</ba:major>
                    <ba:minor>c#</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="5s">
                    <ba:major>B</ba:major>
                    <ba:minor>g#</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="6s">
                    <ba:major>F#</ba:major>
                    <ba:minor>d#</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="7s">
                    <ba:major>C#</ba:major>
                    <ba:minor>a#</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="1f">
                    <ba:major>F</ba:major>
                    <ba:minor>d</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="2f">
                    <ba:major>Bb</ba:major>
                    <ba:minor>g</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="3f">
                    <ba:major>Eb</ba:major>
                    <ba:minor>c</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="4f">
                    <ba:major>Ab</ba:major>
                    <ba:minor>f</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="5f">
                    <ba:major>Db</ba:major>
                    <ba:minor>bb</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="6f">
                    <ba:major>Gb</ba:major>
                    <ba:minor>eb</ba:minor>
                </ba:key.sig>
                <ba:key.sig value="7f">
                    <ba:major>Cb</ba:major>
                    <ba:minor>ab</ba:minor>
                </ba:key.sig>
            </ba:circle>
        </xsl:variable>
        <xsl:variable name="relevant.key.sig" select="$circle.5//ba:key.sig[@value=$relevant.scoreDef/@key.sig]" as="node()"/>
        <xsl:variable name="key" as="xs:string">
            <xsl:choose>
                <xsl:when test="$relevant.scoreDef/@key.mode='major'">
                    <xsl:value-of select="$relevant.key.sig/ba:major/text()"/>
                </xsl:when>
                <xsl:when test="$relevant.scoreDef/@key.mode='minor'">
                    <xsl:value-of select="$relevant.key.sig/ba:minor/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    
                    <!-- TODO: Robuster machen, evtl. mit @tstamp arbeiten -->
                    <xsl:variable name="first.note" select="((.//mei:measure)[1]/mei:staff[last()]/mei:layer[.//@pname][last()]//@pname)[1]" as="xs:string"/>
                    <xsl:choose>
                        <xsl:when test="starts-with(lower-case($relevant.key.sig/ba:major/text()),$first.note)">
                            <xsl:value-of select="$relevant.key.sig/ba:major/text()"/>
                        </xsl:when>
                        <xsl:when test="starts-with(lower-case($relevant.key.sig/ba:minor/text()),$first.note)">
                            <xsl:value-of select="$relevant.key.sig/ba:minor/text()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="'Unable to relate first bass note to key signature. First note: ' || $first.note || ', key sig: ' || $relevant.scoreDef/@key.sig"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message select="'Indentified section as key ' || $key"/>
        <xsl:copy>
            <xsl:attribute name="base.key" select="$key"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>