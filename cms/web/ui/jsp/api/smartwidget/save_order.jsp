<%@  page language="java"
          import="java.net.*,
                  com.britemoon.*,
                  com.britemoon.cps.*,
                  java.sql.*,
                  java.util.Date,
                  java.io.*,
                  java.math.BigDecimal,
                  java.text.NumberFormat,
                  java.util.Locale,
                  java.io.*,
                  org.apache.log4j.Logger,
                  org.w3c.dom.*"
          contentType="text/html;charset=UTF-8"
%>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>
<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    String enabled = request.getParameter("enabled");
    String cust_id = request.getParameter("cust_id");
    String form_id = request.getParameter("form_id");
    String popup_name = request.getParameter("popup_name");
    String popup_id = request.getParameter("popup_id");
    String isOrder = request.getParameter("is_order");
    String orderString = request.getParameter("order_string");
    String rcp_link = request.getParameter("rcp_link");
    ServletInputStream sis = request.getInputStream();
    BufferedReader in = new BufferedReader(new InputStreamReader(sis));

    String configParam = in.readLine();

    //configParam = java.net.URLEncoder.encode(configParam);
%>
<%


    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("save_order.jsp");
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
                out.println("205");
            else
                out.println("500");
        } else {
            Integer orderNumber = 0;
            String sql = "select top 1 order_number from c_smart_widget_config where cust_id = ? order by order_number desc";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1, Long.parseLong(cust_id));
            rs = pstmt.executeQuery();
            if (rs.next())
                orderNumber = rs.getInt(1) + 1;

            pstmt.close();
            rs.close();


            sql = "IF (NOT EXISTS(SELECT id FROM c_smart_widget_config WHERE cust_id = ? AND popup_id = ?)) " +
                    "BEGIN " +
                    "INSERT INTO c_smart_widget_config (cust_id,popup_id,popup_name,form_id,config_param,status,rcp_link,create_date,modify_date,order_number) VALUES (?,?,?,?,?,?,?,getdate(),getdate(),'" + orderNumber + "') " +
                    "END " +
                    "ELSE " +
                    "BEGIN " +
                    "UPDATE c_smart_widget_config SET popup_name = ?, form_id = ?, config_param = ?, status = ?, rcp_link = ?, modify_date = getdate() WHERE cust_id = ? AND popup_id = ? " +
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
            pstmt.setString(x++, rcp_link);
            pstmt.setString(x++, popup_name);
            pstmt.setLong(x++, Long.parseLong(form_id));
            pstmt.setString(x++, configParam);
            pstmt.setLong(x++, Long.parseLong(enabled));
            pstmt.setString(x++, rcp_link);
            pstmt.setLong(x++, Long.parseLong(cust_id));
            pstmt.setString(x++, popup_id);

            pstmt.executeUpdate();
            out.println("200");
        }
    } catch (Exception e) {
        System.out.println("CustID :" + cust_id + "->User İnfo save error :" + e);
        out.print(e);
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
    }

%>