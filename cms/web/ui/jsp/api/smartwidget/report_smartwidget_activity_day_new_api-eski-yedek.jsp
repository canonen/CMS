<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Calendar,
                java.util.Date,
                java.io.*,
                java.math.BigDecimal,
		java.text.DecimalFormat,
                java.text.NumberFormat,
                java.text.DateFormat,
                java.util.Locale,
                java.util.*,
                java.io.*,
                org.apache.log4j.Logger,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    String sCustId = cust.s_cust_id;
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

        // currentValue tarih araligi (bugun - 7 gun oncesi)
        currentValueEndDate = formatDate(calendar.getTime()); // Bugunun tarihi
        calendar.add(Calendar.DATE, -7); // 7 gun oncesine git
        currentValueStartDate = formatDate(calendar.getTime()); // 7 gun onceki tarih

        // oldValue tarih araligi (currentValueStartDate - 7 gun oncesi)
        oldValueEndDate = formatDate(calendar.getTime()); // 7 gun onceki tarih
        calendar.add(Calendar.DATE, -7); // 14 gun oncesine git
        oldValueStartDate = formatDate(calendar.getTime()); // 14 gun onceki tarih
        dayDifference = 6;
        System.out.println("currentValueStartDate 22"+currentValueStartDate);
        System.out.println("currentValueEndDate 22"+currentValueEndDate);
        System.out.println("dayDifference 22"+dayDifference);
        System.out.println("oldValueStartDate 22"+oldValueStartDate);
        System.out.println("oldValueEndDate 22"+oldValueEndDate);

    } else {
        // date_between parametresi belirtildiginde
        String[] parts = date_between.split("-");
        currentValueStartDate = parts[0].trim();
        currentValueEndDate = parts[1].trim();

        // Date araliklarini hesapla
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
        Date startDate = dateFormat.parse(currentValueStartDate);
        Date endDate = dateFormat.parse(currentValueEndDate);
        System.out.println("");
        // Gun farkini hesapla
        dayDifference = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);

        // oldValue tarih araligini hesapla
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(startDate);
        calendar.add(Calendar.DATE, -(int) dayDifference);
        oldValueStartDate = formatDate(calendar.getTime()); // currentValueStartDate'dan gun farki kadar onceki tarih
        oldValueEndDate = currentValueStartDate; // oldValueEndDate her zaman currentValueStartDate'a esit olmali
        System.out.println("currentValueStartDate 11"+currentValueStartDate);
        System.out.println("currentValueEndDate 11"+currentValueEndDate);
        System.out.println("startDate 11"+startDate);
        System.out.println("endDate 11"+endDate);
        System.out.println("dayDifference 11"+dayDifference);
        System.out.println("oldValueStartDate 11"+oldValueStartDate);
        System.out.println("oldValueEndDate 11"+oldValueEndDate);

    }

    Statement stmt = null;
    ResultSet rs = null;
    ResultSet resultSet = null;
    ConnectionPool cp = null;
    Connection conn = null;

    JsonObject data = new JsonObject();
    JsonArray arrayData = new JsonArray();
    JsonArray smartWidgetActivityDay = new JsonArray();

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();
        String sql_clearTempTable = "IF (OBJECT_ID('TempDB..#t') IS NOT NULL) DROP TABLE #t;";
        stmt.executeUpdate(sql_clearTempTable);

        String sSql_day = "";

        sSql_day = "IF (OBJECT_ID('TempDB..#t') IS NOT NULL)  DROP TABLE #t;\n" +
                "SELECT\n" +
                "    CONVERT(VARCHAR(10), activity_date, 120) AS activity_date,\n" +
                "    COUNT(activity_date) AS counts,\n" +
                "    type_name,\n" +
                "    SUM(activity) AS activity,\n" +
                "    SUM(impression) AS impression,\n" +
                "    SUM(revenue) AS revenue\n" +
                "INTO #t\n" +
                "FROM ccps_smart_widget_activity_day with (nolock)\n" +
                "WHERE cust_id = " + sCustId + " AND (activity_date BETWEEN '" + currentValueStartDate + "  00:00:00' AND '" + currentValueEndDate + " 23:59:59') \n" +
                "GROUP BY CONVERT(VARCHAR(10), activity_date, 120), type_name\n" +
                "ORDER BY activity_date, type_name;\n" +
                "\n" +
                "INSERT INTO #t (activity_date, counts, type_name)\n" +
                "SELECT\n" +
                "    #t.activity_date,\n" +
                "    0,\n" +
                "    '1'\n" +
                "FROM #t\n" +
                "WHERE\n" +
                "    type_name = '1'\n" +
                "    AND NOT EXISTS (\n" +
                "        SELECT 1 FROM #t t2 WHERE t2.type_name = '2' AND t2.activity_date = #t.activity_date\n" +
                "    );\n" +
                "\n" +
                "INSERT INTO #t (activity_date, counts, type_name)\n" +
                "SELECT\n" +
                "    #t.activity_date,\n" +
                "    0,\n" +
                "    '1'\n" +
                "FROM #t\n" +
                "WHERE\n" +
                "    type_name = '2'\n" +
                "    AND NOT EXISTS (\n" +
                "        SELECT 1 FROM #t t2 WHERE t2.type_name = '1' AND t2.activity_date = #t.activity_date\n" +
                "    );\n" +
                "\n" +
                "SELECT\n" +
                "    activity_date,\n" +
                "    SUM(activity) AS activity,\n" +
                "    SUM(impression) AS impression,\n" +
                "    SUM(revenue) AS revenue,\n" +
                "    type_name\n" +
                "FROM #t\n" +
                "GROUP BY activity_date, type_name\n" +
                "ORDER BY activity_date, type_name;\n";

        rs = stmt.executeQuery(sSql_day);
        JsonObject currentWeek = new JsonObject();
        arrayData = new JsonArray();
        while (rs.next()) {
            data = new JsonObject();
            String activity_date = rs.getString(1);
            String activity = rs.getString(2);
            String impression = rs.getString(3);
            String revenue = rs.getString(4);
            String type_name = rs.getString(5);
            data.put("date", activity_date);
            data.put("impression", impression);
            data.put("revenue", revenue);
            data.put("type_name", type_name);
            data.put("activity", activity);
            arrayData.put(data);
        }
        currentWeek.put("currentData", arrayData);
        smartWidgetActivityDay.put(currentWeek);
        rs.close();

        stmt.executeUpdate(sql_clearTempTable);


        String sSql_week = "IF (OBJECT_ID('TempDB..#t') IS NOT NULL)\n" +
                "    DROP TABLE #t;\n" +
                "\n" +
                "SELECT\n" +
                "    CONVERT(VARCHAR(10), activity_date, 120) AS activity_date,\n" +
                "    COUNT(activity_date) AS counts,\n" +
                "    type_name,\n" +
                "    SUM(activity) AS activity,\n" +
                "    SUM(impression) AS impression,\n" +
                "    SUM(revenue) AS revenue\n" +
                "INTO #t\n" +
                "FROM ccps_smart_widget_activity_day with (nolock)\n" +
                "WHERE cust_id = " + sCustId + " AND (activity_date BETWEEN '" + oldValueStartDate + "   00:00:00' AND '" + oldValueEndDate + "  23:59:59') \n" +
                "GROUP BY CONVERT(VARCHAR(10), activity_date, 120), type_name\n" +
                "ORDER BY activity_date, type_name;\n" +
                "\n" +
                "INSERT INTO #t (activity_date, counts, type_name)\n" +
                "SELECT\n" +
                "    #t.activity_date,\n" +
                "    0,\n" +
                "    '1'\n" +
                "FROM #t\n" +
                "WHERE\n" +
                "    type_name = '1'\n" +
                "    AND NOT EXISTS (\n" +
                "        SELECT 1 FROM #t t2 WHERE t2.type_name = '2' AND t2.activity_date = #t.activity_date\n" +
                "    );\n" +
                "\n" +
                "INSERT INTO #t (activity_date, counts, type_name)\n" +
                "SELECT\n" +
                "    #t.activity_date,\n" +
                "    0,\n" +
                "    '1'\n" +
                "FROM #t\n" +
                "WHERE\n" +
                "    type_name = '2'\n" +
                "    AND NOT EXISTS (\n" +
                "        SELECT 1 FROM #t t2 WHERE t2.type_name = '1' AND t2.activity_date = #t.activity_date\n" +
                "    );\n" +
                "\n" +
                "SELECT\n" +
                "    activity_date,\n" +
                "    SUM(activity) AS activity,\n" +
                "    SUM(impression) AS impression,\n" +
                "    SUM(revenue) AS revenue,\n" +
                "    type_name\n" +
                "FROM #t\n" +
                "GROUP BY activity_date, type_name\n" +
                "ORDER BY activity_date, type_name;\n";


        rs = stmt.executeQuery(sSql_week);
        JsonObject weekObject = new JsonObject();
        arrayData = new JsonArray();
        while (rs.next()) {
            data = new JsonObject();
            String activity_date = rs.getString(1);
            String activity = rs.getString(2);
            String impression = rs.getString(3);
            String revenue = rs.getString(4);
            String type_name = rs.getString(5);
            data.put("date", activity_date);
            data.put("impression", impression);
            data.put("revenue", revenue);
            data.put("type_name", type_name);
            data.put("activity", activity);

            arrayData.put(data);
        }
        weekObject.put("oldData", arrayData);
        smartWidgetActivityDay.put(weekObject);
        rs.close();


        String sql = "SELECT c.popup_id, " +
                "c.popup_name, " +
                "c.create_date, " +
                "c.modify_date, " +
                "c.status, " +
                "SUM(CASE WHEN a.type_name = 1 THEN a.activity ELSE 0 END) AS total_activity_type_1,SUM(CASE WHEN a.type_name = 2 THEN a.activity ELSE 0 END) AS total_activity_type_2," +
                "SUM(a.impression) AS impression, " +
                "SUM(a.revenue) AS revenue" +
                ",a.type_name " +
                "FROM c_smart_widget_config AS c " +
                "LEFT JOIN ccps_smart_widget_activity_day AS a ON c.popup_id = a.popup_id " +
                "WHERE c.cust_id = " + sCustId + " " +
                "AND a.activity_date >= '" + currentValueStartDate + " 00:00:00' " +
                "AND a.activity_date <= '" + currentValueEndDate + " 23:59:59' " +
                "AND c.status <> 90" +
                "GROUP BY c.popup_id, c.popup_name, c.create_date, c.status,a.type_name,c.modify_date " +
                "ORDER BY SUM(a.activity) DESC;";


        rs = stmt.executeQuery(sql);
        JsonObject smartWidgetObject = new JsonObject();
        arrayData = new JsonArray();

        while (rs.next()) {
            data = new JsonObject();

            String popup_id = rs.getString("popup_id");
            String popup_name = rs.getString("popup_name");
            String create_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp("create_date"));
            String modify_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp("modify_date"));
            Integer status = rs.getInt("status");
            BigDecimal click = rs.getBigDecimal("total_activity_type_1");
            BigDecimal submit = rs.getBigDecimal("total_activity_type_2");
            BigDecimal view = rs.getBigDecimal("impression");
            BigDecimal revenue = rs.getBigDecimal("revenue");
            Integer typeName = rs.getInt("type_name");

			double clickAsDouble = click == null ? 0 : click.doubleValue();
			double submitAsDouble = submit == null ? 0 : submit.doubleValue();
			double viewAsDouble = view == null ? 0 : view.doubleValue();

			double clickPercentage  = viewAsDouble == 0 ? 0 : clickAsDouble / viewAsDouble;
			double submitPercentage = viewAsDouble == 0 ? 0 : submitAsDouble / viewAsDouble;

            data.put("popup_id", popup_id);
            data.put("popup_name", popup_name);
            data.put("create_date", create_date);
            data.put("modify_date", modify_date);
            data.put("status", status);
            data.put("click", click == null ? "0" : format(click));
            data.put("view", view == null ? "0" : format(view));
            data.put("revenue", revenue == null ? "0 TL" : formatInCurrency(revenue) + " TL");
			data.put("revenueWithoutFormatted", revenue);
            data.put("type_name", typeName);
            data.put("submit", submit == null ? "0" : format(submit));
			data.put("clickPercentage", formatInPercentage(clickPercentage));
			data.put("submitPercentage", formatInPercentage(submitPercentage));

            arrayData.put(data);

        }
        smartWidgetObject.put("smartWidget", arrayData);
        smartWidgetActivityDay.put(smartWidgetObject);
        rs.close();

        Integer totalView = 0;
        Integer totalSubmit = 0;
        Integer totalClick = 0;
        Double totalRevenue = 0.0;
        JsonObject totalObject = new JsonObject();


        String totalViewSqlQuery = "SELECT SUM(impression) AS totalview FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +"WHERE cust_id = " + sCustId + " AND activity_date >= DATEADD(day, -" + dayDifference + ", '" + currentValueEndDate + " 00:00:00')";
        String totalViewSqlQuery2 = "SELECT SUM(impression) AS totalview FROM ccps_smart_widget_activity_day WITH (NOLOCK) " + "WHERE cust_id = " + sCustId + " AND activity_date BETWEEN '" + currentValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59'";


        resultSet = stmt.executeQuery(totalViewSqlQuery2);
        arrayData = new JsonArray();
        while (resultSet.next()) {
            data = new JsonObject();
            totalView = resultSet.getInt(1);
            data.put("totalView", totalView);
            arrayData.put(data);
        }

        resultSet.close();
        String totalRevenueSqlQuery = "SELECT SUM(revenue) AS revenue FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +"WHERE cust_id = " + sCustId + " AND activity_date >= DATEADD(day, " + dayDifference + ", '" + currentValueEndDate + " 00:00:00')";
        String totalRevenueSqlQuery2 = "SELECT SUM(revenue) AS revenue FROM ccps_smart_widget_activity_day WITH (NOLOCK) " + "WHERE cust_id = " + sCustId + " AND activity_date BETWEEN '" + currentValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59'";

        System.out.println("DAY DİFFERENCE "+dayDifference);
        System.out.println("CURRENT VALUEEE "+currentValueEndDate);
        System.out.println("ENDDD DATEE "+currentValueStartDate);

        resultSet = stmt.executeQuery(totalRevenueSqlQuery2);

        while (resultSet.next()) {
            data = new JsonObject();
            totalRevenue = resultSet.getDouble(1);
            data.put("totalRevenue", totalRevenue);
            arrayData.put(data);
        }

        resultSet.close();
        String totalClickSqlQuery = "SELECT SUM(activity) AS click FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +"WHERE cust_id = " + sCustId +  " AND activity_date >= DATEADD(day, -" + dayDifference + ", '" + currentValueEndDate + " 00:00:00') " +" AND type_name = 1";
        String totalClickSqlQuery2 = "SELECT SUM(activity) AS click FROM ccps_smart_widget_activity_day WITH (NOLOCK) " + "WHERE cust_id = " + sCustId + " AND activity_date BETWEEN '" + currentValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59'" + " AND type_name = 1";



        resultSet = stmt.executeQuery(totalClickSqlQuery2);

        while (resultSet.next()) {
            data = new JsonObject();
            totalClick = resultSet.getInt(1);
            data.put("totalClick", totalClick);
            arrayData.put(data);
        }

        resultSet.close();

        String totalSubmitSqlQuery = "SELECT SUM(activity) AS click FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +"WHERE cust_id = " + sCustId +  " AND activity_date >= DATEADD(day, -" + dayDifference + ", '" + currentValueEndDate + " 00:00:00') " +" AND type_name = 2";
        String totalSubmitSqlQuery2 = "SELECT SUM(cswad.activity) AS click " +
                "FROM ccps_smart_widget_activity_day cswad WITH (NOLOCK) " +
                "LEFT JOIN c_smart_widget_config AS cswc ON cswad.popup_id = cswc.popup_id " +
                "WHERE cswad.cust_id = " + sCustId +
                " AND cswad.activity_date BETWEEN '" + currentValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59'" +
                " AND cswad.type_name = 2" +
                " AND cswc.status <> 90 AND cswc.status != 0";


        resultSet = stmt.executeQuery(totalSubmitSqlQuery2);

        while (resultSet.next()) {
            totalSubmit = resultSet.getInt(1);
            data = new JsonObject();
            data.put("totalSubmit", totalSubmit);
            arrayData.put(data);
        }
        resultSet.close();
        totalObject.put("total", arrayData);

        smartWidgetActivityDay.put(totalObject);

        out.println(smartWidgetActivityDay);
    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    } finally {
        try {
            if (resultSet != null) resultSet.close();
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection on report_smartwidget_activity_day_new_api.jsp", e);
        }
    }
%>
<%!
    public String formatDate(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1;
        int day = calendar.get(Calendar.DAY_OF_MONTH);

        return String.format("%04d-%02d-%02d", year, month, day);
    }
%>

<%!
    public String format(long value) {
        DecimalFormat df = new DecimalFormat("###,###,###");

        return df.format(value);
    }
%>

<%!
    public String format(int value) {
        DecimalFormat df = new DecimalFormat("###,###,###");

        return df.format(value);
    }
%>

<%!
    public String format(BigDecimal value) {
        DecimalFormat df = new DecimalFormat("###,###,###");

        return df.format(value);
    }
%>

<%!
    public String formatInCurrency(double value) {
        DecimalFormat df = new DecimalFormat("###,###,###.##");

        return df.format(value);
    }
%>

<%!
    public String formatInCurrency(BigDecimal value) {
        DecimalFormat df = new DecimalFormat("###,###,###.##");

        return df.format(value);
    }
%>

<%!
    public String formatInPercentage(double value) {
        DecimalFormat df = new DecimalFormat("0.00%");

        return df.format(value);
    }
%>

<%!
    public String formatInPercentage(BigDecimal value) {
        DecimalFormat df = new DecimalFormat("0.00%");

        return df.format(value);
    }
%>