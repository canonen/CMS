<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- <xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl"> -->

	<xsl:output method="html" indent="yes" />
	
	<xsl:template match="/">
		<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">]]></xsl:text>
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>Revotas Report</title>
			<meta http-equiv="Expires" content="0"/>
			<meta http-equiv="Caching" content=""/>
			<meta http-equiv="Pragma" content="no-cache"/>
			<meta http-equiv="Cache-Control" content="no-cache"/>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<link rel="stylesheet" media="all" type="text/css" href="http://cms.revotas.com/cms/ui/css/reset.css" />
			<link rel="stylesheet" media="all" type="text/css" href="http://cms.revotas.com/cms/ui/css/style_compressed_zaf.css" />
			<link href="http://cms.revotas.com/cms/ui/css/jqvmap.css" media="screen" rel="stylesheet" type="text/css" />
			<script type="text/javascript" src="http://cms.revotas.com/cms/ui/js/report/main_compressed_zaf.js">//</script>	
			<script src="http://cms.revotas.com/cms/ui/js/report/jquery.vmap.js" type="text/javascript">//</script>
			<script src="http://cms.revotas.com/cms/ui/js/report/jquery.vmap.world.js" type="text/javascript">//</script>
			
			<xsl:if test="1 = /CampaignList/RecipView">
			
				<xsl:variable name="geoLoc">
					<xsl:text>{</xsl:text>
					<xsl:for-each select="CampaignList/GeoLocation/Location">
					<xsl:text>"</xsl:text><xsl:value-of select="country_code"/><xsl:text>"</xsl:text>
					<xsl:text>:"</xsl:text><xsl:value-of select="count"/><xsl:text>"</xsl:text>					
					<xsl:if test="not(position() = last())">
						<xsl:text>,</xsl:text>
					</xsl:if>
					</xsl:for-each>
					<xsl:text>}</xsl:text>
				</xsl:variable>

				<script type="text/javascript">
				
					<![CDATA[
					function pop_up_win(url) {
						windowName = 'report_results_window';
						windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=700';
						ReportWin = window.open(url, windowName, windowFeatures);
					} 
					]]>
					
					

					jQuery(document).ready(function() {

						var geoLocation = <xsl:value-of select="$geoLoc"></xsl:value-of>;

						jQuery('#vmap').vectorMap({
						    map: 'world_en',
						    backgroundColor: '#84b4e4',
						    color: '#ffffff',
						    hoverOpacity: 0.7,
						    selectedColor: '#558dc5',
						    enableZoom: true,
						    showTooltip: true,
						    values: geoLocation,
						    scaleColors: ['#5ccd2a'],
						    normalizeFunction: 'polynomial',
							onLabelShow: function(event, label, code)
							{
								if(typeof geoLocation[code] !== 'undefined') {
									label.text(label.text() + ' ' + geoLocation[code] + ' Reads');
								}
							}
						});						
					});
					
					
				</script>
			</xsl:if>				
		</head>
		<body>
			
			<xsl:choose>
				<xsl:when test = "CampaignList/OnlyOne">
				<div class="wrapper">
					<div class="topLinksContainer">
						<xsl:if test="1 = /CampaignList/ReportCache">
							<xsl:element name="a">
							<xsl:attribute name="class">topLinks</xsl:attribute>
							<xsl:attribute name="href">report_cache_list.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;C=0</xsl:attribute>
								Return to Demographic or Time Reports</xsl:element>
								<xsl:comment><xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/></xsl:comment> 
						</xsl:if>
						
						<xsl:if test="/CampaignList/Campaigns/Row/Cache/StartDate!='' or /CampaignList/Campaigns/Row/Cache/EndDate!='' or /CampaignList/Campaigns/Row/Cache/AttrName!=''">
							<xsl:element name="a">
								<xsl:attribute name="class">topLinks</xsl:attribute>
								<xsl:attribute name="href">report_cache_edit.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/></xsl:attribute>
								Edit Criteria</xsl:element>
						</xsl:if>
								
						<xsl:element name="a">
							<xsl:attribute name="class">topLinks</xsl:attribute>
							<xsl:attribute name="href">report_object.jsp?act=PRNT&#38;id=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>
							</xsl:attribute>
								Export to Excel
						</xsl:element>
						
						<xsl:element name="a">
							<xsl:attribute name="class">topLinks</xsl:attribute>
							<xsl:attribute name="href">/cms/servlet/ReportToPDF</xsl:attribute>
							<xsl:attribute name="target">_blank</xsl:attribute>
								Export to PDF
						</xsl:element>

						<div class="clearfix"><xsl:text> </xsl:text></div>
					</div>
			
					<!-- start header tabs -->
					<div class="sectionTopHeader">
						<xsl:choose>
							<xsl:when test="1 = /CampaignList/ReportCache">
								<xsl:element name="a">
									<xsl:attribute name="href">report_object.jsp?act=VIEW&#38;id=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
									<span>Campaign Results</span>	 
								</xsl:element>
								<a href="javscript:void(null);" class="activeTab"><span>Demographic Or Time Report</span></a>				
							</xsl:when>
							<xsl:otherwise>
								<a href="javscript:void(null);" class="activeTab"><span>Campaign Results</span></a>
								<xsl:element name="a">
									<xsl:attribute name="href">report_cache_list.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/></xsl:attribute>
									<span>Demographic Or Time Report</span>	 
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
						
						<xsl:element name="a">
							<xsl:attribute name="href">report_time.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
							<span>Activity vs Time Report</span>	 
						</xsl:element>
						
						<xsl:if test="1 = /CampaignList/DeliveryTrackerRptFlag">
							<xsl:element name="a">
								<xsl:attribute name="href">eTrackerReport.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
								<span>Delivery Tracking</span>
							</xsl:element>
						</xsl:if>
						
						<xsl:if test="0 &lt; /CampaignList/ReportPosFlag">
							<xsl:element name="a">
								<xsl:attribute name="href">report_track.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/></xsl:attribute>
								<span>RevoTrack Results</span>
							</xsl:element>
						</xsl:if>
								
						<br class="clearfix" />
					</div>
					<!-- end header tabs -->
					
					<!-- start main content -->
					<div class="sectionBox">
						<!-- left container start -->
						<div id="sortableColumnLeft" class="droptrue moveObj">
													
							<xsl:if test="1 = /CampaignList/GeneralSecFlag">
							<!-- Report Summary Start -->
							<div class="ui-state-default sectionblock" id="section-reportSummary">
								<a class="sectionSheaders" href="javascript:toggleContentBox('reportSummaryCnt')"><img id="reportSummaryCnt_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Report Summary</span></a>	
									<div id="reportSummaryCnt" style="display:block;" class="midSizeBoxes">
									<table cellpadding="0" cellspacing="0" border="0" width="100%" class="sectionContainerTbl">
										<tr class="sectionHeadersWhite">
											<td>Campaign</td>
											<td>Sending Start</td>
											<td>Sending Finished</td>
										</tr>
										<tr class="contentRows blockborderbottom">
											<td><xsl:value-of select="CampaignList/Campaigns/Row/Name"/></td>
											<td><xsl:value-of select="CampaignList/Campaigns/Row/StartDate"/></td>
											<td><xsl:value-of select="CampaignList/Campaigns/Row/EndDate"/></td>
										</tr>
										<tr>
											<td colspan="3">
												<table cellpadding="0" cellspacing="0" border="0" width="100%">
													<tr>
														<td>
															<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
																<tr class="sectionHeaders">
																	<td>Metric</td>
																	<td>#</td>
																	<td>%</td>
																	<td>Total</td>
																</tr>
																<tr class="contentRows">
																	<td>Sent</td>
																	<td>
																		<xsl:element name="div">
																			<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																			<div class="hovercontent">																		
																			<xsl:element name="a">																			
																				<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																				<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																				<xsl:value-of select="CampaignList/Campaigns/Row/Size"/>
																			</xsl:element>
																			</div>
																		</xsl:element>
																	</td>
																	<td>100%</td>
																	<td>N/A</td>
																</tr>
																<tr>
																	<td>Bounced</td>
																	<td>
																		<xsl:element name="div">
																				<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																			<div class="hovercontent">
																			<xsl:element name="a">
																				<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																				<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																				<xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
																			</xsl:element>
																			</div>
																		</xsl:element>																		
																	</td>
																	<td><xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%</td>
																	<td>N/A</td>
																</tr>
																<tr class="contentRows">
																	<td>Received</td>
																	<td>
																		<xsl:element name="div">
																				<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																			<div class="hovercontent">
																			<xsl:element name="a">
																				<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																				<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																				<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
																			</xsl:element>
																			</div>
																		</xsl:element>
																	</td>
																	<td><xsl:value-of select="CampaignList/Campaigns/Row/ReachingPrc"/>%</td>
																	<td>N/A</td>
																</tr>
																<tr>
																	<td>Read</td>
																	<td>
																		<xsl:element name="div">
																				<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																			<div class="hovercontent">
																			<xsl:element name="a">
																				<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																				<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																				<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>
																			</xsl:element> 
																			</div>
																		</xsl:element>	
																	</td>
																	<td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%</td>
																	<td><xsl:value-of select="CampaignList/Campaigns/Row/TotalReads"/></td>
																</tr>
																<tr class="contentRows">
																	<td>Clicks</td>
																	<td>
																	<xsl:element name="div">
																			<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																		<div class="hovercontent">
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																			<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
																		</xsl:element> 
																		</div>
																	</xsl:element>																		
																	</td>
																	<td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%</td>
																	<td><xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/></td>
																</tr>
																<tr>
																	<td>Unsubs</td>
																	<td>
																	<xsl:element name="div">
																			<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>	
																		<div class="hovercontent">
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																			<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
																		</xsl:element> 
																		</div>
																	</xsl:element>	
																	</td>
																	<td><xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%</td>
																	<td>N/A</td>
																</tr>
															</table>
														</td>
														<td style="width:220px;">
															<div>
																<div id="summaryTabsContainer">
																	<a id="sumGraphLink1" href="javascript:switchGraphTab('1')" class="summaryTabsActive">Received</a>
																	<a id="sumGraphLink2" href="javascript:switchGraphTab('2')" class="summaryTabsPassive">Read</a>
																	<a id="sumGraphLink3" href="javascript:switchGraphTab('3')" class="summaryTabsPassive">Clicks</a>
																	<a id="sumGraphLink4" href="javascript:switchGraphTab('4')" class="summaryTabsPassive">Unsubs</a>
																	<br class="clearfix" />
																</div>		
																<div id="summaryTabsContent">
																	<div style="display:block;" id="sumGraph1">
																		<div id="chartContainerRecieved">
																		
																			<xsl:variable name="reclink">
																				<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chs=220x150&amp;cht=p3&amp;chco=008000|FF0000&amp;chd=t:</xsl:text><xsl:value-of select='CampaignList/Campaigns/Row/ReachingPrc'/><xsl:text>,</xsl:text><xsl:value-of select='100-CampaignList/Campaigns/Row/ReachingPrc'/><xsl:text>&amp;chdl=Received|Bounced&amp;chdlp=b&amp;chdls=000000,10</xsl:text>
																			</xsl:variable>
																			<img src="{$reclink}" width="220" height="150" alt="" />
																			
																		</div>
																		<script type="text/javascript">
																			var myChartSent = new FusionCharts("fusioncharts/Pie3D.swf", "myChartId1", "220", "150", "0", "1");
																				myChartSent.setJSONData({ 
																					"chart": { 

																						 paletteColors : "F984A1,8bba00",  
																						 bgColor : "FFFFFF",
																							 canvasbgColor : "FFFFFF",
																							 showLabels : "0",
																							 showValues : "1",
																							 showlegend : "1",
																							 legendBgColor : "FFFFFF",
																							 legendBorderColor : "DFDFDF",
																							 basefontcolor : "333333",
																							 pieRadius : "66",
																							 enableSmartLabels : "0",
																							 showpercentvalues : "1",
																							 placeValuesInside : "1",
																							 tooltipbgcolor : "FFFFFF",
																        				 	 	tooltipbordercolor : "DFDFDF"								 																			
																					},
																					"data" : [ 
																						{ "label" : "Bounced", "value" : "<xsl:value-of select="100 - CampaignList/Campaigns/Row/ReachingPrc"/>" },
																						{ "label" : "Received", "value" : "<xsl:value-of select="CampaignList/Campaigns/Row/ReachingPrc"/>" }
																					]
																			 	});
																			myChartSent.render("chartContainerRecieved");
																		</script>
																	</div>
																	<div style="display:none;" id="sumGraph2">
																		<div id="chartContainerRead">
																			<xsl:variable name="readlink">
																				<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chs=220x150&amp;cht=p3&amp;chco=3399CC|008000&amp;chd=t:</xsl:text><xsl:value-of select='100 - CampaignList/Campaigns/Row/DistinctReadPrc'/><xsl:text>,</xsl:text><xsl:value-of select='CampaignList/Campaigns/Row/DistinctReadPrc'/><xsl:text>&amp;chdl=Received|Read&amp;chdlp=b&amp;chdls=000000,10</xsl:text>
																			</xsl:variable>
																			<img src="{$readlink}" width="220" height="150" alt="" />
																		</div>
																		
																			<script type="text/javascript">
																				var myChartRead = new FusionCharts("fusioncharts/Pie3D.swf", "myChartId2", "220", "150", "0", "1");
																					myChartRead.setJSONData({ 
																						"chart": { 
																							 paletteColors : "AFD8F8,8bba00",
																							 bgColor : "FFFFFF",
																							 canvasbgColor : "FFFFFF",
																							 showLabels : "0",
																							 showValues : "1",
																							 showlegend : "1",
																							 legendBgColor : "FFFFFF",
																							 legendBorderColor : "DFDFDF",
																							 basefontcolor : "333333",
																							 pieRadius : "66",
																							 enableSmartLabels : "0",
																							 showpercentvalues : "1",
																							 placeValuesInside : "1",
																							 tooltipbgcolor : "FFFFFF",
																        				 	 	tooltipbordercolor : "DFDFDF"																			 																			
																						},		
																						"data" : [ 
																							{ "label" : "Recieved", "value" : "<xsl:value-of select="100 - CampaignList/Campaigns/Row/DistinctReadPrc"/>" },
																							{ "label" : "Read", "value" : "<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>" }
																						]
																				 	});
																				myChartRead.render("chartContainerRead");
																			</script>    
																			
																	</div>
																	<div style="display:none;" id="sumGraph3">
																		<div id="chartContainerClicks">
																			<xsl:variable name="clicklink">
																				<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chs=220x150&amp;cht=p3&amp;chco=3399CC|008000&amp;chd=t:</xsl:text><xsl:value-of select='100 - CampaignList/Campaigns/Row/DistinctClickPrc'/><xsl:text>,</xsl:text><xsl:value-of select='CampaignList/Campaigns/Row/DistinctClickPrc'/><xsl:text>&amp;chdl=Received|Click&amp;chdlp=b&amp;chdls=000000,10</xsl:text>
																			</xsl:variable>
																			<img src="{$clicklink}" width="220" height="150" alt="" />
																		</div>
																			<script type="text/javascript">
																				var myChartClicks = new FusionCharts("fusioncharts/Pie3D.swf", "myChartId3", "220", "150", "0", "1");
																					myChartClicks.setJSONData({ 
																						"chart": { 
																							 paletteColors : "F984A1,8bba00",
																							 bgColor : "FFFFFF",
																							 canvasbgColor : "FFFFFF",
																							 showLabels : "0",
																							 showValues : "1",
																							 showlegend : "1",
																							 legendBgColor : "FFFFFF",
																							 legendBorderColor : "DFDFDF",
																							 basefontcolor : "333333",
																							 pieRadius : "66",
																							 enableSmartLabels : "0",
																							 showpercentvalues : "1",
																							 placeValuesInside : "1",
																							 tooltipbgcolor : "FFFFFF",
																        				 	 	tooltipbordercolor : "DFDFDF"																			 																			
																						},
																						"data" : [ 
																							{ "label" : "No Clicks", "value" : "<xsl:value-of select="100 - CampaignList/Campaigns/Row/DistinctClickPrc"/>" },
																							{ "label" : "Clicks", "value" : "<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>" }
																						]
																				 	});
																				myChartClicks.render("chartContainerClicks");
																			</script> 
																	</div>
																	<div style="display:none;" id="sumGraph4">
																		<div id="chartContainerUnsubs">
																			<xsl:variable name="unsublink">
																				<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chs=220x150&amp;cht=p3&amp;chco=008000|FF0000&amp;chd=t:</xsl:text><xsl:value-of select='100 - CampaignList/Campaigns/Row/UnsubPrc'/><xsl:text>,</xsl:text><xsl:value-of select='CampaignList/Campaigns/Row/UnsubPrc'/><xsl:text>&amp;chdl=Received|Unsubs&amp;chdlp=b&amp;chdls=000000,10</xsl:text>
																			</xsl:variable>
																			<img src="{$unsublink}" width="220" height="150" alt="" />
																		</div>
																			<script type="text/javascript">
																				var myChartUnsub = new FusionCharts("fusioncharts/Pie3D.swf", "myChartId4", "220", "150", "0", "1");
																					myChartUnsub.setJSONData({ 
																						"chart": { 
																							 paletteColors : "AFD8F8,8bba00",
																							 bgColor : "FFFFFF",
																							 canvasbgColor : "FFFFFF",
																							 showLabels : "0",
																							 showValues : "1",
																							 showlegend : "1",
																							 legendBgColor : "FFFFFF",
																							 legendBorderColor : "DFDFDF",
																							 basefontcolor : "333333",
																							 pieRadius : "66",
																							 enableSmartLabels : "0",
																							 showpercentvalues : "1",
																							 placeValuesInside : "1",
																							 tooltipbgcolor : "FFFFFF",
																        				 	 	tooltipbordercolor : "DFDFDF"																			 																			
																						},
																						"data" : [ 
																							{ "label" : "Recieved", "value" : "<xsl:value-of select="100 - CampaignList/Campaigns/Row/UnsubPrc"/>" },
																							{ "label" : "Unsubs", "value" : "<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>" }
																						]
																				 	});
																				myChartUnsub.render("chartContainerUnsubs");
																			</script>
																	</div>
																</div>
															</div>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
									</div>
								</div>
								<!-- Report Summary End -->
								</xsl:if>
								
								<!-- Geo Location Start -->
								<div class="ui-state-default sectionblock" id="section-gelocation">
									<a class="sectionSheaders" href="javascript:toggleContentBox('reportAddmetrics')"><img id="reportAddmetrics_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Geo Location</span></a>	
									<div id="reportAddmetrics" style="display:block;" class="smallSizeBoxes">
										<div id="vmap" style="display:block;width: 100%; height: 400px;">&#160;</div>
									</div>
									<div id="reportAddmetrics" style="display:block;" class="smallSizeBoxes">
										<table cellpadding="0" cellspacing="0" border="0" width="100%">
											<tr class="sectionContainerTbl">
												<td>
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
														<tr class="sectionHeaders">
															<td>Countries</td>
															<td>Read Count</td>
														</tr>
														<xsl:for-each select="CampaignList/GeoLocation/Location">
														<xsl:if test="position() mod 2 = 0">
														<tr class="contentRows">														
															<td><xsl:value-of select="country_name"/></td>
															<td><xsl:value-of select="count"/></td>
														</tr>
														</xsl:if>
														<xsl:if test="position() mod 2 = 1">															
														<tr>														
															<td><xsl:value-of select="country_name"/></td>
															<td><xsl:value-of select="count"/></td>
														</tr>
														</xsl:if>
														</xsl:for-each>
													</table>
												</td>
											</tr>
										</table>
									</div>									
								</div>
								<!-- Geo Location End -->
								
								<!-- Agent Start -->
								<div class="ui-state-default sectionblock" id="section-agent">
									<a class="sectionSheaders" href="javascript:toggleContentBox('reportAddmetrics')"><img id="reportAddmetrics_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Agent Information</span></a>	
									<div id="reportAddmetrics" style="display:block;" class="smallSizeBoxes">
										<table cellpadding="0" cellspacing="0" border="0" width="100%">
											<tr class="sectionContainerTbl">
												<td>
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
														<tr class="sectionHeaders">
															<td>Agent</td>
															<td>Read Count</td>
														</tr>
														<xsl:for-each select="CampaignList/Agent/Brand">
														<xsl:if test="position() mod 2 = 0">
														<tr class="contentRows">														
															<td><xsl:value-of select="agent_name"/></td>
															<td><xsl:value-of select="agent_read_count"/></td>
														</tr>
														</xsl:if>
														<xsl:if test="position() mod 2 = 1">															
														<tr>														
															<td><xsl:value-of select="agent_name"/></td>
															<td><xsl:value-of select="agent_read_count"/></td>
														</tr>
														</xsl:if>
														</xsl:for-each>
													</table>
												</td>
											</tr>
										</table>
									</div>									
								</div>
								<!-- Agent End -->
								
								<xsl:if test="1 = /CampaignList/DistClickSecFlag">
								<!-- Detailed ClickedThrues Unique Start -->
								<div class="ui-state-default sectionblock" id="section-DetailedClickedUnique">
									<a class="sectionSheaders" href="javascript:toggleContentBox('reportDetailedClickedUnique')"><img id="reportDetailedClickedUnique_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Detailed Click Throughs (Unique)</span></a>	
									<div id="reportDetailedClickedUnique" style="display:block;" class="bigSizeBoxes">
										<table cellpadding="0" cellspacing="0" border="0" width="100%">
											<tr class="sectionContainerTbl">
												<td>
												
												<xsl:variable name="jsonDataLinks">
													<xsl:for-each select="CampaignList/Campaigns/Row/Links">
														<xsl:text>{ "label" : "</xsl:text><xsl:value-of select="translate(LinkName,translate(LinkName,'&#231;&#305;&#287;&#246;&#351;&#252;&#199;&#304;&#208;&#214;&#350;&#220;abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ',''),'')"/><xsl:text>" },</xsl:text>
													</xsl:for-each>
												</xsl:variable>
												
												

												
												<xsl:variable name="jsonDataLinksHTMLClicks">
													<xsl:for-each select="CampaignList/Campaigns/Row/Links">
														<xsl:text>{ "value" : "</xsl:text><xsl:value-of select="(DistinctHTMLPrc * DistinctClickPrc) div 100"/><xsl:text>" },</xsl:text>
													</xsl:for-each>
												</xsl:variable>
												
												<xsl:variable name="jsonDataLinksTextClicks">
													<xsl:for-each select="CampaignList/Campaigns/Row/Links">
														<xsl:text>{ "value" : "</xsl:text><xsl:value-of select="(DistinctTextPrc * DistinctClickPrc) div 100"/><xsl:text>" },</xsl:text>
													</xsl:for-each>
												</xsl:variable>
												
												<xsl:variable name="TotalNumOfLinks">
													    <xsl:value-of select="count(CampaignList/Campaigns/Row/Links) * 25"/>
												</xsl:variable>
												
												<xsl:variable name="TotalNumOfLinksurl">
													    <xsl:value-of select="count(CampaignList/Campaigns/Row/Links) * 25"/>
												</xsl:variable>
												
												<div style="margin-bottom:10px;">
												<div id="clickthrueuniqgraph">
													
													
													<xsl:variable name="detailedClickLabels">
														<xsl:for-each select="CampaignList/Campaigns/Row/Links">
														<xsl:sort select="position()" data-type="number" order="descending"/>
													    		<xsl:value-of select="LinkName"/>
													    		<xsl:if test="not(position() = last())">
													    			<xsl:text>|</xsl:text>
													    		</xsl:if>
														</xsl:for-each>
													</xsl:variable>
													
													<xsl:variable name="detailedClickHTMLValues">
														<xsl:for-each select="CampaignList/Campaigns/Row/Links">
													    		<xsl:value-of select="DistinctHTML"/>
													    		<xsl:if test="not(position() = last())">
													    			<xsl:text>,</xsl:text>
													    		</xsl:if>
														</xsl:for-each>
													</xsl:variable>
													
													<xsl:variable name="detailedClickTextValues">
														<xsl:for-each select="CampaignList/Campaigns/Row/Links">
													    		<xsl:value-of select="DistinctText"/>
													    		<xsl:if test="not(position() = last())">
													    			<xsl:text>,</xsl:text>
													    		</xsl:if>
														</xsl:for-each>
													</xsl:variable>
													
													<xsl:variable name="detailedClickLink">
														<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chxl=0:|0|20|40|60|80|100|1:|</xsl:text><xsl:value-of select='$detailedClickLabels'/><xsl:text>&amp;chxs=0,000000,10,0,l,676767|1,000000,10,0,l,676767&amp;chxt=x,y&amp;chbh=14,10,10&amp;chs=450x</xsl:text><xsl:value-of select="$TotalNumOfLinksurl"></xsl:value-of><xsl:text></xsl:text><xsl:text>&amp;cht=bhs&amp;chco=3399CC,80C65A&amp;chd=t:</xsl:text><xsl:value-of select='$detailedClickTextValues'/><xsl:text>|</xsl:text><xsl:value-of select='$detailedClickHTMLValues'/><xsl:text>&amp;chdlp=b&amp;chg=20,20,2,2&amp;chm=N,000000,0,-1,11|N,000000,1,-1,11,1</xsl:text>
													</xsl:variable>
													
													<img src="{$detailedClickLink}" alt="" />
													
												</div>
													<script type="text/javascript">
						
															var myChartcl = new FusionCharts("fusioncharts/StackedBar2D.swf", "myChartId5", "100%", "<xsl:value-of select="$TotalNumOfLinks + 60"></xsl:value-of>", "0", "1");
																myChartcl.setJSONData({
																    "chart": {
																    	useroundedges :"1",
																        showvalues : "0",
																        showborder : "0",
																     	tooltipbgcolor : "ffffff",
																        tooltipbordercolor : "f9f9f9",
																        plotborderdashed : "1",
																        plotborderdashlen : "2",
																        plotborderdashgap : "2",
																		bgColor : "FFFFFF, FFFFFF",
																		bgAlpha : "100,100",
																		canvasbgColor : "FFFFFF",
																        basefontcolor : "333333",
																        alternatevgridcolor : "40b8fd",
																        formatNumber : "0",
																		numberPrefix : "%",
																        formatNumberScale : "0",
																        showCanvasBase : "0",
																        legendBgColor : "ffffff",
																		legendBorderColor : "f9f9f9",
																		rotateValues : "1"
																    },
																    "categories": [
																        {
																            "category": [
																            	<xsl:value-of select="$jsonDataLinks"></xsl:value-of>
																            ]
																        }
																    ],
																    "dataset": [
																        {
																            "seriesname": "Text",
																            "color": "0080C0",
																            "data": [
																                <xsl:value-of select="$jsonDataLinksTextClicks"></xsl:value-of>
																            ]
																        },
																        {
																            "seriesname": "HTML",
																            "color": "F6BD0F",
																            "data": [
																                <xsl:value-of select="$jsonDataLinksHTMLClicks"></xsl:value-of>
																            ]
																        }
																    ]
																});
															myChartcl.render("clickthrueuniqgraph");
														</script>
												
												</div>
						
													<div style="position:relative;">
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
														<tr class="sectionHeaders">
															<td style="width:100px">Name</td>
															<td style="width:100px">Clicks</td>
															<td style="width:100px">Text</td>
															<td style="width:100px">HTML</td>
															<td style="width:100px">%</td>
														</tr>
														<tr>
															<td colspan="5" style="padding:0">
																<div class="lessmoreContentMore" id="lessMoreContentreportDetailedClickedUnique">
																	<table cellpadding="0" width="100%" cellspacing="0" border="0">
																		<tr style="display:none;">
																			<td colspan="5"> </td>
																		</tr>
																		<xsl:for-each select="CampaignList/Campaigns/Row/Links">
																			
																			<xsl:variable name="aColor">
																			    <xsl:choose>
																			    	<xsl:when test="position() mod 2 = 1">
																			    		<xsl:text>nobg</xsl:text>
																			    	</xsl:when>
																			    	<xsl:otherwise>contentRows</xsl:otherwise>
																		    	</xsl:choose>
																		    </xsl:variable>

														    				<tr class="{$aColor}">
																				<td style="width:100px"><xsl:value-of select="LinkName"/></td>
																				<td style="width:100px">
																					
																						<div class="hovercontent">																		
																							<xsl:element name="a">
																								<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																								</xsl:attribute>
																								<xsl:value-of select="DistinctClicks"/>
																							</xsl:element>
																						</div>
																					
																				</td>
																				<td style="width:100px">
																					<xsl:element name="div">
																					
																						<div class="hovercontent">																		
																							<xsl:element name="a">
																								<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																								</xsl:attribute>
																								<xsl:value-of select="DistinctText"/>
																							</xsl:element>
																						</div>
																					</xsl:element>
																				</td>
																				<td style="width:100px">
																					<xsl:element name="div">
																					
																						<div class="hovercontent">																		
																							<xsl:element name="a">
																								<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																								<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																								</xsl:attribute>
																								<xsl:value-of select="DistinctHTML"/>
																							</xsl:element>
																						</div>
																					</xsl:element>
																				</td>
																				<td style="width:100px"><xsl:value-of select="DistinctClickPrc"/>%</td>
																			</tr>
																		</xsl:for-each>
																		
																	</table>
																</div>
															</td>
														</tr> 
													</table>
													<div class="lessmoreBtn">
														<a href="javascript:toggleClickThrue('lessmoreContentLess','reportDetailedClickedUnique','bigSizeBoxes')"><img src="http://www.revotas.com/br_down_icon16.png" style="border:none;" alt=""  /></a> 
														<a href="javascript:toggleClickThrue('lessmoreContentMore','reportDetailedClickedUnique','bigSizeBoxes')"><img src="http://www.revotas.com/br_up_icon16.png" style="border:none;" alt=""  /></a>
													</div>
													</div>
												</td>
											</tr>
										</table>
									</div>
								</div>
								<!-- Detailed ClickedThrues Unique End -->
								</xsl:if>
								
								<xsl:if test="1 = /CampaignList/TotClickSecFlag">
								<!-- Detailed ClickedThrues Agree Start -->
								<div class="ui-state-default sectionblock" id="section-DetailedClickedAgg">
									<a class="sectionSheaders" href="javascript:toggleContentBox('reportDetailedClickedAgg')"><img id="reportDetailedClickedAgg_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Detailed Click Throughs (Aggregate)</span></a>	
									<div id="reportDetailedClickedAgg" style="display:block;" class="smallSizeBoxes">
										<table cellpadding="0" cellspacing="0" border="0" width="100%">
											<tr class="sectionContainerTbl">
												<td>
													<div style="position:relative;">
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
														<tr class="sectionHeaders">
															<td style="width:100px">Name</td>
															<td style="width:100px">Clicks</td>
															<td style="width:100px">Text</td>
															<td style="width:100px">HTML</td>
															<td style="width:100px">%</td>
														</tr>
														<tr>
															<td colspan="5" style="padding:0">
																<div class="lessmoreContentMore" id="lessMoreContentreportDetailedClickedAgg">
																	<table cellpadding="0" width="100%" cellspacing="0" border="0">
																		<xsl:for-each select="CampaignList/Campaigns/Row/Links">
																			
																			<xsl:variable name="aColor">
																			    <xsl:choose>
																			    	<xsl:when test="position() mod 2 = 1">
																			    		<xsl:text>nobg</xsl:text>
																			    	</xsl:when>
																			    	<xsl:otherwise>contentRows</xsl:otherwise>
																		    	</xsl:choose>
																		    </xsl:variable>
																		    
														    				<tr class="{$aColor}">
																					<td style="width:100px"><xsl:value-of select="LinkName"/></td>
																					<td style="width:100px">
																						<xsl:element name="div">
																						<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																						<div class="hovercontent">																		
																							<xsl:element name="a">
																							<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																							</xsl:attribute>
																							<xsl:value-of select="TotalClicks"/>
																						</xsl:element>
																						</div>
																					</xsl:element>

																					</td>
																					<td style="width:100px">
																					<xsl:element name="div">
																						<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																						<div class="hovercontent">																		
																							<xsl:element name="a">
																							<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																							<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																							</xsl:attribute>
																							<xsl:value-of select="TotalText"/>
																						</xsl:element>
																						</div>
																					</xsl:element>
																					</td>
																					<td style="width:100px">
																						<xsl:element name="div">
																							<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																							<div class="hovercontent">																		
																								<xsl:element name="a">
																									<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																									<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																									</xsl:attribute>
																									<xsl:value-of select="TotalHTML"/>
																								</xsl:element>
																							</div>
																						</xsl:element>
																					</td>
																					<td style="width:100px"><xsl:value-of select="TotalClickPrc"/>%</td>
																				</tr>
																		</xsl:for-each>
																	</table>
																</div>
															</td>
														</tr> 
													</table>
													<div class="lessmoreBtn">
														<a href="javascript:toggleClickThrue('lessmoreContentLess','reportDetailedClickedAgg','smallSizeBoxes')"><img src="http://www.revotas.com/br_down_icon16.png" style="border:none;" alt=""  /></a> 
														<a href="javascript:toggleClickThrue('lessmoreContentMore','reportDetailedClickedAgg','smallSizeBoxes')"><img src="http://www.revotas.com/br_up_icon16.png" style="border:none;" alt=""  /></a>
													</div>
													</div>
												</td>
											</tr>
										</table>
									</div>
								</div>
								<!-- Detailed ClickedThrues Aggre End -->
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
							
							<xsl:if test="1 = /CampaignList/BBackSecFlag">
								<!-- Bounceback Categories Start -->
								<div class="ui-state-default sectionblock" id="section-bouncebackCategories">
									<a class="sectionSheaders" href="javascript:toggleContentBox('reportBbacksCnt')"><img id="reportBbacksCnt_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Bounceback Categories</span></a>	
									<div id="reportBbacksCnt" style="display:block;" class="midSizeBoxes">
										<table cellpadding="0" cellspacing="0" border="0" width="100%">
											<tr class="sectionContainerTbl">
												<td>
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
														<tr class="sectionHeaders">
															<td></td>
															<td>#</td>
															<td>%</td>
														</tr>
														<tr class="contentRows">
															<td>Total Bounceback</td>
															<td>
																<xsl:element name="div">
																	<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																	<div class="hovercontent">																		
																	<xsl:element name="a">
																		<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																		<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																		</xsl:attribute>
																		<xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
																	</xsl:element>
																	</div>
																</xsl:element>
															</td>
															<td>100%</td>
														</tr>
														
														<xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
														
															<xsl:variable name="aColor">
															    <xsl:choose>
															    	<xsl:when test="position() mod 2 = 1">
															    		<xsl:text>nobg</xsl:text>
															    	</xsl:when>
															    	<xsl:otherwise>contentRows</xsl:otherwise>
														    	</xsl:choose>
														    </xsl:variable>
																	    
															<tr class="{$aColor}">
																<td><xsl:value-of select="CategoryName"/></td>
																<td>
																	<xsl:element name="div">
																		<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																		<div class="hovercontent">																		
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampID"/>&#38;B=<xsl:value-of select="CategoryID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																			</xsl:attribute>
																			<xsl:value-of select="BBacks"/>
																		</xsl:element>
																		</div>
																	</xsl:element>
																</td>
																<td><xsl:value-of select="BBackPrc"/></td>
															</tr>

														</xsl:for-each>														
													</table>
												</td>
												<td style="width:220px;">
												
													<xsl:variable name="bounceCatNames">
														<xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
														<xsl:sort select="position()" data-type="number" order="descending"/>
															<xsl:text>|</xsl:text>
													    		<xsl:value-of select="CategoryName"/>
														</xsl:for-each>
													</xsl:variable>
													
													<xsl:variable name="bounceCatValues">
														<xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
													    		<xsl:value-of select="BBackPrc"/>
													    		<xsl:if test="not(position() = last())">
													    			<xsl:text>,</xsl:text>
													    		</xsl:if>
														</xsl:for-each>
													</xsl:variable>
													
													<xsl:variable name="bouncebackCatLinks">
														<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chxl=0:|%250|%2520|%2540|%2560|%2580|%25100|1:</xsl:text><xsl:value-of select='$bounceCatNames'/><xsl:text>&amp;chxs=0,000000,10,0,l,676767|1,000000,10,0,l,676767&amp;chxt=x,y&amp;chbh=14,10,10&amp;chs=300x150&amp;cht=bhs&amp;chco=3399CC&amp;chd=t:</xsl:text><xsl:value-of select='$bounceCatValues'/><xsl:text>&amp;chdlp=b&amp;chg=20,20,2,2&amp;chm=N%25,CCCCCC,0,-1,10</xsl:text>
													</xsl:variable>
													
													<div id="chart3div">
														<img src="{$bouncebackCatLinks}" alt="" />
													</div>
													
													<xsl:variable name="jsonData">
														<xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
															<xsl:text>{ "label" : "</xsl:text>
													    		<xsl:value-of select="CategoryName"/>
													    	<xsl:text>", "value" : "</xsl:text>
													    		<xsl:value-of select="BBackPrc"/>
															<xsl:text>" },</xsl:text>
														</xsl:for-each>
													</xsl:variable>
													
													<script type="text/javascript">
														var myChart2 = new FusionCharts("fusioncharts/Bar2D.swf", "myChartId6", "220", "200", "0", "1");
															myChart2.setJSONData({
															    "chart": {
															        "useroundedges": "1",
															        "showborder": "0",
															        "bgColor" : "f9f9f9",
															        "bgAlpha" : "100",
															        "bgRatio" : "50,50",
															        "basefontcolor": "333333",
															        "alternatevgridcolor": "40b8fd",
															        "tooltipbgcolor": "ffffff",
															        "tooltipbordercolor": "f9f9f9",
															        "plotborderdashed": "1",
															        "plotborderdashlen": "2",
															        "plotborderdashgap": "2",
															        "labelDisplay" : "WRAP",
															        "canvasbgColor" : "f9f9f9",
															        "showLabels" : "0",
															        "formatNumber" : "0",
															        "formatNumberScale" : "0",
															        "numberPrefix" : "%"
															    },
															    "data": [
															    	<xsl:value-of select="$jsonData"></xsl:value-of>
															    ]
																});
															myChart2.render("chart3div");
													</script>
											
												</td>
											</tr>
										</table>
									</div>
								</div>
								<!-- Bounceback Categories End -->
							</xsl:if>
							
						<xsl:if test="count(CampaignList/Campaigns/Row/Domains) &gt; 0">
							<xsl:if test="1 = /CampaignList/DomainFlag">
							<!-- Domain Deliverability Start -->
							<div class="ui-state-default sectionblock" id="section-domainDeliv">
								<a class="sectionSheaders" href="javascript:toggleContentBox('domainDeliv')"><img id="domainDeliv_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Domain Deliverability</span></a>	
								<div id="domainDeliv" style="display:block;" class="bigSizeBoxes">
									<table cellpadding="0" cellspacing="0" border="0" width="100%">
										<tr>
											<td>
												
												<table cellpadding="0" cellspacing="0" border="0" width="100%">
													<tr class="sectionContainerTbl">
														<td valign="top">
															<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
																<tr class="sectionHeaders">
																	<td colspan="2">Top 5 Domains</td>
																</tr>
																<xsl:for-each select="CampaignList/Campaigns/Row/Domains">
																
																<xsl:variable name="aColor">
																    <xsl:choose>
																    	<xsl:when test="position() mod 2 = 1">
																    		<xsl:text>nobg</xsl:text>
																    	</xsl:when>
																    <xsl:otherwise>contentRows</xsl:otherwise>
															    </xsl:choose>
															    </xsl:variable>
															    												    
																<xsl:if test="position() &lt; = 5">
																	<tr class="{$aColor}">
																		<td><xsl:value-of select="Domain"/></td>
																		<td><xsl:value-of select="Reads"/>(<xsl:value-of select="ReadPrc"/>%) Reads</td>
																	</tr>	
																</xsl:if>
																</xsl:for-each>
															</table>
														</td>
														<td valign="top" width="220">
															<div id="chartContainer342">
															
																<xsl:variable name="domainDelivValues">
																	<xsl:for-each select="CampaignList/Campaigns/Row/Domains">
																		<xsl:if test="position() &lt; = 5">
																    		<xsl:value-of select="Reads"/>
																    		<xsl:if test="position() &lt; 5">
																    			<xsl:text>,</xsl:text>
																    		</xsl:if>
																    	</xsl:if>
																	</xsl:for-each>
																</xsl:variable>
																
																<xsl:variable name="domainDelivLabels">
																	<xsl:for-each select="CampaignList/Campaigns/Row/Domains">
																		<xsl:if test="position() &lt; = 5">
																    		<xsl:value-of select="Domain"/>
																    		<xsl:if test="position() &lt; 5">
																    			<xsl:text>|</xsl:text>
																    		</xsl:if>
																    	</xsl:if>
																	</xsl:for-each>
																</xsl:variable>
															
																<xsl:variable name="domaindelivlink">
																	<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chs=300x150&amp;cht=p3&amp;chco=008000|FF0000|3399CC|FF9900|C2BDDD&amp;chds=0,10000&amp;chd=t:</xsl:text><xsl:value-of select='$domainDelivValues'/><xsl:text>&amp;chdl=</xsl:text><xsl:value-of select='$domainDelivLabels'/><xsl:text>&amp;chdlp=b&amp;chdls=000000,10</xsl:text>
																</xsl:variable>
																<img src="{$domaindelivlink}" width="300" height="150" alt="" />
															</div>    
															
															<xsl:variable name="jsonDataDomains">
																<xsl:for-each select="CampaignList/Campaigns/Row/Domains">
																	<xsl:if test="position() &lt; = 5">
																		<xsl:text>{ "label" : "</xsl:text>
																    		<xsl:value-of select="Domain"/>
																    	<xsl:text>", "value" : "</xsl:text>
																    		<xsl:value-of select="Reads"/>
																		<xsl:text>" },</xsl:text>
																	</xsl:if>
																</xsl:for-each>
															</xsl:variable>
															<script type="text/javascript">
																var myChart22d = new FusionCharts("fusioncharts/Pie3D.swf", "myChartId72", "220", "150", "0", "1");
																	myChart22d.setJSONData({ 
																		"chart": { 
																			 paletteColors : "228b22,b8860b,6495ed,eedfcc,202020,494949",
																			 basefontcolor : "333333",
																			 bgColor : "ffffff",
																			 canvasbgColor: "ffffff",
																			 showLabels : "0",
																			 showValues : "0",
																			 pieRadius : "95",
																			 enableSmartLabels : "0",
																			 showpercentvalues : "1",
																			 tooltipbgcolor : "ffffff",
													        				 tooltipbordercolor : "f9f9f9"																 																			
																		},
																		"data" : [ 
																		<xsl:value-of select="$jsonDataDomains"></xsl:value-of>
																		]
																	});
																myChart22d.render("chartContainer342");
															</script>
														</td>
													</tr>
												</table>
					
											</td>
										</tr>
										<tr class="sectionContainerTbl">
											<td>
											
												<div style="position:relative;">
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
														<tr class="sectionHeaders">
															<td width="90">Domain</td>
															<td width="60">Sent</td>
															<td width="60">Bounced</td>
															<td width="60">Read</td>
															<td width="60">Click</td>
															<td width="60">Unsub</td>
															<td width="60">Spam</td>
														</tr>
														<tr>
															<td colspan="7" style="padding:0">
																<div class="lessmoreContentMore" id="lessMoreContentdomainDeliv">
																	<table cellpadding="0" width="100%" cellspacing="0" border="0">
																	<tr style="display:none;"><td colspan="7"></td></tr>
																	<xsl:for-each select="CampaignList/Campaigns/Row/Domains">
																	
																		<xsl:variable name="aColor">
																		    <xsl:choose>
																		    	<xsl:when test="position() mod 2 = 1">
																		    		<xsl:text>nobg</xsl:text>
																		    	</xsl:when>
																		    	<xsl:otherwise>contentRows</xsl:otherwise>
																	    	</xsl:choose>
																	    </xsl:variable>
																    
																		<tr class="{$aColor}">
																			<td width="90"><xsl:value-of select="Domain"/></td>
																			<td width="60">
																				<xsl:element name="a">
																					<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																					<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainsent&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
																					<xsl:value-of select="Sent"/>
																				</xsl:element>
																			</td>
																			<td width="60">
																				<xsl:element name="a">
																					<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																					<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainbbk&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																					</xsl:attribute>
																					<xsl:value-of select="BBacks"/></xsl:element>(<xsl:value-of select="BBackPrc"/>%)
																			</td>
																			<td width="60">
																				<xsl:element name="a">
																					<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																					<xsl:attribute name="href">
																						javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainread&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																					</xsl:attribute>
																					<xsl:value-of select="Reads"/>
																				</xsl:element>(<xsl:value-of select="ReadPrc"/>%)
																			</td>
																			<td width="60">
																				<xsl:element name="a">
																					<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																					<xsl:attribute name="href">
																						javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainclick&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																					</xsl:attribute>
																					<xsl:value-of select="Clicks"/>
																				</xsl:element>(<xsl:value-of select="ClickPrc"/>%)
																			</td>
																			<td width="60">
																				<xsl:element name="a">
																					<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																					<xsl:attribute name="href">
																						javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainunsub&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																					</xsl:attribute>
																					<xsl:value-of select="Unsubs"/>
																				</xsl:element>(<xsl:value-of select="UnsubPrc"/>%)
																			</td>
																			<td width="60">
																				<xsl:element name="a">
																					<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																					<xsl:attribute name="href">
																						javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainspam&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																					</xsl:attribute>
																					<xsl:value-of select="UnsubsSpam"/>
																				</xsl:element>(<xsl:value-of select="UnsubsSpamPrc"/>%)
																			</td>
																		</tr>
																	</xsl:for-each>
																	</table>
																</div>
															</td>
														</tr> 
													</table>
													<div class="lessmoreBtn">
														<a href="javascript:toggleClickThrue('lessmoreContentLess','domainDeliv','bigSizeBoxes')"><img src="http://www.revotas.com/br_down_icon16.png" style="border:none;" alt=""  /></a> 
														<a href="javascript:toggleClickThrue('lessmoreContentMore','domainDeliv','bigSizeBoxes')"><img src="http://www.revotas.com/br_up_icon16.png" style="border:none;" alt=""  /></a>
													</div>
												</div>
											</td>
										</tr>
									</table>
								</div>
							</div>
							<!-- Domain Deliverability End -->	
							</xsl:if>	
						</xsl:if>
							
							
						<xsl:if test="1 = /CampaignList/BBackSecFlag">
								<!-- Unsubscriptions Start -->
								<div class="ui-state-default sectionblock" id="section-unsubs">
									<a class="sectionSheaders" href="javascript:toggleContentBox('reportUnsub')"><img id="reportUnsub_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Unsubscribe Categories</span></a>	
									<div id="reportUnsub" style="display:block;" class="smallSizeBoxes">
										<table cellpadding="0" cellspacing="0" border="0" width="100%">
											<tr class="sectionContainerTbl">
												<td>
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
														<tr class="sectionHeaders">
															<td></td>
															<td># Unique</td>
															<td>% Percent</td>
														</tr>
														<tr class="contentRows">
															<td>Total Unsubscribes</td>
															<td>
																<xsl:element name="div">
																<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																	<div class="hovercontent">																		
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																			</xsl:attribute>
																			<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
																		</xsl:element>
																	</div>
																</xsl:element>
															</td>
															<td>100%</td>
														</tr>
														<xsl:if test="count(CampaignList/Campaigns/Row/Unsub) &gt; 0">
														<xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
															<xsl:variable name="aColor">
															    <xsl:choose>
															    	<xsl:when test="position() mod 2 = 1">
															    		<xsl:text>nobg</xsl:text>
															    	</xsl:when>
															    	<xsl:otherwise>contentRows</xsl:otherwise>
														    	</xsl:choose>
														    </xsl:variable>
																	    
															<tr class="{$aColor}">
																<td><xsl:value-of select="LevelName"/></td>
																<td>
																	<xsl:element name="div">
																	<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																		<div class="hovercontent">																		
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsublevel&#38;Q=<xsl:value-of select="CampID"/>&#38;S=<xsl:value-of select="LevelID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																			</xsl:attribute>
																			<xsl:value-of select="Unsubs"/>
																		</xsl:element>
																		</div>
																	</xsl:element>
																</td>
																<td><xsl:value-of select="UnsubsPrc"/>%</td>
															</tr>	
															
														</xsl:for-each>
														</xsl:if>
													</table>
												</td>
												<td style="width:220px;">
															<xsl:if test="count(CampaignList/Campaigns/Row/Unsub) &gt; 0">
															<xsl:variable name="jsonDataUnsubs">
																<xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
																	<xsl:text>{ "value" : "</xsl:text>
																    	<xsl:value-of select="Unsubs"/>	
																    	<xsl:text>", "label":"</xsl:text><xsl:value-of select="LevelName"/><xsl:text>" },</xsl:text>
																</xsl:for-each>
															</xsl:variable>
															
															<xsl:variable name="unsubvalues">
																<xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
														    		<xsl:value-of select="Unsubs"/>
														    		<xsl:if test="not(position() = last())">
														    			<xsl:text>|</xsl:text>
														    		</xsl:if>
																</xsl:for-each>
															</xsl:variable>
															
															<xsl:variable name="unsublabels">
																<xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
														    		<xsl:value-of select="LevelName"/>
														    		<xsl:if test="not(position() = last())">
														    			<xsl:text>|</xsl:text>
														    		</xsl:if>
																</xsl:for-each>
															</xsl:variable>
														
															<xsl:variable name="unsublink">
																<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chxl=1:|%250|%2525|%2550|%2575|%25100&amp;chxs=0,676767,10|1,FFFFFF,10,0,l,676767&amp;chxt=x,y&amp;chs=300x150&amp;cht=gm&amp;chco=FFCC33,FFFFFF,008000|80C65A|FFCC33|FFFF88|FF0000|AA0033&amp;chd=t:</xsl:text><xsl:value-of select='$unsubvalues'/><xsl:text>&amp;chl=</xsl:text><xsl:value-of select='$unsublabels'/>
															</xsl:variable>
															
													
															<div id="unsubgraph">
																<img src="{$unsublink}" width="300" height="150" alt="" />
															</div>
															
															<script type="text/javascript">
																	var myChartunsub = new FusionCharts("fusioncharts/Doughnut3D.swf", "myChartId8", "320", "135", "0", "1");
																		myChartunsub.setJSONData({
																		    "chart": {
																		        bgColor : "ffffff",
																		        showLabels : "0",
																				showValues : "0",
																				showlegend: "0",
																				basefontcolor : "333333",
																				enebleSmartLabels : "0",
																				showlegend: "1",
																				legendBgColor : "ffffff",
																				legendBorderColor : "f9f9f9",
																				pieRadius : "85",
																				enableSmartLabels : "0",
																				showpercentvalues : "1",
																				placeValuesInside : "1",
																				tooltipbgcolor : "ffffff",
														        				tooltipbordercolor : "f9f9f9"	
																		    },
																		    "data": [
																		        <xsl:value-of select="$jsonDataUnsubs"></xsl:value-of>
																		    ]
																		});
																	myChartunsub.render("unsubgraph");
																</script>
															</xsl:if>
												</td>
											</tr>
										</table>
									</div>
								</div>
								<!-- Unsubscriptions End -->
								</xsl:if>	
							
							
							
							
							
							
							
							
							
							
							
							
							<xsl:if test="1 = /CampaignList/OptoutFlag">
							<!-- Newsletter Opt-outs Start -->
							<div class="ui-state-default sectionblock" id="section-optouts">
								<a class="sectionSheaders" href="javascript:toggleContentBox('reportOptouts')"><img id="reportOptouts_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Newsletter Optouts</span></a>	
								<div id="reportOptouts" style="display:block;" class="smallSizeBoxes">
									<table cellpadding="0" cellspacing="0" border="0" width="100%">
										<tr class="sectionContainerTbl">
											<td>
												<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
													<tr class="sectionHeaders">
														<td></td>
														<td># Unique</td>
													</tr>
													<tr class="contentRows">
														<td>Total Reaching</td>
														<td>
															<xsl:element name="div">
															<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																<div class="hovercontent">																		
																<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">
																		javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
																</xsl:element>
																</div>
															</xsl:element>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</div>
							</div>
							<!-- Newsletter Opt-outs End -->
							</xsl:if>	
							
							<xsl:if test="1 = /CampaignList/FormSecFlag">
							<!-- form submissions start -->
							<div class="ui-state-default sectionblock" id="section-formSubmissions">
								<a class="sectionSheaders" href="javascript:toggleContentBox('reportFormSubmissions')"><img id="reportFormSubmissions_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Form Submissions</span></a>	
								<div id="reportFormSubmissions" style="display:block;" class="smallSizeBoxes">
									<table cellpadding="0" cellspacing="0" border="0" width="100%">
										<tr class="sectionContainerTbl">
											<td>
												<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
													<tr class="sectionHeaders">
														<td>Form Name</td>
														<td>Page Views</td>
														<td>Submissions</td>
														<td>Multiple Times</td>
														<td>Submit</td>
													</tr>
													
													<xsl:for-each select="CampaignList/Campaigns/Row/Forms">
														<tr class="contentRows">
															<td><xsl:value-of select="FirstFormName"/></td>
															<td>
																<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=view&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="FirstFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="DistinctViews"/>
																</xsl:element>
															</td>
															<td>
																<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=submit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="DistinctSubmits"/>
																</xsl:element>
																(<xsl:value-of select="DistinctViewSubmitPrc"/>%)
															</td>
															<td>
																<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multisubmit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="MultiSubmitters"/>
																</xsl:element>
															</td>
															<td><xsl:value-of select="LastFormName"/></td>
														</tr>
													</xsl:for-each>														
													<tr class="sectionHeaders">
														<td>Form Name</td>
														<td>Page Views</td>
														<td>Submissions</td>
														<td>Multiple Times</td>
														<td>Submit</td>
													</tr>
													
													<xsl:for-each select="CampaignList/Campaigns/Row/Forms">
														<tr class="contentRows">
															<td><xsl:value-of select="FirstFormName"/></td>
															<td>
																<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=view&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="FirstFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="TotalViews"/>
																</xsl:element>
															</td>
															<td>
																<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=submit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="TotalSubmits"/>
																</xsl:element>
																(<xsl:value-of select="TotalViewSubmitPrc"/>%)
															</td>
															<td>
																<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multisubmit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="MultiSubmitters"/>
																</xsl:element>
															</td>
															<td><xsl:value-of select="LastFormName"/></td>
														</tr>
													</xsl:for-each>
												</table>
											</td>
										</tr>
									</table>
								</div>
							</div>
							<!-- form submissions end -->
								
							</xsl:if>

							
							<xsl:if test="1 = /CampaignList/DistClickSecFlag">
							<!-- Additional Metrics Start -->
							<div class="ui-state-default sectionblock" id="section-addmetrics">
								<a class="sectionSheaders" href="javascript:toggleContentBox('reportAddmetrics')"><img id="reportAddmetrics_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Additional Metrics</span></a>	
								<div id="reportAddmetrics" style="display:block;" class="smallSizeBoxes">
									<table cellpadding="0" cellspacing="0" border="0" width="100%">
										<tr class="sectionContainerTbl">
											<td>
												<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
													<tr class="sectionHeaders">
														<td></td>
														<td># Count</td>
													</tr>
													<xsl:if test="1 = /CampaignList/TotReadFlag">
														<tr class="contentRows">
															<td>Total HTML Email views</td>
															<td>
																<xsl:element name="div">
																<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																	<div class="hovercontent">																		
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																			</xsl:attribute>
																			<xsl:value-of select="CampaignList/Campaigns/Row/TotalReads"/>
																		</xsl:element>
																	</div>
																</xsl:element>
															</td>
														</tr>
													</xsl:if>
													<xsl:if test="1 = /CampaignList/MultiReadFlag">
													<tr class="contentRows">
														<td>Opened HTML Email more than once</td>
														<td>
															<xsl:element name="div">
															<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																<div class="hovercontent">																		
																	<xsl:element name="a">	
																		<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																		<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiread&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																		</xsl:attribute>
																		<xsl:value-of select="CampaignList/Campaigns/Row/MultiReaders"/>
																	</xsl:element>
																</div>
															</xsl:element>
														</td>
													</tr>
													</xsl:if>
													<xsl:if test="1 = /CampaignList/TotClickFlag">
														<tr class="contentRows">
															<td>Aggregate Clickthroughs</td>
															<td>
																<xsl:element name="div">
																<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																	<div class="hovercontent">																		
																		<xsl:element name="a">
																				<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																				<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																				</xsl:attribute>
																				<xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/>
																			</xsl:element>
																	</div>
																</xsl:element>
															</td>
														</tr>
													</xsl:if>
													<xsl:if test="1 = /CampaignList/MultiLinkClickFlag">
														<tr class="contentRows">
															<td>Clicked on more than one link</td>
															<td>
																<xsl:element name="div">
																		<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																			<div class="hovercontent">																		
																				<xsl:element name="a">
																					<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																					<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																					</xsl:attribute>
																					<xsl:value-of select="CampaignList/Campaigns/Row/MultiLinkClickers"/>
																				</xsl:element>
																	</div>
																</xsl:element>
															</td>
														</tr>
													</xsl:if>
													<xsl:if test="1 = /CampaignList/LinkMultiClickFlag">
														<tr class="contentRows">
															<td>Clicked on one link multiple times</td>
															<td>
																<xsl:element name="div">
																	<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																		<div class="hovercontent">																		
																			<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="CampaignList/Campaigns/Row/OneLinkMultiClickers"/>
																	</xsl:element>
																	</div>
																</xsl:element>
															</td>
														</tr>
													</xsl:if>
													
												</table>
											</td>
										</tr>
									</table>
								</div>
							</div>
							<!-- Additional Metrics End -->
							</xsl:if>
				
								<xsl:if test="1 = /CampaignList/ActionSecFlag">
								<!-- Reciepent Actions Start -->
								<div class="ui-state-default sectionblock" id="section-ReciepentActions">
									<a class="sectionSheaders" href="javascript:toggleContentBox('reportRecActions')"><img id="reportRecActions_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Recipient Actions</span></a>	
									<div id="reportRecActions" style="display:block;" class="smallSizeBoxes">
										<table cellpadding="0" cellspacing="0" border="0" width="100%">
											<tr class="sectionContainerTbl">
												<td>
													<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
														<tr class="sectionHeaders">
															<td></td>
															<td># Unique</td>
															<td>% Percent</td>
														</tr>
														<tr class="contentRows">
															<td>Total Reaching</td>
															<td>
																<xsl:element name="div">
																	<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																		<div class="hovercontent">																		
																		<xsl:element name="a">
																	<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																	<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																	</xsl:attribute>
																	<xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
																</xsl:element>
																	</div>
																</xsl:element>
															</td>
															<td>100%</td>
														</tr>
														<tr>
															<td>Total Open HTML</td>
															<td>
																<xsl:element name="div">
																	<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																		<div class="hovercontent">																		
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																			</xsl:attribute>
																			<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>
																		</xsl:element>
																	</div>
																</xsl:element>
															</td>
															<td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%</td>
														</tr>
														<tr class="contentRows">
															<td>Total Click Throughs</td>
															<td>
																<xsl:element name="div">
																	<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																		<div class="hovercontent">																		
																		<xsl:element name="a">
																			<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																			<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																			</xsl:attribute>
																			<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
																		</xsl:element>
																	</div>
																</xsl:element>
															</td>
															<td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%</td>
														</tr>
														<tr>
															<td>Total Unsubscribes</td>
															<td>
																<xsl:element name="div">
																	<xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
																		<div class="hovercontent">																		
																			<xsl:element name="a">
																				<xsl:attribute name="class">reportPopDetail</xsl:attribute>
																				<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
																				</xsl:attribute>
																				<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
																			</xsl:element>
																	</div>
																</xsl:element>
																

															</td>
															<td><xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%</td>
														</tr>
													</table>
												</td>
												<td style="width:220px;">

														<xsl:variable name="recActionsLink">
															<xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chxl=0:|%250|%2520|%2540|%2560|%2580|%25100|1:|Open HTML|Click Throughs|Unsubscribes&amp;chxs=0,000000,10,0,l,676767|1,000000,10,0,l,676767&amp;chxt=x,y&amp;chbh=14,10,10&amp;chs=300x100&amp;cht=bhs&amp;chco=3399CC&amp;chd=t:</xsl:text>
																<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>
																<xsl:text>,</xsl:text>
																<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>
																<xsl:text>,</xsl:text>
																<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>
															<xsl:text>&amp;chdlp=b&amp;chg=20,20,2,2&amp;chm=N%25,CCCCCC,0,-1,10</xsl:text>
														</xsl:variable>
													
														<div id="recactionsgraph">
															<img src="{$recActionsLink}" alt="" />
														</div>
														
															<script type="text/javascript">
																	var myChartrecac = new FusionCharts("fusioncharts/Bar2D.swf", "myChartId9", "220", "140", "0", "1");
																		myChartrecac.setJSONData({
																		    "chart": {
																		        "useroundedges": "1",
																		        "showborder": "0",
																		        "bgColor" : "ffffff",
																		        "bgAlpha" : "100",
																		        "bgRatio" : "50,50",
																		        "basefontcolor": "333333",
																		        "alternatevgridcolor": "40b8fd",
																		        "tooltipbgcolor": "ffffff",
																		        "tooltipbordercolor": "f9f9f9",
																		        "plotborderdashed": "1",
																		        "plotborderdashlen": "2",
																		        "plotborderdashgap": "2",
																		        "labelDisplay" : "WRAP",
																		        "canvasbgColor" : "ffffff",
																		        "showLabels" : "1",
																				"formatNumber" : "0",
																		        "formatNumberScale" : "0"
																		    },
																		    "data": [
																		        {
																		            "label": "Open HTML",
																		            "value": "<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>",
																		            "color": "AFD8F8"
																		        },
																		        {
																		            "label": "Click Throughs",
																		            "value": "<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>",
																		            "color": "F6BD0F"
																		        },
																		        {
																		            "label": "Unsubscribes",
																		            "value": "<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>",
																		            "color": "8BBA00"
																		        }
																		    ]
																		});
																	myChartrecac.render("recactionsgraph");
																</script>													
												</td>
											</tr>
										</table>
									</div>
								</div>
								<!-- Reciepent Actions End -->
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
					<xsl:if test="1 = /CampaignList/GeneralSecFlag">
					<!-- General Campaign Statistics Start -->
					<div class="ui-state-default sectionblock" id="section-GenCampStats">
						<a class="sectionSheaders" href="javascript:toggleContentBox('reportGenCampStats')"><img id="reportGenCampStats_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>General Campaign  Statistics</span></a>	
						<div id="reportGenCampStats" style="display:block;">
							<table cellpadding="0" cellspacing="0" border="0" width="100%">
								<tr class="sectionContainerTbl">
									<td width="">
										<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
											<tr class="sectionHeaders">
												<td width="300">Campaign Name</td>
												<td width="150">Total Sent</td>
												<td width="150">Total Bouncebacks</td>
												<td>Total Reaching</td>
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
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
															</xsl:attribute>
															<xsl:value-of select="Reaching"/>
														</xsl:element>
														(<xsl:value-of select="ReachingPrc"/>%)
													</td>
												</tr>
											</xsl:for-each>
										</table>
									</td>
								</tr>
							</table>
						</div>
					</div>
					<!-- General Campaign Statistics End -->
					</xsl:if>
					
					<xsl:if test="1 = /CampaignList/DistClickSecFlag">
						<!-- Detailed Clickthrough Info Start -->
						<div class="ui-state-default sectionblock" id="section-DetCTInfo">
							<a class="sectionSheaders" href="javascript:toggleContentBox('reportDetCTInfo')"><img id="reportDetCTInfo_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Detailed Clickthrough Info</span></a>	
							<div id="reportDetCTInfo" style="display:block;">
								<table cellpadding="0" cellspacing="0" border="0" width="100%">
									<tr class="sectionContainerTbl">
										<td width="">
											<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
											<xsl:for-each select="CampaignList/Campaigns/Row">
												<tr class="sectionHeaders">
													<td width="250">Campaign Name</td>
													<td width="150"># of Links</td>
													<td width="150">Total Clicks</td>
													<td width="250"># of Recipients who clicked multiple links</td>
													<td width="150">Total Text</td>
													<td>Total HTML</td>
												</tr>
												<tr class="contentRows">
													<td width="">
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
															</xsl:attribute>
															<xsl:value-of select="Name"/>
														</xsl:element>(cache=<xsl:value-of select="CacheId"/>)
													</td>
													<td><xsl:value-of select="TotalLinks"/></td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
															</xsl:attribute>
															<xsl:value-of select="DistinctClicks"/>
														</xsl:element>
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
															</xsl:attribute>
															<xsl:value-of select="MultiLinkClickers"/>
														</xsl:element>
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=T');
															</xsl:attribute>
															<xsl:value-of select="DistinctText"/>
														</xsl:element>
														(<xsl:value-of select="DistinctTextPrc"/>%)
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=H');
															</xsl:attribute>
															<xsl:value-of select="DistinctHTML"/>
														</xsl:element>
														(<xsl:value-of select="DistinctHTMLPrc"/>%)
													</td>
												</tr>
												<tr class="sectionHeaders">
													<td width="250">Link Name</td>
													<td width="150"># of Clicks</td>
													<td width="150">Text Clicks</td>
													<td width="250">HTML Clicks</td>
													<td width="150"></td>
													<td></td>
												</tr>
												<xsl:for-each select="./Links">
													<xsl:variable name="aColor">
													    <xsl:choose>
													    	<xsl:when test="position() mod 2 = 1">
													    		<xsl:text>nobg</xsl:text>
													    	</xsl:when>
													    <xsl:otherwise>contentRows</xsl:otherwise>
												    </xsl:choose>
												    </xsl:variable>
												    
												    <tr class="{$aColor}">
													<td><xsl:value-of select="LinkName"/></td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');
															</xsl:attribute>
															<xsl:value-of select="DistinctClicks"/>
														</xsl:element> (<xsl:value-of select="DistinctClickPrc"/>%)
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T');
															</xsl:attribute>
															<xsl:value-of select="DistinctText"/>
														</xsl:element>
														(<xsl:value-of select="DistinctTextPrc"/>%)
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H');
															</xsl:attribute>
															<xsl:value-of select="DistinctHTML"/>
														</xsl:element>
														(<xsl:value-of select="DistinctHTMLPrc"/>%)
													</td>
													<td></td>
													<td></td>
												</tr>
												</xsl:for-each>
											</xsl:for-each>
											</table>
										</td>
									</tr>
								</table>
							</div>
						</div>
							
						<!-- Detailed Clickthrough Info End -->
					</xsl:if>
					
					<xsl:if test="1 = /CampaignList/TotClickSecFlag">
						<!-- Additional Total Clickthrough Info Start -->
						
						<div class="ui-state-default sectionblock" id="section-AddTCInfo">
							<a class="sectionSheaders" href="javascript:toggleContentBox('reportAddTCInfo')"><img id="reportAddTCInfo_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Additional Total Clickthrough Info</span></a>	
							<div id="reportAddTCInfo" style="display:block;">
								<table cellpadding="0" cellspacing="0" border="0" width="100%">
									<tr class="sectionContainerTbl">
										<td width="">
											<table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
											<xsl:for-each select="CampaignList/Campaigns/Row">
												<tr class="sectionHeaders">
													<td width="200">Campaign Name</td>
													<td width="150"># of Links</td>
													<td width="200">Total Clicks</td>
													<td width="200"># clicked on more than one link</td>
													<td width="200"># clicked on one link multiple times</td>
													<td style="width:100px">Total Text</td>
													<td>Total HTML</td>
												</tr>
												<tr class="contentRows">
													<td width="">
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
															</xsl:attribute>
															<xsl:value-of select="Name"/>
														</xsl:element>
													</td>
													<td><xsl:value-of select="TotalLinks"/></td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
															</xsl:attribute>
															<xsl:value-of select="TotalClicks"/>
														</xsl:element>
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
															</xsl:attribute>
															<xsl:value-of select="MultiLinkClickers"/>
														</xsl:element>
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
															</xsl:attribute>
															<xsl:value-of select="OneLinkMultiClickers"/>
														</xsl:element>
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=T');
															</xsl:attribute>
															<xsl:value-of select="TotalText"/>
														</xsl:element>
														(<xsl:value-of select="TotalTextPrc"/>%)
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=H');
															</xsl:attribute>
															<xsl:value-of select="TotalHTML"/>
														</xsl:element>
														(<xsl:value-of select="TotalHTMLPrc"/>%)
													</td>
												</tr>
												<tr class="sectionHeaders">
													<td>Link Name</td>
													<td># of Clicks</td>
													<td># clicked on one link multiple times</td>
													<td>Text Clicks</td>
													<td>HTML Clicks</td>
													<td></td>
													<td></td>
												</tr>
												<xsl:for-each select="./Links">
													<xsl:variable name="aColor">
													    <xsl:choose>
													    	<xsl:when test="position() mod 2 = 1">
													    		<xsl:text>nobg</xsl:text>
													    	</xsl:when>
													    <xsl:otherwise>contentRows</xsl:otherwise>
												    </xsl:choose>
												    </xsl:variable>
												    
													<tr class="{$aColor}">
													<td><xsl:value-of select="LinkName"/></td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">
																javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');
															</xsl:attribute>
															<xsl:value-of select="TotalClicks"/>
														</xsl:element> 
														(<xsl:value-of select="TotalClickPrc"/>%)
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');
															</xsl:attribute>
															<xsl:value-of select="MultiClickers"/>
														</xsl:element>
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T');
															</xsl:attribute>
															<xsl:value-of select="TotalText"/>
														</xsl:element>
														<xsl:value-of select="TotalTextPrc"/>%
													</td>
													<td>
														<xsl:element name="a">
															<xsl:attribute name="class">reportPopDetail</xsl:attribute>
															<xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H');
															</xsl:attribute>
															<xsl:value-of select="TotalHTML"/>
														</xsl:element>
														(<xsl:value-of select="TotalHTMLPrc"/>%)
													</td>
													<td></td>
													<td></td>
												</tr>
												</xsl:for-each>
											</xsl:for-each>
											</table>
										</td>
									</tr>
								</table>
							</div>
						</div>									
						
						
						<!-- Additional Total Clickthrough Info End -->
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