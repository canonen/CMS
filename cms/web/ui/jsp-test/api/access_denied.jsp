<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,java.net.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="header.jsp"%>

<HTML>

<HEAD>
	<TITLE>Login</TITLE>
	<BASE target="_self">
<link rel="stylesheet" href="/cms/ui/ooo/style.css" TYPE="text/css"/>
</HEAD>
<BODY>
<BR><BR><BR>
<center>
<table width=300>
<tr>
<td class=sectionheader>You do not have access to view this page.  <br><br>Please contact your Admin user to give you access for this task.</td>
</td>
</tr>
</table>
<BR><BR><BR>
</BODY>

</HTML>
