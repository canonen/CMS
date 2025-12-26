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
function pop_up_win(url)
{
	windowName = 'report_results_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=750';
	ReportWin = window.open(url, windowName, windowFeatures);
}
</script>
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
			" FROM cque_campaign c" +
			" WHERE c.cust_id = " + cust.s_cust_id +
			" AND c.camp_id = " + sCampID;
			
		rs = stmt.executeQuery(sSql);
		if(rs.next()) numRecs = rs.getInt(1);
		rs.close();

		// === === ===		

		sSql = 
			" SELECT count(*)" +
			" FROM crpt_camp_pos" +
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
	<table width=95% class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<b class=sectionheader>Report:</b> <%= reportName %></td>
		</tr>
	</table>
	<br>
	<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="95%" border="0">
		<tr>
			<td class="EditTabOff" valign="center" nowrap align="middle" onclick="location.href = 'report_object.jsp?id=<%=sCampID%>';">Campaign Results</td>
			<td class="EditTabOff" valign="center" nowrap align="middle" onclick="location.href = 'report_cache_edit.jsp?Q=<%=sCampID%>';">Demographic Or Time Report</td>
			<td class="EditTabOff" valign="center" nowrap align="middle" onclick="location.href = 'report_time.jsp?Q=<%=sCampID%>';">Activity vs. Time Report</td>
			<td class="EditTabOn" valign="center" nowrap align="middle">BriteTrack Results</td>
		
			<!--  added the tag to show Delivery tracker tab (part of release 5.9) -->
			<% if (showTrackerRpt == 1) { %>
				<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'eTrackerReport.jsp?Q=<%=sCampID%>';">Delivery Tracking</td>
			<%}%>
			<!--  END (part of release 5.9) -->
				
			<td class="EmptyTab" valign="center" nowrap="true" align="middle" width="250"><img height="2" src="../../images/blank.gif" width="1" /></td>
		</tr>
		<tbody class="EditBlock" id="block1_Step1">
		<tr>
			<td class="fillTab" valign="top" align="center" width="100%" colspan="6">
				<table class=listTable border=0 cellspacing=0 cellpadding=2 width="100%">
					<tr>
						<th colspan="3">Tracked Web Pages</th>
					</tr>
					<tr>
						<td class="subsectionheader" width="200">Page URL</td>
						<td class="subsectionheader" width="50">Distinct Visits</td>
						<td class="subsectionheader" width="50">Total Visits</td>
					</tr>  
<%
		int iCount = 0;
		String sClassAppend = "_Alt";

		String sSql =
			" EXEC usp_crpt_camp_pos_list" +
			" @camp_id = " + sCampID + 
			",@cache = "+sCache;

		rs = stmt.executeQuery(sSql);
		
		while(rs.next())
		{
			if (iCount % 2 != 0) sClassAppend = "_Alt";
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
					<tr>
						<td class="listItem_Title<%= sClassAppend %>"><a href="report_track_connect.jsp?Q=<%= sCurCampID %>&P=<%= sLinkID %>&Z=<%= sCache %>"><%= sHref %></a></td>
						<td class="listItem_Data<%= sClassAppend %>"><%= sDistClicks %> (<%= sDistClickPct %>%)</td>
						<td class="listItem_Data<%= sClassAppend %>"><%= sTotClicks %> (<%= sTotClickPct %>%)</td>
					</tr>
<%
		}
		rs.close();
%>
				</table>
<%
	MbsRevenueReport mbsRevenueReport = new MbsRevenueReport();
	mbsRevenueReport.s_camp_id = sCampID;
	if(mbsRevenueReport.retrieve() > 0)
	{
%>
				<br>
				<table class=listTable border=0 cellspacing=0 cellpadding=2 width="100%">
					<tr>
						<th colspan="4">Revenue Summary</th>
					</tr>
					<tr>
						<th class="subsectionheader" colspan="2" width="50%">Purchasers</th>
						<th class="subsectionheader" colspan="2" width="50%">Purchases</th>						
					</tr>
					<tr>
						<td class="subsectionheader" width="25%">#</td>
						<td class="subsectionheader" width="25%">% Of Delivered</td>
						<td class="subsectionheader" width="25%">#</td>
						<td class="subsectionheader" width="25%">$ Amount</td>						
					</tr>
					<tr>
<%
Service service = null;
Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
service = (Service) services.get(0); 
String sMbsReportDetailsUrl =
	"http://" + service.getURL().getHost() + "/rrcp/imc/rpt/mbs_revenue_report_details.jsp" +
	"?cust_id=" + cust.s_cust_id + "&camp_id=" + sCampID;
%>
						<td width="25%">
							<a href="javascript:pop_up_win('<%=sMbsReportDetailsUrl%>');"><%=HtmlUtil.escape(mbsRevenueReport.s_purchasers)%></a>
						</td>
						<td width="25%"><%=HtmlUtil.escape(mbsRevenueReport.s_delivered)%></td>
						<td width="25%"><%=HtmlUtil.escape(mbsRevenueReport.s_purchases)%></td>
						<td width="25%"><%=HtmlUtil.escape(mbsRevenueReport.s_total)%></td>
					</tr>
				</table>
<%
	}
%>
			</td>
		</tr>
	</table>
	<br><br>
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
