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

<%! static Logger logger = Logger.getLogger("ListActivityReport"); %>

<%!
    public class ListActivityReport {

        private final Map<String, String> SQL_CACHE = createSqlCache();

        private ConnectionPool connectionPool;
        private Connection connection;

        public ListActivityReport() throws Exception {
            this.connectionPool = ConnectionPool.getInstance();
            this.connection = connectionPool.getConnection(this);
            this.connection.setAutoCommit(false);
        }

        private Map<String, String> createSqlCache() {
            Map<String, String> cache = new HashMap<String, String>();
            cache.put("DELETE_CAMP_SUMMARY", "DELETE FROM ccps_rrpt_camp_summary_and_rque_campaign WHERE cust_id = ?");
            cache.put("INSERT_CAMP_SUMMARY", "INSERT INTO ccps_rrpt_camp_summary_and_rque_campaign (cust_id, sent, bbacks, dist_reads, dist_clicks, start_date) VALUES(?,?,?,?,?,?)");
            cache.put("DELETE_RQUE_MESSAGE", "DELETE FROM ccps_rque_message WHERE cust_id = ?");
            cache.put("INSERT_RQUE_MESSAGE", "INSERT INTO ccps_rque_message (cust_id, send_date, rque_count) VALUES(?,?,?)");
            cache.put("DELETE_RJTK_ACTIVITY", "DELETE FROM ccps_rjtk_link_activity WHERE cust_id = ?");
            cache.put("INSERT_RJTK_ACTIVITY", "INSERT INTO ccps_rjtk_link_activity (cust_id, camp_id, click_time, type_id, rjtk_count) VALUES(?,?,?,?,?)");
            return cache;
        }

        // Ortak batch save metodu
        private void saveBatch(List<String[]> records, String deleteSql, String insertSql, String custId) throws Exception {
            PreparedStatement deleteStmt = null;
            PreparedStatement insertStmt = null;

            try {
                deleteStmt = connection.prepareStatement(deleteSql);
                deleteStmt.setString(1, custId);
                deleteStmt.executeUpdate();

                insertStmt = connection.prepareStatement(insertSql);

                for (String[] fields : records) {
                    for (int i = 0; i < fields.length; i++) {
                        insertStmt.setString(i + 1, nullIfEmpty(fields[i]));
                    }
                    insertStmt.addBatch();
                }

                insertStmt.executeBatch();
                logger.info("Batch insert completed for " + custId + " - Records: " + records.size());

            } finally {
                if (deleteStmt != null) try { deleteStmt.close(); } catch (Exception ignore) {}
                if (insertStmt != null) try { insertStmt.close(); } catch (Exception ignore) {}
            }
        }

        // Transaction yönetimi
        public void commit() throws Exception { connection.commit(); }
        public void rollback() throws Exception { connection.rollback(); }

        // XML Node değerini al
        private String getValue(Element element, String tagName) {
            NodeList nodeList = element.getElementsByTagName(tagName);
            if (nodeList.getLength() > 0 && nodeList.item(0).hasChildNodes()) {
                return nodeList.item(0).getTextContent().trim();
            }
            return null;
        }

        private String nullIfEmpty(String value) {
            return (value == null || value.trim().isEmpty() || "null".equals(value)) ? null : value;
        }

        // Customer ID -> kayıt gruplama
        private Map<String, List<String[]>> groupByCustId(List<String[]> dataList) {
            Map<String, List<String[]>> grouped = new HashMap<String, List<String[]>>();
            for (String[] data : dataList) {
                String custId = data[0];
                if (custId != null && !custId.trim().isEmpty() && !"null".equals(custId)) {
                    if (!grouped.containsKey(custId)) {
                        grouped.put(custId, new ArrayList<String[]>());
                    }
                    grouped.get(custId).add(data);
                }
            }
            return grouped;
        }

        // Camp Summary işleme
        public void processCampSummary(NodeList nodes) throws Exception {
            List<String[]> records = new ArrayList<String[]>();
            for (int i = 0; i < nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                records.add(new String[]{
                        getValue(el, "cust_id"),
                        getValue(el, "sent"),
                        getValue(el, "bbacks"),
                        getValue(el, "dist_reads"),
                        getValue(el, "dist_clicks"),
                        getValue(el, "start_date")
                });
            }
            Map<String, List<String[]>> grouped = groupByCustId(records);
            for (String custId : grouped.keySet()) {
                saveBatch(grouped.get(custId), SQL_CACHE.get("DELETE_CAMP_SUMMARY"), SQL_CACHE.get("INSERT_CAMP_SUMMARY"), custId);
            }
        }

        // Rque Message işleme
        public void processRqueMessage(NodeList nodes) throws Exception {
            List<String[]> records = new ArrayList<String[]>();
            for (int i = 0; i < nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                records.add(new String[]{
                        getValue(el, "cust_id"),
                        getValue(el, "send_date"),
                        getValue(el, "rque_count")
                });
            }
            Map<String, List<String[]>> grouped = groupByCustId(records);
            for (String custId : grouped.keySet()) {
                saveBatch(grouped.get(custId), SQL_CACHE.get("DELETE_RQUE_MESSAGE"), SQL_CACHE.get("INSERT_RQUE_MESSAGE"), custId);
            }
        }

        // Rjtk Activity işleme
        public void processRjtkActivity(NodeList nodes) throws Exception {
            List<String[]> records = new ArrayList<String[]>();
            for (int i = 0; i < nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                records.add(new String[]{
                        getValue(el, "cust_id"),
                        getValue(el, "camp_id"),
                        getValue(el, "click_time"),
                        getValue(el, "type_id"),
                        getValue(el, "rjtk_count")
                });
            }
            Map<String, List<String[]>> grouped = groupByCustId(records);
            for (String custId : grouped.keySet()) {
                saveBatch(grouped.get(custId), SQL_CACHE.get("DELETE_RJTK_ACTIVITY"), SQL_CACHE.get("INSERT_RJTK_ACTIVITY"), custId);
            }
        }
        public void close(boolean committed) throws Exception {
            if (connection != null) {
                try {
                    if (!committed) {   // sadece commit edilmediyse
                        connection.rollback();
                    }
                } catch (Exception e) {
                    logger.warn("Rollback failed, connection may be invalid", e);
                } finally {
                    connectionPool.free(connection);
                }
            }
        }
    }
%>

<%@ include file="header.jsp" %>

<%
    ListActivityReport processor = null;
    boolean committed = false;
    try {
        long start = System.currentTimeMillis();
        logger.info("list_activity_report started...");

        BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(), "UTF-8"));
        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document doc = builder.parse(new InputSource(reader));

        processor = new ListActivityReport();

        processor.processCampSummary(doc.getElementsByTagName("rrpt_camp_summary_and_rque_campaign"));
        processor.processRqueMessage(doc.getElementsByTagName("rrcp_rque_message"));
        processor.processRjtkActivity(doc.getElementsByTagName("rrcp_rjtk_link_activity"));

        processor.commit();
        committed = true;
        logger.info("Completed in " + (System.currentTimeMillis() - start) + "ms");

    } catch (Exception ex) {
        throw ex; // rollback işi close içinde
    } finally {
        if (processor != null) processor.close(committed);
    }
%>
