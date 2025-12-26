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

String sNoteId = request.getParameter("note_id");
String sAction = request.getParameter("action");

ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
String sSql = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	if (sAction != null)
	{
		if (sAction.equals("setdraft"))
		{
			sSql = "update sadm_system_note set published = 0, modify_date = GETDATE() where note_id = '" + sNoteId + "'";
			stmt.executeUpdate(sSql);
			%>
			<html>
			<head>
			<script language="javascript">
                 parent.frames("left_01").location.href = "system_note_list.jsp";
                 parent.frames("main_01").location.href = "../w_left.jsp";
			</script>
			</head>
			<body>
			</body>
			</html>
			<%
			return;
		}
		else if (sAction.equals("publish"))
		{
			sSql = "update sadm_system_note set published = 1, modify_date = GETDATE() where note_id = '" + sNoteId + "'";
			stmt.executeUpdate(sSql);
			%>
			<html>
			<head>
			<script language="javascript">
                 parent.frames("left_01").location.href = "system_note_list.jsp";
                 parent.frames("main_01").location.href = "../w_left.jsp";
			</script>
			</head>
			<body>
			</body>
			</html>
			<%
			return;
		}
	}
}
catch(Exception ex)
{
	logger.error("Exception:", ex);
	throw ex;
}
finally
{
	try
	{
		if (stmt!=null) stmt.close();
	}
	catch (SQLException ignore) { }
		
	if(conn!=null) cp.free(conn);
}
%>