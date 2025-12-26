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
	<TITLE>Module Instance Service</TITLE>
	<%@ include file="../header.html" %>
	<LINK rel="stylesheet" href="../../css/style.css" type="text/css">
</HEAD>

<BODY bgcolor="#FFFFFF">

<%
ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
PreparedStatement prepStmt = null;
ResultSet rs = null;
String sSQL = null;

String sModInstID = BriteRequest.getParameter(request, "mod_inst_id");
String sServTypeID = BriteRequest.getParameter(request, "service_type_id");
String sProtocol = BriteRequest.getParameter(request, "protocol");
String sPort = BriteRequest.getParameter(request, "port");
String sPath = BriteRequest.getParameter(request, "path");
%>

<%
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("mod_inst_service_save.jsp");
	stmt = conn.createStatement();

	sSQL = "SELECT count(*) FROM sadm_mod_inst_service"
		+ " WHERE mod_inst_id = "+sModInstID
		+ "  AND  service_type_id = "+sServTypeID;
		
	rs = stmt.executeQuery(sSQL);
	int nCount = 0;
	if (rs.next()) nCount = rs.getInt(1);

	if (nCount < 1) {
		sSQL = "INSERT sadm_mod_inst_service (protocol, port, path, mod_inst_id, service_type_id)"
			+ " VALUES (?,?,?,?,?)";
		prepStmt = conn.prepareStatement(sSQL);
	} else {
		sSQL = "UPDATE sadm_mod_inst_service SET protocol=?, port=?, path=?"
			+ " WHERE mod_inst_id=? AND service_type_id=?";
		prepStmt = conn.prepareStatement(sSQL);
	}
	
	prepStmt.setString(1, sProtocol);
	prepStmt.setString(2, sPort);
	prepStmt.setString(3, sPath);
	prepStmt.setString(4, sModInstID);
	prepStmt.setString(5, sServTypeID);
	
	prepStmt.executeUpdate();
	
	prepStmt.close();
	
%>
Module-Instance-Service saved.
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
