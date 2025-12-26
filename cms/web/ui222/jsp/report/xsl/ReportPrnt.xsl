<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- <xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl"> -->

<xsl:template match="/">
<html>

<head>
	<META HTTP-EQUIV="Expires" CONTENT="0"/>
	<META HTTP-EQUIV="Caching" CONTENT=""/>
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
	<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache"/>
	<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8"/>
<title>Report</title>
<base target="_new" /> 
</head>

<body>

<xsl:choose>
	<xsl:when test = "CampaignList/OnlyOne">
<!-- Block for one campaign-->

<br />
<xsl:if test="1 = /CampaignList/TotalsSecFlag">
<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
  <td colspan="2"><b><xsl:value-of select="CampaignList/Campaigns/Row/Name"/></b></td>
</tr>
<tr>
  <td>Send Date</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/StartDate"/></td>
</tr>
<tr>
  <td>Total Sent</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/Size"/></td>
</tr>
<tr>			
  <td>Total Bounceback</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/></td>
</tr>
<tr>
  <td>Total Click Throughs</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/></td>
</tr>
<tr>
  <td>Total Unsubscribes</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/></td>
</tr>
</table>

</xsl:if>


<xsl:if test="1 = /CampaignList/ReportCache">
<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
<td colspan="2"><b>Report Parameters</b></td>
</tr>
<tr>
	<td>Start Date</td>
	<td><nobr><xsl:value-of select="/CampaignList/Campaigns/Row/Cache/StartDate"/>&#160;</nobr></td>
</tr>
<tr>
	<td>End Date</td>
	<td><nobr><xsl:value-of select="/CampaignList/Campaigns/Row/Cache/EndDate"/>&#160;</nobr></td>
</tr>
<tr>
	<td>Attribute</td>
	<td><xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrName"/>&#160;</td>
</tr>
<tr>
	<td>Value</td>
	<td><xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrValue"/>&#160;</td>
</tr>
</table>
<br />

</xsl:if>

<!-- First Report Grid -->

<xsl:if test="1 = /CampaignList/GeneralSecFlag">
<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
  <td colspan="2"><b>General Campaign Statistics</b></td>
</tr>
<tr>
  <td>Total Sent</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/Size"/></td>
</tr>
<tr>
  <td>Total Bounceback</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/></td>
</tr>
<tr>
  <td>Total Reaching</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/></td>
</tr>
</table>
</xsl:if>

<!-- Bounce Back Categories -->

<xsl:if test="1 = /CampaignList/BBackSecFlag">
<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
  <td colspan="2"><b>Bounceback Categories</b></td>
</tr>
<tr>
  <td>Total Bounceback</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/></td>
</tr>

<xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
	<tr>
	  <td><xsl:value-of select="CategoryName"/></td>
	  <td><xsl:value-of select="BBacks"/></td>
	</tr> 
</xsl:for-each>

</table>
</xsl:if>

<!--Recipient Actions -->

<xsl:if test="1 = /CampaignList/ActionSecFlag">
<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
  <td colspan="2"><b>Recipient Actions</b></td>
</tr>
<tr>
  <td>Total Reaching</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/></td>
</tr>
<tr>
  <td>Total Open HTML</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/></td>
</tr>
<tr>
  <td>Total Click Throughs</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/></td>
</tr>
<tr>
  	<td>Total Unsubscribes</td>
  	<td><xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/></td>
</tr>
</table>
</xsl:if>

<!-- Detailed Clicks-->

<xsl:if test="1 = /CampaignList/DistClickSecFlag">
<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
  <td colspan="5"><b>Detailed Clickthroughs</b></td>
</tr>
<tr>
  <td>Total Clicks</td>
  <td colspan="4"><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/></td>
</tr>
	<tr>
	  <td>Link Name</td>
	  <td>Total Clicks</td>
	  <td>Text</td>
	  <td>HTML</td>
	  <!--<td>AOL</td>//-->
	</tr>
<xsl:for-each select="CampaignList/Campaigns/Row/Links">
	<tr>
	  <td><xsl:value-of select="LinkName"/></td>
	  <td><xsl:value-of select="DistinctClicks"/></td>
	  <td><xsl:value-of select="DistinctText"/></td>
	  <td><xsl:value-of select="DistinctHTML"/></td>
	  <!--<td><xsl:value-of select="DistinctAOL"/></td>//-->
	</tr>
</xsl:for-each>
</table>
</xsl:if>

<!-- Detailed Clicks-->

<xsl:if test="1 = /CampaignList/TotClickSecFlag">
<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
  <td colspan="5"><b>Detailed Clickthroughs</b></td>
</tr>
<tr>
  <td>Total Clicks</td>
  <td colspan="4"><xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/></td>
</tr>
	<tr>
	  <td>Link Name</td>
	  <td>Total Clicks</td>
	  <td>Text</td>
	  <td>HTML</td>
	  <!--<td>AOL</td>//-->
	</tr>
<xsl:for-each select="CampaignList/Campaigns/Row/Links">
	<tr>
	  <td><xsl:value-of select="LinkName"/></td>
	  <td><xsl:value-of select="TotalClicks"/></td>
	  <td><xsl:value-of select="TotalText"/></td>
	  <td><xsl:value-of select="TotalHTML"/></td>
	  <!--<td><xsl:value-of select="TotalAOL"/></td>//-->
	</tr>
</xsl:for-each>
</table>
</xsl:if>

<!-- Form Submits -->

<xsl:if test="1 = /CampaignList/FormSecFlag">
<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
  <td colspan="5"><b>Form Submissions</b></td>
</tr>

	<tr>
	  <td>Form Name</td>
	  <td>Distinct Page Views</td>
	  <td>Distinct Submissions</td>
	  <td>Submitted Multiple Times</td>
	  <td>Submit Form Name</td>
	</tr> 
<xsl:for-each select="CampaignList/Campaigns/Row/Forms">
	<tr>
	  <td><xsl:value-of select="FirstFormName"/></td>
	  <td><xsl:value-of select="DistinctViews"/></td>
	  <td><xsl:value-of select="DistinctSubmits"/></td>
	  <td><xsl:value-of select="MultiSubmitters"/></td>
	  <td><xsl:value-of select="LastFormName"/></td>
	</tr> 
</xsl:for-each>
	<tr>
		<td>Form Name</td>
		<td>Total Page Views</td>
		<td>Total Submissions</td>
		<td>Submitted Multiple Times</td>
		<td>Submit Form Name</td>
	</tr> 
<xsl:for-each select="CampaignList/Campaigns/Row/Forms">
	<tr>
	  <td><xsl:value-of select="FirstFormName"/></td>
	  <td><xsl:value-of select="TotalViews"/></td>
	  <td><xsl:value-of select="TotalSubmits"/></td>
	  <td><xsl:value-of select="MultiSubmitters"/></td>
	  <td><xsl:value-of select="LastFormName"/></td>
	</tr> 
</xsl:for-each>
  
</table>
</xsl:if>
<!-- Additional Metrics -->

<br />
<table border="1" cellpadding="3" cellspacing="0">
<tr>
  <td colspan="2"><b>Additional Metrics</b></td>
</tr>
<xsl:if test="1 = /CampaignList/TotReadFlag">
<tr>
  <td>Total HTML Email views</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/TotalReads"/></td>
</tr>
</xsl:if>
<xsl:if test="1 = /CampaignList/MultiReadFlag">
<tr>
  <td>Opened HTML Email more than once</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/MultiReaders"/></td>
</tr>
</xsl:if>
<xsl:if test="1 = /CampaignList/TotClickFlag">
<tr>
  <td>Aggregate Clickthroughs</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/></td>
</tr>
</xsl:if>
<xsl:if test="1 = /CampaignList/MultiLinkClickFlag">
<tr>
  <td>Clicked on more than one link</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/MultiLinkClickers"/></td>
</tr>
</xsl:if>
<xsl:if test="1 = /CampaignList/LinkMultiClickFlag">
<tr>
  <td>Clicked on one link multiple times</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/OneLinkMultiClickers"/></td>
</tr>
</xsl:if>
</table>

	</xsl:when> <!-- End Block for one campaign -->
	<xsl:otherwise>
<br /><br />
<table>
<tr>
  <td>Only available for single campaign</td> 
</tr>
</table>
	</xsl:otherwise>
</xsl:choose>

<br /><br />

</body>

</html>

</xsl:template>
</xsl:stylesheet>
