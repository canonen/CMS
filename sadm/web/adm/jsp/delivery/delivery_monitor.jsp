<%@ page
	language="java"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.text.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<HTML>
<%
String actionType = request.getParameter("act");
boolean isExcelReport = false;
if (actionType != null && actionType.equals("PRNT")) {
	isExcelReport = true;
}
if (isExcelReport) {
	response.setContentType ("application/vnd.ms-excel");
	response.setHeader("Content-disposition","inline; filename=delivery_monitor.xls"); 
}
else {
%>
<HEAD>
	<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
	<link rel="stylesheet" href="../../css/reportstyle.css" type="text/css">
</HEAD>
<%
	response.setContentType ("text/html");
}
String sort = request.getParameter("sort");
if (sort == null || sort.length() == 0) {
	sort = "custid";
}
String hm = request.getParameter("hm");
boolean isHM = false;
if (hm != null && hm.equals("1")) isHM = true;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
String sql =  null;
try {
	conn = DriverManager.getConnection(Registry.getKey("delivery_db_connection_string"));
	stmt = conn.createStatement();
%>
<BODY>
    <% if (!isExcelReport) { %>
	<BR>
	<table cellpadding="0" cellspacing="0" class="main" width="100%">

		<tr>
			<td colspan="3" class="sectionheader">&nbsp;<b class="sectionheader">Delivery Confirmation:</b>&nbsp;&nbsp;Recent Campaigns (sorted by <%= sort %>)</td>
		</tr>
		<tr>
			<td colspan="2" align="left" class="listItem_Data" nowrap="true">
				Sort by: &nbsp;
				<a class="subactionbutton" href="?sort=custname">Cust Name</a> &nbsp;
				<a class="subactionbutton" href="?sort=custid">Cust Id</a> &nbsp;
				<a class="subactionbutton" href="?sort=campdate">Start Date</a> &nbsp;
				<a class="subactionbutton" href="?sort=camppct">Camp Sent %</a> &nbsp;
				<a class="subactionbutton" href="?sort=campsize">Queued</a> &nbsp;
				<a class="subactionbutton" href="?sort=acctpct">Accounted</a> &nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;
				<a class="resourcebutton"  href="?act=PRNT&sort=<%=sort%>">Export to Excel</a>
			</td>
			<td width="100%" align="right" class="listItem_Data">
				<table border="0" cellpadding="3" cellspacing="0">
					<tr>
						<td valign="middle" align="left">Deliverability Legend:</td>
						<td valign="middle" align="left">&nbsp;</td>
						<td style="border:1px solid #000000;" valign="middle" align="left" class="delivered">
							<img src="../../images/blank.gif" width="10" height="10">
						</td>
						<td valign="middle" align="left">Delivered</td>
						<td valign="middle" align="left">&nbsp;</td>
						<td style="border:1px solid #000000;" valign="middle" align="left" class="bounced">
							<img src="../../images/blank.gif" width="10" height="10">
						</td>
						<td valign="middle" align="left">Bounced</td>
						<td valign="middle" align="left">&nbsp;</td>
						<td style="border:1px solid #000000;" valign="middle" align="left" class="unknown">
							<img src="../../images/blank.gif" width="10" height="10">
						</td>
						<td valign="middle" align="left">No Data</td>
						<td valign="middle" align="left">&nbsp;</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<br>
	<% } %>
	<table width="100%" border="1" cellpadding="1" cellspacing="0" class="listTable">
		<tr>
			<th width=15%>Customer</th>
			<th width=25%>Campaign</th>
			<th width=10%>Start Date</th>
			<th width=6%>Queued</th>
			<th width=10%>Sent To Mailer</th>
			<th width=6%>Delivered</th>
			<th width=6%>Bounced</th>
			<th width=6%>Accounted %</th>
			<% if (!isExcelReport) { %>
			<th width=16%>Deliverability</th>
			<% } else { %>
			<th width=4%>Delivered %</th>
			<th width=4%>Bounced %</th>
			<th width=4%>Unknown %</th>
			<th width=4%>Not Sent %</th>
			<% } %>
		</tr>
<%
	String sortBy = " ORDER BY cust_id ASC, start_date DESC ";
	if (sort != null) {
		if (sort.equals("custname")) {
			sortBy = " ORDER BY cust_name ASC, start_date DESC ";
		}
		else if (sort.equals("custid")) {
			sortBy = " ORDER BY cust_id ASC, start_date DESC ";
		}
		else if (sort.equals("campdate")) {
			sortBy = " ORDER BY start_date DESC ";
		}
		else if (sort.equals("camppct")) {
			sortBy = " ORDER BY sent_pct DESC ";
		}
		else if (sort.equals("campsize")) {
			sortBy = " ORDER BY recip_total_qty DESC ";
		}
		else if (sort.equals("acctpct")) {
			sortBy = " ORDER BY acct_pct DESC ";
		}
	}
	
	sql = "SELECT cust_id, camp_id, cust_name, camp_name, start_date, recip_total_qty, recip_sent_qty, delivered, bounced, alert, type_id" +
	      "  FROM brite_campaign WITH(NOLOCK)" + sortBy;
	rs = stmt.executeQuery(sql);
	while (rs.next()) {
		String cust_id = rs.getString(1);
		String camp_id = rs.getString(2);
		String cust_name = rs.getString(3);
		String camp_name = rs.getString(4);
		String start_date = rs.getString(5);
		int recip_total_qty = rs.getInt(6);
		int recip_sent_qty = rs.getInt(7);
		int pmta_delivered = rs.getInt(8);
		int pmta_bounced = rs.getInt(9);
		String alert = rs.getString(10);
		if (alert == null || alert == "") {
			alert = "OK";
		}
		String type_id = rs.getString(11);
		String type_name = "std";
		if (type_id != null && type_id.equals("1")) {
			type_name = "test";
		}	
		// calculations
		int sentPct = 0;
		try {
			sentPct = 100 * recip_sent_qty / recip_total_qty;
		}
		catch (Exception ex) {}

	 	int deliveredPct = 0; 
		try {
			deliveredPct = 100 * pmta_delivered / recip_total_qty;
		}
		catch (Exception ex) {}
	  
		int bouncedPct = 0;
		try {
			bouncedPct = 100 * pmta_bounced / recip_total_qty;
		}
		catch (Exception ex) {}
		  
		int acctPct = 0; 
		try {
			acctPct = 100 * (pmta_delivered + pmta_bounced) / recip_sent_qty;
		}
		catch (Exception ex) {}

		int unknownPct = 0; 
		try {
			unknownPct = 100 * (recip_sent_qty - pmta_delivered - pmta_bounced) / recip_total_qty;
		}
		catch (Exception ex) {}

		int notSentPct = 0; 
		try {
			notSentPct = 100 * (recip_total_qty - recip_sent_qty) / recip_total_qty;
		}
		catch (Exception ex) {}
		
%>
		<tr> 
			<td width=15% align="left" class="listItem_Data">
				<%= cust_name %> &nbsp; (<%= cust_id %>)
			</td>
			<td width=25% align="left" class="listItem_Data">
				<%= camp_name %> &nbsp; (<%= camp_id %>) &nbsp [<%= type_name %>]
			</td>
			<td width=10% align="left" class="listItem_Data">
				&nbsp;<%= start_date.substring(0,16) %>&nbsp;
			</td>
			<td width=6% align="right" class="listItem_Data">
				<%= recip_total_qty %>&nbsp;
			</td>			
			<td width=10% align="right" class="listItem_Data">
				<%= recip_sent_qty %> &nbsp; (<%= sentPct %>%)&nbsp; 
			</td>
			<td width=6% align="right" class="listItem_Data">
				<%= pmta_delivered %>&nbsp;
			</td>
			<td width=6% align="right" class="listItem_Data">
				<%= pmta_bounced %>&nbsp;
			</td>
			<td width=6% align="right" class="listItem_Data">
				<%= acctPct %>%&nbsp;
			</td>
			<% if (!isExcelReport) { %>
			<td width=16% align="left" class="listItem_Data" >
<%      if (!isHM) {  %>
				<table width="95%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<% if (deliveredPct > 0) { %>
							<td width="<%= deliveredPct %>%" valign="middle" align="center" class="delivered">
								<img src="../img/blank.gif" width="1" height="10">
							</td>
						<% } %>
						<% if (bouncedPct > 0) { %>	
							<td width="<%= bouncedPct %>%" valign="middle" align="center" class="bounced">
								<img src="../img/blank.gif" width="1" height="10">
							</td>
						<% } %>
						<% if (unknownPct > 0) { %>	
							<td width="<%= unknownPct %>%" valign="middle" align="center" class="unknown">
								<img src="../img/blank.gif" width="1" height="10">
							</td>
						<% } %>
						<% if (notSentPct > 0) { %>	
							<td width="<%= notSentPct %>%" valign="middle" align="center" class="notsent">
								<img src="../img/blank.gif" width="1" height="10">
							</td>
						<% } %>
					</tr>
				</table>
<%      } 
        else { %>
			<%= alert %>
<%      } %>				
			</td>
			<% } else { %>
			<td width=4% align="right" class="listItem_Data">
				<%= deliveredPct %>%&nbsp;
			</td>
			<td width=4% align="right" class="listItem_Data">
				<%= bouncedPct %>%&nbsp;
			</td>
			<td width=4% align="right" class="listItem_Data">
				<%= unknownPct %>%&nbsp;
			</td>
			<td width=4% align="right" class="listItem_Data">
				<%= notSentPct %>%&nbsp;
			</td>									
			<% } %>
		</tr>

			
<%  }
	rs.close();
}
catch (Exception ex) {}
finally {
	try	 {
		if ( stmt != null ) stmt.close();
	}
	catch (SQLException se1) { }
	try	 {
		if ( conn != null ) conn.close(); 
	}	
	catch (SQLException se2) { }
}
%>
	</table>
</BODY>
</html>