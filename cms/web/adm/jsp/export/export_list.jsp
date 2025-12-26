<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.imc.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%@ include file="../header.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

try {
	String sql = "";

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("adm/export_list.jsp");
	stmt = conn.createStatement();

	String custID = request.getParameter("cust_id");
	if (custID == null) custID = "0";

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<FORM  METHOD="GET" NAME="FT" ACTION="export_list.jsp" TARGET="_self">
Customer ID: (0 for all) <INPUT name="cust_id" size=10 type="text" value="<%= custID %>">
<INPUT TYPE=submit>
</FORM>
<br>
<table border=1>
<tr>
<th>Customer</th><th>Export Name</th><th>Status</th>
<th>File URL</th><th>Export Parameters</th>
</tr>

<%

	sql = "SELECT e.cust_id, e.export_name, ISNULL(s.display_name, s.status_name), e.file_url, ISNULL(e.params,'&nbsp;') " +
		  "FROM cexp_export_file e WITH(NOLOCK), cexp_export_status s " +
		  "WHERE e.type_id = 1 " +
		  "AND ISNULL(e.status_id, "+ExportStatus.COMPLETE+") = s.status_id " +
		  (!custID.equals("0")?"AND e.cust_id = "+custID:"")+" " +
		  "ORDER BY e.cust_id, e.file_id";

	rs = stmt.executeQuery(sql);
	while (rs.next()) {
		String cust = rs.getString(1);
		String expName = rs.getString(2);
		String status = rs.getString(3);
		String fileUrl = rs.getString(4);
		String params = rs.getString(5);
%>
		<tr>
		<td><%=cust%></td>
		<td><%=expName%></td>
		<td><%=status%></td>
		<td><a href="<%=fileUrl%>"><%=fileUrl%></a></td>
		<td><%=params%></td>
		</tr>
<%
	}

%>
</table>

<%
} catch(Exception ex) {
	ErrLog.put(this,ex,"export_list.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>
</BODY>
</HTML>
