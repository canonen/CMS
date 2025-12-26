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
<title>Report List</title>
	<xsl:element name="link">
		<xsl:attribute name="rel">stylesheet</xsl:attribute>
		<xsl:attribute name="href"><xsl:value-of select="CampaignList/StyleSheet"/></xsl:attribute>
		<xsl:attribute name="type">text/css</xsl:attribute>
	</xsl:element>
</head>

<script language="javascript">
<xsl:comment>
<![CDATA[
function ShowHide(val){
	if (val[0].style.display == 'none') val[0].style.display = '';
	else val[0].style.display='none';
	if (val[1].style.display == 'none') val[1].style.display = '';
	else val[1].style.display='none';
}

function PreviewURL(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,location=no,status=yes,height=500,width=650';
	SmallWin = window.open(freshurl,'ReportWin',window_features);
}
]]>
</xsl:comment>
</script>

<body>
<form name="ReportView" method="post">
<xsl:choose>
	<xsl:when test = "CampaignList/OnlyOne">
		
		<!-- Block for one campaign-->
		<table class="main" cellspacing="1" cellpadding="1">
			<tr>
				<td class="sectionheader">&#160; <b class="sectionheader"><xsl:value-of select="CampaignList/Campaigns/Row/Name"/></b>  &#160;</td>
				<td class="sectionheader">&#160; <b class="sectionheader">Start Date</b>  &#160;</td>
				<td class="sectionheader">&#160; <b class="sectionheader">Size</b>  &#160;</td>
				<td class="sectionheader">&#160; <b class="sectionheader">Bounce Backs</b>  &#160;</td>
				<td class="sectionheader">&#160; <b class="sectionheader">Click Throughs</b>  &#160;</td>
				<td class="sectionheader">&#160; <b class="sectionheader">Unsubscribes</b>  &#160;</td>
			</tr>
			<xsl:for-each select="CampaignList/Campaigns/Row/SubCampaigns">
				<tr>
					<td  class="reportheader">&#160;
						<xsl:element name="a">
							<xsl:attribute name="class">reportheader</xsl:attribute>
							<xsl:attribute name="href">javascript:PreviewURL('<xsl:value-of select="/CampaignList/SubCampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="CampID"/>');</xsl:attribute>
							<xsl:value-of select="CampName"/>
						</xsl:element>  
					</td>
                    <td class="reportheader">&#160;<xsl:value-of select="StartDate"/>&#160;</td>
                    <td align="right" class="reportheader">&#160;<xsl:value-of select="Size"/>&#160;</td>
                    <td align="center" class="reportheader">&#160;<xsl:value-of select="BBacks"/>&#160;(<xsl:value-of select="BBackPrc"/>%)&#160;</td>
                    <td align="center" class="reportheader">&#160;<xsl:value-of select="Clicks"/>&#160;(<xsl:value-of select="ClickPrc"/>%)&#160;</td>
                    <td align="center" class="reportheader">&#160;<xsl:value-of select="Unsubs"/>&#160;(<xsl:value-of select="UnsubPrc"/>%)&#160;</td>
				</tr>
			</xsl:for-each>
		</table>
		<table width="755" class="main" cellspacing="0" cellpadding="0">
			<tr>
				<td align="left">&#160;</td>
			</tr>
		</table>
		<br />
		<table width="755" class="main" cellspacing="1" cellpadding="1">
			<tr>
				<td colspan="8" width="755" class="sectionheader">&#160; <b class="reportheader"> Overview</b></td>
			</tr>
			<tr>
				<td align="center">Total Sent :</td>
				<td width="75" class="reportheader">
					<xsl:value-of select="CampaignList/Campaigns/Row/Size"/>
				</td>
				<td  align="center">Total Bounceback :</td>
				<td align="center" class="reportheader">
					<xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
					(<xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%)
				</td>
				<td width="75" align="center">Total Click Throughs :</td>
				<td align="center" class="reportheader">
					<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
					(<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%)
				</td>
				<td  align="center">Total Unsubscribes :</td>
				<td align="center" class="reportheader">
					<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
					(<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%)
				</td>
			</tr>
		</table>

<!-- First Report Grid -->

		<br />
		<table class="main" cellspacing="1" cellpadding="1">
			<tr>
				<td colspan="3" class="sectionheader">&#160;<b class="reportheader">General Campaign Statistics</b></td>
			</tr>
			<tr>
				<td width="125" align="right">Total Sent :</td>
				<td width="175" class="reportheader">&#160;
					<xsl:value-of select="CampaignList/Campaigns/Row/Size"/>
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width">100%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">1</xsl:attribute>
						<tr> 
							<td valign="middle" class="reportmarkers" width="10%" align="left">Percent</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">2</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">4</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td>
							<td class="reportmarkers" valign="middle" width="10%" align="right">6</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">8</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td>
							<td class="reportmarkers" valign="middle" width="10%" align="right"><img height="15" width="1" src="/cms/ui/images/blank.gif" /></td>
						</tr>  
					</xsl:element>
				</td>
			</tr>
			<tr>
				<td  align="right">Total Bounceback :</td>
				<td class="reportheader">&#160;
					<xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
					(<xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%)
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width"><xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">0</xsl:attribute>
						<tr> 
							<td valign="middle" class="html" align="center"><img height="15" width="1" src="/cms/ui/images/blank.gif" /></td> 
						</tr> 
					</xsl:element>
				</td>
			</tr>
			<tr>
				<td align="right">Total Reaching :</td>
				<td class="reportheader">&#160;
					<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width"><xsl:value-of select="CampaignList/Campaigns/Row/ReachingPrc"/>%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">0</xsl:attribute>
						<tr> 
							<td valign="middle" class="html" align="center"><img height="15" width="1" src="/cms/ui/images/blank.gif" /></td> 
						</tr> 
					</xsl:element>
				</td>
			</tr>
		</table>
		<br />

	<!--Recipient Actions -->

		<br />
		<table class="main" cellspacing="1" cellpadding="1">
			<tr>
				<td colspan="3" class="sectionheader">&#160;<b class="reportheader">Recipient Actions</b></td>
			</tr>
			<tr>
				<td width="125" align="right">Total Reaching :</td>
				<td width="175" class="reportheader">&#160;
					<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width">100%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">1</xsl:attribute>
						<tr> 
							<td valign="middle" class="reportmarkers" width="10%" align="left">Percent</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">2</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">4</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td>
							<td class="reportmarkers" valign="middle" width="10%" align="right">6</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">8</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td>
							<td class="reportmarkers" valign="middle" width="10%" align="right"><img height="15" width="1" src="/cms/ui/images/blank.gif" /></td>
						</tr>  
					</xsl:element>
				</td>
			</tr>
			<tr>
				<td align="right">Total Open HTML :</td>
				<td class="reportheader">&#160;
					<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/> 
					(<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%)
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width"><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">0</xsl:attribute>
						<tr> 
							<td valign="middle" class="html" align="center"><img height="15" width="1" src="/cms/ui/images/blank.gif" /></td> 
						</tr> 
					</xsl:element>
				</td>
			</tr>
			<tr>
				<td align="right">Total Click Throughs :</td>
				<td class="reportheader">&#160;
					<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
					(<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%) 
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width"><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">0</xsl:attribute>
						<tr> 
							<td valign="middle" class="html" align="center"><img height="15" width="1" src="/cms/ui/images/blank.gif" /></td> 
						</tr> 
					</xsl:element>
				</td>
			</tr>
			<tr>
				<td align="right">Total Unsubscribes :</td>
				<td class="reportheader">&#160;
					<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
					(<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%)
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width"><xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">0</xsl:attribute>
						<tr> 
							<td valign="middle" class="html" align="center"><img height="15" width="1" src="/cms/ui/images/blank.gif" /></td> 
						</tr> 
					</xsl:element>
				</td>
			</tr>
		</table>
		<br />

	<!-- Detailed Clicks-->

		<br />
		<table class="main" cellspacing="1" cellpadding="1">
			<tr>
				<td colspan="3" class="sectionheader">&#160;<b class="reportheader">Detailed Clickthroughs</b></td>
			</tr>
			<tr>
				<td width="125" align="right">Total Clicks :</td>
				<td width="175" class="reportheader">&#160;
					<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width">100%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">1</xsl:attribute>
						<tr> 
							<td valign="middle" class="reportmarkers" width="10%" align="left">Percent</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">2</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">4</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td>
							<td class="reportmarkers" valign="middle" width="10%" align="right">6</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="right">8</td> 
							<td class="reportmarkers" valign="middle" width="10%" align="left">0%</td>
							<td class="reportmarkers" valign="middle" width="10%" align="right"><img height="15" width="1" src="/cms/ui/images/blank.gif" /></td>
						</tr>  
					</xsl:element>
				</td>
			</tr>
			
		<xsl:for-each select="CampaignList/Campaigns/Row/SuperLinks">
			<tr>
				<td  align="right"><xsl:value-of select="SuperLinkName"/>
					<xsl:if test="NonLinkCamps &gt; 0">
						*
					</xsl:if>
				</td>
				<td  class="reportheader">&#160;
					<xsl:value-of select="DistinctClicks"/>
					&#160;
					<xsl:value-of select="DistinctText"/> 
					T | 
					<xsl:value-of select="DistinctHTML"/> 
					H <!--|
					<xsl:value-of select="DistinctAOL"/> 
					A //-->&#160;
					(<xsl:value-of select="DistinctClickPrc"/>%)
				</td>
				<td width="450">
					<xsl:element name="table">
						<xsl:attribute name="width"><xsl:value-of select="DistinctClickPrc"/>%</xsl:attribute>
						<xsl:attribute name="border">0</xsl:attribute>
						<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
						<xsl:attribute name="cellpadding">0</xsl:attribute>
						<xsl:attribute name="cellspacing">0</xsl:attribute>
						
						<tr> 
						<xsl:element name="td">
							<xsl:attribute name="width"><xsl:value-of select="./DistinctTextPrc"/>%</xsl:attribute>
							<xsl:attribute name="valign">middle</xsl:attribute>
							<xsl:attribute name="align">center</xsl:attribute>
							<xsl:attribute name="class">text</xsl:attribute>
							<img height="15" width="1" src="/cms/ui/images/blank.gif" />
						</xsl:element>

						<xsl:element name="td">
							<xsl:attribute name="width"><xsl:value-of select="./DistinctHTMLPrc"/>%</xsl:attribute>
							<xsl:attribute name="valign">middle</xsl:attribute>
							<xsl:attribute name="align">center</xsl:attribute>
							<xsl:attribute name="class">html</xsl:attribute>
							<img height="15" width="1" src="/cms/ui/images/blank.gif" />
						</xsl:element>

						<!--<xsl:element name="td">
							<xsl:attribute name="width"><xsl:value-of select="./DistinctAOLPrc"/>%</xsl:attribute>
							<xsl:attribute name="valign">middle</xsl:attribute>
							<xsl:attribute name="align">center</xsl:attribute>
							<xsl:attribute name="class">aol</xsl:attribute>
							<img height="15" width="1" src="/cms/ui/images/blank.gif" />
						</xsl:element>//-->

						</tr> 
					</xsl:element>
				</td>
			</tr>
		</xsl:for-each>

			<tr>
				<td colspan="2">* Link does not participate in all Campaigns Sent</td>
				<td>
					<table cellspacing="0" cellpadding="3" border="0">
						<tr>
							<td align="left" valign="middle">Clickthrough Legend:</td>
							<td align="left" valign="middle">&#160;</td>
							<td class="text" align="left" valign="middle" style="border:1px solid #000000;"><img height="10" width="10" src="/cms/ui/images/blank.gif" /></td>
							<td align="left" valign="middle">Text Click</td>
							<td align="left" valign="middle">&#160;</td>
							<td class="html" align="left" valign="middle" style="border:1px solid #000000;"><img height="10" width="10" src="/cms/ui/images/blank.gif" /></td>
							<td align="left" valign="middle">HTML Click</td>
							<!--<td align="left" valign="middle">&#160;</td>
							<td class="aol" align="left" valign="middle" style="border:1px solid #000000;"><img height="10" width="10" src="/cms/ui/images/blank.gif" /></td>
							<td align="left" valign="middle">AOL Click</td>//-->
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<br />

		<br />
		<table width="700">
			<tr>
				<td>
					<table class="main" cellspacing="1" cellpadding="1">
						<tr>
							<td colspan="2" class="sectionheader">&#160;<b class="reportheader">Additional Metrics</b></td>
						</tr>
						<tr>
							<td width="125" align="right">Opened HTML Email more than once</td>
							<td width="175" class="reportheader">&#160; 
								<xsl:value-of select="CampaignList/Campaigns/Row/MultiReaders"/>
							</td>
						</tr>
						<tr>
							<td width="125" align="right">Aggregate Clickthroughs</td> <td class="reportheader">&#160;
								<xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/>
							</td>
						</tr>
						<tr>
							<td width="125"  align="right">Clicked on more than one link</td>
							<td class="reportheader">&#160;
								<xsl:value-of select="CampaignList/Campaigns/Row/MultiLinkClickers"/>
							</td>
						</tr>
						<tr>
							<td width="125"  align="right">Clicked on one link multiple times</td>
							<td class="reportheader">&#160;
								<xsl:value-of select="CampaignList/Campaigns/Row/OneLinkMultiClickers"/>
							</td>
						</tr>
					</table>
				</td>
				<td align="left" valign="center">&#160;</td>
			</tr>
		</table>
	</xsl:when>
	
	<xsl:otherwise>
		
		<br /><br />
		<b>General Campaign Info</b>
		<br /><br />			
		
		<!-- Block for many campaigns-->
		
		<table class="main" width="100%" cellpadding="1" cellspacing="1">
		<!-- Header -->
			<tr>
				<th width="30%">Campaign Name</th>
				<th width="20%">Date</th>
				<th width="10%">Total Sent</th>
				<th width="10%" colspan="2">Bounce Backs</th>
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
				<td><xsl:value-of select="DistinctClicks"/></td>
				<td><xsl:value-of select="DistinctClickPrc"/>%</td>
				<td><xsl:value-of select="Unsubs"/></td>
				<td><xsl:value-of select="UnsubPrc"/>%</td>
			</tr>
		</xsl:for-each>
		</table>
		
		<br /><br />
		<b>Sendout Statistics</b>
		<br /><br />
					
		<!-- Block for many campaigns-->
		
		<table class="main" width="100%" cellpadding="1" cellspacing="1">
		<!-- Header -->
			<tr>
				<th width="40%">Campaign Name</th>
				<th width="20%">Total Sent</th>
				<th width="20%" colspan="2">Total Bouncebacks</th>
				<th width="20%" colspan="2">Total Reaching</th>
			</tr>
		<!-- Data -->
		<xsl:for-each select="CampaignList/Campaigns/Row">
			<tr>
				<td>
					<xsl:element name="a">
					<xsl:attribute name="href">
					<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/></xsl:attribute>
					<xsl:value-of select="Name"/>
					</xsl:element>
				</td>
				<td><xsl:value-of select="Size"/></td>
				<td><xsl:value-of select="BBacks"/></td>
				<td><xsl:value-of select="BBackPrc"/>%</td>
				<td><xsl:value-of select="Reaching"/></td>
				<td><xsl:value-of select="ReachingPrc"/>%</td>
			</tr>
		</xsl:for-each>
		</table>
		
		<br /><br />
		<b>Activity Details</b>
		<br /><br />	
		
		<!-- Block for many campaigns-->
		
		<table class="main" width="100%" cellpadding="1" cellspacing="1">
		<!-- Header -->
			<tr>
				<th width="40%">Campaign Name</th>
				<th>Total Reaching</th>
				<th colspan="2">Total Unsubscribes</th>
				<th colspan="2">Total Opened Email (HTML)</th>
				<th colspan="2">Total Clickthroughs</th>
			</tr>
		<!-- Data -->
		<xsl:for-each select="CampaignList/Campaigns/Row">
			<tr>
				<td>
					<xsl:element name="a">
					<xsl:attribute name="href">
					<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/></xsl:attribute>
					<xsl:value-of select="Name"/>
					</xsl:element>
				</td>
				<td><xsl:value-of select="Reaching"/></td>
				<td><xsl:value-of select="Unsubs"/></td>
				<td><xsl:value-of select="UnsubPrc"/>%</td>
				<td>
					<xsl:value-of select="DistinctReads"/> recipients 
					- <xsl:value-of select="TotalReads"/> reads 
					- <xsl:value-of select="MultiReaders"/> repeat readers
				</td>
				<td><xsl:value-of select="DistinctReadPrc"/>%</td>
				<td><xsl:value-of select="DistinctClicks"/></td>
				<td><xsl:value-of select="DistinctClickPrc"/>%</td>
			</tr>
		</xsl:for-each>
		</table>

		<br /><br />
		<b>Detailed Clickthrough Info</b>
		<br /><br />	
		
		<!-- Begin block: For Comparison Only-->
		
		<!-- Header -->
		<xsl:for-each select="CampaignList/Campaigns/Row">
			<table class="main" width="100%" cellpadding="1" cellspacing="1">
				<tr>
					<th width="10%">Campaign Name</th>
					<th width="10%"># of Links</th>
					<th width="10%">Total Clicks</th>
					<th width="10%"># of Recipients who clicked multiple links</th>
					<th width="20%" colspan="2">Total Text</th>
					<th width="20%" colspan="2">Total HTML</th>
					<!--<th width="20%" colspan="2">Total AOL</th>//-->
				</tr>
				<!-- Data -->
				<tr>
					<td width="10%"><xsl:value-of select="Name"/></td>
					<td width="10%"><xsl:value-of select="TotalLinks"/></td>
					<td width="10%"><xsl:value-of select="DistinctClicks"/></td>
					<td width="10%"><xsl:value-of select="MultiLinkClickers"/></td>
					<td width="10%"><xsl:value-of select="DistinctText"/></td>
					<td width="10%"><xsl:value-of select="DistinctTextPrc"/>%</td>
					<td width="10%"><xsl:value-of select="DistinctHTML"/></td>
					<td width="10%"><xsl:value-of select="DistinctHTMLPrc"/>%</td>
					<!--<td width="10%"><xsl:value-of select="DistinctAOL"/></td>
					<td width="10%"><xsl:value-of select="DistinctAOLPrc"/>%</td>//-->
				</tr>
			</table>
		</xsl:for-each>

<!-- End block: For Comparison Only-->

		<br /><br />
		<b>Additional Total Clickthrough Info</b>
		<br /><br />	

		<xsl:for-each select="CampaignList/Campaigns/Row">
			<table class="main" width="100%" cellpadding="1" cellspacing="1">
				<tr>
					<th width="20%">Campaign Name</th>
					<th width="8%"># of Links</th>
					<th width="8%">Total Clicks</th>
					<th width="8%"># clicked on more than one link</th>
					<th width="8%"># clicked on one link multiple times</th>
					<th width="16%" colspan="2">Total Text</th>
					<th width="16%" colspan="2">Total HTML</th>
					<!--<th width="16%" colspan="2">Total AOL</th>//-->
				</tr>
				<!-- Data -->
				<tr>
					<td width="22%"><xsl:value-of select="Name"/></td>
					<td width="8%"><xsl:value-of select="TotalLinks"/></td>
					<td width="8%"><xsl:value-of select="TotalClicks"/></td>
					<td width="8%"><xsl:value-of select="MultiLinkClickers"/></td>
					<td width="8%"><xsl:value-of select="OneLinkMultiClickers"/></td>
					<td width="8%"><xsl:value-of select="TotalText"/></td>
					<td width="8%"><xsl:value-of select="TotalTextPrc"/>%</td>
					<td width="8%"><xsl:value-of select="TotalHTML"/></td>
					<td width="8%"><xsl:value-of select="TotalHTMLPrc"/>%</td>
					<!--<td width="8%"><xsl:value-of select="TotalAOL"/></td>
					<td width="8%"><xsl:value-of select="TotalAOLPrc"/>%</td>//-->
				</tr>
			</table>
		</xsl:for-each>

<!-- End block: For Comparison Only-->

	</xsl:otherwise>
	
</xsl:choose>

</form>
<br /><br />
</body>
</html>

</xsl:template>
</xsl:stylesheet>
