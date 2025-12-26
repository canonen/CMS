<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../utilities/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../utilities/header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sStatus = request.getParameter("status");
if (sStatus == null) sStatus = "1";

String sErr = request.getParameter("err");
if (sErr == null) sErr = "0";

String sUserId = request.getParameter("user_id");

User u = null;
UserUiSettings uus = null;

u = new User(sUserId);
uus = new UserUiSettings(sUserId);

String sRemainingDays = u.remainingPassDays();
if (sRemainingDays == null) sRemainingDays = "0";

%>

<HTML>
<HEAD>
<TITLE>Password Change</TITLE>
<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">	
<SCRIPT src="../../../js/scripts.js"></SCRIPT>
</HEAD>
<SCRIPT LANGUAGE="JAVASCRIPT">

function SubmitCheck()
{
     undisable_forms();       //just in case
// Check the text
	var Frm = document.user;
	var errCount;
	
	if(isBlank(Frm.old_password, "Old Password")) return;
	else if(isBlank(Frm.password, "New Password")) return;
	else if(isBlank(Frm.confirm_password, "Confirm Password")) return;
	else if(Frm.password.value != Frm.confirm_password.value)
	{
		alert("The new passwords entered do not match.");
		Frm.old_password.value = "";
		Frm.password.value = "";
		Frm.confirm_password.value = "";
		return;
	}
	else if(Frm.old_password.value == Frm.password.value)
	{
		alert("You must change the password.");
		Frm.old_password.value = "";
		Frm.password.value = "";
		Frm.confirm_password.value = "";
		return;
	}
	else
	{
		Frm.submit();
	}
}

function isBlank(field, strBodyHeader)
{
	strTrimmed = trim(field.value);
	if (strTrimmed.length > 0)
	{
		return false;
	}
	alert("\"" + strBodyHeader + "\" is a required field. Please type a value.");
	field.focus();
	return true;
}

function trimLeft(s)
{
	var whitespaces = " \t\n\r";
	for(n = 0; n < s.length; n++)
	{
		if (whitespaces.indexOf(s.charAt(n)) == -1) return (n > 0) ? s.substring(n, s.length) : s;
	}
	return("");
}

function trimRight(s)
{
	var whitespaces = " \t\n\r";
	for(n = s.length - 1; n  > -1; n--)
	{
		if (whitespaces.indexOf(s.charAt(n)) == -1) return (n < (s.length - 1)) ? s.substring(0, n+1) : s;
	}
	return("");
}

function trim(s)
{
	return ((s == null) ? "" : trimRight(trimLeft(s)));
}

function undisable_forms()
{
  var l = document.forms.length;
  for(var i=0; i < l; i++)
  {
       var m = document.forms[i].elements.length;
       for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = false;
  }
}

</SCRIPT>
<BODY>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onClick="SubmitCheck();">Save Password</a>
		</td>
	</tr>
</table>
<br>
<form method="POST" action="pass_change_save.jsp" name="user">
<input type="hidden" name="user_id" value="<%= u.s_user_id %>">
<input type="hidden" name="status" value="<%= sStatus %>">
<% if ("1".equals(sErr)) { %>
<table id="Tabs_Table" cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						The &quot;Old Password&quot; entered does not match your current password. Please try again.
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>
<% } else if ("1".equals(sStatus)) { %>
<table id="Tabs_Table" cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p>Your password is about to expire. Please update it below.<br>
						You have only <%= sRemainingDays %> days remaining before you will no longer be able to log in.</p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>
<% } %>
<!--- Step 1 Header----->
<table width="95%" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Password:</b> Change &amp; Confirm</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Old Password:</td>
					<td align="left" valign="middle"><INPUT type="password" name="old_password" size="30" value=""></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">New Password:</td>
					<td align="left" valign="middle"><INPUT type="password" name="password" size="30" value=""></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Confirm Password:</td>
					<td align="left" valign="middle"><INPUT type="password" name="confirm_password" size="30" value=""></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
</form>
</BODY>
</HTML>
