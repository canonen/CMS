<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			javax.servlet.*,javax.servlet.http.*,
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
try	
{
	String sCustID = request.getParameter("c");
	String checkHyatt = request.getParameter("h");
	
	boolean isHyatt = false;
	
	if ("true".equals(checkHyatt)) isHyatt = true;
	
	String sCustLogin = request.getParameter("company");
	String sUserLogin = request.getParameter("login");
	String sPassword = request.getParameter("password");
	
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
	
	String sRedirect = "";

	Customer cust = new Customer(null, sCustLogin);
	boolean bIsCustActive = ((cust.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id)))?true:false;

	User user = new User(null, sUserLogin, cust.s_cust_id);
	boolean bIsUserActive = ((user.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id)))?true:false;
	boolean bIsPasswordValid = ((user.s_password != null) && (user.s_password.equals(sPassword)))?true:false;

	if ( bIsCustActive && bIsUserActive && bIsPasswordValid)
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
		session.invalidate();
	
		boolean showMultiD = false;
		Customer cSuper = null;
		
		if (sCustID == null) sCustID = "";
		if (!("".equals(sCustID)))
		{
			cSuper = new Customer(sCustID);
			if (cSuper.s_login_name != null && !("null".equals(cSuper.s_login_name)))
			{
				showMultiD = true;
			}
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

</script>
</head>
<body bgcolor="#dddddd" onLoad="putFocus();">
<form method="POST" action="multi_login2.jsp" name="login_form">
	<input type="hidden" name="tab" value="<%= (sNavTab==null)?"":sNavTab %>">
	<input type="hidden" name="sec" value="<%= (sNavSection==null)?"":sNavSection %>">
	<input type="hidden" name="url" value="<%= (sAltURL==null)?"":sAltURL %>">
	<input type="hidden" name="c" value="<%= (sCustID==null)?"":sCustID %>">
	<input type="hidden" name="h" value="<%= String.valueOf(isHyatt) %>">
	<font face="arial" size="1">
	<center>
		<br><br><br><br><br><br>
		<table bgcolor="#aaaaaa" width="250" cellpadding="1" cellspacing="1">
			<tr>
				<td bgcolor="#ffffff" width="250">
					<table style="font-family:arial;color:#555555;font-size:10px;" border="0" align="left" cellpadding="3" cellspacing="1">
						<tr>
							<td style="font-family:arial;color:#990000;font-size:10px;" colspan=2 align=center>Your login information is incorrect.  Please try again or contact support for assistance.</td>
						</tr>
						<tr>
							<td colspan="2" align="center">&nbsp;<img border="0" src="../nav/hyatt/logohyatt.gif"></td>
						</tr>
						<tr>
							<td align="right">Company:</td>
							<td>
								<% if (showMultiD) { %>
								<select style="font-family:arial;color:#555555;font-size:10px;" name="company">
								<%= drawCustSelect(cSuper, sCustLogin, 0, isHyatt) %>
								</select>
								<% } else { %>
								<input style="font-family:arial;color:#555555;font-size:10px;" type="text" name="company" size="32" value="<%=(sCustLogin==null)?"":sCustLogin%>">
								<% } %>
							</td>
						</tr>
						<tr>
							<td align="right">Login:</td>
							<td><input style="font-family:arial;color:#555555;font-size:10px;" type="text" name="login" size="32" value="<%=(sUserLogin==null)?"":sUserLogin%>"></td>
						</tr>
						<tr>
							<td align="right">Password:</td>
							<td><input style="font-family:arial;color:#555555;font-size:10px;" type="password" name="password" size="32" value=""></td>
						</tr>
						<tr>
							<td align="center" colspan="2"><input style="font-family:arial;color:#555555;font-size:10px;" type="submit" value="Submit"></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</center>
</form>
</body>
</html>
<%
	}
}
catch(Exception ex)
{
	ErrLog.put(this, ex, "Error in multi_login.jsp", out, 1);
}
finally
{
}
%>
<%!
private String drawCustSelect(Customer c, String sSelected, int iIndent, boolean isHyatt) throws Exception
{
	String sCustHTML = "";
	
	int tmpStatus = Integer.parseInt(c.s_status_id);
		
	if (tmpStatus == CustStatus.ACTIVATED)
{
	String iSpace = "";
	int i = 0;
	for (i=0; i < iIndent; i++)
	{
		iSpace += "&nbsp;&nbsp;&nbsp;";
	}
	
	String selOp = "";
	if (c.s_login_name.equals(sSelected)) selOp = " selected";
	
	sCustHTML += "<option value=\"" + c.s_login_name + "\"" + selOp + ">";

		if (isHyatt) sCustHTML += c.s_login_name;
		else sCustHTML += c.s_cust_name;

	sCustHTML += "</option>\n";
	
	c.retriveCustTree(c);
	
	Customers custs = c.m_Customers;
	if(custs != null)
	{
		iIndent++;		
		Enumeration e = custs.elements();
		while(e.hasMoreElements())
		{
				sCustHTML += drawCustSelect((Customer) e.nextElement(), sSelected, iIndent, isHyatt);
		}

		return sCustHTML;
		}
		else
		{
			return sCustHTML;
		}
	}
	else
	{
		return sCustHTML;
	}
}
%>
