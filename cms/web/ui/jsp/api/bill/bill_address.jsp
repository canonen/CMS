<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 2.01.2025
  Time: 12:45
  To change this template use File | Settings | File Templates.
--%>
<%@ page
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.imc.*"
        import="java.io.*"
        import="java.security.MessageDigest"
        import="java.security.NoSuchAlgorithmException"
        import="java.sql.*"
        import="java.util.*"
        import="org.apache.log4j.*"
        import="org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.britemoon.cps.adm.CustAddr" %>
<%@ page import="java.net.InetAddress" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    String custId = cust.s_cust_id;
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();

    CustAddr custAddr = null;
    try {
        custAddr = new CustAddr(custId);
    } catch (Exception e) {
        data.put("Error", e.getMessage());
        throw new RuntimeException(e);
    }
    int retrieve = 0;
    try {
        retrieve = custAddr.retrieve();
    } catch (Exception e) {
        data.put("Error", e.getMessage());
        throw new RuntimeException(e);
    }
    if(retrieve != 0) {
        data.put("state", custAddr.s_state);
        data.put("address1", custAddr.s_address1);
        data.put("address2", custAddr.s_address2);
        data.put("city", custAddr.s_city);
        data.put("country", custAddr.s_country);
        data.put("zip", custAddr.s_zip);
        data.put("phone", custAddr.s_phone);
        data.put("fax", custAddr.s_fax);
        array.put(data);
        out.print(array.toString());
    }else {
        data.put("Error", "Customer address not found");
    }
%>