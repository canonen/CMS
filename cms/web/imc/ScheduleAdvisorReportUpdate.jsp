<%@ page language="java"
         import="com.britemoon.cps.*,
            javax.xml.parsers.*,
            java.util.*,
            java.sql.*,
            java.io.*,
            org.w3c.dom.*,
            org.xml.sax.InputSource,
            org.apache.log4j.Logger"
         contentType="text/html;charset=UTF-8"
%>

<%! static Logger logger = Logger.getLogger("ScheduleAdvisorReport"); %>

<%!
    public class ScheduleAdvisorReport {

        private final Connection connection;
        private final Map<String, String> SQL_CACHE = createSqlCache();

        public ScheduleAdvisorReport(Connection connection) {
            this.connection = connection;
        }

        private Map<String,String> createSqlCache() {
            Map<String,String> cache = new HashMap<String,String>();
            cache.put("DELETE_REPORT", "DELETE FROM ccps_schedule_advisor_report WHERE cust_id = ?");
            cache.put("INSERT_REPORT", "INSERT INTO ccps_schedule_advisor_report (cust_id,hours,opens1,clicks,pct) VALUES (?,?,?,?,?)");

            cache.put("DELETE_DAY", "DELETE FROM ccps_schedule_advisor_day_report WHERE cust_id = ?");
            cache.put("INSERT_DAY", "INSERT INTO ccps_schedule_advisor_day_report (cust_id,opens,days,days_num) VALUES (?,?,?,?)");

            cache.put("DELETE_WEEK", "DELETE FROM ccps_schedule_advisor_week_report WHERE cust_id = ?");
            cache.put("INSERT_WEEK", "INSERT INTO ccps_schedule_advisor_week_report (cust_id,week,hour,\"open\",click) VALUES (?,?,?,?,?)");
            return cache;
        }

        private String getVal(Element el, String tag) {
            NodeList n = el.getElementsByTagName(tag);
            return (n.getLength() > 0 && n.item(0).getFirstChild() != null) ? n.item(0).getTextContent().trim() : null;
        }

        private String nullIfEmpty(String v) {
            return (v == null || v.trim().isEmpty() || "null".equalsIgnoreCase(v)) ? null : v;
        }

        private Map<String,List<String[]>> groupByCustId(List<String[]> list) {
            Map<String,List<String[]>> grouped = new HashMap<String,List<String[]>>();
            for (String[] r : list) {
                String custId = r[0];
                if (custId != null && !"null".equalsIgnoreCase(custId)) {
                    if (!grouped.containsKey(custId)) grouped.put(custId,new ArrayList<String[]>());
                    grouped.get(custId).add(r);
                }
            }
            return grouped;
        }

        private void saveBatch(List<String[]> records, String deleteSql, String insertSql, String custId) throws Exception {
            PreparedStatement deleteStmt = null;
            PreparedStatement insertStmt = null;
            try {
                deleteStmt = connection.prepareStatement(deleteSql);
                deleteStmt.setString(1, custId);
                deleteStmt.executeUpdate();

                insertStmt = connection.prepareStatement(insertSql);
                for (String[] r : records) {
                    for (int i=0; i<r.length; i++) {
                        insertStmt.setString(i+1, nullIfEmpty(r[i]));
                    }
                    insertStmt.addBatch();
                }
                insertStmt.executeBatch();
                logger.info("Batch insert -> " + custId + " kayıt sayısı: " + records.size());

            } finally {
                if (deleteStmt != null) try { deleteStmt.close(); } catch (Exception ignore) {}
                if (insertStmt != null) try { insertStmt.close(); } catch (Exception ignore) {}
            }
        }

        // Ana rapor
        public void processReport(NodeList nodes) throws Exception {
            List<String[]> records = new ArrayList<String[]>();
            for (int i=0; i<nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                records.add(new String[]{
                        getVal(el,"cust_id"),
                        getVal(el,"hours"),
                        getVal(el,"opens1"),
                        getVal(el,"clicks"),
                        getVal(el,"pct")
                });
            }
            Map<String,List<String[]>> grouped = groupByCustId(records);
            for (String custId : grouped.keySet()) {
                saveBatch(grouped.get(custId), SQL_CACHE.get("DELETE_REPORT"), SQL_CACHE.get("INSERT_REPORT"), custId);
            }
        }

        // Günlük rapor
        public void processDay(NodeList nodes) throws Exception {
            List<String[]> records = new ArrayList<String[]>();
            for (int i=0; i<nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                records.add(new String[]{
                        getVal(el,"cust_id"),
                        getVal(el,"opens2"),
                        getVal(el,"days"),
                        getVal(el,"days_num")
                });
            }
            Map<String,List<String[]>> grouped = groupByCustId(records);
            for (String custId : grouped.keySet()) {
                saveBatch(grouped.get(custId), SQL_CACHE.get("DELETE_DAY"), SQL_CACHE.get("INSERT_DAY"), custId);
            }
        }

        // Haftalık rapor
        public void processWeek(NodeList nodes) throws Exception {
            List<String[]> records = new ArrayList<String[]>();
            for (int i=0; i<nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                records.add(new String[]{
                        getVal(el,"cust_id"),
                        getVal(el,"week"),
                        getVal(el,"hour"),
                        getVal(el,"open"),
                        getVal(el,"click")
                });
            }
            Map<String,List<String[]>> grouped = groupByCustId(records);
            for (String custId : grouped.keySet()) {
                saveBatch(grouped.get(custId), SQL_CACHE.get("DELETE_WEEK"), SQL_CACHE.get("INSERT_WEEK"), custId);
            }
        }
    }
%>

<%@ include file="header.jsp" %>

<%

    ConnectionPool pool = null;
    Connection conn = null;
    ScheduleAdvisorReport processor = null;
    boolean committed = false;

    try {
        logger.info("schedule_advisor_report started...");
        long start = System.currentTimeMillis();

        BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(),"UTF-8"));
        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document doc = builder.parse(new InputSource(reader));

        pool = ConnectionPool.getInstance();
        conn = pool.getConnection(this);
        conn.setAutoCommit(false);

        processor = new ScheduleAdvisorReport(conn);

        processor.processReport(doc.getElementsByTagName("rrcp_schedule_advisor_report"));
        processor.processDay(doc.getElementsByTagName("rrcp_schedule_advisor_day_report"));
        processor.processWeek(doc.getElementsByTagName("rrcp_schedule_advisor_week_report"));

        conn.commit();
        committed = true;
        logger.info("schedule_advisor_report başarıyla tamamlandı. Süre=" + (System.currentTimeMillis() - start) + "ms");

    } catch (Exception ex) {
        logger.error("schedule_advisor_report hata!", ex);
        if (conn != null) {
            try {
                conn.rollback();
            } catch (Exception ignore) {
                logger.warn("rollback başarısız oldu", ignore);
            }
        }
    } finally {
        if (conn != null && pool != null) {
            if (committed) {
                pool.free(conn); // sadece başarılı commit sonrası havuza geri ver
            } else {
                try {
                    conn.close(); // başarısızsa doğrudan kapat
                } catch (Exception e) {
                    logger.warn("Bağlantı kapatılırken hata oluştu", e);
                }
            }
        }
    }
%>
