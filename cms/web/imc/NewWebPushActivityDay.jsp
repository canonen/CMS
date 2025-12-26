<%@ page language="java"
         import="com.britemoon.cps.*,
            javax.xml.parsers.*,
            java.util.*,
            java.sql.*,
            java.io.*,
            java.net.*,
            org.w3c.dom.*,
            org.xml.sax.InputSource,
            org.apache.log4j.Logger"
         contentType="text/html;charset=UTF-8"
%>

<%! static Logger logger = Logger.getLogger("NewWebPushActivityDay"); %>

<%!
    public class NewWebPushActivityDay {

        private final String cust_id;
        private final String camp_id;
        private final String camp_name;
        private final String sent;
        private final String activity;
        private final String conversion;
        private final String revenue;
        private final String total_order;
        private final String total_revenue;
        private final String total_qty;
        private final String activity_date;
        private final String last_update_date;

        public NewWebPushActivityDay(Element element) {
            cust_id        = getValue(element, "cust_id");
            camp_id        = getValue(element, "camp_id");
            camp_name      = getValue(element, "camp_name");
            sent           = getValue(element, "sent");
            activity       = getValue(element, "activity");
            conversion     = getValue(element, "conversion");
            revenue        = getValue(element, "revenue");
            total_order    = getValue(element, "total_order");
            total_revenue  = getValue(element, "total_revenue");
            total_qty      = getValue(element, "total_qty");
            activity_date  = getValue(element, "activity_date");
            last_update_date = getValue(element, "last_update_date");
        }

        public void save() throws Exception {
            ConnectionPool connectionPool = null;
            Connection connection = null;
            PreparedStatement stmt = null;

            try {
                connectionPool = ConnectionPool.getInstance();
                connection = connectionPool.getConnection(this);

                String sql = "INSERT INTO ccps_webpush_activity_day" +
                        "(cust_id,camp_id,camp_name,sent,activity,conversion,revenue," +
                        " total_order,total_revenue,total_qty,activity_date,last_update_date)" +
                        " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                stmt = connection.prepareStatement(sql);

                int i = 1;
                stmt.setInt(i++, parseIntSafe(cust_id));
                stmt.setInt(i++, parseIntSafe(camp_id));
                stmt.setString(i++, camp_name);
                stmt.setInt(i++, parseIntSafe(sent));
                stmt.setInt(i++, parseIntSafe(activity));
                stmt.setInt(i++, parseIntSafe(conversion));
                stmt.setDouble(i++, parseDoubleSafe(revenue));
                stmt.setDouble(i++, parseDoubleSafe(total_order));
                stmt.setDouble(i++, parseDoubleSafe(total_revenue));
                stmt.setDouble(i++, parseDoubleSafe(total_qty));
                stmt.setString(i++, nullIfEmpty(activity_date));
                stmt.setString(i++, nullIfEmpty(last_update_date));

                stmt.executeUpdate();
                logger.info("WebPushActivityDay kaydedildi. cust_id=" + cust_id + ", camp_id=" + camp_id);

            } catch (Exception e) {
                logger.error("Save Function : WebPush Activity Day hatası", e);
                throw e;
            } finally {
                if (stmt != null) try { stmt.close(); } catch (Exception ignore) {}
                if (connection != null) connectionPool.free(connection);
            }
        }

        private String getValue(Element element, String tag) {
            NodeList list = element.getElementsByTagName(tag);
            if (list.getLength() > 0 && list.item(0).hasChildNodes()) {
                return list.item(0).getTextContent().trim();
            }
            return null;
        }

        private int parseIntSafe(String val) {
            try {
                if (val == null || "null".equalsIgnoreCase(val)) return 0;
                return Integer.parseInt(val);
            } catch (Exception e) {
                return 0;
            }
        }

        private double parseDoubleSafe(String val) {
            try {
                if (val == null || "null".equalsIgnoreCase(val)) return 0.0;
                return Double.parseDouble(val);
            } catch (Exception e) {
                return 0.0;
            }
        }

        private String nullIfEmpty(String val) {
            return (val == null || val.trim().isEmpty() || "null".equalsIgnoreCase(val)) ? null : val;
        }
    }
%>

<%@ include file="header.jsp" %>

<%
    try {
        logger.info("WebPush Activity Day yükleniyor...");

        BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(), "UTF-8"));
        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document doc = builder.parse(new InputSource(reader));

        NodeList nodes = doc.getElementsByTagName("webpush_activity_day");
        for (int i = 0; i < nodes.getLength(); i++) {
            NewWebPushActivityDay report = new NewWebPushActivityDay((Element) nodes.item(i));
            report.save();
        }

        logger.info("WebPush Activity Day işlemi tamamlandı. Kayıt sayısı=" + nodes.getLength());

    } catch (Exception e) {
        logger.error("Webpush Activity Day Update Error!", e);
    }
%>
