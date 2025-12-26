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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp" %>
<%--<%@ include file="../header.jsp" %>--%>

<%
    response.setContentType("*/*");
    response.setHeader("Access-Control-Allow-Origin","https://cms.revotas.com:3001");
    response.setHeader("Access-Control-Allow-Methods","GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Credentials", "true");
%>
<%! static Logger logger = null;%>

<%

    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    ServletInputStream sis = request.getInputStream();
    BufferedReader in = new BufferedReader(new InputStreamReader(sis));

    String config_param = in.readLine();

%>
<%

    //config_param = java.net.URLEncoder.encode(config_param);
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String enabled = request.getParameter("enabled");
    String cust_id = request.getParameter("cust_id");
    String form_id = request.getParameter("form_id");
    String popup_name = request.getParameter("popup_name");
    String popup_id = request.getParameter("popup_id");
    String is_order = request.getParameter("is_order");
    String order_number = request.getParameter("order_number");
    String rcp_link = request.getParameter("rcp_link");
	
    //boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    JsonObject jsonObject = new JsonObject();

    out.println("cust_id : " + cust_id);
    out.println("enabled : " + enabled);
    out.println("form_id : " + form_id);
    out.println("popup_name : " + popup_name);
    out.println("popup_id : " + popup_id);
    out.println("is_order : " + is_order);
    out.println("order_number : " + order_number);
    out.println("rcp_link : " + rcp_link);
    out.println("config_param : " + config_param);

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("save_smartwidget_config.jsp");
        if (is_order != null && is_order.equals("1")) {
            String[] orderArray = order_number.split(",");
            String[] popupArray = popup_id.split(",");
            for (int i = 0; i < orderArray.length; i++) {
                String s = popupArray[i];
                String sql = "UPDATE c_smart_widget_config SET order_number = ? WHERE popup_id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, orderArray[i]);
                pstmt.setString(2, s);
                pstmt.executeUpdate();
            }
        }
        else {
            Integer order_number_2 = 0;
            String sql = "select top 1 order_number from c_smart_widget_config where cust_id = ? order by order_number desc";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1,Long.parseLong(cust_id));
            rs = pstmt.executeQuery();
            if(rs.next())
                order_number_2 = rs.getInt(1) + 1;

            pstmt.close();
            rs.close();

            sql = "IF (NOT EXISTS(SELECT id FROM c_smart_widget_config WHERE cust_id = ? AND popup_id = ?)) " +
                    "BEGIN " +
                    "INSERT INTO c_smart_widget_config (cust_id,popup_id,popup_name,form_id,config_param,status,rcp_link,create_date,modify_date,order_number) VALUES (?,?,?,?,?,?,?,getdate(),getdate(),'"+order_number_2+"') " +
                    "END " +
                    "ELSE " +
                    "BEGIN " +
                    "UPDATE c_smart_widget_config SET popup_name = ?, form_id = ?, config_param = ?, status = ?, rcp_link = ?, modify_date = getdate() WHERE cust_id = ? AND popup_id = ? " +
                    "END ";

            pstmt = conn.prepareStatement(sql);
            int x=1;
            pstmt.setLong(x++,Long.parseLong(cust_id));
            pstmt.setString(x++,popup_id);
            pstmt.setLong(x++,Long.parseLong(cust_id));
            pstmt.setString(x++,popup_id);
            pstmt.setString(x++,popup_name);
            pstmt.setLong(x++,Long.parseLong(form_id));
            pstmt.setString(x++,config_param);
            pstmt.setLong(x++,Long.parseLong(enabled));
            pstmt.setString(x++,rcp_link);
            pstmt.setString(x++,popup_name);
            pstmt.setLong(x++,Long.parseLong(form_id));
            pstmt.setString(x++,config_param);
            pstmt.setLong(x++,Long.parseLong(enabled));
            pstmt.setString(x++,rcp_link);
            pstmt.setLong(x++,Long.parseLong(cust_id));
            pstmt.setString(x++,popup_id);

            pstmt.executeUpdate();
            jsonObject.put("status_code", "200");
            jsonObject.put("status_txt", "OK");
            //out.println(jsonObject);
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