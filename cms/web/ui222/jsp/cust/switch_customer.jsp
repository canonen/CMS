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

	String sCustId = request.getParameter("cust_id");

	if(sCustId!=null)
	{
		ui.setUIMode(ui.SINGLE_CUSTOMER);
		ui.setActiveCustomer(session, sCustId);
		ui.setDestinationCustomer(session, sCustId);
	}
%>

<HTML>

<HEAD>
<TITLE></TITLE>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>
<SCRIPT>
	if(opener.parent.parent!=null) opener.parent.parent.location.reload();
	window.close();
</SCRIPT>	
</BODY>

</HTML>
