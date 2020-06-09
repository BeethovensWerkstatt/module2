<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs xhtml tei xsl uuid teix xd "
    version="2.0">
    
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> April 14, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Ran Mo</xd:p>
            <xd:p>This XSLT converts Codierungsrichtlinie to xhtml</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="html" indent="yes" doctype-system="about:legacy-compat" use-character-maps="CharMap"/>
    
    <xsl:character-map name="CharMap">
        <xsl:output-character character="&quot;" string="&amp;quot;"/>
    </xsl:character-map>
    
    
    <xsl:template match="/"> 
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    <xsl:template name="sch.name">
        <p class="schema">
        <xsl:text>im Schema: </xsl:text>
        <xsl:for-each select="descendant::tei:ref/text()">
            <xsl:if test="position() > 1">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="." />
        </xsl:for-each>
        </p>
    </xsl:template>
    
    
    <xsl:template match="tei:teiHeader | tei:schemaSpec"/>
    <xsl:strip-space elements="*"/>
    
    
   <xsl:template match="tei:div[@type='main']">
     <!--  <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>-->
       <html>
        <head>
            <!--<link rel="stylesheet" href="bw_richtlinie.css"/>-->
            <style>
            h1 {
            text-align: center;
            }
            h5 {
            font-size: 100%;
            }
            .contents{
            display:inline-block;
            background: #F1F1F1;
            padding: 20px;
            
            }
            dt{
            font-size: 105%;
            font-weight: normal;
            padding-bottom: 5px;
            
            }
            .toc_1 {
            padding-top: 0.5em;
            padding-bottom: 0.3em;
            font-size: 110%;
            }
            .toc_1_1 {
            padding-left:5%;
            }
            .toc_1_1_1 {
            padding-left:10%;
            }
            
            ul.contents a:link { color: black; text-decoration: none;}
            ul.contents a:visited { color: black; text-decoration: none;}
            ul.contents a:hover {  text-decoration: underline;}
            .att{
            font-weight: bold;
            }
            ul.contents{
            
            list-style:none;
            }
            div {
            margin-left: 10px; 
            }
            
            div.sub_2 {
            
            padding-bottom:1em;
            }
            .pre {
            white-space: pre-wrap;
            }
            li>.element {font-style: normal;
            }
            
            li>.element a:link { color: darkblue; text-decoration: none;}
            li>.element a:visited { color: darkblue; text-decoration: none;}
            li>.element a:hover {  text-decoration: underline;}
            
            
            .name{
            font-style: italic;
            }
            
            /* egXML */
            .indent1{
            box-shadow: 1px 1px 5px gray;
            background-color:#F3F3F3;
            display:inline-block;
            overflow:auto; 
            padding:3px;
            margin:10px;
            font-size:0.9em;
            font-family: monospace;
            white-space:pre;
            color: black;
            }
            
            div.indent > .element {
            color: darkblue;
            }
            
            .attribute {
            color: #008080;
            }
            
            .attributevalue {
            color: #800080;
            }
            </style>
            
            
            <title>
                <xsl:value-of select="string(tei:head[@type='main'])"/>
            </title>
            
        </head>
        <body>
                <div class="toc"><!-- toc -->
                    <h1><xsl:apply-templates select="tei:head[@type='main']"/></h1>
                    <h2>Inhaltsverzeichnis</h2>
                    <ul class="contents">
                       
                        
                        <xsl:for-each select="//tei:div[@type='sub_1']/descendant-or-self::tei:head">
                            <xsl:variable name="id" select="./@xml:id"/>
                            
                            <xsl:element name="li">
                                <xsl:if test="./@type = 'sub_1'">
                                    
                                <xsl:attribute name="class" select="'toc_1'"/>
                                <xsl:element name="a">
                                    <xsl:attribute name="href" select="concat('#',$id)"/>
                                    <xsl:variable name="level_sub_1">
                                        <xsl:number count="tei:div[@type='sub_1']" level="single" format="1."/>
                                    </xsl:variable>
                                    
                                    <xsl:value-of select="concat($level_sub_1,' ', ./text())"/>
                                </xsl:element>
                                </xsl:if>
                                
                                <xsl:if test="./@type = 'sub_2'">
                                    <xsl:attribute name="class" select="'toc_1_1'"/>
                                    <xsl:element name="a">
                                        <xsl:attribute name="href" select="concat('#',$id)"/>
                                        <xsl:variable name="level_sub_2">
                                            <xsl:number count="tei:div[@type='sub_1'] | tei:div[@type='sub_2']" level="multiple" format="1.1."/>
                                        </xsl:variable>
                                        
                                        <xsl:value-of select="concat($level_sub_2,' ', ./text())"/>
                                    </xsl:element>
                                </xsl:if>
                                
                                <xsl:if test="./@type = 'sub_3'">
                                    <xsl:attribute name="class" select="'toc_1_1_1'"/>
                                    <xsl:element name="a">
                                        <xsl:attribute name="href" select="concat('#',$id)"/>
                                        <xsl:variable name="level_sub_3">
                                            <xsl:number count="tei:div[@type='sub_1'] | tei:div[@type='sub_2'] | tei:div[@type='sub_3']" level="multiple" format="1.1.1."/>
                                        </xsl:variable>
                                        
                                        <xsl:value-of select="concat($level_sub_3,' ', ./text())"/>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:element>
                            
                        </xsl:for-each>
                    </ul>
                </div>
            
            <div class="main">
                <xsl:for-each select="//tei:head[@type='sub_1']">
                    <xsl:variable name="level_sub_1">
                        <xsl:number count="tei:div[@type='sub_1']" level="single" format="1."/>
                    </xsl:variable>
                    <xsl:element name="div">
                        <xsl:attribute name="class" select="string(@type)"/>
                        <xsl:element name="h3">
                            <xsl:attribute name="id" select="./@xml:id/string()"/>
                            <xsl:value-of select="concat($level_sub_1,' ', .)"/>
                        </xsl:element>
                        
                        <!-- sub_1 item -->
                        <xsl:if test="not(following-sibling::tei:div)">
                            <ul>
                                <li class="item"><xsl:apply-templates/></li>
                            </ul>
                        </xsl:if>
                        
                        <xsl:for-each select="./following-sibling::tei:div">
                        <xsl:element name="div"><!-- sub_2 div -->
                            <xsl:attribute name="class" select="string(@type)"/>
                            <xsl:element name="h4">
                                <xsl:variable name="level_sub_2">
                                    <xsl:number count="tei:div[@type='sub_1'] | tei:div[@type='sub_2']" level="multiple" format="1.1."/>
                                </xsl:variable>
                                <xsl:attribute name="id" select="./tei:head[@type='sub_2']/@xml:id/string()"/>
                                <xsl:value-of select="concat($level_sub_2,' ', ./tei:head[@type='sub_2'])"/>
                            </xsl:element>
                            
                            <xsl:for-each select="./tei:div"><!-- sub_3 div -->
                                <xsl:element name="div">
                                    <xsl:attribute name="class" select="string(@type)"/>
                                    <xsl:element name="h5">
                                        <xsl:variable name="level_sub_3">
                                            <xsl:number count="tei:div[@type='sub_1'] | tei:div[@type='sub_2']| tei:div[@type='sub_3']" level="multiple" format="1.1.1."/>
                                        </xsl:variable>
                                        <xsl:attribute name="id" select="./tei:head[@type='sub_3']/@xml:id/string()"/>
                                        <xsl:value-of select="concat($level_sub_3,' ', ./tei:head[@type='sub_3'])"/>
                                    </xsl:element>
                                    
                                    <ul>
                                    <xsl:for-each select="./tei:list/tei:item">
                                      <li class="item"><xsl:apply-templates/></li>
                                    </xsl:for-each>
                                    </ul>
                                    
                                    <xsl:if test="descendant::teix:egXML">
                                        <xsl:for-each select="teix:egXML/child::node()">
                                            <xsl:apply-templates select="." mode="preserveSpace"/>
                                        </xsl:for-each>
                                    </xsl:if>
                                    
                                   <xsl:if test="descendant::tei:ref">
                                                <xsl:call-template name="sch.name"/>
                                   </xsl:if>
                                        
                                </xsl:element>
                            </xsl:for-each>
                            
                            <xsl:if test="./tei:list">
                            <ul>
                            <xsl:for-each select="./tei:list/tei:item">
                                <!-- sub_2 items -->
                                    <li class="item"><xsl:apply-templates/></li>
                            </xsl:for-each>
                            </ul>
                                
                                <xsl:if test="descendant::teix:egXML">
                                        <xsl:for-each select="teix:egXML/child::node()">
                                            <xsl:apply-templates select="." mode="preserveSpace"/>
                                        </xsl:for-each>
                                </xsl:if>
                                
                                <xsl:if test="descendant::tei:ref">
                                       <xsl:call-template name="sch.name"/>
                                </xsl:if>
                            </xsl:if>
                         
                        </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                
                </xsl:for-each>
            </div>
            
        </body>
    </html>
    
   </xsl:template>
   
   <xsl:template match="tei:name[@type='org']">
       <span class="name">
           <xsl:value-of select="."/>
       </span>
   </xsl:template>
    
    <xsl:template match="tei:tag">
        <xsl:variable name="element" select="lower-case(.)"/>
        <xsl:variable name="ele.link" select="concat('https://music-encoding.org/guidelines/v4/elements/', $element, '.html')"/>
        
        <span class="element"> 
            <a>
                <xsl:attribute name="href" select="$ele.link"/><xsl:text>&lt;</xsl:text><xsl:value-of select="."/><xsl:text>&gt;</xsl:text></a></span>
    </xsl:template>
    <xsl:template match="tei:att">
        <span class="att"><xsl:value-of select="concat('@', .)"/></span>
    </xsl:template>
    
    <xsl:template match="teix:egXML" mode="preserveSpace" priority="5">
        <xsl:copy-of select="node()"/>
    </xsl:template>
    
    <!-- in order to preserve spacing, it is important that the following template is kept on one line -->
    <xsl:template match="element()" mode="preserveSpace" priority="1">
        <xsl:param name="indent" as="xs:integer?"/>
        <xsl:variable name="indent.level" select="if($indent) then($indent) else(1)" as="xs:integer"/>
        <xsl:variable name="element" select="." as="node()"/>
        <xsl:choose>
            <xsl:when test="local-name() = 'param' and @name = 'pattern' and string-length(text()) gt 30">
                <div class="indent{$indent.level} indent"><span data-indentation="{$indent.level}" class="element">&lt;<xsl:value-of select="name($element)"/><xsl:apply-templates select="$element/@*" mode="#current"/>&gt;</span>
                    <xsl:choose>
                        <xsl:when test="string-length(text()) gt 240">
                            <div class="indent{$indent.level + 1} indent"><xsl:value-of select="substring(text(),1,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),61,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),121,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),181,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),241,60)"/></div>
                        </xsl:when>
                        <xsl:when test="string-length(text()) gt 180">
                            <div class="indent{$indent.level + 1} indent"><xsl:value-of select="substring(text(),1,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),61,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),121,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),181,60)"/></div>
                        </xsl:when>
                        <xsl:when test="string-length(text()) gt 120">
                            <div class="indent{$indent.level + 1} indent"><xsl:value-of select="substring(text(),1,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),61,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),121,60)"/></div>
                        </xsl:when>
                        <xsl:when test="string-length(text()) gt 60">
                            <div class="indent{$indent.level + 1} indent"><xsl:value-of select="substring(text(),1,60)"/></div>
                            <div class="indent{$indent.level + 2} dblIndent"><xsl:value-of select="substring(text(),61,60)"/></div>
                        </xsl:when>
                        <xsl:when test="string-length(text()) gt 30">
                            <div class="indent{$indent.level + 1} indent"><xsl:value-of select="substring(text(),1,100)"/></div>        
                        </xsl:when>
                    </xsl:choose>
                    <span data-indentation="{$indent.level}" class="element">&lt;/<xsl:value-of select="name($element)"/>&gt;</span></div>
            </xsl:when>
            <xsl:otherwise>
                <div class="indent{$indent.level} indent"><span data-indentation="{$indent.level}" class="element">&lt;<xsl:value-of select="name($element)"/><xsl:apply-templates select="$element/@*" mode="#current"/><xsl:if test="not($element/node())">/</xsl:if>&gt;</span><xsl:apply-templates select="$element/node()" mode="#current"><xsl:with-param name="indent" select="$indent.level + 1" as="xs:integer"/></xsl:apply-templates><xsl:if test="$element/node()"><span data-indentation="{$indent.level}" class="element">&lt;/<xsl:value-of select="name($element)"/>&gt;</span></xsl:if></div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- in order to preserve spacing, it is important that the following template is kept on one line -->
    <xsl:template match="comment()" mode="preserveSpace" priority="1">
        <xsl:param name="indent" as="xs:integer?"/>
        <xsl:variable name="indent.level" select="if($indent) then($indent) else(1)" as="xs:integer"/>
        <xsl:variable name="element" select="." as="node()"/>
        <div class="indent{$indent.level} indent"><span data-indentation="{$indent.level}" class="comment">&lt;!--<xsl:value-of select="."/>--&gt;</span></div>   
    </xsl:template>
    
    <!-- in order to preserve spacing, it is important that the following template is kept on one line -->
    <xsl:template match="@*" mode="preserveSpace" priority="1"><xsl:value-of select="' '"/><span class="attribute"><xsl:value-of select="name()"/>=</span><span class="attributevalue"><xsl:text>&quot;</xsl:text><xsl:value-of select="string(.)"/><xsl:text>&quot;</xsl:text></span></xsl:template>
    
    
    <!--<xsl:template match="@mode[not(ancestor::teix:egXML)]" mode="preserveSpace" priority="2">
        <xsl:param name="getODD" tunnel="yes" as="xs:boolean?"/>
        <!-\-<xsl:if test="not($getODD) or $getODD = false()">
            <xsl:next-match/>
        </xsl:if>-\->
    </xsl:template>
    -->
    
</xsl:stylesheet>
