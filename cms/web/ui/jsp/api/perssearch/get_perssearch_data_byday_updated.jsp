<%@ page language="java"
         import="java.net.*,
                 com.britemoon.*,
                 com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                 java.sql.*,
                 java.util.Calendar,
                 java.util.Date,
                 java.io.*,
                 java.math.BigDecimal,
                 java.text.NumberFormat,
                 java.util.Locale,
                 java.util.*,
                 java.io.*,
                 org.apache.log4j.Logger,
                 org.w3c.dom.*"
         contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.britemoon.cps.ConnectionPool" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%
    String date_between = request.getParameter("date_between");
    String oldValueStartDate = null;
    String oldValueEndDate = null;
    String currentValueStartDate = null;
    String currentValueEndDate = null;
    int total_count = 0;
    int total_conversion = 0;
    double total_revenue = 0.0;

    if (date_between == null) {
        // date_between parametresi belirtilmediğinde
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(new Date());

        // currentValue tarih aralığı (bugün - 7 gün öncesi)
        currentValueEndDate = formatDate(calendar.getTime()); // Bugünün tarihi
        calendar.add(Calendar.DATE, -7); // 7 gün öncesine git
        currentValueStartDate = formatDate(calendar.getTime()); // 7 gün önceki tarih

        // oldValue tarih aralığı (currentValueStartDate - 7 gün öncesi)
        oldValueEndDate = formatDate(calendar.getTime()); // 7 gün önceki tarih
        calendar.add(Calendar.DATE, -7); // 14 gün öncesine git
        oldValueStartDate = formatDate(calendar.getTime()); // 14 gün önceki tarih

    } else {
        // date_between parametresi belirtildiğinde
        String[] parts = date_between.split("-");
        currentValueStartDate = parts[0].trim();
        currentValueEndDate = parts[1].trim();

        // Date aralıklarını hesapla
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
        Date startDate = dateFormat.parse(currentValueStartDate);
        Date endDate = dateFormat.parse(currentValueEndDate);

        // Gün farkını hesapla
        long dayDifference = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);

        // oldValue tarih aralığını hesapla
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(startDate);
        calendar.add(Calendar.DATE, -(int) dayDifference);
        oldValueStartDate = formatDate(calendar.getTime()); // currentValueStartDate'dan gün farkı kadar önceki tarih
        oldValueEndDate = currentValueStartDate; // oldValueEndDate her zaman currentValueStartDate'a eşit olmalı
    }

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;


    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        JsonObject resultObject = new JsonObject();
        JsonArray currentDataArray = new JsonArray();
        JsonObject currentDataObject = new JsonObject();
        JsonArray oldDataArray = new JsonArray();
        JsonObject oldDataObject = new JsonObject();

        String sql = "SELECT CONVERT(CHAR(10), activity_date, 120) AS date, SUM(count) AS total_count, SUM(conversion) AS total_conversion, SUM(revenue) AS total_revenue " +
                "FROM ccps_pers_search_activity_day WITH (NOLOCK) " +
                "WHERE cust_id = ? AND activity_date >= ? AND activity_date <= ? " +
                "GROUP BY CONVERT(CHAR(10), activity_date, 120) ORDER BY date";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1,cust.s_cust_id);
        pstmt.setString(2, currentValueStartDate + " 00:00:00"); 
        pstmt.setString(3, currentValueEndDate + " 23:59:59");
        rs = pstmt.executeQuery();

        while (rs.next()) {
            currentDataObject = new JsonObject();
            total_count = rs.getInt("total_count");
            total_conversion = rs.getInt("total_conversion");
            total_revenue = rs.getDouble("total_revenue");
            currentDataObject.put("date", rs.getString("date"));
            currentDataObject.put("total_count", total_count);
            currentDataObject.put("total_conversion", total_conversion);
            currentDataObject.put("total_revenue", total_revenue);
            currentDataArray.put(currentDataObject);
        }

        resultObject.put("currentValue", currentDataArray);
        rs.close();
        pstmt.close();

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1,cust.s_cust_id);
        pstmt.setString(2, oldValueStartDate + " 00:00:00");
        pstmt.setString(3, oldValueEndDate + " 23:59:59");
        rs = pstmt.executeQuery();


        while (rs.next()) {
            oldDataObject = new JsonObject();
            total_count = rs.getInt("total_count");
            total_conversion = rs.getInt("total_conversion");
            total_revenue = rs.getDouble("total_revenue");
            oldDataObject.put("date", rs.getString("date"));
            oldDataObject.put("total_count", total_count);
            oldDataObject.put("total_conversion", total_conversion);
            oldDataObject.put("total_revenue", total_revenue);
            oldDataArray.put(oldDataObject);
        }

        rs.close();
        resultObject.put("oldValue", oldDataArray);
        out.println(resultObject);

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null)
                rs.close();
            if (pstmt != null)
                pstmt.close();
            if (conn != null)
                conn.close();
        } catch (SQLException sqle) {
            sqle.printStackTrace();
        }
    }
%>
<%!
    public String formatDate(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1; // Ay değeri 0-11 aralığında olduğu için 1 ekliyoruz
        int day = calendar.get(Calendar.DAY_OF_MONTH);

        return String.format("%04d-%02d-%02d", year, month, day);
    }
%>
