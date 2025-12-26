<%@ page
	language="java"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt" %>
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
	<FRAMESET name="main_welcome_frame">
		<FRAME SRC="welcome.jsp?locale=<c:out value="${loc}"/>">
	</FRAMESET>
</fmt:bundle>	
</HTML>