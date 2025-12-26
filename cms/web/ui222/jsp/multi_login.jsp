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
	String sCustID = (String)session.getAttribute("c");
	String checkHyatt = (String)session.getAttribute("h");
	
	boolean isHyatt = false;
	
	if ("true".equals(checkHyatt)) isHyatt = true;
	
	String sUserLogin = request.getParameter("login");
	
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
	
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
<body bgcolor="#dddddd" onLoad="putFocus();" >
<form method="POST" action="multi_login2.jsp" name="login_form">
	<input type="hidden" name="tab" value="<%= (sNavTab==null)?"":sNavTab %>">
	<input type="hidden" name="sec" value="<%= (sNavSection==null)?"":sNavSection %>">
	<input type="hidden" name="url" value="<%= (sAltURL==null)?"":sAltURL %>">
	<input type="hidden" name="c" value="<%= (sCustID==null)?"":sCustID %>">
	<input type="hidden" name="h" value="<%= String.valueOf(isHyatt) %>">
	<font face="arial" size=1"">
	<center>
		<br><br><br><br><br><br>
		<table bgcolor="#aaaaaa" width="250" cellpadding="1" cellspacing="1">
			<tr>
				<td bgcolor="#ffffff" width="250">
					<table style="font-family:arial;color:#555555;font-size:10px;" border="0" align="left" cellpadding="3" cellspacing="1">
						<tr>
							<td colspan="2" align="center">&nbsp;<img border="0" src="../nav/hyatt/logohyatt.gif"></td>
						</tr>
						<tr>
							<td align="right">Company:</td>
							<td>
								<% if (showMultiD) { %>
								<select style="font-family:arial;color:#555555;font-size:10px;" name="company">
								<%= drawCustSelect(cSuper, 0, isHyatt) %>
								</select>
								<% } else { %>
								<input style="font-family:arial;color:#555555;font-size:10px;" type="text" name="company" size="32" value="">
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
							<td colspan="2" align="center"><input style="font-family:arial;color:#555555;font-size:10px;" type="submit" value="Submit"></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</center>
</form>
</body>
</html>
<%!
private String drawCustSelect(Customer c, int iIndent, boolean isHyatt) throws Exception
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
	
	sCustHTML += "<option value=\"" + c.s_login_name + "\">";

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
				sCustHTML += drawCustSelect((Customer) e.nextElement(), iIndent, isHyatt);
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
