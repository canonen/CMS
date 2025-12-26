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
	
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
	
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
			sRedirect += "&url=" + URLEncoder.encode(sAltURL, "UTF-8");
		}
 		
 		response.sendRedirect(sRedirect);

		SessionMonitor.update(session, request.getRequestURI());
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
</head>
<body bgcolor=#dddddd<% if (!bPasswordHasExpired) { %> onLoad="putFocus();"<% } %>>
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
						<td style="font-family:arial;color:#990000;font-size:10px;" colspan=2 align=center>Your login information is incorrect.  Please try again or contact support for assistance.</td>
					</tr>
					<tr>
						<td></td>
						<td align="left" valign=bottom>&nbsp;<IMG border="0" src="../images/logologin.gif"></TD>
					</tr>
					<tr>
						<td align="right">Company:</TD>
						<td><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="company" size="32" value="<%=(sCustLogin==null)?"":sCustLogin%>"></TD>
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
				<% } %>
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
	ErrLog.put(this, ex, "Error in login.jsp", out, 1);
}
finally
{
}
%>
