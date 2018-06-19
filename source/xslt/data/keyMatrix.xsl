<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="key.matrix" as="node()">
        <custom:keys>
            <custom:accid.mod s="1" f="-1" ss="2" x="2" ff="-2" xs="3" tb="-3" n="0" nf="-1" ns="1"/>
            <custom:major>
                <custom:base.steps c="1" d="2" e="3" f="4" g="5" a="6" b="7"/>
                <custom:key base="c" c="0" d="0" e="0" f="0" g="0" a="0" b="0" step.offset="0"/>
                <custom:key base="d" c="1" d="0" e="0" f="1" g="0" a="0" b="0" step.offset="-1"/>
                <custom:key base="e" c="1" d="1" e="0" f="1" g="1" a="0" b="0" step.offset="-2"/>
                <custom:key base="f" c="0" d="0" e="0" f="0" g="0" a="0" b="-1" step.offset="-3"/>
                <custom:key base="g" c="0" d="0" e="0" f="1" g="0" a="0" b="0" step.offset="-4"/>
                <custom:key base="a" c="1" d="0" e="0" f="1" g="1" a="0" b="0" step.offset="-5"/>
                <custom:key base="b" c="1" d="1" e="0" f="1" g="1" a="1" b="0" step.offset="-6"/>
            </custom:major>
            <custom:minor>
                <custom:base.steps c="3" d="4" e="5" f="6" g="7" a="1" b="2"/>
                <custom:key base="c" c="0" d="0" e="-1" f="0" g="0" a="-1" b="-1" step.offset="-2"/>
                <custom:key base="d" c="0" d="0" e="0" f="0" g="0" a="0" b="-1" step.offset="-3"/>
                <custom:key base="e" c="0" d="0" e="0" f="1" g="0" a="0" b="0" step.offset="-4"/>
                <custom:key base="f" c="0" d="-1" e="-1" f="0" g="0" a="-1" b="-1" step.offset="-5"/>
                <custom:key base="g" c="0" d="0" e="-1" f="0" g="0" a="0" b="-1" step.offset="-6"/>
                <custom:key base="a" c="0" d="0" e="0" f="0" g="0" a="0" b="0" step.offset="0"/>
                <custom:key base="b" c="1" d="0" e="0" f="1" g="0" a="0" b="0" step.offset="-1"/>
            </custom:minor>
        </custom:keys>
    </xsl:variable>
</xsl:stylesheet>