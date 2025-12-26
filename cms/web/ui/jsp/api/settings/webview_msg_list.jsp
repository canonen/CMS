<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Calendar,
                java.io.*,
                org.apache.log4j.Logger,
                java.text.DateFormat,
                org.json.JSONArray,
                org.json.JSONObject,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="validator.jsp" %>
<%

    String sCustId = cust.s_cust_id;
    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;


    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        Integer msgId = 0;
        String msgName = null;

        String webViewSqlQuery = "SELECT u.msg_id, u.msg_name FROM ccps_webview_msg u WHERE cust_id=" + sCustId + "ORDER BY msg_name";

        resultSet = statement.executeQuery(webViewSqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            msgId = resultSet.getInt(1);
            msgName = resultSet.getString(2);

            JSONObject data = new JSONObject();
            data.put("msgId", msgId);
            data.put("msgName", msgName);
            array.put(data);
        }

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("WebView", array);

        resultSet.close();

        out.print(jsonObject);

    } catch (Exception exception) {
        System.out.println(sCustId + exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (resultSet != null) resultSet.close();
        if(statement != null) statement.close();
        if(connection != null) connectionPool.free(connection);
        
    }

%>
