<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs math xd mei"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Created on:<xd:b>2019-03-04</xd:b></xd:p>
            <xd:p>Author:<xd:b>Kristin Herold, Johannes Kepper</xd:b></xd:p>
            <xd:p>Delete mei:sb-elements and mei:pb-elements, get rid of rend-elements but keep its contents,
                rename mSpace-elements to mRest-elements.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    
    
    <xd:doc>
        <xd:desc> Start template </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    
    <xd:doc>
        <xd:desc> create change-element </xd:desc>
    </xd:doc>
    <xsl:template match="mei:revisionDesc">
        <xsl:variable name="new.n" select="count(child::mei:change) + 1" as="xs:integer"/>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <change xmlns="http://www.music-encoding.org/ns/mei" n="{$new.n}">
                <respStmt>
                    <persName auth.uri="https://github.com/" codedval="krHERO">Kristin Herold</persName>
                </respStmt>
                <changeDesc>
                    <p>Deleted mei:sb-elements and mei:pb-elements, got rid of rend-elements but keep its contents,
                        renamed mSpace-elements to mRest-elements, moved accid-attributes from accid-elements to note-elements, 
                        moved artic-attributes from artic-elements to note-elements; utilizing dataCleanUp.xsl</p>
                </changeDesc>
                <date isodate="{substring(string(current-date()),1,10)}"/>
            </change>
        </xsl:copy>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc> delete sb-elements </xd:desc>
    </xd:doc>
    <xsl:template match="mei:sb"/>
    
    
    <xd:doc>
        <xd:desc> delete pb-elements </xd:desc>
    </xd:doc>
    <xsl:template match="mei:pb"/>
    
    
    <xd:doc>
        <xd:desc> get rid of rend-elements but keep its contents </xd:desc>
    </xd:doc>
    <xsl:template match="mei:rend">
        <xsl:apply-templates select="node()" mode="#current"/>        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>rename mSpace-elements to mRest-elements</xd:desc>
    </xd:doc>
    <xsl:template match="mei:mSpace">
        <mRest xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*" mode="#current"/>
        </mRest>  
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>move accid-attributes from accid-elements to note-elements, 
            move artic-attributes from artic-elements to note-elements</xd:desc>
    </xd:doc>    
    <xsl:template match="mei:note">
        <xsl:copy>
<!--            <xsl:apply-templates select="@* | .//@accid | .//@accid.ges | .//@artic" mode="#current"/>-->
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:if test=".//@artic">
                <xsl:attribute name="artic" select=".//@artic"/>
            </xsl:if>
            <xsl:if test=".//@accid">
                <xsl:attribute name="accid" select=".//@accid"/>
            </xsl:if>
            <xsl:if test=".//@accid.ges">
                <xsl:attribute name="accid.ges" select=".//@accid.ges"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>move artic-attributes from artic-elements to chord-elements</xd:desc>
    </xd:doc>    
    <xsl:template match="mei:chord">
        <xsl:copy>
            <xsl:if test=".//@artic">
                <xsl:attribute name="artic" select=".//@artic"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    <xd:doc>
        <xd:desc>delete accid-elements</xd:desc>
    </xd:doc>
    <xsl:template match="mei:accid"/>
    <xd:doc>
        <xd:desc>delete artic-elements</xd:desc>
    </xd:doc>
    <xsl:template match="mei:artic"/>
    
    
    <xd:doc>
        <xd:desc> copy template </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>