<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.adm.*,
                java.io.*,
                java.sql.*,
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

    boolean HYATTADMIN = (ui.n_ui_type_id == UIType.HYATT_ADMIN);

    if (!can.bWrite && !HYATTADMIN) {
        response.sendRedirect("../../access_denied.jsp");
        return;
    }

    String sAttrId = BriteRequest.getParameter(request, "attr_id");
    String sCustId = BriteRequest.getParameter(request, "cust_id");
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    AttrCalcProps acp = new AttrCalcProps(sCustId, sAttrId);
    if ("2".equals(acp.s_calc_values_flag)) {
        acp.s_distinct_values_qty = BriteRequest.getParameter(request, "num_values");
        acp.save();
    }

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
                " DELETE" +
                        " FROM ccps_attr_value" +
                        " WHERE cust_id = '" + sCustId + "'" +
                        " AND attr_id = '" + sAttrId + "'";

        stmt.executeUpdate(sSQL);

        int numVals = Integer.parseInt(request.getParameter("num_values"));
        String attr_val = "";

        int count = 0;
        for (int i = 1; i <= numVals; i++) {
            attr_val = BriteRequest.getParameter(request, "attr_value" + i);
            if (attr_val != null) {
                count++;
                sSQL =
                        " INSERT INTO ccps_attr_value" +
                                " (cust_id, attr_id, attr_value, value_qty)" +
                                " VALUES ('" + sCustId + "', '" + sAttrId + "', '" + attr_val + "', '1')";
                stmt.executeUpdate(sSQL);
            }
        }

        jsonObject.put("message", "The custom field values were saved.Back to List");
        jsonArray.put(jsonObject);
        out.print(jsonArray);
    } catch (Exception ex) {
        throw ex;
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>
