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
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%


        String custId = request.getParameter("custId");
        JsonArray popupListData = new JsonArray();
    JsonObject data = new JsonObject();
        ConnectionPool cp = null;
        Connection conn = null;
        Statement stmt =null;
        ResultSet rs =null ;

        String popupName ="";
        String popup_id ="";
        String modify_date ="";
        String create_date ="";
        String config_param ="";

        try
        {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection(this);

            stmt = conn.createStatement();

            String sSql =
                    " SELECT" +
                            "	popup_name," +
                            "	popup_id," +
                            "	modify_date," +
                            "	create_date," +
                            "	config_param" +
                            " FROM c_smart_widget_config" +
                            " WHERE status <> 90 AND " +
                            "	cust_id=" + custId +
                            " ORDER BY order_number asc";

             rs = stmt.executeQuery(sSql);
            while (rs.next()){
                data = new JsonObject();

                popupName = rs.getString(1);
                popup_id = rs.getString(2);
                modify_date = rs.getString(3);
                create_date = rs.getString(4);
                config_param = rs.getString(5);


                data.put("popupName",popupName);
                data.put("popup_id",popup_id);
                data.put("modify_date",modify_date);
                data.put("create_date",create_date);
                data.put("config_param", new String(rs.getBytes(5), "UTF-8"));
              //  data.put("config_param",config_param);

                popupListData.put(data);

            }
            rs.close();




            out.print(popupListData.toString());
        }catch (Exception exception){
            exception.getMessage();
        }finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) { /* Ignored */}
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) { /* Ignored */}
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) { /* Ignored */}
            }
        }

%>