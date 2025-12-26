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
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="org.json.JSONException" %>

<%!
  private static final Logger log = Logger.getLogger("webpush_edit_settings.jsp");
%>

<%

  Connection connection       =null;
  PreparedStatement ps = null;
  ResultSet rs = null;

  Connection connection2       =null;
  PreparedStatement ps2 = null;
  ResultSet rs2 = null;

  // "SELECT id, cust_id, native_flag, popup_html, cookie_domain , statu FROM brite_ajtk_610.dbo.ajtk_push_customer WHERE cust_id = ?";

//  StringBuilder sb = new StringBuilder();
//  String line;
//  try {
//    BufferedReader reader = request.getReader();
//    while ((line = reader.readLine()) != null) {
//      sb.append(line);
//    }
//  } catch (Exception e) {
//    out.println("Veri okunurken hata oluştu: " + e.getMessage());
//  }
//
//  // Gövde içeriğini JSON objesine çeviriyoruz
//  JsonObject jsonObj = null;
//  try {
//    jsonObj = new JsonObject(sb.toString());
//  } catch (Exception e) {
//    throw new RuntimeException(e);
//  }

  String pushCustomerId         = BriteRequest.getParameter(request ,"id");
  String pushCustomerNativeFlag = BriteRequest.getParameter(request ,"native_flag");
  String pushCustomerPopupHtml  = BriteRequest.getParameter(request ,"popup_html");
  String pushCustomerCookieDomain = BriteRequest.getParameter(request ,"cookie_domain");
  String pushCustomerStatus     = BriteRequest.getParameter(request ,"status");


  StringBuilder queryBuilder = new StringBuilder("UPDATE brite_ajtk_610.dbo.ajtk_push_customer SET ");
  boolean firstField = true;
  List<Object> parameters = new ArrayList<Object>();

  if (pushCustomerNativeFlag != null) {
    queryBuilder.append("native_flag = ?");
    parameters.add(pushCustomerNativeFlag);
    firstField = false;
  }
  if (pushCustomerPopupHtml != null) {
    queryBuilder.append(firstField ? "" : ", ").append("popup_html = ?");
    parameters.add(pushCustomerPopupHtml);
    firstField = false;
  }
  if (pushCustomerCookieDomain != null) {
    queryBuilder.append(firstField ? "" : ", ").append("cookie_domain = ?");
    parameters.add(pushCustomerCookieDomain);
    firstField = false;
  }
  if (pushCustomerStatus != null) {
    queryBuilder.append(firstField ? "" : ", ").append("statu = ?");
    parameters.add(pushCustomerStatus);
    firstField = false;
  }

  if (!firstField) {
    queryBuilder.append(" WHERE id = ? AND cust_id = ?");
    parameters.add(pushCustomerId);
    parameters.add(cust.s_cust_id);
  } else {
    System.out.println("No fields to update. All request parameters are null.");
    out.println("No fields to update. All request parameters are null.");
    return;
  }

  String updateQuery = queryBuilder.toString();

  try {

    final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    InetAddress ip = InetAddress.getLocalHost();
    final  String urdb = "jdbc:sqlserver://192.168.151.11:1433;databaseName=brite_ajtk_610";
    final  String dbUser = "revotasadm";
    final  String dbPassword = "abs0lut";

    connection = DriverManager.getConnection(urdb,dbUser,dbPassword);
    ps = connection.prepareStatement(updateQuery);
    for (int i = 0; i < parameters.size(); i++) {
      ps.setObject(i + 1, parameters.get(i));
    }
    int rowsUpdated = ps.executeUpdate();
    out.println("JTK 1 Update Success");

  }catch (Exception e) {
    System.out.println("Error: "+e);
    throw new RuntimeException(e);
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


  try {

    final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    InetAddress ip = InetAddress.getLocalHost();
    final  String urdb = "jdbc:sqlserver://192.168.151.13:1433;databaseName=brite_ajtk_610";
    final  String dbUser = "revotasadm";
    final  String dbPassword = "abs0lut";


    connection2 = DriverManager.getConnection(urdb,dbUser,dbPassword);
    ps2 = connection2.prepareStatement(updateQuery);
    for (int i = 0; i < parameters.size(); i++) {
      ps2.setObject(i + 1, parameters.get(i));
    }
    ps2.executeUpdate();
    out.println("JTK 2 Update Success");

  }catch (Exception e) {
    System.out.println("Error: " + e);
    throw new RuntimeException(e);
  } finally {
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