<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%@ include file="header.jsp" %>
<%@ include file="validator.jsp"%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String sMainUrl = request.getParameter("url");
	String sTypeID = request.getParameter("typeID");
	if(sMainUrl == null) return;
	
	if (null != sTypeID)
	{
		sMainUrl += "?typeID=" + sTypeID;
	}

	String sTreeWidth = "175";
	String sTreeUrl = "/cms/ui/jsp/cust/cust_tree_frame.jsp";

	Customer cActive = ui.getActiveCustomer();
	if(ui.getUIMode() == ui.SINGLE_CUSTOMER)
	{
		response.sendRedirect(sMainUrl);
	}
	else
	{
%>

<HTML>
	<HEAD>
		<TITLE></TITLE>
	</HEAD>
	<FRAMESET name="main_frame" rows="*,<%=sTreeWidth%>">
		<FRAME SRC="<%=sMainUrl%>">
		<FRAME SRC="<%=sTreeUrl%>">
	</FRAMESET>
</HTML>

<%
	}
%>