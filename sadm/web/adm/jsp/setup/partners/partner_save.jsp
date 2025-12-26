<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*" 
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*" 
	import="org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>

<%
	Partner p = new Partner();

	p.s_partner_id = BriteRequest.getParameter(request,"partner_id");
	p.s_partner_name = BriteRequest.getParameter(request,"partner_name");
	
	p.save();
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		location.href = "partner_edit.jsp?partner_id=<%=p.s_partner_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
