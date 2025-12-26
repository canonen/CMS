<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.imc.*, 
			java.sql.*, 
			java.io.*, 
			java.util.*, 
			java.net.*, 
			org.w3c.dom.*, 
			javax.servlet.*, 
			javax.servlet.http.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../jsp/header.jsp"%>
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
	
	String sURL = request.getParameter("url");
	
	Customer cust = new Customer(null, sCustLogin);
	boolean bIsCustActive = ((cust.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id)))?true:false;

	User user = new User(null, sUserLogin, cust.s_cust_id);
	boolean bIsUserActive = ((user.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id)))?true:false;
	boolean bIsPasswordValid = ((user.s_password != null) && (user.s_password.equals(sPassword)))?true:false;

	if ( bIsCustActive && bIsUserActive && bIsPasswordValid)
	{
		session = request.getSession(true);
		UIEnvironment ui = new UIEnvironment(session, user, cust);
		
		response.sendRedirect("/cms/ui/jsp/" + sURL);

		SessionMonitor.update(session, request.getRequestURI());
	}
	else
	{
		SessionMonitor.update(session, request.getRequestURI());
		session.invalidate();
%>

<HTML>

<HEAD>
	<TITLE>Login</TITLE>
	<SCRIPT>

	function putFocus()
	{
		if (login_form.company.value=='')login_form.company.focus();
		else if (login_form.login.value=='')login_form.login.focus();
		else if (login_form.password.value=='')login_form.password.focus();
	}

	</SCRIPT>
</HEAD>

<BODY bgcolor=#dddddd onLoad="putFocus(0,1);">

<FORM method="POST" action="loginurl.jsp" name="login_form">

<font face=arial size=1>
<center><br><br><br><br><br><br><table bgcolor=#aaaaaa width=250 cellpadding=1 cellspacing=1>
<tr>
<td bgcolor=#ffffff width=250>
  <TABLE style="font-family:arial;color:#555555;font-size:10px;" border="0" align="left" cellpadding=3 cellspacing=1>
    
<tr>
<td style="font-family:arial;color:#990000;font-size:10px;" colspan=2 align=center>Your login information is incorrect.  Please try again or contact support for assistance.</td>
</tr>
<TR>
	<TD></TD>
    <TD align="left" valign=bottom>&nbsp;<IMG border="0" src="../images/logologin.gif"></TD>
      
    </TR>
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
			<TD align="center" colspan="2"><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="submit" value="Submit"></TD>
		</TR>
	</TABLE>
</FORM>
</BODY>

</HTML>

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
