<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ropen="http://ropen.sub.uni-goettingen.de/ropen-backend/xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 9, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> cmahnke</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:function name="ropen:concat-path" as="xs:anyURI">
        <xsl:param name="path" as="xs:string"/>
        <xsl:param name="filename" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="ends-with($path, '/') or starts-with($filename, '/')">
                <xsl:value-of select="concat($path, $filename)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($path, '/', $filename)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="ropen:normalize-space" as="xs:string">
        <xsl:param name="text" as="text()*"/>
        <xsl:choose>
            <xsl:when test="count($text) &gt; 1">
                <xsl:variable name="seq">
                    <!--
                    <xsl:choose>
                        <xsl:when test="ropen:count-non-whitespace($text) = 1">
                            <xsl:copy-of select="$text"></xsl:copy-of>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ropen:add-whitespace($text)"></xsl:copy-of>
                        </xsl:otherwise>
                    </xsl:choose>
                    -->
                    <xsl:copy-of select="ropen:add-whitespace($text)"/>
                </xsl:variable>


                <xsl:value-of select="ropen:trim(replace(replace(string-join($seq, ''), '-\s*\n\s*', ''), '\s+', ' '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="tokens" select="tokenize($text, '-\s*\n')"/>
                <xsl:value-of select="ropen:trim(replace(string-join($tokens, ' '), '\s+', ' '))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="ropen:count-non-whitespace" as="xs:integer">
        <xsl:param name="text" as="text()*"/>
        <xsl:value-of select="count($text[not(matches(., '\s*'))])"/>
    </xsl:function>

    <!-- 
        This is used to add white space to text nodes, which are tagged alone
    -->
    <xsl:function name="ropen:add-whitespace" as="text()*">
        <xsl:param name="text" as="text()*"/>
        <xsl:for-each select="$text">
            <xsl:choose>
                <xsl:when test="not(matches(., '\s'))">
                    <xsl:value-of select="concat(' ', ., ' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="ropen:ltrim" as="xs:string">
        <xsl:param name="str" as="xs:string"/>
        <xsl:value-of select="replace($str, '^\s+', '')"/>
    </xsl:function>
    <xsl:function name="ropen:rtrim" as="xs:string">
        <xsl:param name="str" as="xs:string"/>
        <xsl:value-of select="replace($str, '\s+$', '')"/>
    </xsl:function>
    <xsl:function name="ropen:trim" as="xs:string">
        <xsl:param name="str" as="xs:string"/>
        <xsl:value-of select="ropen:ltrim(ropen:rtrim($str))"/>
    </xsl:function>

    <!-- Get file name of a node -->
    <xsl:function name="ropen:document-name" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            <xsl:when test="document-uri(root($node)) != ''">
                <xsl:value-of select="ropen:uri-to-name(document-uri(root($node)))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Get the name of a file from an URI -->
    <xsl:function name="ropen:uri-to-name" as="xs:string">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:variable name="file-name" select="replace($uri, '^.*/(.*)$', '$1')" as="xs:string"/>
        <xsl:value-of select="replace($file-name, '^(.*?)\.[^.]*$', '$1')"/>
    </xsl:function>
    <!-- Generate XPath for a given node -->
    <xsl:function name="ropen:generate-xpath">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="numbers" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="$numbers">
                <xsl:for-each select="$node/ancestor::*">
                    <xsl:value-of select="name()"/>
                    <xsl:variable name="parent" select="."/>
                    <xsl:variable name="siblings" select="count(preceding-sibling::*[name()=name($parent)])"/>
                    <xsl:if test="$siblings">
                        <xsl:value-of select="concat('[', $siblings + 1, ']')"/>
                    </xsl:if>
                    <xsl:value-of select="'/'"/>
                </xsl:for-each>
                <xsl:value-of select="name($node)"/>
                <xsl:variable name="siblings" select="count($node/preceding-sibling::*[name()=name($node)])"/>
                <xsl:if test="$siblings">
                    <xsl:value-of select="concat('[', $siblings + 1, ']')"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$node/ancestor::*/name()" separator="/"/>
                <xsl:value-of select="concat('/', name($node))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Checks id an file exists -->
    <xsl:function name="ropen:file-exists" as="xs:boolean">
        <xsl:param name="location" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="document($location)">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- extracts a relative path from a absolute path -->
    <xsl:function name="ropen:absolute-to-relative-path" as="xs:string">
        <xsl:param name="path" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains($path, './')">
                <xsl:value-of select="replace($path, '^.*/(\./.*)$', '$1')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
