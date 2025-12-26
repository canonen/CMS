<%@page import="com.britemoon.*" %>
<%@page import="com.britemoon.cps.*" %>
<%@page import="com.britemoon.cps.imc.*" %>

<%@ page
        language="java"
        import="com.britemoon.*,
    com.britemoon.cps.*,
    java.sql.*,java.io.*,
    java.util.*,java.net.*,
    com.britemoon.cps.*,java.sql.*,
    java.io.*,javax.servlet.*,
    javax.servlet.http.*,java.util.*,
    java.net.*,
    org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="org.json.JSONObject" %>
<%! static Logger logger = null;%>
<%@ include file="header.jsp"%>

<%
  if(logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
  }
  try{
    JsonObject data = new JsonObject();
    String sUserLogin = request.getParameter("login");
    String sPassword = request.getParameter("password");
    boolean setLoading =false;
    if ("Revotas".equals(sUserLogin) && "4t4turkf0r4!".equals(sPassword)) {
      setLoading = true;
    }
    data.put("setLoading",setLoading);
    out.println(data.toString());
  }catch (Exception ex) {
    JSONObject data1 = new JSONObject();
    data1.put("success", false);
    data1.put("message", "Server error: " + ex.getMessage());

    response.setStatus(500);

    out.print(data1.toString());

    ErrLog.put(this, ex, "Error in newlogin.jsp", out, 1);
  } finally {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
  }


%>