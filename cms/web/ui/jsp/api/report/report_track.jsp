<%--
  Created by IntelliJ IDEA.
  User: Emre CERRAH
  Date: 25.07.2025
  Time: 16:09
  To change this template use File | Settings | File Templates.
--%>
<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.rpt.*,
                java.sql.*,
                java.net.*,
                java.io.*,
                java.util.*,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ include file="functions.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%!
    static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    int numRecs = 0;
    int nPos = 0;
    String reportName = "";
    String reportDate = "";

    String tReceived = "";
    String tRead = "";
    String tClicks = "";
    int clickPerct = 0;

    String sLinkID = "";
    String sCurCampID = "";
    String sHref = "";
    String sDistClicks = "";
    String sDistClickPct = "";
    String sTotClicks = "";
    String sTotClickPct = "";

    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    String sCampID = request.getParameter("Q").trim();
    String sCache = request.getParameter("Z");
    sCache = ("1".equals(sCache)) ? sCache : "0";

    if (sCampID == null|| sCampID.isEmpty()) {
        response.sendError(400, "Q parameter is required");
        return;
    }

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sql =
                " SELECT count(camp_id)" +
                        " FROM cque_campaign c with(nolock)" +
                        " WHERE c.cust_id = " + cust.s_cust_id +
                        " AND c.camp_id = " + sCampID;

        rs = stmt.executeQuery(sql);
        if (rs.next()) numRecs = rs.getInt(1);
        jsonObject.put("numRecs", numRecs);
        rs.close();

        sql =
                " SELECT count(*)" +
                        " FROM crpt_camp_pos with(nolock)" +
                        " WHERE camp_id IN (" + sCampID + ")";

        rs = stmt.executeQuery(sql);
        if (rs.next()) nPos = rs.getInt(1);
        jsonObject.put("nPos", nPos);
        rs.close();

        sql =
                " EXEC usp_crpt_camp_list" +
                        "  @camp_id=" + sCampID +
                        ", @cust_id=" + cust.s_cust_id +
                        ", @cache=0";

        rs = stmt.executeQuery(sql);

        while (rs.next()) {
            byte[] bVal = rs.getBytes("CampName");
            reportName = (bVal != null ? new String(bVal, "UTF-8") : "");
            reportDate = rs.getString("StartDate");
        }
        jsonObject.put("reportName", reportName);
        jsonObject.put("StartDate", reportDate);
        rs.close();

        sql = "select reaching,dist_reads,dist_clicks from crpt_camp_summary with(nolock) where camp_id = " + sCampID;
        rs = stmt.executeQuery(sql);
        while (rs.next()) {
            tReceived = rs.getString("reaching");
            tClicks = rs.getString("dist_clicks");
            clickPerct = ((Integer.parseInt(tClicks) * 100) / Integer.parseInt(tReceived));

            jsonObject.put("tRead", rs.getString("dist_reads"));
            jsonObject.put("tReceived", tReceived);
            jsonObject.put("tClicks",  tClicks);
            jsonObject.put("clickPerct", clickPerct + 0.1);
        }
        rs.close();

        sql =
                " EXEC usp_crpt_camp_pos_list" +
                        " @camp_id = " + sCampID +
                        ",@cache = " + sCache;
        rs = stmt.executeQuery(sql);

        while (rs.next()) {
            jsonObject.put("sLinkID", rs.getString(1));
            jsonObject.put("sCurCampID", rs.getString(2));
            jsonObject.put("sHref", rs.getString(3));
            jsonObject.put("sDistClicks", rs.getString(4));
            jsonObject.put("sDistClickPct",  rs.getString(5));
            jsonObject.put("sTotClicks", rs.getString(6));
            jsonObject.put("sTotClickPct", rs.getString(7));
        }

        sql = "SELECT " +
                "    rr.camp_id, " +
                "    rr.purchasers, " +
                "    rr.delivered, " +
                "    rr.purchases, " +
                "    rr.total AS revenue_total, " +
                "    SUM(od.customers) AS total_customers, " +
                "    SUM(od.orders)             AS total_orders, " +
                "    SUM(od.amount_sum)         AS total_amount " +
                " FROM crpt_mbs_revenue_report AS rr " +
                " LEFT JOIN untt_mbs_order_date AS od ON rr.camp_id = od.camp_id " +
                " WHERE rr.camp_id = "+ sCampID +
                "GROUP BY " +
                "    rr.camp_id, rr.purchasers, rr.delivered, rr.purchases, rr.total ";
        rs = stmt.executeQuery(sql);
        while (rs.next()) {

            jsonObject.put("customers", rs.getString("total_customers"));
            jsonObject.put("s_delivered",  rs.getString("delivered"));
            jsonObject.put("revenue", rs.getString("revenue_total"));
            jsonObject.put("orders",rs.getString("total_orders"));
        }
        rs.close();
       jsonArray.put(jsonObject);
       out.print(jsonArray);
        // out.print(jsonObject);

    } catch (Exception ex) {
        throw ex;
    } finally {

        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);

    }
%>
