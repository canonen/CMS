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
    System.out.println("--------------CUSTOMFIELDS------------");

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

        Integer attrId = 0;
        String attrName = null;
        Integer valueQty = null;
        String displayName = null;
        Integer displaySeq = 0;
        Integer fingerprintSeq = null;
        Integer newsletterFlag = null;
        String typeName = null;

        String customFieldsSqlQuery = "SELECT a.attr_id, a.attr_name, a.value_qty, ca.display_name, ca.display_seq, ca.fingerprint_seq, ca.newsletter_flag, t.type_name FROM ccps_cust_attr ca, ccps_attribute a, ccps_data_type t WHERE ca.cust_id=" + sCustId + " AND ca.attr_id = a.attr_id AND a.type_id = t.type_id AND ISNULL(ca.display_seq, 0) > 0 AND ISNULL(a.internal_flag,0) <= 0 ORDER BY display_seq, display_name";

        resultSet = statement.executeQuery(customFieldsSqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            attrId = resultSet.getInt(1);
            attrName = resultSet.getString(2);
            valueQty = resultSet.getInt(3);
            displayName = resultSet.getString(4);
            displaySeq = resultSet.getInt(5);
            fingerprintSeq = resultSet.getInt(6);
            newsletterFlag = resultSet.getInt(7);
            typeName = resultSet.getString(8);

            JSONObject data = new JSONObject();
            data.put("attrId", attrId);
            data.put("attrName", attrName);
            data.put("valueQty", valueQty);
            data.put("displayName", displayName);
            data.put("displaySeq", displaySeq);
            data.put("fingerprintSeq", fingerprintSeq);
            data.put("newsletterFlag", newsletterFlag);
            data.put("typeName", typeName);
            array.put(data);
        }
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("customFields", array);
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
