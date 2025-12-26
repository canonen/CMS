<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- <xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl"> -->

	<xsl:output method="html" indent="yes" />
	
	<xsl:template match="/">
		<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">]]></xsl:text>
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>Kampanya Raporu</title>
			<meta http-equiv="Expires" content="0"/>
			<meta http-equiv="Caching" content=""/>
			<meta http-equiv="Pragma" content="no-cache"/>
			<meta http-equiv="Cache-Control" content="no-cache"/>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<link rel="stylesheet" media="all" type="text/css" href="https://cms.revotas.com/cms/ui/jsp/mini/default.css" />
			<script type="text/javascript" src="https://www.google.com/jsapi">//</script>
			
			<xsl:if test="1 = /CampaignList/RecipView">
				<script type="text/javascript">
					<xsl:text>
					function pop_up_win(url) {
						windowName = 'report_results_window';
						windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=700';
						ReportWin = window.open(url, windowName, windowFeatures);
					} 
					</xsl:text>
				</script>
			</xsl:if>				
		</head>
		<body style="margin:10px;">

			<xsl:choose>
				<xsl:when test = "CampaignList/OnlyOne">

					
				<div class="wrapper" style="background-color: white; padding: 15px;border: 1px solid #CCCCCC;border-radius: 0 0 6px 6px;">
					
					<!-- start main content -->
					<div class="sectionBox">
						<!-- left container start -->
						<div id="sortableColumnLeft" class="droptrue moveObj">
													
							<xsl:if test="1 = /CampaignList/GeneralSecFlag">
							<!-- Report Summary Start -->
							<div class="ui-state-default sectionblock" id="section-reportSummary">
								
									<div style="margin-top:10px;margin-bottom:10px;font-size:11px;font-weight:bold;"><xsl:value-of select="CampaignList/Campaigns/Row/Name"/></div>
									
									<div id="reportSummaryCnt" style="display:block;" class="midSizeBoxes">
																		
										<table cellpadding="0" cellspacing="0" border="0">
											<tr>
												<td align="center" style="padding-right:10px;">
													
													<div id="chart_div"></div>	
													
													<script type="text/javascript">
														google.load("visualization", "1", {packages:["corechart"]});
														google.setOnLoadCallback(drawChart);
														function drawChart() {
														var data = google.visualization.arrayToDataTable([
														  ['Task', 'Hours per Day'],
														  ['Okuyan',     <xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>],
														  ['Okumayan',  <xsl:value-of select="(CampaignList/Campaigns/Row/Reaching)-(CampaignList/Campaigns/Row/DistinctReads)"/>]
														]);
														
														var options = {
															is3D:false,
															legend: {position: 'none'},
															width:250,
															height:250,
															chartArea:{left:10,top:10,width:"90%",height:"100%"},
															colors:['#3366CC','#FF9900'],
															backgroundColor:'#FFFFFF'
														};
		
														var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
														chart.draw(data, options);
														}
													</script>
			
													<div class="camp-sum-sentn"><xsl:value-of select="CampaignList/Campaigns/Row/Size"/></div>
													<div class="camp-sum-sent">email gönderildi</div>
												</td>
												<td>
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="camp-summary-table">
														<tr class="contentRows">
															<td valign="middle" align="center" class="camp-sum-headers">Ulaşan</td>
															<td>
																<xsl:element name="div">
																		<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																	<div class="hovercontent">
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail reportPopDetailr</xsl:attribute>
																			
																			<xsl:choose>
																				<xsl:when test="'280' = /CampaignList/CustID">
																					<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:attribute name="href">#</xsl:attribute>
																				</xsl:otherwise>
																			</xsl:choose>

																			<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
																		</xsl:element>
																	</div>
																</xsl:element>
															</td>
															<td class="perc">(<xsl:value-of select="CampaignList/Campaigns/Row/ReachingPrc"/>%)</td>
														</tr>
														<tr>
															<td valign="middle" align="center" class="camp-sum-headers">Okuyan</td>
															<td>
																<xsl:element name="div">
																		<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																	<div class="hovercontent">
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail reportPopDetailb</xsl:attribute>
																			
																			<xsl:choose>
																				<xsl:when test="'280' = /CampaignList/CustID">
																					<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:attribute name="href">#</xsl:attribute>
																				</xsl:otherwise>
																			</xsl:choose>
																			
																			<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>
																		</xsl:element> 
																	</div>
																</xsl:element>	
															</td>
															<td class="perc">(<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%)</td>
														</tr>
														<tr>
															<td valign="middle" align="center" class="camp-sum-headers">Ulaşmayan</td>
															<td>
																<xsl:element name="div">
																		<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																	<div class="hovercontent">
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail reportPopDetailund</xsl:attribute>
																			
																			<xsl:choose>
																				<xsl:when test="'280' = /CampaignList/CustID">
																					<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:attribute name="href">#</xsl:attribute>
																				</xsl:otherwise>
																			</xsl:choose>
																			
																			<xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
																		</xsl:element>
																	</div>
																</xsl:element>																		
															</td>
															<td class="perc">(<xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%)</td>
														</tr>
														<tr>
															<td valign="middle" align="center" class="camp-sum-headers">Listeden Çıkan</td>
															<td>
															<xsl:element name="div">
																	<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>	
																<div class="hovercontent">
																	<xsl:element name="a">
																		<xsl:attribute name="class">reportPopDetail reportPopDetailu</xsl:attribute>
																		
																		<xsl:choose>
																				<xsl:when test="'280' = /CampaignList/CustID">
																					<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																					</xsl:attribute>
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:attribute name="href">#</xsl:attribute>
																				</xsl:otherwise>
																			</xsl:choose>
																			
																		<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
																	</xsl:element> 
																</div>
															</xsl:element>	
															</td>
															<td class="perc">(<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%)</td>
														</tr>
													</table>
												</td>
												
											</tr>
										</table>
									
									</div>
								</div>
								<!-- Report Summary End -->
								</xsl:if>

						</div>
						<!-- left container end -->
						
						<!-- right container start -->
						<div id="sortableColumnRight" class="droptrue moveObj">
						
						<xsl:if test="1 = /CampaignList/ReportCache">
						<!-- Report Parameters Start -->
							<div class="ui-state-default sectionblock" id="section-reportParams" style="border:1px solid #FFCC00;">
								<a class="sectionSheaders" href="javascript:toggleContentBox('reportParams')"><img id="reportParams_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Report Parameters</span></a>	
								<div id="reportParams" style="display:block;">
									<table cellpadding="0" cellspacing="0" border="0" width="100%">
										<tr class="sectionContainerTbl">
											<td>
												<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
													<tr class="sectionHeaders">
														<td width="200">&#160;</td>
														<td width="">&#160;</td>
													</tr>
													<xsl:if test="/CampaignList/Campaigns/Row/Cache/StartDate!=''">
														<tr>
															<td width="150">Start Date:</td>
															<td><xsl:value-of select="/CampaignList/Campaigns/Row/Cache/StartDate"/></td>
														</tr>
													</xsl:if>
													
													<xsl:if test="/CampaignList/Campaigns/Row/Cache/EndDate!=''">
													<tr class="contentRows">
														<td width="150">End Date:</td>
														<td><xsl:value-of select="/CampaignList/Campaigns/Row/Cache/EndDate"/></td>
													</tr>
													</xsl:if>
													
													<xsl:if test="/CampaignList/Campaigns/Row/Cache/AttrName!=''">
														<tr class="contentRows">
															<td width="150">Attribute:</td>
															<td>
																<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrName"/>
																<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrOperator"/>
																<xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrValue1"/>
																<xsl:if test="/CampaignList/Campaigns/Row/Cache/AttrOperator = 'BETWEEN'">
																AND <xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrValue2"/>
																</xsl:if>
															</td>
														</tr>
													</xsl:if>
													<tr>
														<td width="150">Only Recips Owned By User?</td>
														<td>
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
											</td>
										</tr>
									</table>
								</div>
							</div>
							<!-- Report Parameters End -->
							</xsl:if>
							
						</div>
						<!-- right container end -->
				
						<div class="clearfix"><xsl:text> </xsl:text></div>

					</div>
					<!-- end main content -->
				</div>
				</xsl:when>
				<!--  End CampaignList/OnlyOne -->
				
				<!-- Start CampaignList/TotalsSecFlag -->
				<xsl:otherwise>
				<div class="wrapper">
				<div id="sortableColumnLeft" class="droptrue moveObj" style="width:100%;border:none;">
					<xsl:if test="1 = /CampaignList/TotalsSecFlag">
					<!-- Campaign Info Start -->
					<div class="ui-state-default sectionblock" id="section-CampInfo">
						<a class="sectionSheaders" href="javascript:toggleContentBox('reportCampInfo')"><img id="reportCampInfo_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Campaign Info</span></a>	
						<div id="reportCampInfo" style="display:block;">
							<table cellpadding="0" cellspacing="0" border="0" width="100%">
								<tr class="sectionContainerTbl">
									<td width="">
										<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
											<tr class="sectionHeaders">
												<td width="300">Campaign Name</td>
												<td width="150">Date</td>
												<td width="150">Total Sent</td>
												<td width="150">Bounce Backs</td>
												<td width="150">Click Throughs</td>
												<td>Unsubscribes</td>
											</tr>
											<xsl:for-each select="CampaignList/Campaigns/Row">
												<xsl:variable name="aColor">
												    <xsl:choose>
												    	<xsl:when test="position() mod 2 = 1">
												    		<xsl:text>nobg</xsl:text>
												    	</xsl:when>
												    <xsl:otherwise>contentRows</xsl:otherwise>
											    </xsl:choose>
											    </xsl:variable>
											    
											    	<tr class="{$aColor}">
												    
														<td width="">
															<xsl:element name="a">
																<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																<xsl:attribute name="href">
																	javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
																</xsl:attribute>
																<xsl:value-of select="Name"/>
															</xsl:element> (cache=<xsl:value-of select="CacheId"/>)
														</td>
														<td><xsl:value-of select="StartDate"/></td>
														<td>
															<xsl:element name="a">
																<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																<xsl:attribute name="href">
																	javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
																</xsl:attribute>
																<xsl:value-of select="Size"/>
															</xsl:element>
														</td>
														<td>
															<xsl:element name="a">
																<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																<xsl:attribute name="href">
																	javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
																</xsl:attribute>
																<xsl:value-of select="BBacks"/> 
															</xsl:element>
															(<xsl:value-of select="BBackPrc"/>%)
														</td>
														<td>
															<xsl:element name="a">
																<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																<xsl:attribute name="href">
																	javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
																</xsl:attribute>
																<xsl:value-of select="DistinctClicks"/>
															</xsl:element>
															(<xsl:value-of select="DistinctClickPrc"/>%)
														</td>
														<td>
															<xsl:element name="a">
																<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																<xsl:attribute name="href">
																	javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
																</xsl:attribute>
																<xsl:value-of select="Unsubs"/>
															</xsl:element>
															(<xsl:value-of select="UnsubPrc"/>%)
														</td>
													</tr>
											</xsl:for-each>
										</table>
									</td>
								</tr>
							</table>
						</div>
					</div>
					<!-- Campaign Info End -->
					</xsl:if>
					
					
					
					
				</div>
				</div>
				</xsl:otherwise>
				<!-- End CampaignList/TotalsSecFlag  -->
			</xsl:choose>
		</body>
		</html>
	</xsl:template>
</xsl:stylesheet>