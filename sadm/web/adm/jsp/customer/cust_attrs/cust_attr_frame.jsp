<%@ page

	language="java"
	import="com.britemoon.*, com.britemoon.sas.*,java.io.*,java.sql.*,java.util.*"
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
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
</HEAD>

<FRAMESET cols="320,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="left_02" src="cust_attr_list.jsp?<%=sRequestString%>">
	<FRAME name="main_02" src="cust_attr_frame_stub.jsp?<%=sRequestString%>">
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
	</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>
