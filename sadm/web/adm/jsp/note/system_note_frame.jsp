<%@ page

	language="java"
	import="com.britemoon.*, com.britemoon.sas.*,java.io.*,java.sql.*,java.util.*"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>

<HTML>

<HEAD>
	<TITLE></TITLE>
	<%@ include file="../header.html" %>
</HEAD>

<FRAMESET cols="400,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="left_01" src="system_note_list.jsp">
	<FRAME name="main_01" src="../w_left.jsp" scrolling="auto">
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
	</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>
