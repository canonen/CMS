<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,java.net.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp"%>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	//grab query strings
	String sCustLogin = request.getParameter("company");
	String sUserLogin = request.getParameter("login");
	
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
%>

<HTML>

<HEAD>
	<TITLE>Revotas: Login</TITLE>
	<BASE target="_self">

<SCRIPT>

	function putFocus()
	{
		if (login_form.company.value=='')login_form.company.focus();
		else if (login_form.login.value=='')login_form.login.focus();
		else if (login_form.password.value=='')login_form.password.focus();
	}

</SCRIPT>
</HEAD>

<BODY bgcolor=#dddddd onLoad="putFocus();" >

<FORM method="POST" action="login2.jsp" name="login_form">
<input type="hidden" name="tab" value="<%= (sNavTab==null)?"":sNavTab %>">
<input type="hidden" name="sec" value="<%= (sNavSection==null)?"":sNavSection %>">
<input type="hidden" name="url" value="<%= (sAltURL==null)?"":sAltURL %>">
	<font face=arial size=1>

<center>
<br><br><br><br><br><br>

<table bgcolor=#aaaaaa width=250 cellpadding=1 cellspacing=1>
<tr>
<td bgcolor=#ffffff width=250>

	<TABLE style="font-family:arial;color:#555555;font-size:10px;" border="0" align="left" cellpadding=3 cellspacing=1>
		<TR>
			<TD></TD>
			<TD align="left" valign=bottom>&nbsp;<IMG border="0" src="../images/logologin.gif"></TD>
		</TR>
		<TR>
		<TR>
			<TD align="right">Company:</TD>
			<TD><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="company" size="32" value="<%=(sCustLogin==null)?"":sCustLogin%>"></TD>
		</TR>
		<TR>
			<TD align="right">Login:</TD>
			<TD><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="login" size="32" value="<%=(sUserLogin==null)?"":sUserLogin%>"></TD>
		</TR>
		<TR>
			<TD align="right">Password:</TD>
			<TD><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="password" name="password" size="32" value=""></TD>
		</TR>
		<TR>
			<TD></TD>
			<TD align="center"><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="submit" value="Submit"></TD>
		</TR>
	</TABLE>
</td>
</tr>
</table>
</center>

</FORM>
</BODY>

</HTML>
