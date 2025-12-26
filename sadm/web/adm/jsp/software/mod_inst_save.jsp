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
<%@ include file="../header.jsp" %>

<HTML>

<HEAD>
	<TITLE>Module Instance</TITLE>
	<%@ include file="../header.html" %>
	<LINK rel="stylesheet" href="../../css/style.css" type="text/css">
</HEAD>

<BODY bgcolor="#FFFFFF">

<%
String sModInstID = BriteRequest.getParameter(request, "mod_inst_id");

ModInst mi = null;
if(sModInstID==null) mi = new ModInst(sModInstID);
else mi = new ModInst(sModInstID);

mi.s_machine_id = BriteRequest.getParameter(request, "machine_id");
mi.s_mod_id = BriteRequest.getParameter(request, "mod_id");
mi.s_version = BriteRequest.getParameter(request, "version");

mi.save();
%>

Module-Instance saved.
</BODY>
</HTML>
