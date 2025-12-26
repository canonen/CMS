<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">
<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.ctl.*,
                com.britemoon.sas.*,
                com.britemoon.cps.adm.*,
                org.w3c.dom.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                java.io.*,
                java.text.DateFormat,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    CustFeature cs = new CustFeature();
    boolean bFeat = false;
    bFeat = cs.exists(user.s_cust_id, Feature.BRITE_TRACK);

    JsonObject object = new JsonObject();
    JsonArray array = new JsonArray();

    object.put("isRevotrack",bFeat);
    array.put(object);

    out.print(array);
%>
</fmt:bundle>



