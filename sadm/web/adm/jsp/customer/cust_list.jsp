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
<%@ include file="../header.jsp" %>
<HTML>
<HEAD>
	<TITLE>Customer List</TITLE>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
</HEAD>
<BODY>
<br>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="cust_edit_frame.jsp">New Customer</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left" nowrap>
			<a class="resourcebutton" href="cust_unique_ids/cust_unique_ids_monitor.jsp">Check Unique IDs</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table class="listTable" width="300" cellspacing="0" cellpadding="2" border="0">
	<tr>
		<th nowrap>Customers</th>
		<th nowrap>ID</th>
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
	conn = cp.getConnection("mod_customer.jsp");
	stmt = conn.createStatement();

	sSQL =
		" SELECT cust_id, cust_name" +
		" FROM sadm_customer" +
		" WHERE cust_id <> 619 ORDER BY cust_name";

 	rs = stmt.executeQuery(sSQL);
	String sCustId = null;
	String sCustName = null;
	
	int iCount = 0;
	String sClassAppend = "";

	while(rs.next())
	{
		if (iCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";
		
		++iCount;
				
		sCustId = rs.getString(1);
		sCustName = new String(rs.getBytes(2),"UTF-8");
		%>
	<tr>
		<td class="listItem_Title<%= sClassAppend %>"><a href="cust_edit_frame.jsp?cust_id=<%= sCustId %>"><%= sCustName %></a>&nbsp;</td>
		<td class="listItem_Data<%= sClassAppend %>"><%= sCustId %>&nbsp;</td>
	</tr>
		<%
	}
	rs.close();
}
catch(Exception ex)
{
	ex.printStackTrace(response.getWriter());
	logger.error("Exception: ",ex);
}
finally
{
	if(conn!=null) cp.free(conn);
}
%>
</table>
</BODY>
</HTML>
