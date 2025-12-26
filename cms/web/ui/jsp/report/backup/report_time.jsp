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
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
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

	rs = stmt.executeQuery("SELECT day_id+1, convert(char(10),day_date,120), " +
				"sent, reads, convert(decimal(5,1),round(100*read_pct,1)), " +
				"clicks, convert(decimal(5,1),round(100*click_pct,1)), " +
				"unsubs, convert(decimal(5,1),round(100*unsub_pct,1)) "+
				"FROM crpt_camp_day WHERE camp_id = "+CampID+
				" ORDER BY day_id");
	%>
<table width=95% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Report:</b> <%= reportName %></td>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="EditTabOff" valign="center" nowrap align="middle" onclick="location.href = 'report_object.jsp?id=<%=CampID%>';">Campaign Results</td>
		<td class="EditTabOff" valign="center" nowrap align="middle" onclick="location.href = 'report_cache_list.jsp?Q=<%=CampID%>';">Demographic Or Time Report</td>
		<td class="EditTabOn" valign="center" nowrap align="middle">Activity vs. Time Report</td>
	
		<!--  added the tag to show Delivery tracker tab (part of release 5.9) -->
		<% if (showTrackerRpt == 1) { %>
		<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'eTrackerReport.jsp?Q=<%=CampID%>';">Delivery Tracking</td>
		<%}%>
		<!--  END (part of release 5.9) -->
		
		<% if (nPos > 0) { %><td class="EditTabOff" valign="center" nowrap align="middle" onclick="location.href = 'report_track.jsp?Q=<%=CampID%>&#38;Z=0';">BriteTrack Results</td><% } %>
		<td class="EmptyTab" valign="center" nowrap="true" align="middle" width="250"><img height="2" src="../../images/blank.gif" width="1" /></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%" colspan="6">
			<a name=day>
			<table cellspacing="1" cellpadding="2" border="0" class="main" align="right">
				<tr>
					<td align="right" valign="middle" style="padding:4px;">
						<a href="#hour">(Go to: Activity by Hour Report)</a>
					</td>
				</tr>
			</table>
			<br><br>
			<table class=listTable cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<th colspan="7">Activity By Day</th>
				</tr>
				<tr>
					<td class="subsectionheader" width="25">Day</td>
					<td class="subsectionheader" width="100">Date</td>
					<td class="subsectionheader" width="50">Sent</td>
					<td class="subsectionheader" width="50">Reads</td>
					<td class="subsectionheader" width="75" nowrap>Click-Thrus</td>
					<td class="subsectionheader" width="50">Unsubscribes</td>
					<td class="subsectionheader" align="left">
						<table cellspacing="0" cellpadding="0" border="0">
							<tr>
								<td class="text" align="left" valign="middle" style="border:1px solid #000000;"><img height="5" width="15" src="/cms/ui/images/blank.gif" /></td>
								<td class="subsectionheader" align="left" valign="middle">&#160;Reads&#160;</td>
								<td class="html" align="left" valign="middle" style="border:1px solid #000000;"><img height="5" width="15" src="/cms/ui/images/blank.gif" /></td>
								<td class="subsectionheader" align="left" valign="middle">&#160;Clicks&#160;</td>
								<td class="aol" align="left" valign="middle" style="border:1px solid #000000;"><img height="5" width="15" src="/cms/ui/images/blank.gif" /></td>
								<td class="subsectionheader" align="left" valign="middle">&#160;Unsubscribes&#160;</td>
							</tr>
						</table>
					</td>
				</tr>  
			<%
			String sClassAppend = "";
			int iCount = 0;
			
			while(rs.next())
			{
				if (iCount % 2 != 0)
				{
					sClassAppend = "_other";
				}
				else
				{
					sClassAppend = "";
				}
				
				iCount++;
				
				sId = rs.getString(1);
				sDate = rs.getString(2);
				sSent = rs.getString(3);
				sReads = rs.getString(4);
				sReadPct = rs.getString(5);
				sClicks = rs.getString(6);
				sClickPct = rs.getString(7);
				sUnsubs = rs.getString(8);
				sUnsubPct = rs.getString(9);
				%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>"><%=sId%></td>
					<td class="list_row<%= sClassAppend %>"><nobr><%=sDate%></nobr></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=sSent%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=sReads%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=sClicks%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=sUnsubs%></td>
					<td class="listItem_Data<%= sClassAppend %>" align="left">
						<table border=0 cellpadding=0 cellspacing=0 width="<%=sReadPct%>%">
							<tr>
								<td class="text"><img height="1" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>
						</table>
						<table border=0 cellpadding=0 cellspacing=0 width="<%=sClickPct%>%">
							<tr>
								<td class="html"><img height="1" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>
						</table>
						<table border=0 cellpadding=0 cellspacing=0 width="<%=sUnsubPct%>%">
							<tr>
								<td class="aol"><img height="1" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>
						</table>
					</td>
				</tr>
				<%
			}
			rs.close();
			%>
			</table>
			<br>
			<%
			rs = stmt.executeQuery("SELECT hour_id+1, convert(char(16),hour_date,120), " +
						"sent, reads, convert(decimal(5,1),round(100*read_pct,1)), " +
						"clicks, convert(decimal(5,1),round(100*click_pct,1)), " +
						"unsubs, convert(decimal(5,1),round(100*unsub_pct,1)) " +
						"FROM crpt_camp_hour WHERE camp_id = "+CampID+
						" ORDER BY hour_id");
			%>
			<a name=hour>
			<table cellspacing="1" cellpadding="2" border="0" class="main" align="right">
				<tr>
					<td align="right" valign="middle" style="padding:4px;">
						<a href="#day">(Go to: Activity by Day Report)</a>
					</td>
				</tr>
			</table>
			<br><br>
			<table class=listTable cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<th colspan="7">Activity By Hour: (For the first week of the Campaign)</th>
				</tr>
				<tr>
					<td class="subsectionheader" width="25">Hour</td>
					<td class="subsectionheader" width="100"><nobr>Time</nobr></td>
					<td class="subsectionheader" width="50">Sent</td>
					<td class="subsectionheader" width="50">Reads</td>
					<td class="subsectionheader" width="75" nowrap>Click-Thrus</td>
					<td class="subsectionheader" width="50">Unsubscribes</td>
					<td class="subsectionheader" align="left">
						<table cellspacing="0" cellpadding="0" border="0">
							<tr>
								<td class="text" align="left" valign="middle" style="border:1px solid #000000;"><img height="5" width="15" src="/cms/ui/images/blank.gif" /></td>
								<td class="subsectionheader" align="left" valign="middle">&#160;Reads&#160;</td>
								<td class="html" align="left" valign="middle" style="border:1px solid #000000;"><img height="5" width="15" src="/cms/ui/images/blank.gif" /></td>
								<td class="subsectionheader" align="left" valign="middle">&#160;Clicks&#160;</td>
								<td class="aol" align="left" valign="middle" style="border:1px solid #000000;"><img height="5" width="15" src="/cms/ui/images/blank.gif" /></td>
								<td class="subsectionheader" align="left" valign="middle">&#160;Unsubscribes&#160;</td>
							</tr>
						</table>
					</td>
				</tr>  
			<%
			iCount = 0;
			
			while(rs.next())
			{
				if (iCount % 2 != 0)
				{
					sClassAppend = "_other";
				}
				else
				{
					sClassAppend = "";
				}
				
				iCount++;
				
				sId = rs.getString(1);
				sDate = rs.getString(2);
				sSent = rs.getString(3);
				sReads = rs.getString(4);
				sReadPct = rs.getString(5);
				sClicks = rs.getString(6);
				sClickPct = rs.getString(7);
				sUnsubs = rs.getString(8);
				sUnsubPct = rs.getString(9);
				%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>"><%=sId%></td>
					<td class="list_row<%= sClassAppend %>"><%=sDate%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=sSent%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=sReads%></td>
					<!-- <%=sReadPct%> -->
					<td class="listItem_Data<%= sClassAppend %>"><%=sClicks%></td>
					<!-- <%=sClickPct%> -->
					<td class="listItem_Data<%= sClassAppend %>"><%=sUnsubs%></td>
					<!-- <%=sUnsubPct%> -->
					<td class="listItem_Data<%= sClassAppend %>" align="left">
						<table border=0 cellpadding=0 cellspacing=0 width="<%=sReadPct%>%">
							<tr>
								<td class="text"><img height="1" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>
						</table>
						<table border=0 cellpadding=0 cellspacing=0 width="<%=sClickPct%>%">
							<tr>
								<td class="html"><img height="1" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>
						</table>
						<table border=0 cellpadding=0 cellspacing=0 width="<%=sUnsubPct%>%">
							<tr>
								<td class="aol"><img height="1" width="1" src="/cms/ui/images/blank.gif" /></td>
							</tr>
						</table>
					</tr>
				</tr>
				<%
			}
			rs.close();
			%>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
	<%
}
%>
</body>
</html>
<%

} catch (Exception ex) {

	ErrLog.put(this, ex, "Error: "+ex.getMessage(),out,1);	
} finally {
	try {
		if( stmt  != null ) stmt.close(); 
		if( conn  != null ) cp.free(conn);
	} catch (SQLException ex) { } 
}

%>



