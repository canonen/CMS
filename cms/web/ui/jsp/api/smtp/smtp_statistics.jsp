<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 19.12.2024
  Time: 10:41
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java"
         import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>
<%@ include file="../validator.jsp"%>
<%@ include file="../header.jsp"%>
<%! static Logger logger = null;%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.net.InetAddress" %>


<%
    if(logger == null){
        logger = Logger.getLogger(this.getClass().getName());
    }

    Connection connection       =null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String sql = null;

    String transactionId	= request.getParameter("transaction_id");
    String startDate = request.getParameter("start_date");
    String endaDate =request.getParameter("end_date");
    String clickTypeStr = request.getParameter("type");
    String toEmail = request.getParameter("recipient_to");
    String domain = request.getParameter("recipient_domain");
    String subject = request.getParameter("subject");

    String whereCondition = " WHERE 1=1";

    if(transactionId != null && !transactionId.isEmpty()){
        whereCondition += " AND alc.transaction_id = '"+transactionId+"'";
    }
    if(startDate != null && !startDate.isEmpty()){
        startDate += " 00:00:00";
        whereCondition += " AND alc.click_time >= '"+startDate+"'";
    }
    if(endaDate != null && !endaDate.isEmpty()) {
        endaDate += " 23:59:59";
        whereCondition += " AND alc.click_time <= '" + endaDate + "'";
    }
    if (clickTypeStr != null && !clickTypeStr.isEmpty()) {

        if (!clickTypeStr.equals("OPEN") && !clickTypeStr.equals("CLICK")) {
            JsonObject obj = new JsonObject();
            obj.put("error", "Invalid click type.Correct values are OPEN or CLICK");
            out.println(obj.toString());
            return;
        }

        if (clickTypeStr.equals("OPEN")) {
            whereCondition += " AND alc.type_id = '1'";
        } else if (clickTypeStr.equals("CLICK")) {
            whereCondition += " AND alc.type_id = '2'";
        }
    }

    if(toEmail != null && !toEmail.isEmpty()){
        whereCondition += " AND mpa.emailTo = '"+toEmail+"'";
    }

    if(domain != null && !domain.isEmpty()){
        whereCondition += " AND mpa.emailTo LIKE '%"+domain+"'";
    }
    if(subject != null && !subject.isEmpty()){
        whereCondition += " AND mpa.subject LIKE '%"+subject+"%'";
    }

    try {
        final String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        final String urdb = "jdbc:sqlserver://192.168.151.6:1433;databaseName=brite_ainb_500";
        final String dbUser = "revotasadm";
        final String dbPassword = "l3br0nj4m3s";
        sql = "SELECT"
                + " SUM(CASE WHEN type_id = 1 THEN 1 ELSE 0 END) AS openCount,"
                + " SUM(CASE WHEN type_id = 2 THEN 1 ELSE 0 END) AS clickCount"
                + " FROM brite_ainb_500.dbo.ainb_link_activity as alc LEFT JOIN brite_ainb_500.dbo.mail_pmta_acct AS mpa ON alc.transaction_id = mpa.transactionID"
                +  whereCondition
                + " AND cust_id = '" + cust.s_cust_id + "'";

        connection = DriverManager.getConnection(urdb, dbUser, dbPassword);
        ps = connection.prepareStatement(sql);
        rs = ps.executeQuery();

        JsonArray arr = new JsonArray();
        while (rs.next()) {
            JsonObject obj = new JsonObject();
            obj.put("openCount", rs.getString("openCount"));
            obj.put("clickCount", rs.getString("clickCount"));
            arr.put(obj);
        }
        out.println(arr.toString());
    } catch (Exception e) {
        logger.error("Error in smtp_data.jsp", e);
        out.print("Error : " + e);
    } finally {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (connection != null) {
                connection.close();
            }
        } catch (Exception ex) {
            logger.error("Error closing resources in smtp_data.jsp", ex);
        }
    }
%>