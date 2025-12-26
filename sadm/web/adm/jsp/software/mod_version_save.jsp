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
	<TITLE>Module Version</TITLE>
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

String sModID = BriteRequest.getParameter(request, "mod_id");
String sVersion = BriteRequest.getParameter(request, "version");
%>

<%
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("mod_version_save.jsp");
	stmt = conn.createStatement();

	sSQL = "SELECT count(*) FROM sadm_mod_version"
		+ " WHERE mod_id = "+sModID
		+ "  AND  version = '"+sVersion+"'";
		
	rs = stmt.executeQuery(sSQL);
	int nCount = 0;
	if (rs.next()) nCount = rs.getInt(1);

	if (nCount < 1) {
		sSQL = "INSERT sadm_mod_version (mod_id, version)"
			+ " VALUES (?,?)";
		prepStmt = conn.prepareStatement(sSQL);

		prepStmt.setString(1, sModID);
		prepStmt.setString(2, sVersion);
		prepStmt.executeUpdate();

		prepStmt.close();
	}
%>
Module-Version saved.
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
