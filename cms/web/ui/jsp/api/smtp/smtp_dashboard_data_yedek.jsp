<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 26.12.2024
  Time: 15:09
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

  String beginDate	= request.getParameter("begin_date");
  String endDate = request.getParameter("end_date");

  beginDate = beginDate + " 00:00:00";
  endDate = endDate + " 23:59:59";

  try {

    final String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    InetAddress ip = InetAddress.getLocalHost();
//		final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
    final String urdb = "jdbc:sqlserver://192.168.151.6:1433;databaseName=brite_ainb_500";
    final String dbUser = "revotasadm";
    final String dbPassword = "l3br0nj4m3s";

    sql = "SELECT CONVERT(CHAR(10), createdDate, 120) as time_idx,reportType as report_type,count(*) as count " +
            " FROM mail_pmta_acct rc (NOLOCK)" +
            " where custId='"+cust.s_cust_id+"'" +
            " AND createdDate >= '"+beginDate+"'" +
            " AND createdDate <= '"+endDate+"'" +
            " GROUP BY CONVERT(CHAR(10), createdDate, 120),reportType" +
            " ORDER BY CONVERT(CHAR(10), createdDate, 120) DESC;";
    connection = DriverManager.getConnection(urdb, dbUser, dbPassword);
    ps = connection.prepareStatement(sql);
    rs = ps.executeQuery();

    JsonArray arr = new JsonArray();
    while (rs.next()){
      JsonObject obj = new JsonObject();
      obj.put("time", rs.getString("time_idx"));
      obj.put("reportType", rs.getString("report_type") == null ? "UNKNOWN" : rs.getString("report_type"));
      obj.put("count", rs.getString("count"));

      arr.put(obj);
    }
    out.println(arr.toString());
  }catch (Exception e){
    logger.error("Error in smtp_data.jsp",e);
  }

%>