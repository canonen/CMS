<%@ page
        language="java"
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="java.io.*"
        import="java.sql.*"
        import="java.util.*"
        import="org.apache.log4j.*"
%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="../header.jsp" %>
<%@include file="../validator.jsp" %>
<%@ page import="java.net.InetAddress" %>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>


<%
    String sCustId = cust.s_cust_id;

    ConnectionPool connectionPool   =null;
    Connection connection       =null;
    Statement statement = null;
    ResultSet rs = null;

    String ticketId = request.getParameter("ticketId");
    String beginDate = request.getParameter("beginDate");
    String endDate = request.getParameter("endDate");

    String whereClause = " 1 = 1";
    if (ticketId != null && !ticketId.isEmpty()) {
        whereClause += " AND th.ticket_id = '" + ticketId + "'";
    }
    if (beginDate != null && !beginDate.isEmpty()) {
        whereClause += " AND th.action_date >= '" + beginDate + "'";
    }
    if (endDate != null && !endDate.isEmpty()) {
        whereClause += " AND th.action_date <= '" + endDate + "'";
    }

    String username;
    String firstname;
    String lastname;
    String action;
    String oldValue;
    String newValue;
    String actionDate;

    try
    {
        final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        InetAddress ip = InetAddress.getLocalHost();
        //final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
        final  String urdb = "jdbc:sqlserver://192.168.151.101:1433;databaseName=brite_sadm_500";
        final  String dbUser = "revotasadm";
        final  String dbPassword = "abs0lut";

        String sql = "SELECT  th.ticket_id as ticket_id, th.update_scps_user_id as user_id , th.update_system_user_id as system_user_id , th.action_type as action , th.old_value as old_value , th.new_value as new_value , " +
                "th.action_date as action_date, su.login_name as first_name , su.last_name as last_name , su.user_name as user_name , syu.username as sys_user_name  , syu.first_name as sys_firt_name , syu.last_name as sys_last_name " +
                " FROM shlp_support_ticket_history AS th " +
                " LEFT JOIN shlp_support_ticket sst on th.ticket_id = sst.ticket_id " +
                " LEFT JOIN dbo.scps_user su on th.update_scps_user_id = su.user_id " +
                " LEFT JOIN sadm_system_user syu ON syu.system_user_id = th.update_system_user_id "
                + " WHERE " + whereClause;

        connection = DriverManager.getConnection(urdb,dbUser,dbPassword);
        statement = connection.createStatement();
        rs=statement.executeQuery(sql);

        JsonArray ticketArray = new JsonArray();

        while (rs.next()) {
            JsonObject ticketHistory = new JsonObject();
             username = fixTurkishCharacters(rs.getString("user_name") == null ? ( rs.getString("sys_user_name") == null  ? "" : rs.getString("sys_user_name") ): rs.getString("user_name"));
             firstname = fixTurkishCharacters(rs.getString("first_name") == null ? (rs.getString("sys_firt_name") == null  ? "" : rs.getString("sys_firt_name") ): rs.getString("first_name"));
             lastname = fixTurkishCharacters(rs.getString("last_name") == null ? (rs.getString("sys_last_name")== null  ? "" : rs.getString("sys_last_name") ) : rs.getString("last_name"));
            ticketHistory.put("ticketId", rs.getString("ticket_id"));
            ticketHistory.put("userId", rs.getString("user_id") == null ? (rs.getString("system_user_id") == null ? "" : rs.getString("system_user_id")) : rs.getString("user_id"));
            ticketHistory.put("userName", username);
            ticketHistory.put("fullName", firstname + " " + lastname);
            ticketHistory.put("action", rs.getString("action"));
            ticketHistory.put("oldValue", fixTurkishCharacters(rs.getString("old_value")));
            ticketHistory.put("newValue", fixTurkishCharacters(rs.getString("new_value")));
            ticketHistory.put("actionDate", rs.getTimestamp("action_date").toString());


            ticketArray.put(ticketHistory);
        }
        JsonObject object = new JsonObject();
        object.put("ticket_history", ticketArray);
        out.print(object.toString());

    }catch(Exception ex) {
        out.println("Hata: " + ex.getMessage());
    }finally {
        try {
            if (rs != null) rs.close();
            if (statement != null) statement.close();
            if (connection != null) connection.close();
            if (statement != null) statement.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>


<%!    public  String fixTurkishCharacters(String input) {
    if (input == null) {
        return null;
    }
    String s = input;
    s = s.replace("Ã„Â±", "ı");
    s = s.replace("Ã„Â°", "İ");
    s = s.replace("Ã„ÂŸ", "ğ");
    s = s.replace("Ã„Âž", "Ğ");
    s = s.replace("Ã…ÅŸ", "ş");
    s = s.replace("Ã…Åž", "Ş");
    s = s.replace("ÃƒÂ¼", "ü");
    s = s.replace("ÃƒÂ–", "Ö");
    s = s.replace("ÃƒÂœ", "Ü");
    s = s.replace("Ãœ", "Ü");
    s = s.replace("ÃƒÂ§", "ç");
    s = s.replace("Ãƒâ€¹", "Ç");
    s = s.replace("Ã\\u2021", "Ç");
    s = s.replace("ÃƒÂ¶", "ö");
    s = s.replace("Ä±", "ı");
    s = s.replace("Ä°", "İ");
    s = s.replace("ÄŸ", "ğ");
    s = s.replace("Äž", "Ğ");
    s = s.replace("ÅŸ", "ş");
    s = s.replace("Åž", "Ş");
    s = s.replace("Ã¼", "ü");
    s = s.replace("Ãœ", "Ü");
    s = s.replace("Ã§", "ç");
    s = s.replace("Ã‡", "Ç");
    s = s.replace("Ã¶", "ö");
    s = s.replace("Ã–", "Ö");

    return s;
}
%>