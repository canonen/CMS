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
AccessPermission admCan = user.getAccessPermission(ObjectType.USER);
boolean isAdmin = false;
boolean isMine = false;

if (admCan.bWrite)
{
    isAdmin = true;   
}
AccessPermission can = user.getAccessPermission(ObjectType.USER_NOTES);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

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
			sSql = "update chom_user_note set admin=0, published = 0, modify_date = GETDATE() where note_id = '" + sNoteId + "' and cust_id = '" + cust.s_cust_id + "'";
			stmt.executeUpdate(sSql);
			%>
			<html>
			<head>
			<script language="javascript">
				location.href = "user_note_list.jsp";
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
			sSql = "update chom_user_note set admin=0, published = 1, modify_date = GETDATE() where note_id = '" + sNoteId + "' and cust_id = '" + cust.s_cust_id + "'";
			stmt.executeUpdate(sSql);
			%>
			<html>
			<head>
			<script language="javascript">
				location.href = "user_note_list.jsp";
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
	ErrLog.put(this, ex, "Error in " + this.getClass().getName() , out, 1);
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
