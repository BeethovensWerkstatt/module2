<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    xmlns:vife="https://edirom.de/ns/vife"
    exclude-result-prefixes="xs math xd mei uuid vife"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 4, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This XSL adjusts controlevents according to the BW encoding style.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:include href="components/addid.xsl"/>
    <xsl:include href="components/addtstamps.xsl"/>
    <xsl:include href="components/controlevent.linking.xsl"/>
    
    <xd:doc>
        <xd:desc>Start template, which determines the processing order</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="added.ids" as="node()*">
            <xsl:apply-templates select="node()" mode="add.id"/>
        </xsl:variable>
        <xsl:variable name="added.tstamps" as="node()*">
            <xsl:apply-templates select="$added.ids" mode="add.tstamps"/>
        </xsl:variable>
        <xsl:variable name="controlevents.linked" as="node()*">
            <xsl:apply-templates select="$added.tstamps" mode="controlevent.linking"/>
        </xsl:variable>
        <xsl:variable name="cleaned" as="node()*">
            <xsl:apply-templates select="$controlevents.linked" mode="final.cleanup"/>
        </xsl:variable>
        <xsl:copy-of select="$cleaned"/>
    </xsl:template>
    
    <xsl:template match="mei:measure/@meter.count" mode="final.cleanup"/>
    <xsl:template match="mei:measure/@meter.unit" mode="final.cleanup"/>
    <xsl:template match="mei:staff//@tstamp" mode="final.cleanup"/>
    <xsl:template match="mei:staff//@tstamp2" mode="final.cleanup"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This is a generic copy template which will copy all content in all modes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>