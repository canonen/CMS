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
	<TITLE>Machine</TITLE>
	<%@ include file="../header.html" %>
	<LINK rel="stylesheet" href="../../css/style.css" type="text/css">
</HEAD>

<BODY bgcolor="#FFFFFF">

<%
ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
PreparedStatement prepStmt = null;
String sSQL = null;

String sMachineID = BriteRequest.getParameter(request, "machine_id");
String sMachineName = BriteRequest.getParameter(request, "machine_name");
String sIPAddr = BriteRequest.getParameter(request, "ip_addr");
%>

<%
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("machine_save.jsp");

	if ((sMachineID == null) || (sMachineID.trim().length() < 1)) {
		sSQL = "INSERT sadm_machine (machine_name, ip_address) VALUES (?,?)";
		prepStmt = conn.prepareStatement(sSQL);
	} else {
		sSQL = "UPDATE sadm_machine SET machine_name=?, ip_address=? WHERE machine_id = "+sMachineID;
		prepStmt = conn.prepareStatement(sSQL);
	}
	
	prepStmt.setString(1, sMachineName);
	prepStmt.setString(2, sIPAddr);
	
	prepStmt.executeUpdate();
	
	prepStmt.close();
	
%>
Machine saved.
<%

} catch(Exception ex) {
	out.print(sSQL);
	ex.printStackTrace(response.getWriter());
} finally {
	if(conn!=null) cp.free(conn);
}

%>
</BODY>
</HTML>
