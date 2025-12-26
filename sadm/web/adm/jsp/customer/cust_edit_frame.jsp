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

<%
	String sCustId = BriteRequest.getParameter(request, "cust_id");
	String sUserId = BriteRequest.getParameter(request, "user_id");
	
	String main01 = null;

	if (sCustId==null)
	{
		main01 = "cust_edit.jsp";
	}
	else if (sUserId==null)
	{
		main01 = "cust_edit.jsp?cust_id=" + sCustId;
	}
	else
	{
		main01 = "users/user_edit_frame.jsp?cust_id=" + sCustId + "&user_id=" + sUserId;
	}
%>

<HTML>

<HEAD>
	<TITLE></TITLE>
	<%@ include file="../header.html" %>
</HEAD>

<FRAMESET cols="250,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="left_01" src="cust_edit_menu.jsp<%=(sCustId==null)?"":"?cust_id=" + sCustId%>">
	<FRAME name="main_01" src="<%= main01 %>" scrolling="auto">
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
	</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>
