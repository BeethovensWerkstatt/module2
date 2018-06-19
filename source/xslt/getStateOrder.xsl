<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs math xd mei xhtml" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 3, 2015</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> maja</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="states" select="//mei:state" as="node()*"/>
    <xsl:template match="/">
        <xsl:variable name="bi.directional.links" as="node()">
            <xsl:apply-templates select="//mei:creation/mei:genDesc" mode="fill.links"/>
        </xsl:variable>
        <xsl:variable name="ordered.states" as="node()*">
            <xsl:apply-templates select="$bi.directional.links//mei:state[not(@prev) and not(@follows)]" mode="order.states">
                <xsl:with-param name="step" select="1" as="xs:integer" tunnel="yes"/>
                <xsl:with-param name="bi.directional.links" select="$bi.directional.links" tunnel="yes" as="node()*"/>
                <xsl:with-param name="is.clear.step" select="true()" as="xs:boolean"/>
            </xsl:apply-templates>
        </xsl:variable>
        <div xmlns="http://www.w3.org/1999/xhtml" class="processedStates">
            <xsl:copy-of select="$ordered.states"/>
        </div>
    </xsl:template>
    <xsl:template match="mei:state" mode="fill.links">
        <xsl:variable name="this.id" select="@xml:id" as="xs:string"/>
        <xsl:copy>
            <xsl:variable name="pointing.nexts" select="$states/descendant-or-self::mei:state[$this.id = tokenize(replace(@next,'#',''),' ')]" as="node()*"/>
            <xsl:variable name="pointing.prevs" select="$states/descendant-or-self::mei:state[$this.id = tokenize(replace(@prev,'#',''),' ')]" as="node()*"/>
            <xsl:variable name="pointing.follows" select="$states/descendant-or-self::mei:state[$this.id = tokenize(replace(@follows,'#',''),' ')]" as="node()*"/>
            <xsl:variable name="pointing.precedes" select="$states/descendant-or-self::mei:state[$this.id = tokenize(replace(@precedes,'#',''),' ')]" as="node()*"/>
            <xsl:if test="not(@prev) and count($pointing.nexts) gt 0">
                <xsl:attribute name="prev" select="string-join($pointing.nexts/concat('#',@xml:id),' ')"/>
            </xsl:if>
            <xsl:if test="not(@next) and count($pointing.prevs) gt 0">
                <xsl:attribute name="next" select="string-join($pointing.prevs/concat('#',@xml:id),' ')"/>
            </xsl:if>
            <xsl:if test="not(@follows) and count($pointing.precedes) gt 0">
                <xsl:attribute name="follows" select="string-join($pointing.precedes/concat('#',@xml:id),' ')"/>
            </xsl:if>
            <xsl:if test="@follows and count($pointing.precedes) gt 0">
                <xsl:variable name="existing.follows" select="tokenize(@follows,' ')" as="xs:string*"/>
                <xsl:variable name="new.follows" select="$pointing.precedes/concat('#',@xml:id)" as="xs:string*"/>
                <xsl:attribute name="follows" select="string-join(distinct-values(($existing.follows,$new.follows)),' ')"/>
            </xsl:if>
            <xsl:if test="@follows and count($pointing.precedes) = 0">
                <xsl:attribute name="follows" select="@follows"/>
            </xsl:if>
            <xsl:if test="not(@precedes) and count($pointing.follows) gt 0">
                <xsl:attribute name="precedes" select="string-join($pointing.follows/concat('#',@xml:id),' ')"/>
            </xsl:if>
            <xsl:if test="@precedes and count($pointing.follows) gt 0">
                <!--<xsl:message select="$this.id || ' has a @precedes, but needs ' || count($pointing.follows) || ' more pointers'"/>-->
                <xsl:variable name="existing.precedes" select="tokenize(@precedes,' ')" as="xs:string*"/>
                <xsl:variable name="new.precedes" select="$pointing.follows/concat('#',@xml:id)" as="xs:string*"/>
                <xsl:variable name="all.precedes" select="($existing.precedes,$new.precedes)" as="xs:string*"/>
                <xsl:attribute name="precedes" select="string-join(distinct-values($all.precedes),' ')"/>
            </xsl:if>
            <xsl:if test="@precedes and count($pointing.follows) = 0">
                <xsl:attribute name="precedes" select="@precedes"/>
            </xsl:if>
            <xsl:apply-templates select="node() | (@* except (@follows,@precedes))" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:state" mode="order.states">
        <xsl:param name="step" tunnel="yes" as="xs:integer"/>
        <xsl:param name="bi.directional.links" tunnel="yes" as="node()*"/>
        <xsl:param name="is.clear.step" as="xs:boolean"/>
        <xsl:param name="alternatives" tunnel="no" required="no" as="node()*"/>
        <xsl:variable name="this.state" select="." as="node()"/>
        <xsl:choose>
            <xsl:when test="$is.clear.step">
                <div xmlns="http://www.w3.org/1999/xhtml" class="step" data-n="{$step}">
                    <xsl:apply-templates select="$this.state" mode="resolve.alternatives">
                        <xsl:with-param name="mode" select="'clear'"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div xmlns="http://www.w3.org/1999/xhtml" class="alternatives" data-n="{$step}">
                    <xsl:apply-templates select="$this.state" mode="resolve.alternatives">
                        <xsl:with-param name="mode" select="'alternative'"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="$alternatives" mode="resolve.alternatives">
                        <xsl:with-param name="mode" select="'alternative'"/>
                        <xsl:with-param name="first.alternative" select="$this.state" as="node()"/>
                    </xsl:apply-templates>
                </div>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="my.next" select="if($this.state/@next) then(replace($this.state/@next,'#','')) else()" as="xs:string?"/>
        <xsl:variable name="alternatives.next" select="$alternatives/descendant-or-self::mei:state[@next]/replace(@next,'#','')" as="xs:string*"/>
        <!--<xsl:if test="count(distinct-values(($my.next,$alternatives.next))) gt 1">
            <xsl:message terminate="yes" select="'ERROR: differeing @next found at elements ' || string-join(($this.state/@xml:id,$alternatives/@xml:id),', ') || '. Processing terminated.'"/>
        </xsl:if>-->
        <xsl:variable name="next" select="if(count(distinct-values(($my.next,$alternatives.next))) = 1) then($bi.directional.links/descendant-or-self::mei:state[@xml:id = ($my.next,$alternatives.next)]) else()" as="node()?"/>
        <xsl:variable name="my.precedes" select="tokenize(replace(@precedes,'#',''),' ')" as="xs:string*"/>
        <xsl:variable name="alternatives.precedes" select="$alternatives/tokenize(replace(@precedes,'#',''),' ')" as="xs:string*"/>
        <xsl:variable name="precedes" select="$bi.directional.links/descendant-or-self::mei:state[@xml:id = ($my.precedes,$alternatives.precedes)]" as="node()*"/>
        <!--<xsl:if test="$this.state/@xml:id = 'qwertz8a'">
            <xsl:message select="'$my.precedes: ' || string-join($my.precedes,', ')"/>
            <xsl:message select="'$alternatives.precedes: ' || string-join($alternatives.precedes,', ')"/>
            <xsl:message select="'count($precedes): ' || count($precedes)"/>
            <xsl:message select="'$my.next: ' || string-join($my.next,', ')"/>
            <xsl:message select="'$alternatives.next: ' || string-join($alternatives.next,', ')"/>
            <xsl:message select="'count($next): ' || count($next)"/>
            <xsl:message select="'$alternatives.ids: ' || string-join($alternatives/@xml:id,', ')"/>
        </xsl:if>-->
        <xsl:choose>
            <xsl:when test="exists($next)">
                <!--<xsl:message select="$this.state/@xml:id || ' in step ' || $step || ' has a clear follower (@next)'"/>-->
                <xsl:apply-templates select="$next" mode="order.states">
                    <xsl:with-param name="is.clear.step" select="true()" as="xs:boolean"/>
                    <xsl:with-param name="step" select="$step + 1" tunnel="yes" as="xs:integer"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="count($precedes) = 1">
                <!--<xsl:message select="$this.state/@xml:id || ' in step ' || $step || ' has a clear follower (1 @follows)'"/>-->
                <xsl:apply-templates select="$precedes[1]" mode="order.states">
                    <xsl:with-param name="is.clear.step" select="true()" as="xs:boolean"/>
                    <xsl:with-param name="step" select="$step + 1" tunnel="yes" as="xs:integer"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="count($precedes) gt 1">
                <!--<xsl:message select="$this.state/@xml:id || ' in step ' || $step || ' has multiple followers'"/>-->
                <xsl:apply-templates select="$precedes[1]" mode="order.states">
                    <xsl:with-param name="is.clear.step" select="false()" as="xs:boolean"/>
                    <xsl:with-param name="alternatives" select="$precedes[position() gt 1]" tunnel="no" as="node()*"/>
                    <xsl:with-param name="step" select="$step + 1" tunnel="yes" as="xs:integer"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:message select="'Have we reached an end with state ' || $this.state/@xml:id || '?'"/>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mei:state" mode="resolve.alternatives">
        <xsl:param name="first.alternative" as="node()?"/>
        <xsl:param name="mode" as="xs:string"/>
        <div xmlns="http://www.w3.org/1999/xhtml" data-stateID="{@xml:id}" class="state btn btn-sm btn-default{(if(not(@precedes) and not(@next)) then(' deadEnd') else(''))}{(if($mode = 'clear') then(' clearBtn') else if(not(@precedes) and not(@next)) then(' openEndBtn') else(' alternativeBtn'))}">
            <!--<xsl:apply-templates select="node() | @*" mode="#current"/>-->
            <h1>
                <div class="colorProbe"/><!--<i class="fa fa-square-o"/>-->
                <xsl:value-of select="if(@label) then(@label) else(@xml:id)"/>
            </h1>
        </div>
    </xsl:template>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>