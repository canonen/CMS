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

    }

    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        stmt = conn.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
        stmt.setFetchSize(1000); // SQL Server 2012 i�in optimize boyut


        String ultraQuery =
                "SET NOCOUNT ON; " +
                        "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; " +


                        "WITH FastData AS ( " +
                        "    SELECT " +
                        "        1 AS query_type, " +
                        "        CONVERT(VARCHAR(10), activity_date, 120) AS str_date, " +
                        "        CAST(type_name AS VARCHAR(10)) AS type_name, " +
                        "        SUM(CAST(activity AS BIGINT)) AS activity, " +
                        "        SUM(CAST(impression AS BIGINT)) AS impression, " +
                        "        SUM(CAST(revenue AS DECIMAL(18,4))) AS revenue, " +
                        "        CASE WHEN activity_date BETWEEN '" + currentValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59' THEN 1 ELSE 0 END AS is_current, " +
                        "        CAST(0 AS VARCHAR(50)) AS popup_id, " +
                        "        CAST('' AS VARCHAR(200)) AS popup_name, " +
                        "        CAST('' AS VARCHAR(8000)) AS config_param, " +
                        "        GETDATE() AS create_date, " +
                        "        GETDATE() AS modify_date, " +
                        "        CAST(0 AS INT) AS status, " +
                        "        CAST(0 AS BIGINT) AS total_click, " +
                        "        CAST(0 AS BIGINT) AS total_submit " +
                        "    FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +
                        "    WHERE cust_id = '" + sCustId + "' " +  // String olarak kullan
                        "        AND activity_date BETWEEN '" + oldValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59' " +
                        "    GROUP BY CONVERT(VARCHAR(10), activity_date, 120), type_name, " +
                        "        CASE WHEN activity_date BETWEEN '" + currentValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59' THEN 1 ELSE 0 END " +
                        "), " +
                        "WidgetData AS ( " +
                        "    SELECT " +
                        "        2 AS query_type, " +
                        "        CAST('' AS VARCHAR(10)) AS str_date, " +
                        "        CAST(a.type_name AS VARCHAR(10)) AS type_name, " +
                        "        CAST(0 AS BIGINT) AS activity, " +
                        "        SUM(CAST(a.impression AS BIGINT)) AS impression, " +
                        "        SUM(CAST(a.revenue  AS DECIMAL(18,4))) AS revenue, " +
                        "        CAST(0 AS INT) AS is_current, " +
                        "        CAST(c.popup_id AS VARCHAR(50)) AS popup_id, " +
                        "        CAST(ISNULL(c.popup_name, '') AS VARCHAR(200)) AS popup_name, " +
                        "        c.config_param, " +
                        "        c.create_date, " +
                        "        c.modify_date, " +
                        "        c.status, " +
                        "        CAST(ISNULL(SUM(CASE WHEN CAST(a.type_name AS INT) = 1 THEN CAST(a.activity AS BIGINT) END), 0) AS BIGINT) AS total_click, " +
                        "        CAST(ISNULL(SUM(CASE WHEN CAST(a.type_name AS INT) = 2 THEN CAST(a.activity AS BIGINT) END), 0) AS BIGINT) AS total_submit " +
                        "    FROM c_smart_widget_config c WITH (NOLOCK) " +
                        "    LEFT JOIN ccps_smart_widget_activity_day a WITH (NOLOCK)  ON c.popup_id = a.popup_id " +
                        "    WHERE c.cust_id = '" + sCustId + "'" +
                        "    AND c.status <> 90 " +
                        "    AND a.activity_date BETWEEN '" + currentValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59' " +
                        "    GROUP BY c.popup_id, c.popup_name, c.create_date, c.modify_date, c.status , a.type_name, c.config_param " +
                        ")" +
//                        "TotalData AS ( " +
//                        "    SELECT " +
//                        "        3 AS query_type, " +
//                        "        CAST('' AS VARCHAR(10)) AS str_date, " +
//                        "        CAST('' AS VARCHAR(10)) AS type_name, " +
//                        "        CAST(SUM(CASE WHEN CAST(a.type_name AS INT) = 1 THEN CAST(a.activity AS BIGINT) ELSE 0 END) AS BIGINT) AS activity, " +
//                        "        CAST(SUM(CAST(a.impression AS BIGINT)) AS BIGINT) AS impression, " +
//                        "        CAST(SUM(CAST(a.revenue AS DECIMAL(18,4))) AS DECIMAL(18,4)) AS revenue, " +
//                        "        CAST(0 AS INT) AS is_current, " +
//                        "        CAST('0' AS VARCHAR(50)) AS popup_id, " +
//                        "        CAST('' AS VARCHAR(200)) AS popup_name, " +
//                        "        CAST('' AS VARCHAR(8000)) AS config_param, " +
//                        "        GETDATE() AS create_date, " +
//                        "        GETDATE() AS modify_date, " +
//                        "        CAST(0 AS INT) AS status, " +
//                        "        CAST(0 AS BIGINT) AS total_click, " +
//                        "        CAST(SUM(CASE WHEN CAST(a.type_name AS INT) = 2 AND ISNULL(c.status, 1) NOT IN (0,90) THEN CAST(a.activity AS BIGINT) ELSE 0 END) AS BIGINT) AS total_submit " +
//                        "    FROM ccps_smart_widget_activity_day a WITH (NOLOCK) " +
//                        "    LEFT JOIN c_smart_widget_config c WITH (NOLOCK) ON a.popup_id = c.popup_id " +
//                        "    WHERE a.cust_id = '" + sCustId + "' " +
//                        "        AND a.activity_date BETWEEN '" + currentValueStartDate + " 00:00:00' AND '" + currentValueEndDate + " 23:59:59' " +
//                        ") " +

                        "SELECT * FROM FastData " +
                        "UNION ALL SELECT * FROM WidgetData " +
                        //"UNION ALL SELECT * FROM TotalData " +
                        "ORDER BY revenue DESC, query_type, is_current DESC, str_date, type_name";

        long startTime = System.currentTimeMillis();
        rs = stmt.executeQuery(ultraQuery);

        // Veri yapilari
        JsonArray smartWidgetActivityDay = new JsonArray();
        JsonArray currentData = new JsonArray();
        JsonArray oldData = new JsonArray();
        JsonArray smartWidgetData = new JsonArray();
        JsonArray totalData = new JsonArray();

        long totalView = 0;
        long totalClick = 0;
        long totalSubmit = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;

        while (rs.next()) {
            int queryType = rs.getInt("query_type");

            switch (queryType) {
                case 1: // Activity Data
                    JsonObject activityData = new JsonObject();
                    activityData.put("date", rs.getString("str_date"));
                    activityData.put("type_name", rs.getString("type_name"));
                    activityData.put("activity", String.valueOf(rs.getLong("activity")));
                    activityData.put("impression", String.valueOf(rs.getLong("impression")));
                    activityData.put("revenue", String.valueOf(rs.getBigDecimal("revenue")));

                    if (rs.getInt("is_current") == 1) {
                        currentData.put(activityData);
                    } else {
                        oldData.put(activityData);
                    }
                    break;

                case 2: // Widget Data
                    JsonObject widgetData = new JsonObject();
                    long click = rs.getLong("total_click");
                    long submit = rs.getLong("total_submit");
                    BigDecimal view = rs.getBigDecimal("impression") == null ? BigDecimal.valueOf(0) : rs.getBigDecimal("impression") ;
                    BigDecimal revenue = rs.getBigDecimal("revenue");

                    double clickAsDouble = click;
                    double submitAsDouble = submit;
                    double viewAsDouble = view.doubleValue();

                    widgetData.put("popup_id", rs.getString("popup_id"));
                    widgetData.put("popup_name", rs.getString("popup_name"));
                    widgetData.put("config_param", rs.getString("config_param"));

                    // Date handling - null check
                    java.sql.Timestamp createTs = rs.getTimestamp("create_date");
                    java.sql.Timestamp modifyTs = rs.getTimestamp("modify_date");

                    widgetData.put("create_date", createTs != null ?
                            DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(createTs) : "");
                    widgetData.put("modify_date", modifyTs != null ?
                            DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(modifyTs) : "");

                    widgetData.put("status", rs.getInt("status"));
                    widgetData.put("click", String.valueOf(click));
                    widgetData.put("view", String.valueOf(view));
                    widgetData.put("revenue", revenue != null ? formatInCurrency(revenue) + " TL" : "0 TL");
                    widgetData.put("revenueWithoutFormatted", revenue);
                    widgetData.put("type_name", rs.getString("type_name"));
                    widgetData.put("submit", String.valueOf(submit));
                    widgetData.put("clickPercentage", formatInPercentage(viewAsDouble == 0 ? 0 : clickAsDouble / viewAsDouble));
                    widgetData.put("submitPercentage", formatInPercentage(viewAsDouble == 0 ? 0 : submitAsDouble / viewAsDouble));

                    smartWidgetData.put(widgetData);

                    // Total Data
                    totalView += view.longValue();
                    totalClick += click;
                    totalSubmit += submit;

                    if ( revenue != null){
                        totalRevenue = totalRevenue.add(revenue);
                    }
                    break;

//                case 3: // Total Data
//                    JsonObject totalEntry = new JsonObject();
//                    totalEntry.put("totalView", rs.getLong("impression"));
//                    totalEntry.put("totalRevenue", rs.getBigDecimal("revenue") == null ? 0 : rs.getLong("revenue") );
//                    totalEntry.put("totalClick", rs.getLong("activity"));
//                    totalEntry.put("totalSubmit", rs.getLong("total_submit") );
//                    totalData.put(totalEntry);
//                    break;
            }
        }

        JsonObject totalEntry = new JsonObject();
        totalEntry.put("totalView", totalView);
        totalEntry.put("totalClick", totalClick);
        totalEntry.put("totalSubmit", totalSubmit);
        totalEntry.put("totalRevenue", totalRevenue);
        totalData.put(totalEntry);

        // JSON yapisini olustur
        JsonObject currentWeek = new JsonObject();
        currentWeek.put("currentData", currentData);

        JsonObject weekObject = new JsonObject();
        weekObject.put("oldData", oldData);

        JsonObject smartWidgetObject = new JsonObject();
        smartWidgetObject.put("smartWidget", smartWidgetData);

        JsonObject totalObject = new JsonObject();
        totalObject.put("total", totalData);

        smartWidgetActivityDay.put(currentWeek);
        smartWidgetActivityDay.put(weekObject);
        smartWidgetActivityDay.put(smartWidgetObject);
        smartWidgetActivityDay.put(totalObject);

        long endTime = System.currentTimeMillis();
        System.out.println("Query execution time: " + (endTime - startTime) + "ms");

        out.print(smartWidgetActivityDay.toString());

    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    }
    finally {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                logger.error("ResultSet close error", e);
            }
        }

        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                logger.error("Statement close error", e);
            }
        }

        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                logger.error("Connection close error", e);
            } finally {
                if (cp != null) {
                    cp.free(conn);
                }
            }
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