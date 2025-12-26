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
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../jsp/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page isELIgnored="false" %>
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
	if ((null == sNavTab) || ("" == sNavTab))		sNavTab = "Home";
	if ((null == sNavSection) || ("" == sNavSection))	sNavSection = "1";

	//check tab and set variables
	if (sNavTab.equals("Home")) sTitle = "Home";
	else if (sNavTab.equals("Camp")) sTitle = "Campaign";
	else if (sNavTab.equals("Data")) sTitle = "Database";
	else if (sNavTab.equals("Cont")) sTitle = "Content";
	else if (sNavTab.equals("Rept")) sTitle = "Report";
	else if (sNavTab.equals("Admn")) sTitle = "Administration";
	else if (sNavTab.equals("Help")) sTitle = "Help & Support";
	else sTitle = "Home";

	//check for alternate url 
	if ((sAltURL != null) && (!"".equals(sAltURL))) sMainUrl = sAltURL;
	
	//String CRMMode = request.getParameter("mode");
	//String redirectURL;
	
	//if (CRMMode == null) CRMMode = ui.getSessionProperty("crm_mode");
	//if ((CRMMode == null)||("".equals(CRMMode))) CRMMode = "advanced";
	//ui.setSessionProperty("crm_mode", CRMMode);
	
	//redirectURL = "home.jsp?tab=" + sNavTab + "&sec=" + sNavSection + "&url=" + URLEncoder.encode("/cms/ui/jsp/" + sMainUrl,"UTF-8");
	
	//if ("simple".equals(CRMMode)) response.sendRedirect(redirectURL);
	
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">

<HEAD>
<TITLE>Revotas: <%= sTitle %></TITLE>
</HEAD>
<!---
<frameset rows="75,*" border=0 frameborder="0">
	<frame src="navigation.jsp?tab=<%= sNavTab %>&sec=<%= sNavSection %>" marginheight="0" marginwidth="0" leftmargin="0" topmargin="0" scrolling=no>
	<frame name="detail" SRC="frame.jsp?url=<%= URLEncoder.encode("/cms/ui/jsp/" + sMainUrl,"UTF-8") %>" marginheight="0" marginwidth="5" leftmargin="5" topmargin="0" scrolling=auto>
</frameset>
--->

 <c:url value="newtopnav.jsp" var="top_URL">
     <c:param name="locale" value="${loc}"/>
  </c:url>

 <c:url value="left_tab_menu.jsp" var="left_tab_menu_URL">
     <c:param name="locale" value="${loc}"/>
  </c:url>

  
<frameset rows="80,*" border="0">
<frame src="${top_URL}" name="topnav" scrolling="no" marginwidth="0" marginheight="0" noresize>
<frameset cols="190,*" border="0">
 <frame src="${left_tab_menu_URL}" name="leftnav" scrolling="no" border="0"marginwidth="0" marginheight="0" noresize>
 <frame src="frame.jsp?locale=${loc}&url=<%= URLEncoder.encode("/cms/ui/jsp/" + sMainUrl,"UTF-8") %>" name="detail" scrolling="yes" marginwidth="0" marginheight="0" noresize>
</frameset>
</frameset>
</fmt:bundle>
</HTML>