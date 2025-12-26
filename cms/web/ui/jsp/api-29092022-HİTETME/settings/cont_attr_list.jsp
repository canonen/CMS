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
    System.out.println("--------------CONTENT------------");

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

        Integer attr_id = 0;
        String attr_name = null;
        String attr_value = null;
        String attr_value2 = null;
        String attr_value3 = null;

        String contentSqlQuery = "SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'self', 'yes'" +
                "FROM ccps_cont_attr a\n" +
                "LEFT JOIN ccps_cont_attr_value v ON v.attr_id = a.attr_id AND v.cust_id = a.cust_id\n" +
                "WHERE a.cust_id =" + sCustId + "\n" +
                "AND a.propagate_flag = 1\n" +
                "UNION    \n" +
                "SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'self', 'no'" +
                "FROM ccps_cont_attr a\n" +
                "LEFT JOIN ccps_cont_attr_value v ON v.attr_id = a.attr_id AND v.cust_id = a.cust_id\n" +
                "WHERE a.cust_id =" + sCustId + "\n" +
                "AND a.propagate_flag != 1\n" +
                "UNION    \n" +
                "SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'parent', '--'" +
                "FROM ccps_customer c\n" +
                "LEFT JOIN ccps_cont_attr a ON c.parent_cust_id = a.cust_id AND a.propagate_flag = 1 \n" +
                "LEFT OUTER JOIN ccps_cont_attr_value v ON c.cust_id = v.cust_id AND a.attr_id = v.attr_id\n" +
                "WHERE c.cust_id =" + sCustId + "\n" +
                "ORDER BY 2";

        resultSet = stmt.executeQuery(contentSqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            attr_id = resultSet.getInt(1);
            attr_name = resultSet.getString(2);
            attr_value = resultSet.getString(3);
            attr_value2 = resultSet.getString(4);
            attr_value3 = resultSet.getString(5);

            JSONObject data = new JSONObject();
            data.put("attr_id", attr_id);
            data.put("attr_name", attr_name);
            data.put("attr_value", attr_value);
            data.put("attr_value2", attr_value2);
            data.put("attr_value3", attr_value3);
            array.put(data);
        }
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("Content", array);

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
