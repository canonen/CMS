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
                java.util.Calendar,
                java.util.Date,
                java.text.NumberFormat,
                java.util.Locale,
                java.math.BigDecimal,
                java.text.SimpleDateFormat,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    String sCustId = user.s_cust_id;
    //  Campaign camp = new Campaign();
    // camp.s_cust_id = sCustId;


//    String firstDate = request.getParameter("firstDate");
//    String lastDate = request.getParameter("lastDate");

    String date_between = request.getParameter("date_between");
    String oldValueStartDate = null;
    String oldValueEndDate = null;
    String currentValueStartDate = null;
    String currentValueEndDate = null;
    long dayDifference = 0;

    if (date_between == null) {
        // date_between parametresi belirtilmediginde
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(new Date());

        // currentValue tarih araligi (bug?n - 7 g?n ?ncesi)
        currentValueEndDate = formatDate(calendar.getTime()); // Bug?n?n tarihi
        calendar.add(Calendar.DATE, -7); // 7 g?n ?ncesine git
        currentValueStartDate = formatDate(calendar.getTime()); // 7 g?n ?nceki tarih

        // oldValue tarih araligi (currentValueStartDate - 7 g?n ?ncesi)
        oldValueEndDate = formatDate(calendar.getTime()); // 7 g?n ?nceki tarih
        calendar.add(Calendar.DATE, -7); // 14 g?n ?ncesine git
        oldValueStartDate = formatDate(calendar.getTime()); // 14 g?n ?nceki tarih
        dayDifference = 6;

    } else {
        // date_between parametresi belirtildiginde
        String[] parts = date_between.split("-");
        currentValueStartDate = parts[0].trim();
        currentValueEndDate = parts[1].trim();

        // Date araliklarini hesapla
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
        Date startDate = dateFormat.parse(currentValueStartDate);
        Date endDate = dateFormat.parse(currentValueEndDate);

        // G?n farkini hesapla
        dayDifference = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);

        // oldValue tarih araligini hesapla
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(startDate);
        calendar.add(Calendar.DATE, -(int) dayDifference);
        oldValueStartDate = formatDate(calendar.getTime()); // currentValueStartDate'dan g?n farki kadar ?nceki tarih
        oldValueEndDate = currentValueStartDate; // oldValueEndDate her zaman currentValueStartDate'a esit olmali
    }


    Calendar calendar = Calendar.getInstance();


    int currentYear;
    int currentMonth;
    int currentMonthCal;
    int currentDay;

    currentYear = calendar.get(Calendar.YEAR);
    currentMonth = calendar.get(Calendar.MONTH);
    currentMonthCal = currentMonth + 1;
    currentDay = calendar.get(Calendar.DAY_OF_MONTH);

    ConnectionPool connectionPool = null;
    Connection connection = null;
    PreparedStatement pstmt = null;
    Statement statement = null;
    ResultSet resultSet = null;

    String totalSent = null;
    BigDecimal sReadPrc = null;
    BigDecimal sClickPrc = null;
    BigDecimal sbBackPrc = null;


    JsonArray totalSentArray = new JsonArray();

    JsonObject readAndClickAndBback = new JsonObject();
    JsonArray readAndClickAndBbackArray = new JsonArray();

    JsonObject currentDailyRqueCount = new JsonObject();
    JsonArray currentDailyRqueCountArray = new JsonArray();

    JsonObject oldDailyRqueCount = new JsonObject();
    JsonArray oldDailyRqueCountArray = new JsonArray();

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

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        String sSqlSend = "";

        sSqlSend = "SELECT sum(m.rque_count) ";
        sSqlSend += "FROM ccps_rque_message m WITH(NOLOCK) ";


        sSqlSend += "WHERE m.send_date >='" + currentValueStartDate + "' AND m.send_date<='" + currentValueEndDate + "' AND cust_id = " + sCustId;


        resultSet = statement.executeQuery(sSqlSend);

        while (resultSet.next()) {

            totalSent = resultSet.getString(1);

            totalSentArray.put(totalSent);
        }
        resultSet.close();


        String sSqlRate = "";
        sSqlRate = "SELECT ";
        sSqlRate += "	 distinctReadPrc = avg(";
        sSqlRate += "	CASE r.sent-r.bbacks";
        sSqlRate += "	WHEN 0 THEN 0";
        sSqlRate += "	ELSE convert(decimal(5,1),(r.dist_reads*100.0)/(r.sent-r.bbacks))";
        sSqlRate += "	   END),";
        sSqlRate += "	  distinctClickPrc =avg(";
        sSqlRate += "	   CASE r.sent-r.bbacks";
        sSqlRate += "		WHEN 0 THEN 0";
        sSqlRate += "		ELSE convert(decimal(5,1),(r.dist_clicks*100.0)/(r.sent-r.bbacks))";
        sSqlRate += "	   END),";

        sSqlRate += "	BBackPrc =avg(";
        sSqlRate += "	CASE Sent";
        sSqlRate += "		WHEN 0 THEN 0";
        sSqlRate += "		ELSE convert(decimal(5,1),(BBacks*100.0)/Sent)";
        sSqlRate += "	END)";

        sSqlRate += "	FROM ccps_rrpt_camp_summary_and_rque_campaign as r with(nolock) ";


        sSqlRate += " WHERE r.start_date >='" + currentValueStartDate + "' AND r.start_date<= '" + currentValueEndDate + "'  AND cust_id = " + sCustId;


        resultSet = statement.executeQuery(sSqlRate);

        int icount_r = 0;


        while (resultSet.next()) {
            readAndClickAndBback = new JsonObject();

            sReadPrc = resultSet.getBigDecimal(1);
            sClickPrc = resultSet.getBigDecimal(2);
            sbBackPrc = resultSet.getBigDecimal(3);

            if (sReadPrc == null) {

                sReadPrc = new BigDecimal("0.00");

            } else {
                sReadPrc = sReadPrc.setScale(2, BigDecimal.ROUND_HALF_UP);
            }

            if (sClickPrc == null) {
                sClickPrc = new BigDecimal("0.00");

            } else {
                sClickPrc = sClickPrc.setScale(2, BigDecimal.ROUND_HALF_UP);
            }

            if (sbBackPrc == null) {
                sbBackPrc = new BigDecimal("0.00");

            } else {
                sbBackPrc = sbBackPrc.setScale(2, BigDecimal.ROUND_HALF_UP);
            }

            sReadPrc = sReadPrc.setScale(2, BigDecimal.ROUND_HALF_UP);
            sClickPrc = sClickPrc.setScale(2, BigDecimal.ROUND_HALF_UP);
            sbBackPrc = sbBackPrc.setScale(2, BigDecimal.ROUND_HALF_UP);
            icount_r++;


            readAndClickAndBback.put("sReadPrc", sReadPrc);
            readAndClickAndBback.put("sClickPrc", sClickPrc);
            readAndClickAndBback.put("sbbackPrc", sbBackPrc);


            readAndClickAndBbackArray.put(readAndClickAndBback);
            // map.put("readAndClickAndBback", readAndClickAndBback);


        }
        resultSet.close();


        String sSqlDay = "";

        sSqlDay = "SELECT send_date, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE send_date >= ? AND send_date<= ? AND cust_id = " + sCustId + " GROUP BY send_date ORDER BY 1 ";
        pstmt = connection.prepareStatement(sSqlDay);
        pstmt.setString(1, currentValueStartDate);
        pstmt.setString(2, currentValueEndDate);
        resultSet = pstmt.executeQuery();
        int iCountD = 0;
        String sDayD = null;
        String sTotalD = null;
        String graphCatD = "";
        String graphVal1D = "";

        while (resultSet.next()) {

            currentDailyRqueCount = new JsonObject();

            sDayD = resultSet.getString(1);
            String [] sDayDArray = sDayD.split(" ");
            sDayD = sDayDArray[0];
            sTotalD = resultSet.getString(2);
//
//            graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
//            graph_val1_d 	+= "{\"value\":\""+sTotal_D+"\"},";
//            SendByDay.append("['"+ sDay_D +"',"+sTotal_D+"],");
            iCountD++;


            currentDailyRqueCount.put("day", sDayD);
            currentDailyRqueCount.put("currentDailyRqueCount", sTotalD);


            currentDailyRqueCountArray.put(currentDailyRqueCount);
            //mapArray.put("dailyRqueCountArray", dailyRqueCountArray);

        }
        resultSet.close();
        pstmt.setString(1, oldValueStartDate);
        pstmt.setString(2, oldValueEndDate);
        resultSet = pstmt.executeQuery();
        while (resultSet.next()) {

            oldDailyRqueCount = new JsonObject();

            sDayD = resultSet.getString(1);
            sTotalD = resultSet.getString(2);
//
//            graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
//            graph_val1_d 	+= "{\"value\":\""+sTotal_D+"\"},";
//            SendByDay.append("['"+ sDay_D +"',"+sTotal_D+"],");
            iCountD++;


            oldDailyRqueCount.put("day", sDayD);
            oldDailyRqueCount.put("oldDailyRqueCount", sTotalD);


            oldDailyRqueCountArray.put(oldDailyRqueCount);
            //mapArray.put("dailyRqueCountArray", dailyRqueCountArray);

        }
        resultSet.close();
        pstmt.close();


        String sSqlOpenday = "";


        sSqlOpenday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND click_time >='" + currentValueStartDate + "' AND click_time<='" + currentValueEndDate + "' AND cust_id = " + sCustId + " GROUP BY DAY(click_time) ORDER BY 1 ";


        //sSql_openday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND MONTH(click_time)="+currentMonthCal+" AND YEAR(click_time)="+currentYear+" GROUP BY DAY(click_time) ORDER BY 1";
        resultSet = statement.executeQuery(sSqlOpenday);


        int iCount_open = 0;
        String sTotal_open = "";
        String graph_value_open = "";

        while (resultSet.next()) {
            dailyTotalOpen = new JsonObject();

            sDayD = resultSet.getString(1);
            sTotal_open = resultSet.getString(2);


            dailyTotalOpen.put("day", sDayD);
            dailyTotalOpen.put("totalOpen", sTotal_open);

            dailyTotalOpenArray.put(dailyTotalOpen);

            //mapArray.put("dailyTotalOpenArray", dailyTotalOpenArray);


            iCount_open++;
        }
        resultSet.close();

        String sSqlClickday = "";


        sSqlClickday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND click_time >='" + currentValueStartDate + "' AND click_time<='" + currentValueEndDate + "' AND cust_id = " + sCustId + " GROUP BY DAY(click_time) ORDER BY 1 ";

        //sSql_clickday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND MONTH(click_time)="+currentMonthCal+" AND YEAR(click_time)="+currentYear+" GROUP BY DAY(click_time) ORDER BY 1";
        resultSet = statement.executeQuery(sSqlClickday);


        int iCount_click = 0;
        String sTotalClick = "";
        String graphValueClick = "";

        while (resultSet.next()) {
            dailyTotalClick = new JsonObject();
            sDayD = resultSet.getString(1);
            sTotalClick = resultSet.getString(2);


            dailyTotalClick.put("day", sDayD);
            dailyTotalClick.put("click", sTotalClick);

            dailyTotalClickArray.put(dailyTotalClick);

            iCount_click++;
        }
        resultSet.close();

        String sSql = "";


        sSql = "SELECT MONTH(send_date) MONTH, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE YEAR(send_date)=" + currentYear + " AND cust_id = " + sCustId + " GROUP BY MONTH(send_date) ORDER BY 1 ";
        resultSet = statement.executeQuery(sSql);

        int iCount = 0;
        String month = null;
        String sTotal = null;
        String graph_cat = "";
        String graph_val1 = "";

        while (resultSet.next()) {

            monthlyRqueCount = new JsonObject();

            month = resultSet.getString(1);
            sTotal = resultSet.getString(2);

            monthlyRqueCount.put("month", month);
            monthlyRqueCount.put("monthlyValue", sTotal);


            monthlyRqueCountArray.put(monthlyRqueCount);


            iCount++;
        }
        resultSet.close();

        String sSqlOpenMonth = "";

        sSqlOpenMonth = "SELECT MONTH(click_time) MONTH, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND YEAR(click_time)=" + currentYear + " AND cust_id = " + sCustId + " GROUP BY MONTH(click_time) ORDER BY 1";
        resultSet = statement.executeQuery(sSqlOpenMonth);


        int iCountOpenMonth = 0;
        String sTotalOpenMonth = "";
        String graph_value_open_month = "";

        while (resultSet.next()) {
            monthlyOpen = new JsonObject();

            month = resultSet.getString(1);
            sTotalOpenMonth = resultSet.getString(2);

            monthlyOpen.put("month", month);
            monthlyOpen.put("monthlyOpen", sTotalOpenMonth);

            monthlyOpenArray.put(monthlyOpen);


            iCountOpenMonth++;
        }
        resultSet.close();


        String sSqlClickMonth = "";

        sSqlClickMonth = "SELECT MONTH(click_time) MONTH, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND YEAR(click_time)=" + currentYear + " AND cust_id = " + sCustId + " GROUP BY MONTH(click_time) ORDER BY 1";
        resultSet = statement.executeQuery(sSqlClickMonth);


        int iCountClickMonth = 0;
        String sTotalClickMonth = "";
        String graph_value_click_month = "";

        while (resultSet.next()) {
            monthlyClickTime = new JsonObject();
            sDayD = resultSet.getString(1);
            sTotalClickMonth = resultSet.getString(2);

            monthlyClickTime.put("month", sDayD);
            monthlyClickTime.put("click", sTotalClickMonth);

            monthlyClickTimeArray.put(monthlyClickTime);

            iCountClickMonth++;
        }

        resultSet.close();


        String sSqlWeek = "";


        sSqlWeek = "SELECT sum(rque_count) as Total_Recipient, YEAR(send_date) as R_Year FROM ccps_rque_message with(nolock)  WHERE cust_id = " + sCustId + " GROUP BY YEAR(send_date)  ORDER BY YEAR(send_date) ";
        //SELECT sum(_amount) as 'Amount', DATENAME(dw, _order_date_time)  as 'days', DATEPART(dw, _order_date_time) as 'Number' FROM untt_mbs_order with(nolock) GROUP BY DATENAME(dw, _order_date_time), DATEPART(dw, _order_date_time) ORDER BY 3 asc ";
        //sSql_Week = "select sum(_amount) as Total, CONVERT(VARCHAR(7), _order_date_time, 111) as 'Date ' from untt_mbs_order with(nolock) where _amount is not null group by CONVERT(VARCHAR(7), _order_date_time, 111) order by 2 ";

        resultSet = statement.executeQuery(sSqlWeek);

        int iCount2 = 0;
        String sDateW = null;
        String sTotalW = null;
        String graphCatW = "";
        String graphVal1W = "";

        while (resultSet.next()) {
            yearsTotalRecipient = new JsonObject();

            sDateW = resultSet.getString(1);
            sTotalW = resultSet.getString(2);

            yearsTotalRecipient.put("year", sDateW);
            yearsTotalRecipient.put("totalRecipient", sTotalW);


            yearsTotalRecipientArray.put(yearsTotalRecipient);


            iCount2++;
        }

        resultSet.close();

        String sSqlOpenYear = "";

        sSqlOpenYear = "SELECT YEAR(click_time) YEAR, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1  AND cust_id = " + sCustId + " GROUP BY YEAR(click_time) ORDER BY 1";
        resultSet = statement.executeQuery(sSqlOpenYear);


        int iCountOpenYear = 0;
        String sTotalOpenYear = "";
        String graph_value_open_year = "";

        while (resultSet.next()) {

            yearOpen = new JsonObject();

            sDayD = resultSet.getString(1);
            sTotalOpenYear = resultSet.getString(2);

            yearOpen.put("year", sDayD);
            yearOpen.put("totalYearCount", sTotalOpenYear);

            yearOpenArray.put(yearOpen);

            iCountOpenYear++;
        }

        resultSet.close();

        String sSqlClickYear = "";

        sSqlClickYear = "SELECT YEAR(click_time) YEAR, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND cust_id = " + sCustId + " GROUP BY YEAR(click_time) ORDER BY 1";
        resultSet = statement.executeQuery(sSqlClickYear);


        int iCountClickYear = 0;
        String sTotalClickYear = "";
        String graphValueClickYear = "";

        while (resultSet.next()) {
            JsonObject yearClick = new JsonObject();

            sDayD = resultSet.getString(1);
            sTotalClickYear = resultSet.getString(2);


            yearClick.put("year", sDayD);
            yearClick.put("totalClickYear", sTotalClickYear);
            yearClickArray.put(yearClick);


            iCountClickYear++;
        }

        resultSet.close();


        JsonObject data = new JsonObject();

        data.put("totalSent", totalSentArray);
        data.put("readAndClickAndBbackArray", readAndClickAndBbackArray);
        data.put("currentSent", currentDailyRqueCountArray);
        data.put("oldSent", oldDailyRqueCountArray);
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
            if (resultSet != null) resultSet.close();
            if (statement != null) statement.close();
            if (connection != null) connectionPool.free(connection);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

%>
<%!
    public String formatDate(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1; // Ay degeri 0-11 araliginda oldugu için 1 ekliyoruz
        int day = calendar.get(Calendar.DAY_OF_MONTH);

        return String.format("%04d-%02d-%02d", year, month, day);
    }
%>
