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
String sEntityId = BriteRequest.getParameter(request, "entity_id");

// === === ===

Entity e = new Entity();

e.s_entity_id = sEntityId;
e.s_cust_id = sCustId;
e.s_entity_name = BriteRequest.getParameter(request,"entity_name");
e.s_scope_id = "300"; //BriteRequest.getParameter(request,"scope_id");

e.save();

// === === ===
%>

<HTML>
<HEAD>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../../css/style.css" TYPE="text/css">
	<SCRIPT>
		parent.parent.location.href = "entities_frame.jsp?cust_id=<%=e.s_cust_id%>&entity_id=<%=e.s_entity_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
