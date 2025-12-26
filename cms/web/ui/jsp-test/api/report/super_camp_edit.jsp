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
<%@ include file="../../utilities/validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
 boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    Statement stmt;
    ResultSet rs;
    ConnectionPool cp = null;
    Connection conn = null;
    int nStep = 1;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("super_camp_edit.jsp");
        stmt = conn.createStatement();
    } catch (Exception ex) {
        cp.free(conn);
        out.println("<BR>Connection error ... !<BR><BR>");
        return;
    }

    String superCampID = request.getParameter("super_camp_id");
    String superCampName = "New Super Campaign";
    String curCampIDsParam = "", curCampIDsName = "";
    String jsInit = "";

    JsonObject superCampObject = new JsonObject();
    JsonObject superCampNameJson = new JsonObject();
    JsonArray  superCampArray = new JsonArray();
    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

    try {

        if (superCampID != null) {
            String sSql = "SELECT super_camp_name FROM cque_super_camp " +
                    "WHERE cust_id = " + cust.s_cust_id + " AND super_camp_id = " + superCampID;
            rs = stmt.executeQuery(sSql);
            if (!rs.next())
                throw new Exception("Invalid super campaign - Doesn't exist or you are not allowed to see it");
            superCampName = new String(rs.getBytes(1), "UTF-8");
            superCampNameJson.put("superCampName",superCampName);

            //Grab all of this super campaign's campaigns.
            sSql = "SELECT c.camp_id, c.camp_name + ' (' + type_name + ')' " +
                    "FROM cque_super_camp_camp cc, cque_campaign c, cque_camp_type t " +
                    "WHERE cc.super_camp_id = " + superCampID + " " +
                    "AND c.camp_id = cc.camp_id " +
                    "AND c.type_id = t.type_id";
            rs = stmt.executeQuery(sSql);
            String rs1, rs2;
            while (rs.next()) {
                superCampObject = new JsonObject();

                rs1 = rs.getString(1);
                rs2 = new String(rs.getBytes(2), "UTF-8");

                superCampObject.put("campId",rs1);
                superCampObject.put("campName",rs2);

                superCampArray.put(superCampObject);


            }
        }


        String attrParm = "var attrParm = new Array ('null','', '0'";
        String attrName = "var attrName = new Array ();";
        String rs1, rs2;

        String extraConstraint = " AND c.camp_id NOT IN" +
                " (SELECT camp_id FROM cque_super_camp_camp WHERE super_camp_id = " + superCampID + ")";
        String sSql = null;
        if ((sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0"))) {
            sSql = "SELECT c.camp_id, c.camp_name + ' (' + t.type_name + ')'" +
                    " FROM cque_campaign c, cque_camp_type t" +
                    " WHERE c.cust_id = " + cust.s_cust_id +
                    " AND c.origin_camp_id IS NULL" +
                    (superCampID != null ? extraConstraint : "") +
                    " AND c.type_id = t.type_id" +
                    " ORDER BY c.type_id, c.camp_name";
        } else {
            sSql = "SELECT c.camp_id, c.camp_name + ' (' + t.type_name + ')'" +
                    " FROM cque_campaign c, cque_camp_type t, ccps_object_category oc" +
                    " WHERE c.cust_id = " + cust.s_cust_id +
                    " AND c.origin_camp_id IS NULL" +
                    (superCampID != null ? extraConstraint : "") +
                    " AND c.type_id = t.type_id" +
                    " AND c.camp_id = oc.object_id" +
                    " AND oc.type_id = " + ObjectType.CAMPAIGN +
                    " AND oc.cust_id = " + cust.s_cust_id +
                    " AND oc.category_id = " + sSelectedCategoryId +
                    " ORDER BY c.type_id, c.camp_name";
        }
        rs = stmt.executeQuery(sSql);

        while (rs.next()) {
            superCampObject = new JsonObject();
            rs1 = rs.getString(1);
            rs2 = new String(rs.getBytes(2), "UTF-8");

            superCampObject.put("campId",rs1);
            superCampObject.put("campName",rs2);

            superCampArray.put(superCampObject);


        }
        rs.close();

     out.print(superCampArray);

    } catch (Exception ex) {
        ErrLog.put(this, ex, "super_camp_edit.jsp", out, 1);
        return;
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
%>
