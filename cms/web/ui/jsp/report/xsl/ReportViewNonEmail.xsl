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
<link rel="stylesheet" href="/cms/ui/css/style.css" TYPE="text/css"/>
<script language="javascript" src="/cms/ui/js/tab_script.js" type="text/javascript"></script>
<script language="javascript">
	
	function pop_up_win(url)
	{
		windowName = 'report_results_window';
		windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=700';
		ReportWin = window.open(url, windowName, windowFeatures);
	}
	
</script>
</head>

<body>

<!-- Block for one campaign-->
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td nowrap="true" valign="middle" align="left">
			<xsl:element name="a">
				<xsl:attribute name="class">resourcebutton</xsl:attribute>
				<xsl:attribute name="href">report_object.jsp?act=PRNT&#38;id=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/></xsl:attribute>
				Export to Excel
			</xsl:element>
		</td>
		<td vAlign="middle" align="right" nowrap="true">
			<xsl:element name="a">
				<xsl:attribute name="class">subactionbutton</xsl:attribute>
				<xsl:attribute name="border">0</xsl:attribute>
				<xsl:attribute name="target">_self</xsl:attribute>
				<xsl:attribute name="href">nonemail_new.jsp?id=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
				Import Responses
			</xsl:element>&#160;&#160;&#160;
		</td>
	</tr>
</table>
<br />

<table width="95%" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&#160;<b class="sectionheader">Report:</b>&#160;&#160;<xsl:value-of select="CampaignList/Campaigns/Row/Name"/></td>
	</tr>
</table>
<br/>
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="EditTabOn" width="200" valign="center" nowrap="true" align="middle">Campaign Results</td>
	<xsl:if test="0 &lt; /CampaignList/ReportPosFlag">
		<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle">
			<xsl:attribute name="onclick">location.href = 'report_track.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>';</xsl:attribute>
			RevoTrack Results</td>
	</xsl:if>
		<td class="EmptyTab" valign="center" nowrap="true" align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1" /></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%" colspan="5">
		<xsl:if test="1 = /CampaignList/TotalsSecFlag">
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="10">Overview</th>
				</tr>
				<tr>
					<td align="center">Send Date :</td>
					<td> <xsl:value-of select="CampaignList/Campaigns/Row/StartDate"/></td>

					<td align="center">Total Sent :</td>
					<td>
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Size"/>
						</xsl:element>
					</td>

					<td align="center">Total Responses :</td>
					<td align="center">
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
						</xsl:element>
						(<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%)
					</td>
				</tr>
			</table>
			<br />
		</xsl:if>

<!--Recipient Actions -->

		<xsl:if test="1 = /CampaignList/ActionSecFlag">
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="3">&#160;Recipient Actions</th>
				</tr>
				<tr>
					<td width="150" align="right" class="listItem_Data" nowrap="true">Total Sent :</td>
					<td class="listItem_Data" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
						</xsl:element> 
					</td>
					<td class="listItem_Data" width="100%">
						<xsl:element name="table">
							<xsl:attribute name="width">100%</xsl:attribute>
							<xsl:attribute name="border">0</xsl:attribute>
							<xsl:attribute name="cellpadding">0</xsl:attribute>
							<xsl:attribute name="cellspacing">0</xsl:attribute>
							<tr> 
								<td valign="middle" width="10%" align="left">Percent</td> 
								<td valign="middle" width="10%" align="right">2</td> 
								<td valign="middle" width="10%" align="left">0%</td> 
								<td valign="middle" width="10%" align="right">4</td> 
								<td valign="middle" width="10%" align="left">0%</td>
								<td valign="middle" width="10%" align="right">6</td> 
								<td valign="middle" width="10%" align="left">0%</td> 
								<td valign="middle" width="10%" align="right">8</td> 
								<td valign="middle" width="10%" align="left">0%</td>
								<td valign="middle" width="10%" align="right"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>  
						</xsl:element>
					</td>
				</tr>
				<tr>
					<td width="150" align="right" class="listItem_Data_Alt" nowrap="true">Total Responses :</td>
					<td class="listItem_Data_Alt" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/> 
						</xsl:element> 
						(<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%)
					</td>
					<td class="listItem_Data_Alt" width="100%">
						<xsl:element name="table">
							<xsl:attribute name="width"><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%</xsl:attribute>
							<xsl:attribute name="border">0</xsl:attribute>
							<xsl:attribute name="cellpadding">0</xsl:attribute>
							<xsl:attribute name="cellspacing">0</xsl:attribute>
							<tr> 
								<td valign="middle" class="html" align="center"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td> 
							</tr> 
						</xsl:element>
					</td>
				</tr>
			</table>
			<br />
		</xsl:if>

<!-- Form Submits -->

		<xsl:if test="1 = /CampaignList/FormSecFlag">
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="5">&#160;Form Submissions</th>
				</tr>
				<tr>
					<td align="right" class="listItem_Data" nowrap="true">Form Name</td>
					<td class="listItem_Data" nowrap="true">Distinct Page Views</td>
					<td class="listItem_Data" nowrap="true">Distinct Submissions</td>
					<td class="listItem_Data" nowrap="true">Submitted Multiple Times</td>
					<td align="left" class="listItem_Data" nowrap="true">Submit Form Name</td>
				</tr> 
			<xsl:for-each select="CampaignList/Campaigns/Row/Forms">
				<tr>
					<td align="right" class="listItem_Data" nowrap="true"><xsl:value-of select="FirstFormName"/></td>
					<td class="listItem_Data" nowrap="true">
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=view&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="FirstFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="DistinctViews"/>
						</xsl:element>
					</td>
					<td class="listItem_Data" nowrap="true">
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=submit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="DistinctSubmits"/>
						</xsl:element>
						(<xsl:value-of select="DistinctViewSubmitPrc"/>%)
					</td>
					<td class="listItem_Data" nowrap="true">
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multisubmit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="MultiSubmitters"/>
						</xsl:element>
					</td>
					<td align="left" class="listItem_Data" nowrap="true"><xsl:value-of select="LastFormName"/></td>
				</tr> 
			</xsl:for-each>
				<tr>
					<td align="right" class="listItem_Data" nowrap="true">Form Name</td>
					<td class="listItem_Data" nowrap="true">Total Page Views</td>
					<td class="listItem_Data" nowrap="true">Total Submissions</td>
					<td class="listItem_Data" nowrap="true">Submitted Multiple Times</td>
					<td align="left" class="listItem_Data" nowrap="true">Submit Form Name</td>
				</tr> 
			<xsl:for-each select="CampaignList/Campaigns/Row/Forms">
				<tr>
					<td align="right" class="listItem_Data" nowrap="true"><xsl:value-of select="FirstFormName"/></td>
					<td class="listItem_Data" nowrap="true">
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=view&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="FirstFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="TotalViews"/>
						</xsl:element>
					</td>
					<td class="listItem_Data" nowrap="true">
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=submit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="TotalSubmits"/>
						</xsl:element>
						(<xsl:value-of select="TotalViewSubmitPrc"/>%)
					</td>
					<td class="listItem_Data" nowrap="true">
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multisubmit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>');</xsl:attribute>
							<xsl:value-of select="MultiSubmitters"/>
						</xsl:element>
					</td>
					<td align="left" class="listItem_Data" nowrap="true"><xsl:value-of select="LastFormName"/></td>
				</tr> 
			</xsl:for-each>
			</table>
			<br />
		</xsl:if>
		</td>
	</tr>
	</tbody>
</table>
<br /><br />
</body>

</html>

</xsl:template>
</xsl:stylesheet>
