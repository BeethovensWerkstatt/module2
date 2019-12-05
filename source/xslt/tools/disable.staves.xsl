<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Dec 4, 2019</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSL removes staves as requested</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:score" mode="disable.staves">
        <xsl:param name="hidden.staves" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$hidden.staves = ''">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="hidden.staves.string" select="tokenize($hidden.staves,',')" as="xs:string+"/>
                <xsl:variable name="hidden.staves.int" select="for $staff in $hidden.staves.string return xs:integer($staff)" as="xs:integer+"/>
                
                <xsl:variable name="all.staves" select="distinct-values(.//mei:staffDef/@n)" as="xs:string+"/>
                <xsl:variable name="new.staves" as="xs:integer+">
                    <xsl:for-each select="$all.staves">
                        <xsl:sort select="xs:integer(.)" data-type="number"/>
                        <xsl:variable name="current.staff" select="xs:integer(.)" as="xs:integer"/>
                        <xsl:choose>
                            <xsl:when test="$current.staff = $hidden.staves.int">
                                <xsl:value-of select="-1"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$current.staff - count($hidden.staves.int[. lt $current.staff])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:variable name="prep" as="node()">
                    <xsl:copy>
                        <xsl:apply-templates select="node() | @*" mode="#current">
                            <xsl:with-param name="new.staves" select="$new.staves" as="xs:integer+" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:copy>
                </xsl:variable>
                
                <xsl:apply-templates select="$prep" mode="disable.staves.cleanup"/>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mei:staffDef | mei:staff" mode="disable.staves">
        <xsl:param name="new.staves" tunnel="yes" as="xs:integer+"/>
        
        <xsl:variable name="old.n" select="xs:integer(@n)" as="xs:integer"/>
        <xsl:variable name="new.n" select="$new.staves[$old.n]" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="$new.n = -1"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="#current">
                        <xsl:with-param name="new.n" select="xs:string($new.n)" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mei:*[@staff]" mode="disable.staves">
        <xsl:param name="new.staves" tunnel="yes" as="xs:integer+"/>
        
        <xsl:variable name="staves.string" select="tokenize(normalize-space(@staff),' ')" as="xs:string+"/>
        <xsl:variable name="staves.int" select="for $staff in $staves.string return xs:integer($staff)" as="xs:integer+"/>
        
        <xsl:choose>
            <xsl:when test="every $staff in $staves.int satisfies ($new.staves[$staff] = -1)"/>
            <xsl:otherwise>
                <xsl:variable name="relevant.staves" as="xs:string+">
                    <xsl:for-each select="$staves.int">
                        <xsl:sort select="." data-type="number"/>
                        <xsl:variable name="current.staff" select="." as="xs:integer"/>
                        <xsl:if test="$new.staves[$current.staff] != -1">
                            <xsl:value-of select="xs:string($new.staves[$current.staff])"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="#current">
                        <xsl:with-param name="new.n" select="string-join($relevant.staves,' ')" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mei:staffDef/@n | mei:staff/@n | @staff" mode="disable.staves">
        <xsl:param name="new.n" tunnel="yes" as="xs:string"/>
        <xsl:attribute name="{local-name()}" select="$new.n"/>
    </xsl:template>
    
    <!--<xsl:template match="mei:staffGrp" mode="disable.staves.cleanup">
        <xsl:choose>
            <xsl:when test="./mei:staffGrp">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="count(./mei:staffDef) lt 2">
                <xsl:apply-templates select="./mei:staffDef" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
</xsl:stylesheet>