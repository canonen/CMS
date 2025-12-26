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
	SystemUser u = new SystemUser();

	u.s_system_user_id = BriteRequest.getParameter(request,"system_user_id");
	u.s_partner_id = BriteRequest.getParameter(request,"partner_id");
	u.s_first_name = BriteRequest.getParameter(request,"first_name");
	u.s_last_name = BriteRequest.getParameter(request,"last_name");
	u.s_email_address = BriteRequest.getParameter(request,"email_address");
	u.s_phone = BriteRequest.getParameter(request,"phone");
	u.s_username = BriteRequest.getParameter(request,"username");
	u.s_password = BriteRequest.getParameter(request,"password");
	u.s_status_id = BriteRequest.getParameter(request,"status_id");

	u.save();
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		parent.location.href = "user_edit_frame.jsp?system_user_id=<%=u.s_system_user_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
