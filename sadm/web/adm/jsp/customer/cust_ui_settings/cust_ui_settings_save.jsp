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

CustUiSettings cus = new CustUiSettings();

cus.s_cust_id = BriteRequest.getParameter(request, "cust_id");
cus.s_css_filename = BriteRequest.getParameter(request, "css_filename");
cus.s_frame_dir = BriteRequest.getParameter(request, "frame_dir");
cus.s_config_file = BriteRequest.getParameter(request, "config_file");

cus.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "cust_ui_settings_edit.jsp?cust_id=<%=cus.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
