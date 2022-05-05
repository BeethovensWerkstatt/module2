<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:mat="http://www.w3.org/2005/xpath-functions/mat" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" xmlns:key="none" exclude-result-prefixes="xs mat xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <!-- requires circleOf5.xsl -->
    
    <xsl:template match="mei:measure" mode="determine.pitch">
        <xsl:variable name="added.normalized.pitch" as="node()*">
            <xsl:apply-templates select="child::node()" mode="determine.pitch_add.normalized.pitch"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="$added.normalized.pitch" mode="#current">
                <!--<xsl:with-param name="file1.pitches" select="$file1.pitches" as="node()*"
                    tunnel="yes"/>
                <xsl:with-param name="file2.pitches" select="$file2.pitches" as="node()*"
                    tunnel="yes"/>-->
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:note" mode="determine.pitch_add.normalized.pitch">
        <xsl:variable name="key" select="if(ancestor::mei:staff/@staff.key) then(ancestor::mei:staff/@staff.key) else if(ancestor::mei:ending[@base.key]) then(ancestor::mei:ending[@base.key]/@base.key) else(ancestor::mei:section[@base.key]/@base.key)" as="xs:string"/>
        <xsl:variable name="base.key" select="if(ancestor::mei:ending[@base.key]) then(ancestor::mei:ending[@base.key]/@base.key) else(ancestor::mei:section[@base.key]/@base.key)" as="xs:string"/>
        <xsl:variable name="trans.dir" as="xs:integer">
            <xsl:choose>
                <xsl:when test="not(exists(ancestor::mei:staff/@trans.semi))">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:when test="starts-with(ancestor::mei:staff/@trans.semi,'-')">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="trans.diat" as="xs:integer">
            <xsl:choose>
                <xsl:when test="not(exists(ancestor::mei:staff/@trans.diat))">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::mei:staff/@trans.diat"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:attribute name="pitch" select="custom:qualifyPitch(., $key)"/>
            <xsl:attribute name="rel.oct" select="custom:determineOct(., $key,$trans.dir, $trans.diat, $base.key)"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- required only as exist-db doesn't support the regular math:pow function: bug! -->
    <xsl:function name="mat:pow">
        <xsl:param name="base"/>
        <xsl:param name="power"/>
        <xsl:choose>
            <xsl:when test="number($base) != $base or number($power) != $power">
                <xsl:value-of select="'NaN'"/>
            </xsl:when>
            <xsl:when test="$power = 0">
                <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$base * mat:pow($base, $power - 1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="custom:qualifyPitch" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="key" as="xs:string" required="yes"/>
        
        <xsl:variable name="key.elem" select="$circle.of.fifths//key:*[@name = $key]" as="node()"/>
        
        <xsl:variable name="base.step" select="number($key.elem//@*[local-name() = $note/@pname])" as="xs:double"/>
        
        <xsl:variable name="local.accid.name" as="xs:string">
            <xsl:choose>
                <xsl:when test="$note/@accid">
                    <xsl:value-of select="$note/@accid"/>
                </xsl:when>
                <xsl:when test="$note/@accid.ges">
                    <xsl:value-of select="$note/@accid.ges"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'n'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="local.accid.value" select="$accidental.values/descendant-or-self::key:accid.value/number(@*[local-name() = $local.accid.name])" as="xs:double"/>
        
        <xsl:variable name="regular.accid.value" select="number($key.elem/parent::key:pos/@*[local-name() = $note/@pname])" as="xs:double"/>
        <xsl:variable name="accid.diff" select="$local.accid.value - $regular.accid.value" as="xs:double"/>
        
        <xsl:variable name="step.mod" as="xs:string">
            <xsl:choose>
                <xsl:when test="$accid.diff = -3">
                    <xsl:value-of select="'---'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = -2">
                    <xsl:value-of select="'--'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = -1">
                    <xsl:value-of select="'-'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = 0">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$accid.diff = 1">
                    <xsl:value-of select="'+'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = 2">
                    <xsl:value-of select="'++'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = 3">
                    <xsl:value-of select="'+++'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($base.step,$step.mod)"/>
    </xsl:function>
    <xsl:function name="custom:determineOct" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="key" as="xs:string" required="yes"/>
        <xsl:param name="trans.dir" as="xs:integer" required="yes"/>
        <xsl:param name="trans.diat" as="xs:integer" required="yes"/>
        <xsl:param name="base.key" as="xs:string" required="yes"/>
        <xsl:variable name="pitches" select="('c','d','e','f','g','a','b')" as="xs:string+"/>
        <xsl:variable name="index.of.key" select="index-of($pitches,lower-case(substring($key,1,1)))" as="xs:integer"/>
        <xsl:variable name="index.of.base.key" select="index-of($pitches,lower-case(substring($base.key,1,1)))" as="xs:integer"/>
        <xsl:variable name="index.of.pname" select="index-of($pitches,$note/@pname)" as="xs:integer"/>
        <xsl:variable name="base.oct" select="if($note/@oct.ges) then($note/xs:integer(@oct.ges)) else($note/xs:integer(@oct))" as="xs:integer"/>
        <xsl:variable name="oct.mod" as="xs:integer">
            <!-- approach 1 -->
            <!--<xsl:choose>
                <!-\- in keys of A / B, pitches in the upper range will be treated as one octave higher… -\->
                <xsl:when test="$index.of.key ge 6 and $index.of.pname ge $index.of.key">
                    <xsl:value-of select="+1"/>
                </xsl:when>
                <!-\- …or as in the same octave -\->
                <xsl:when test="$index.of.key ge 6">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:when test="$index.of.pname lt $index.of.key">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>-->
            
            <!-- approach 2 -->
            <!--<xsl:choose>
                <xsl:when test="$index.of.key gt $index.of.pname">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <!-\- offset all C-keys by -1; was necessary for Op.122 -\->
                <!-\-<xsl:when test="$index.of.key = 1">
                    <xsl:value-of select="-1"/>
                </xsl:when>-\->
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>-->
            
            <!-- approach 3 -->
            <xsl:variable name="new.index.prep" select="$index.of.pname - ($index.of.key - 1)" as="xs:integer"/>
            <xsl:variable name="new.index" select="if($new.index.prep lt 1) then($new.index.prep + 7) else($new.index.prep)" as="xs:integer"/>
            <xsl:choose>
                <xsl:when test="8 - $index.of.key lt $new.index">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$note/@xml:id = 'x11e7dff3-0ef9-477f-b99c-0203f094a055'">
            <xsl:message select="'-------oct.mod: ' || $oct.mod || ' 8 - $index.of.key:' || $index.of.key || ' is less than $index.of.pname: ' || $index.of.pname"/>
        </xsl:if>
        
        <!-- approach 3 -->
        <xsl:variable name="trans.mod.new" as="xs:integer">
            <xsl:variable name="step1" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="$key = $base.key and $trans.diat = -7">
                        <xsl:value-of select="-1"/>
                    </xsl:when>
                    <xsl:when test="$key = $base.key and $trans.diat = 7">
                        <xsl:value-of select="1"/>
                    </xsl:when>
                    <xsl:when test="$key = $base.key">
                        <xsl:value-of select="0"/>
                    </xsl:when>
                    <xsl:when test="$trans.dir = -1 and $index.of.key lt $index.of.base.key">
                        <xsl:value-of select="-1"/>
                    </xsl:when>
                    <xsl:when test="$trans.dir = 1 and $index.of.key gt $index.of.base.key">
                        <xsl:value-of select="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="step2" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="$trans.diat ge 14"><xsl:value-of select="2"/></xsl:when>
                    <xsl:when test="$trans.diat ge 8"><xsl:value-of select="1"/></xsl:when><!-- a value of 7 is already covered above -->
                    <xsl:when test="$trans.diat le -14"><xsl:value-of select="-2"/></xsl:when>
                    <xsl:when test="$trans.diat le -8"><xsl:value-of select="-1"/></xsl:when><!-- a value of 7 is already covered above -->
                    <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$step1 + $step2"/>
        </xsl:variable>
        
        <!--<xsl:if test="$trans.mod.new != 0">
            <xsl:message select="'  ' || $note/@xml:id || ' has ' || $trans.mod.new"/>
        </xsl:if>-->
        
        <!--<xsl:variable name="trans.mod" select="if($trans.dir = -1) then(0) else(0)"/>-->
        <xsl:variable name="trans.mod" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$index.of.key + $trans.diat lt 0">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:when test="$trans.diat = -7">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:when test="$trans.diat = 7">
                    <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--<xsl:variable name="output" select="string($base.oct + $oct.mod + $trans.mod.new)" as="xs:string"/>-->
        <!--<xsl:value-of select="$output"/>-->
        <xsl:value-of select="string($base.oct + $oct.mod + $trans.mod.new)"/>
    </xsl:function>
</xsl:stylesheet>