<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			java.sql.*,java.io.*,
			java.util.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

     String sApprovalId = BriteRequest.getParameter(request,"approval_id");
     ApprovalTask atApprovalTask = null;
     String sObjectTypeName = null, sObjectName = null;
     if (sApprovalId != null) {
          atApprovalTask = new ApprovalTask(sApprovalId);
          sObjectTypeName = ObjectType.getDisplayName(Integer.parseInt(atApprovalTask.s_object_type));
          sObjectName = WorkflowUtil.getObjectName(Integer.parseInt(atApprovalTask.s_object_type), atApprovalTask.s_object_id);
     }
     else
          throw new Exception("Cannot retrieve Approval Request History.  No Approval ID supplied.");

    	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs = null;

	String sSql = null;

     String sErrors = null;
     String sClassAppend = "";

%>

<html>
<head>
<title>Approval Request History</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>

<body>
<form name="FT" method="post" action="pending_assets.jsp">

<br>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Approval Request History for <%=sObjectTypeName + ": " + sObjectName%>
			<br><br>
			<table cellspacing="0" cellpadding="2" border="0" class="listTable layout" style="width:100%;">
				<col width="25">
				<col width="40">
				<col>
				<col width="40">
				<col width="150">
		<%
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();
			String sRequestId = null, sRequestor = null, sApprover = null, sRequestDate = null;
			String sDispositionDate = null, sDisposition = null, sRequestComment = null, sAprvlComment = null;
			String sReturnPage = null;
			
			String ResponseClass = "";

			int iRequestCount = 0;

			rs = stmt.executeQuery("Exec usp_ccps_approval_request_list_get "+cust.s_cust_id + ", " + sApprovalId);
			while (rs.next())
			{
				sRequestId = rs.getString(1);
				sRequestor = rs.getString(2);
				sApprover = rs.getString(3);
				sRequestDate = rs.getString(4);
				sDispositionDate = rs.getString(5);
				sDisposition = rs.getString(6);
				sRequestComment = rs.getString(7);
				sAprvlComment = rs.getString(8);

				if (iRequestCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";

				iRequestCount++;
				%>
				<tr height="25" class="ApproveRequestMenuBar">
					<td colspan="5" align="left" valign="middle">
					<b>Request for Approval</b>
					</td>
				</tr>
				<tr height="25" class="ApproveRequestMenuBar">
					<td colspan="2" align="left" valign="middle"><b>From:</b></td>
					<td align="left" valign="middle"><%= sRequestor %></td>
					<td align="left" valign="middle"><b>Date: </b></td>
					<td align="left" valign="middle"><%= sRequestDate %></td>
				</tr>
				<tr>
					<td colspan="5" align="left" valign="middle" style="padding:10px;">
						<%=(sRequestComment == null)?" --":sRequestComment.replaceAll("\n", "<br>")%>
					</td>
				</tr>
			<%
			if (sDispositionDate != null)
			{
				if (sDisposition.equals("REJECT"))
				{
					ResponseClass = "RejectResponseMenuBar";
				}
				else
				{
					ResponseClass = "ApproveResponseMenuBar";
				}
				%>
				<tr>
					<td>&nbsp;</td>
					<td colspan="4" style="padding:10px;">
						<table cellspacing="0" cellpadding="2" border="0" class="listTable layout" style="width:100%;">
							<col width="40">
							<col>
							<col width="40">
							<col width="150">
							<tr height="25" class="<%= ResponseClass %>">
								<td colspan="4" align="left" valign="middle"><b>Approval Status: <%= sDisposition %></b></td>
							</tr>
							<tr height="25" class="<%= ResponseClass %>">
								<td align="left" valign="middle"><b>From:</b></td>
								<td align="left" valign="middle"><%= sApprover %></td>
								<td align="left" valign="middle"><b>Date: </b></td>
								<td align="left" valign="middle"><%= sDispositionDate %></td>
							</tr>
							<tr>
								<td align="left" valign="middle" colspan="4" style="padding:10px;">
								<%=(sAprvlComment == null)?" --":sAprvlComment.replaceAll("\n", "<br>")%>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<%
			}
			%>
			</table>
			<br>
			<table cellspacing="0" cellpadding="2" border="0" class="listTable layout" style="width:100%;">
				<col width="25">
				<col width="40">
				<col>
				<col width="40">
				<col width="150">
			<%
		}
		%>
			</table>
		</td>
	</tr>
</table>
<br><br>
<%
}
catch(Exception ex) { throw ex; }
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception ex) {}
	if (conn != null) cp.free(conn);
}
%>
</body>
</html>