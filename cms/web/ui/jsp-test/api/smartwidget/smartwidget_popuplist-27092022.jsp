<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			org.json.JSONObject,
			java.text.DateFormat,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../utilities/validator.jsp"%>
<%@ include file="../header.jsp"%>
<%! static Logger logger = null;%>

<%

    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }


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
        int order_number=0;

        try
        {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection(this);

            stmt = conn.createStatement();

            String sSql =
                    " SELECT" +
                            "	order_number" +
                            " FROM c_smart_widget_config" +
                            " WHERE status <> 90 AND " +
                            "	cust_id=" + cust.s_cust_id +
                            " ORDER BY order_number asc";

            System.out.println(cust.s_cust_id);

             rs = stmt.executeQuery(sSql);
            while (rs.next()){
                data = new JsonObject();

               /* popupName = rs.getString(1);
                popup_id = rs.getString(2);
                modify_date = rs.getString(3);
                create_date = rs.getString(4);
                config_param = rs.getString(5);*/
                order_number=rs.getInt(1);


                /*data.put("popupName",popupName);
                data.put("popup_id",popup_id);
                data.put("modify_date",modify_date);
                data.put("create_date",create_date);
                data.put("config_param", new String(rs.getBytes(5), "UTF-8"));*/
              //  data.put("config_param",config_param);
                data.put("OrderNumber",order_number);
  
                popupListData.put(data);

            }
            rs.close();

   out.println(order_number);


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
