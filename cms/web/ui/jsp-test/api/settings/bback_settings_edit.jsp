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
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../../utilities/validator.jsp" %>
<%@ include file="../header.jsp" %>

<%

%>
<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    JsonObject data = new JsonObject();
    JsonObject jsonObject = new JsonObject();
    JsonObject data2 = new JsonObject();
    JsonObject jsonObject2 = new JsonObject();
    JsonArray x = new JsonArray();
    String sCustId = request.getParameter("custId");
    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;

    JsonArray array3 = null;
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

        JsonArray array = new JsonArray();

        while (resultSet.next()) {
            maxBbacks = resultSet.getInt(1);
            maxBbackDays = resultSet.getInt(2);
            maxConsecBbacks = resultSet.getInt(3);
            maxConsecBbackDays = resultSet.getInt(4);

            data = new JsonObject();
            data.put("max_bouncebacks", maxBbacks);
            data.put("max_bounceback_days", maxBbackDays);
            data.put("max_consec_bouncebacks", maxConsecBbacks);
            data.put("max_consec_bounceback_days", maxConsecBbackDays);

        }


        resultSet.close();


        int categoryId = 0;
        String categoryName = null;
        int bbackCategoryId = 0;

        String bBackCategorySqlQuery = "SELECT c.category_id, c.category_name, h.bback_category_id FROM crpt_bback_category c LEFT OUTER JOIN ccps_cust_hard_bback h ON c.category_id = h.bback_category_id AND h.cust_id =" + sCustId + " ORDER BY c.category_id";

        resultSet = statement.executeQuery(bBackCategorySqlQuery);

        JsonArray array2 = new JsonArray();

        while (resultSet.next()) {
            categoryId = resultSet.getInt(1);
            categoryName = resultSet.getString(2);
            bbackCategoryId = resultSet.getInt(3);

            data2 = new JsonObject();
            data2.put("category_id", categoryId);
            data2.put("category_name", categoryName);

            array2.put(data2);

        }
        jsonObject2.put("max_bounceback", array2);
        jsonObject2.put("bounceback_category", data);


        resultSet.close();


        int bbackCategoryid = 0;

        String bbackCategoryidSqlQuery = "SELECT bback_category_id FROM ccps_cust_hard_bback WHERE cust_id =" + cust.s_cust_id;

        array3 = new JsonArray();
        resultSet = statement.executeQuery(bbackCategoryidSqlQuery);

        while (resultSet.next()) {
            bbackCategoryid = resultSet.getInt(1);
            JsonObject data3 = new JsonObject();
            data3.put("bounceback_category_id", bbackCategoryid);
            array3.put(data3);
        }

        jsonObject2.put("bounceback_category_id", array3);

        resultSet.close();


    } catch (Exception exception) {
        System.out.println(sCustId + exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (statement != null) {
            statement.close();
            connection.close();
        }
    }
    out.print(jsonObject2);
%>
