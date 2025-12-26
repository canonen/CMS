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
    System.out.println("--------------FROMADDRESS------------");

    String sCustId = request.getParameter("custId");
    Statement stmt = null;
    ResultSet resultSet = null;
    ConnectionPool cp = null;
    Connection conn = null;
%>
<%
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        Integer category_id = 0;
        String category_name = null;
        String category_descrip = "";

        String categorySqlQuery = "SELECT category_id, category_name, ISNULL(category_descrip,'') FROM ccps_category WHERE cust_id=" + sCustId + " ORDER BY category_name";

        resultSet = stmt.executeQuery(categorySqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            category_id = resultSet.getInt(1);
            category_name = resultSet.getString(2);
            category_descrip = resultSet.getString(3);

            JSONObject data = new JSONObject();
            data.put("category_id", category_id);
            data.put("category_name", category_name);
            data.put("category_descrip", category_descrip);
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
        if (stmt != null) {
            stmt.close();
            conn.close();
        }
    }
%>
