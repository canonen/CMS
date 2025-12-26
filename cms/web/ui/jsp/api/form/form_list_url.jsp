<%@ page
        language="java"
        import="com.britemoon.*,
            com.britemoon.cps.*,
            java.util.*,java.sql.*,
            java.net.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>

<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;

    JsonObject responseJson = new JsonObject();
    JsonArray formArray = new JsonArray();
    JsonArray campaignArray = new JsonArray();
    JsonArray responseJsonArray = new JsonArray();

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String CUSTOMER_ID = cust.s_cust_id;
        String unSub_msg = request.getParameter("unsubmsgID");
        boolean showFrmUnSub = (unSub_msg != null);

        String sSql = "SELECT form_url + CASE WHEN (type_id = 3 OR type_id = 4) THEN '&I=' ELSE '&C=' END, form_name " +
                "FROM csbs_form WHERE cust_id = " + CUSTOMER_ID + " ORDER BY form_id DESC";

        if (showFrmUnSub) {
            sSql = "SELECT form_url, form_name " +
                    "FROM csbs_form WHERE cust_id = " + CUSTOMER_ID +
                    " AND type_id IN (1, 2) ORDER BY form_id DESC";
        }

        rs = stmt.executeQuery(sSql);
        while (rs.next()) {
            JsonObject formObject = new JsonObject();
            formObject.put("form_url", rs.getString(1));
            formObject.put("form_name", new String(rs.getBytes(2), "UTF-8"));
            formArray.put(formObject);
        }
        rs.close();

        if (!showFrmUnSub) {
            sSql = "SELECT c.camp_id + 1, c.camp_name " +
                    "FROM cque_campaign c, cque_camp_edit_info cei " +
                    "WHERE c.origin_camp_id IS NULL AND cei.camp_id = c.camp_id AND c.cust_id = " + CUSTOMER_ID +
                    " ORDER BY cei.modify_date DESC";

            rs = stmt.executeQuery(sSql);
            while (rs.next()) {
                JsonObject campaignObject = new JsonObject();
                campaignObject.put("camp_id", rs.getString(1));
                campaignObject.put("camp_name", new String(rs.getBytes(2), "UTF-8"));
                campaignArray.put(campaignObject);
            }
            rs.close();
        }

        responseJson.put("forms", formArray);
        responseJson.put("campaigns", campaignArray);

        responseJsonArray.put(responseJson);

        out.print(responseJsonArray.toString());

    } catch (Exception ex) {
        responseJson.put("error", ex.getMessage());
        out.print(responseJson.toString());
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>