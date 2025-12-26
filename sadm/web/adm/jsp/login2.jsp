<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, java.sql.*,java.io.*,javax.servlet.*,javax.servlet.http.*, java.util.*,java.net.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.britemoon.cps.UserStatus" %>
<%@ include file="header.jsp"%>
<%
try	
{
	String sPartLogin = request.getParameter("partner");
	String sUserLogin = request.getParameter("login");
	String sPassword = request.getParameter("password");
	
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
	
	String sRedirect = "";
	String sSystemUserId = "";

	Partner part = new Partner(null, sPartLogin);
	
	SystemUser systemuser = new SystemUser(null, sUserLogin, part.s_partner_id);
	sSystemUserId = systemuser.s_system_user_id;
	
	boolean bIsUserActive = ((systemuser.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(systemuser.s_status_id)))?true:false;
	boolean bIsPasswordValid = ((systemuser.s_password != null) && (systemuser.s_password.equals(sPassword)))?true:false;
	
	if (bIsUserActive && bIsPasswordValid)
	{
		session = request.getSession(true);
		UIEnvironment ui = new UIEnvironment(session, systemuser, part);
		
		sRedirect = "index.jsp?login=true";
		
		if (null != sNavTab)
		{
			sRedirect += "&tab=" + sNavTab;
		}
		if (null != sNavSection)
		{
			sRedirect += "&sec=" + sNavSection;
		}
		if ((null != sAltURL) && (!sAltURL.equals("")))
		{
			sRedirect += "&url=" + URLEncoder.encode(sAltURL);
		}
 		
 		response.sendRedirect(sRedirect);
	}
	else
	{		
		session.invalidate();
%>
<html>
<head>
<title>Revotas Administration Module: Login</title>
<script>

function putFocus()
{
	if (login_form.partner.value=='')login_form.partner.focus();
	else if (login_form.login.value=='')login_form.login.focus();
	else if (login_form.password.value=='')login_form.password.focus();
}

</script>
</head>
<body bgcolor=#dddddd onLoad="putFocus();">
<form method="POST" action="login2.jsp" name="login_form">
<input type="hidden" name="tab" value="<%= (sNavTab==null)?"":sNavTab %>">
<input type="hidden" name="sec" value="<%= (sNavSection==null)?"":sNavSection %>">
<input type="hidden" name="url" value="<%= (sAltURL==null)?"":sAltURL %>">
<font face=arial size=1>
<center>
	<br><br><br><br><br><br>
	<table bgcolor=#aaaaaa width=250 cellpadding=1 cellspacing=1>
		<tr>
			<td bgcolor=#ffffff width=250>
				<table style="font-family:arial;color:#555555;font-size:10px;" border="0" align="left" cellpadding=3 cellspacing=1>
					<tr>
						<td style="font-family:arial;color:#990000;font-size:10px;" colspan=2 align=center>Your login information is incorrect.  Please try again or contact support for assistance.</td>
					</tr>
					<tr>
						<td></td>
						<td align="left" valign=bottom>&nbsp;<IMG border="0" src="../../ui/images/logologin.gif"></TD>
					</tr>
					<tr>
						<td align="right">Partner:</TD>
						<td><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="partner" size="32" value="<%=(sPartLogin==null)?"":sPartLogin%>"></TD>
					</tr>
					<tr>
						<td align="right">Login:</TD>
						<td><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="login" size="32" value="<%=(sUserLogin==null)?"":sUserLogin%>"></TD>
					</tr>
					<tr>
						<td align="right">Password:</TD>
						<td><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="password" name="password" size="32" value=""></TD>
					</tr>
					<tr>
						<td align="center" colspan="2"><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="submit" value="Submit"></TD>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</center>
</font>
</form>
</body>
</html>
<%
	}
}
catch(Exception ex)
{
	System.out.println("Error in login2.jsp");
}
finally
{
}
%>
