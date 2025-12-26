<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
        errorPage="../../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);

    if(!can.bWrite)
    {
        response.sendRedirect("../../access_denied.jsp");
        return;
    }
    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    StringWriter sw = new StringWriter();
    JsonArray jsonArray = new JsonArray();
    String sSql="";

    try
    {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        sSql = "SELECT ca.attr_id, ca.display_name, dt.type_name FROM ccps_attribute a, ccps_cust_attr ca, ccps_data_type dt " +
                "WHERE ca.cust_id=? AND a.attr_id = ca.attr_id AND a.type_id = dt.type_id " +
                "AND ISNULL(ca.display_seq, 0) > 0 AND ISNULL(ca.recip_view_seq, 0) > 0 " +
                "AND ISNULL(a.internal_flag,0) <= 0 ORDER BY ca.recip_view_seq, ca.display_name";

        pstmt = conn.prepareStatement(sSql);
        pstmt.setString(1, cust.s_cust_id);

        rs = pstmt.executeQuery();

        while (rs.next()) {
            JsonObject jsonObj = new JsonObject();
            jsonObj.put("attr_id", rs.getString(1));
            jsonObj.put("display_name", new String(rs.getBytes(2), "UTF-8"));
            jsonObj.put("type_name", rs.getString(3));
            jsonObj.put("visit_type","visible");
            jsonArray.put(jsonObj);
        }
        rs.close();
        sSql="SELECT ca.attr_id, ca.display_name, dt.type_name FROM ccps_attribute a, ccps_cust_attr ca, ccps_data_type dt " +
                "WHERE ca.cust_id=? AND a.attr_id = ca.attr_id AND a.type_id = dt.type_id " +
                "AND ISNULL(ca.display_seq, 0) > 0 AND ISNULL(ca.recip_view_seq, 0) <= 0 " +
                "AND ISNULL(a.internal_flag,0) <= 0 ORDER BY ca.recip_view_seq, ca.display_name";

        pstmt = conn.prepareStatement(sSql);
        pstmt.setString(1, cust.s_cust_id);

        rs = pstmt.executeQuery();

        while (rs.next()) {
            JsonObject jsonObj2 = new JsonObject();
            jsonObj2.put("attr_id", rs.getString(1));
            jsonObj2.put("display_name", new String(rs.getBytes(2), "UTF-8"));
            jsonObj2.put("type_name", rs.getString(3));
            jsonObj2.put("visit_type","invisible");
            jsonArray.put(jsonObj2);
        }

        out.println(jsonArray.toString());


    } catch(Exception ex)	{ throw ex;	}

    finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        if (pstmt != null) {
            try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
