<%@ page
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.net.*"
	import="java.sql.*"
	import="java.text.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<html>
<head>
<title>System Announcement</title>
<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
</head>
<body>
<table cellspacing="0" cellpadding="0" width="100%" height="100%" border="0">
	<tr>
		<td valign="center" nowrap align="left" style="padding:0px;">
			<table cellspacing="0" cellpadding="1" border="0" class="systemTable layout" style="width:100%; height:100%;">
				<col>
				<col>
<%
String sNoteId = request.getParameter("note_id");

ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 

try
{

	if (sNoteId != null)
	{
		//nothing
	}
	else
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("system_note_get.jsp");
		stmt = conn.createStatement();

		String sSql = "SELECT TOP 1 note_id FROM sadm_system_note WHERE published = 1 ORDER BY modify_date DESC";

		rs = stmt.executeQuery(sSql);

		if (rs.next()) sNoteId = rs.getString(1);

		rs.close();
	}
}
catch(Exception ex)
{ 
	logger.error("Exception:", ex);
	throw ex;
}
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception e) {}
	if (conn != null) cp.free(conn);
}

SystemNote note = new SystemNote();
logger.info("retrieving " + sNoteId);

if (sNoteId != null && !sNoteId.equals("null"))
{
	note.s_note_id = sNoteId;
	int nRetrieve = note.retrieve();
	%>
    <input type=hidden name=noteid value="<%=note.s_note_id%>">
    <tr height="25">
		<td colspan="2" class="SystemMenuBar" align="left" valign="middle">
			<b>Subject:</b>&nbsp;<%= note.s_subject %>
		</td>
	</tr>
	<tr height="25">
		<td class="SystemMenuBar" align="left" valign="middle">
			<b>From:</b>&nbsp;Revotas Support
		</td>
		<td class="SystemMenuBar" align="right" valign="middle">
			<b>Date:</b>&nbsp;<%= note.s_modify_date %>
		</td>
	</tr>
	<tr>
		<td colspan="2" align="left" valign="top" style="padding:0px;">
			<div style="width:100%; height:100%; overflow:auto; padding:10px;">
			<%= note.s_body %>
			</div>
		</td>
	</tr>
	<%
}
else
{
	%>
	<tr>
		<td colspan="2">There are currently no system notices</td>
	</tr>
	<%
}
%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
