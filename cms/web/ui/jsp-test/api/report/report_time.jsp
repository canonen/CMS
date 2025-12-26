<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.net.*,java.io.*,java.text.*,java.util.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.util.Date" %>

<%@ include file="../../utilities/validator.jsp"%>
<%@ include file="../header.jsp"%>
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
	JsonObject data = new JsonObject();
	JsonObject dataDaily = new JsonObject();
	JsonObject dataHours = new JsonObject();
	JsonObject dataValues = new JsonObject();
	JsonArray array = new JsonArray();
	JsonArray arrayData = new JsonArray();
boolean durum=true;
String graph_cat 	= "";
String graph_val1 	= "";
String graph_val2 	= "";
String graph_val3 	= "";
String graph_val4 	= "";

String reportName = "";

String dgraph_cat 	= "";
String dgraph_val1 	= "";
String dgraph_val2 	= "";
String dgraph_val3 	= "";

int dCount=0;
String	CampID="";
int showTrackerRpt = 0;
int nPos = 0;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_list.jsp");
	stmt = conn.createStatement();

	CampID= request.getParameter("campID");
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



String reads2="";
String clicks2="";
String unsub2="";





String reportDate = "";
byte[] bVal = new byte[255];
	
//Customize deliveryTracter report Feature (part of release 5.9)
	
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
		data = new JsonObject();
		numRecs = rs.getInt(1);
		data.put("numRecs",numRecs);
		arrayData.put(data);
	}

	rs.close();
	
	//KU 2004-02-20
	rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_pos WHERE camp_id IN ("+CampID+")");
	
	if ( rs.next() )
	{	data = new JsonObject();
		nPos = rs.getInt(1);
		data.put("nPos",nPos);
		arrayData.put(data);
	}
	rs.close();
	
	rs = stmt.executeQuery("Exec usp_crpt_camp_list @camp_id="+CampID+", @cust_id="+cust.s_cust_id+", @cache=0");
	
	while( rs.next() )
	{
		data = new JsonObject();
		bVal = rs.getBytes("CampName");
		reportName = (bVal!=null?new String(bVal,"UTF-8"):"");
		reportDate = rs.getString("StartDate");
		data.put("StartDate",reportDate);
		data.put("reportName",reportName);
		arrayData.put(data);
	}
	dataValues.put("dataValues",arrayData);
	arrayData = new JsonArray();
	rs.close();
}
//if ((CampID == null) || (CampID == "") || (numRecs < 1))
if ((CampID == null) || (CampID == "")) {
	durum=false;
	out.println("false ");
}
else
{

						rs = stmt.executeQuery("SELECT  day_id+1, convert(char(16),day_date,120), " +
												"sent, reads, convert(decimal(5,1),round(100*read_pct,1)), " +
												"clicks, convert(decimal(5,1),round(100*click_pct,1)), " +
												"unsubs, convert(decimal(5,1),round(100*unsub_pct,1)) " +
												"FROM crpt_camp_day WHERE camp_id = "+CampID+
												" ORDER BY day_id");
						
						int iCount 			= 0;

			
							while(rs.next()){
							data = new JsonObject();
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
							String sDateDate	= sDate.substring(0, 10);
							
							String sDateStr = sDate;
							//sDate = sDateDate + " - " + sDateTime;
							sDate = sDateDate;
							data.put("ID",sId);
							data.put("sDate",sDate);
							data.put("sSent",sSent);
							data.put("sReads",sReads);
							data.put("sReadPct",sReadPct);
							data.put("sClicks",sClicks);
							data.put("sClickPct",sClickPct);
							data.put("sUnsubs",sUnsubs);
							data.put("sUnsubPct",sUnsubPct);
							arrayData.put(data);
			
							iCount++;			
						}
							dataHours.put("dataHours",arrayData);
							arrayData = new JsonArray();
//						int graph_catCount 	= graph_cat.length();
//						int graph_val1Count = graph_val1.length();
//						int graph_val2Count = graph_val2.length();
//						int graph_val3Count = graph_val3.length();
//						int graph_val4Count = graph_val4.length();
//
//						graph_cat 	= graph_cat.substring(0, graph_catCount - 1);
//						graph_val1 	= graph_val1.substring(0, graph_val1Count - 1);
//						graph_val2 	= graph_val2.substring(0, graph_val2Count - 1);
//						graph_val3 	= graph_val3.substring(0, graph_val3Count - 1);
//						graph_val4 	= graph_val4.substring(0, graph_val4Count - 1);
						
						rs.close();
						
						 
					rs = stmt.executeQuery("SELECT  day_id+1, convert(char(10),day_date,120), " +
							"sent, reads, convert(decimal(5,1),round(100*read_pct,1)), " +
							"clicks, convert(decimal(5,1),round(100*click_pct,1)), " +
							"unsubs, convert(decimal(5,1),round(100*unsub_pct,1)) "+
							"FROM crpt_camp_day WHERE camp_id = "+CampID+
							" ORDER BY day_id");
					
                  
                          while(rs.next()){
						data = new JsonObject();
						sId 		= rs.getString(1);
						sDate 		= rs.getString(2);
						sSent 		= rs.getString(3);
						sReads 		= rs.getString(4);
						sReadPct 	= rs.getString(5);
						sClicks 	= rs.getString(6);
						sClickPct 	= rs.getString(7);
						sUnsubs 	= rs.getString(8);
						sUnsubPct 	= rs.getString(9);
							  data.put("ID",sId);
							  data.put("sDate",sDate);
							  data.put("sSent",sSent);
							  data.put("sReads",sReads);
							  data.put("sReadPct",sReadPct);
							  data.put("sClicks",sClicks);
							  data.put("sClickPct",sClickPct);
							  data.put("sUnsubs",sUnsubs);
							  data.put("sUnsubPct",sUnsubPct);
							  arrayData.put(data);
		

		
						dCount++;			
					}
						  dataDaily.put("dataDaily",arrayData);
						  array.put(dataDaily);
						  array.put(dataHours);
						  array.put(dataValues);
						  out.println(array);
						  rs.close();
		
//					int dgraph_catCount 	= dgraph_cat.length();
//					int dgraph_val1Count 	= dgraph_val1.length();
//					int dgraph_val2Count 	= dgraph_val2.length();
//					int dgraph_val3Count 	= dgraph_val3.length();
//
//					dgraph_cat 		= dgraph_cat.substring(0, dgraph_catCount - 1);
//					dgraph_val1 	= dgraph_val1.substring(0, dgraph_val1Count - 1);
//					dgraph_val2 	= dgraph_val2.substring(0, dgraph_val2Count - 1);
//					dgraph_val3 	= dgraph_val3.substring(0, dgraph_val3Count - 1);
//
					 
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
