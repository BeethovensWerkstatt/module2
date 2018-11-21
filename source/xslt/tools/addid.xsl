<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 10, 2014</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This stylesheet ensures that all relevant elements have xml:ids</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:include href="uuid.xsl"/>
    <xsl:template match="mei:body//mei:*[not(@xml:id)]" mode="add.id">
        <xsl:copy>
            <xsl:attribute name="xml:id" select="custom:uuid(.)"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:function name="custom:uuid" as="xs:string">
        <xsl:param name="elem" as="node()"/>
        <!--<xsl:value-of select="concat(system-property('xsl:version'),'-',system-property('xsl:vendor'),'-',system-property('xsl:vendor-url'))"/>-->
        <!--<xsl:variable name="uuid" select="doc('http://localhost:8080/exist/apps/mod2/resources/xql/getUUID.xql')//@id"/>-->
        <!--<xsl:variable name="uuid" select="unparsed-text('https://www.uuidgenerator.net/api/version4')"/>-->
        <!--<xsl:variable name="uuid" as="xs:string*">
            <xsl:for-each select="1 to 10">
                <xsl:value-of select="uuid:get-uuid(.)"/>
            </xsl:for-each>
        </xsl:variable>-->
        <!--<xsl:variable name="uuid" select="unparsed-text('http://localhost:8080/exist/apps/mod2/resources/xql/getUUID.xql')"/>-->
        <xsl:variable name="seed">
            <xsl:comment select="count($elem/preceding::node())"/>
        </xsl:variable>
        <xsl:variable name="uuid" select="uuid:get-uuid()"/>
        <xsl:value-of select="'x' || $uuid"/>
    </xsl:function>
</xsl:stylesheet>