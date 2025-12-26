<%@ page
        language="java"
        import="com.britemoon.*,
            com.britemoon.cps.*,
            java.sql.*,
            java.io.*,
            java.util.*,
            java.math.BigDecimal,
            java.util.Calendar"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp" %>
<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    String sCustId = user.s_cust_id;
    String firstDate = request.getParameter("firstDate");
    String lastDate = request.getParameter("lastDate");

    Calendar calendar = Calendar.getInstance();
    int currentYear = calendar.get(Calendar.YEAR);

    ConnectionPool connectionPool = null;
    Connection connection = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    JsonArray totalSentArray = new JsonArray();
    JsonArray readAndClickAndBbackArray = new JsonArray();
    JsonArray dailyRqueCountArray = new JsonArray();
    JsonArray dailyTotalOpenArray = new JsonArray();
    JsonArray dailyTotalClickArray = new JsonArray();
    JsonArray monthlyRqueCountArray = new JsonArray();
    JsonArray monthlyOpenArray = new JsonArray();
    JsonArray monthlyClickTimeArray = new JsonArray();
    JsonArray yearsTotalRecipientArray = new JsonArray();
    JsonArray yearOpenArray = new JsonArray();
    JsonArray yearClickArray = new JsonArray();

    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);

        // ====================================================
        // 1️⃣ TOTAL SENT
        // ====================================================
        String sqlTotalSent =
                "SELECT SUM(CAST(m.rque_count AS BIGINT)) " +
                        "FROM ccps_rque_message m WITH(NOLOCK) " +
                        "WHERE m.send_date >= ? AND m.send_date <= ? AND m.cust_id = ?";
        pstmt = connection.prepareStatement(sqlTotalSent);
        pstmt.setString(1, firstDate);
        pstmt.setString(2, lastDate);
        pstmt.setString(3, sCustId);
        rs = pstmt.executeQuery();
        if (rs.next() && rs.getString(1) != null)
            totalSentArray.put(rs.getString(1));
        rs.close(); pstmt.close();

        // ====================================================
        // 2️⃣ READ / CLICK / BOUNCE RATES
        // ====================================================
        String sqlRates =
                "SELECT " +
                        "AVG(CASE r.sent - r.bbacks WHEN 0 THEN 0 ELSE CONVERT(DECIMAL(5,1),(r.dist_reads*100.0)/(r.sent-r.bbacks)) END) AS readPrc, " +
                        "AVG(CASE r.sent - r.bbacks WHEN 0 THEN 0 ELSE CONVERT(DECIMAL(5,1),(r.dist_clicks*100.0)/(r.sent-r.bbacks)) END) AS clickPrc, " +
                        "AVG(CASE r.sent WHEN 0 THEN 0 ELSE CONVERT(DECIMAL(5,1),(r.bbacks*100.0)/r.sent) END) AS bbackPrc " +
                        "FROM ccps_rrpt_camp_summary_and_rque_campaign r WITH(NOLOCK) " +
                        "WHERE r.start_date >= ? AND r.start_date <= ? AND r.cust_id = ?";
        pstmt = connection.prepareStatement(sqlRates);
        pstmt.setString(1, firstDate);
        pstmt.setString(2, lastDate);
        pstmt.setString(3, sCustId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            JsonObject rates = new JsonObject();
            rates.put("sReadPrc", rs.getBigDecimal(1) == null ? "0.00" : rs.getBigDecimal(1).setScale(2, java.math.RoundingMode.HALF_UP));
            rates.put("sClickPrc", rs.getBigDecimal(2) == null ? "0.00" : rs.getBigDecimal(2).setScale(2, java.math.RoundingMode.HALF_UP));
            rates.put("sbbackPrc", rs.getBigDecimal(3) == null ? "0.00" : rs.getBigDecimal(3).setScale(2, java.math.RoundingMode.HALF_UP));
            readAndClickAndBbackArray.put(rates);
        }
        rs.close(); pstmt.close();

        // ====================================================
        // 3️⃣ DAILY STATS (sent / open / click)
        // ====================================================
        String sqlDaily =
                "SELECT " +
                        "DAY(m.send_date) AS day, " +
                        "SUM(CAST(m.rque_count AS BIGINT)) AS sent, " +
                        "SUM(CASE WHEN l.type_id = 1 THEN CAST(l.rjtk_count AS BIGINT) ELSE 0 END) AS openCnt, " +
                        "SUM(CASE WHEN l.type_id = 2 THEN CAST(l.rjtk_count AS BIGINT) ELSE 0 END) AS clickCnt " +
                        "FROM ccps_rque_message m WITH(NOLOCK) " +
                        "LEFT JOIN ccps_rjtk_link_activity l WITH(NOLOCK) " +
                        "ON l.cust_id = m.cust_id " +
                        "AND l.click_time >= m.send_date AND l.click_time < DATEADD(DAY, 1, m.send_date) " +
                        "WHERE m.cust_id = ? AND m.send_date >= ? AND m.send_date <= ? " +
                        "GROUP BY DAY(m.send_date) ORDER BY DAY(m.send_date)";
        pstmt = connection.prepareStatement(sqlDaily);
        pstmt.setString(1, sCustId);
        pstmt.setString(2, firstDate);
        pstmt.setString(3, lastDate);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            String day = rs.getString("day");
            if (rs.getString("sent") != null && !rs.getString("sent").equals("0")) {
                JsonObject s = new JsonObject();
                s.put("day", day);
                s.put("dailyRqueCount", rs.getString("sent"));
                dailyRqueCountArray.put(s);
            }
            if (rs.getString("openCnt") != null && !rs.getString("openCnt").equals("0")) {
                JsonObject o = new JsonObject();
                o.put("day", day);
                o.put("totalOpen", rs.getString("openCnt"));
                dailyTotalOpenArray.put(o);
            }
            if (rs.getString("clickCnt") != null && !rs.getString("clickCnt").equals("0")) {
                JsonObject c = new JsonObject();
                c.put("day", day);
                c.put("click", rs.getString("clickCnt"));
                dailyTotalClickArray.put(c);
            }
        }
        rs.close(); pstmt.close();

        // ====================================================
        // 4️⃣ MONTHLY STATS
        // ====================================================
        String sqlMonthly =
                "SELECT " +
                        "MONTH(m.send_date) AS month, " +
                        "SUM(CAST(m.rque_count AS BIGINT)) AS sent, " +
                        "SUM(CASE WHEN l.type_id = 1 THEN CAST(l.rjtk_count AS BIGINT) ELSE 0 END) AS openCnt, " +
                        "SUM(CASE WHEN l.type_id = 2 THEN CAST(l.rjtk_count AS BIGINT) ELSE 0 END) AS clickCnt " +
                        "FROM ccps_rque_message m WITH(NOLOCK) " +
                        "LEFT JOIN ccps_rjtk_link_activity l WITH(NOLOCK) " +
                        "ON l.cust_id = m.cust_id " +
                        "AND YEAR(l.click_time) = YEAR(m.send_date) " +
                        "AND MONTH(l.click_time) = MONTH(m.send_date) " +
                        "WHERE m.cust_id = ? AND YEAR(m.send_date) = ? " +
                        "GROUP BY MONTH(m.send_date) ORDER BY MONTH(m.send_date)";
        pstmt = connection.prepareStatement(sqlMonthly);
        pstmt.setString(1, sCustId);
        pstmt.setInt(2, currentYear);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            String month = rs.getString("month");
            if (rs.getString("sent") != null && !rs.getString("sent").equals("0")) {
                JsonObject s = new JsonObject();
                s.put("month", month);
                s.put("monthlyValue", rs.getString("sent"));
                monthlyRqueCountArray.put(s);
            }
            if (rs.getString("openCnt") != null && !rs.getString("openCnt").equals("0")) {
                JsonObject o = new JsonObject();
                o.put("month", month);
                o.put("monthlyOpen", rs.getString("openCnt"));
                monthlyOpenArray.put(o);
            }
            if (rs.getString("clickCnt") != null && !rs.getString("clickCnt").equals("0")) {
                JsonObject c = new JsonObject();
                c.put("month", month);
                c.put("click", rs.getString("clickCnt"));
                monthlyClickTimeArray.put(c);
            }
        }
        rs.close(); pstmt.close();

        // ====================================================
        // 5️⃣ YEARLY STATS (JOIN YOK — ayrı SUM’lar)
        // ====================================================

        // Sent
        String sqlYearlySent =
                "SELECT YEAR(send_date) AS year, SUM(CAST(rque_count AS BIGINT)) AS sent " +
                        "FROM ccps_rque_message WITH(NOLOCK) " +
                        "WHERE cust_id = ? GROUP BY YEAR(send_date) ORDER BY YEAR(send_date)";
        pstmt = connection.prepareStatement(sqlYearlySent);
        pstmt.setString(1, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JsonObject s = new JsonObject();
            s.put("year", rs.getString("year"));
            s.put("totalRecipient", rs.getString("sent"));
            yearsTotalRecipientArray.put(s);
        }
        rs.close(); pstmt.close();

        // Open
        String sqlYearlyOpen =
                "SELECT YEAR(click_time) AS year, SUM(CAST(rjtk_count AS BIGINT)) AS openCnt " +
                        "FROM ccps_rjtk_link_activity WITH(NOLOCK) " +
                        "WHERE type_id = 1 AND cust_id = ? GROUP BY YEAR(click_time) ORDER BY YEAR(click_time)";
        pstmt = connection.prepareStatement(sqlYearlyOpen);
        pstmt.setString(1, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JsonObject o = new JsonObject();
            o.put("year", rs.getString("year"));
            o.put("totalYearCount", rs.getString("openCnt"));
            yearOpenArray.put(o);
        }
        rs.close(); pstmt.close();

        // Click
        String sqlYearlyClick =
                "SELECT YEAR(click_time) AS year, SUM(CAST(rjtk_count AS BIGINT)) AS clickCnt " +
                        "FROM ccps_rjtk_link_activity WITH(NOLOCK) " +
                        "WHERE type_id = 2 AND cust_id = ? GROUP BY YEAR(click_time) ORDER BY YEAR(click_time)";
        pstmt = connection.prepareStatement(sqlYearlyClick);
        pstmt.setString(1, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JsonObject c = new JsonObject();
            c.put("year", rs.getString("year"));
            c.put("totalClickYear", rs.getString("clickCnt"));
            yearClickArray.put(c);
        }
        rs.close(); pstmt.close();

        // ====================================================
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

        out.print(data);

    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (connection != null) connectionPool.free(connection);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
