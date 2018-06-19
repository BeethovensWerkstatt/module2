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
    <xsl:template match="mei:harm[@type = 'romanBaseNumeral']" mode="examine.roman.base.numerals">
        <xsl:variable name="preceding.base.numeral" select="preceding::mei:harm[@type = 'romanBaseNumeral'][1]" as="node()?"/>
        <xsl:variable name="this.number" select="number(.//text())" as="xs:double"/>
        <xsl:variable name="preceding.number" select="number($preceding.base.numeral//text())" as="xs:double"/>
        <xsl:choose>
            <xsl:when test="$preceding.number -4 = $this.number">
                <harm xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <rend fontweight="bold" fontstyle="italic">
                        <xsl:value-of select="$preceding.base.numeral || '-' || $this.number"/>
                    </rend>
                </harm>
            </xsl:when><!-- Fall: V I -->
            <xsl:when test="$preceding.number + 7 - 4 = $this.number">
                <harm xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <rend fontweight="bold" fontstyle="italic">
                        <xsl:value-of select="$preceding.base.numeral || '-' || $this.number"/>
                    </rend>
                </harm>
            </xsl:when><!-- Fall: I IV -->
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>