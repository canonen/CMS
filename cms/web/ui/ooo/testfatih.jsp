<%@ page import="org.apache.taglibs.standard.lang.jstl.Logger" %>
<%@ page import = "javax.servlet.*,javax.servlet.http.* "%>
<%@ page import ="javax.servlet.jsp.jstl.core.Config"%>



<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt" %>


<%! static Logger logger = null;%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>JSP - JSTL</title>
</head>
<body>


<!-- Setting Locale to US -->
<%--<c:set var="loc" value="en_US"/>
<fmt:setLocale value="en_US"/>--%>



<%
   /* String loc = request.getParameter("locale");
    out.println(loc);
    Config.set( session, Config.FMT_LOCALE, new java.util.Locale("en", "US") );*/



%>
<%--<c:set var = "tr" scope = "session" value = "tr_TR"/>
<c:out value = "${tr}"/>--%>


<%--<fmt:setLocale value="${tr}"/>--%>
<c:out value="${param.locale}"/><br/>
<br/>

<%--<c:url value="testfatih.jsp" var="myUrl" scope="session">
    <c:param name="name" value="${param.name}"/>
</c:url>--%>
<a target="_parent" href="${salary}">myURLLLLL</a>

<c:set var="loc" value="${param.locale}"/>
<fmt:setLocale value="${loc}"/>
    <%--<c:set var="loc" value="en_US"/>--%>
<c:if test="${!(empty loc)}">
    <c:set var="loc" value="${loc}"/>
</c:if>

<fmt:bundle basename="app">
    <fmt:message key="contents"/><br/>
    <fmt:message key="reports"/><br/>
    <fmt:message key="ecommerce"/><br/>
    <c:url value="testfatih.jsp" var="turkishURL">
        <c:param name="locale" value="tr_TR"/>
    </c:url>

    <a target="_parent" href="testfatih.jsp?locale=en">en_EN</a>
    <a target="_parent" href="testfatih.jsp?locale=tr">tr</a><br>
    <a target="_parent" href="testfatih.jsp?locale=${loc}">ssss</a>
    
    
</fmt:bundle>

<%--
<c:set var="loc" value="tr_TR"/>
<fmt:setLocale value="tr_TR"/>--%>
<fmt:bundle basename="app"><br/>
    <fmt:message key="contents"/><br/>
    <fmt:message key="reports"/><br/>
    <fmt:message key="ecommerce"/><br/>
</fmt:bundle>
</body>
</html>