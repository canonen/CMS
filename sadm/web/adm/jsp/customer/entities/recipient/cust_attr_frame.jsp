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
	<TITLE></TITLE>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../../css/style.css" TYPE="text/css">
</HEAD>

<FRAMESET cols="320,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="left_03" scrolling="auto" src="cust_attr_list.jsp?<%=sRequestString%>">
	<FRAME name="main_03" scrolling="auto" src="cust_attr_frame_stub.jsp?<%=sRequestString%>">
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
	</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>
