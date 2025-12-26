<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
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

Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool		cp				= null;
Connection			conn 			= null;

try	{

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("super_camp_list.jsp");
	stmt = conn.createStatement();

	String htmlSuperCamps = "";
	
	String sSql = "SELECT super_camp_id, super_camp_name " +
				  "FROM cque_super_camp  " +
				  "WHERE cust_id = "+cust.s_cust_id+" " +
				  "ORDER BY super_camp_id";
	rs = stmt.executeQuery(sSql);
	while (rs.next()) {
	
		htmlSuperCamps += "<TR><TD><a href=super_camp_edit.jsp?super_camp_id="+rs.getString(1)+">"+new String(rs.getBytes(2),"UTF-8")+"</a></TD></TR>\n";
	
	}
	
	if (htmlSuperCamps.length() == 0)
		htmlSuperCamps = "<TR><TD>None</TD></TR>\n";
	
	
%>
<html>
<head>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</head>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="newbutton" href="super_camp_edit.jsp">New</a>
		</td>
	</tr>
</table>
<br>

<TABLE class=main WIDTH="600" cellpadding=2 cellspacing=1>
<TR><TH>Super Campaigns</TH></TR>
<%= htmlSuperCamps %>
</TABLE>
<br><br>
</body>
</html>

<%

} catch(Exception ex) {
	ErrLog.put(this,ex,"super_camp_list.jsp",out,1);
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
