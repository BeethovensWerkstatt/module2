<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    xmlns:local="local"
    exclude-result-prefixes="xs math xd mei uuid local"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 09, 2015</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>
                This stylesheet processes an MEI instance and makes sure that every note gets the values for @accid.ges
                that are required by:
                <xd:ul>
                    <xd:li>key signature</xd:li>
                    <xd:li>precedings accidentals</xd:li>
                </xd:ul>                
            </xd:p>
            <xd:p>It assumes that timestamps are available for all notes.</xd:p>
            <xd:p>With the parameter <xd:b>$octave</xd:b>, it is possible to indicate
                if an accid applies only to the very octave of the note (value <xd:i>strict</xd:i>),
                or if it applices to all octaves (value <xd:i>all</xd:i>, default).</xd:p>
            <xd:p>The parameter <xd:b>$range</xd:b> indicates the range of effect of an accidental, which is either
                to the next barline (value <xd:i>measure</xd:i>, default),
                or for all subsequent notes of the same pitch (value <xd:i>pitch</xd:i>).</xd:p>
        </xd:desc>
    </xd:doc>
    <!--
    <xsl:template match="/">
        <xsl:if test="not($octave = ('all','strict'))">
            <xsl:message terminate="yes" select="'Value *' || $octave || '* not allowed for param $octave. Allowed values are *all* and *strict*.'"/>
        </xsl:if>
        <xsl:if test="not($range = ('measure','pitch'))">
            <xsl:message terminate="yes" select="'Value *' || $range || '* not allowed for param $range. Allowed values are *measure* and *pitch*.'"/>
        </xsl:if>
        
        <!-\- todo -\->
        <xsl:if test="$range = 'pitch'">
            <xsl:message terminate="yes">Value *pitch* for param $range not yet supported – sorry…</xsl:message>
        </xsl:if>
        
        <xsl:if test="//mei:application[@xml:id = 'addAccid.ges.xsl_v' || $xsl.version]">
            <xsl:message terminate="yes">File already processed with addAccid.ges.xsl in version <xsl:value-of select="$xsl.version"/> – processing stopped.</xsl:message>
        </xsl:if>
        
        <xsl:if test="//mei:application[starts-with(@xml:id, 'addAccid.ges.xsl_v')]">
            <xsl:message terminate="no">File has been processed with addAccid.ges.xsl in in a prior version. Please check results for unexpected side-effects.</xsl:message>
        </xsl:if>
        
        <xsl:if test="//mei:keySig">
            <xsl:message terminate="no">
                This file contains one or more &lt;mei:keySig&gt; elements, which are not yet supported by this
                stylesheet. It is very likely that the resulting file will be incorrect!
            </xsl:message>
        </xsl:if>
        
        
        
    </xsl:template>-->
    
    <!--<xsl:template match="mei:note[child::mei:accid]" mode="convert2attributes">
        <xsl:copy>
            <xsl:copy-of select="child::mei:accid/@accid"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:accid" mode="convert2attributes"/>
    -->
    
    <xsl:param name="octave" select="'all'" as="xs:string"/>
    <xsl:param name="range" select="'measure'" as="xs:string"/>
    <!--
    <xsl:template match="mei:appInfo" mode="add.accid.ges">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <application xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id" select="'addAccid.ges.xsl_v' || $xsl.version"/>
                <xsl:attribute name="version" select="$xsl.version"/>
                <name>addAccid.ges.xsl</name>
                <ptr target="https://github.com/Freischuetz-Digital/Tools/blob/develop/13%20reCore/addAccid.ges.xsl"/>
            </application>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:revisionDesc" mode="add.accid.ges">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <change xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="n" select="count(./mei:change) + 1"/>
                <respStmt>
                    <persName>Johannes Kepper</persName>
                </respStmt>
                <changeDesc>
                    <p>
                        Included @accid.ges for all notes by using 
                        <ptr target="addAccid.ges.xsl_v{$xsl.version}"/>.
                    </p>
                </changeDesc>
                <date isodate="{substring(string(current-date()),1,10)}"/>
            </change>
        </xsl:copy>
    </xsl:template>
    -->
    <xsl:template match="mei:staff" mode="add.accid.ges">
        <xsl:variable name="n" select="@n" as="xs:string"/>
        
        <xsl:variable name="key.sig" as="xs:string?">
            <xsl:choose>
                <xsl:when test=".//mei:staffDef[count(preceding-sibling::mei:*) = 0 and @key.sig]">
                    <xsl:value-of select=".//mei:staffDef[count(preceding-sibling::mei:*) = 0 and @key.sig][1]/@key.sig"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="preceding::mei:*[(local-name() = 'staffDef' and @n = $n and @key.sig) or (local-name() = 'scoreDef' and @key.sig)][1]/@key.sig"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="accids" as="element()*">
            <xsl:for-each select=".//mei:*[@accid]">
                <xsl:sort select="@tstamp" data-type="number"/>
                <xsl:choose>
                    <xsl:when test="local-name() = 'note'">
                        <accid xmlns="http://www.music-encoding.org/ns/mei" pname="{@pname}" oct="{if($octave='strict') then(@oct) else('all')}" tstamp="{@tstamp}" accid="{@accid}"/>
                    </xsl:when>
                    <xsl:when test="local-name() = 'accid' and @ploc and @oloc">
                        <accid xmlns="http://www.music-encoding.org/ns/mei" pname="{string(@ploc)}" oct="{if($octave='strict') then(string(@oloc)) else('all')}" tstamp="{@tstamp}" accid="{@accid}"/>
                    </xsl:when>
                    <xsl:when test="local-name() = 'accid' and @loc">
                        <!-- todo: hier Tonhöhe raussuchen -->
                        <xsl:message>accid gefunden…</xsl:message>
                    </xsl:when>                    
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="preceding.staff" select="local:getPrecedingStaff(.)" as="element()?"/>
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current">
                <xsl:with-param name="key.sig" select="$key.sig" tunnel="yes" as="xs:string?"/>
                <xsl:with-param name="accids" select="$accids" tunnel="yes" as="element()*"/>
                <xsl:with-param name="preceding.staff" select="$preceding.staff" tunnel="yes" as="element()?"/>
            </xsl:apply-templates>    
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:note" mode="add.accid.ges">
        <xsl:param name="key.sig" tunnel="yes" as="xs:string?"/>
        <xsl:param name="accids" tunnel="yes" as="element()*"/>
        <xsl:param name="preceding.staff" tunnel="yes" as="element()?"/>
        
        <xsl:variable name="current.pname" select="string(@pname)" as="xs:string"/>
        <xsl:variable name="current.oct" select="string(@oct)" as="xs:string"/>
        <xsl:variable name="current.tstamp" select="number(@tstamp)" as="xs:double"/>
        <xsl:variable name="current.id" select="string(@xml:id)" as="xs:string"/>
        
        <xsl:variable name="key.sig.mod" as="xs:string?">
            <xsl:variable name="sharps" select="('f','c','g','d','a','e','b')" as="xs:string*"/>
            <xsl:variable name="flats" select="('b','e','a','d','g','c','f')" as="xs:string*"/>
            <xsl:if test="exists($key.sig) and $key.sig != '0'">
                <xsl:choose>
                    <xsl:when test="ends-with($key.sig,'s') and index-of($sharps,$current.pname) le number(substring-before($key.sig,'s'))">s</xsl:when>
                    <xsl:when test="ends-with($key.sig,'f') and index-of($flats,$current.pname) le number(substring-before($key.sig,'f'))">f</xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:apply-templates select="@* except @accid" mode="#current"/>
            
            <xsl:choose>
                <!-- if an @accid is present, no further action is required -->
                <xsl:when test="@accid">
                    <!--<xsl:message select="'[INFO]: @accid on ' || @xml:id || ' seems correct.'"/>-->
                    <xsl:copy-of select="@accid"/>
                </xsl:when>
                
                <!-- if accid on preceding note of same pitch is found -->
                <xsl:when test="$accids[@pname = $current.pname and 
                    (if($octave = 'strict') then(@oct = $current.oct) else(true())) and
                    number(@tstamp) lt $current.tstamp]">
                    
                    <xsl:variable name="preceding.accid" select="$accids[@pname = $current.pname and 
                        (if($octave = 'strict') then(@oct = $current.oct) else(true())) and
                        number(@tstamp) lt $current.tstamp][last()]" as="element()"/>
                    
                    <xsl:choose>
                        <xsl:when test="@accid.ges and string(@accid.ges) != string($preceding.accid/@accid)">
                            <xsl:message terminate="no" select="'False @accid.ges on note #' || $current.id || '. Accid earlier in the staff. @accid.ges was: ' || @accid.ges || ', is: ' || string($preceding.accid/@accid)"/>
                            <xsl:attribute name="accid.ges" select="string($preceding.accid/@accid)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="accid.ges" select="string($preceding.accid/@accid)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:when>
                
                <!-- if note is tied to note in preceding staff -->
                <xsl:when test="@tie and @tie = ('m','t') and @tstamp = '1'">
                    <xsl:variable name="tieStart" select="local:getTieStartInPrecedingStaff(ancestor::mei:staff,$current.pname)" as="element()?"/>
                    
                    <xsl:if test="@xml:id='x3f1978d6-70db-48ea-8c81-c6a21ecc73e9'">
                        <xsl:message select="'DINGELINGELING'"></xsl:message>
                        <xsl:message select="$tieStart"/>
                    </xsl:if>
                    
                    <xsl:choose>
                        
                        <!-- the note seems incorrectly tied -->
                        <xsl:when test="not(exists($tieStart))">
                            <xsl:message terminate="no" select="'note ' || @xml:id || ' in ' || ancestor::mei:staff/@xml:id || ' seems incorrectly tied. Please check!'"/>
                        </xsl:when>
                        <!-- the note where the tie starts has an @accid by itself -->
                        <xsl:when test="$tieStart/@accid">
                            <xsl:attribute name="accid.ges" select="string($tieStart/@accid)"/>
                        </xsl:when>
                        
                        <!-- when tiestart has an accid.ges that conforms to the keySig -->
                        <xsl:when test="$tieStart/@accid.ges and exists($key.sig.mod) and string($tieStart/@accid.ges) = $key.sig.mod">
                            <xsl:message select="'DONGELONGELOnG'"/>
                            <xsl:message select="'adding @accid.ges on ' || @xml:id"/>
                            <xsl:attribute name="accid.ges" select="string($tieStart/@accid.ges)"/>
                        </xsl:when>
                        
                        <!-- when there is a preceding note in that measure that has an accid for the same pname -->
                        <xsl:when test="number($tieStart/@tstamp) gt 1 and 
                            $tieStart/ancestor::mei:staff[.//mei:note[@pname = $current.pname and 
                                (if($octave) then(@oct = $tieStart/@oct) else(true())) and
                                number(@tstamp) lt number($tieStart/@tstamp) and
                                @accid]]">
                            <xsl:variable name="accid.ges" select="$tieStart/ancestor::mei:staff//mei:note[@pname = $current.pname and 
                                (if($octave) then(@oct = $tieStart/@oct) else(true())) and
                                number(@tstamp) lt number($tieStart/@tstamp) and
                                @accid][last()]/@accid" as="xs:string"/>
                            
                            <xsl:choose>
                                <xsl:when test="@accid.ges and string(@accid.ges) != string($accid.ges)">
                                    <xsl:message terminate="no" select="'False @accid.ges on note #' || $current.id || '. To be derived from preceding measure. @accid.ges: ' || @accid.ges || ', is: ' || string($accid.ges)"/>
                                    <xsl:attribute name="accid.ges" select="$accid.ges"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="accid.ges" select="$accid.ges"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:when>
                    </xsl:choose>
                    
                </xsl:when>
                
                <!-- accid depending on key.sig -->
                <xsl:when test="exists($key.sig.mod)">
                    <xsl:choose>
                        <xsl:when test="@accid.ges and string(@accid.ges) != $key.sig.mod">
                            <xsl:message terminate="no" select="'False @accid.ges on note #' || $current.id || '. Key sig differs. @accid.ges was: ' || @accid.ges || ', is: ' || $key.sig.mod"/>
                            <xsl:attribute name="accid.ges" select="$key.sig.mod"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="accid.ges" select="$key.sig.mod"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
            </xsl:choose>
            
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:function name="local:getTieStartInPrecedingStaff" as="element()?">
        <xsl:param name="staff" as="element()"/>
        <xsl:param name="pname" as="xs:string"/>
        <xsl:variable name="preceding.staff" select="local:getPrecedingStaff($staff)"/>
        <xsl:choose>
            <xsl:when test="$preceding.staff//mei:note[@tie = 'i' and @pname = $pname]">
                <xsl:sequence select="($preceding.staff//mei:note[@tie = 'i' and @pname = $pname])[last()]"/>
            </xsl:when>
            <xsl:when test="$preceding.staff">
                <xsl:sequence select="local:getTieStartInPrecedingStaff($preceding.staff,$pname)"/>
            </xsl:when>
            <xsl:otherwise>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="local:getPrecedingStaff" as="element()?">
        <xsl:param name="staff" as="element()"/>
        <xsl:variable name="n" select="$staff/@n"/>
        <xsl:sequence select="$staff/preceding::mei:staff[@n = $n][1]"/>
    </xsl:function>
    
</xsl:stylesheet>