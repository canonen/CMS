<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.sql.*,
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
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("custom_export_list.jsp");
	stmt = conn.createStatement();

	String		sExpName	= "";
	String		sExpID		= "";
	String		sCustName	= "";
	String		sCustID		= "";

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
<BASE target="task">
</HEAD>

<BODY>
<TABLE class=main cellpadding=1 cellspacing=1 WIDTH="650"> 
<TR>

<TH>Customer</TH><TH>Export name</TH></TR>
<%
	  	rs = stmt.executeQuery(
			"SELECT e.cstm_exp_id, e.exp_name, e.cust_id, c.cust_name " +
			"FROM cexp_custom_export e, ccps_customer c " +
			"WHERE e.cust_id = c.cust_id " +
			"ORDER BY e.cust_id, e.cstm_exp_id");
		boolean isOne = false;
		while (rs.next()) { 
			isOne = true;
			sExpID   = rs.getString(1);
			sExpName = new String(rs.getBytes(2),"ISO-8859-1");
			sCustID = rs.getString(3);
			sCustName = new String(rs.getBytes(4),"ISO-8859-1");
			%>
			<TR>
			<TD><%=sCustName%>
			<TD><A HREF="custom_export_edit.jsp?exp_id=<%=sExpID%>" target="_self"> <%=sExpName%> </A></TD>
			</TR>
			<%
		} rs.close();
		
		if (!isOne) {
			%>
			<TR><TD></TD><TD>No custom exports defined.</TD></TR>
			<%
		}
%>
</TABLE>
<A HREF="custom_export_edit.jsp" target="_self">New</A>
</BODY>

<%

	} catch(Exception ex) {
		ErrLog.put(this,ex,"custom_export_list.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
</HTML>
