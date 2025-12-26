<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Calendar,
                java.io.*,
                java.math.BigDecimal,
                java.text.DecimalFormat,
                org.apache.log4j.Logger,
                java.text.DateFormat,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%
    String sCustId = cust.s_cust_id;

    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
    service = (Service) services.get(0);
    String rcpLink = service.getURL().getHost();

    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;

    String d_startdate = null;
    String d_enddate = null;
    String firstDate = request.getParameter("firstDate");
    String lastDate = request.getParameter("lastDate");
    String valuee = request.getParameter("oldData");
    Integer value = 0;

    value = Integer.parseInt(valuee);
    if (firstDate != null) {
        d_startdate = firstDate;
    }
    if (lastDate != null) {
        d_enddate = lastDate;
    }

    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
        stmt.setFetchSize(1000);

        // SQL Server 2012 uyumlu - DECLARE ve SET ayrı ayrı
        String optimizedQuery =
                "SET NOCOUNT ON; " +
                        "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; " +

                        // Değişkenleri DECLARE et
                        "DECLARE @startDate DATETIME; " +
                        "DECLARE @endDate DATETIME; " +
                        "DECLARE @oldStartDate DATETIME; " +
                        "DECLARE @oldEndDate DATETIME; " +

                        // Değerleri SET ile ata
                        "SET @startDate = '" + d_startdate + " 00:00:00'; " +
                        "SET @endDate = '" + d_enddate + " 23:59:59'; " +
                        "SET @oldStartDate = DATEADD(day, -" + value + ", @startDate); " +
                        "SET @oldEndDate = DATEADD(day, -1, @startDate); " +

                        "WITH AllData AS ( " +
                        // Current Week Data
                        "    SELECT " +
                        "        1 AS data_type, " +
                        "        YEAR(activity_date) AS year_val, " +
                        "        MONTH(activity_date) AS month_val, " +
                        "        DAY(activity_date) AS day_val, " +
                        "        CAST(type_name AS VARCHAR(10)) AS type_name, " +
                        "        SUM(CAST(activity AS BIGINT)) AS activity, " +
                        "        SUM(CAST(impression AS BIGINT)) AS impression, " +
                        "        SUM(CAST(revenue AS DECIMAL(18,4))) AS revenue, " +
                        "        CAST('' AS VARCHAR(50)) AS popup_id, " +
                        "        CAST('' AS VARCHAR(200)) AS popup_name, " +
                        "        CAST('' AS VARCHAR(50)) AS form_id, " +
                        "        GETDATE() AS create_date, " +
                        "        GETDATE() AS modify_date " +
                        "    FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +
                        "    WHERE cust_id = '" + sCustId + "' " +
                        "        AND activity_date BETWEEN @startDate AND @endDate " +
                        "    GROUP BY YEAR(activity_date), MONTH(activity_date), DAY(activity_date), type_name " +

                        "    UNION ALL " +

                        // Old Week Data
                        "    SELECT " +
                        "        2 AS data_type, " +
                        "        YEAR(activity_date) AS year_val, " +
                        "        MONTH(activity_date) AS month_val, " +
                        "        DAY(activity_date) AS day_val, " +
                        "        CAST(type_name AS VARCHAR(10)) AS type_name, " +
                        "        SUM(CAST(activity AS BIGINT)) AS activity, " +
                        "        SUM(CAST(impression AS BIGINT)) AS impression, " +
                        "        SUM(CAST(revenue AS DECIMAL(18,4))) AS revenue, " +
                        "        CAST('' AS VARCHAR(50)) AS popup_id, " +
                        "        CAST('' AS VARCHAR(200)) AS popup_name, " +
                        "        CAST('' AS VARCHAR(50)) AS form_id, " +
                        "        GETDATE() AS create_date, " +
                        "        GETDATE() AS modify_date " +
                        "    FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +
                        "    WHERE cust_id = '" + sCustId + "' " +
                        "        AND activity_date BETWEEN @oldStartDate AND @oldEndDate " +
                        "    GROUP BY YEAR(activity_date), MONTH(activity_date), DAY(activity_date), type_name " +

                        "    UNION ALL " +

                        // Config Data
                        "    SELECT " +
                        "        3 AS data_type, " +
                        "        0 AS year_val, 0 AS month_val, 0 AS day_val, " +
                        "        CAST('0' AS VARCHAR(10)) AS type_name, " +
                        "        CAST(0 AS BIGINT) AS activity, " +
                        "        CAST(0 AS BIGINT) AS impression, " +
                        "        CAST(0 AS DECIMAL(18,4)) AS revenue, " +
                        "        CAST(popup_id AS VARCHAR(50)) AS popup_id, " +
                        "        CAST(ISNULL(popup_name, '') AS VARCHAR(200)) AS popup_name, " +
                        "        CAST(ISNULL(CAST(form_id AS VARCHAR(50)), '') AS VARCHAR(50)) AS form_id, " +
                        "        create_date, modify_date " +
                        "    FROM c_smart_widget_config WITH (NOLOCK) " +
                        "    WHERE cust_id = '" + sCustId + "' " +
                        ") " +

                        "SELECT * FROM AllData " +
                        "ORDER BY data_type, year_val, month_val, day_val, type_name";

        long startTime = System.currentTimeMillis();
        rs = stmt.executeQuery(optimizedQuery);

        JsonArray smartWidgetActivityDay = new JsonArray();
        JsonArray currentWeekData = new JsonArray();
        JsonArray weekData = new JsonArray();
        JsonArray configData = new JsonArray();

        while (rs.next()) {
            int dataType = rs.getInt("data_type");
            JsonObject data = new JsonObject();

            switch (dataType) {
                case 1: // Current Week
                    String currentDate = rs.getInt("year_val") + "-" + rs.getInt("month_val") + "-" + rs.getInt("day_val");
                    data.put("date", currentDate);
                    data.put("impression", String.valueOf(rs.getLong("impression")));
                    data.put("revenue", formatInCurrency(rs.getBigDecimal("revenue"))); // 4 hane
                    data.put("type_name", rs.getString("type_name"));
                    data.put("activity", String.valueOf(rs.getLong("activity")));
                    currentWeekData.put(data);
                    break;

                case 2: // Old Week
                    String oldDate = rs.getInt("year_val") + "-" + rs.getInt("month_val") + "-" + rs.getInt("day_val");
                    data.put("date", oldDate);
                    data.put("impression", String.valueOf(rs.getLong("impression")));
                    data.put("revenue", formatInCurrency(rs.getBigDecimal("revenue"))); // 4 hane
                    data.put("type_name", rs.getString("type_name"));
                    data.put("activity", String.valueOf(rs.getLong("activity")));
                    weekData.put(data);
                    break;

                case 3: // Config
                    data.put("popup_id", rs.getString("popup_id"));
                    data.put("popup_name", rs.getString("popup_name"));
                    data.put("form_id", rs.getString("form_id"));

                    java.sql.Timestamp createTs = rs.getTimestamp("create_date");
                    java.sql.Timestamp modifyTs = rs.getTimestamp("modify_date");
                    data.put("create_date", createTs != null ?
                            DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(createTs) : "");
                    data.put("modify_date", modifyTs != null ?
                            DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(modifyTs) : "");

                    configData.put(data);
                    break;
            }
        }

        rs.close();

        // Total Data için ayrı sorgu - daha basit
        String totalQuery = "SELECT " +
                "    SUM(impression) AS totalView, " +
                "    SUM(revenue) AS totalRevenue, " +
                "    SUM(CASE WHEN type_name = '1' THEN activity ELSE 0 END) AS totalClick, " +
                "    SUM(CASE WHEN type_name = '2' THEN activity ELSE 0 END) AS totalSubmit " +
                "FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +
                "WHERE cust_id = '" + sCustId + "' " +
                "    AND activity_date >= DATEADD(day, -" + value + ", '" + d_startdate + "')";

        rs = stmt.executeQuery(totalQuery);
        JsonArray totalData = new JsonArray();

        if (rs.next()) {
            JsonObject totalObj = new JsonObject();
            totalObj.put("totalView", rs.getLong("totalView"));
            totalObj.put("totalRevenue", rs.getDouble("totalRevenue"));
            totalObj.put("totalClick", rs.getLong("totalClick"));
            totalObj.put("totalSubmit", rs.getLong("totalSubmit"));
            totalData.put(totalObj);
        }

        // JSON yapısını oluştur
        JsonObject currentWeek = new JsonObject();
        currentWeek.put("currentWeek", currentWeekData);

        JsonObject weekObject = new JsonObject();
        weekObject.put("weekData", weekData);

        smartWidgetActivityDay.put(currentWeek);
        smartWidgetActivityDay.put(weekObject);
        smartWidgetActivityDay.put(configData);
        smartWidgetActivityDay.put(totalData);

        long endTime = System.currentTimeMillis();
        System.out.println("Optimized query execution time: " + (endTime - startTime) + "ms");

        out.println(smartWidgetActivityDay);

    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection", e);
        }
    }
%>

<%!
    public String formatInCurrency(BigDecimal value) {
        if (value == null) return "0.0000";
        DecimalFormat df = new DecimalFormat("###,###,###.####");
        return df.format(value);
    }
%>