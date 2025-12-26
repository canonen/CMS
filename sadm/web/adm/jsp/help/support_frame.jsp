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
<html>
<head>
	<title></title>
	<%@ include file="../header.html" %>
</head>
<frameset cols="400,*" framespacing="0" border="0" frameborder="0">
	<frame name="left_01" src="support_list.jsp">
	<frame name="main_01" src="../w_left.jsp" scrolling="auto">
	<noframes>
	<body>
		<p>This page uses frames, but your browser doesn't support them.</p>
	</body>
	</noframes>
</frameset>
</html>