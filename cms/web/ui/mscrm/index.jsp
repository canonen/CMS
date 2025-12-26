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
<%@ include file="../jsp/header.jsp" %>
<%@ include file="../jsp/validator.jsp"%>
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
	if ((null == sNavTab) || ("" == sNavTab))
	{
		sNavTab = "Home";
	}
	
	if ((null == sNavSection) || ("" == sNavSection))
	{
		sNavSection = "1";
	}


//check tab and set variables
	if (sNavTab.equals("Home"))
	{
		//set variables
			sTitle = "Home";
	}
	else if (sNavTab.equals("Camp"))
	{
		//set variables
			sTitle = "Campaign";
	}
	else if (sNavTab.equals("Data"))
	{
		//set variables
			sTitle = "Database";
	}
	else if (sNavTab.equals("Cont"))
	{
		//set variables
			sTitle = "Content";
	}
	else if (sNavTab.equals("Rept"))
	{
		//set variables
			sTitle = "Report";
	}
	else if (sNavTab.equals("Admn"))
	{
		//set variables
			sTitle = "Administration";
	}
	else if (sNavTab.equals("Help"))
	{
		//set variables
			sTitle = "Help";
	}
	else
	{
		//set variables
			sTitle = "Home";
	}

//check for alternate url
//	if ((null != sAltURL) && ("" != sAltURL))
//	{
//		sMainUrl = sAltURL;
//	}
	
//	String CRMMode = request.getParameter("mode");
//	String redirectURL;
	
//	if (CRMMode == null) CRMMode = ui.getSessionProperty("crm_mode");
//	if ((CRMMode == null)||("".equals(CRMMode))) CRMMode = "advanced";
//	ui.setSessionProperty("crm_mode", CRMMode);
	
//	redirectURL = "home.jsp?tab=" + sNavTab + "&sec=" + sNavSection + "&url=" + URLEncoder.encode("/cms/ui/jsp/" + sMainUrl,"UTF-8");
	
//	if ("simple".equals(CRMMode)) response.sendRedirect(redirectURL);
	
%>
<HTML>
<HEAD>
<TITLE>Revotas: <%= sTitle %></TITLE>
</HEAD>
<frameset cols="150,*" border=0 frameborder="0">
	<frame src="navigation.jsp?tab=<%= sNavTab %>&sec=<%= sNavSection %>" marginheight="0" marginwidth="0" leftmargin="0" topmargin="0" scrolling=auto>
	<frameset rows="55,*" border=0 frameborder="0">
		<frame name="logo" SRC="top.jsp" marginheight="0" marginwidth="0" leftmargin="0" topmargin="0" scrolling=no>
		<frame name="detail" SRC="frame.jsp?url=<%= URLEncoder.encode("/cms/ui/jsp/" + sMainUrl,"UTF-8") %>" marginheight="0" marginwidth="5" leftmargin="5" topmargin="0" scrolling=auto>
	</frameset>
</frameset>
</HTML>