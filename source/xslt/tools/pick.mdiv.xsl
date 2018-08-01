<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Jul 31, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSL selects the right mdiv</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:mdiv" mode="pick.mdiv">
        <xsl:param name="mdiv" tunnel="yes"/>
        <xsl:variable name="pos" select="string(count(preceding-sibling::mei:mdiv) + 1)" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="@n = $mdiv">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="$pos = $mdiv">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>