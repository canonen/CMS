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

<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
Customer cust = new Customer(sCustId);
if( cust.s_cust_id == null) {
	throw new Exception(this.getClass().getName() + ": cust_id is null");
}
%>
<HTML>

<HEAD>
	<%@ include file="../../header.html" %>
	<BASE target="main_02">
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>

<BODY>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="from_address_edit.jsp?cust_id=<%= cust.s_cust_id %>">New From Address</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table class="listTable" width="300" cellspacing="0" cellpadding="2" border="0">
	<tr>
		<th nowrap>From Address</th>
	</tr>
<%
ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null; 
String sSQL = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	sSQL =
		" SELECT from_address_id, prefix, domain" +
		" FROM scps_from_address" +
		" WHERE cust_id=" + cust.s_cust_id +
		" ORDER BY prefix";

	rs = stmt.executeQuery(sSQL);

	String sFromAddressId = null;
	String sPrefix = null;
	String sDomain = null;
		
	int iCount = 0;
	String sClassAppend = "";

	while(rs.next())
	{
		if (iCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";
		
		++iCount;
		
		sFromAddressId = rs.getString(1);
		sPrefix = rs.getString(2);
		sDomain = rs.getString(3);
		%>
	<tr>
		<td class="listItem_Title<%= sClassAppend %>"><a href="from_address_edit.jsp?from_address_id=<%= sFromAddressId %>"><%= sPrefix %>@<%= sDomain %></a>&nbsp;</td>
	</tr>
		<%
	}
	rs.close();
	
	if (iCount == 0)
	{
		%>
	<tr>
		<td class="listItem_Data">There are currently no From Addresses</td>
	</tr>
		<%
	}
}
catch(Exception ex) { ex.printStackTrace(response.getWriter()); }
finally { if(conn!=null) cp.free(conn); }
%>
</table>
</BODY>
</HTML>
