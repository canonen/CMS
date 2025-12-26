<%@ page language="java"
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
<%@ include file="../header.jsp" %>


<%!
    private static final Logger log = Logger.getLogger("save_persserch_config.jsp");
%>
<%

    String enabled = request.getParameter("enabled");
    String cust_id = request.getParameter("cust_id");
    String rcp_link = request.getParameter("rcp_link");
    String filter_id = request.getParameter("filter_id");
    String config_param = request.getParameter("config_param");
    String exclude_recently_viewed = request.getParameter("exclude_recently_viewed");
    String exclude_recently_purchased = request.getParameter("exclude_recently_purchased");
    ServletInputStream sis = request.getInputStream();
    BufferedReader in = new BufferedReader(new InputStreamReader(sis, "UTF-8"));

    String configParam = request.getParameter("object");

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    Integer personalSearchId = null;



    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("save_smartwidget_config.jsp");

        String sql = "IF (NOT EXISTS(SELECT id FROM c_personal_search_config WHERE cust_id = ?)) " +
                "BEGIN " +
                "INSERT INTO c_personal_search_config (cust_id,config_param,status,create_date,modify_date,rcp_link,filter_id,exclude_recently_viewed,exclude_recently_purchased) OUTPUT inserted.id AS newId VALUES (?,?,?,getdate(),getdate(),?,?,?,?) " +
                "END " +
                "ELSE " +
                "BEGIN " +
                "UPDATE c_personal_search_config SET config_param = ?, status = ?, modify_date = getdate(), rcp_link = ?, filter_id = ?, exclude_recently_viewed = ?, exclude_recently_purchased = ? OUTPUT inserted.id AS newId WHERE cust_id = ? " +
                "END ";

        pstmt = conn.prepareStatement(sql);
        int x = 1;
        pstmt.setLong(x++, Long.parseLong(cust_id));
        pstmt.setLong(x++,Long.parseLong(cust_id));
        pstmt.setString(x++,configParam == null ? "{}" : configParam);
        pstmt.setLong(x++, Long.parseLong(enabled));
        pstmt.setString(x++, rcp_link);
        pstmt.setString(x++, filter_id);
        pstmt.setString(x++, exclude_recently_viewed);
        pstmt.setString(x++, exclude_recently_purchased);
        pstmt.setString(x++,configParam == null ? "{}" : configParam);
        pstmt.setLong(x++, Long.parseLong(enabled));
        pstmt.setString(x++, rcp_link);
        pstmt.setString(x++, filter_id);
        pstmt.setString(x++, exclude_recently_viewed);
        pstmt.setString(x++, exclude_recently_purchased);
        pstmt.setLong(x++, Long.parseLong(cust_id));

        boolean hasResult = pstmt.execute();

        if (hasResult) {
            try {
                ResultSet rs1 = pstmt.getResultSet();
                if (rs1.next()) {
                    personalSearchId = rs1.getInt("newId");
                }
                rs1.close();
            } catch (Exception e){
                log.error("Error while getting returned ID", e);
            }

        }

        int persSearchEditId = -1;

        if(personalSearchId != null && personalSearchId != 0){
            String sqlhistory = "SELECT personal_search_id FROM c_personal_search_edit_info WHERE personal_search_id = ?";
            pstmt = conn.prepareStatement(sqlhistory);
            pstmt.setInt(1, personalSearchId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                persSearchEditId = rs.getInt(1);
            }
            pstmt.close();
            rs.close();


            if(persSearchEditId == -1){
                String insertSql = "INSERT INTO c_personal_search_edit_info " +
                        "(personal_search_id,creator_id,create_date) " +
                        "VALUES (?,?,getdate())";
                pstmt = conn.prepareStatement(insertSql);
                pstmt.setInt(1, personalSearchId);
                pstmt.setInt(2, Integer.parseInt(user.s_user_id));
                pstmt.executeUpdate();
                pstmt.close();
                rs.close();
            }else {
               String updateSql = "UPDATE c_personal_search_edit_info  SET modify_date = getdate(), modifier_id = ? WHERE personal_search_id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, Integer.parseInt(user.s_user_id));
                pstmt.setInt(2, persSearchEditId);
                pstmt.executeUpdate();
                pstmt.close();
                rs.close();
            }

        }
        out.println("Success");

    } catch (Exception e) {
        System.out.println("CustID :" + cust_id + "->User İnfo save error :" + e);
        out.println("Not Saved");
        out.print(e);
    } finally {

        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);

    }

%>