<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.net.*, 
			java.io.*, 
			java.sql.*, 
			java.util.*, 
			java.util.*, 
			java.sql.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../jsp/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
%>
<%@ include file="../jsp/header.jsp" %>
<%@ include file="../jsp/validator.jsp"%>
<html>
<head>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" style="padding:0px;">
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td width="75%" align="right" valign="top" class="navFill"><img src="../images/blank.gif" width="1" height="50"></td>
		<td width="25%" align="right" valign="top" class="navLogoFade"><img src="../images/blank.gif" width="1" height="50"></td>
		<td align="right" valign="middle" class="navLogo">
			<IFRAME src="../jsp/cust/session_info.jsp" width="400" height="50" scrolling="no" frameborder="0" class="navLogo">
			[Your user agent does not support frames or is currently configured
			not to display frames. However, you may visit
			<A href="foo.html">the related document.</A>]
			</IFRAME>
		</td>
		<td align="right" valign="top" class="navDiv"><img src="../images/blank.gif" width="1" height="50"></td>
		<td align="right" valign="top" class="navLogo"><img src="../images/blank.gif" width="15" height="50"></td>
		<td align="right" valign="middle" class="navLogo"><img src="images/logo.gif" width="77" height="30"></td>
	</tr>
	<tr>
		<td width="100%" align="right" valign="top" colspan="6" class="navDiv"><img src="../images/blank.gif" width="1" height="1"></td>
	</tr>
	<tr>
		<td width="100%" align="right" valign="top" colspan="6"><img src="../images/blank.gif" width="1" height="15"></td>
	</tr>
</table>
</body>
</html>