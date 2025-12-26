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
String sUserId = BriteRequest.getParameter(request, "user_id");
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="../../../css/style.css" TYPE="text/css">

<% if(sUserId!=null) { %>
	<SCRIPT>
		self.location.href = "user_edit.jsp?user_id=<%=sUserId%>";
	</SCRIPT>
<% } %>
</HEAD>

<BODY>
</BODY>
</HTML>
