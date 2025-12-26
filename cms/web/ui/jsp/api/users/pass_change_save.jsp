<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}


String oldPass = BriteRequest.getParameter(request,"old_password");
String newPass = BriteRequest.getParameter(request,"password");
String sUserId = BriteRequest.getParameter(request,"user_id");

String sStatus = BriteRequest.getParameter(request,"status");

// === === ===

User chkU = new User(sUserId);
String confirmOldPass = chkU.s_password;
if (oldPass == null) oldPass = "";

if (oldPass.equals(confirmOldPass))
{
	User u = new User(sUserId);
	u.s_password = BriteRequest.getParameter(request,"password");
	u.saveWithSync();
}
else
{
	response.sendRedirect("pass_change.jsp?err=1&status=" + sStatus + "&user_id=" + sUserId);
	return;
}
// === === ===


%>

<HTML>
<HEAD>
<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
	function closeWin()
	{
	<% if ("2".equals(sStatus)) { %>
		var op = window.opener;
		op.location.href = "/cms/ui/jsp/index.jsp?tab=Home&sec=1";
	<% } %>
		self.close();
	}
	
</script>
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=95% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Password:</b> Changed</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p>Your password was successfully changed!</p>
						<p><a href="javascript:closeWin();">Close Window</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
</BODY>
</HTML>
