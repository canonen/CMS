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
<META HTTP-EQUIV="Content-Type" CONTENT="application/vnd.ms-excel; charset=utf-8"/>
<title>Report</title>
<script language="javascript" src="/ccps/ui/js/tab_script.js" type="text/javascript"></script>
</head>

<body>
<xsl:choose>
	<xsl:when test = "CampaignList/OnlyOne">
	<br />
<!-- Block for one campaign-->
<br /><br />
<b>Campaign Info</b><br /><br />

<xsl:if test="1 = /CampaignList/TotalsSecFlag">
	<table border="0"  width="95%" cellpadding="0" cellspacing="0">
		<tbody class="EditBlock" id="block1_Step1">
		<tr>
	          <th width="30%">Campaign Name</th>
	          <th width="20%">Date</th>
	          <th width="10%">Total Sent</th>
	          <th width="10%" colspan="2">Bounce Backs</th>
	          <th width="10%" colspan="2">Total Opened Email (HTML)</th>
	          <th width="10%" colspan="2">Click Throughs</th>
	          <th width="10%" colspan="2">Unsubscribes</th>
	    </tr>
    
		<tr>
			<td><xsl:value-of select="CampaignList/Campaigns/Row/Name"/></td>
			<td> <xsl:value-of select="CampaignList/Campaigns/Row/StartDate"/></td>
	
			<td><xsl:value-of select="CampaignList/Campaigns/Row/Size"/></td>
	
			<td><xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/></td>
			<td><xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%</td>
						
			<td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/></td>
			<td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%</td>
						
			<td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/></td>
			<td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%</td>
	
			<td><xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/></td>
			<td><xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%</td>
		</tr>
		</tbody>	
	</table>		
</xsl:if>

</xsl:when>

<xsl:otherwise>

	
<xsl:if test="1 = /CampaignList/TotalsSecFlag">
<br /><br />
<b>Campaign Info</b><br /><br />			
<!-- Block for many campaigns-->
      <table class="main" width="100%" cellpadding="1" cellspacing="1">
<!-- Header -->
        <tr>
          <th width="30%">Campaign Name</th>
          <th width="20%">Date</th>
          <th width="10%">Total Sent</th>
          <th width="10%" colspan="2">Bounce Backs</th>
          <th width="10%" colspan="2">Total Opened Email (HTML)</th>
          <th width="10%" colspan="2">Click Throughs</th>
          <th width="10%" colspan="2">Unsubscribes</th>
        </tr>
<!-- Data -->
  <xsl:for-each select="CampaignList/Campaigns/Row">
        <tr>
		  <td><xsl:value-of select="Name"/></td>
          <td><xsl:value-of select="StartDate"/></td>
          
          <td><xsl:value-of select="Size"/></td>
          
          <td><xsl:value-of select="BBacks"/></td>
          <td><xsl:value-of select="BBackPrc"/>%</td>
          
          <td><xsl:value-of select="DistinctReads"/></td>
          <td><xsl:value-of select="DistinctReadPrc"/>%</td>
          
          <td><xsl:value-of select="DistinctClicks"/></td>
          <td><xsl:value-of select="DistinctClickPrc"/>%</td>
          
          <td><xsl:value-of select="Unsubs"/></td>
          <td><xsl:value-of select="UnsubPrc"/>%</td>
        </tr>
  </xsl:for-each>
      </table>
</xsl:if>
	</xsl:otherwise>
</xsl:choose>

<br /><br />
</body>

</html>

</xsl:template>
</xsl:stylesheet>
