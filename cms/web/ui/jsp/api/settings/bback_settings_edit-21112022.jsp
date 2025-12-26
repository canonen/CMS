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

<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>

<%
    System.out.println("--------------FROMADDRESS------------");

    String sCustId = request.getParameter("custId");
    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;
%>
<%

    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        Integer maxBbacks = 0;
        Integer maxBbackDays = 0;
        Integer maxConsecBbacks = 0;
        Integer maxConsecBbackDays = 0;

        String maxBBackSqlQuery = "SELECT max_bbacks, max_bback_days, max_consec_bbacks, max_consec_bback_days FROM ccps_customer WHERE cust_id =" + cust.s_cust_id;

        resultSet = statement.executeQuery(maxBBackSqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            maxBbacks = resultSet.getInt(1);
            maxBbackDays = resultSet.getInt(2);
            maxConsecBbacks = resultSet.getInt(3);
            maxConsecBbackDays = resultSet.getInt(4);

            JSONObject data = new JSONObject();
            data.put("maxBbacks", maxBbacks);
            data.put("maxBbackDays", maxBbackDays);
            data.put("maxConsecBbacks", maxConsecBbacks);
            data.put("maxConsecBbackDays", maxConsecBbackDays);
            array.put(data);
        }

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("Max_BBack", array);

        resultSet.close();

        out.print(jsonObject);

        Integer categoryId = 0;
        String categoryName = null;
        Integer bbackCategoryId = 0;

        String bBackCategorySqlQuery = "SELECT c.category_id, c.category_name, h.bback_category_id FROM crpt_bback_category c LEFT OUTER JOIN ccps_cust_hard_bback h ON c.category_id = h.bback_category_id AND h.cust_id =" + sCustId + " ORDER BY c.category_id";

        resultSet = statement.executeQuery(bBackCategorySqlQuery);

        JSONArray array2 = new JSONArray();

        while (resultSet.next()) {
            categoryId = resultSet.getInt(1);
            categoryName = resultSet.getString(2);
            bbackCategoryId = resultSet.getInt(3);

            JSONObject data2 = new JSONObject();
            data2.put("categoryId", categoryId);
            data2.put("categoryName", categoryName);
            data2.put("bbackCategoryId", bbackCategoryId);
            array2.put(data2);
        }

        JSONObject jsonObject2 = new JSONObject();
        jsonObject2.put("Bback_Category", array2);

        resultSet.close();

        out.print(jsonObject2);

    } catch (Exception exception) {
        System.out.println(sCustId + exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (statement != null) {
            statement.close();
            connection.close();
        }
    }
%>
