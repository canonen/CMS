<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,org.apache.log4j.*"
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

	String sMode = request.getParameter("mode");
	if("multi".equals(sMode)) ui.setUIMode(ui.MULTI_CUSTOMER);
	else ui.setUIMode(ui.SINGLE_CUSTOMER);
%>

<HTML>

<HEAD>
<TITLE></TITLE>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>
<SCRIPT>
	this.location.href = 'session_info.jsp';
	if(parent.parent!=null) parent.parent.location.reload();
</SCRIPT>	
</BODY>

</HTML>
