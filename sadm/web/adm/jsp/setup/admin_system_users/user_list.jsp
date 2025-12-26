<%@ page

	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>
<HTML>
<HEAD>
	<TITLE>User List</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../../css/style.css">
</HEAD>
<BODY>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="user_edit_frame.jsp">New System User</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table class="listTable" width="300" cellspacing="0" cellpadding="2" border="0">
	<tr>
		<th nowrap>User Name</th>
	</tr>
<%
ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
String sSQL = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	sSQL =
		" SELECT system_user_id, first_name + ' ' + isnull(last_name, ' ') as 'fullName'" +
		" FROM sadm_system_user" +
		" WHERE status_id < " + UserStatus.DELETED +  
		" ORDER BY last_name";

	rs = stmt.executeQuery(sSQL);

	String sUserId = null;
	String sUserName = null;

	int iCount = 0;
	String sClassAppend = "";

	byte[] b = null;
	while(rs.next())
	{
		if (iCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";

		++iCount;
		
		sUserId = rs.getString(1);
		b = rs.getBytes(2);
		sUserName = (b==null)?null:new String(b,"UTF-8");
%>
	<tr>
		<td class="listItem_Data<%= sClassAppend %>">
			<a href="user_edit_frame.jsp?system_user_id=<%= sUserId %>">
				<%= HtmlUtil.escape(sUserName) %>
			</a>
			&nbsp;
		</td>
	</tr>
<%
	}
	rs.close();
	
	if (iCount == 0)
	{
%>
	<tr>
		<td class="listItem_Data<%= sClassAppend %>">There are currently no system users</td>
	</tr>
<%
	}
}
catch(Exception ex)
{
	ex.printStackTrace(response.getWriter());
}
finally
{
	if(conn!=null) cp.free(conn);
}
%>
</table>
</BODY>
</HTML>
