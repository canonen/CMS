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
	String sMsgId = BriteRequest.getParameter(request, "msg_id");

	String sRequestString="";

	sRequestString += (sCustId==null)?"":"cust_id=" + sCustId + "&";
	sRequestString += (sMsgId==null)?"":"msg_id=" + sMsgId;
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="../../../css/style.css" TYPE="text/css">

<% if(sMsgId!=null) { %>
	<SCRIPT>
		self.location.href="unsub_msg_edit.jsp?<%=sRequestString%>";
	</SCRIPT>
<% } %>

</HEAD>

<BODY>
</BODY>
</HTML>
