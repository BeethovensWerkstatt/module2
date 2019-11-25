<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:local="no:link"
    exclude-result-prefixes="xs math xd mei local"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 25, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>
                This XSLT generates a report of the differences between two works. It is applied to the 
                output of the comparison XSLTs, i.e. the file available from 
                https://dev.beethovens-werkstatt.de/resources/xql/getAnalysis.xql?comparisonId=x418650e0-d899-4e3d-bff3-f7d459e1d5d7&amp;method=comparison&amp;mdiv=1&amp;transpose=none
                (when copying the link from above, make sure to resolve the ampersand character &amp;)
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:template match="/">
        <xsl:variable name="workTitle" select="//mei:meiHead/mei:fileDesc/mei:titleStmt/mei:title[@type='main']" as="xs:string"/>
        
        <xsl:variable name="total.notes" select="count(//mei:note[@type])" as="xs:integer"/>
        <xsl:variable name="notes.file1" select="//mei:staff[@type='file1']//mei:note[@type]" as="node()*"/>
        <xsl:variable name="notes.file2" select="//mei:staff[@type='file2']//mei:note[@type]" as="node()*"/>
        
        <xsl:variable name="identical.notes.file1" select="$notes.file1[local:getValue(.) = 1]"/>
        <xsl:variable name="identical.notes.file2" select="$notes.file2[local:getValue(.) = 1]"/>
        
        <xsl:variable name="octaving.notes.file1" select="$notes.file1[local:getValue(.) = 2]"/>
        <xsl:variable name="octaving.notes.file2" select="$notes.file2[local:getValue(.) = 2]"/>
        
        <xsl:variable name="otherDur.notes.file1" select="$notes.file1[local:getValue(.) = 3]"/>
        <xsl:variable name="otherDur.notes.file2" select="$notes.file2[local:getValue(.) = 3]"/>
        
        <xsl:variable name="octavingOtherDur.notes.file1" select="$notes.file1[local:getValue(.) = 4]"/>
        <xsl:variable name="octavingOtherDur.notes.file2" select="$notes.file2[local:getValue(.) = 4]"/>
        
        <xsl:variable name="otherPitchClass.notes.file1" select="$notes.file1[local:getValue(.) = 5]"/>
        <xsl:variable name="otherPitchClass.notes.file2" select="$notes.file2[local:getValue(.) = 5]"/>
        
        <xsl:variable name="different.notes.file1" select="$notes.file1[local:getValue(.) = 6]"/>
        <xsl:variable name="different.notes.file2" select="$notes.file2[local:getValue(.) = 6]"/>
        
        <report date="{substring(string(current-date()),1,10)}">
            <work title="{$workTitle}"/>
            <noteCount>
                <file1 num="{count($notes.file1)}"/>
                <file2 num="{count($notes.file2)}"/>
                <total num="{$total.notes}"/>
                <increase 
                    num="{count($notes.file2) - count($notes.file1)}"  
                    percent="{round(100 div count($notes.file1) * count($notes.file2) - 100,2)}"/>
            </noteCount>
            <identical>
                <file1 
                    num="{count($identical.notes.file1)}"
                    percent="{round(100 div count($notes.file1) * count($identical.notes.file1),2)}"/>
                <file2 
                    num="{count($identical.notes.file2)}" 
                    percent="{round(100 div count($notes.file2) * count($identical.notes.file2),2)}"/>
                <total
                    num="{(count($identical.notes.file1) + count($identical.notes.file2))}"
                    percent="{round(100 div $total.notes * (count($identical.notes.file1) + count($identical.notes.file2)),2)}" />
                <increase
                    num="{count($identical.notes.file2) - count($identical.notes.file1)}" 
                    percent="{round(100 div $total.notes * (count($identical.notes.file2) - count($identical.notes.file1)), 2)}"/>
            </identical>
            <octaving>
                <file1 
                    num="{count($octaving.notes.file1)}"
                    percent="{round(100 div count($notes.file1) * count($octaving.notes.file1),2)}"/>
                <file2 
                    num="{count($octaving.notes.file2)}" 
                    percent="{round(100 div count($notes.file2) * count($octaving.notes.file2),2)}"/>
                <total
                    num="{(count($octaving.notes.file1) + count($octaving.notes.file2))}"
                    percent="{round(100 div $total.notes * (count($octaving.notes.file1) + count($octaving.notes.file2)),2)}" />
                <increase
                    num="{count($octaving.notes.file2) - count($octaving.notes.file1)}" 
                    percent="{round(100 div $total.notes * (count($octaving.notes.file2) - count($octaving.notes.file1)), 2)}"/>
            </octaving>
            <otherDur>
                <file1 
                    num="{count($otherDur.notes.file1)}"
                    percent="{round(100 div count($notes.file1) * count($otherDur.notes.file1),2)}"/>
                <file2 
                    num="{count($otherDur.notes.file2)}" 
                    percent="{round(100 div count($notes.file2) * count($otherDur.notes.file2),2)}"/>
                <total
                    num="{(count($otherDur.notes.file1) + count($otherDur.notes.file2))}"
                    percent="{round(100 div $total.notes * (count($otherDur.notes.file1) + count($otherDur.notes.file2)),2)}" />
                <increase
                    num="{count($otherDur.notes.file2) - count($otherDur.notes.file1)}" 
                    percent="{round(100 div $total.notes * (count($otherDur.notes.file2) - count($otherDur.notes.file1)), 2)}"/>
            </otherDur>
            <octavingOtherDur>
                <file1 
                    num="{count($octavingOtherDur.notes.file1)}"
                    percent="{round(100 div count($notes.file1) * count($octavingOtherDur.notes.file1),2)}"/>
                <file2 
                    num="{count($octavingOtherDur.notes.file2)}" 
                    percent="{round(100 div count($notes.file2) * count($octavingOtherDur.notes.file2),2)}"/>
                <total
                    num="{(count($octavingOtherDur.notes.file1) + count($octavingOtherDur.notes.file2))}"
                    percent="{round(100 div $total.notes * (count($octavingOtherDur.notes.file1) + count($octavingOtherDur.notes.file2)),2)}" />
                <increase
                    num="{count($octavingOtherDur.notes.file2) - count($octavingOtherDur.notes.file1)}" 
                    percent="{round(100 div $total.notes * (count($octavingOtherDur.notes.file2) - count($octavingOtherDur.notes.file1)), 2)}"/>
            </octavingOtherDur>
            <otherPitchClass>
                <file1 
                    num="{count($otherPitchClass.notes.file1)}"
                    percent="{round(100 div count($notes.file1) * count($otherPitchClass.notes.file1),2)}"/>
                <file2 
                    num="{count($otherPitchClass.notes.file2)}" 
                    percent="{round(100 div count($notes.file2) * count($otherPitchClass.notes.file2),2)}"/>
                <total
                    num="{(count($otherPitchClass.notes.file1) + count($otherPitchClass.notes.file2))}"
                    percent="{round(100 div $total.notes * (count($otherPitchClass.notes.file1) + count($otherPitchClass.notes.file2)),2)}" />
                <increase
                    num="{count($otherPitchClass.notes.file2) - count($otherPitchClass.notes.file1)}" 
                    percent="{round(100 div $total.notes * (count($otherPitchClass.notes.file2) - count($otherPitchClass.notes.file1)), 2)}"/>
            </otherPitchClass>
            <different>
                <file1 
                    num="{count($different.notes.file1)}"
                    percent="{round(100 div count($notes.file1) * count($different.notes.file1),2)}"/>
                <file2 
                    num="{count($different.notes.file2)}" 
                    percent="{round(100 div count($notes.file2) * count($different.notes.file2),2)}"/>
                <total
                    num="{(count($different.notes.file1) + count($different.notes.file2))}"
                    percent="{round(100 div $total.notes * (count($different.notes.file1) + count($different.notes.file2)),2)}" />
                <increase
                    num="{count($different.notes.file2) - count($different.notes.file1)}" 
                    percent="{round(100 div $total.notes * (count($different.notes.file2) - count($different.notes.file1)), 2)}"/>
            </different>
        </report>
    </xsl:template>
    
    <xsl:function name="local:getValue" as="xs:integer">
        <xsl:param name="note" as="node()"/>
        
        <xsl:variable name="types" select="tokenize($note/@type,' ')" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="'id' = $types">
                <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="'os' = $types">
                <xsl:value-of select="2"/>
            </xsl:when>
            <xsl:when test="'sd' = $types">
                <xsl:value-of select="3"/>
            </xsl:when>
            <xsl:when test="'od' = $types">
                <xsl:value-of select="4"/>
            </xsl:when>
            <xsl:when test="'ts' = $types">
                <xsl:value-of select="5"/>
            </xsl:when>
            <xsl:when test="'noMatch' = $types">
                <xsl:value-of select="6"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="-1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>