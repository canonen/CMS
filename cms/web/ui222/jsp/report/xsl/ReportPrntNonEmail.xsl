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
  <td>Total Responses</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/></td>
</tr>
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
  <td>Total Sent</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/></td>
</tr>
<tr>
  <td>Total Responses</td>
  <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/></td>
</tr>
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

<br /><br />

</body>

</html>

</xsl:template>
</xsl:stylesheet>
