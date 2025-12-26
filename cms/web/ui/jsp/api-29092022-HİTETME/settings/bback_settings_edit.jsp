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

        Integer max_bbacks = 0;
        Integer max_bback_days = 0;
        Integer max_consec_bbacks = 0;
        Integer max_consec_bback_days = 0;

        String maxBBackSqlQuery = "SELECT max_bbacks, max_bback_days, max_consec_bbacks, max_consec_bback_days FROM ccps_customer WHERE cust_id =" + sCustId + "";

        resultSet = stmt.executeQuery(maxBBackSqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            max_bbacks = resultSet.getInt(1);
            max_bback_days = resultSet.getInt(2);
            max_consec_bbacks = resultSet.getInt(3);
            max_consec_bback_days = resultSet.getInt(4);

            JSONObject data = new JSONObject();
            data.put("max_bbacks", max_bbacks);
            data.put("max_bback_days", max_bback_days);
            data.put("max_consec_bbacks", max_consec_bbacks);
            data.put("max_consec_bback_days", max_consec_bback_days);
            array.put(data);
        }

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("Max BBack", array);

        resultSet.close();

        out.print(jsonObject);

        Integer category_id = 0;
        String category_name = null;
        Integer bback_category_id = 0;

        String bBackCategorySqlQuery = "SELECT c.category_id, c.category_name, h.bback_category_id FROM crpt_bback_category c LEFT OUTER JOIN ccps_cust_hard_bback h ON c.category_id = h.bback_category_id AND h.cust_id =" + sCustId + " ORDER BY c.category_id";

        resultSet = stmt.executeQuery(bBackCategorySqlQuery);

        JSONArray array2 = new JSONArray();

        while (resultSet.next()) {
            category_id = resultSet.getInt(1);
            category_name = resultSet.getString(2);
            bback_category_id = resultSet.getInt(3);

            JSONObject data2 = new JSONObject();
            data2.put("category_id", category_id);
            data2.put("category_name", category_name);
            data2.put("bback_category_id", bback_category_id);
            array2.put(data2);
        }

        JSONObject jsonObject2 = new JSONObject();
        jsonObject2.put("Bback Category", array2);

        resultSet.close();

        out.print(jsonObject2);

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
