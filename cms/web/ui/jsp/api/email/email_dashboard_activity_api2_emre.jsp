<%@ page
        language="java"
        import="com.britemoon.cps.*,
            java.sql.*,
            java.util.*,
            java.text.SimpleDateFormat"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.util.Date" %>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%
    String sCustId = user.s_cust_id;
    String date_between = request.getParameter("date_between");

    String oldStart, oldEnd, currentStart, currentEnd;
    long dayDiff;

    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
    Calendar cal = Calendar.getInstance();

    if (date_between == null) {
        // Default: son 7 gün
        currentEnd = fmt.format(new Date());
        cal.add(Calendar.DATE, -7);
        currentStart = fmt.format(cal.getTime());

        oldEnd = currentStart;
        cal.add(Calendar.DATE, -7);
        oldStart = fmt.format(cal.getTime());
        dayDiff = 6;
    } else {
        String[] parts = date_between.split("-");
        currentStart = parts[0].trim().replace("/", "-");
        currentEnd = parts[1].trim().replace("/", "-");

        Date start = fmt.parse(currentStart);
        Date end = fmt.parse(currentEnd);
        dayDiff = (end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000);

        cal.setTime(start);
        cal.add(Calendar.DATE, -(int) dayDiff);
        oldStart = fmt.format(cal.getTime());
        oldEnd = currentStart;
    }

    ConnectionPool pool = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    JsonObject data = new JsonObject();
    JsonArray totalSentArray = new JsonArray();
    JsonArray readClickArray = new JsonArray();
    JsonArray currentDailyArray = new JsonArray();
    JsonArray oldDailyArray = new JsonArray();
    JsonArray dailyOpenArray = new JsonArray();
    JsonArray dailyClickArray = new JsonArray();
    JsonArray monthlySentArray = new JsonArray();
    JsonArray monthlyOpenArray = new JsonArray();
    JsonArray monthlyClickArray = new JsonArray();
    JsonArray yearlySentArray = new JsonArray();
    JsonArray yearlyOpenArray = new JsonArray();
    JsonArray yearlyClickArray = new JsonArray();

    try {
        pool = ConnectionPool.getInstance();
        conn = pool.getConnection(this);

        // ====================================================
        // 1️⃣ Toplam gönderim (current)
        // ====================================================
        String sqlTotal = "SELECT SUM(CAST(rque_count AS BIGINT)) FROM ccps_rque_message WITH(NOLOCK) " +
                "WHERE send_date >= ? AND send_date <= ? AND cust_id = ?";
        pstmt = conn.prepareStatement(sqlTotal);
        pstmt.setString(1, currentStart);
        pstmt.setString(2, currentEnd);
        pstmt.setString(3, sCustId);
        rs = pstmt.executeQuery();
        if (rs.next() && rs.getString(1) != null) totalSentArray.put(rs.getString(1));
        rs.close(); pstmt.close();

        // ====================================================
        // 2️⃣ Açılma ve Tıklama sayıları
        // ====================================================
        String sqlClick = "SELECT " +
                "SUM(CASE WHEN type_id=1 THEN rjtk_count ELSE 0 END) AS openCnt, " +
                "SUM(CASE WHEN type_id=2 THEN rjtk_count ELSE 0 END) AS clickCnt " +
                "FROM ccps_rjtk_link_activity WITH(NOLOCK) " +
                "WHERE click_time >= ? AND click_time <= ? AND cust_id = ?";
        pstmt = conn.prepareStatement(sqlClick);
        pstmt.setString(1, currentStart);
        pstmt.setString(2, currentEnd);
        pstmt.setString(3, sCustId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            JsonObject o = new JsonObject();
            o.put("sReadPrc", rs.getBigDecimal(1) == null ? "0" : rs.getBigDecimal(1));
            o.put("sClickPrc", rs.getBigDecimal(2) == null ? "0" : rs.getBigDecimal(2));
            readClickArray.put(o);
        }
        rs.close(); pstmt.close();

        // ====================================================
        // 3️⃣ Günlük gönderim (current ve old)
        // ====================================================
        String sqlDaily = "SELECT CONVERT(VARCHAR(10), send_date, 120) AS day, SUM(rque_count) AS total " +
                "FROM ccps_rque_message WITH(NOLOCK) WHERE send_date >= ? AND send_date <= ? " +
                "AND cust_id = ? GROUP BY CONVERT(VARCHAR(10), send_date, 120) ORDER BY 1";

        pstmt = conn.prepareStatement(sqlDaily);
        pstmt.setString(1, currentStart);
        pstmt.setString(2, currentEnd);
        pstmt.setString(3, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JsonObject j = new JsonObject();
            j.put("day", rs.getString("day"));
            j.put("currentDailyRqueCount", rs.getString("total"));
            currentDailyArray.put(j);
        }
        rs.close(); pstmt.close();

        pstmt = conn.prepareStatement(sqlDaily);
        pstmt.setString(1, oldStart);
        pstmt.setString(2, oldEnd);
        pstmt.setString(3, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JsonObject j = new JsonObject();
            j.put("day", rs.getString("day"));
            j.put("oldDailyRqueCount", rs.getString("total"));
            oldDailyArray.put(j);
        }
        rs.close(); pstmt.close();

        // ====================================================
        // 4️⃣ Günlük Open / Click
        // ====================================================
        String sqlDailyClick = "SELECT DAY(click_time) AS day, " +
                "SUM(CASE WHEN type_id=1 THEN rjtk_count ELSE 0 END) AS openCnt, " +
                "SUM(CASE WHEN type_id=2 THEN rjtk_count ELSE 0 END) AS clickCnt " +
                "FROM ccps_rjtk_link_activity WITH(NOLOCK) " +
                "WHERE click_time >= ? AND click_time <= ? AND cust_id = ? " +
                "GROUP BY DAY(click_time) ORDER BY 1";
        pstmt = conn.prepareStatement(sqlDailyClick);
        pstmt.setString(1, currentStart);
        pstmt.setString(2, currentEnd);
        pstmt.setString(3, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            if (rs.getString("openCnt") != null) {
                JsonObject j = new JsonObject();
                j.put("day", rs.getString("day"));
                j.put("totalOpen", rs.getString("openCnt"));
                dailyOpenArray.put(j);
            }
            if (rs.getString("clickCnt") != null) {
                JsonObject j = new JsonObject();
                j.put("day", rs.getString("day"));
                j.put("click", rs.getString("clickCnt"));
                dailyClickArray.put(j);
            }
        }
        rs.close(); pstmt.close();

        // ====================================================
        // 5️⃣ Aylık ve Yıllık istatistikler
        // ====================================================
        String sqlMonthly = "SELECT MONTH(send_date) AS month, SUM(rque_count) AS total " +
                "FROM ccps_rque_message WITH(NOLOCK) WHERE YEAR(send_date)=YEAR(GETDATE()) " +
                "AND cust_id = ? GROUP BY MONTH(send_date) ORDER BY 1";
        pstmt = conn.prepareStatement(sqlMonthly);
        pstmt.setString(1, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JsonObject j = new JsonObject();
            j.put("month", rs.getString("month"));
            j.put("monthlyValue", rs.getString("total"));
            monthlySentArray.put(j);
        }
        rs.close(); pstmt.close();

        String sqlYearly = "SELECT YEAR(send_date) AS year, SUM(rque_count) AS total " +
                "FROM ccps_rque_message WITH(NOLOCK) WHERE cust_id=? GROUP BY YEAR(send_date) ORDER BY 1";
        pstmt = conn.prepareStatement(sqlYearly);
        pstmt.setString(1, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JsonObject j = new JsonObject();
            j.put("year", rs.getString("year"));
            j.put("totalRecipient", rs.getString("total"));
            yearlySentArray.put(j);
        }
        rs.close(); pstmt.close();

        String sqlYearlyOpen = "SELECT YEAR(click_time) AS year, " +
                "SUM(CASE WHEN type_id=1 THEN rjtk_count ELSE 0 END) AS openCnt, " +
                "SUM(CASE WHEN type_id=2 THEN rjtk_count ELSE 0 END) AS clickCnt " +
                "FROM ccps_rjtk_link_activity WITH(NOLOCK) WHERE cust_id = ? " +
                "GROUP BY YEAR(click_time) ORDER BY 1";
        pstmt = conn.prepareStatement(sqlYearlyOpen);
        pstmt.setString(1, sCustId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JsonObject open = new JsonObject();
            open.put("year", rs.getString("year"));
            open.put("totalYearCount", rs.getString("openCnt"));
            yearlyOpenArray.put(open);

            JsonObject click = new JsonObject();
            click.put("year", rs.getString("year"));
            click.put("totalClickYear", rs.getString("clickCnt"));
            yearlyClickArray.put(click);
        }
        rs.close(); pstmt.close();

        // ====================================================
        // JSON output
        // ====================================================
        data.put("totalSent", totalSentArray);
        data.put("readAndClickAndBbackArray", readClickArray);
        data.put("currentSent", currentDailyArray);
        data.put("oldSent", oldDailyArray);
        data.put("open", dailyOpenArray);
        data.put("click", dailyClickArray);
        data.put("monthlyRqueCountArray", monthlySentArray);
        data.put("monthlyOpenArray", monthlyOpenArray);
        data.put("monthlyClickTimeArray", monthlyClickArray);
        data.put("yearsTotalRecipientArray", yearlySentArray);
        data.put("yearOpenArray", yearlyOpenArray);
        data.put("yearClickArray", yearlyClickArray);

        out.print(data);

    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in compare stats JSP", out, 1);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) pool.free(conn);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

%>
