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
    System.out.println("--------------WEBView------------");

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

        Integer msg_id = 0;
        String msg_name = null;

        String webViewSqlQuery = "SELECT u.msg_id, u.msg_name FROM ccps_webview_msg u WHERE cust_id="+sCustId+"ORDER BY msg_name";

        resultSet = stmt.executeQuery(webViewSqlQuery);

        JSONArray array = new JSONArray();

        while(resultSet.next()){
            msg_id = resultSet.getInt(1);
            msg_name = resultSet.getString(2);

            JSONObject data = new JSONObject();
            data.put("msg_id", msg_id);
            data.put("msg_name", msg_name);
            array.put(data);
        }

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("WebView", array);

        resultSet.close();

        out.print(jsonObject);

    }catch (Exception exception) {
        System.out.println(sCustId + exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (stmt != null) {
            stmt.close();
            conn.close();
        }
    }

%>
