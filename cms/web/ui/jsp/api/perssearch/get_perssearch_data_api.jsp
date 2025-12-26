<%@  page language="java"
          import="java.net.*,
                  com.britemoon.*,
                  java.sql.*,
                  com.britemoon.cps.*,
                  java.util.Calendar,
                  java.util.Date,
                  java.io.*,
                  java.math.BigDecimal,
                  java.text.DecimalFormat,
                  java.text.NumberFormat,
                  java.util.Locale,
                  java.util.*,
                  org.apache.log4j.Logger,
                  org.w3c.dom.*"
%>

<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>

<%!
    static Logger logger = null;

    // Static formatters - Java 6/7 compatible
    private static final SimpleDateFormat SQL_DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static final SimpleDateFormat DISPLAY_DATE_FORMAT = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    private static final DecimalFormat FORMATTER = new DecimalFormat("###,###");
    private static final DecimalFormat FORMATTER2 = new DecimalFormat("#,###.## TL");

    // Optimized formatters
    private String formatDateForSQL(Date date) {
        synchronized(SQL_DATE_FORMAT) {
            return SQL_DATE_FORMAT.format(date);
        }
    }

    private String formatDate(Date date) {
        synchronized(DISPLAY_DATE_FORMAT) {
            return DISPLAY_DATE_FORMAT.format(date);
        }
    }

    // Ultra-fast Turkish character replacement
    private String fixTurkishCharacters(String input) {
        if (input == null) return null;
        if (input.indexOf('Ã') == -1 && input.indexOf('Ä') == -1 && input.indexOf('Å') == -1) {
            return input; // No Turkish chars to fix
        }
        return input.replace("Ã„Â±", "ı").replace("Ã„Â°", "İ").replace("Ã„ÂŸ", "ğ")
                   .replace("Ã„Âž", "Ğ").replace("Ã…ÅŸ", "ş").replace("Ã…Åž", "Ş")
                   .replace("ÃƒÂ¼", "ü").replace("ÃƒÂœ", "Ü").replace("ÃƒÂ§", "ç")
                   .replace("ÃƒÂ‡", "Ç").replace("ÃƒÂ¶", "ö").replace("ÃƒÂ–", "Ö")
                   .replace("Ä±", "ı").replace("Ä°", "İ").replace("ÄŸ", "ğ")
                   .replace("Äž", "Ğ").replace("ÅŸ", "ş").replace("Åž", "Ş")
                   .replace("Ã¼", "ü").replace("Ãœ", "Ü").replace("Ã§", "ç")
                   .replace("Ã‡", "Ç").replace("Ã¶", "ö").replace("Ã–", "Ö");
    }
%>

<%
    long totalStartTime = System.currentTimeMillis();

    if(logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    String date_between = request.getParameter("date_between");
    String search_keyword = request.getParameter("search_keyword");
    if (search_keyword == null) search_keyword = "";

    // Fast date calculations
    String oldValueStartDate = null;
    String oldValueEndDate = null;
    String currentValueStartDate = null;
    String currentValueEndDate = null;
    long dayDifference = 0;

    try {
        if (date_between == null) {
            Calendar calendar = Calendar.getInstance();
            Date currentDate = new Date();
            calendar.setTime(currentDate);

            currentValueEndDate = formatDate(currentDate);
            calendar.add(Calendar.DATE, -7);
            currentValueStartDate = formatDate(calendar.getTime());

            oldValueEndDate = formatDate(calendar.getTime());
            calendar.add(Calendar.DATE, -7);
            oldValueStartDate = formatDate(calendar.getTime());
            dayDifference = 6;
        } else {
            String[] parts = date_between.split("-");
            currentValueStartDate = parts[0].trim() + " 00:00:00";
            currentValueEndDate = parts[1].trim() + " 23:59:59";

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
            Date startDate = dateFormat.parse(currentValueStartDate);
            Date endDate = dateFormat.parse(currentValueEndDate);

            dayDifference = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);

            Calendar calendar = Calendar.getInstance();
            calendar.setTime(startDate);
            calendar.add(Calendar.DATE, -(int) dayDifference);
            oldValueStartDate = formatDate(calendar.getTime()) + " 00:00:00";
            oldValueEndDate = currentValueStartDate.replace("00:00:00", "23:59:59");
        }
    } catch (Exception e) {
        logger.error("Date parsing error", e);
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("{\"error\":\"Invalid date format\"}");
        return;
    }

    // Database connection
    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        // Convert dates to SQL format once
        String currentStartSQL = formatDateForSQL(new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse(currentValueStartDate));
        String currentEndSQL = formatDateForSQL(new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse(currentValueEndDate));
        String oldStartSQL = formatDateForSQL(new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse(oldValueStartDate));
        String oldEndSQL = formatDateForSQL(new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse(oldValueEndDate));

        // Use StringBuilder for fast JSON building
        StringBuilder jsonResponse = new StringBuilder(4096);
        jsonResponse.append("{");

        // === OPTIMIZED APPROACH: Single base query for all data ===
        // Data structures for in-memory processing
        Map<String, Integer> currentKeywordCounts = new HashMap<String, Integer>();
        Map<String, Integer> currentKeywordConversions = new HashMap<String, Integer>();
        Map<String, Double> currentKeywordRevenues = new HashMap<String, Double>();
        Map<String, Integer> oldKeywordCounts = new HashMap<String, Integer>();
        Map<String, Integer> oldKeywordConversions = new HashMap<String, Integer>();
        Map<String, Double> oldKeywordRevenues = new HashMap<String, Double>();
        
        // Additional maps for failed searches and result tracking
        Map<String, Boolean> currentKeywordHasResults = new HashMap<String, Boolean>();
        Map<String, Boolean> oldKeywordHasResults = new HashMap<String, Boolean>();
        Map<String, Integer> currentFailedCounts = new HashMap<String, Integer>();
        Map<String, Integer> oldFailedCounts = new HashMap<String, Integer>();

        int currentTotalCount = 0, currentTotalConversion = 0, oldTotalCount = 0, oldTotalConversion = 0;
        double currentTotalRevenue = 0.0, oldTotalRevenue = 0.0;

        // Base query to retrieve all data for both periods - enhanced with search_result_count
        String baseSQL = "SELECT search_keyword, " +
                        "SUM(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) THEN count ELSE 0 END) as current_count, " +
                        "SUM(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) THEN conversion ELSE 0 END) as current_conversion, " +
                        "SUM(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) THEN revenue ELSE 0 END) as current_revenue, " +
                        "SUM(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) THEN count ELSE 0 END) as old_count, " +
                        "SUM(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) THEN conversion ELSE 0 END) as old_conversion, " +
                        "SUM(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) THEN revenue ELSE 0 END) as old_revenue, " +
                        "MAX(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) AND search_result_count > 0 THEN 1 ELSE 0 END) as current_has_results, " +
                        "MAX(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) AND search_result_count > 0 THEN 1 ELSE 0 END) as old_has_results, " +
                        "SUM(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) AND search_result_count = 0 THEN count ELSE 0 END) as current_failed_count, " +
                        "SUM(CASE WHEN activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME) AND search_result_count = 0 THEN count ELSE 0 END) as old_failed_count " +
                        "FROM ccps_pers_search_activity_day WITH(NOLOCK) " +
                        "WHERE cust_id = ? AND ((activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME)) " +
                        "OR (activity_date >= CAST(? AS DATETIME) AND activity_date <= CAST(? AS DATETIME))) " +
                        "GROUP BY search_keyword";

        pstmt = conn.prepareStatement(baseSQL);
        pstmt.setString(1, currentStartSQL);
        pstmt.setString(2, currentEndSQL);
        pstmt.setString(3, currentStartSQL);
        pstmt.setString(4, currentEndSQL);
        pstmt.setString(5, currentStartSQL);
        pstmt.setString(6, currentEndSQL);
        pstmt.setString(7, oldStartSQL);
        pstmt.setString(8, oldEndSQL);
        pstmt.setString(9, oldStartSQL);
        pstmt.setString(10, oldEndSQL);
        pstmt.setString(11, oldStartSQL);
        pstmt.setString(12, oldEndSQL);
        pstmt.setString(13, currentStartSQL);
        pstmt.setString(14, currentEndSQL);
        pstmt.setString(15, oldStartSQL);
        pstmt.setString(16, oldEndSQL);
        pstmt.setString(17, currentStartSQL);
        pstmt.setString(18, currentEndSQL);
        pstmt.setString(19, oldStartSQL);
        pstmt.setString(20, oldEndSQL);
        pstmt.setString(21, cust.s_cust_id);
        pstmt.setString(22, currentStartSQL);
        pstmt.setString(23, currentEndSQL);
        pstmt.setString(24, oldStartSQL);
        pstmt.setString(25, oldEndSQL);
        rs = pstmt.executeQuery();

        // Process base data and populate maps
        while (rs.next()) {
            String keyword = rs.getString("search_keyword");
            if (keyword == null) keyword = "";
            
            int currentCount = rs.getInt("current_count");
            int currentConversion = rs.getInt("current_conversion");
            double currentRevenue = rs.getDouble("current_revenue");
            int oldCount = rs.getInt("old_count");
            int oldConversion = rs.getInt("old_conversion");
            double oldRevenue = rs.getDouble("old_revenue");
            
            // Enhanced data for failed searches and result tracking
            boolean currentHasResults = rs.getInt("current_has_results") > 0;
            boolean oldHasResults = rs.getInt("old_has_results") > 0;
            int currentFailedCount = rs.getInt("current_failed_count");
            int oldFailedCount = rs.getInt("old_failed_count");
            
            if (currentCount > 0) {
                currentKeywordCounts.put(keyword, currentCount);
                currentKeywordConversions.put(keyword, currentConversion);
                currentKeywordRevenues.put(keyword, currentRevenue);
                currentTotalCount += currentCount;
                currentTotalConversion += currentConversion;
                currentTotalRevenue += currentRevenue;
            }
            
            if (oldCount > 0) {
                oldKeywordCounts.put(keyword, oldCount);
                oldKeywordConversions.put(keyword, oldConversion);
                oldKeywordRevenues.put(keyword, oldRevenue);
                oldTotalCount += oldCount;
                oldTotalConversion += oldConversion;
                oldTotalRevenue += oldRevenue;
            }
            
            // Store additional tracking data
            currentKeywordHasResults.put(keyword, currentHasResults);
            oldKeywordHasResults.put(keyword, oldHasResults);
            if (currentFailedCount > 0) {
                currentFailedCounts.put(keyword, currentFailedCount);
            }
            if (oldFailedCount > 0) {
                oldFailedCounts.put(keyword, oldFailedCount);
            }
        }
        rs.close();
        pstmt.close();

        // Helper class for sorting
        class KeywordData {
            String keyword;
            int count;
            int conversion;
            double revenue;
            
            KeywordData(String keyword, int count, int conversion, double revenue) {
                this.keyword = keyword;
                this.count = count;
                this.conversion = conversion;
                this.revenue = revenue;
            }
        }

        // === CURRENT STATISTICS ===
        jsonResponse.append("\"currentStatistics\":[");
        jsonResponse.append("{")
                   .append("\"total_count\":").append(currentTotalCount).append(",")
                   .append("\"total_conversion\":").append(currentTotalConversion).append(",")
                   .append("\"total_revenue\":").append(currentTotalRevenue)
                   .append("}");
        jsonResponse.append("],");

        // === OLD STATISTICS ===
        jsonResponse.append("\"oldStatistics\":[");
        jsonResponse.append("{")
                   .append("\"total_count\":").append(oldTotalCount).append(",")
                   .append("\"total_conversion\":").append(oldTotalConversion).append(",")
                   .append("\"total_revenue\":").append(oldTotalRevenue)
                   .append("}");
        jsonResponse.append("],");

        // === OLD POPULAR QUERIES ===
        List<KeywordData> oldPopularList = new ArrayList<KeywordData>();
        for (Map.Entry<String, Integer> entry : oldKeywordCounts.entrySet()) {
            String keyword = entry.getKey();
            int count = entry.getValue();
            int conversion = oldKeywordConversions.getOrDefault(keyword, 0);
            oldPopularList.add(new KeywordData(keyword, count, conversion, 0.0));
        }
        Collections.sort(oldPopularList, new Comparator<KeywordData>() {
            public int compare(KeywordData a, KeywordData b) {
                return Integer.compare(b.count, a.count);
            }
        });

        jsonResponse.append("\"oldPopularQueries\":[");
        boolean firstOldPop = true;
        for (int i = 0; i < Math.min(30, oldPopularList.size()); i++) {  // Match original TOP 30
            if (!firstOldPop) jsonResponse.append(",");
            KeywordData data = oldPopularList.get(i);
            jsonResponse.append("{")
                       .append("\"search_keyword\":\"").append(fixTurkishCharacters(data.keyword.replace("\"", "\\\""))).append("\",")
                       .append("\"total_count\":").append(data.count).append(",")  // Match original: no quotes, no formatting
                       .append("\"total_conversion\":").append(data.conversion)
                       .append("}");
            firstOldPop = false;
        }
        jsonResponse.append("],");

        // === CURRENT TOP PERFORMING QUERIES ===
        List<KeywordData> currentPerformingList = new ArrayList<KeywordData>();
        for (Map.Entry<String, Double> entry : currentKeywordRevenues.entrySet()) {
            String keyword = entry.getKey();
            double revenue = entry.getValue();
            if (revenue > 0) {  // Match original: HAVING SUM(revenue) <> 0
                int count = currentKeywordCounts.getOrDefault(keyword, 0);
                int conversion = currentKeywordConversions.getOrDefault(keyword, 0);
                currentPerformingList.add(new KeywordData(keyword, count, conversion, revenue));
            }
        }
        Collections.sort(currentPerformingList, new Comparator<KeywordData>() {
            public int compare(KeywordData a, KeywordData b) {
                return Integer.compare(b.count, a.count);  // Match original: ORDER BY total_count DESC
            }
        });

        jsonResponse.append("\"currentTopPerformingQueries\":[");
        boolean firstCurrPerf = true;
        for (int i = 0; i < Math.min(30, currentPerformingList.size()); i++) {  // Match original TOP 30
            if (!firstCurrPerf) jsonResponse.append(",");
            KeywordData data = currentPerformingList.get(i);
            jsonResponse.append("{")
                       .append("\"search_keyword\":\"").append(fixTurkishCharacters(data.keyword.replace("\"", "\\\""))).append("\",")
                       .append("\"total_count\":\"").append(FORMATTER.format(data.count)).append("\",")
                       .append("\"total_revenue\":\"").append(FORMATTER2.format(data.revenue)).append("\"")  // Match original output
                       .append("}");
            firstCurrPerf = false;
        }
        jsonResponse.append("],");

        // === CURRENT POPULAR QUERIES ===
        List<KeywordData> currentPopularList = new ArrayList<KeywordData>();
        for (Map.Entry<String, Integer> entry : currentKeywordCounts.entrySet()) {
            String keyword = entry.getKey();
            int count = entry.getValue();
            int conversion = currentKeywordConversions.getOrDefault(keyword, 0);
            currentPopularList.add(new KeywordData(keyword, count, conversion, 0.0));
        }
        Collections.sort(currentPopularList, new Comparator<KeywordData>() {
            public int compare(KeywordData a, KeywordData b) {
                return Integer.compare(b.count, a.count);
            }
        });

        jsonResponse.append("\"currentPopularQueries\":[");
        boolean firstCurrPop = true;
        for (int i = 0; i < Math.min(30, currentPopularList.size()); i++) {  // Match original TOP 30
            if (!firstCurrPop) jsonResponse.append(",");
            KeywordData data = currentPopularList.get(i);
            jsonResponse.append("{")
                       .append("\"search_keyword\":\"").append(fixTurkishCharacters(data.keyword.replace("\"", "\\\""))).append("\",")
                       .append("\"total_count\":\"").append(FORMATTER.format(data.count)).append("\",")
                       .append("\"total_conversion\":").append(data.conversion)
                       .append("}");
            firstCurrPop = false;
        }
        jsonResponse.append("],");

        // === OLD TOP PERFORMING QUERIES ===
        List<KeywordData> oldPerformingList = new ArrayList<KeywordData>();
        for (Map.Entry<String, Double> entry : oldKeywordRevenues.entrySet()) {
            String keyword = entry.getKey();
            double revenue = entry.getValue();
            if (revenue > 0) {  // Match original: HAVING SUM(revenue) <> 0
                int count = oldKeywordCounts.getOrDefault(keyword, 0);
                int conversion = oldKeywordConversions.getOrDefault(keyword, 0);
                oldPerformingList.add(new KeywordData(keyword, count, conversion, revenue));
            }
        }
        Collections.sort(oldPerformingList, new Comparator<KeywordData>() {
            public int compare(KeywordData a, KeywordData b) {
                return Integer.compare(b.count, a.count);  // Match original: ORDER BY total_count DESC
            }
        });

        jsonResponse.append("\"oldTopPerformingQueries\":[");
        boolean firstOldPerf = true;
        for (int i = 0; i < Math.min(30, oldPerformingList.size()); i++) {  // Match original TOP 30
            if (!firstOldPerf) jsonResponse.append(",");
            KeywordData data = oldPerformingList.get(i);
            jsonResponse.append("{")
                       .append("\"search_keyword\":\"").append(fixTurkishCharacters(data.keyword.replace("\"", "\\\""))).append("\",")
                       .append("\"total_count\":\"").append(FORMATTER.format(data.count)).append("\",")
                       .append("\"total_revenue\":\"").append(FORMATTER2.format(data.revenue)).append("\"")  // Match original output
                       .append("}");
            firstOldPerf = false;
        }
        jsonResponse.append("],");

        // === OLD QUERIES WITHOUT PURCHASES ===
        List<KeywordData> oldNoPurchaseList = new ArrayList<KeywordData>();
        for (Map.Entry<String, Integer> entry : oldKeywordCounts.entrySet()) {
            String keyword = entry.getKey();
            int count = entry.getValue();
            int conversion = oldKeywordConversions.getOrDefault(keyword, 0);
            if (conversion == 0) {
                oldNoPurchaseList.add(new KeywordData(keyword, count, conversion, 0.0));
            }
        }
        Collections.sort(oldNoPurchaseList, new Comparator<KeywordData>() {
            public int compare(KeywordData a, KeywordData b) {
                return Integer.compare(b.count, a.count);
            }
        });

        jsonResponse.append("\"oldQueriesWithoutPurchases\":[");
        boolean firstOldNo = true;
        for (int i = 0; i < Math.min(30, oldNoPurchaseList.size()); i++) {  // Match original TOP 30
            if (!firstOldNo) jsonResponse.append(",");
            KeywordData data = oldNoPurchaseList.get(i);
            jsonResponse.append("{")
                       .append("\"search_keyword\":\"").append(fixTurkishCharacters(data.keyword.replace("\"", "\\\""))).append("\",")
                       .append("\"total_count\":").append(data.count)  // Match original: no quotes, no formatting
                       .append("}");
            firstOldNo = false;
        }
        jsonResponse.append("],");

        // === OLD FAILED SEARCH QUERIES ===
        List<KeywordData> oldFailedList = new ArrayList<KeywordData>();
        for (Map.Entry<String, Integer> entry : oldFailedCounts.entrySet()) {
            String keyword = entry.getKey();
            int failedCount = entry.getValue();
            // Only include keywords that don't have successful results (search_result_count > 0)
            if (failedCount > 0 && !oldKeywordHasResults.getOrDefault(keyword, false)) {
                oldFailedList.add(new KeywordData(keyword, failedCount, 0, 0.0));
            }
        }
        Collections.sort(oldFailedList, new Comparator<KeywordData>() {
            public int compare(KeywordData a, KeywordData b) {
                return Integer.compare(b.count, a.count);
            }
        });

        jsonResponse.append("\"oldFailedSearchQueries\":[");
        boolean firstOldFail = true;
        for (int i = 0; i < Math.min(30, oldFailedList.size()); i++) {  // Match original TOP 30
            if (!firstOldFail) jsonResponse.append(",");
            KeywordData data = oldFailedList.get(i);
            jsonResponse.append("{")
                       .append("\"search_keyword\":\"").append(fixTurkishCharacters(data.keyword.replace("\"", "\\\""))).append("\",")
                       .append("\"total_count\":\"").append(FORMATTER.format(data.count)).append("\"")
                       .append("}");
            firstOldFail = false;
        }
        jsonResponse.append("],");

        // === CURRENT TOP QUERIES WITHOUT PURCHASES ===
        List<KeywordData> currentNoPurchaseList = new ArrayList<KeywordData>();
        for (Map.Entry<String, Integer> entry : currentKeywordCounts.entrySet()) {
            String keyword = entry.getKey();
            int count = entry.getValue();
            int conversion = currentKeywordConversions.getOrDefault(keyword, 0);
            if (conversion == 0) {
                currentNoPurchaseList.add(new KeywordData(keyword, count, conversion, 0.0));
            }
        }
        Collections.sort(currentNoPurchaseList, new Comparator<KeywordData>() {
            public int compare(KeywordData a, KeywordData b) {
                return Integer.compare(b.count, a.count);
            }
        });

        jsonResponse.append("\"currentTopQueriesWithoutPurchases\":[");
        boolean firstCurrNo = true;
        for (int i = 0; i < Math.min(30, currentNoPurchaseList.size()); i++) {  // Match original TOP 30
            if (!firstCurrNo) jsonResponse.append(",");
            KeywordData data = currentNoPurchaseList.get(i);
            jsonResponse.append("{")
                       .append("\"search_keyword\":\"").append(fixTurkishCharacters(data.keyword.replace("\"", "\\\""))).append("\",")
                       .append("\"total_count\":\"").append(FORMATTER.format(data.count)).append("\"")
                       .append("}");
            firstCurrNo = false;
        }
        jsonResponse.append("],");

        // === CURRENT FAILED SEARCH QUERIES ===
        List<KeywordData> currentFailedList = new ArrayList<KeywordData>();
        for (Map.Entry<String, Integer> entry : currentFailedCounts.entrySet()) {
            String keyword = entry.getKey();
            int failedCount = entry.getValue();
            // Only include keywords that don't have successful results (search_result_count > 0)
            if (failedCount > 0 && !currentKeywordHasResults.getOrDefault(keyword, false)) {
                currentFailedList.add(new KeywordData(keyword, failedCount, 0, 0.0));
            }
        }
        Collections.sort(currentFailedList, new Comparator<KeywordData>() {
            public int compare(KeywordData a, KeywordData b) {
                return Integer.compare(b.count, a.count);
            }
        });

        jsonResponse.append("\"currentFailedSearchQueries\":[");
        boolean firstCurrFail = true;
        for (int i = 0; i < Math.min(30, currentFailedList.size()); i++) {  // Match original TOP 30
            if (!firstCurrFail) jsonResponse.append(",");
            KeywordData data = currentFailedList.get(i);
            jsonResponse.append("{")
                       .append("\"search_keyword\":\"").append(fixTurkishCharacters(data.keyword.replace("\"", "\\\""))).append("\",")
                       .append("\"total_count\":\"").append(FORMATTER.format(data.count)).append("\"")
                       .append("}");
            firstCurrFail = false;
        }
        jsonResponse.append("]");

        jsonResponse.append("}");

        // Output result
        out.print(jsonResponse.toString());

    } catch (Exception e) {
        logger.error("Database error in get_perssearch_data_api", e);
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("{\"error\":\"Database error occurred\",\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) {
                logger.error("ResultSet close error", e);
            }
        }
        if (pstmt != null) {
            try { pstmt.close(); } catch (SQLException e) {
                logger.error("PreparedStatement close error", e);
            }
        }
        if (conn != null) {
            try {
                cp.free(conn);
            } catch (Exception e) {
                logger.error("Connection return error", e);
            }
        }
    }

    long totalEndTime = System.currentTimeMillis();
    logger.info("Total processing time: " + (totalEndTime - totalStartTime) + "ms for customer: " + cust.s_cust_id);
%>