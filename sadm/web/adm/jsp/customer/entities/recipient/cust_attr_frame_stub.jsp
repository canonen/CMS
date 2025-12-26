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
<%@ include file="/adm/jsp/header.jsp" %>
<%
	String sCustId = BriteRequest.getParameter(request, "cust_id");
	String sAttrId = BriteRequest.getParameter(request, "attr_id");

	String sRequestString="";

	sRequestString += (sCustId==null)?"":"cust_id=" + sCustId + "&";
	sRequestString += (sAttrId==null)?"":"attr_id=" + sAttrId;
%>

<HTML>
<HEAD>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../../css/style.css" TYPE="text/css">

<% if(sAttrId!=null) { %>
	<SCRIPT>
		self.location.href="cust_attr_edit.jsp?<%=sRequestString%>";
	</SCRIPT>
<% } %>

</HEAD>

<BODY>
</BODY>
</HTML>
