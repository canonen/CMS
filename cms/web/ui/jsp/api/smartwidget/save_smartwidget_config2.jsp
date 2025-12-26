<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "https://dev.revotas.com:3002");
%>
<%@ page
        language="java"
        import="java.net.*,
                com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Date,
                java.io.*,
                java.math.BigDecimal,
                java.text.NumberFormat,
                java.util.Locale,
                java.util.Calendar,
                org.apache.log4j.Logger,
                java.text.DateFormat,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%--<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "https://dev.revotas.com:3002");
    //response.setHeader("Access-Control-Allow-Credentials", "true");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
    response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>--%>


<%--<%
        response.setContentType("application/json");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>--%>
<%
    String enabled = request.getParameter("enabled");
    String cust_id = request.getParameter("cust_id");
    String form_id = request.getParameter("form_id");
    String popup_name = request.getParameter("popup_name");
    String popup_id = request.getParameter("popup_id");
    String isOrder = request.getParameter("is_order");
    String orderString = request.getParameter("order_string");
    String configParam = request.getParameter("config_param");

    /*ServletInputStream sis = request.getInputStream();
    BufferedReader in = new BufferedReader(new InputStreamReader(sis));
    String configParam = in.readLine();*/
    out.println("configParam : " + configParam);
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

    //configParam = java.net.URLEncoder.encode(configParam);
%>
<%

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    out.println("selam  " );
    System.out.println("selam2  " );

/*    try {
        if (configParam == null) {
            out.println("configparam null !! ");
            configParam = "bbb";
        }
        out.println("cust_id : " + cust_id);
        out.println("popup_name : " + popup_name);
        out.println("isOrder : " + isOrder);
        out.println("popup_id : " + popup_id);
        out.println("configParam : " + configParam);
        out.println("enabled : " + enabled);
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("save_smartwidget_config.jsp");

        if (isOrder != null && isOrder.equals("1")) {
            String[] orderArray = orderString.split(",");
            String sql = "UPDATE c_smart_widget_config SET order_number = ? WHERE popup_id = ?";
            pstmt = conn.prepareStatement(sql);
            for (int i = 0; i < orderArray.length; i++) {
                int x = 1;
                pstmt.setLong(x++, i);
                pstmt.setString(x++, orderArray[i]);
                pstmt.addBatch();
            }
            int[] result = pstmt.executeBatch();

            if (result.length > 0)
                out.println("200");
            else
                out.println("500");
        } else {
            String sql = "IF (NOT EXISTS(SELECT id FROM c_smart_widget_config WHERE cust_id = ? AND popup_id = ?)) " +
                    "BEGIN " +
                    "INSERT INTO c_smart_widget_config (cust_id,popup_id,popup_name,form_id,config_param,status,create_date,modify_date,order_number) VALUES (?,?,?,?,?,?,getdate(),getdate(),'1000') " +
                    "END " +
                    "ELSE " +
                    "BEGIN " +
                    "UPDATE c_smart_widget_config SET popup_name = ?, form_id = ?, config_param = ?, status = ?, modify_date = getdate() WHERE cust_id = ? AND popup_id = ? " +
                    "END ";


            pstmt = conn.prepareStatement(sql);
            int x = 1;
            pstmt.setLong(x++, Long.parseLong(cust_id));
            pstmt.setString(x++, popup_id);
            pstmt.setLong(x++, Long.parseLong(cust_id));
            pstmt.setString(x++, popup_id);
            pstmt.setString(x++, popup_name);
            pstmt.setLong(x++, Long.parseLong(form_id));
            pstmt.setString(x++, configParam);
            pstmt.setLong(x++, Long.parseLong(enabled));
            pstmt.setString(x++, popup_name);
            pstmt.setLong(x++, Long.parseLong(form_id));
            pstmt.setString(x++, configParam);
            pstmt.setLong(x++, Long.parseLong(enabled));
            pstmt.setLong(x++, Long.parseLong(cust_id));
            pstmt.setString(x++, popup_id);

            pstmt.executeUpdate();


            jsonObject.put("status_code", "200");
            jsonObject.put("status_txt", "OK");
            jsonArray.put(jsonObject);
            out.print(jsonArray);
            //out.println("200");
        }
    } catch (Exception e) {
        System.out.println("CustID :" + cust_id + "->User İnfo save error :" + e);
        out.print(e);
    } finally {
        out.println("configParam : ");
        out.println(configParam);
        try {
            if (pstmt != null) pstmt.close();
        } catch (Exception ignore) {
        }

        if (conn != null) {
            cp.free(conn);
        }

    }*/

%>