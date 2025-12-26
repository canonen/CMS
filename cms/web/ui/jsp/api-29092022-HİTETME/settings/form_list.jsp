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
                org.json.JSONObject,
                org.json.JSONArray,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>

<%
    System.out.println("--------------SUBSCRIPTION------------");

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

        Integer form_id = 0;
        String form_name = null;
        String form_url = null;
        String modify_date = null;
        String create_date = null;

        String subscriptionFormSqlQuery = "SELECT f.form_id, f.form_name, f.form_url, fei.modify_date, fei.create_date FROM csbs_form f, csbs_form_edit_info fei WHERE f.cust_id=" + sCustId + "AND fei.form_id = f.form_id ORDER BY fei.modify_date desc";

        resultSet = stmt.executeQuery(subscriptionFormSqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
            form_id = resultSet.getInt(1);
            form_name = resultSet.getString(2);
            form_url = resultSet.getString(3);
            modify_date = resultSet.getString(4);
            create_date = resultSet.getString(5);

            JSONObject data = new JSONObject();
            data.put("form_id", form_id);
            data.put("form_name", form_name);
            data.put("form_url", form_url);
            data.put("modify_date", modify_date);
            data.put("create_date", create_date);
            array.put(data);
        }
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("Subscription", array);

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
