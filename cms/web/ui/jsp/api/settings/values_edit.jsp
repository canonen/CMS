<%@ page
        language="java"
        import="com.britemoon.*,
        		com.britemoon.cps.*,
        		com.britemoon.cps.adm.*,
        		java.io.*,
        		java.sql.*,
        		java.util.*,
        		org.apache.log4j.*"
        errorPage="../../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);

    if (!can.bRead) {
        response.sendRedirect("../../access_denied.jsp");
        return;
    }

    String sAttrId = request.getParameter("attr_id");
    if (sAttrId == null) return;

    Attribute a = new Attribute(sAttrId);
    CustAttr ca = new CustAttr(cust.s_cust_id, sAttrId);
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

    jsonObject.put("attr_id", sAttrId);
    jsonObject.put("cust_id", cust.s_cust_id);
    jsonObject.put("display_name", ca.s_display_name);
    jsonObject.put("attr_name", a.s_attr_name);

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    String sSQL = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        sSQL =
                " SELECT attr_value, value_qty" +
                        " FROM ccps_attr_value" +
                        " WHERE cust_id = '" + ca.s_cust_id + "'" +
                        " AND attr_id = '" + ca.s_attr_id + "'" +
                        " ORDER BY attr_value";

        rs = stmt.executeQuery(sSQL);

        String sAttrValue = null;
        byte[] b = null;
        String sClassAppend = "";
        int i = 0;
        JsonObject jsonClassAppend;
        JsonArray arrayClassAppend = new JsonArray();
        for (i = 0; rs.next(); i++) {
            jsonClassAppend = new JsonObject();
            if (i % 2 != 0) sClassAppend = "_Alt";
            else sClassAppend = "";

            b = rs.getBytes(1);
            sAttrValue = (b != null) ? new String(b, "UTF-8") : null;
            if (i == 0)
                jsonClassAppend.put("attr_value", sAttrValue);
            else
                jsonClassAppend.put("attr_value", sAttrValue);

            jsonClassAppend.put("attr_value", sAttrValue);
            jsonClassAppend.put("b", b);
            jsonClassAppend.put("sClassAppend", sClassAppend);

            arrayClassAppend.put(jsonClassAppend);
        }

        jsonObject.put("values", arrayClassAppend);
        rs.close();

        if (i == 0) {
            jsonObject.put("attr_value", sAttrValue);
        }

        jsonArray.put(jsonObject);
        out.print(jsonArray);
    } catch (Exception ex) {
        throw ex;
    } finally {
        if(rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>
