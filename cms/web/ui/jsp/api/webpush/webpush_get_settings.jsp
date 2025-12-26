<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 30.01.2025
  Time: 09:40
  To change this template use File | Settings | File Templates.
--%>
<%@  page language="java"
          import="java.net.*,
            com.britemoon.*,
            com.britemoon.cps.*,
			java.sql.*,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			org.json.JSONObject,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
          contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%!
    private static final Logger log = Logger.getLogger("webpush_get_settings.jsp");
%>

<%
    JsonObject json = new JsonObject();
    JsonArray arr = new JsonArray();

    Connection connection       =null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {

        final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        InetAddress ip = InetAddress.getLocalHost();
        final  String urdb = "jdbc:sqlserver://192.168.151.11:1433;databaseName=brite_ajtk_610";
        final  String dbUser = "revotasadm";
        final  String dbPassword = "abs0lut";

//        SELECT id, cust_id, native_flag, popup_html, cookie_domain FROM brite_ajtk_610.dbo.ajtk_push_customer WHERE cust_id = ?

        String sql = "SELECT id, cust_id, native_flag, popup_html, cookie_domain , statu FROM brite_ajtk_610.dbo.ajtk_push_customer WHERE cust_id = ?";
        connection = DriverManager.getConnection(urdb,dbUser,dbPassword);
        ps = connection.prepareStatement(sql);
        ps.setString(1, cust.s_cust_id);
        rs = ps.executeQuery();
        if(rs.next()){
            json.put("id", rs.getString("id"));
            json.put("cust_id", rs.getString("cust_id"));
            json.put("native_flag", rs.getString("native_flag"));
            json.put("popup_html", rs.getString("popup_html"));
            json.put("cookie_domain", rs.getString("cookie_domain"));
            json.put("status", rs.getString("statu"));
            arr.put(json);
        }
        out.println(arr.toString());

    }catch (Exception e) {
        System.out.println("Error: "+e);
        throw new Exception(e);
    }finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (connection != null) {
                connection.close();
            }
    }



%>