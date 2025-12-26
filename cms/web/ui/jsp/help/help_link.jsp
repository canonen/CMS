<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.net.*,java.io.*,
			java.sql.*,java.util.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../jsp/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
String helpURL = "http://www.revotas.com/products/60help/Revotas60.htm";
%>
<html>
<head>
<title>Help Document</title>
</head>
<FRAMESET ROWS="*" BORDER=0 FRAMEBORDER="0">
	<FRAME name="help" SRC="<%=helpURL%>" marginheight="0" marginwidth="5" leftmargin="5" topmargin="0" SCROLLING=auto>
</FRAMESET>
</html>