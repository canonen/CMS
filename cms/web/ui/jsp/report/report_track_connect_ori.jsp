<%@ page
	language="java"
	import="com.britemoon.*,
		    com.britemoon.cps.*,
		    java.sql.*,java.net.*,
		    org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
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

	String	sCampID 	= request.getParameter("Q");
	String	sLinkID 	= request.getParameter("P");
	String	sCache	 	= request.getParameter("Z");
	sCache = ("1".equals(sCache))?sCache:"0";

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<%
int numRecs = 0;

if ((sLinkID != null) && (sLinkID != ""))
{
	rs = stmt.executeQuery("SELECT count(pos_link_id) FROM crpt_camp_pos p"
			+ " WHERE p.pos_link_id="+sLinkID+" and p.camp_id="+sCampID); 
	while(rs.next())
	{
		numRecs = rs.getInt(1);
	}
}

rs.close();
if ((sLinkID == null) || (sLinkID == "") || (numRecs < 1))
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
							<b>No Page for that ID</b>
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

	String sHref = null;
	String sDistClicks = null;
	String sTotClicks = null;

	rs = stmt.executeQuery("SELECT href, dist_clicks, tot_clicks"
			+ " FROM crpt_camp_pos"+(("1".equals(sCache))?"_cache":"")+" p"
			+ " WHERE p.pos_link_id="+sLinkID+" and p.camp_id="+sCampID);
				
	while(rs.next())
	{
		sHref = rs.getString(1);
		sDistClicks = rs.getString(2);
		sTotClicks = rs.getString(3);
	}
	%>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="subactionbutton" href="report_track.jsp?Q=<%= sCampID %>&Z=<%= sCache %>">Back to Campaign Tracking Report</a>
		</td>
	</tr>
</table>
<br>

<table width=100% class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Tracked Web Page Connections</b> </th>
	</tr>
	<tr>
	<td>

<table cellspacing="0" cellpadding="0" width="100%" class="listTable">
	<tr>
		<th>Current Page</th>
	</tr>
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table class=listTable cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<th width="100%">Page URL</th>
					<th nowrap>Distinct Visits</th>
					<th nowrap>Total Visits</th>
				</tr>  
				<tr>
					<td class="listItem_Data"><%=sHref%></td>
					<td class="listItem_Data"><%=sDistClicks%></td>
					<td class="listItem_Data"><%=sTotClicks%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>

<table cellpadding="0" cellspacing="0" width="100%">
	<td valign="top" style="padding: 0 10px 0 0;">
	<table cellspacing="0" cellpadding="0" width="100%" class="listTable">
<tr>
	<th>Page Visited Prior to Current Page</th>
</tr>
	<tr>
		<td valign="center" nowrap align="left">
						 
			<table class=listTable cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<th width="100%">Page URL</th>
					<th nowrap>Distinct Visits</th>
					<th nowrap>Total Visits</th>
				</tr>  

						<%
						String sSql = "EXEC usp_crpt_camp_pos_connect_prev @pos_link_id = "+sLinkID+",@camp_id = "+sCampID+",@cache = "+sCache;

						rs = stmt.executeQuery(sSql);
						
						int iCount = 0;
						
						String sClassAppend = "_other";

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

							String sCurLinkID = rs.getString(1);
							String sCurHref = rs.getString(2);
							String sCurDistClicks = rs.getString(3);
							String sCurDistClickPct = rs.getString(4);
							String sCurTotClicks = rs.getString(5);
							String sCurTotClickPct = rs.getString(6);

							%>
							<tr>
								<td class="list_row<%= sClassAppend %>"><a href="report_track_connect.jsp?Q=<%= sCampID %>&P=<%= sCurLinkID %>&Z=<%= sCache %>"><%= sCurHref %></a></td>
								<td class="list_row<%= sClassAppend %>"><b><%= sCurDistClicks %></b> visits <div style="position:relative;margin-top:3px;width:100px;height:15px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;"><div style="background-color:#CBEBFF;height:15px;width:<%= sCurDistClickPct %>%"><span style="position:absolute;top:1;right:2;font-size:11px;"><%= sCurDistClickPct %>%</span></div></div></td>
								<td class="list_row<%= sClassAppend %>"><b><%= sCurTotClicks %></b> visits <div style="position:relative;margin-top:3px;width:100px;height:15px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;"><div style="background-color:#CBEBFF;height:15px;width:<%= sCurTotClickPct %>%"><span style="position:absolute;top:1;right:2;font-size:11px;"><%= sCurTotClickPct %>%</span></div></div></td>
							</tr>
							<%
						}
						rs.close();
						%>
						</table>
					</td>
				</tr>
			</table>
	</td>
	
	<td style="vertical-align:top;padding:0" valign="top">
		<table cellspacing="0" cellpadding="0" width="100%" class="listTable">
			<tr>
				<th>Page Visited After Current Page</th>
			</tr>
				<tr>
					<td class="listHeading" valign="center" nowrap align="left">			 
						<table class=listTable cellspacing=0 cellpadding=2 width="100%">
							<tr>
								<th width="100%">Page URL</th>
								<th nowrap>Distinct Visits</th>
								<th nowrap>Total Visits</th>
							</tr>   
						<%
						sSql = "EXEC usp_crpt_camp_pos_connect_sub @pos_link_id = "+sLinkID+",@camp_id = "+sCampID+",@cache = "+sCache;

						rs = stmt.executeQuery(sSql);
						
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
							
							String sCurLinkID = rs.getString(1);
							String sCurHref = rs.getString(2);
							String sCurDistClicks = rs.getString(3);
							String sCurDistClickPct = rs.getString(4);
							String sCurTotClicks = rs.getString(5);
							String sCurTotClickPct = rs.getString(6);

							%>
							<tr>
								<td class="list_row<%= sClassAppend %>"><a href="report_track_connect.jsp?Q=<%= sCampID %>&P=<%= sCurLinkID %>&Z=<%= sCache %>"><%= sCurHref %></a></td>
								<td class="list_row<%= sClassAppend %>"><b><%= sCurDistClicks %></b> visits <div style="position:relative;margin-top:3px;width:100px;height:15px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;"><div style="background-color:#CBEBFF;height:15px;width:<%= sCurDistClickPct %>%"><span style="position:absolute;top:1;right:2;font-size:11px;"><%= sCurDistClickPct %>%</span></div></div></td>
								<td class="list_row<%= sClassAppend %>"><b><%= sCurTotClicks %></b> visits <div style="position:relative;margin-top:3px;width:100px;height:15px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;"><div style="background-color:#CBEBFF;height:15px;width:<%= sCurTotClickPct %>%"><span style="position:absolute;top:1;right:2;font-size:11px;"><%= sCurTotClickPct %>%</span></div></div></td>
							</tr>
							<%
						}
						rs.close();
						%>
						</table>
					</td>
				</tr>
			</table>
	</td>
</table>



</td>
</tr>
</table>
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



