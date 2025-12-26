<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.rpt.*,
			java.sql.*,java.net.*,java.io.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String	sCampID	= request.getParameter("Q");
String	sCache 	= request.getParameter("Z");
sCache = ("1".equals(sCache))?sCache:"0";
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
var showMoreOn = false;
function pop_up_win(url)
{
	windowName = 'report_results_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=750';
	ReportWin = window.open(url, windowName, windowFeatures);
}
function toggleShowMore(more)
{
	var elems = document.getElementById('twebp').getElementsByTagName('tr');
	
	if(!showMoreOn)
	{
		
		for (var i = 0; i < elems.length; i++) {
				elems[i].className = 'showMore';
		}
		document.getElementById('showMoreText').text = 'Show less';
		showMoreOn = true;
	}
	else
	{
		var l = elems.length;
		if(l < 10)
		{
			l = elems.length;
		}
		for (var i = 0; i < l; i++) 
		{
			if(i>10)
			elems[i].className = 'hideMore';
			else
			elems[i].className = 'showMore';
		}
		elems[l-1].className = 'showMore';
		document.getElementById('showMoreText').text = 'Show more';
		showMoreOn = false;
		
	}
}
</script>
<style>
.hideMore {
	display:none;
}
.showMore {
}
</style>
</HEAD>
<BODY>

<%
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	int nPos = 0;
	String reportName = "";
	String reportDate = "";

	int numRecs = 0;


	//Customize deliveryTracker report Feature (part of release 5.9)
	int showTrackerRpt = 0;
	boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
	if (bFeat)
	{
 		int nCount = getSeedListCount(stmt,cust.s_cust_id, sCampID);
		if (nCount > 0)
			showTrackerRpt = 1;
	}
	// end release 5.9
	
	if ((sCampID != null))
	{
		String sSql = 
			" SELECT count(camp_id)" +
			" FROM cque_campaign c with(nolock)" +
			" WHERE c.cust_id = " + cust.s_cust_id +
			" AND c.camp_id = " + sCampID;
			
		rs = stmt.executeQuery(sSql);
		if(rs.next()) numRecs = rs.getInt(1);
		rs.close();

		// === === ===		

		sSql = 
			" SELECT count(*)" +
			" FROM crpt_camp_pos with(nolock)" +
			" WHERE camp_id IN ("+sCampID+")";
			
		rs = stmt.executeQuery(sSql);
		if ( rs.next() ) nPos = rs.getInt(1);
		rs.close();
		
		// === === ===				

		sSql = 
			" EXEC usp_crpt_camp_list" +
			"  @camp_id="+sCampID+
			", @cust_id="+cust.s_cust_id+
			", @cache=0";
			
		rs = stmt.executeQuery(sSql);
		
		while( rs.next() )
		{
			byte[] bVal = rs.getBytes("CampName");
			reportName = (bVal!=null?new String(bVal,"UTF-8"):"");
			reportDate = rs.getString("StartDate");
		}
		rs.close();
	}

	if ((sCampID == null) || ("".equals(sCampID)) || (numRecs < 1))
	{
%>
	<table class="listTable" cellspacing=0 cellpadding=0 width=650 border=0>
		<tr>
			<td valign=top align=center width=650>
				<table cellspacing=1 cellpadding=2 width="100%">
					<tr>
						<td align="center" valign="middle" style="padding:10px;">
							<b>No Campaign for that ID</b>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<br><br>
<%
	}
	else
	{
%>
		<div class="sectionTopHeader" style="margin-bottom:1px;">
			<a href="report_object.jsp?id=<%=sCampID%>">
				<span>Campaign Results</span>
			</a>
			<a href="report_cache_list.jsp?Q=<%=sCampID%>">	<span>Demographic Or Time Report</span>	</a>
			<a href="report_time.jsp?Q=<%=sCampID%>"><span>Activity vs. Time Report</span></a>
			<a class="activeTab" href="javascript:void(null);">	<span>RevoTrack Results</span>	</a>
			<a href="report_heatmap.jsp?Q=<%=sCampID%>"><span>HeatMap</span></a>
			<br class="clearfix">
		</div>
	
		<table width=100% class=listTable  cellspacing=0 cellpadding=0>
			<tr>
				<th class=sectionheader>&nbsp;<b class=sectionheader>Report</b></th>
			</tr>
			<tr>
				<td><%= reportName %></td>
			</tr>
		</table>
		
		<br>
		
		<!-- Main container start -->
		<table cellspacing="0" cellpadding="0" width="100%">
			<tr>
				<td valign="top" width="465">
					<!-- Revenue Report Start -->
					<%
					boolean displayPurchOnChart = false;
					MbsRevenueReport mbsRevenueReport = new MbsRevenueReport();
					mbsRevenueReport.s_camp_id = sCampID;
					if(mbsRevenueReport.retrieve() > 0)
					{
						displayPurchOnChart = true;
					%>

				
					<table class=listTable border=0 cellspacing=0 cellpadding=0 width="465">
						<tr>
							<th colspan="4">Revenue Summary</th>
						</tr>
						<tr>
							<td>
								<!-- 
								<table class=listTable border=0 cellspacing=0 cellpadding=2 width="100%">
									<tr>
										<th class="subsectionheader" colspan="2" width="50%">Purchasers</th>
										<th class="subsectionheader" colspan="2" width="50%">Purchases</th>						
									</tr>
									<tr>
										<th class="subsectionheader" width="25%">#</th>
										<th class="subsectionheader" width="25%">% Of Delivered</th>
										<th class="subsectionheader" width="25%">#</th>
										<th class="subsectionheader" width="25%">$ Amount</th>
									</tr>
									<tr>
									-->
									<%
									Service service = null;
									Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
									service = (Service) services.get(0); 
									String sMbsReportDetailsUrl =
										"http://" + service.getURL().getHost() + "/rrcp/imc/rpt/mbs_revenue_report_details.jsp" +
										"?cust_id=" + cust.s_cust_id + "&camp_id=" + sCampID;
									%>
									<!--
										<td width="25%">
											a
										</td>
										<td width="25%"><%//HtmlUtil.escape(mbsRevenueReport.s_delivered)%></td>
										<td width="25%"><%//HtmlUtil.escape(mbsRevenueReport.s_purchases)%></td>
										<td width="25%"><%//HtmlUtil.escape(mbsRevenueReport.s_total)%></td>
									</tr>
								</table>
								-->
								<%										
								String campSummarySql = "select * from crpt_camp_summary with(nolock) where camp_id = " + sCampID;

								rs = stmt.executeQuery(campSummarySql);
								
								String tReceived = "";
								String tRead = "";
								String tClicks = "";
								
								while(rs.next())
								{
									 tReceived = rs.getString(7);
									 tRead = rs.getString(8);
									 tClicks = rs.getString(10);
								}
								String xmlData = "<graph baseFontSize='12' isSliced='1' decimalPrecision='0'>";
								if(displayPurchOnChart)
								{
									//int purchAmount = Math.round(Integer.parseInt(mbsRevenueReport.s_total));
									//String purchAmountStr = Integer.toString(purchAmount);
									//xmlData += "<set name='Purchases' value='"+HtmlUtil.escape(purchAmountStr)+"' />";
								}
									
								xmlData += "<set name='Clicks' value='"+tClicks+"' /><set name='Reads' value='"+tRead+"' /><set name='Received' value='"+tReceived+"' /></graph>";

								%>
								<!--<div id="chartdiv"></div>-->

								<%
									int readPerct = ((Integer.parseInt(tRead) * 100) / Integer.parseInt(tReceived));
									int clickPerct = ((Integer.parseInt(tClicks) * 100) / Integer.parseInt(tReceived));
								%>
								
								<div style="margin-bottom:15px;">
									<div style="margin:12px auto;width:300px;"><div style="border-bottom:1px solid #4f96c7;float:left;background: url(http://www.revotas.com/1x20blue.gif) repeat scroll 0 0 transparent;height: 32px;width: 200px;"></div><div style="padding-left:205px;"><div style="font-size:13px;">Received</div><div style="font-size:14px;font-weight:bold;"><%=tReceived%></div></div><div style="clear:both;"></div></div>
									<div style="margin:12px auto;width:300px;"><div style="border-bottom:1px solid #c58249;margin-left:25px;float:left;background: url(http://www.revotas.com/1x20orange.gif) repeat scroll 0 0 transparent;height: 32px;width: 150;"></div><div style="padding-left:185px;"><div style="font-size:13px;">Read</div><div style="font-size:14px;font-weight:bold;"><%=tRead%> <span style="font-size:12px;font-weight:normal">(<%= readPerct %>%)</span></div></div><div style="clear:both;"></div></div>
									<div style="margin:12px auto;width:300px;"><div style="border-bottom:1px solid #ca4242;margin-left:52.5px;float:left;background: url(http://www.revotas.com/1x20red.gif) repeat scroll 0 0 transparent;height: 32px;width: 100px;"></div><div style="padding-left:165px;"><div style="font-size:13px;">Clicks</div><div style="font-size:14px;font-weight:bold;"><%=tClicks%> <span style="font-size:12px;font-weight:normal">(<%= clickPerct %>%)</span></div></div><div style="clear:both;"></div></div>
									<div style="margin:12px auto;width:300px;"><div style="border-bottom:1px solid #39bb4b;margin-left:82px;float:left;background: url(http://www.revotas.com/1x20green.gif) repeat scroll 0 0 transparent;height: 32px;width: 50px;"></div><div style="padding-left:145px;"><div style="font-size:13px;">Purchase</div><div style="font-size:14px;font-weight:bold;"><a href="javascript:pop_up_win('<%=sMbsReportDetailsUrl%>');"><%=HtmlUtil.escape(mbsRevenueReport.s_total)%></a></div></div><div style="clear:both;"></div></div>
								</div>
								
								<style>
								.sumTbl td {
									border:1px solid #e9e9e9;
									text-align:right;
								}
								</style>
								<table cellpadding="8" cellspacing="0" width="500" class="sumTbl" style="border-collapse:collapse;">
									<tr>
										<td style="text-align:left;">Received</td>
										<td style="background-color:#f3f3f3;font-weight: bold;"><%=tReceived%></td>
										<td><div style="background-color:#479bd8;height:20px;width:60%;z-index:1;float:left;"></div><span style="padding-left:5px;padding-top:3px;float:left;">%100</span></td>
									</tr>
									<tr>
										<td style="text-align:left;background-color:#fafafa">Read</td>
										<td style="background-color:#eaeaea;font-weight: bold;"><%=tRead%></td>
										<td><div style="background-color:#479bd8;height:20px;width:<%=readPerct+0.1%>%;z-index:1;float:left;"></div><span style="padding-left:5px;padding-top:3px;float:left;">%<%=readPerct%></span></td>
									</tr>
									<tr>
										<td style="text-align:left;">Click</td>
										<td style="background-color:#f3f3f3;font-weight: bold;"><%=tClicks%></td>
										<td><div style="background-color:#479bd8;height:20px;width:<%=clickPerct+0.1%>%;z-index:1;float:left;"></div><span style="padding-left:5px;padding-top:3px;float:left;">%<%=clickPerct%></span></td>
									</tr>
									<tr>
										<td style="background-color:#fafafa;text-align:left;">Purchasers</td>
										<td style="background-color:#eaeaea;font-weight: bold;"><a href="javascript:pop_up_win('<%=sMbsReportDetailsUrl%>');"><%=HtmlUtil.escape(mbsRevenueReport.s_purchasers)%></a></td>
										<td><div style="background-color:#479bd8;height:20px;width:<%=HtmlUtil.escape(mbsRevenueReport.s_delivered)%>%;z-index:1;float:left;"></div><span style="padding-left:5px;padding-top:3px;float:left;">%<%=HtmlUtil.escape(mbsRevenueReport.s_delivered)%></span></td>
									</tr>
									<tr>
										<td style="text-align:left;">Purchases</td>
										<td style="background-color:#f3f3f3;font-weight: bold;"><%=HtmlUtil.escape(mbsRevenueReport.s_purchases)%></td>
										<td></td>
									</tr>
									<tr>
										<td style="background-color:#fafafa;text-align:left;">Revenue</td>
										<td style="background-color:#eaeaea;font-weight: bold;"><%=HtmlUtil.escape(mbsRevenueReport.s_total)%></td>	
										<td></td>
									</tr>
								</table>
								
							</td>
						</tr>
					</table>
					<%
					}
					%>
						<!-- Revenue Report End -->
				</td>
				<td style="padding-left:10px;vertical-align:top;" valign="top">
						<!-- links start-->
								<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="100%" border="0">
										
								<!--  added the tag to show Delivery tracker tab (part of release 5.9) -->
								<% if (showTrackerRpt == 1) { %>
									<tr><td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'eTrackerReport.jsp?Q=<%=sCampID%>';">Delivery Tracking</td></tr>
								<%}%>
								<!--  END (part of release 5.9) -->
									
								<tr>
									<td valign="top" align="center" width="100%">
										<table class=listTable border=0 cellspacing=0 cellpadding=2 width="100%">
											<tr>
												<th>Tracked Web Pages</th>
											</tr>
											<tr>
												<td>
													<table id="twebp" class=listTable border=0 cellspacing=0 cellpadding=0 width="100%">
														<tr>
															<th>Page URL</th>
															<th>Distinct Visits</th>
															<th>Total Visits</th>
														</tr>
														
														<%
														int iCount = 0;
														String sClassAppend = "_other";

														String sSql =
															" EXEC usp_crpt_camp_pos_list" +
															" @camp_id = " + sCampID + 
															",@cache = "+sCache;

														rs = stmt.executeQuery(sSql);
														
														while(rs.next())
														{
															if (iCount % 2 != 0) sClassAppend = "_other";
															else sClassAppend = "";
														
															iCount++;

															String sLinkID = rs.getString(1);
															String sCurCampID = rs.getString(2);
															String sHref = rs.getString(3);
															String sDistClicks = rs.getString(4);
															String sDistClickPct = rs.getString(5);
															String sTotClicks = rs.getString(6);
															String sTotClickPct = rs.getString(7);		
														%>		
														<tr class="<%=(iCount > 10 ? "hideMore" : "showMore")%>">
															<td class="list_row<%= sClassAppend %>"><a href="report_track_connect.jsp?Q=<%= sCurCampID %>&P=<%= sLinkID %>&Z=<%= sCache %>"><%= sHref %></a></td>
															<td class="list_row<%= sClassAppend %>"><b><%= sDistClicks %></b> visits <div style="position:relative;margin-top:3px;width:100px;height:15px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;"><div style="background-color:#CBEBFF;height:15px;width:<%= sDistClickPct %>%"><span style="position:absolute;top:1;right:2;font-size:11px;"><%= sDistClickPct %>%</span></div></div></td>
															<td class="list_row<%= sClassAppend %>"><b><%= sTotClicks %></b> visits <div style="position:relative;margin-top:3px;width:100px;height:15px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;"><div style="background-color:#CBEBFF;height:15px;width:<%= sTotClickPct %>%"><span style="position:absolute;top:1;right:2;font-size:11px;"><%= sTotClickPct %>%</span></div></div></td>
														</tr>
														<%
														}
														rs.close();
														%>
														<tr>
															<th colspan="3" style="text-align:center;"><a id="showMoreText" style="font-size:11px;" href="javascript:void(0);" onclick="toggleShowMore()">Show more</a></th>
														</tr>
														</table>
													</td>
												</tr>
											</table>

										</td>
									</tr>
								</table>
							
						
						<!-- links end -->
				</td>
			</tr>
		</table>
		<!-- Main container end -->


		
<%
	}
}
catch (Exception ex) { throw ex; }
finally
{
	try
	{
		if( stmt  != null ) stmt.close(); 
		if( conn  != null ) cp.free(conn);
	}
	catch (SQLException ex) { }
}
%>
</body>
</html>
