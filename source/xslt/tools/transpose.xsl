<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:key="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom key uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Aug 7, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <!-- requires circleOf5.xsl -->
    
    
    <!-- INFO: First, a distance between old and new key is calculated. This distance
        is then passed to child sections, which are transposed to the key determined
        by that "offset".
    -->
    
    <xsl:variable name="pitches" select="('c','d','e','f','g','a','b')" as="xs:string+"/>
    
    <xsl:template match="mei:meiHead" mode="transpose"/>
    
    <xsl:template match="mei:mdiv" mode="transpose">
        <xsl:param name="target.key.name" tunnel="yes" as="xs:string"/>
        
        <xsl:variable name="start.key.name" select="(.//mei:section)[1]/@base.key" as="xs:string"/>
        <xsl:variable name="start.key" select="$circle.of.fifths//key:*[@name = $start.key.name]" as="node()"/>
        <xsl:variable name="target.key" select="$circle.of.fifths//key:*[@name = $target.key.name]" as="node()"/>
        
        <!-- distance of keys in the circle of fifths -->
        <xsl:variable name="key.distance" select="number($target.key/parent::key:pos/@n) - number($start.key/parent::key:pos/@n)" as="xs:double"/>
        
        <xsl:variable name="transpose.dir" select="custom:determineTransposeDirection($start.key.name,$target.key.name)" as="xs:string"/>
        
        <xsl:message select="'INFO: mdiv[' || (count(preceding-sibling::mei:mdiv) + 1) || '] needs a transposition by ' || $key.distance || ' fifths, direction is ' || $transpose.dir"/>
        
        <xsl:choose>
            <xsl:when test="$key.distance != 0">
                <xsl:next-match>
                    <xsl:with-param name="key.distance" select="$key.distance" as="xs:double" tunnel="yes"/>
                    <xsl:with-param name="transpose.dir" select="$transpose.dir" as="xs:string" tunnel="yes"/>
                </xsl:next-match>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
    <xsl:template match="mei:section | mei:ending" mode="transpose">
        <xsl:param name="key.distance" tunnel="yes" as="xs:double"/>
        
        <xsl:if test="not(@base.key)">
            <xsl:message select="'ERROR: There is a section without @base.key, which is required for mode transpose. 
                This is probably an error in the order of XSLTs being called. Please fix!'"/>
        </xsl:if>
        
        <xsl:variable name="start.key.name" select="@base.key" as="xs:string"/>
        <xsl:variable name="start.key" select="$circle.of.fifths//key:*[@name = $start.key.name]" as="node()"/>
        <xsl:variable name="start.key.pos" select="number($start.key/parent::key:pos/@n)" as="xs:double"/>
        
        <xsl:variable name="mode" select="local-name($start.key)" as="xs:string"/>
        <xsl:variable name="target.key" select="$circle.of.fifths//key:pos[number(@n) = $start.key.pos + $key.distance]/key:*[local-name() = $mode]" as="node()"/>
        
        <xsl:next-match>
            <xsl:with-param name="target.key" select="$target.key" tunnel="yes"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="mei:scoreDef/@key.sig | mei:staffDef/@key.sig" mode="transpose">
        <xsl:param name="key.distance" tunnel="yes" as="xs:double"/>
        
        <xsl:variable name="current.sig" select="string(.)" as="xs:string"/>
        <xsl:variable name="pos" select="number($circle.of.fifths//key:pos[.//@sig = $current.sig]/@n)" as="xs:double"/>
        
        <xsl:variable name="new.sig" select="$circle.of.fifths//key:pos[number(@n) = $pos + $key.distance]/key:major/@sig" as="xs:string"/>
        
        <xsl:attribute name="key.sig" select="$new.sig"/>
        
    </xsl:template>
    
    <xsl:template match="mei:note" mode="transpose">
        <xsl:param name="key.distance" tunnel="yes" as="xs:double"/>
        <xsl:param name="target.key" tunnel="yes" as="node()"/>
        <xsl:param name="transpose.dir" tunnel="yes" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$key.distance = 0">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    
                    <xsl:variable name="pitch" select="@pitch" as="xs:string"/>
                    <xsl:variable name="target.pname.full" select="$target.key/@*[local-name() = ('n' || substring($pitch,1,1))]" as="xs:string"/>
                    <xsl:variable name="target.pname" select="substring($target.pname.full,1,1)" as="xs:string"/>
                    
                    <!-- write new pname -->
                    <xsl:attribute name="pname" select="$target.pname"/>
                    <xsl:attribute name="oct" select="custom:revertRelOct(.,$target.pname,$transpose.dir)"/>
                    
                    <!-- check if accidentals are needed -->
                    <xsl:variable name="offset" as="xs:integer">
                        <xsl:choose>
                            <xsl:when test="string-length(@pitch) = 1">
                                <xsl:value-of select="0"/>
                            </xsl:when>
                            <xsl:when test="ends-with(@pitch,'---')">
                                <xsl:value-of select="-3"/>
                            </xsl:when>
                            <xsl:when test="ends-with(@pitch,'--')">
                                <xsl:value-of select="-2"/>
                            </xsl:when>
                            <xsl:when test="ends-with(@pitch,'-')">
                                <xsl:value-of select="-1"/>
                            </xsl:when>
                            <xsl:when test="ends-with(@pitch,'+++')">
                                <xsl:value-of select="3"/>
                            </xsl:when>
                            <xsl:when test="ends-with(@pitch,'++')">
                                <xsl:value-of select="2"/>
                            </xsl:when>
                            <xsl:when test="ends-with(@pitch,'+')">
                                <xsl:value-of select="1"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="standard.offset" select="number($target.key/parent::key:pos/@*[local-name() = $target.pname])" as="xs:double"/>
                    
                    <xsl:variable name="fits.scale" select="$offset = 0" as="xs:boolean"/>
                    
                    <xsl:choose>
                        <xsl:when test="$fits.scale and $standard.offset != 0 and not(@accid)">
                            <xsl:attribute name="accid.ges" select="substring($target.pname.full,2)"/>
                        </xsl:when>
                        <xsl:when test="$fits.scale and $standard.offset != 0 and @accid">
                            <xsl:attribute name="accid" select="replace(substring($target.pname.full,2),'ss','x')"/>
                        </xsl:when>
                        <xsl:when test="not($fits.scale) and @accid">
                            <xsl:attribute name="accid" select="custom:getAccidValue($offset,$standard.offset)"/>
                        </xsl:when>
                        <xsl:when test="not($fits.scale) and not(@accid)">
                            <xsl:attribute name="accid.ges" select="custom:getAccidValue($offset,$standard.offset)"/>
                        </xsl:when>
                    </xsl:choose>
                    
                    <xsl:apply-templates select="node() | @* except (@pname,@accid,@accid.ges,@oct)" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:function name="custom:getAccidValue" as="xs:string">
        <xsl:param name="offset" as="xs:integer" required="yes"/>
        <xsl:param name="standard.offset" as="xs:double" required="yes"/>
        
        <xsl:value-of select="($key.matrix//custom:accid.mod/@*[number(.) = ($offset + $standard.offset)])[1]/local-name()"/>
    </xsl:function>
    
    <xsl:function name="custom:revertRelOct" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="target.pname" as="xs:string" required="yes"/>
        <xsl:param name="transpose.dir" as="xs:string" required="yes"/>
        
        <!--<xsl:variable name="index.of.key" select="index-of($pitches,lower-case(substring($key,1,1)))" as="xs:integer"/>-->
        <xsl:variable name="index.of.old.pname" select="index-of($pitches,$note/@pname)" as="xs:integer"/>
        <xsl:variable name="index.of.new.pname" select="index-of($pitches,$target.pname)" as="xs:integer"/>
        
        <xsl:variable name="old.oct" select="number($note/@oct)" as="xs:double"/>
        
        <!--<xsl:variable name="oct.mismatch" select="$note/@rel.oct != $note/@oct" as="xs:boolean"/>
        
        <xsl:variable name="oct.mod" select="if($oct.mismatch and $index.of.pname lt $index.of.key) then(1) else(0)" as="xs:integer"/>
        <xsl:variable name="output" select="string($note/number(@rel.oct) + $oct.mod)" as="xs:string"/>
        
        
        <xsl:value-of select="$output"/>
        -->
        
        <xsl:choose>
            <xsl:when test="$index.of.new.pname lt $index.of.old.pname and $transpose.dir = 'down'">
                <xsl:value-of select="string($old.oct)"/>
            </xsl:when>
            <xsl:when test="$index.of.new.pname lt $index.of.old.pname and $transpose.dir = 'up'">
                <xsl:value-of select="string($old.oct + 1)"/>
            </xsl:when>
            <xsl:when test="$index.of.new.pname gt $index.of.old.pname and $transpose.dir = 'down'">
                <xsl:value-of select="string($old.oct - 1)"/>
            </xsl:when>
            <xsl:when test="$index.of.new.pname gt $index.of.old.pname and $transpose.dir = 'up'">
                <xsl:value-of select="string($old.oct)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string($old.oct)"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="custom:determineTransposeDirection" as="xs:string">
        <xsl:param name="start.key.name" as="xs:string" required="yes"/>
        <xsl:param name="target.key.name" as="xs:string" required="yes"/>
        
        <!-- distance of keys in diatonic steps, used to calculate the direction -->
        <xsl:variable name="index.start.key" select="index-of($pitches,lower-case(substring($start.key.name,1,1)))" as="xs:integer"/>
        <xsl:variable name="index.target.key" select="index-of($pitches,lower-case(substring($target.key.name,1,1)))" as="xs:integer"/>
        
        <xsl:choose>
            <!-- the direction is determined by the smaller interval – the new key will be no more than a fourth away -->
            <xsl:when test="$index.start.key gt $index.target.key and ($index.start.key - $index.target.key lt 4)">
                <xsl:value-of select="'down'"/>
            </xsl:when>
            <xsl:when test="$index.start.key gt $index.target.key and ($index.start.key - $index.target.key ge 4)">
                <xsl:value-of select="'up'"/>
            </xsl:when>
            <xsl:when test="$index.start.key lt $index.target.key and ($index.target.key - $index.start.key lt 4)">
                <xsl:value-of select="'up'"/>
            </xsl:when>
            <xsl:when test="$index.start.key lt $index.target.key and ($index.target.key - $index.start.key ge 4)">
                <xsl:value-of select="'down'"/>
            </xsl:when>
            <!-- default -->
            <xsl:otherwise>
                <xsl:value-of select="'up'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- this is a hack for op.14 -->
    <xsl:template match="@pnum" mode="special.transpose">
        <xsl:attribute name="pnum" select="if(string(.) != '') then(string(xs:integer(.) - 1)) else(.)"/>
    </xsl:template>
    
    
</xsl:stylesheet>