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
	String sUserId = BriteRequest.getParameter(request, "system_user_id");

	String sRequestString=null;

	if(sUserId!=null)
	{
		sRequestString = (sUserId==null)?"":"system_user_id=" + sUserId;
	}
%>

<HTML>

<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
</HEAD>

<FRAMESET cols="320,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="left_02" src="user_edit_menu.jsp?<%=sRequestString%>">
	<FRAME name="main_02" src="user_edit_frame_stub.jsp?<%=sRequestString%>">
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
	</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>
