<%@ page
	language="java"
	import="javax.servlet.http.*,
			javax.servlet.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}	

boolean showTextarea = false;

if(request.getParameter("zunique") == null)
{
	showTextarea = false;
} 
else 
{
	out.println("dadasdasdasd");
}
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT src="../../js/scripts.js"></SCRIPT>
<script src="../../js/tab_script.js"></script>
<title>Image To HTML Converter</title>
<script language="javascript">
</script>
<style type="text/css">
	
	SELECT
	{
		width:100%;
	}
	
</style></style>
</HEAD>
<BODY topmargin="0" leftmargin="0" style="padding:0px;">
	<form action="" method="post" name="converter">
		<h1>Create HTML for your image</h1>
		<p>This feature allows you to easily create the HTML code from a given picture.</p>
		<input type="file" name="imageselection">
		<input type="submit" name="submit" value="Convert">
		<input type="hidden" name="zunique" value="1"/>
	</form>
	<div style=""><textarea name="html_code" cols="100" rows="15"></textarea></div>
</BODY>
</HTML>
