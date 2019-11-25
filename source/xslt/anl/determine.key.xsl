<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:key="none" exclude-result-prefixes="xs math xd mei key" version="3.0">
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
    
    <!-- requires circleOf5.xsl -->
    
    <!-- 
        Ziel: //mei:section/@base.key
        Format: C-Dur = C; C-moll = Cm; Cis-Dur: C#; Ces-Dur: Cb
    
    
    -->
    <xsl:template match="mei:section | mei:ending" mode="determine.key">
        <xsl:variable name="relevant.scoreDef" as="node()">
            <xsl:choose>
                <xsl:when test="child::mei:scoreDef[@key.sig][count(preceding-sibling::mei:*[not(local-name() = 'annot')]) = 0]">
                    <xsl:sequence select="child::mei:scoreDef[@key.sig][count(preceding-sibling::mei:*[not(local-name() = 'annot')]) = 0]"/>
                </xsl:when>
                <xsl:when test="preceding-sibling::mei:*[(local-name() = 'scoreDef' and @key.sig) or (local-name() = ('section','ending') and child::mei:scoreDef[@key.sig])]">
                    <xsl:sequence select="preceding-sibling::mei:*[(local-name() = 'scoreDef' and @key.sig) or (local-name() = ('section','ending') and child::mei:scoreDef[@key.sig])][1]/descendant-or-self::mei:scoreDef[@key.sig][1]"/>
                </xsl:when>
                <xsl:when test="ancestor-or-self::mei:*[local-name() = ('section','ending')]/preceding-sibling::mei:scoreDef[@key.sig]">
                    <xsl:sequence select="ancestor-or-self::mei:*[local-name() = ('section','ending')]/preceding-sibling::mei:scoreDef[@key.sig][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'ERROR: Unable to find scoreDef at ' || (descendant-or-self::mei:*[@xml:id])[1]/@xml:id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="relevant.key.elem" as="node()">
            <xsl:choose>
                <xsl:when test="$relevant.scoreDef/@key.mode='major'">
                    <xsl:sequence select="$circle.of.fifths//key:major[@sig = $relevant.scoreDef/@key.sig]"/>
                </xsl:when>
                <xsl:when test="$relevant.scoreDef/@key.mode='minor'">
                    <xsl:sequence select="$circle.of.fifths//key:minor[@sig = $relevant.scoreDef/@key.sig]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="'Problem caused by $relevant.scoreDef:'"/>
                    <xsl:message select="$relevant.scoreDef"/>
                    <xsl:message terminate="yes" select="'ERROR: Currently, only major and minor modes are supported.'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="key" select="$relevant.key.elem/@name" as="xs:string">
            <!-- todo: here was a test if that's really the right key. We could look for a Krumhansl-Schmuckler-Evaluation -->
        </xsl:variable>
        <xsl:message select="'Identified section starting at measure ' || (.//mei:measure)[1]/@n || ' as key ' || $key"/>
        <xsl:copy>
            <xsl:attribute name="base.key" select="$key"/>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="base.key" select="$key" tunnel="yes" as="xs:string"/>
                <xsl:with-param name="relevant.scoreDef" select="$relevant.scoreDef" tunnel="yes" as="node()"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staff" mode="determine.key">
        <xsl:param name="relevant.scoreDef" as="node()" tunnel="yes"/>
        
        <xsl:variable name="current.n" select="@n" as="xs:string"/>
        
        <xsl:choose>
            <!-- transposing instrument -->
            <xsl:when test="$relevant.scoreDef//mei:staffDef[@n = $current.n][@key.sig][@key.sig != $relevant.scoreDef/@key.sig]">
                <xsl:variable name="staff.key.sig" select="$relevant.scoreDef//mei:staffDef[@n = $current.n]/@key.sig" as="xs:string"/>
                <xsl:variable name="staff.trans.semi" select="$relevant.scoreDef//mei:staffDef[@n = $current.n]/@trans.semi" as="xs:string"/>
                <xsl:variable name="staff.trans.diat" select="$relevant.scoreDef//mei:staffDef[@n = $current.n]/@trans.diat" as="xs:string"/>
                
                <xsl:variable name="relevant.key.elem" as="node()">
                    <xsl:choose>
                        <xsl:when test="$relevant.scoreDef/@key.mode='major'">
                            <xsl:sequence select="$circle.of.fifths//key:major[@sig = $staff.key.sig]"/>
                        </xsl:when>
                        <xsl:when test="$relevant.scoreDef/@key.mode='minor'">
                            <xsl:sequence select="$circle.of.fifths//key:minor[@sig = $staff.key.sig]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="'ERROR: Currently, only major and minor modes are supported.'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="key" select="$relevant.key.elem/@name" as="xs:string">
                    <!-- todo: here was a test if that's really the right key. We could look for a Krumhansl-Schmuckler-Evaluation -->
                </xsl:variable>
                
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:attribute name="staff.key" select="$key"/>
                    <xsl:attribute name="trans.semi" select="$staff.trans.semi"/>
                    <xsl:attribute name="trans.diat" select="$staff.trans.diat"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            
            <!-- transposed by a full octave -->
            <xsl:when test="$relevant.scoreDef//mei:staffDef[@n = $current.n][@trans.semi = ('-12','12')][@trans.diat = ('-7','7')][@key.sig = $relevant.scoreDef/@key.sig]">
                <xsl:variable name="staff.key.sig" select="$relevant.scoreDef//mei:staffDef[@n = $current.n]/@key.sig" as="xs:string"/>
                <xsl:variable name="staff.trans.semi" select="$relevant.scoreDef//mei:staffDef[@n = $current.n]/@trans.semi" as="xs:string"/>
                <xsl:variable name="staff.trans.diat" select="$relevant.scoreDef//mei:staffDef[@n = $current.n]/@trans.diat" as="xs:string"/>
                
                <xsl:variable name="relevant.key.elem" as="node()">
                    <xsl:choose>
                        <xsl:when test="$relevant.scoreDef/@key.mode='major'">
                            <xsl:sequence select="$circle.of.fifths//key:major[@sig = $staff.key.sig]"/>
                        </xsl:when>
                        <xsl:when test="$relevant.scoreDef/@key.mode='minor'">
                            <xsl:sequence select="$circle.of.fifths//key:minor[@sig = $staff.key.sig]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="'ERROR: Currently, only major and minor modes are supported.'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="key" select="$relevant.key.elem/@name" as="xs:string">
                    <!-- todo: here was a test if that's really the right key. We could look for a Krumhansl-Schmuckler-Evaluation -->
                </xsl:variable>
                
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:attribute name="staff.key" select="$key"/>
                    <xsl:attribute name="trans.semi" select="$staff.trans.semi"/>
                    <xsl:attribute name="trans.diat" select="$staff.trans.diat"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>