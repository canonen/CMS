<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.britemoon.sas.Partner" %>
<%@ page import="com.britemoon.sas.SystemUser" %><%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 6.01.2025
  Time: 10:05
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../header.jsp" %>
<%@ include file="validator.jsp"%>

<%

    JsonObject sessionObject = new JsonObject();
    JsonArray sessionArray = new JsonArray();

    if ( (session != null) && (request.isRequestedSessionIdValid())) {
        sessionObject.put("success",true);
        sessionObject.put("session_id", session.getId());
        sessionObject.put("partner", part.s_partner_name);
        sessionObject.put("userName", systemuser.s_username);
        sessionObject.put("fullName", systemuser.s_first_name + " " + systemuser.s_last_name);
        sessionObject.put("message", "login successful.");
        sessionArray.put(sessionObject);
        out.print(sessionArray.toString());
    }
    else {
        response.sendRedirect("admin_login.jsp");
    }

%>