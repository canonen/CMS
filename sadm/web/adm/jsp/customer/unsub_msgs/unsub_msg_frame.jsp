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
	String sMsgId = BriteRequest.getParameter(request, "msg_id");

	String sRequestString="";

	sRequestString += (sCustId==null)?"":"cust_id=" + sCustId + "&";
	sRequestString += (sMsgId==null)?"":"msg_id=" + sMsgId;
%>

<HTML>

<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
</HEAD>

<FRAMESET cols="320,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="left_02" src="unsub_msg_list.jsp?<%=sRequestString%>">
	<FRAME name="main_02" src="unsub_msg_frame_stub.jsp?<%=sRequestString%>">
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
	</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>
