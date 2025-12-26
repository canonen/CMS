<%@ page
        language="java"
        import="com.britemoon.*,
        		com.britemoon.cps.*,
        		java.sql.*,
        		java.util.*,
        		java.net.*,
        		org.w3c.dom.*,
        		org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    Statement stmt, stmt2;
    ResultSet rs, rs2;
    ConnectionPool cp = null;
    Connection conn = null;
    Connection conn2 = null;
    int nStep = 1;
    JsonObject data = new JsonObject();
    JsonObject data2 = new JsonObject();
    JsonArray array = new JsonArray();

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("super_camp_edit.jsp");
        conn2 = cp.getConnection("super_camp_edit.jsp 2");
        stmt = conn.createStatement();
        stmt2 = conn2.createStatement();
    } catch (Exception ex) {
        cp.free(conn);
        cp.free(conn2);
        out.println("<BR>Connection error ... !<BR><BR>");
        return;
    }

    String superCampID = request.getParameter("super_camp_id");
    String superCampName = null;

    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

    sSelectedCategoryId = (sSelectedCategoryId != null) ? sSelectedCategoryId : "0";
    try {
        String sSql = "SELECT super_camp_name FROM cque_super_camp " +
                "WHERE cust_id = " + cust.s_cust_id + " AND super_camp_id = " + superCampID;
        rs = stmt.executeQuery(sSql);
        if (!rs.next()) {
            throw new Exception("Invalid super campaign - Doesn't exist or you are not allowed to see it");
        }else{
            data.put("super_camp_name", new String(rs.getBytes(1), "UTF-8"));
        }

        array.put(data);

        sSql = "SELECT c.camp_id, c.camp_name, type_name " +
                "FROM cque_super_camp_camp cc, cque_campaign c, cque_camp_type t " +
                "WHERE cc.super_camp_id = " + superCampID + " " +
                "AND c.camp_id = cc.camp_id " +
                "AND c.type_id = t.type_id";
        rs = stmt.executeQuery(sSql);
        String sCurCampID, sCurCampName, sCurCampType;
        int iCount = 0;
        String sClassAppend = "_other";
        JsonArray campArray = new JsonArray();
        while (rs.next()) {
            if (iCount % 2 != 0) {
                sClassAppend = "_other";
            } else {
                sClassAppend = "";
            }
            iCount++;
            JsonObject campObj = new JsonObject();
            campObj.put("sCurCampID", rs.getString(1));
            campObj.put("sCurCampName", new String(rs.getBytes(2), "UTF-8"));
            campObj.put("sCurCampType", new String(rs.getBytes(3), "UTF-8"));
            campArray.put(campObj);

        }
        array.put(campArray);
        int nLinks = 0;

        sSql = "SELECT super_link_id, super_link_name FROM crpt_super_link WHERE super_camp_id = " + superCampID
                + " ORDER BY super_link_id";

        rs = stmt.executeQuery(sSql);

        String sLinkID, sLinkName;
        JsonArray superArray = new JsonArray();
        while (rs.next()) {
            JsonObject superObj = new JsonObject();
            sLinkID = rs.getString(1);
            sLinkName = new String(rs.getBytes(2), "UTF-8");
            superObj.put("sLinkID", sLinkID);
            superObj.put("sLinkName", sLinkName);
            superArray.put(superObj);
            nLinks++;
            array.put(superArray);
            String sCurLinkID, sCurLinkName, sCurLinkHref;

            sSql = "SELECT s.link_id, l.link_name, c.camp_name, l.href"
                    + " FROM crpt_super_link_link s, cjtk_link l, cque_campaign c"
                    + " WHERE s.link_id = l.link_id"
                    + " AND l.cont_id = c.cont_id"
                    + " AND s.super_link_id = " + sLinkID
                    + " AND s.super_camp_id = " + superCampID
                    + " ORDER BY c.camp_id, l.link_name";

            rs2 = stmt2.executeQuery(sSql);

            iCount = 0;
            JsonArray superArray2 = new JsonArray();
            while (rs2.next()) {
                if (iCount % 2 != 0) {
                    sClassAppend = "_other";
                } else {
                    sClassAppend = "";
                }

                iCount++;

                sCurLinkID = rs2.getString(1);
                data2.put("sCurLinkID", sCurLinkID);
                sCurLinkName = new String(rs2.getBytes(2), "UTF-8");
                data2.put("sCurCampName", sCurLinkName);
                sCurCampName = new String(rs2.getBytes(3), "UTF-8");
                data2.put("sCurCampName", sCurCampName);
                sCurLinkHref = rs2.getString(4);
                data2.put("sCurLinkHref", sCurLinkHref);

            }
            superArray2.put(data2);
            array.put(superArray2);
        }
    } catch (Exception ex) {
        ErrLog.put(this, ex, "super_camp_edit.jsp", out, 1);
        return;
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
        if (stmt2 != null) stmt2.close();
        if (conn2 != null) cp.free(conn2);
    }
    out.print(array.toString());
%>
