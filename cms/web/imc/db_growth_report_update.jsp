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

<%! static Logger logger = Logger.getLogger("DbGrowthReport"); %>

<%!
    public class DbGrowthReport {

        private final Connection connection;

        public DbGrowthReport(Connection connection) {
            this.connection = connection;
        }

        private String getVal(Element el, String tag) {
            NodeList n = el.getElementsByTagName(tag);
            return (n.getLength() > 0 && n.item(0).getFirstChild() != null) ? n.item(0).getTextContent().trim() : null;
        }

        private String nullIfEmpty(String v) {
            return (v == null || v.trim().isEmpty() || "null".equalsIgnoreCase(v)) ? null : v;
        }

        private Map<String, List<String[]>> groupByCustId(List<String[]> list) {
            Map<String, List<String[]>> grouped = new HashMap<String, List<String[]>>();
            for (String[] r : list) {
                String custId = r[0];
                if (custId != null && !"null".equalsIgnoreCase(custId)) {
                    if (!grouped.containsKey(custId)) {
                        grouped.put(custId, new ArrayList<String[]>());
                    }
                    grouped.get(custId).add(r);
                }
            }
            return grouped;
        }

        public void process(NodeList nodes) throws Exception {
            List<String[]> records = new ArrayList<String[]>();
            for (int i = 0; i < nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                records.add(new String[]{
                        getVal(el,"cust_id"),
                        getVal(el,"DATE"),
                        getVal(el,"subCount"),
                        getVal(el,"unsubCount")
                });
            }

            Map<String,List<String[]>> grouped = groupByCustId(records);

            PreparedStatement deleteStmt = null;
            PreparedStatement insertStmt = null;
            try {
                deleteStmt = connection.prepareStatement("DELETE FROM ccps_db_growth_summary WHERE cust_id = ?");
                insertStmt = connection.prepareStatement(
                        "INSERT INTO ccps_db_growth_summary (cust_id, summary_date, sub_count, unsub_count) VALUES (?,?,?,?)"
                );

                for (String custId : grouped.keySet()) {
                    // önce cust_id bazlı delete
                    deleteStmt.setString(1, custId);
                    deleteStmt.addBatch();

                    // sonra bütün kayıtları insert batch'e ekle
                    for (String[] r : grouped.get(custId)) {
                        int x = 1;
                        insertStmt.setString(x++, nullIfEmpty(r[0]));
                        insertStmt.setString(x++, nullIfEmpty(r[1]));
                        insertStmt.setString(x++, nullIfEmpty(r[2]));
                        insertStmt.setString(x++, nullIfEmpty(r[3]));
                        insertStmt.addBatch();
                    }
                }

                deleteStmt.executeBatch();
                insertStmt.executeBatch();
                logger.info("DbGrowthReport batch insert tamamlandı. Toplam kayıt=" + records.size());

            } finally {
                if (deleteStmt != null) try { deleteStmt.close(); } catch (Exception ignore) {}
                if (insertStmt != null) try { insertStmt.close(); } catch (Exception ignore) {}
            }
        }
    }
%>

<%@ include file="header.jsp" %>

<%
    ConnectionPool pool = null;
    Connection conn = null;
    boolean committed = false;
    try {
        logger.info("DbGrowthReport started...");
        long start = System.currentTimeMillis();

        BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(),"UTF-8"));
        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document doc = builder.parse(new InputSource(reader));

        pool = ConnectionPool.getInstance();
        conn = pool.getConnection(this);
        conn.setAutoCommit(false);

        DbGrowthReport processor = new DbGrowthReport(conn);
        processor.process(doc.getElementsByTagName("rrcp_db_growth_summary"));

        conn.commit();
        committed = true;
        logger.info("DbGrowthReport başarıyla tamamlandı. Süre=" + (System.currentTimeMillis() - start) + "ms");

    } catch (Exception ex) {
        logger.error("DbGrowthReport hata!", ex);
        if (conn != null) {
            try {
                conn.rollback();
            } catch (Exception ignore) {
                logger.warn("Rollback başarısız oldu!", ignore);
            }
        }
    } finally {
        safeClose(conn,pool,committed);
    }
%>
<%!
    public static void safeClose(Connection conn, ConnectionPool cp, boolean committed) {
        if (conn == null) return;
        try {
            if (committed && conn.isValid(2)) {
                cp.free(conn);
            } else {
                conn.close(); // dirty ise havuza verme
            }
        } catch (Exception e) {
            try { conn.close(); } catch (Exception ignore) {}
        }
    }
%>
