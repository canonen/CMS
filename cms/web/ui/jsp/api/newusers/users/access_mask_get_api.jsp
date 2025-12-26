<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.adm.*,
                com.britemoon.cps.wfl.*,
                java.io.*,
                java.sql.*,
                org.json.JSONException,
                org.json.JSONObject,
                org.json.XML,
                org.json.JSONArray,
                java.util.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>


<%@ include file="../../validator.jsp" %>
<%@ include file="../../header.jsp" %>

<%! static Logger logger = null;%>


<%
    String sUserId = request.getParameter("user_id");
    User u = new User(sUserId);


// === === ===


    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;
    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();
    // JSONArray jsonArray = new JSONArray();
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {
            sSql = "SELECT ot.type_id, ot.type_name, mask=ISNULL(am.mask, 0) ";
            sSql += "FROM ccps_object_type ot ";
            sSql += "LEFT OUTER JOIN ccps_access_mask am ";
            sSql += "ON ( ot.type_id = am.type_id ) ";
            sSql += "AND ( am.user_id = ? ) ";
            sSql += "WHERE ( 1 = 1 ) ";

            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1, u.s_user_id);
            JsonObject access = new JsonObject();
            rs = pstmt.executeQuery();
            while (rs.next()) {


                access = new JsonObject();
                access.put("read", (AccessRight.READ & rs.getInt(3)) == AccessRight.READ);
                access.put("write", (AccessRight.WRITE & rs.getInt(3)) == AccessRight.WRITE);
                access.put("execute", (AccessRight.EXECUTE & rs.getInt(3)) == AccessRight.EXECUTE);
                access.put("erase", (AccessRight.DELETE & rs.getInt(3)) == AccessRight.DELETE);
                access.put("approve", (AccessRight.APPROVE & rs.getInt(3)) == AccessRight.APPROVE);
                data.put(String.valueOf(rs.getInt(1)), access);


            }
            array.put(data);
            out.println(array.toString());
            rs.close();


        } catch (Exception ex) {
            throw ex;
        } finally {

            if (pstmt != null) pstmt.close();
        }
    } catch (SQLException sqlex) {
        throw sqlex;
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
    }
%>

