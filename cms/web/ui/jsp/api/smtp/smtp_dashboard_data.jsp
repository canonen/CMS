<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 26.12.2024
  Time: 15:09
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java"
         import="com.britemoon.*,
   com.britemoon.cps.*,
   com.britemoon.cps.imc.*,
   java.io.*,
   java.util.*,
   java.sql.*,
   org.w3c.dom.*,
   org.apache.log4j.*"
%>
<%@ include file="../validator.jsp"%>
<%@ include file="../header.jsp"%>
<%! static Logger logger = null;%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    if(logger == null){
        logger = Logger.getLogger(this.getClass().getName());
    }

    Connection connection = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String sql = null;

    String beginDate = request.getParameter("begin_date");
    String endDate = request.getParameter("end_date");

    // Her iki tarih de dolu değilse hata dön
    if (beginDate == null || beginDate.isEmpty() || endDate == null || endDate.isEmpty()) {
        out.println("{\"error\": \"Başlangıç ve bitiş tarihi gereklidir\"}");
        return;
    }

    beginDate = beginDate + " 00:00:00";
    endDate = endDate + " 23:59:59";

    try {
        final String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        final String urdb = "jdbc:sqlserver://192.168.151.6:1433;databaseName=brite_ainb_500";
        final String dbUser = "revotasadm";
        final String dbPassword = "l3br0nj4m3s";

        connection = DriverManager.getConnection(urdb, dbUser, dbPassword);

        // Dinamik tablo adlarını oluştur (tarih formatını düzelt)
        String startDate = request.getParameter("begin_date"); // yyyy-MM-dd
        String endDateParam = request.getParameter("end_date");  // yyyy-MM-dd

        List<String> tableNames = generateTableNames(connection, startDate, endDateParam, logger);

        JsonArray arr = new JsonArray();

        // Her tablo için sorgu çalıştır
        for (String tableName : tableNames) {
            sql = "SELECT CONVERT(CHAR(10), createdDate, 120) as time_idx,reportType as report_type,count(*) as count " +
                    " FROM brite_ainb_500.dbo." + tableName + " rc (NOLOCK)" +
                    " where custId='" + cust.s_cust_id + "'" +
                    " AND createdDate >= '" + beginDate + "'" +
                    " AND createdDate <= '" + endDate + "'" +
                    " GROUP BY CONVERT(CHAR(10), createdDate, 120),reportType" +
                    " ORDER BY CONVERT(CHAR(10), createdDate, 120) DESC;";

            ps = connection.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                JsonObject obj = new JsonObject();
                obj.put("time", rs.getString("time_idx"));
                obj.put("reportType", rs.getString("report_type") == null ? "UNKNOWN" : rs.getString("report_type"));
                obj.put("count", rs.getString("count"));

                arr.put(obj);
            }

            // Her tablo sorgusu sonrası resources'ları temizle
            if (rs != null) {
                rs.close();
                rs = null;
            }
            if (ps != null) {
                ps.close();
                ps = null;
            }
        }

        out.println(arr.toString());

    } catch (Exception e) {
        logger.error("Error in smtp_dashboard_data.jsp", e);
        out.println("{\"error\": \"" + e.getMessage() + "\"}");
    } finally {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (connection != null) {
                connection.close();
            }
        } catch (Exception ex) {
            logger.error("Error closing resources in smtp_dashboard_data.jsp", ex);
        }
    }
%>

<%!
    public List<String> generateTableNames(Connection connection, String startDate, String endDate, Logger logger) {
        List<String> tableNames = new ArrayList<String>();
        final String TABLE_PREFIX = "mail_pmta_acct";
        final int MIN_YEAR = 2025;

        // Her iki tarih de dolu değilse orijinal tabloya bak
        if (startDate == null || endDate == null || startDate.isEmpty() || endDate.isEmpty()) {
            tableNames.add(TABLE_PREFIX);
            logger.info("Tarih parametresi eksik, orijinal tablo kullanılıyor: " + TABLE_PREFIX);
            return tableNames;
        }

        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date start = dateFormat.parse(startDate);
            java.util.Date end = dateFormat.parse(endDate);

            Calendar startCal = Calendar.getInstance();
            startCal.setTime(start);
            Calendar endCal = Calendar.getInstance();
            endCal.setTime(end);

            List<String> existingTables = getExistingMailPmtaAcctTables(connection, TABLE_PREFIX, MIN_YEAR, logger);
            logger.debug("Veritabanında bulunan 2025+ tablolar: " + existingTables);

            for (String tableName : existingTables) {
                if (isTableInDateRange(tableName, TABLE_PREFIX, startCal, endCal, logger)) {
                    tableNames.add(tableName);
                }
            }

            if (tableNames.isEmpty()) {
                logger.warn("Tarih aralığına uygun tablo bulunamadı, orijinal tablo kullanılacak");
                tableNames.add(TABLE_PREFIX);
            }

        } catch (Exception e) {
            logger.error("Tarih parse edilirken hata oluştu: " + e.getMessage(), e);
            tableNames.add(TABLE_PREFIX);
        }

        logger.info("Sorgulanacak tablolar: " + tableNames);
        return tableNames;
    }

    private List<String> getExistingMailPmtaAcctTables(Connection connection, String tablePrefix, int minYear, Logger logger) {
        List<String> tables = new ArrayList<String>();
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME LIKE '" + tablePrefix + "_' + CAST(" + minYear + " AS VARCHAR) + '%' " +
                    "AND TABLE_TYPE = 'BASE TABLE' " +
                    "AND LEN(TABLE_NAME) = LEN('" + tablePrefix + "_') + 6 " +
                    "ORDER BY TABLE_NAME";

            ps = connection.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                String tableName = rs.getString("TABLE_NAME");
                if (isValidTableFormat(tableName, tablePrefix, minYear, logger)) {
                    tables.add(tableName);
                }
            }

            logger.debug("Veritabanında bulunan geçerli format tablolar: " + tables);

        } catch (Exception e) {
            logger.error("Mevcut tablolar sorgulanırken hata oluştu: " + e.getMessage(), e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (Exception ex) {
                logger.error("Resource kapatılırken hata: " + ex.getMessage());
            }
        }

        return tables;
    }

    private boolean isValidTableFormat(String tableName, String tablePrefix, int minYear, Logger logger) {
        try {
            if (!tableName.startsWith(tablePrefix + "_")) {
                return false;
            }

            String suffix = tableName.substring(tablePrefix.length() + 1);

            if (suffix.length() != 6) {
                return false;
            }

            int yearMonth = Integer.parseInt(suffix);
            int year = yearMonth / 100;
            int month = yearMonth % 100;

            if (year < minYear || month < 1 || month > 12) {
                return false;
            }

            logger.debug("Geçerli tablo formatı: " + tableName + " - Yıl: " + year + ", Ay: " + month);
            return true;

        } catch (NumberFormatException e) {
            logger.debug("Geçersiz tablo formatı (sayı formatı): " + tableName);
            return false;
        } catch (Exception e) {
            logger.debug("Geçersiz tablo formatı: " + tableName + " - " + e.getMessage());
            return false;
        }
    }

    private boolean isTableInDateRange(String tableName, String tablePrefix, Calendar start, Calendar end, Logger logger) {
        try {
            if (tablePrefix.equals(tableName)) {
                return true;
            }

            String suffix = tableName.substring(tablePrefix.length() + 1);

            if (suffix.length() == 6) {
                int yearMonth = Integer.parseInt(suffix);
                int year = yearMonth / 100;
                int month = yearMonth % 100;

                Calendar tableMonth = Calendar.getInstance();
                tableMonth.set(year, month - 1, 1);

                Calendar startMonth = (Calendar) start.clone();
                startMonth.set(Calendar.DAY_OF_MONTH, 1);

                Calendar endMonth = (Calendar) end.clone();
                endMonth.set(Calendar.DAY_OF_MONTH, 1);

                boolean inRange = !tableMonth.before(startMonth) && !tableMonth.after(endMonth);
                logger.debug("Tablo: " + tableName + ", Ay: " + month + "/" + year + ", Dahil mi: " + inRange);

                return inRange;
            }

            logger.warn("Tablo adı beklenen formatta değil: " + tableName);
            return false;

        } catch (Exception e) {
            logger.warn("Tablo adı parse edilirken hata: " + tableName + " - " + e.getMessage());
            return false;
        }
    }
%>
