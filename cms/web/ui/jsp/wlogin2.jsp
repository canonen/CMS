<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,java.sql.*,
			java.io.*,javax.servlet.*,
			javax.servlet.http.*,java.util.*,
			java.net.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
try	
{
	String sCustLogin = request.getParameter("company");
	String sUserLogin = request.getParameter("login");
	String sPassword = request.getParameter("password");
		
	String sRedirect = "";
	String sUserId = "";

	Customer cust = new Customer(null, sCustLogin);

	boolean bIsCustActive = ((cust.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id)))?true:false;

	User user = new User(null, sUserLogin, cust.s_cust_id);
	sUserId = user.s_user_id;
	boolean bIsUserActive = ((user.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id)))?true:false;
	boolean bIsPasswordValid = ((user.s_password != null) && (user.s_password.equals(sPassword)))?true:false;
	boolean bPasswordExpiring = user.isPassExpiring();
	boolean bPasswordHasExpired = user.isPassHasExpired();
	
	if ( bIsCustActive && bIsUserActive && bIsPasswordValid && (!bPasswordHasExpired))
	{
		session = request.getSession(true);
		UIEnvironment ui = new UIEnvironment(session, user, cust);

		SessionMonitor.update(session, request.getRequestURI());
		
		sRedirect = "/cms/ui/jsp/bilginet/home.jsp";
		 		
 		response.sendRedirect(sRedirect);
		
	}
	else
	{		
		SessionMonitor.update(session, request.getRequestURI());
		
		if (bIsCustActive && bIsUserActive && bIsPasswordValid && bPasswordHasExpired)
		{
			session = request.getSession(true);
			UIEnvironment ui = new UIEnvironment(session, user, cust);
		}
		else
		{
			session.invalidate();
		}
%>
<html>
<head>
<title>Revotas: Login</title>
<script>

function putFocus()
{
	if (login_form.company.value=='')login_form.company.focus();
	else if (login_form.login.value=='')login_form.login.focus();
	else if (login_form.password.value=='')login_form.password.focus();
}

function loadPassChange()
{
	URL = "setup/users/pass_change.jsp?status=2&user_id=<%= sUserId %>";
	windowName = "PassChange";
	windowFeatures = "dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=350, width=400";
   	window.open(URL, windowName, windowFeatures);
}

</script>
<link rel="stylesheet" href="/cms/ui/ooo/style.css" TYPE="text/css"/>
</HEAD>

<body class="login" <% if (!bPasswordHasExpired) { %> onLoad="putFocus();"<% } %>>
	
	
<form method="POST" action="wlogin2.jsp" name="login_form">
<font face=arial size=1>
<center>
	<br><br><br><br><br><br>
	<table width=450 cellpadding=0 cellspacing=0>
	<tr>
		<td><img src="http://cms.revotas.com/cms/ui/ooo/images/nav/revotaslogo.png"/><br><br></td>
</tr>
		<tr>
			<td width=450>
				<table class=listTable align="left" cellpadding=0 cellspacing=0>
				<TR>
							<th colspan=2 align="left" valign=bottom>Sistem Dogrulamasi</th>
		</TR>
				<% if (bIsCustActive && bIsUserActive && bIsPasswordValid && bPasswordHasExpired) { %>
					<tr>
						<td style="font-family:arial;color:#555555;font-size:10px;" colspan=2 align=center>
							<b>Your password has expired!</b><br><br>
							You will be unable to log in until you have changed your password.<br><br>
							<a href="javascript:loadPassChange();">Click here</a> to change your password.
						</td>
					</tr>
				<% } else { %>
					<tr>
						<td style="font-family:arial;color:#990000;font-size:10px;" colspan=2 align=center>Lütfen tekrar deneyin.</td>
					</tr>
					<tr>
						<td align="right">Sirket:</TD>
						<td><INPUT class=logintblinput type="text" name="company" size="32" value="<%=(sCustLogin==null)?"":sCustLogin%>"></TD>
					</tr>
					<tr>
						<td align="right">Kullanici Adi:</TD>
						<td><INPUT class=logintblinput type="text" name="login" size="32" value="<%=(sUserLogin==null)?"":sUserLogin%>"></TD>
					</tr>
					<tr>
						<td align="right">Sifre:</TD>
						<td><INPUT class=logintblinput type="password" name="password" size="32" value=""></TD>
					</tr>
					<tr>
						<td></TD>
						<td align=right><a class="buttons-action" href="#" onclick="document.forms['login_form'].submit()" style="text-align:center;width:100px">Giris</a></TD>
					</tr>
				<% } %>
				</table>
			</td>
		</tr>
	</table>
</center>
</font>
</form>
<!-- Google Code for Email Marketers Remarketing List -->
<script type="text/javascript">
/* <![CDATA[ */
var google_conversion_id = 1055764569;
var google_conversion_language = "en";
var google_conversion_format = "3";
var google_conversion_color = "ffffff";
var google_conversion_label = "i7aeCO-s1gIQ2eC29wM";
var google_conversion_value = 0;
/* ]]> */
</script>
<script type="text/javascript" src="http://www.googleadservices.com/pagead/conversion.js">
</script>
<noscript>
<div style="display:inline;">
<img height="1" width="1" style="border-style:none;" alt="" src="http://www.googleadservices.com/pagead/conversion/1055764569/?label=i7aeCO-s1gIQ2eC29wM&amp;guid=ON&amp;script=0"/>
</div>
</noscript>
</body>
</html>
<%
	}
}
catch(Exception ex)
{
	ErrLog.put(this, ex, "Error in login.jsp", out, 1);
}
finally
{
}
%>
