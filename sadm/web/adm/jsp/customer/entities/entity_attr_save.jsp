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
String sEntityId = BriteRequest.getParameter(request, "entity_id");
String sAttrId = BriteRequest.getParameter(request, "attr_id");

// === === ===

EntityAttr ea = new EntityAttr();

ea.s_attr_id = sAttrId;
ea.s_entity_id = sEntityId;
ea.s_attr_name = BriteRequest.getParameter(request,"attr_name");
ea.s_type_id = BriteRequest.getParameter(request,"type_id");
ea.s_fingerprint_seq = BriteRequest.getParameter(request,"fingerprint_seq");
ea.s_internal_id_flag = BriteRequest.getParameter(request,"internal_id_flag");
ea.s_scope_id = BriteRequest.getParameter(request,"scope_id");

ea.save();

// === === ===
%>

<HTML>
<HEAD>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../../css/style.css" TYPE="text/css">
	<SCRIPT>
		parent.location.href = "entity_edit_frame.jsp?entity_id=<%=ea.s_entity_id%>&attr_id=<%=ea.s_attr_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
