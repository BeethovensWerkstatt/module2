<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs math xd mei uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 3, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:template match="/">
        
        <xsl:variable name="new.ids">
            <xsl:apply-templates select="node()" mode="first.run"/>
        </xsl:variable>
        
        <xsl:apply-templates select="$new.ids" mode="clean.up"/>
        
    </xsl:template>
    
    <xsl:template match="mei:score" mode="clean.up">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="type" select="'score'" tunnel="yes" as="xs:string"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:part" mode="clean.up">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="type" select="'part'" tunnel="yes" as="xs:string"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:measure//mei:*[not(@xml:id)]" mode="first.run">
        <xsl:choose>
            <xsl:when test="local-name() = 'staff'">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="local-name() = 'layer'">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:attribute name="xml:id" select="'x' || uuid:randomUUID()"/>
                    <xsl:apply-templates select="node() | @*" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mei:music//@xml:id" mode="first.run">
        <xsl:attribute name="xml:id" select="'x' || uuid:randomUUID()"/>
        <xsl:attribute name="old.id" select="."/>
    </xsl:template>
    
    <xsl:template match="@startid" mode="clean.up">
        <xsl:param name="type" tunnel="yes" as="xs:string"/>
        
        <xsl:variable name="old.start" select="replace(.,'#','')" as="xs:string"/>
        <xsl:variable name="scope" select="if($type = 'score') then(ancestor::mei:score) else(ancestor::mei:part)" as="node()"/>
        <xsl:variable name="start.elem" select="$scope//mei:*[@old.id = $old.start]" as="node()?"/>
        
        <xsl:choose>
            <xsl:when test="not($start.elem)">
                <xsl:next-match/>
                <xsl:attribute name="todo" select="'bad startid'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'moving @startid ' || . || ' to #' || $start.elem/@xml:id"/>
                <xsl:attribute name="startid" select="'#' || $start.elem/@xml:id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@endid" mode="clean.up">
        <xsl:param name="type" tunnel="yes" as="xs:string"/>
        
        <xsl:variable name="old.end" select="replace(.,'#','')" as="xs:string"/>
        <xsl:variable name="scope" select="if($type = 'score') then(ancestor::mei:score) else(ancestor::mei:part)" as="node()"/>
        <xsl:variable name="end.elem" select="$scope//mei:*[@old.id = $old.end]" as="node()?"/>
        
        <xsl:choose>
            <xsl:when test="not($end.elem)">
                <xsl:next-match/>
                <xsl:attribute name="todo" select="'bad endid'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'moving  @endid ' || . || ' to #' || $end.elem/@xml:id"/>
                <xsl:attribute name="endid" select="'#' || $end.elem/@xml:id"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="@plist" mode="clean.up">
        <xsl:param name="type" tunnel="yes" as="xs:string"/>
        
        <xsl:variable name="elem" select="parent::mei:*" as="node()"/>
        <xsl:variable name="tokens" as="xs:string*">
            <xsl:for-each select="tokenize(normalize-space(.),' ')">
                <xsl:variable name="old.p" select="replace(.,'#','')" as="xs:string"/>
                <xsl:variable name="scope" select="if($type = 'score') then($elem/ancestor::mei:score) else($elem/ancestor::mei:part)" as="node()"/>
                <xsl:variable name="p.elem" select="$scope//mei:*[@old.id = $old.p]" as="node()"/>
                
                <xsl:value-of select="'#' || $p.elem/@xml:id"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:message select="'moving  @plist ' || . || ' to ' || string-join($tokens,' ')"/>
        <xsl:attribute name="plist" select="string-join($tokens,' ')"/>
    </xsl:template>
    
    <xsl:template match="@old.id" mode="clean.up"/>
    
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