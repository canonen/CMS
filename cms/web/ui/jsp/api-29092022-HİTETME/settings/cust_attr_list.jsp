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
    System.out.println("--------------CUSTOMFIELDS------------");

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
        Integer value_qty = null;
        String display_name = null;
        Integer display_seq = 0;
        Integer fingerprint_seq = null;
        Integer newsletter_flag = null;
        String type_name = null;

        String customFieldsSqlQuery = "SELECT a.attr_id, a.attr_name, a.value_qty, ca.display_name, ca.display_seq, ca.fingerprint_seq, ca.newsletter_flag, t.type_name FROM ccps_cust_attr ca, ccps_attribute a, ccps_data_type t WHERE ca.cust_id=" + sCustId + " AND ca.attr_id = a.attr_id AND a.type_id = t.type_id AND ISNULL(ca.display_seq, 0) > 0 AND ISNULL(a.internal_flag,0) <= 0 ORDER BY display_seq, display_name";

        resultSet = stmt.executeQuery(customFieldsSqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            attr_id = resultSet.getInt(1);
            attr_name = resultSet.getString(2);
            value_qty = resultSet.getInt(3);
            display_name = resultSet.getString(4);
            display_seq = resultSet.getInt(5);
            fingerprint_seq = resultSet.getInt(6);
            newsletter_flag = resultSet.getInt(7);
            type_name = resultSet.getString(8);

            JSONObject data = new JSONObject();
            data.put("attr_id", attr_id);
            data.put("attr_name", attr_name);
            data.put("value_qty", value_qty);
            data.put("display_name", display_name);
            data.put("display_seq", display_seq);
            data.put("fingerprint_seq", fingerprint_seq);
            data.put("newsletter_flag", newsletter_flag);
            data.put("type_name", type_name);
            array.put(data);
        }
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("Custom Fields", array);
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
