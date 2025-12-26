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
String sCustId = BriteRequest.getParameter(request, "cust_id");

ImgCustRefreshInfo icri = new ImgCustRefreshInfo();

icri.s_cust_id = sCustId;
icri.s_domain_prefix = BriteRequest.getParameter(request, "domain_prefix");
icri.s_refresh_url = BriteRequest.getParameter(request, "refresh_url");
icri.s_immediate_refresh_flag = BriteRequest.getParameter(request, "immediate_refresh_flag");
icri.s_login_id = BriteRequest.getParameter(request, "login_id");
icri.s_login_pwd = BriteRequest.getParameter(request, "login_pwd");
icri.s_last_refresh_date = BriteRequest.getParameter(request, "last_refresh_date");
	
icri.save();
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "img_cust_refresh_info.jsp?cust_id=<%=sCustId%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
