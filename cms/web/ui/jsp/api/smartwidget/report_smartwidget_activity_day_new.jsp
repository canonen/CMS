<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Calendar,
                java.io.*,
                org.apache.log4j.Logger,
                java.text.DateFormat,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>


<%

    // System.out.println("--------------SMARTWIDGETREPORT----------");
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
    // value=(-1)*(value);

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

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        // Önceki CTE'li ve geçici tablolu çözümlere göre daha basit ve uyumlu UNION ALL sorgusu
        String simpleCombinedQuery = "SELECT 'current' as period, YEAR(activity_date) as YIL, MONTH(activity_date) as AY, DAY(activity_date) as GUN, type_name, " +
                "       SUM(activity) as total_activity, SUM(impression) as total_impression, SUM(revenue) as total_revenue " +
                "FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +
                "WHERE cust_id = " + sCustId + " AND activity_date BETWEEN '" + d_startdate + " 00:00:00' AND '" + d_enddate + " 23:59:59' " +
                "GROUP BY YEAR(activity_date), MONTH(activity_date), DAY(activity_date), type_name " +
                "UNION ALL " +
                "SELECT 'previous' as period, YEAR(activity_date) as YIL, MONTH(activity_date) as AY, DAY(activity_date) as GUN, type_name, " +
                "       SUM(activity) as total_activity, SUM(impression) as total_impression, SUM(revenue) as total_revenue " +
                "FROM ccps_smart_widget_activity_day WITH (NOLOCK) " +
                "WHERE cust_id = " + sCustId + " AND activity_date BETWEEN DATEADD(day, -" + valuee + ", '" + d_startdate + "') AND '" + d_startdate + " 23:59:59' " +
                "GROUP BY YEAR(activity_date), MONTH(activity_date), DAY(activity_date), type_name " +
                "ORDER BY period, YIL, AY, GUN, type_name";

        rs = stmt.executeQuery(simpleCombinedQuery);

        JsonObject currentWeek = new JsonObject();
        JsonArray currentArrayData = new JsonArray();
        JsonObject weekObject = new JsonObject();
        JsonArray weekArrayData = new JsonArray();

        while (rs.next()) {
            String period = rs.getString("period");
            String year = rs.getString("YIL");
            String month = rs.getString("AY");
            String day = rs.getString("GUN");
            String activity = rs.getString("total_activity");
            String impression = rs.getString("total_impression");
            String revenue = rs.getString("total_revenue");
            String type_name = rs.getString("type_name");

            data = new JsonObject();
            data.put("date", year + "-" + month + "-" + day);
            data.put("impression", impression);
            data.put("revenue", revenue);
            data.put("type_name", type_name);
            data.put("activity", activity);

            if ("current".equals(period)) {
                currentArrayData.put(data);
            } else {
                weekArrayData.put(data);
            }
        }

        currentWeek.put("currentWeek", currentArrayData);
        smartWidgetActivityDay.put(currentWeek);

        weekObject.put("weekData", weekArrayData);
        smartWidgetActivityDay.put(weekObject);
        rs.close();



        String sql = "select popup_id, popup_name, form_id, create_date, modify_date from c_smart_widget_config where cust_id=" + sCustId;
        // System.out.println("SQL':" + sql);

        rs = stmt.executeQuery(sql);

        arrayData = new JsonArray();
        while (rs.next()) {


            data = new JsonObject();
            String popup_id = rs.getString(1);
            String popup_name = rs.getString(2);
            String form_id = rs.getString(3);
            String create_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(4));
            String modify_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(5));

            data.put("popup_id", popup_id);
            data.put("popup_name", popup_name);
            data.put("form_id", form_id);
            data.put("create_date", create_date);
            data.put("modify_date", modify_date);

            arrayData.put(data);

        }
        smartWidgetActivityDay.put(arrayData);
        rs.close();

        Integer totalView = 0;
        Integer totalSubmit = 0;
        Integer totalClick = 0;
        Double totalRevenue = 0.0;


        String totalStatsQuery = "SELECT " +
                "COALESCE(SUM(impression), 0) AS total_view, " +
                "COALESCE(SUM(revenue), 0) AS total_revenue, " +
                "COALESCE(SUM(CASE WHEN type_name = '1' THEN activity ELSE 0 END), 0) AS total_click, " +
                "COALESCE(SUM(CASE WHEN type_name = '2' THEN activity ELSE 0 END), 0) AS total_submit " +
                "FROM ccps_smart_widget_activity_day " +
                "WHERE cust_id=" + sCustId + " AND activity_date >= DATEADD(day, " + (-value) + ", '" + d_startdate + "')";

        resultSet = stmt.executeQuery(totalStatsQuery);

        if (resultSet.next()) {
            totalView = resultSet.getInt("total_view");
            totalClick = resultSet.getInt("total_click");
            totalSubmit = resultSet.getInt("total_submit");
            totalRevenue = resultSet.getDouble("total_revenue");
        }
        resultSet.close();

        // Recreate the original's buggy JSON structure for total stats
        arrayData = new JsonArray();

        data = new JsonObject();
        data.put("totalRevenue", totalRevenue);
        arrayData.put(data);

        data = new JsonObject();
        data.put("totalView", totalView);
        arrayData.put(data);

        data = new JsonObject();
        data.put("totalClick", totalClick);
        arrayData.put(data);

        data = new JsonObject();
        data.put("totalSubmit", totalSubmit);
        arrayData.put(data);

        smartWidgetActivityDay.put(arrayData);

        out.println(smartWidgetActivityDay);
    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    } finally {
        try {
            if (resultSet != null) resultSet.close();
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection on report_smartwidget_activity_day_new.jsp", e);
        }
    }


%>