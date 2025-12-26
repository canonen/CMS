<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*"
	import="java.sql.*"
	import="java.io.*"
	import="javax.servlet.*"
	import="javax.servlet.http.*"
	import="java.util.*"
	import="java.net.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%!
%>

<%@ include file="header.jsp"%>

<%
	String sCustName = BriteRequest.getParameter(request, "company");
%>

<HTML>

<HEAD>
	<TITLE>Revotas Media Login</TITLE>
	<%@ include file="header.html" %>
	<BASE target="_self">
	<SCRIPT>
if(top!=this)top.location.href=this.location.href;</SCRIPT>
<link rel="stylesheet" href="http://cms.revotas.com/cms/ui/css/style.css" TYPE="text/css"/>
</HEAD>

<BODY class="login">
<font face=arial size=1>
<FORM method="POST" action="login2.jsp">
<center><br><br><br><br><br><br><table  width=250 cellpadding=1 cellspacing=1>
<tr>
<td width=250>

	<TABLE border="0" align="left" cellpadding=3 cellspacing=1>
		<TR>
			<TD></TD>
			<TD align="left" valign=bottom><img src="../images/logo.gif"/></TD>
		</TR>
		<TR>
		<TD>
			Company name:
		</TD>
		<TD>
			<INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="company" size="32" value="<%=(sCustName==null)?"":sCustName%>">
		</TD>
	</TR>
	<TR>
		<TD>
		</TD>
		<TD align="left">
			<INPUT style="font-family:arial;color:#555555;font-size:10px;" type="submit" value="Submit">
		</TD>
	</TR>
</TABLE>

</FORM>
</BODY>

</HTML>
