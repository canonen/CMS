<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.rcp.*,
                java.sql.*,
                java.io.*,
                java.util.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.util.Calendar,
                java.math.BigDecimal,
				java.text.DecimalFormat,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.util.Date" %>
<%@ page import="net.sourceforge.jtds.jdbc.DateTime" %>
<%@ page import="java.time.DateTimeException" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%!
    // Logger nesnesini burada tanımlayın ve başlatın
    private static final Logger logger = Logger.getLogger("email_dashboard_rev_api");
%>

<%
    String sCustId = cust.s_cust_id;
    String date1 = request.getParameter("firstDate");
    String date2 = request.getParameter("lastDate");

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    JsonObject rptEcommerceObject = new JsonObject();
    JsonArray campaignsArray = new JsonArray();
    JsonObject totalDataObject = new JsonObject();

    String sql = "WITH CampaignIds AS ( " +
            "    SELECT DISTINCT camp_id FROM untt_mbs_order_date WITH(NOLOCK) " +
            "    WHERE cust_id = ? AND amount_sum IS NOT NULL AND date BETWEEN ? AND ? " +
            "), " +
            "CampaignClicks AS ( " +
            "    SELECT camp_id, SUM(rjtk_count) AS clicks " +
            "    FROM ccps_rjtk_link_activity WITH(NOLOCK) " +
            "    WHERE cust_id = ? AND type_id = 2 AND click_time BETWEEN ? AND ? AND camp_id IN (SELECT camp_id FROM CampaignIds) " +
            "    GROUP BY camp_id " +
            ") " +
            "SELECT " +
            "    cc.camp_name, " +
            "    SUM(mbs.orders) AS purchasers, " +
            "    SUM(mbs.customers) AS purchases, " +
            "    SUM(mbs.amount_sum) AS total_sales, " +
            "    mbs.camp_id, " +
            "    rs.start_date, " +
            "    ISNULL(c.clicks, 1) AS clicks, " +
            "    cc.type_id, " +
            "    rcs.queue_daily_flag, " +
            "    cc.camp_code, " +
            "    SUM(SUM(mbs.amount_sum)) OVER() as grand_total_sales, " +
            "    SUM(SUM(mbs.orders)) OVER() as grand_total_purchases, " +
            "    SUM(SUM(mbs.customers)) OVER() as grand_total_purchasers, " +
            "    (SELECT COUNT(DISTINCT camp_id) FROM CampaignIds) as grand_total_campaigns, " +
            "    (SELECT SUM(clicks) FROM CampaignClicks) as grand_total_clicks " +
            "FROM untt_mbs_order_date AS mbs WITH(NOLOCK) " +
            "JOIN cque_campaign cc WITH(NOLOCK) ON mbs.camp_id = cc.camp_id " +
            "JOIN cque_schedule rs WITH(NOLOCK) ON mbs.camp_id = rs.camp_id " +
            "JOIN cque_camp_send_param rcs WITH(NOLOCK) ON mbs.camp_id = rcs.camp_id " +
            "LEFT JOIN CampaignClicks c ON mbs.camp_id = c.camp_id " +
            "WHERE mbs.cust_id = ? AND cc.type_id IN (2, 4) AND mbs.date BETWEEN ? AND ? AND mbs.camp_id IN (SELECT camp_id FROM CampaignIds) " +
            "GROUP BY mbs.camp_id, cc.camp_name, rs.start_date, c.clicks, cc.type_id, rcs.queue_daily_flag, cc.camp_code " +
            "ORDER BY mbs.camp_id DESC";

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        pstmt = conn.prepareStatement(sql);

        String start_date = date1 + " 00:00:00";
        String end_date = date2 + " 23:59:59";

        pstmt.setString(1, sCustId);
        pstmt.setString(2, start_date);
        pstmt.setString(3, end_date);
        pstmt.setString(4, sCustId);
        pstmt.setString(5, start_date);
        pstmt.setString(6, end_date);
        pstmt.setString(7, sCustId);
        pstmt.setString(8, start_date);
        pstmt.setString(9, end_date);

        rs = pstmt.executeQuery();

        boolean totalsCalculated = false;
        Locale turkish = new Locale("tr", "TR");
        NumberFormat turkishFormat = NumberFormat.getCurrencyInstance(turkish);

        while (rs.next()) {
            if (!totalsCalculated) {
                BigDecimal grandTotalSales = rs.getBigDecimal("grand_total_sales");
                if (grandTotalSales == null) grandTotalSales = BigDecimal.ZERO;

                int grandTotalPurchases = rs.getInt("grand_total_purchases"); // sum(orders)
                int grandTotalPurchasers = rs.getInt("grand_total_purchasers"); // sum(customers)
                int grandTotalCampaigns = rs.getInt("grand_total_campaigns");
                double grandTotalClicks = rs.getDouble("grand_total_clicks");

                double averageSales = (grandTotalPurchases > 0) ? grandTotalSales.doubleValue() / grandTotalPurchases : 0.0;
                double conversionRate = (grandTotalClicks > 0) ? (100.0 * grandTotalPurchasers) / grandTotalClicks : 0.0;

                totalDataObject.put("totalClicks", grandTotalClicks);
                totalDataObject.put("purchases", grandTotalPurchases);
                totalDataObject.put("totalPurchasers", grandTotalPurchasers);
                totalDataObject.put("campCount", grandTotalCampaigns);
                totalDataObject.put("zTotal_Sales", turkishFormat.format(grandTotalSales));
                totalDataObject.put("sAverage_Sales", averageSales);
                totalDataObject.put("sAverage_Sales_Formated", String.format(Locale.US, "%.2f", averageSales));
                totalDataObject.put("sConversion_Rate", conversionRate);
                totalDataObject.put("sConversion_Formated", String.format(Locale.US, "%.2f", conversionRate));
                totalsCalculated = true;
            }

            JsonObject campaignData = new JsonObject();
            String sCamp_Name = new String(rs.getBytes("camp_name"), "UTF-8");
            int sCamp_Purchasers = rs.getInt("purchasers");
            int sCamp_Purchases = rs.getInt("purchases");
            BigDecimal sCamp_Sales = rs.getBigDecimal("total_sales");
            int intClicks = rs.getInt("clicks");

            double nConversion = (intClicks > 0) ? (100.0 * sCamp_Purchases) / intClicks : 0.0;

            campaignData.put("sCamp_Name", sCamp_Name);
            campaignData.put("sCamp_Purchasers", sCamp_Purchasers);
            campaignData.put("sCamp_Purchases", sCamp_Purchases);
            campaignData.put("sCamp_Sales", sCamp_Sales);
            campaignData.put("zCamp_Sales", turkishFormat.format(sCamp_Sales));
            campaignData.put("sCamp_ID", rs.getString("camp_id"));
            campaignData.put("zCamp_Start_Date", rs.getString("start_date"));
            campaignData.put("sClicks", intClicks);
            campaignData.put("intPurchases", sCamp_Purchases);
            campaignData.put("intClicks", intClicks);
            campaignData.put("nConversion", nConversion);
            campaignData.put("nConversion_Formated", String.format(Locale.US, "%.2f", nConversion));

            String sType_ID = rs.getString("type_id");
            String sDaily_Flag = rs.getString("queue_daily_flag");
            String sCamp_Code = rs.getString("camp_code");

            campaignData.put("sType_ID", sType_ID);
            campaignData.put("sDaily_Flag", sDaily_Flag);
            campaignData.put("sCamp_Code", sCamp_Code == null ? "-" : sCamp_Code);

            String sDisplay_Type = "Standard";
            if ("4".equals(sType_ID)) {
                sDisplay_Type = "Automated";
            } else if ("2".equals(sType_ID) && sDaily_Flag != null) {
                sDisplay_Type = "Check Daily";
            }
            campaignData.put("sDisplay_Type", sDisplay_Type);

            campaignsArray.put(campaignData);
        }

        // Orijinal yapıdaki gibi total ve campaigns nesnelerini ana objeye ekle
        rptEcommerceObject.put("total", new JsonArray().put(totalDataObject));
        rptEcommerceObject.put("campaigns", campaignsArray);

    } catch (Exception e) {
        logger.error("rpt_ecommerce error for cust:" + sCustId, e);
        if (!response.isCommitted()) {
            response.setStatus(500);
            JsonObject errorJson = new JsonObject();
            errorJson.put("error", "An internal error occurred.");
            errorJson.put("message", e.getMessage());
            out.print(errorJson);
        }
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db resources", e);
        }
    }

    if (!response.isCommitted()) {
        if (rptEcommerceObject.length() == 0 || !rptEcommerceObject.has("campaigns") || rptEcommerceObject.getJsonArray("campaigns").length() == 0) {
            response.setStatus(204); // No Content
        } else {
            response.setContentType("application/json; charset=UTF-8");
            out.print(rptEcommerceObject);
        }
    }

%>

<%!
    public String formatCurrency(double value) {
        DecimalFormat df = new DecimalFormat("###,###,###.##");

        return df.format(value);
    }
%>