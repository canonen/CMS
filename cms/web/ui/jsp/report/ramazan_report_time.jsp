<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.net.*,java.io.*,
			org.apache.log4j.*"
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

//CY 08042013
//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_list.jsp");
	stmt = conn.createStatement();

	String	CampID 	= request.getParameter("Q");
	int		numRecs		= 0;

	String sId			= null;
	String sDate		= null;
	String sSent		= null;
	String sReads		= null;
	String sClicks		= null;
	String sUnsubs		= null;
	String sReadPct		= null;
	String sClickPct	= null;
	String sUnsubPct	= null;

%>
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
		<head>
			<title>Revotas Report</title>
			<meta http-equiv="Expires" content="0"/>
			<meta http-equiv="Caching" content=""/>
			<meta http-equiv="Pragma" content="no-cache"/>
			<meta http-equiv="Cache-Control" content="no-cache"/>
			<meta http-equiv="content-Type" content="text/html" charset="utf-8"/>
			
			<link rel="stylesheet" media="all" type="text/css" href="http://cms.revotas.com/cms/ui/css/reset.css" />
			<link rel="stylesheet" media="all" type="text/css" href="http://cms.revotas.com/cms/ui/css/style_compressed_zaf.css" />
			<script type="text/javascript" src="http://cms.revotas.com/cms/ui/js/report/main_compressed_zaf.js"></script>
		</head>
		<body>
<%
//KU 2004-02-20
int nPos = 0;
String reportName = "";
String reportDate = "";
byte[] bVal = new byte[255];
	
//Customize deliveryTracter report Feature (part of release 5.9)
	int showTrackerRpt = 0;
	boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
	if (bFeat)
	{
 		int nCount = getSeedListCount(stmt,cust.s_cust_id, CampID);
		if (nCount > 0)
			showTrackerRpt = 1;
	}
// end (part of release 5.9)
	
if ((CampID != null) && (CampID != ""))
{
	rs = stmt.executeQuery("SELECT count(camp_id) FROM cque_campaign c"
			+ " WHERE c.cust_id="+cust.s_cust_id+" and c.camp_id="+CampID);
			
	while(rs.next())
	{
		numRecs = rs.getInt(1);
	}
	
	rs.close();
	
	//KU 2004-02-20
	rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_pos WHERE camp_id IN ("+CampID+")");
	
	if ( rs.next() )
	{
		nPos = rs.getInt(1);
	}
	rs.close();
	
	rs = stmt.executeQuery("Exec usp_crpt_camp_list @camp_id="+CampID+", @cust_id="+cust.s_cust_id+", @cache=0");
	
	while( rs.next() )
	{
		bVal = rs.getBytes("CampName");
		reportName = (bVal!=null?new String(bVal,"UTF-8"):"");
		reportDate = rs.getString("StartDate");
	}
	rs.close();
}

if ((CampID == null) || (CampID == "") || (numRecs < 1))
{
%>
	<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
		<tr>
			<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<tr>
			<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<tbody class=EditBlock id=block1_Step1>
		<tr>
			<td class=fillTab valign=top align=center width=650>
				<table class=main cellspacing=1 cellpadding=2 width="100%">
					<tr>
						<td align="center" valign="middle" style="padding:10px;">
							<b>No Campaign for that ID</b>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		</tbody>
	</table>
	<br><br>
<%	
}
else
{


	%>
<!-- edited by zafer 10.05.2011 -->
<!-- start header tabs -->


<div class="sectionTopHeader">
<%if (bStandardUI) { %>
	<a href="report_object.jsp?id=<%=CampID%>"><span>Campaign Results</span></a>
	<a href="javascript:void(null);"><span>Activity vs. Time Report</span></a>

<%}%>	

<%if (!bStandardUI) { %>
	<a href="report_object.jsp?id=<%=CampID%>"><span>Campaign Results</span></a>
	<a href="report_cache_list.jsp?Q=<%=CampID%>"><span>Demographic Or Time Report</span></a>
	<a href="javascript:void(null);" class="activeTab" ><span>Activity vs. Time Report</span></a>
	
<%}%>	
	
	<% if(showTrackerRpt == 1){ %>
		<a href="eTrackerReport.jsp?Q=<%=CampID%>"><span>Delivery Tracking</span></a>
	<% }%>
	<% if(nPos > 0){%><a href="report_track.jsp?Q=<%=CampID%>&#38;Z=0"><span>RevoTrack Results</span></a><%}%>
		
	<a href="report_heatmap.jsp?Q=<%=CampID%>"><span>HeatMap</span></a>	
	
	<br class="clearfix" />
</div>
<!-- end header tabs -->


		<table width=100% class=listTable  cellspacing=0 cellpadding=0>
			<tr>
				<th class=sectionheader>&nbsp; </th>
			</tr>
			<tr>
				<td><b>Report:</b> <%= reportName %></td>
			</tr>
			 
			<tr><td height=10></td></tr>
			 
		</table>


<div class="sectionBox">
	<div id="sortableColumnLeft" class="droptrue moveObj" style="width:80%">
			 <div class="ui-state-default sectionblock" id="section-ActivityTimeHour">
				<a class="sectionSheaders" href="javascript:toggleContentBox('reportActivityTimeHour')"><img id="reportActivityTimeHour_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /><span>Activity By Hour: (For the first week of the Campaign)</span></a>	
				<div id="reportActivityTimeHour" style="display:block;">
					<div style="display:block;" id="sumGraph1">
						
						<div id="chartContainer" style="background-color:#ffffff"></div>
						
						<%
						rs = stmt.executeQuery("SELECT hour_id+1, convert(char(16),hour_date,120), " +
												"sent, reads, convert(decimal(5,1),round(100*read_pct,1)), " +
												"clicks, convert(decimal(5,1),round(100*click_pct,1)), " +
												"unsubs, convert(decimal(5,1),round(100*unsub_pct,1)) " +
												"FROM crpt_camp_hour WHERE camp_id = "+CampID+
												" ORDER BY hour_id");
						
						int iCount 			= 0;
						String graph_cat 	= "";
						String graph_val1 	= "";
						String graph_val2 	= "";
						String graph_val3 	= "";
						String graph_val4 	= "";
			
						while(rs.next()){
							
							sId 		= rs.getString(1);
							sDate 		= rs.getString(2);
							sSent 		= rs.getString(3);
							sReads 		= rs.getString(4);
							sReadPct 	= rs.getString(5);
							sClicks 	= rs.getString(6);
							sClickPct 	= rs.getString(7);
							sUnsubs 	= rs.getString(8);
							sUnsubPct 	= rs.getString(9);
							
							String sDateTime	= sDate.substring(11, 16);
							String sDateDate	= sDate.substring(0, 11);
							
							String sDateStr = sDate;
							sDate = sDateDate + "<br>" + sDateTime + "<br>Sent: " + sSent; 
							
							graph_cat 	+= "{\"label\":\""+sDate+"\"},";
							graph_val1 	+= "{\"value\":\""+sReads+"\",\"tooltext\":\""+sDateStr+", "+sReads+" Reads\"},";
							graph_val2 	+= "{\"value\":\""+sClicks+"\",\"tooltext\":\""+sDateStr+", "+sClicks+" Clicks\"},";
							graph_val3 	+= "{\"value\":\""+sUnsubs+"\",\"tooltext\":\""+sDateStr+", "+sUnsubs+" Unsubscribes\"},";
							graph_val4 	+= "{\"value\":\""+sSent+"\",\"tooltext\":\""+sDateStr+", "+sSent+" Sent\"},";
			
							iCount++;			
						} 
			
						int graph_catCount 	= graph_cat.length();
						int graph_val1Count = graph_val1.length();
						int graph_val2Count = graph_val2.length();
						int graph_val3Count = graph_val3.length();
						int graph_val4Count = graph_val4.length();
						
						graph_cat 	= graph_cat.substring(0, graph_catCount - 1);
						graph_val1 	= graph_val1.substring(0, graph_val1Count - 1);
						graph_val2 	= graph_val2.substring(0, graph_val2Count - 1);
						graph_val3 	= graph_val3.substring(0, graph_val3Count - 1);
						graph_val4 	= graph_val4.substring(0, graph_val4Count - 1);
						%>
			
						<script type="text/javascript">
						
							var myChart = new FusionCharts("fusioncharts/ScrollColumn2D.swf", "myChartId", "955", "380", "0", "1");

							myChart.setJSONData({
								"chart": {
						      
							        
								"useroundedges":"1",
						        "showborder": "0",
						     	"tooltipbgcolor": "ffffff",
						        "tooltipbordercolor": "f9f9f9",
						        
						        "plotborderdashed": "1",
						        "plotborderdashlen": "2",
						        "plotborderdashgap": "2",
						        
								"bgColor" : "ffffff, ffffff",
								"bgAlpha" : "100,100",
								"canvasbgColor" : "ffffff",
						        "basefontcolor": "333333",
						        "alternateHGridColor": "40b8fd",
							        
						        "formatNumber" : "0",
						        "formatNumberScale" : "0",
						        "showCanvasBase" : "0",
						        "legendBgColor" : "ffffff",
								"legendBorderColor" : "f9f9f9",
								"rotateValues" : "1",
								"scrollColor" : "f9f9f9"
						    						        

							    },
							    "categories": [
							        { "category": [ <% out.print(graph_cat); %> ] }
							    ],
							    "dataset": [
										    
							        {
							        	"seriesname": "Reads",
							        	"renderas": "Area",
							            "color": "4169e1",
							            "plotbordercolor": "4169e1",
							            "data": [ <% out.print(graph_val1); %> ]
							        },
							        {
							        	"seriesname": "Clicks",
							        	"renderas": "Area",
							            "color": "228b22",
							            "plotbordercolor": "228b22",
							            "data": [ <% out.print(graph_val2); %> ]
							        },
							        {
							        	"seriesname": "Unsubscribes",
							        	"renderas": "Area",
							            "color": "FF0000",
							            "plotbordercolor": "FF0000",
							            "data": [ <% out.print(graph_val3); %> ]
							        }
							    ],
							    "styles": {
							        "definition": [
							            {
							                "name": "captionFont",
							                "type": "font",
							                "font" : "Verdana",
							                "size": "9",
							                "color" : "333333",
							                "isHTML" : "1",
							                "italic" : "0",
							                "borderColor" : "f9f9f9"
							            }
							        ],
							        "application": [
							            {
							                "toobject": "DataLabels",
							                "styles": "captionfont"
							            }
							        ]
							    }

							   
							    
			    
							});
							myChart.render("chartContainer");
						</script>
					
					</div>
				</div>
			</div>		
			
			
			<div class="ui-state-default sectionblock" id="section-ActivityTime">
				<a class="sectionSheaders" href="javascript:toggleContentBox('reportActivityTime')"><img id="reportActivityTime_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /><span>Activity By Day</span></a>	
				<div id="reportActivityTime" style="display:block;">
				
					<div style="display:block;" id="sumGraph2">
						<div id="chartContainer2" style="background-color:#ffffff"></div>
					<%
					rs = stmt.executeQuery("SELECT day_id+1, convert(char(10),day_date,120), " +
							"sent, reads, convert(decimal(5,1),round(100*read_pct,1)), " +
							"clicks, convert(decimal(5,1),round(100*click_pct,1)), " +
							"unsubs, convert(decimal(5,1),round(100*unsub_pct,1)) "+
							"FROM crpt_camp_day WHERE camp_id = "+CampID+
							" ORDER BY day_id");
					
					int dCount 			= 0;
					String dgraph_cat 	= "";
					String dgraph_val1 	= "";
					String dgraph_val2 	= "";
					String dgraph_val3 	= "";
		
					while(rs.next()){
						
						sId 		= rs.getString(1);
						sDate 		= rs.getString(2);
						sSent 		= rs.getString(3);
						sReads 		= rs.getString(4);
						sReadPct 	= rs.getString(5);
						sClicks 	= rs.getString(6);
						sClickPct 	= rs.getString(7);
						sUnsubs 	= rs.getString(8);
						sUnsubPct 	= rs.getString(9);
		
						dgraph_cat 		+= "{\"label\":\""+sDate+"\"},";
						
						dgraph_val1 	+= "{\"value\":\""+sReads+"\",\"tooltext\":\""+sReads+" Reads\"},";
						dgraph_val2 	+= "{\"value\":\""+sClicks+"\",\"tooltext\":\""+sClicks+" Clicks\"},";
						dgraph_val3 	+= "{\"value\":\""+sUnsubs+"\",\"tooltext\":\""+sUnsubs+" Unsubscribes\"},";
		
						dCount++;			
					} 
		
					int dgraph_catCount 	= dgraph_cat.length();
					int dgraph_val1Count 	= dgraph_val1.length();
					int dgraph_val2Count 	= dgraph_val2.length();
					int dgraph_val3Count 	= dgraph_val3.length();
					
					dgraph_cat 		= dgraph_cat.substring(0, dgraph_catCount - 1);
					dgraph_val1 	= dgraph_val1.substring(0, dgraph_val1Count - 1);
					dgraph_val2 	= dgraph_val2.substring(0, dgraph_val2Count - 1);
					dgraph_val3 	= dgraph_val3.substring(0, dgraph_val3Count - 1);
					%>
					
						<script type="text/javascript">
						
							var myChartxxx = new FusionCharts("fusioncharts/MSBar2D.swf", "myChartIdxxx", "955", "<%=120+dCount*50%>", "0", "1");

							myChartxxx.setJSONData({
								"chart": {
						        

								"useroundedges":"1",
						        "showborder": "0",
						     	"tooltipbgcolor": "ffffff",
						        "tooltipbordercolor": "f9f9f9",
						        
						        "plotborderdashed": "1",
						        "plotborderdashlen": "2",
						        "plotborderdashgap": "2",
						        
								"bgColor" : "ffffff, ffffff",
								"bgAlpha" : "100,100",
								"canvasbgColor" : "ffffff",
						        "basefontcolor": "333333",
						        "alternatevgridcolor": "40b8fd",
							        
						        "formatNumber" : "0",
						        "formatNumberScale" : "0",
						        "showCanvasBase" : "0",
						        "legendBgColor" : "ffffff",
								"legendBorderColor" : "f9f9f9",
								"rotateValues" : "1"
							    },
							    "categories": [
							        { "category": [ <% out.print(dgraph_cat); %> ] }
							    ],
							    "dataset": [
										    
							        {
							        	"seriesname": "Reads",
							        	"renderas": "Area",
							            "color": "4169e1",
							            "plotbordercolor": "4169e1",
							            "data": [ <% out.print(dgraph_val1); %> ]
							        },
							        {
							        	"seriesname": "Clicks",
							        	"renderas": "Area",
							            "color": "228b22",
							            "plotbordercolor": "228b22",
							            "data": [ <% out.print(dgraph_val2); %> ]
							        },
							        {
							        	"seriesname": "Unsubscribes",
							        	"renderas": "Area",
							            "color": "FF0000",
							            "plotbordercolor": "FF0000",
							            "data": [ <% out.print(dgraph_val3); %> ]
							        }
							    ]
							});
							myChartxxx.render("chartContainer2");
						</script>
			
				</div>
				</div>
			</div>

	</div>	
	<div class="clearfix"></div>
</div>
</body>
</html>
<%
}
} catch (Exception ex) {
	ErrLog.put(this, ex, "Error: "+ex.getMessage(),out,1);	
} finally {
	try {
		if( stmt  != null ) stmt.close(); 
		if( conn  != null ) cp.free(conn);
	} catch (SQLException ex) { } 
}
%>



