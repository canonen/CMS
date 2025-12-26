<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 24.03.2025
  Time: 10:22
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
<%@ page import="java.util.Date" %>

<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }

    Connection connection       =null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    JsonArray arr = new JsonArray();
    JsonObject obj = new JsonObject();
    String sql;

    try {

        final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        InetAddress ip = InetAddress.getLocalHost();
		final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
//        final  String urdb = "jdbc:sqlserver://192.168.151.4:1433;databaseName=brite_sadm_500";
        final  String dbUser = "revotasadm";
        final  String dbPassword = "abs0lut";


        sql = "SELECT " +
                "v.help_doc_id as  volume_id, " +
                "v.display_heading as volume_heading, " +
                "v.help_order as volume_order, " +
                "v.approved_flag as volume_approved, " +
                "c.help_doc_id as chapter_id, " +
                "c.display_heading as chapter_heading, " +
                "c.help_order as chapter_order, " +
                "c.approved_flag as chapter_approved, " +
                "p.help_doc_id as page_id, " +
                "p.display_heading as page_heading, " +
                "p.help_order as page_order, " +
                "p.approved_flag as page_approved " +
                "FROM shlp_help_doc v WITH(NOLOCK) " +
                "LEFT OUTER join shlp_help_doc c WITH(NOLOCK) ON v.help_doc_id = c.parent_help_doc_id " +
                "LEFT OUTER join shlp_help_doc p WITH(NOLOCK) ON c.help_doc_id = p.parent_help_doc_id " +
                "WHERE v.type_id = 101 or c.type_id = 102 or p.type_id = 103 AND p.approved_flag= 1 ORDER BY 3, 7, 11";

        connection = DriverManager.getConnection(urdb,dbUser,dbPassword);
        ps = connection.prepareStatement(sql);
        rs = ps.executeQuery();

        while (rs.next()){
            JsonObject volumeJson = new JsonObject();
            volumeJson.put("volume_id", rs.getString("volume_id"));
            volumeJson.put("volume_heading", rs.getString("volume_heading"));
            volumeJson.put("volume_order", rs.getString("volume_order"));
            volumeJson.put("volume_approved", rs.getString("volume_approved"));

            volumeJson.put("chapter_id", rs.getString("chapter_id"));
            volumeJson.put("chapter_heading", rs.getString("chapter_heading"));
            volumeJson.put("chapter_order", rs.getString("chapter_order"));
            volumeJson.put("chapter_approved", rs.getString("chapter_approved"));

            volumeJson.put("page_id", rs.getString("page_id"));
            volumeJson.put("page_heading", rs.getString("page_heading"));
            volumeJson.put("page_order", rs.getString("page_order"));
            volumeJson.put("page_approved", rs.getString("page_approved"));
            arr.put(volumeJson);
        }

        out.println(arr.toString());

    }catch (Exception e){
        logger.error("Exception: ", e);
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    }


%>