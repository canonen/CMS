<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, java.io.*, java.sql.*, java.util.*, java.util.*, java.sql.*, org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../jsp/header.jsp" %>
<%@ include file="../jsp/validator.jsp"%>
<%
	String sMainUrl = request.getParameter("url");
	String sTypeID = request.getParameter("typeID");
	if(sMainUrl == null) return;
	
	if (null != sTypeID)
	{
		sMainUrl += "?typeID=" + sTypeID;
	}

	response.sendRedirect(sMainUrl);
%>