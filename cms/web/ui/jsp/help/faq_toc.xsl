<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:crm="http://mscrm" version="1.0" exclude-result-prefixes="msxsl crm">
<xsl:output method="html" indent="no" encoding="UTF-8"/>
<xsl:param name="autoLoadTopic"/>

<xsl:template match="books/volume">

	<xsl:apply-templates select="chapter"/>

</xsl:template>


<xsl:template match="chapter">

	<xsl:if test="not(@hidden)">
		<table>
		<col width="20"/><col/>
			<tr style="cursor:hand;" level="1">
				<xsl:attribute name="code"><xsl:value-of select="../@code"/></xsl:attribute>
				<xsl:attribute name="onclick">toggle(this, '<xsl:value-of select="@faq_id"/>');</xsl:attribute>
				<td>
					<img>
						<xsl:attribute name="src">
							<xsl:choose>
								<xsl:when test="not(page[@topic=$autoLoadTopic])">imgs/16_closedBook.gif</xsl:when>
								<xsl:otherwise>imgs/16_openBook.gif</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</img>
				</td>
				<td><xsl:value-of select="@name"/></td>
			</tr>
			<tr>
				<xsl:attribute name="style">
					<xsl:choose>
						<xsl:when test="not(page[@topic=$autoLoadTopic])">display:none</xsl:when>
						<xsl:otherwise>display:inline</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<td><br/></td>
				<td>
					<xsl:if test="page[@topic=$autoLoadTopic]">
						<xsl:apply-templates select="page"/>
					</xsl:if>
				</td>
			</tr>
		</table>
		
		
	</xsl:if>
</xsl:template>


<xsl:template match="page">

	<table>
	<col width="20"/><col/>
		<tr level="2">
			<td><img src="imgs/16_helpDoc.gif"/></td>
			<td><a target="helpContents"><xsl:attribute name="href">faq_display.jsp?faq_id=<xsl:value-of select="@faq_id"/></xsl:attribute><xsl:value-of select="."/></a></td>
		</tr>
	</table>

</xsl:template>

</xsl:stylesheet>