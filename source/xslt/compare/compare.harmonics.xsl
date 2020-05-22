<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Jan 17, 2020</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Agnes and Johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <!-- mode add.invariance -->
    <xsl:template match="mei:harm[@type = 'analysis.result']" mode="compare.harmonics">
        <xsl:variable name="tstamp" select="@tstamp" as="xs:string"/>
        <xsl:variable name="is.file.1" select="if(number(@staff) le $first.file.staff.count) then(true()) else(false())" as="xs:boolean"/>
        <xsl:variable name="content" select="string-join(.//text(),'')" as="xs:string"/>
        
        <!-- TODO: We need to check if these harms are identical, and not just if they're available… -->
        <xsl:variable name="match" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$is.file.1">
                    <xsl:sequence select="parent::mei:*/mei:harm[@type = 'analysis.result' and @tstamp = $tstamp and number(@staff) gt $first.file.staff.count] and string-join(.//text(),'') = $content"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="parent::mei:*/mei:harm[@type = 'analysis.result' and @tstamp = $tstamp and number(@staff) le $first.file.staff.count] and string-join(.//text(),'') = $content"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$is.file.1 and $match">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="$is.file.1 and not($match)">
                <xsl:copy>
                    <xsl:apply-templates select="@* except @type" mode="#current"/>
                    <xsl:attribute name="type" select="'anl diff file1only'"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="not($is.file.1) and $match">
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@staff | @place)" mode="#current"/>
                    <xsl:attribute name="staff" select="($first.file.staff.count + 1)"/>
                    <xsl:attribute name="place" select="'above'"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="not($is.file.1) and not($match)">
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@staff | @place | @type)" mode="#current"/>
                    <xsl:attribute name="staff" select="($first.file.staff.count + 1)"/>
                    <xsl:attribute name="place" select="'above'"/>
                    <xsl:attribute name="type" select="'anl diff file2only'"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>