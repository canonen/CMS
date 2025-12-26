<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<HTML>
<HEAD>
<title>Testing Lists: Which To Use?</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
	function window.onload()
	{
		window.resizeTo(450, 375);
	}
	
</script>
</HEAD>
<BODY>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
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
					
					<strong>Which Testing List should I use?</strong><br><br>

					<strong>Random Testing List:</strong><br>

					Use the Random Testing List if you want to test both your content formatting as well as the integrity of your target group.
					Random Testing will pull live data from your target group and send the sample email to the address you specify.<br><br>

					<strong>Specified Testing List:</strong><br>

					Use Specified Testing List if you have completed live data testing and would like to confirm by getting a test with the specific information of the recipient you specified.
					Specified Testing is a good method to use if you are sending a test to those unfamiliar with the Random Testing process thus eliminating any confusion before launch.<br><br>

					<strong>Dynamic Content Testing List:</strong><br>

					Use Dynamic Content Testing List if you would like to receive iterations of dynamic content.

					<br><br>
					<a class="subactionbutton" href="javascript:window.close()">CLOSE WINDOW</a>
						
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
</BODY>
