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

CustSendParam csp = new CustSendParam();

csp.s_cust_id = BriteRequest.getParameter(request, "cust_id");
csp.s_error_to_address = BriteRequest.getParameter(request, "error_to_address");
csp.s_sender_address = BriteRequest.getParameter(request, "sender_address");

csp.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "cust_send_param_edit.jsp?cust_id=<%=csp.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
