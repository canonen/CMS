<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.USER);

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<HTML>

<HEAD>
	<TITLE>Customer List</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
	<SCRIPT src="../../../js/scripts.js"></SCRIPT>
</HEAD>

<BODY>
<TABLE width="650">
	<TR>
<%
if(can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="3" border="0" width="650">
		<tr>
			<td align="left" valign="middle">
				<a class="newbutton" href="user_edit.jsp">New User</a>&nbsp;&nbsp;&nbsp;
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Users&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>Name</th>
					<th>Phone</th>
					<th>Email</th>
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
					" SELECT user_id, user_name + ' ' + ISNull(last_name,''), phone, email" +
					" FROM ccps_user" +
					" WHERE cust_id=" + cust.s_cust_id +
					" AND status_id!=" + UserStatus.DELETED +
					" ORDER BY user_name";

 				rs = stmt.executeQuery(sSQL);
				String sUserId = null;
				String sUserName = null;
				String sPhone = null;
				String sEmail = null;
				
				String sClassAppend = "";
				int i = 0;

				while(rs.next())
				{
					if (i % 2 != 0)
					{
						sClassAppend = "_Alt";
					}
					else
					{
						sClassAppend = "";
					}
					
					i++;
					
					sUserId = rs.getString(1);
					sUserName = new String(rs.getBytes(2), "UTF-8");
					sPhone = new String(rs.getBytes(3), "UTF-8");
					sEmail = new String(rs.getBytes(4), "UTF-8");
					%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><a href="user_edit.jsp?user_id=<%= sUserId %>"><%= sUserName %></a></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= sPhone %></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= sEmail %></td>
				</tr>
					<%
				}
				rs.close();
				
				if (i == 0)
				{
					%>
				<tr>
					<td class="listItem_Title" colspan="3">There are currently no Users</td>
				</tr>
					<%
				}
			}
			catch(Exception ex)
			{
				ex.printStackTrace(new PrintWriter(out));
			}
			finally
			{
				if(conn!=null) cp.free(conn);
			}
			%>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>
