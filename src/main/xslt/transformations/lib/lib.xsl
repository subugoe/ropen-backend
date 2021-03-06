<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ex="http://exslt.org/dates-and-times"
                xmlns:str="http://www.exslt.org/strings"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:url="http://whatever/java/java.net.URLEncoder"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:exsl="http://exslt.org/common"
                version="1.0">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Oct 7, 2011</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> cmahnke</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
    <!-- 
        See ehttp://www.jonmiles.co.uk/2009/02/url-encoding-with-xslt/
    -->
    <!-- 
    This is needed to use the exsl:node-set function in IE, see:
    http://dpcarlisle.blogspot.com/2007/05/exslt-node-set-function.html
    --><msxsl:script language="JScript" implements-prefix="exsl"> this['node-set'] = function (x) {
        return x; } </msxsl:script>
   <msxsl:script language="JScript" implements-prefix="ex">
        function today()
        {
        return new Date(); 
        } 
    </msxsl:script>
   <xsl:template name="date">
      <xsl:param name="str"/>
      <xsl:choose>
            <!-- MS XML --><xsl:when test="function-available(ex:today)">
            <xsl:value-of select="ex:today"/>
         </xsl:when>
            <!-- EXSL --><xsl:when test="function-available(ex:date-time)">
            <xsl:value-of select="ex:date-time()"/>
         </xsl:when>
            <!-- XSLT 2.0 --><xsl:when test="function-available(current-dateTime)">
            <xsl:value-of select="current-dateTime()"/>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="CDATA">
      <xsl:param name="node"/>
      <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
      <xsl:copy-of select="$node"/>
      <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
   </xsl:template>
   <xsl:template name="removeLeadingChar">
      <xsl:param name="str"/>
      <xsl:param name="char"/>
      <xsl:variable name="cutStr">
         <xsl:choose>
            <xsl:when test="starts-with($str, $char)">
               <xsl:value-of select="substring($str, string-length($char) + 1, string-length($str) - string-length($char))"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$str"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="starts-with($str, $char)">
            <xsl:call-template name="removeLeadingChar">
               <xsl:with-param name="str" select="$cutStr"/>
               <xsl:with-param name="char" select="$char"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$cutStr"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

    <!-- A simple tokenizer, use the exsl:node-set function from the following namespace
        xmlns:exsl="http://exslt.org/common" to seperate the tokens if you're using XSLT 1.0 
        otherwise use XSLT 1.1 draft or XSLT 2.0.
    --><xsl:template name="tokenize">
      <xsl:param name="str"/>
      <xsl:param name="char"/>
      <xsl:choose>
         <xsl:when test="contains($str, $char)">
            <xsl:variable name="firstToken">
               <xsl:value-of select="substring-before($str, $char)"/>
            </xsl:variable>
            <xsl:variable name="remainder"/>
            <token>
               <xsl:value-of select="$firstToken"/>
            </token>
            <xsl:if test="string-length($remainder) &gt; 0">
               <xsl:call-template name="tokenize">
                  <xsl:with-param name="str" select="$remainder"/>
                  <xsl:with-param name="char" select="$char"/>
               </xsl:call-template>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$str"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="log">
      <xsl:param name="message"/>
      <xsl:param name="level" select="'WARN'"/>
      <xsl:param name="logFacility" select="'MESSAGE'"/>
      <xsl:param name="fatal" select="true()"/>
      <xsl:variable name="terminate">
         <xsl:choose>
            <xsl:when test="string($fatal) = string(true())">
               <xsl:value-of select="'yes'"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="'no'"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="outputMessage">
         <xsl:value-of select="$level"/>
         <xsl:text>: </xsl:text>
         <xsl:value-of select="$message"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$logFacility = 'MESSAGE'">
            <xsl:message terminate="{$terminate}">
               <xsl:value-of select="$outputMessage"/>
            </xsl:message>
         </xsl:when>
         <xsl:when test="$logFacility = 'RETURN'">
            <xsl:value-of select="$outputMessage"/>
         </xsl:when>
         <xsl:when test="$logFacility = 'RESULTTREE'">
            <xsl:value-of select="$outputMessage"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">No logging facility configured!</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
