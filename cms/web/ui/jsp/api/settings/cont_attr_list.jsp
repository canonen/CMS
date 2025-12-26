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
<%@ include file="../validator.jsp" %>

<%
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
    //String sCustId = request.getParameter("custId");
    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;
    if (!can.bExecute) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
%>
<%
    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        Integer attrId = 0;
        String attrName = null;
        String attrValue = null;
        String attrValue2 = null;
        String attrValue3 = null;

        String contentSqlQuery = "SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'self', 'yes'" +
                "FROM ccps_cont_attr a\n" +
                "LEFT JOIN ccps_cont_attr_value v ON v.attr_id = a.attr_id AND v.cust_id = a.cust_id\n" +
                "WHERE a.cust_id =" + cust.s_cust_id + "\n" +
                "AND a.propagate_flag = 1\n" +
                "UNION    \n" +
                "SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'self', 'no'" +
                "FROM ccps_cont_attr a\n" +
                "LEFT JOIN ccps_cont_attr_value v ON v.attr_id = a.attr_id AND v.cust_id = a.cust_id\n" +
                "WHERE a.cust_id =" + cust.s_cust_id + "\n" +
                "AND a.propagate_flag != 1\n" +
                "UNION    \n" +
                "SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'parent', '--'" +
                "FROM ccps_customer c\n" +
                "LEFT JOIN ccps_cont_attr a ON c.parent_cust_id = a.cust_id AND a.propagate_flag = 1 \n" +
                "LEFT OUTER JOIN ccps_cont_attr_value v ON c.cust_id = v.cust_id AND a.attr_id = v.attr_id\n" +
                "WHERE c.cust_id =" + cust.s_cust_id + "\n" +
                "ORDER BY 2";

        resultSet = statement.executeQuery(contentSqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            attrId = resultSet.getInt(1);
            attrName = resultSet.getString(2);
            attrValue = resultSet.getString(3);
            attrValue2 = resultSet.getString(4);
            attrValue3 = resultSet.getString(5);

            JSONObject data = new JSONObject();
            data.put("attrId", resultSet.getInt(1));
            data.put("attrName", attrName);
            data.put("attrValue", attrValue);
            data.put("attrValue2", attrValue2);
            data.put("attrValue3", attrValue3);
            array.put(data);
        }
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("Content", array);

        resultSet.close();

        out.print(jsonObject);

    } catch (Exception exception) {
        exception.printStackTrace();
    } finally {
        if (resultSet != null) resultSet.close();
        if (statement != null) statement.close();
        if (connection != null) connectionPool.free(connection);
    }


%>
