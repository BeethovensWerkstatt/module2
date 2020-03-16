<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" xmlns:key="none" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xs math xd mei custom uuid xlink" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:mei" mode="extract.melodic.lines">
        <xsl:variable name="pre.process">
            <xsl:apply-templates select="." mode="extract.melodic.lines.prep"/>
        </xsl:variable>
        
        <mei xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="$pre.process//mei:mdiv" mode="extract.melodic.lines"/>
        </mei>
        
    </xsl:template>
    
    <xsl:template match="mei:mdiv" mode="extract.melodic.lines.prep">
        <xsl:variable name="measures" select=".//mei:measure" as="node()*"/>
        <xsl:variable name="durations" as="node()*">
            <custom:durations>
                <xsl:for-each select="$measures">
                    
                    <xsl:variable name="ends" select=".//mei:staff//@tstamp2[string(number(.)) != 'NaN']/number(.)" as="xs:double*"/>
                    
                    <xsl:variable name="solution1" select="number(@meter.count)" as="xs:double"/>
                    <xsl:variable name="solution2" select="if(count($ends) gt 0) then(max($ends) - 1) else(0)" as="xs:double"/>
                    
                    <custom:dur id="{@xml:id}" dur="{((if(position() = 1) then($solution2) else($solution1))) div number(@meter.unit)}"/>
                </xsl:for-each>
            </custom:durations>
        </xsl:variable>
        
        <xsl:next-match>
            <xsl:with-param name="durations" select="$durations" tunnel="yes"/>
        </xsl:next-match>
        
    </xsl:template>
    
    <xsl:template match="mei:measure" mode="extract.melodic.lines.prep">
        <xsl:param name="durations" tunnel="yes"/>
        
        <xsl:variable name="this.measure" select="." as="node()"/>
        <xsl:variable name="matching.dur" select="$durations/descendant-or-self::custom:dur[@id = $this.measure/@xml:id]" as="node()"/>
        <xsl:variable name="sum" select="sum($matching.dur/preceding-sibling::custom:dur/number(@dur))" as="xs:double"/>
        
        <xsl:copy>
            <xsl:attribute name="dur.offset" select="$sum"/>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="dur.offset" select="$sum" tunnel="yes"/>
                <xsl:with-param name="meter.unit" select="@meter.unit" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staff" mode="extract.melodic.lines.prep">
        <xsl:next-match>
            <xsl:with-param name="staff" select="@n" tunnel="yes"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="mei:layer" mode="extract.melodic.lines.prep">
        <xsl:param name="dur.offset" tunnel="yes"/>
        <xsl:param name="meter.unit" tunnel="yes"/>
        <xsl:param name="staff" tunnel="yes"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            
            <xsl:for-each select=".//*[local-name() = ('note','mRest','multiRest','rest') and not(@grace)]">
                <xsl:sort select="ancestor-or-self::mei:*[@tstamp][1]/@tstamp" data-type="number"/>
                <xsl:variable name="note" select="." as="node()"/>
                <xsl:variable name="tstamp" select="number($note/ancestor-or-self::mei:*[@tstamp][1]/@tstamp)"/>
                <xsl:variable name="tstamp2" select="number($note/ancestor-or-self::mei:*[@tstamp2][1]/@tstamp2)"/>
                
                <event xsl:exclude-result-prefixes="xlink" pnum="{$note/@pnum}" start="{$dur.offset + ($tstamp div number($meter.unit))}" end="{$dur.offset + ($tstamp2 div number($meter.unit))}" staff="{$staff}" tstamp="{$tstamp}" tstamp2="{$tstamp2}" id="{$note/@xml:id}"/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- START MODE extract.melodic.lines – converts results to list -->
    
    <xsl:template match="mei:mdiv" mode="extract.melodic.lines">
        <xsl:variable name="this.mdiv" select="." as="node()"/>
        <mdiv>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:for-each select=".//mei:measure">
                <xsl:sort select="@dur.offset" data-type="number"/>
                
                <xsl:variable name="start" select="number(@dur.offset) + (1 div number(@meter.unit))" as="xs:double"/>
                <measure start="{$start}" id="{@xml:id}" n="{@n}"/>
            </xsl:for-each>
            <xsl:for-each-group select=".//event" group-by="@staff">
                <xsl:sort select="@staff" data-type="number"/>
                <staff n="{current-grouping-key()}">
                    <xsl:attribute name="label" select="($this.mdiv//mei:staffDef[@n = current-grouping-key() and @label])[1]/@label"/>
                    <xsl:for-each select="current-group()">
                        <xsl:sort select="@start" data-type="number"/>
                        <xsl:sort select="@pnum" data-type="number"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                    <!--<xsl:sequence select="current-group()"/>-->
                </staff>
            </xsl:for-each-group>
        </mdiv>
    </xsl:template>
    
    
</xsl:stylesheet>