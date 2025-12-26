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
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.USER);
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    if (!can.bRead) {
        response.sendRedirect("../../access_denied.jsp");
        return;
    }
%>
<%
    //String pCustId = request.getParameter("custId");
    String custID = cust.s_cust_id;

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;
    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {
            sSql = "select * from ccps_category where cust_id=?";


            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1, custID);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                data = new JsonObject();

                String categoryId = String.valueOf(rs.getInt(2));
                String categoryName = rs.getString(3);

                data.put("categoryId", categoryId);
                data.put("categoryName", categoryName);
                array.put(data);

            }

            rs.close();
            out.println(array);


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

