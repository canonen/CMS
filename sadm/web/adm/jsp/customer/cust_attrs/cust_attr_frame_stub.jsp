<%@ page

	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, com.britemoon.sas.adm.*, java.io.*,java.sql.*,java.util.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%
	String sCustId = BriteRequest.getParameter(request, "cust_id");
	String sAttrId = BriteRequest.getParameter(request, "attr_id");

	String sRequestString="";

	sRequestString += (sCustId==null)?"":"cust_id=" + sCustId + "&";
	sRequestString += (sAttrId==null)?"":"attr_id=" + sAttrId;
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="../../../css/style.css" TYPE="text/css">

<% if(sAttrId!=null) { %>
	<SCRIPT>
		self.location.href="cust_attr_edit.jsp?<%=sRequestString%>";
	</SCRIPT>
<% } %>

</HEAD>

<BODY>
</BODY>
</HTML>
