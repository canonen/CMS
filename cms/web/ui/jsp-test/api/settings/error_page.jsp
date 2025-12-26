<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,org.apache.log4j.*"
	isErrorPage="true" 
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<% if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>

<html>
<head>
	<title>Error</title>
	<%@ include file="header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript">
	<!--
		
		function switchError()
		{
			if (document.getElementById("hideError").style.display == "none")
			{
				window.event.srcElement.innerHTML = "- Hide Error";
				document.getElementById("hideError").style.display = "";
			}
			else
			{
				window.event.srcElement.innerHTML = "+ Show Error";
				document.getElementById("hideError").style.display = "none";
			}
		}
	//-->
	</script>
</head>

<body>
<form name="support" action="/cms/ui/jsp/help/support_success.jsp" method="post" style="display:inline;">
<input type="hidden" name="selAreas" value="Error Page Exception Report">
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p><span style="font-size:16pt;">Oops. There has been an error.</span></p>
						<p>Please report this error to Technical Support:</p>
						<p><a class="savebutton" href="#" onclick="support.submit();">Send Error Information</a></p>
						<p>Some one from the Technical Support staff will contact you shortly.</p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<span style="cursor:hand;" onclick="switchError();">+ Show Error</span>
			<br><br>
			<table class="main" cellpadding="2" cellspacing="1" border="0" width="650" id="hideError" style="display:none;">
				<tr>
					<td align="left" valign="top" style="padding:10px;">
<textarea cols="150" rows="25" style="width:100%;" name="txtProblemVisible">
Date: <%= new java.util.Date() %>;

Client IP Address: <%= request.getRemoteAddr() %>

Referer: <%= request.getHeader("referer") %>

<%= exception.getMessage()%>

</textarea>

<textarea cols="150" rows="25" style="display:none;" name="txtProblem">
Date: <%= new java.util.Date() %>;

Client IP Address: <%= request.getRemoteAddr() %>

Referer: <%= request.getHeader("referer") %>

<%
exception.printStackTrace(new PrintWriter(out));
%>
</textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
<br>
<br>
</body>
</html>

























