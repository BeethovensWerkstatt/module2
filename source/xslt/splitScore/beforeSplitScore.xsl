<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs mei uuid xd math"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b>Jan 14 2020</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> </xd:p>
        </xd:desc>
    </xd:doc>
    
    <!--<xsl:output indent="yes" method="xml"/>-->
    
   <!-- <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>-->
     
     
     <xd:doc>
         <xd:desc>give @staff attribute to elements that have no @staff attribue</xd:desc>
     </xd:doc>
    <xsl:template match="mei:*[parent::mei:measure and not(local-name() = 'staff') and not(@staff)]" mode="giveStaffNo">
    <xsl:variable name="startid" select="replace(@startid,'#','')" as="xs:string"/><!-- slur, tie -->
    <xsl:variable name="startnote" select="ancestor::mei:measure//mei:*[@xml:id = $startid]" as="node()?"/>
    
    <xsl:if test="not($startnote)">
        <xsl:message select="." terminate="yes"/>
    </xsl:if> 
    
    <xsl:variable name="staff.n" select="$startnote/ancestor::mei:staff/xs:integer(@n)" as="xs:integer"/>
    
    <xsl:copy>
        <xsl:apply-templates select="@*"/>
       <xsl:attribute name="staff" select="$staff.n"/>
    </xsl:copy>
    
</xsl:template>    
    
    
  
    
    
    <!-- copies xml nodes -->
    <!--<xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>-->
    
    
</xsl:stylesheet>