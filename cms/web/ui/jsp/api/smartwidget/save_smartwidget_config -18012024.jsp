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
<%@ include file="../validator.jsp" %>
<%
    response.setContentType("*/*");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin","https://cms.revotas.com:3001");
    response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>
<%
    //	String popup_id = request.getParameter("popup_id");
    String isOrder = request.getParameter("is_order");
    //String order_number = request.getParameter("order_number");
    String s_cust_id = cust.s_cust_id;
    ServletInputStream sis = request.getInputStream();
    BufferedReader in = new BufferedReader(new InputStreamReader(sis));

    String configParam = in.readLine();

    //configParam = java.net.URLEncoder.encode(configParam);
%>
<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String ordernumber = request.getParameter("order_number");
    String popupid = request.getParameter("popup_id");
    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("save_smartwidget_config.jsp");
        if (isOrder != null && isOrder.equals("1")) {
            String[] orderArray = ordernumber.split(",");
            String[] popupArray = popupid.split(",");
            for (int i = 0; i < orderArray.length; i++) {
                String s = popupArray[i];

                String sql = "UPDATE c_smart_widget_config SET order_number = ? WHERE popup_id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, orderArray[i]);
                pstmt.setString(2, s);
                pstmt.executeUpdate();
            }
        }
    } catch (Exception e) {
        System.out.println("CustID :" + s_cust_id + "->User İnfo save error :" + e);
        out.print(e);
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
    }

%>