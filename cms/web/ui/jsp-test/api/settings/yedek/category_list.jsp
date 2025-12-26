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
<%
   response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
   response.setHeader("Access-Control-Allow-Credentials", "true");
%>
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

        Integer categoryId = 0;
        String categoryName = null;
        String categoryDescrip = "";

        String categorySqlQuery = "SELECT category_id, category_name, ISNULL(category_descrip,'') FROM ccps_category WHERE cust_id=" + sCustId + " ORDER BY category_name";

        resultSet = statement.executeQuery(categorySqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            categoryId = resultSet.getInt(1);
            categoryName = resultSet.getString(2);
            categoryDescrip = resultSet.getString(3);

            JSONObject data = new JSONObject();
            data.put("categoryId", categoryId);
            data.put("categoryName", categoryName);
            data.put("categoryDescrip", categoryDescrip);
            array.put(data);
        }

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("Category", array);

        resultSet.close();

        out.print(jsonObject);

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
