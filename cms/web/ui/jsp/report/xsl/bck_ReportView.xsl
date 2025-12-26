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
	<xsl:element name="link">
		<xsl:attribute name="rel">stylesheet</xsl:attribute>
		<xsl:attribute name="href"><xsl:value-of select="CampaignList/StyleSheet"/></xsl:attribute>
		<xsl:attribute name="type">text/css</xsl:attribute>
	</xsl:element>
<script language="javascript" src="/cms/ui/js/tab_script.js" type="text/javascript"></script>
<script language="javascript">
	
	function pop_up_win(url)
	{
		<xsl:if test="1 = /CampaignList/RecipView">
		windowName = 'report_results_window';
		windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=700';
		ReportWin = window.open(url, windowName, windowFeatures);
		</xsl:if>
	}
	
</script>
</head>

<body>

<xsl:choose>

	<xsl:when test = "CampaignList/OnlyOne">
	<table cellpadding="4" cellspacing="0" border="0">
		<tr>
			<xsl:if test="1 = /CampaignList/ReportCache">
			<td vAlign="middle" align="left">
				<xsl:element name="a">
					<xsl:attribute name="class">resourcebutton</xsl:attribute>
					<xsl:attribute name="href">report_cache_list.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
					&lt;&lt; Return to Demographic or Time Reports
				</xsl:element>
			</td>
			<xsl:if test="/CampaignList/Campaigns/Row/Cache/StartDate!='' or /CampaignList/Campaigns/Row/Cache/EndDate!='' or /CampaignList/Campaigns/Row/Cache/AttrName!=''">
			<td vAlign="middle" align="left">
				<xsl:element name="a">
					<xsl:attribute name="class">subactionbutton</xsl:attribute>
					<xsl:attribute name="href">report_cache_edit.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/></xsl:attribute>
					Edit Criteria
				</xsl:element>
			</td>
			</xsl:if>
			</xsl:if>
			<td vAlign="middle" align="left">
				<xsl:element name="a">
					<xsl:attribute name="class">resourcebutton</xsl:attribute>
					<xsl:attribute name="href">report_object.jsp?act=PRNT&#38;id=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/></xsl:attribute>
					Export to Excel
				</xsl:element>
			</td>
		</tr>
	</table>
	<br />

<!-- Block for one campaign-->

<table width="95%" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&#160;<b class="sectionheader">Report:</b>&#160;&#160;<xsl:value-of select="CampaignList/Campaigns/Row/Name"/></td>
	</tr>
</table>
<br/>
<table border="0" width="95%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="left" valign="bottom" style="padding:0px;">
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0">
				<tr>
				<xsl:choose>
					<xsl:when test="1 = /CampaignList/ReportCache">
						<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle">
							<xsl:attribute name="onclick">location.href = 'report_object.jsp?act=VIEW&#38;id=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>';</xsl:attribute>
							Campaign Results</td>
						<td class="EditTabOn" width="200" valign="center" nowrap="true" align="middle">Demographic Or Time Report</td>
					</xsl:when>
					<xsl:otherwise>
						<td class="EditTabOn" width="200" valign="center" nowrap="true" align="middle">Campaign Results</td>
						<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle">
							<xsl:attribute name="onclick">location.href = 'report_cache_list.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>';</xsl:attribute>
							Demographic Or Time Report</td>
					</xsl:otherwise>
				</xsl:choose>
					<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle">
						<xsl:attribute name="onclick">location.href = 'report_time.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>';</xsl:attribute>
						Activity vs. Time Report</td>
					
				<!--  added the tag to show Delivery tracker tab (part of release 5.9) -->	
				<xsl:if test="1 = /CampaignList/DeliveryTrackerRptFlag">
							<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle">
						<xsl:attribute name="onclick">location.href = 'eTrackerReport.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>';</xsl:attribute>
						Delivery Tracking</td>
					</xsl:if>	
				<!-- END of release 5.9-->
					
				<xsl:if test="0 &lt; /CampaignList/ReportPosFlag">
					<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle">
						<xsl:attribute name="onclick">location.href = 'report_track.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>';</xsl:attribute>
						BriteTrack Results</td>
				</xsl:if>
					<td class="EmptyTab" valign="center" nowrap="true" align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1" /></td>
				</tr>
			</table>
		</td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%" colspan="6">
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
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Size"/>
						</xsl:element>
					</td>

					<td align="center">Total Bounceback :</td>
					<td align="center">
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
						</xsl:element>
						(<xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%)
					</td>

					<td align="center">Total Click Throughs :</td>
					<td align="center">
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
						</xsl:element>
						(<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%)
					</td>

					<td align="center">Total Unsubscribes :</td>
					<td align="center">
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
						</xsl:element>
						(<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%)
					</td>
				</tr>
			</table>
			<br />
		</xsl:if>
		<xsl:if test="1 = /CampaignList/ReportCache">
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="2">&#160; Report Parameters</th>
				</tr>
				<xsl:if test="/CampaignList/Campaigns/Row/Cache/StartDate!=''">
				<tr>
					<td align="right" class="list_row" nowrap="true">Start Date:</td>
					<td class="list_row" width="100%"><nobr>&#160;<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/StartDate"/></nobr></td>
				</tr>
				</xsl:if>
				<xsl:if test="/CampaignList/Campaigns/Row/Cache/EndDate!=''">
				<tr>
					<td align="right" class="list_row_other" nowrap="true">End Date:</td>
					<td class="list_row_other" width="100%"><nobr>&#160;<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/EndDate"/></nobr></td>
				</tr>
				</xsl:if>
				<xsl:if test="/CampaignList/Campaigns/Row/Cache/AttrName!=''">
				<tr>
					<td align="right" class="list_row" nowrap="true">Attribute:</td>
					<td class="list_row" width="100%">
						&#160;<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrName"/>
						&#160;<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrOperator"/>
						&#160;<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrValue1"/>
						<xsl:if test="/CampaignList/Campaigns/Row/Cache/AttrOperator = 'BETWEEN'">
						&#160;AND&#160;<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrValue2"/>
						</xsl:if>
					</td>
				</tr>
				</xsl:if>
				<tr>
					<td align="right" class="list_row" nowrap="true">Only Recips Owned By User?</td>
					<td class="list_row" width="100%">
						<xsl:choose>
							<xsl:when test="/CampaignList/Campaigns/Row/Cache/UserID = 0">
								No
							</xsl:when>
							<xsl:otherwise>
								Yes
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</table>
			<br />
		</xsl:if>


			<!-- First Report Grid -->

			<xsl:if test="1 = /CampaignList/GeneralSecFlag">
			<div id="info">
					<div id="xsnazzy">
						<b class="xtop">
							<b class="xb1"></b>
							<b class="xb2"></b>
							<b class="xb3"></b>
							<b class="xb4"></b>
						</b>
						<div class="xboxcontent">

							<table class="listTable" cellSpacing="0" cellPadding="2" width="100%" style="padding-top: 4px;">
								<tr>
									<th colspan="3">General Campaign Statistics</th>
								</tr>
								<tr>
									<td width="150" align="left" class="list_row" nowrap="true">Messages Sent :</td>
									<td class="list_row" nowrap="true">
										&#160;
										<xsl:element name="a">
											<xsl:attribute name="href">
												javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
											</xsl:attribute>
											<xsl:value-of select="CampaignList/Campaigns/Row/Size"/>
										</xsl:element>
									</td>
									<td class="list_row" width="100%">
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
												<td valign="middle" width="10%" align="right">
													<img height="10" width="1" src="/cms/ui/images/blank.gif" />
												</td>
											</tr>

										</xsl:element>
									</td>
								</tr>
								<tr>
									<td width="150" align="left" class="list_row_other" nowrap="true">Total Bounceback :</td>
									<td class="list_row_other" nowrap="true">
										&#160;
										<xsl:element name="a">
											<xsl:attribute name="href">
												javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
											</xsl:attribute>
											<xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
										</xsl:element>
										(<xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%)
									</td>
									<td class="list_row_other" width="100%">
										<xsl:element name="table">
											<xsl:attribute name="width">
												<xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%
											</xsl:attribute>
											<xsl:attribute name="border">0</xsl:attribute>
											<xsl:attribute name="cellpadding">0</xsl:attribute>
											<xsl:attribute name="cellspacing">0</xsl:attribute>
											<tr>
												<td valign="middle" class="html" align="center">
													<img height="10" width="1" src="/cms/ui/images/blank.gif" />
												</td>
											</tr>
										</xsl:element>
									</td>
								</tr>
								<tr>
									<td width="150" align="left" class="list_row" nowrap="true">Total Reaching :</td>
									<td class="list_row" nowrap="true">
										&#160;
										<xsl:element name="a">
											<xsl:attribute name="href">
												javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
											</xsl:attribute>
											<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
										</xsl:element> (<xsl:value-of select="CampaignList/Campaigns/Row/ReachingPrc"/>%)
									</td>
									<td class="list_row" width="100%">
										<xsl:element name="table">
											<xsl:attribute name="width">
												<xsl:value-of select="CampaignList/Campaigns/Row/ReachingPrc"/>%
											</xsl:attribute>
											<xsl:attribute name="border">0</xsl:attribute>
											<xsl:attribute name="cellpadding">0</xsl:attribute>
											<xsl:attribute name="cellspacing">0</xsl:attribute>
											<tr>
												<td valign="middle" class="html" align="center">
													<img height="10" width="1" src="/cms/ui/images/blank.gif" />
												</td>
											</tr>
										</xsl:element>
									</td>
								</tr>
							</table>
						</div>
						<b class="xbottom">
							<b class="xb4"></b>
							<b class="xb3"></b>
							<b class="xb2"></b>
							<b class="xb1"></b>
						</b>
					</div>
				</div>
				<br />
			</xsl:if>

<!-- Bounce Back Categories -->

		<xsl:if test="1 = /CampaignList/BBackSecFlag">
			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">
			
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="3">Bounceback Categories</th>
				</tr>
				<tr>
					<td width="150" align="left" class="list_row" nowrap="true">Total Bounceback :</td>
					<td class="list_row" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
						</xsl:element>
					</td>
					<td class="list_row" width="100%">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
						</table>
					</td>
				</tr>
			<xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row_other<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">150</xsl:attribute>
						<xsl:attribute name="align">left</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="CategoryName"/> :
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampID"/>&#38;B=<xsl:value-of select="CategoryID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="BBacks"/>
							</xsl:element> (<xsl:value-of select="BBackPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">100%</xsl:attribute>
							<xsl:element name="table">
								<xsl:attribute name="width"><xsl:value-of select="BBackPrc"/>%</xsl:attribute>
								<xsl:attribute name="border">0</xsl:attribute>
								<xsl:attribute name="cellpadding">0</xsl:attribute>
								<xsl:attribute name="cellspacing">0</xsl:attribute>
								<tr> 
									<td valign="middle" class="html" align="center"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td> 
								</tr> 
							</xsl:element>
					</xsl:element>
				</tr> 
			</xsl:for-each>
			</table>
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<br />
		</xsl:if>

<!--Recipient Actions -->

		<xsl:if test="1 = /CampaignList/ActionSecFlag">
			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">

						<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="3">Recipient Actions</th>
				</tr>
				<tr>
					<td width="150" align="left" class="list_row" nowrap="true">Total Reaching :</td>
					<td class="list_row" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
						</xsl:element> 
					</td>
					<td class="list_row" width="100%">
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
					<td width="150" align="left" class="list_row_other" nowrap="true">Total Open HTML :</td>
					<td class="list_row_other" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/> 
						</xsl:element> 
						(<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%)
					</td>
					<td class="list_row_other" width="100%">
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
				<tr>
					<td width="150" align="left" class="list_row" nowrap="true">Total Click Throughs :</td>
					<td class="list_row" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
						</xsl:element> (<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%) 
					</td>
					<td class="list_row" width="100%">
						<xsl:element name="table">
							<xsl:attribute name="width"><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%</xsl:attribute>
							<xsl:attribute name="border">0</xsl:attribute>
							<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
							<xsl:attribute name="cellpadding">0</xsl:attribute>
							<xsl:attribute name="cellspacing">0</xsl:attribute>
							<tr> 
								<td valign="middle" class="html" align="center"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td> 
							</tr> 
						</xsl:element>
					</td>
				</tr>
				<tr>
					<td width="150" align="left" class="list_row_other" nowrap="true">Total Unsubscribes :</td>
					<td class="list_row_other" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
						</xsl:element> (<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%)
					</td>
					<td class="list_row_other" width="100%">
						<xsl:element name="table">
							<xsl:attribute name="width"><xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%</xsl:attribute>
							<xsl:attribute name="border">0</xsl:attribute>
							<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
							<xsl:attribute name="cellpadding">0</xsl:attribute>
							<xsl:attribute name="cellspacing">0</xsl:attribute>
							<tr> 
								<td valign="middle" class="html" align="center"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td> 
							</tr> 
						</xsl:element>
					</td>
				</tr>
			</table>
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<br />
		</xsl:if>
		
		
		<!-- New Unsubscribe Categories -->

		<xsl:if test="1 = /CampaignList/BBackSecFlag">
			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">
						
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="3">Unsubscribe Categories</th>
				</tr>
				<tr>
					<td width="150" align="left" class="list_row" nowrap="true">Total Unsubscribes :</td>
					<td class="list_row" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
						</xsl:element>
					</td>
					<td class="list_row" width="100%">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
						</table>
					</td>
				</tr>
			<xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">150</xsl:attribute>
						<xsl:attribute name="align">right</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="LevelName"/> :
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsublevel&#38;Q=<xsl:value-of select="CampID"/>&#38;S=<xsl:value-of select="LevelID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="Unsubs"/>
							</xsl:element> (<xsl:value-of select="UnsubsPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">100%</xsl:attribute>
							<xsl:element name="table">
								<xsl:attribute name="width"><xsl:value-of select="UnsubsPrc"/>%</xsl:attribute>
								<xsl:attribute name="border">0</xsl:attribute>
								<xsl:attribute name="cellpadding">0</xsl:attribute>
								<xsl:attribute name="cellspacing">0</xsl:attribute>
								<tr> 
									<td valign="middle" class="html" align="center"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td> 
								</tr> 
							</xsl:element>
					</xsl:element>
				</tr> 
			</xsl:for-each>
			</table>
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<br />
		</xsl:if>	
	
<!-- Optouts -->

		<xsl:if test="1 = /CampaignList/OptoutFlag">
			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">			
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="3">Newsletter Optouts</th>
				</tr>
				<tr>
					<td width="150" align="left" class="list_row" nowrap="true">Total Reaching :</td>
					<td class="list_row" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
						</xsl:element> 
					</td>
					<td class="list_row" width="100%">
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
			<xsl:for-each select="CampaignList/Campaigns/Row/Optouts">
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">150</xsl:attribute>
						<xsl:attribute name="align">right</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="AttrName"/> :
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=optout&#38;Q=<xsl:value-of select="CampID"/>&#38;N=<xsl:value-of select="AttrID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="Optouts"/>
							</xsl:element> (<xsl:value-of select="OptoutPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">100%</xsl:attribute>
							<xsl:element name="table">
								<xsl:attribute name="width"><xsl:value-of select="OptoutPrc"/>%</xsl:attribute>
								<xsl:attribute name="border">0</xsl:attribute>
								<xsl:attribute name="cellpadding">0</xsl:attribute>
								<xsl:attribute name="cellspacing">0</xsl:attribute>
								<tr> 
									<td valign="middle" class="html" align="center"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td> 
								</tr> 
							</xsl:element>
					</xsl:element>
				</tr> 
			</xsl:for-each>
			</table>
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<br />
		</xsl:if>

<!-- Detailed Clicks-->

		<xsl:if test="1 = /CampaignList/DistClickSecFlag">
			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">
						
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="3">Detailed Clickthroughs (Unique Clicks)</th>
				</tr>
				<tr>
					<td width="150" align="left" class="list_row" nowrap="true">Total Clicks :</td>
					<td class="list_row" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
						</xsl:element> 
					</td>
					<td class="list_row" width="100%">
						<xsl:element name="table">
							<xsl:attribute name="width">100%</xsl:attribute>
							<xsl:attribute name="border">0</xsl:attribute>
							<xsl:attribute name="cellpadding">0</xsl:attribute>
							<xsl:attribute name="cellspacing">0</xsl:attribute>
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
								<td class="reportmarkers" valign="middle" width="10%" align="right"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>  
						</xsl:element>
					</td>
				</tr>
			<xsl:for-each select="CampaignList/Campaigns/Row/Links">
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">150</xsl:attribute>
						<xsl:attribute name="align">right</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="LinkName"/>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="DistinctClicks"/>
							</xsl:element>  
							&#160;
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="DistinctText"/> 
							</xsl:element>
							T | 
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="DistinctHTML"/> 
							</xsl:element> H <!--|
							<xsl:element name="a">
								<xsl:attribute name="class">reportclientaol</xsl:attribute>
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=A&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="DistinctAOL"/> 
							</xsl:element>
							A //-->&#160;
							(<xsl:value-of select="DistinctClickPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">100%</xsl:attribute>
							<xsl:element name="table">
								<xsl:attribute name="width"><xsl:value-of select="DistinctClickPrc"/>%</xsl:attribute>
								<xsl:attribute name="border">0</xsl:attribute>
								<xsl:attribute name="cellpadding">0</xsl:attribute>
								<xsl:attribute name="cellspacing">0</xsl:attribute>
								<tr> 
									<xsl:element name="td">
										<xsl:attribute name="width"><xsl:value-of select="./DistinctTextPrc"/>%</xsl:attribute>
										<xsl:attribute name="valign">middle</xsl:attribute>
										<xsl:attribute name="align">center</xsl:attribute>
										<xsl:attribute name="class">text</xsl:attribute>
										<img height="10" width="1" src="/cms/ui/images/blank.gif" />
									</xsl:element>

									<xsl:element name="td">
										<xsl:attribute name="width"><xsl:value-of select="./DistinctHTMLPrc"/>%</xsl:attribute>
										<xsl:attribute name="valign">middle</xsl:attribute>
										<xsl:attribute name="align">center</xsl:attribute>
										<xsl:attribute name="class">html</xsl:attribute>
										<img height="10" width="1" src="/cms/ui/images/blank.gif" />
									</xsl:element>

									<!--<xsl:element name="td">
										<xsl:attribute name="width"><xsl:value-of select="./DistinctAOLPrc"/>%</xsl:attribute>
										<xsl:attribute name="valign">middle</xsl:attribute>
										<xsl:attribute name="align">center</xsl:attribute>
										<xsl:attribute name="class">aol</xsl:attribute>
										<img height="10" width="1" src="/cms/ui/images/blank.gif" />
									</xsl:element>//-->
								</tr> 
							</xsl:element>
					</xsl:element>
				</tr>
			</xsl:for-each>
				<tr>
					<td colspan="2" align="right" class="list_row" nowrap="true">&#160;</td>
					<td class="list_row" width="100%">
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
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<br />
		</xsl:if>

<!-- Detailed Clicks-->

		<xsl:if test="1 = /CampaignList/TotClickSecFlag">
			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">			
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="3">Detailed Clickthroughs (Total Aggregate Clicks)</th>
				</tr>
				<tr>
					<td width="150" align="left" class="list_row" nowrap="true">Total Clicks :</td>
					<td class="list_row" nowrap="true">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/>
						</xsl:element> 
					</td>
					<td class="list_row" width="100%">
						<xsl:element name="table">
							<xsl:attribute name="width">100%</xsl:attribute>
							<xsl:attribute name="border">0</xsl:attribute>
							<xsl:attribute name="cellpadding">0</xsl:attribute>
							<xsl:attribute name="cellspacing">0</xsl:attribute>
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
								<td class="reportmarkers" valign="middle" width="10%" align="right"><img height="10" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>  
						</xsl:element>
					</td>
				</tr>
			<xsl:for-each select="CampaignList/Campaigns/Row/Links">
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">150</xsl:attribute>
						<xsl:attribute name="align">right</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="LinkName"/>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="TotalClicks"/>
							</xsl:element>  
							&#160;
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="TotalText"/> 
							</xsl:element>
							T | 
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="TotalHTML"/> 
							</xsl:element> H <!--|
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=A&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="TotalAOL"/> 
							</xsl:element>
							A //-->&#160;
							(<xsl:value-of select="TotalClickPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">100%</xsl:attribute>
							<xsl:element name="table">
								<xsl:attribute name="width"><xsl:value-of select="TotalClickPrc"/>%</xsl:attribute>
								<xsl:attribute name="border">0</xsl:attribute>
								<xsl:attribute name="bgcolor">#cccccc</xsl:attribute>
								<xsl:attribute name="cellpadding">0</xsl:attribute>
								<xsl:attribute name="cellspacing">0</xsl:attribute>
								<tr> 
									<xsl:element name="td">
										<xsl:attribute name="width"><xsl:value-of select="./TotalTextPrc"/>%</xsl:attribute>
										<xsl:attribute name="valign">middle</xsl:attribute>
										<xsl:attribute name="align">center</xsl:attribute>
										<xsl:attribute name="class">text</xsl:attribute>
										<img height="10" width="1" src="/cms/ui/images/blank.gif" />
									</xsl:element>

									<xsl:element name="td">
										<xsl:attribute name="width"><xsl:value-of select="./TotalHTMLPrc"/>%</xsl:attribute>
										<xsl:attribute name="valign">middle</xsl:attribute>
										<xsl:attribute name="align">center</xsl:attribute>
										<xsl:attribute name="class">html</xsl:attribute>
										<img height="10" width="1" src="/cms/ui/images/blank.gif" />
									</xsl:element>

									<!--<xsl:element name="td">
										<xsl:attribute name="width"><xsl:value-of select="./TotalAOLPrc"/>%</xsl:attribute>
										<xsl:attribute name="valign">middle</xsl:attribute>
										<xsl:attribute name="align">center</xsl:attribute>
										<xsl:attribute name="class">aol</xsl:attribute>
										<img height="10" width="1" src="/cms/ui/images/blank.gif" />
									</xsl:element>//-->
								</tr> 
							</xsl:element>
					</xsl:element>
				</tr>
			</xsl:for-each>
				<tr>
					<td colspan="2" align="right" class="list_row" nowrap="true">&#160;</td>
					<td class="list_row" width="100%">
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
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<br />
		</xsl:if>

<!-- Form Submits -->

		<xsl:if test="1 = /CampaignList/FormSecFlag">
			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">			
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="5">&#160;Form Submissions</th>
				</tr>
				<tr>
					<td align="right" class="subsectionheader" nowrap="true">Form Name</td>
					<td class="subsectionheader" nowrap="true">Distinct Page Views</td>
					<td class="subsectionheader" nowrap="true">Distinct Submissions</td>
					<td class="subsectionheader" nowrap="true">Submitted Multiple Times</td>
					<td align="left" class="subsectionheader" nowrap="true">Submit Form Name</td>
				</tr> 
			<xsl:for-each select="CampaignList/Campaigns/Row/Forms">
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="align">right</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="FirstFormName"/>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=view&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="FirstFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="DistinctViews"/>
							</xsl:element>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=submit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="DistinctSubmits"/>
							</xsl:element>
							(<xsl:value-of select="DistinctViewSubmitPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multisubmit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="MultiSubmitters"/>
							</xsl:element>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="align">left</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="LastFormName"/>
					</xsl:element>
				</tr> 
			</xsl:for-each>
				<tr>
					<td align="right" class="subsectionheader" nowrap="true">Form Name</td>
					<td class="subsectionheader" nowrap="true">Total Page Views</td>
					<td class="subsectionheader" nowrap="true">Total Submissions</td>
					<td class="subsectionheader" nowrap="true">Submitted Multiple Times</td>
					<td align="left" class="subsectionheader" nowrap="true">Submit Form Name</td>
				</tr> 
			<xsl:for-each select="CampaignList/Campaigns/Row/Forms">
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="align">right</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="FirstFormName"/>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=view&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="FirstFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="TotalViews"/>
							</xsl:element>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=submit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="TotalSubmits"/>
							</xsl:element>
							(<xsl:value-of select="TotalViewSubmitPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multisubmit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="MultiSubmitters"/>
							</xsl:element>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="align">left</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="LastFormName"/>
					</xsl:element>
				</tr> 
			</xsl:for-each>
			</table>
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<br />
		</xsl:if>

			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">			
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="2">&#160;Additional Metrics</th>
				</tr>
			<xsl:if test="1 = /CampaignList/TotReadFlag">
				<tr>
					<td align="right" class="list_row" nowrap="true">Total HTML Email views</td>
					<td class="list_row" width="100%">&#160; 
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/TotalReads"/>
						</xsl:element>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="1 = /CampaignList/MultiReadFlag">
				<tr>
					<td align="right" class="list_row" nowrap="true">Opened HTML Email more than once</td>
					<td class="list_row" width="100%">&#160; 
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiread&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/MultiReaders"/>
						</xsl:element>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="1 = /CampaignList/TotClickFlag">
				<tr>
					<td align="right" class="list_row" nowrap="true">Aggregate Clickthroughs</td>
					<td class="list_row" width="100%">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/>
						</xsl:element>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="1 = /CampaignList/MultiLinkClickFlag">
				<tr>
					<td align="right" class="list_row" nowrap="true">Clicked on more than one link</td>
					<td class="list_row" width="100%">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/MultiLinkClickers"/>
						</xsl:element>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="1 = /CampaignList/LinkMultiClickFlag">
				<tr>
					<td align="right" class="list_row" nowrap="true">Clicked on one link multiple times</td>
					<td class="list_row" width="100%">&#160;
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
							<xsl:value-of select="CampaignList/Campaigns/Row/OneLinkMultiClickers"/>
						</xsl:element>
					</td>
				</tr>
			</xsl:if>
			</table>
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<!-- Domain Deliverability -->

		<xsl:if test="1 = /CampaignList/DomainFlag">
			<br />
			<div id="info">
				<div id="xsnazzy">
					<b class="xtop">
						<b class="xb1"></b>
						<b class="xb2"></b>
						<b class="xb3"></b>
						<b class="xb4"></b>
					</b>
					<div class="xboxcontent">			
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th colspan="7">&#160;Domain Deliverability</th>
				</tr>
				<tr>
					<td class="subsectionheader" width="150" nowrap="true">Domain</td>
					<td class="subsectionheader" nowrap="true">Sent</td>
					<td class="subsectionheader" nowrap="true">Bounced</td>
					<td class="subsectionheader" nowrap="true">Read</td>
					<td class="subsectionheader" nowrap="true">Clicked</td>
					<td class="subsectionheader" nowrap="true">Total Unsubscribed</td>
					<td class="subsectionheader" nowrap="true">Unsubscribe - Spam Complaints</td>  <!-- Spam Complaints -->
				</tr>
			<xsl:for-each select="CampaignList/Campaigns/Row/Domains">
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="width">150</xsl:attribute>
						<xsl:attribute name="align">right</xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							<xsl:value-of select="Domain"/>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainsent&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="Sent"/> 
							</xsl:element>
					</xsl:element>
					<!-- added for release 5.9 , reporting changes -->
					<xsl:element name="td">
						<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainbbk&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="BBacks"/>
							</xsl:element>
							(<xsl:value-of select="BBackPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainread&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="Reads"/> 
							</xsl:element>
							(<xsl:value-of select="ReadPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainclick&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="Clicks"/> 
							</xsl:element>
							(<xsl:value-of select="ClickPrc"/>%)
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainunsub&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="Unsubs"/>
							</xsl:element>
							(<xsl:value-of select="UnsubPrc"/>%)							
					</xsl:element>
						<!-- end release 5.9 changes -->
										
					<!-- added for release 6.1 ,Spam complaints --> 
										
					<xsl:element name="td">
						<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="nowrap">true</xsl:attribute>
							&#160;
							<xsl:element name="a">
							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainspam&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
								<xsl:value-of select="UnsubsSpam"/>
							</xsl:element>
							(<xsl:value-of select="UnsubsSpamPrc"/>%)							
					</xsl:element>
					<!-- end of release 6.1 ,Spam complaints --> 
				</tr> 
			</xsl:for-each>
			</table>
					</div>
					<b class="xbottom">
						<b class="xb4"></b>
						<b class="xb3"></b>
						<b class="xb2"></b>
						<b class="xb1"></b>
					</b>
				</div>
			</div>
			<br />
		</xsl:if>

		</td>
	</tr>
	</tbody>
</table>


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
          <th width="10%" colspan="2">Click Throughs</th>
          <th width="10%" colspan="2">Unsubscribes</th>
        </tr>
<!-- Data -->
  <xsl:for-each select="CampaignList/Campaigns/Row">
        <tr>
		  <td>
			<xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Name"/>
			</xsl:element> (cache=<xsl:value-of select="CacheId"/>)
          </td>
          <td><xsl:value-of select="StartDate"/></td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Size"/>
			</xsl:element></td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="BBacks"/>
			</xsl:element></td>
          <td><xsl:value-of select="BBackPrc"/>%</td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="DistinctClicks"/>
			</xsl:element></td>
          <td><xsl:value-of select="DistinctClickPrc"/>%</td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Unsubs"/>
			</xsl:element></td>
          <td><xsl:value-of select="UnsubPrc"/>%</td>
        </tr>
  </xsl:for-each>
      </table>
</xsl:if>
<xsl:if test="1 = /CampaignList/GeneralSecFlag">
<br /><br />
	  <b>General Campaign  Statistics</b><br /><br />			
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
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Name"/>
			</xsl:element> (cache=<xsl:value-of select="CacheId"/>)
		  </td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Size"/>
			</xsl:element></td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="BBacks"/>&#x20;
			</xsl:element>
          </td>
          <td><xsl:value-of select="BBackPrc"/>%</td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Reaching"/>
			</xsl:element></td>
          <td><xsl:value-of select="ReachingPrc"/>%</td>
        </tr>
  </xsl:for-each>
      </table>
</xsl:if>
<xsl:if test="1 = /CampaignList/ActivitySecFlag">
<br /><br />
	  <b>Activity Details</b><br /><br />	
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
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Name"/>
			</xsl:element>(cache=<xsl:value-of select="CacheId"/>)
		  </td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Reaching"/>
			</xsl:element></td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Unsubs"/>
			</xsl:element></td>
          <td><xsl:value-of select="UnsubPrc"/>%</td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="DistinctReads"/>
			</xsl:element> recipients 
			  - <xsl:value-of select="TotalReads"/> reads 
			  - <xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiread&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
            <xsl:value-of select="MultiReaders"/></xsl:element> repeat readers</td>
          <td><xsl:value-of select="DistinctReadPrc"/>%</td>
          <td><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="DistinctClicks"/>
			</xsl:element></td>
          <td><xsl:value-of select="DistinctClickPrc"/>%</td>
        </tr>
  </xsl:for-each>
      </table>
</xsl:if>
<xsl:if test="1 = /CampaignList/DistClickSecFlag">
<br /><br />
	  <b>Detailed Clickthrough Info</b><br /><br />	
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
          <td width="10%">
			<xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="Name"/>
			</xsl:element>(cache=<xsl:value-of select="CacheId"/>)
          </td>
          <td width="10%"><xsl:value-of select="TotalLinks"/></td>
          <td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="DistinctClicks"/>
			</xsl:element></td>
          <td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
			<xsl:value-of select="MultiLinkClickers"/>
			</xsl:element></td>
          <td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=T');</xsl:attribute>
			<xsl:value-of select="DistinctText"/>
			</xsl:element></td>
          <td width="10%"><xsl:value-of select="DistinctTextPrc"/>%</td>
          <td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=H');</xsl:attribute>
			<xsl:value-of select="DistinctHTML"/>
			</xsl:element></td>
          <td width="10%"><xsl:value-of select="DistinctHTMLPrc"/>%</td>
          <!--<td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=A');</xsl:attribute>
			<xsl:value-of select="DistinctAOL"/>
			</xsl:element></td>
          <td width="10%"><xsl:value-of select="DistinctAOLPrc"/>%</td>//-->
        </tr>

<!-- Header -->
        <tr>
          <th width="20%" colspan="2">Link Name</th>
          <th width="20%" colspan="2">Number Clicks</th>
          <th width="20%" colspan="2">Text</th>
          <th width="20%" colspan="2">HTML</th>
          <!--<th width="20%" colspan="2">AOL</th>//-->
        </tr>
	
<!-- Data -->
    <xsl:for-each select="./Links">
        <tr>
          <td width="20%" colspan="2"><xsl:value-of select="LinkName"/></td>
          <td width="20%" colspan="2"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');</xsl:attribute>
			<xsl:value-of select="DistinctClicks"/>
			</xsl:element> (<xsl:value-of select="DistinctClickPrc"/>%)</td>
          <td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T');</xsl:attribute>
			<xsl:value-of select="DistinctText"/>
            </xsl:element></td>
          <td width="10%"><xsl:value-of select="DistinctTextPrc"/>%</td>
          <td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H');</xsl:attribute>
			<xsl:value-of select="DistinctHTML"/>
            </xsl:element></td>
          <td width="10%"><xsl:value-of select="DistinctHTMLPrc"/>%</td>
          <!--<td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=A');</xsl:attribute>
			<xsl:value-of select="DistinctAOL"/>
            </xsl:element></td>
          <td width="10%"><xsl:value-of select="DistinctAOLPrc"/>%</td>//-->
        </tr>
		
    </xsl:for-each>
	</table>
</xsl:for-each>

<!-- End block: For Comparison Only-->
</xsl:if>
<xsl:if test="1 = /CampaignList/TotClickSecFlag">

	 <br /><br />
	  <b>Additional Total Clickthrough Info</b><br /><br />	
	 
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
          <td width="22%">
  		<xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
  		<xsl:value-of select="Name"/>
  		</xsl:element>
          </td>
          <td width="8%"><xsl:value-of select="TotalLinks"/></td>
          <td width="8%"><xsl:element name="a">
          <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
        <xsl:value-of select="TotalClicks"/>
        </xsl:element></td>
          <td width="8%"><xsl:element name="a">
          <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
        <xsl:value-of select="MultiLinkClickers"/>
        </xsl:element></td>
          <td width="8%"><xsl:element name="a">
          <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
        <xsl:value-of select="OneLinkMultiClickers"/>
        </xsl:element></td>
          <td width="8%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=T');</xsl:attribute>
  		<xsl:value-of select="TotalText"/>
  		</xsl:element></td>
          <td width="8%"><xsl:value-of select="TotalTextPrc"/>%</td>
          <td width="8%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=H');</xsl:attribute>
  		<xsl:value-of select="TotalHTML"/>
  		</xsl:element></td>
          <td width="8%"><xsl:value-of select="TotalHTMLPrc"/>%</td>
          <!--<td width="8%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=A');</xsl:attribute>
  		<xsl:value-of select="TotalAOL"/>
  		</xsl:element></td>
          <td width="8%"><xsl:value-of select="TotalAOLPrc"/>%</td>//-->
        </tr>

<!-- Header -->
        <tr>
          <th width="20%">Link Name</th>
          <th width="10%" colspan="2">Number Clicks</th>
          <th width="10%" colspan="2"># clicked on one link multiple times</th>
          <th width="20%" colspan="2">Text</th>
          <th width="20%" colspan="2">HTML</th>
          <!--<th width="20%" colspan="2">AOL</th>//-->
        </tr>
<!-- Data -->
    <xsl:for-each select="./Links">
        <tr>
          <td width="20%"><xsl:value-of select="LinkName"/></td>
          <td width="10%" colspan="2"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');</xsl:attribute>
  		<xsl:value-of select="TotalClicks"/>
  		</xsl:element> (<xsl:value-of select="TotalClickPrc"/>%)</td>
          <td width="10%"  colspan="2"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');</xsl:attribute>
  		<xsl:value-of select="MultiClickers"/>
  		</xsl:element>
          </td>
          <td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T');</xsl:attribute>
  		<xsl:value-of select="TotalText"/>
            </xsl:element></td>
          <td width="10%"><xsl:value-of select="TotalTextPrc"/>%</td>
          <td width="10%"><xsl:element name="a">
  			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H');</xsl:attribute>
  		<xsl:value-of select="TotalHTML"/>
            </xsl:element></td>
          <td width="10%"><xsl:value-of select="TotalHTMLPrc"/>%</td>
        </tr>
		
    </xsl:for-each>
	</table>
  </xsl:for-each>
<!-- End block: For Comparison Only-->
 
</xsl:if>
	  
	</xsl:otherwise>
</xsl:choose>

<br /><br />
</body>

</html>

</xsl:template>
</xsl:stylesheet>
