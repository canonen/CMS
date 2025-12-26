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
<%

ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("system_note_list.jsp");
	stmt = conn.createStatement();
	String sClassAppend = "";
	String sSql = "";
%>
<html>
<head>
<title></title>
<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
<script language="JavaScript" src="/sadm/ui/js/scripts.js"></script>
<script language="JavaScript" src="/sadm/ui/js/tab_script.js"></script>
</head>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="system_note_edit.jsp" target="main_01">New System Note</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table class="main" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="left" valign="top" style="padding:0px;">
			<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
				<tr>
					<th align="left" valign="middle" width="65%">Subject</th>
					<th align="left" valign="middle" width="20%" nowrap>Modified Date</th>
					<!--<th align="left" valign="middle" width="15%" nowrap>Status</th>//-->
					<th align="left" valign="middle" width="15%" nowrap>Action</th>
				</tr>
			<%
			String sNoteId = "-999";
			
			String sId = "";
			String sSubj = "";
			String sDate = "";
			String sPub = "";
			
			String sStatus = "";
			String sAction = "";

			sSql = "EXEC usp_sadm_system_note_list_get @exclude_id="+ sNoteId;
			int reportCount = 0;

			rs = stmt.executeQuery(sSql);

			while (rs.next())
			{
				if (reportCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";

				++reportCount;

				sId = rs.getString(1);
				sSubj = rs.getString(2);
				sDate = rs.getString(3);
				sPub = rs.getString(4);
				
				sStatus = "Draft";
				sAction = "---";

				if (sPub.equals("1"))
				{
					sStatus = "Published";
					sAction = "<a href=\"system_note_publish.jsp?action=setdraft&note_id=" + sId + "\">Set to Draft</a>";
				}
				else
				{
					sStatus = "Draft";
					sAction = "<a href=\"system_note_publish.jsp?action=publish&note_id=" + sId + "\">Publish</a>";
				}
				%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="65%"><a href="system_note_edit.jsp?note_id=<%= sId %>" target="main_01"><%= sSubj %></a></td>
					<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="20%" nowrap><%= sDate %></td>
					<!--<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="15%" nowrap><%= sStatus %></td>//-->
					<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="15%" nowrap><%= sAction %></td>
				</tr>
				<%
			}
			rs.close();

			if (reportCount == 0)
			{
				%>
				<tr>
					<td class="listItem_Title" colspan="5" align="left" valign="middle">There are currently no System Notes</td>
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
<%
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
%>
