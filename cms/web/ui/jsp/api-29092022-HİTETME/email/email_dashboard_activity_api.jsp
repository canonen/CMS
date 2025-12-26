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
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>


<%@ include file="../validator_api.jsp" %>
<%
    String sCustId = "420";
    //  Campaign camp = new Campaign();
    // camp.s_cust_id = sCustId;


    String firstDate = request.getParameter("firstDate");
    String lastDate = request.getParameter("lastDate");


    Calendar calendar = Calendar.getInstance();


    int current_year;
    int current_month;
    int current_month_cal;
    int current_day;

    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
    current_day = calendar.get(Calendar.DAY_OF_MONTH);

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String totalSent = null;
    BigDecimal sread_prc = null;
    BigDecimal sclick_prc = null;
    BigDecimal sbback_prc = null;


    JsonArray totalSentArray = new JsonArray();

    JsonObject readAndClickAndBback = new JsonObject();
    JsonArray readAndClickAndBbackArray = new JsonArray();

    JsonObject dailyRqueCount = new JsonObject();
    JsonArray dailyRqueCountArray = new JsonArray();

    JsonObject dailyTotalOpen;
    JsonArray dailyTotalOpenArray = new JsonArray();

    JsonObject dailyTotalClick;
    JsonArray dailyTotalClickArray = new JsonArray();

    JsonObject monthlyRqueCount;
    JsonArray monthlyRqueCountArray = new JsonArray();

    JsonObject monthlyOpen;
    JsonArray monthlyOpenArray = new JsonArray();


    JsonObject monthlyClickTime;
    JsonArray monthlyClickTimeArray = new JsonArray();

    JsonObject yearsTotalRecipient;
    JsonArray yearsTotalRecipientArray = new JsonArray();

    JsonObject yearOpen;
    JsonArray yearOpenArray = new JsonArray();

    JsonArray yearClickArray = new JsonArray();

    //HashMap<String, JsonObject> map = new HashMap<String, JsonObject>();

    //HashMap<String, JsonArray> mapArray = new HashMap<String, JsonArray>();


    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_Send = "";

        sSql_Send = "SELECT sum(m.rque_count) ";
        sSql_Send += "FROM ccps_rque_message m WITH(NOLOCK) ";


        sSql_Send += "WHERE m.send_date >='" + firstDate + "' AND m.send_date<='" + lastDate + "' AND cust_id = " + sCustId;


        rs = stmt.executeQuery(sSql_Send);

        while (rs.next()) {

            totalSent = rs.getString(1);

            totalSentArray.put(totalSent);
        }
        rs.close();


        String sSql_Rate = "";
        sSql_Rate = "SELECT ";
        sSql_Rate += "	 distinctReadPrc = avg(";
        sSql_Rate += "	CASE r.sent-r.bbacks";
        sSql_Rate += "	WHEN 0 THEN 0";
        sSql_Rate += "	ELSE convert(decimal(5,1),(r.dist_reads*100.0)/(r.sent-r.bbacks))";
        sSql_Rate += "	   END),";
        sSql_Rate += "	  distinctClickPrc =avg(";
        sSql_Rate += "	   CASE r.sent-r.bbacks";
        sSql_Rate += "		WHEN 0 THEN 0";
        sSql_Rate += "		ELSE convert(decimal(5,1),(r.dist_clicks*100.0)/(r.sent-r.bbacks))";
        sSql_Rate += "	   END),";

        sSql_Rate += "	BBackPrc =avg(";
        sSql_Rate += "	CASE Sent";
        sSql_Rate += "		WHEN 0 THEN 0";
        sSql_Rate += "		ELSE convert(decimal(5,1),(BBacks*100.0)/Sent)";
        sSql_Rate += "	END)";

        sSql_Rate += "	FROM ccps_rrpt_camp_summary_and_rque_campaign as r with(nolock) ";


        sSql_Rate += " WHERE r.start_date >='" + firstDate + "' AND r.start_date<= '" + lastDate + "'  AND cust_id = " + sCustId;


        rs = stmt.executeQuery(sSql_Rate);

        int icount_r = 0;


        while (rs.next()) {
            readAndClickAndBback = new JsonObject();

            sread_prc = rs.getBigDecimal(1);
            sclick_prc = rs.getBigDecimal(2);
            sbback_prc = rs.getBigDecimal(3);

            if (sread_prc == null) {

                sread_prc = new BigDecimal("0.00");

            } else {
                sread_prc = sread_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
            }

            if (sclick_prc == null) {
                sclick_prc = new BigDecimal("0.00");

            } else {
                sclick_prc = sclick_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
            }

            if (sbback_prc == null) {
                sbback_prc = new BigDecimal("0.00");

            } else {
                sbback_prc = sbback_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
            }

            sread_prc = sread_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
            sclick_prc = sclick_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
            sbback_prc = sbback_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
            icount_r++;


            readAndClickAndBback.put("sreadPrc", sread_prc);
            readAndClickAndBback.put("sclickPrc", sclick_prc);
            readAndClickAndBback.put("sbbackPrc", sbback_prc);


            readAndClickAndBbackArray.put(readAndClickAndBback);
            // map.put("readAndClickAndBback", readAndClickAndBback);


        }
        rs.close();


        String sSql_day = "";

        sSql_day = "SELECT DAY(send_date) DAY, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE send_date >='" + firstDate + "' AND send_date<='" + lastDate + "' AND cust_id = " + sCustId + " GROUP BY DAY(send_date) ORDER BY 1 ";
        rs = stmt.executeQuery(sSql_day);
        int iCount_D = 0;
        String sDay_D = null;
        String sTotal_D = null;
        String graph_cat_d = "";
        String graph_val1_d = "";

        while (rs.next()) {

            dailyRqueCount = new JsonObject();

            sDay_D = rs.getString(1);
            sTotal_D = rs.getString(2);
//
//            graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
//            graph_val1_d 	+= "{\"value\":\""+sTotal_D+"\"},";
//            SendByDay.append("['"+ sDay_D +"',"+sTotal_D+"],");
            iCount_D++;


            dailyRqueCount.put("day", sDay_D);
            dailyRqueCount.put("dailyRqueCount", sTotal_D);


            dailyRqueCountArray.put(dailyRqueCount);
            //mapArray.put("dailyRqueCountArray", dailyRqueCountArray);

        }
        rs.close();

        String sSql_openday = "";




         sSql_openday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND click_time >='" + firstDate + "' AND click_time<='" + lastDate + "' AND cust_id = " + sCustId + " GROUP BY DAY(click_time) ORDER BY 1 ";


        //sSql_openday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND MONTH(click_time)="+current_month_cal+" AND YEAR(click_time)="+current_year+" GROUP BY DAY(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_openday);


        int iCount_open = 0;
        String sTotal_open = "";
        String graph_value_open = "";

        while (rs.next()) {
            dailyTotalOpen = new JsonObject();

            sDay_D = rs.getString(1);
            sTotal_open = rs.getString(2);


            dailyTotalOpen.put("day", sDay_D);
            dailyTotalOpen.put("totalOpen", sTotal_open);

            dailyTotalOpenArray.put(dailyTotalOpen);

            //mapArray.put("dailyTotalOpenArray", dailyTotalOpenArray);


            iCount_open++;
        }
        rs.close();

        String sSql_clickday = "";



        sSql_clickday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND click_time >='" + firstDate + "' AND click_time<='" + lastDate + "' AND cust_id = " + sCustId + " GROUP BY DAY(click_time) ORDER BY 1 ";

        //sSql_clickday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND MONTH(click_time)="+current_month_cal+" AND YEAR(click_time)="+current_year+" GROUP BY DAY(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_clickday);


        int iCount_click = 0;
        String sTotal_click = "";
        String graph_value_click = "";

        while (rs.next()) {
            dailyTotalClick = new JsonObject();
            sDay_D = rs.getString(1);
            sTotal_click = rs.getString(2);


            dailyTotalClick.put("day", sDay_D);
            dailyTotalClick.put("click", sTotal_click);

            dailyTotalClickArray.put(dailyTotalClick);

            iCount_click++;
        }
        rs.close();

        String sSql = "";


        sSql = "SELECT MONTH(send_date) MONTH, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE YEAR(send_date)=" + current_year + " AND cust_id = " + sCustId + " GROUP BY MONTH(send_date) ORDER BY 1 ";
        rs = stmt.executeQuery(sSql);

        int iCount = 0;
        String month = null;
        String sTotal = null;
        String graph_cat = "";
        String graph_val1 = "";

        while (rs.next()) {

            monthlyRqueCount = new JsonObject();

            month = rs.getString(1);
            sTotal = rs.getString(2);

            monthlyRqueCount.put("month", month);
            monthlyRqueCount.put("monthlyValue", sTotal);


            monthlyRqueCountArray.put(monthlyRqueCount);


            iCount++;
        }
        rs.close();

        String sSql_open_month = "";

        sSql_open_month = "SELECT MONTH(click_time) MONTH, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND YEAR(click_time)=" + current_year + " AND cust_id = " + sCustId + " GROUP BY MONTH(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_open_month);


        int iCount_open_month = 0;
        String sTotal_open_month = "";
        String graph_value_open_month = "";

        while (rs.next()) {
            monthlyOpen = new JsonObject();

            month = rs.getString(1);
            sTotal_open_month = rs.getString(2);

            monthlyOpen.put("month", month);
            monthlyOpen.put("monthlyOpen", sTotal_open_month);

            monthlyOpenArray.put(monthlyOpen);


            iCount_open_month++;
        }
        rs.close();


        String sSql_click_month = "";

        sSql_click_month = "SELECT MONTH(click_time) MONTH, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND YEAR(click_time)=" + current_year + " AND cust_id = " + sCustId + " GROUP BY MONTH(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_click_month);


        int iCount_click_month = 0;
        String sTotal_click_month = "";
        String graph_value_click_month = "";

        while (rs.next()) {
            monthlyClickTime = new JsonObject();
            sDay_D = rs.getString(1);
            sTotal_click_month = rs.getString(2);

            monthlyClickTime.put("month", sDay_D);
            monthlyClickTime.put("click", sTotal_click_month);

            monthlyClickTimeArray.put(monthlyClickTime);

            iCount_click_month++;
        }

        rs.close();


        String sSql_Week = "";


        sSql_Week = "SELECT sum(rque_count) as Total_Recipient, YEAR(send_date) as R_Year FROM ccps_rque_message with(nolock)  WHERE cust_id = " + sCustId + " GROUP BY YEAR(send_date)  ORDER BY YEAR(send_date) ";
        //SELECT sum(_amount) as 'Amount', DATENAME(dw, _order_date_time)  as 'days', DATEPART(dw, _order_date_time) as 'Number' FROM untt_mbs_order with(nolock) GROUP BY DATENAME(dw, _order_date_time), DATEPART(dw, _order_date_time) ORDER BY 3 asc ";
        //sSql_Week = "select sum(_amount) as Total, CONVERT(VARCHAR(7), _order_date_time, 111) as 'Date ' from untt_mbs_order with(nolock) where _amount is not null group by CONVERT(VARCHAR(7), _order_date_time, 111) order by 2 ";

        rs = stmt.executeQuery(sSql_Week);

        int iCount2 = 0;
        String sDate_w = null;
        String sTotal_w = null;
        String graph_cat_w = "";
        String graph_val1_w = "";

        while (rs.next()) {
            yearsTotalRecipient = new JsonObject();

            sDate_w = rs.getString(1);
            sTotal_w = rs.getString(2);

            yearsTotalRecipient.put("year", sDate_w);
            yearsTotalRecipient.put("totalRecipient", sTotal_w);


            yearsTotalRecipientArray.put(yearsTotalRecipient);


            iCount2++;
        }

        rs.close();

        String sSql_open_year = "";

        sSql_open_year = "SELECT YEAR(click_time) YEAR, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1  AND cust_id = " + sCustId + " GROUP BY YEAR(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_open_year);


        int iCount_open_year = 0;
        String sTotal_open_year = "";
        String graph_value_open_year = "";

        while (rs.next()) {

            yearOpen = new JsonObject();

            sDay_D = rs.getString(1);
            sTotal_open_year = rs.getString(2);

            yearOpen.put("year", sDay_D);
            yearOpen.put("totalYearCount", sTotal_open_year);

            yearOpenArray.put(yearOpen);

            iCount_open_year++;
        }

        rs.close();

        String sSql_click_year = "";

        sSql_click_year = "SELECT YEAR(click_time) YEAR, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND cust_id = " + sCustId + " GROUP BY YEAR(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_click_year);


        int iCount_click_year = 0;
        String sTotal_click_year = "";
        String graph_value_click_year = "";

        while (rs.next()) {
            JsonObject yearClick = new JsonObject();

            sDay_D = rs.getString(1);
            sTotal_click_year = rs.getString(2);


            yearClick.put("year", sDay_D);
            yearClick.put("totalClickYear", sTotal_click_year);
            yearClickArray.put(yearClick);


            iCount_click_year++;
        }

        rs.close();


        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");


        JsonObject data = new JsonObject();

        data.put("totalSent", totalSentArray);
        data.put("readAndClickAndBbackArray", readAndClickAndBbackArray);
        data.put("sent", dailyRqueCountArray);
        data.put("open", dailyTotalOpenArray);
        data.put("click", dailyTotalClickArray);
        data.put("monthlyRqueCountArray", monthlyRqueCountArray);
        data.put("monthlyOpenArray", monthlyOpenArray);
        data.put("monthlyClickTimeArray", monthlyClickTimeArray);
        data.put("yearsTotalRecipientArray", yearsTotalRecipientArray);
        data.put("yearOpenArray", yearOpenArray);
        data.put("yearClickArray", yearClickArray);
        //out.print(mapArray);
        out.print(data);


    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

%>

