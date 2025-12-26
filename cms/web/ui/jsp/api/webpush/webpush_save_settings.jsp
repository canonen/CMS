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
<%@ page import="java.io.BufferedReader" %>

<%!
    private static final Logger log = Logger.getLogger("webpush_edit_settings.jsp");
%>

<%

    Connection connectionCheck=null;
    PreparedStatement psCheck = null;
    ResultSet rsCheck = null;

    Connection connection=null;
    PreparedStatement ps = null;

    Connection connection2=null;
    PreparedStatement ps2 = null;


    try {
        final String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        final String urdb = "jdbc:sqlserver://192.168.151.11:1433;databaseName=brite_ajtk_610";
        final String dbUser = "revotasadm";
        final String dbPassword = "abs0lut";

        String sqlCheck = "SELECT COUNT(*) FROM brite_ajtk_610.dbo.ajtk_push_customer WHERE cust_id = ?";
        connectionCheck = DriverManager.getConnection(urdb, dbUser, dbPassword);
        psCheck = connectionCheck.prepareStatement(sqlCheck);
        psCheck.setString(1, cust.s_cust_id);
        rsCheck = psCheck.executeQuery();
        rsCheck.next();
        int count = rsCheck.getInt(1);
        rsCheck.close();
        psCheck.close();

        if (count > 0) {
            out.println("Hata: Bu cust_id zaten mevcut!");
            return;
        }

    } catch (SQLException e) {
        throw new RuntimeException(e);
    }

    // "SELECT id, cust_id, native_flag, popup_html, cookie_domain , statu FROM brite_ajtk_610.dbo.ajtk_push_customer WHERE cust_id = ?";
//    StringBuilder sb = new StringBuilder();
//    String line;
//    try {
//        BufferedReader reader = request.getReader();
//        while ((line = reader.readLine()) != null) {
//            sb.append(line);
//        }
//    } catch (Exception e) {
//        out.println("Veri okunurken hata oluştu: " + e.getMessage());
//    }
//
//    // Gövde içeriğini JSON objesine çeviriyoruz
//    JsonObject jsonObj = null;
//    try {
//        jsonObj = new JsonObject(sb.toString());
//    } catch (Exception e) {
//        throw new RuntimeException(e);
//    }

    String pushCustomerNativeFlag = BriteRequest.getParameter(request ,"native_flag");
    String pushCustomerPopupHtml  = BriteRequest.getParameter(request ,"popup_html");
    String pushCustomerCookieDomain = BriteRequest.getParameter(request ,"cookie_domain");
    String pushCustomerStatus     = BriteRequest.getParameter(request ,"status");

    StringBuilder queryBuilder = new StringBuilder("INSERT INTO brite_ajtk_610.dbo.ajtk_push_customer (cust_id");
    List<Object> parameters = new ArrayList<Object>();

    if (pushCustomerNativeFlag != null) {
        queryBuilder.append(", native_flag");
    }
    if (pushCustomerPopupHtml != null) {
        queryBuilder.append(", popup_html");
    }
    if (pushCustomerCookieDomain != null) {
        queryBuilder.append(", cookie_domain");
    }
    if (pushCustomerStatus != null) {
        queryBuilder.append(", statu");
    }

    queryBuilder.append(", cust_type, activity_track_flag) VALUES (?");
    parameters.add(cust.s_cust_id);

    if (pushCustomerNativeFlag != null) {
        queryBuilder.append(", ?");
        parameters.add(pushCustomerNativeFlag);
    }
    if (pushCustomerPopupHtml != null) {
        queryBuilder.append(", ?");
        parameters.add(pushCustomerPopupHtml);
    }
    if (pushCustomerCookieDomain != null) {
        queryBuilder.append(", ?");
        parameters.add(pushCustomerCookieDomain);
    }
    if (pushCustomerStatus != null) {
        queryBuilder.append(", ?");
        parameters.add(pushCustomerStatus);
    }

    queryBuilder.append(", ?, ?)");
    parameters.add(0);
    parameters.add(0);

    System.out.println("SQL Sorgusu: " + queryBuilder.toString());
    System.out.println("Parametreler: " + parameters);





    try {
        final String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        final String urdb = "jdbc:sqlserver://192.168.151.11:1433;databaseName=brite_ajtk_610";
        final String dbUser = "revotasadm";
        final String dbPassword = "abs0lut";

        connection = DriverManager.getConnection(urdb, dbUser, dbPassword);
        ps = connection.prepareStatement(queryBuilder.toString());

        for (int i = 0; i < parameters.size(); i++) {
            ps.setObject(i + 1, parameters.get(i));
        }
        ps.executeUpdate();

        out.println("JTK 1 Insert Success");
    } catch (Exception e) {
        out.println("Error: " + e);
        throw new RuntimeException(e);
    } finally {
        try {
            if (ps != null) ps.close();
            if (connection != null) connection.close();
        } catch (Exception ex) {
            out.println("Error closing resources: " + ex);
        }
    }


    try {

        final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        final  String urdb = "jdbc:sqlserver://192.168.151.13:1433;databaseName=brite_ajtk_610";
        final  String dbUser = "revotasadm";
        final  String dbPassword = "abs0lut";


        connection2 = DriverManager.getConnection(urdb,dbUser,dbPassword);
        ps2 = connection2.prepareStatement(queryBuilder.toString());
        for (int i = 0; i < parameters.size(); i++) {
            ps2.setObject(i + 1, parameters.get(i));
        }
        ps2.executeUpdate();
        out.println("JTK 2 Insert Success");

    }catch (Exception e) {
        System.out.println("Error: " + e);
        throw new RuntimeException(e);
    } finally {
        try {
            if (ps != null) ps.close();
            if (connection != null) connection.close();
        } catch (Exception ex) {
            out.println("Error closing resources: " + ex);
        }
    }

%>