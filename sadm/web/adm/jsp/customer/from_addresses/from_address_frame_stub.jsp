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
	String sFromAddressId = BriteRequest.getParameter(request, "from_address_id");

	String sRequestString="";

	sRequestString += (sCustId==null)?"":"cust_id=" + sCustId + "&";
	sRequestString += (sFromAddressId==null)?"":"from_address_id=" + sFromAddressId;
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="../../../css/style.css" TYPE="text/css">
<%
if(sFromAddressId!=null)
{
%>
	<SCRIPT>
		self.location.href="from_address_edit.jsp?<%=sRequestString%>";
	</SCRIPT>
<%
}
%>
</HEAD>

<BODY>
</BODY>
</HTML>
