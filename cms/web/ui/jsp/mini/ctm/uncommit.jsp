<%@ page
	import="org.apache.log4j.*"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="java.io.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.net.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>

<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../wvalidator.jsp"%>
<%

String templateID = request.getParameter("templateID");
String contentID = request.getParameter("contentID");

if (templateID == null) {
	%>Error in uncommit.jsp -- no Template ID was supplied.<%
	return;
}
if (contentID == null) {
	%>Error in uncommit.jsp -- no Content ID was supplied.<%
	return;
}

ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;

connPool = ConnectionPool.getInstance();
conn = connPool.getConnection("uncommit.jsp");
stmt = conn.createStatement();

if (stmt.executeUpdate("UPDATE ctm_pages set status = 'draft' WHERE content_id = " + contentID) != 1) {
     throw new Exception("Error setting template status from uncommit.jsp.");
}

stmt.close();
if (conn != null) connPool.free(conn);

response.sendRedirect("index.jsp");

%>
