<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*" 
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*" 
	import="org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<HTML>
<HEAD>
	<TITLE>Partner List</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../../css/style.css">
</HEAD>
<BODY>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="partner_edit.jsp">New Partner</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table class="listTable" width="300" cellspacing="0" cellpadding="2" border="0">
	<tr>
		<th nowrap>Partner Name</th>
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
		" SELECT partner_id, partner_name" +
		" FROM sadm_partner" +
		" ORDER BY partner_name";

	rs = stmt.executeQuery(sSQL);

	String sPartnerId = null;
	String sPartnerName = null;

	int iCount = 0;
	String sClassAppend = "";

	byte[] b = null;
	while(rs.next())
	{
		if (iCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";

		++iCount;
		
		sPartnerId = rs.getString(1);
		b = rs.getBytes(2);
		sPartnerName = (b==null)?null:new String(b,"UTF-8");
%>
	<tr>
		<td class="listItem_Data<%= sClassAppend %>">
			<a href="partner_edit.jsp?partner_id=<%= sPartnerId %>">
				<%= HtmlUtil.escape(sPartnerName) %>
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
		<td class="listItem_Data<%= sClassAppend %>">There are currently no partners</td>
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
