<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.hom.*,
		java.util.*,java.sql.*,
		java.net.*,java.text.*,
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
//check if in pop up or not
String inWin = request.getParameter("win");
if (inWin == null) inWin = "true";

Customer cSuper = ui.getSuperiorCustomer();
Customer cActive = ui.getActiveCustomer();

%>
<html>
<head>
<title>Admin Note</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
<script language="JavaScript">
	
	function loadAdminNote(note_id)
	{
		var newWin;
        var url = "admin_note_get.jsp?win=true&note_id=" + note_id;
        var windowName = "admin_note";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
</script>
</head>
<body<% if ("false".equals(inWin)) { %> leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" style="padding:0px;"<% } %>>
<%
String sNoteId = request.getParameter("note_id");

if (sNoteId != null) {
	//nothing
} else {

	ConnectionPool		cp				= null;
	Connection			conn 			= null;
	Statement			stmt			= null;
	ResultSet			rs				= null; 

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("welcome.jsp");
		stmt = conn.createStatement();
		String sSql = "SELECT TOP 1 note_id FROM chom_user_note WHERE cust_id = " + cust.s_cust_id + " AND admin=1 AND published = 1 ORDER BY modify_date DESC";
		rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			sNoteId = rs.getString(1);
		}
		rs.close();
	}
	catch(Exception ex)	{ 
		ErrLog.put(this,ex,"admin_note_get.jsp",out,1);	
	}
	finally {
		try { if (stmt != null) stmt.close(); }
		catch(Exception e) {}
		if (conn != null) cp.free(conn);
	}
}


UserNote note = new UserNote();
//System.out.println("retrieving " + sNoteId);

if (sNoteId != null && !sNoteId.equals("null"))
{
	note.s_note_id = sNoteId;
	int nRetrieve = note.retrieve();
	
	String s_body = note.s_body;
	%>
    <input type=hidden name=noteid value="<%=note.s_note_id%>">
	<%
	if ("true".equals(inWin))
	{
		%>
	<table cellspacing="0" cellpadding="3" border="0" class="adminTable layout" style="width:100%; height:100%;">
		<col>
		<tr height="25">
			<td class="AdminMenuBar" align="left" valign="middle">
				<b>From:</b>&nbsp;<%= note.s_user_name %>
			</td>
			<td class="AdminMenuBar" align="right" valign="middle">
				<b>Date:</b>&nbsp;<%= note.s_modify_date %>
			</td>
		</tr>
		<tr height="25">
			<td class="AdminMenuBar" align="left" valign="middle" colspan="2">
				<b>Subject:</b>&nbsp;<%= note.s_subject %>
			</td>
		</tr>
		<tr>
			<td align="left" valign="top" colspan="2">
				<div style="width:100%; height:100%; overflow:auto; padding:10px;">
					<%= s_body %>
				</div>
			</td>
		</tr>
	</table>
		<%
	}
	else
	{
		%>
	<table cellspacing="0" cellpadding="0" width="100%" height="100%" border="0">
		<tr>
			<td valign="center" nowrap align="left">
				<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%; height:100%;">
					<col width="45">
					<col>
					<tr height="20">
						<td align="left" valign="middle" colspan="2"><div style="font-weight:bold; text-overflow:ellipsis; overflow:hidden;"><nobr><%= note.s_subject %></nobr></div></td>
					</tr>
					<tr>
						<td align="left" valign="top" colspan="2">
							<div style="width:100%; height:100%; text-overflow:ellipsis; overflow:hidden; padding:5px;">
								<%= s_body %>
							</div>
						</td>
					</tr>
					<tr height="25">
						<td align="left" valign="bottom">
							<a href="javascript:loadAdminNote('<%= sNoteId %>');">More...</a>
						</td>
						<td align="right" valign="bottom">
							&nbsp;<a target="_top" class="resourcebutton" href="../index.jsp?tab=Home&sec=3">Past Announcements</a>&nbsp;
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
		<%
	}
	%>
	<%
}
else
{
	%>
	<table cellspacing="0" cellpadding="0" width="100%" height="100%" border="0">
		<tr>
			<td colspan="2">There are currently no admin notes</td>
		</tr>
	</table>
	<%
}
%>
</body>
</html>
