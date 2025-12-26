<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
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
		<TITLE></TITLE>
	</HEAD>
	<FRAMESET name="main_frame" rows="*,<%=sTreeWidth%>">
		<FRAME SRC="<%=sMainUrl%>?${loc}">
		<FRAME SRC="<%=sTreeUrl%>?${loc}">
	</FRAMESET>
	</fmt:bundle>
</HTML>

<%
	}
%>