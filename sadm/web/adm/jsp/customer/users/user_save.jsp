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
	User u = new User();

	u.s_user_id = BriteRequest.getParameter(request,"user_id");
	u.s_user_name = BriteRequest.getParameter(request,"user_name");
	u.s_last_name = BriteRequest.getParameter(request,"last_name");
	u.s_cust_id = BriteRequest.getParameter(request,"cust_id");
	u.s_login_name = BriteRequest.getParameter(request,"login_name");
	u.s_password = BriteRequest.getParameter(request,"password");
	u.s_position = BriteRequest.getParameter(request,"position");
	u.s_phone = BriteRequest.getParameter(request,"phone");
	u.s_email = BriteRequest.getParameter(request,"email");
	u.s_descrip = BriteRequest.getParameter(request,"descrip");
	u.s_status_id = BriteRequest.getParameter(request,"status_id");
	u.s_recip_owner = BriteRequest.getParameter(request,"recip_owner");
	//added for release 5.9 , pviq changes
	u.s_pv_login = BriteRequest.getParameter(request, "pv_login");
	u.s_pv_password = BriteRequest.getParameter(request, "pv_password");

	// === === ===

	UserUiSettings uus = new UserUiSettings();

	uus.s_user_id = BriteRequest.getParameter(request,"user_id");
	uus.s_ui_type_id = BriteRequest.getParameter(request,"ui_type_id");
	uus.s_recip_view_count = BriteRequest.getParameter(request,"recip_view_count");
	uus.s_default_page_size = BriteRequest.getParameter(request,"default_page_size");		

	u.m_UserUiSettings = uus;

	// === === ===

	u.save();
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		parent.location.href = "user_edit_frame.jsp?user_id=<%=u.s_user_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
