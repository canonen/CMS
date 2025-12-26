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
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<html>
<head>
<title>User Note</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
</head>
<body>
	<table cellspacing="0" cellpadding="3" border="0" class="listTable layout" style="width:100%; height:100%;">
		<col>
		<col>
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
		String sSql = "SELECT TOP 1 note_id FROM chom_user_note WHERE cust_id = " + cust.s_cust_id + " AND admin=0 AND published = 1 ORDER BY modify_date DESC";
		rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			sNoteId = rs.getString(1);
		}
		rs.close();
	}
	catch(Exception ex)	{ 
		ErrLog.put(this,ex,"user_note_get.jsp",out,1);	
	}
	finally {
		try { if (stmt != null) stmt.close(); }
		catch(Exception e) {}
		if (conn != null) cp.free(conn);
	}
}


UserNote note = new UserNote();
//System.out.println("retrieving " + sNoteId);
if (sNoteId != null && !sNoteId.equals("null")) {
	note.s_note_id = sNoteId;
	int nRetrieve = note.retrieve();
%>
    <input type=hidden name=noteid value="<%=note.s_note_id%>">
    <tr height="25">
		<td colspan="2" class="MenuBar" align="left" valign="middle">
			<b>Subject:</b>&nbsp;<%= note.s_subject %>
		</td>
	</tr>
	<tr height="25">
		<td class="MenuBar" align="left" valign="middle">
			<b>From:</b>&nbsp;<%= note.s_user_name %>
		</td>
		<td class="MenuBar" align="right" valign="middle">
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
else {
%>
    <tr>
		<td colspan="2">There are currently no user notes</td>
	</tr>
<%
}
%>
</body>
</html>
