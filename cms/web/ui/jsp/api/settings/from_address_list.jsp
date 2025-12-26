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
        errorPage="../../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    System.out.println("--------------FROMADDRESS------------");

    //String sCustId = request.getParameter("custId");
    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;
    String s_cust_id = cust.s_cust_id;
%>
<%
    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        Integer fromAddressId = 0;
        String prefix = null;
        String domain = null;


        String fromAddressSqlQuery = "select from_address_id, prefix, domain from ccps_from_address where cust_id=" + s_cust_id + " order by  prefix";

        resultSet = statement.executeQuery(fromAddressSqlQuery);

        JSONArray array = new JSONArray();
        JSONObject data = new JSONObject();

        while (resultSet.next()) {

            fromAddressId = resultSet.getInt(1);
            prefix = resultSet.getString(2);
            domain = resultSet.getString(3);

            data = new JSONObject();
            data.put("from_address_id", fromAddressId);
            data.put("prefix", prefix + "@" + domain);
            data.put("domain", domain);
            array.put(data);
        }
        //JSONObject jsonObject = new JSONObject();
        //jsonObject.put("FromAddress", array);

        resultSet.close();

        out.println(array);

    } catch (Exception exception) {
        System.out.println(s_cust_id + exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (resultSet != null) resultSet.close();
        if (statement != null) statement.close();
        if (connection != null) connectionPool.free(connection);
    }


%>

