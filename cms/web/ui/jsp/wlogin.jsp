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
%>

<HTML>

<HEAD>
	<TITLE>Revotas Login</TITLE>
	<BASE target="_self">

<SCRIPT>

	function putFocus()
	{
		if (login_form.company.value=='')login_form.company.focus();
		else if (login_form.login.value=='')login_form.login.focus();
		else if (login_form.password.value=='')login_form.password.focus();
	}

</SCRIPT>
<link rel="stylesheet" href="/cms/ui/ooo/style.css" TYPE="text/css"/>
</HEAD>

<BODY class="login" onLoad="putFocus();" >
	
	

<FORM method="POST" action="wlogin2.jsp" name="login_form">
	<font face=arial size=1>

<center>
<br><br><br><br><br><br>

<table width=450 cellpadding=0 cellspacing=0>
<tr>
	<td align="center"><img src="http://cms.revotas.com/cms/ui/ooo/images/nav/revotaslogo.png"/><br><br></td>
</tr>
<tr>
<td width=450>

	<TABLE border="0" align="center" cellpadding=0 cellspacing=0 class=listTable>
		<TR>
			<th colspan=2 align="left" valign=bottom>Sistem Dogrulamasi</th>
		</TR>
		<TR>
		<TR>
			<TD align="right">Sirket:</TD>
			<TD><INPUT class=logintblinput type="text" name="company" size="32" value="<%=(sCustLogin==null)?"":sCustLogin%>"></TD>
		</TR>
		<TR>
			<TD align="right">Kullanici Adi:</TD>
			<TD><INPUT class=logintblinput type="text" name="login" size="32" value="<%=(sUserLogin==null)?"":sUserLogin%>"></TD>
		</TR>
		<TR>
			<TD align="right">Sifre:</TD>
			<TD><INPUT class=logintblinput type="password" name="password" size="32" value=""></TD>
		</TR>
		<TR>
			<TD></TD>
			<TD align="right"><a class="buttons-action" href="#" onclick="document.forms['login_form'].submit()" style="text-align:center;width:100px">Giris</a></TD>
		</TR>
	</TABLE>
</td>
</tr>
</table>
</center>

</FORM>
</BODY>

</HTML>
