<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, java.net.*,
			java.io.*, java.sql.*,
			java.util.*, java.util.*,
			java.sql.*, org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../../jsp/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../jsp/header.jsp" %>
<%@ include file="../../jsp/validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	//grab query strings
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
	String sMainUrl = "";
	String sTitle = "";

	//set default values for querystrings
	if ((null == sNavTab) || ("" == sNavTab))		sNavTab = "Home";
	if ((null == sNavSection) || ("" == sNavSection))	sNavSection = "1";

	//check tab and set variables
	if (sNavTab.equals("Home")) sTitle = "Home";
	else if (sNavTab.equals("Camp")) sTitle = "Campaign";
	else if (sNavTab.equals("Data")) sTitle = "Database";
	else if (sNavTab.equals("Cont")) sTitle = "Content";
	else if (sNavTab.equals("Rept")) sTitle = "Report";
	else if (sNavTab.equals("Admn")) sTitle = "Administration";
	else if (sNavTab.equals("Help")) sTitle = "Help";
	else sTitle = "Home";

	//check for alternate url
	if ((sAltURL != null) && (!"".equals(sAltURL))) sMainUrl = sAltURL;
%>
<HTML>
<HEAD>
<TITLE>Revotas: <%= sTitle %></TITLE>
</HEAD>
<FRAMESET ROWS="115,*" BORDER=0 FRAMEBORDER="0">
	<FRAME SRC="navigation.jsp?tab=<%= sNavTab %>&sec=<%= sNavSection %>" marginheight="0" marginwidth="0" leftmargin="0" topmargin="0" SCROLLING=no>
	<FRAME name="detail" SRC="frame.jsp?url=<%= URLEncoder.encode("/cms/ui/jsp/" + sMainUrl,"UTF-8") %>" marginheight="0" marginwidth="5" leftmargin="5" topmargin="0" SCROLLING=auto>
</FRAMESET>
</HTML>