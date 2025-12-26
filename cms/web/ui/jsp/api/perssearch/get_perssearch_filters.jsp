<%@  page language="java"
          import="java.net.*,
                  com.britemoon.*,
                  com.britemoon.rcp.*,
                  com.britemoon.rcp.imc.*,
                  com.britemoon.rcp.que.*,
                  java.sql.*,
                  java.util.Calendar,
                  java.util.Date,
                  java.io.*,
                  java.math.BigDecimal,
                  java.text.NumberFormat,
                  java.util.Locale,
                  java.util.*,
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

    String cust_id = request.getParameter("cust_id");

    if (cust_id == null)
        return;
%>
<%

    String[] columnList = {"brand", "gender", "product_color", "visible", "size", "top_category_id", "category_id_2", "category_id_3", "category_id_4"};
    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {

        cp = ConnectionPool.getInstance(cust_id);
        conn = cp.getConnection("get_perssearch_filters.jsp");
        String sql = "";


        StringBuilder json = new StringBuilder();
        json.append("{");
        int counter = 0;
        int forCounter = 0;

        for (int i = 0; i < columnList.length; i++) {
            String column = columnList[i];
            sql = "IF COL_LENGTH('z_rec_products', '" + column + "') IS NOT NULL "
                    + "BEGIN "
                    + "select distinct 1 from z_rec_products with(nolock) "
                    + "END "
                    + "ELSE "
                    + "BEGIN "
                    + "select distinct 2 from z_rec_products with(nolock) "
                    + "END";

            pstmt = conn.prepareStatement(sql);

            rs = pstmt.executeQuery();

            int exists = 0;
            if (rs.next()) {
                exists = rs.getInt(1);
            }
            pstmt.close();
            rs.close();
            if (exists == 2) continue;


            if (forCounter != 0)
                json.append(",");


            sql = "select distinct " + column + " from z_rec_products with(nolock)";

            json.append("\"" + column + "\":[");

            pstmt = conn.prepareStatement(sql);

            rs = pstmt.executeQuery();
            counter = 0;

            while (rs.next()) {
                String value = null;
                if (column.equals("visible")) {
                    value = rs.getString(1);
                } else {
                    if (rs.getBytes(1) != null) {
                        value = new String(rs.getBytes(1), "UTF-8");
                    } else {
                        value = null;
                    }
                }
                if (!(value == null || value.equals(""))) {
                    if (counter != 0)
                        json.append(",");
                    json.append("\"" + value + "\"");
                    counter++;
                }
            }

            pstmt.close();
            rs.close();
            json.append("]");
            forCounter++;
        }

        json.append("}");


        out.print(json.toString());


    } catch (Exception e) {
        //System.out.println("CustID :"+cust_id+"->get recommendation data error :"+e);
        //out.print(e);
        throw e;
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
        
    }

%>