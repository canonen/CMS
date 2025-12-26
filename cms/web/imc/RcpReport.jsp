<%@ page language="java"
         import="com.britemoon.cps.*,
            java.util.*,
            java.sql.*,
            org.w3c.dom.*,
            org.apache.log4j.Logger"
         contentType="text/html;charset=UTF-8"
%>

<%! static Logger logger = Logger.getLogger("RcpReport"); %>

<%@ include file="header.jsp" %>

<%!
    class RcpReportClass {

        private String cust_id;
        private String total;
        private String active;
        private String bback;
        private String unsub;
        private String exclude_;
        private String update_date;

        public RcpReportClass(Element root) {
            cust_id   = XmlUtil.getChildCDataValue(root, "cust_id");
            total     = XmlUtil.getChildCDataValue(root, "total");
            active    = XmlUtil.getChildCDataValue(root, "active");
            bback     = XmlUtil.getChildCDataValue(root, "bback");
            unsub     = XmlUtil.getChildCDataValue(root, "unsub");
            exclude_  = XmlUtil.getChildCDataValue(root, "exclude_");
            update_date = XmlUtil.getChildCDataValue(root, "update_date");
        }

        public void save(Connection conn) throws Exception {
            PreparedStatement pstmt = null;
            try {
                String sql =
                        "IF EXISTS (SELECT 1 FROM crpt_cust_email_summary WHERE cust_id = ?) " +
                                "BEGIN " +
                                "   UPDATE crpt_cust_email_summary " +
                                "   SET total=?, active=?, bback=?, unsub=?, exclude_=?, update_date=? " +
                                "   WHERE cust_id=? " +
                                "END " +
                                "ELSE " +
                                "BEGIN " +
                                "   INSERT INTO crpt_cust_email_summary (cust_id,total,active,bback,unsub,exclude_,update_date) " +
                                "   VALUES (?,?,?,?,?,?,?) " +
                                "END";

                pstmt = conn.prepareStatement(sql);
                int x = 1;

                // UPDATE parametreleri
                pstmt.setInt(x++, parseIntSafe(cust_id));   // exists kontrolü için
                pstmt.setInt(x++, parseIntSafe(total));
                pstmt.setInt(x++, parseIntSafe(active));
                pstmt.setInt(x++, parseIntSafe(bback));
                pstmt.setInt(x++, parseIntSafe(unsub));
                pstmt.setInt(x++, parseIntSafe(exclude_));
                pstmt.setTimestamp(x++, new Timestamp(System.currentTimeMillis()));
                pstmt.setInt(x++, parseIntSafe(cust_id));

                // INSERT parametreleri
                pstmt.setInt(x++, parseIntSafe(cust_id));
                pstmt.setInt(x++, parseIntSafe(total));
                pstmt.setInt(x++, parseIntSafe(active));
                pstmt.setInt(x++, parseIntSafe(bback));
                pstmt.setInt(x++, parseIntSafe(unsub));
                pstmt.setInt(x++, parseIntSafe(exclude_));
                pstmt.setTimestamp(x++, new Timestamp(System.currentTimeMillis()));

                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (Exception ignore) {}
            }
        }

        private int parseIntSafe(String v) {
            try {
                if (v == null || v.trim().isEmpty() || "null".equalsIgnoreCase(v)) return 0;
                return Integer.parseInt(v);
            } catch (Exception e) {
                return 0;
            }
        }
    }
%>

<%
    ConnectionPool pool = null;
    Connection conn = null;
    try {
        logger.info("RcpReport started...");

        Element e = XmlUtil.getRootElement(request);
        if (e == null) throw new Exception("Rcp Report xml boş geldi!");

        pool = ConnectionPool.getInstance();
        conn = pool.getConnection(this);
        conn.setAutoCommit(false);

        RcpReportClass report = new RcpReportClass(e);
        report.save(conn);

        conn.commit();
        logger.info("RcpReport başarıyla güncellendi.");

    } catch (Exception ex) {
        logger.error("RcpReport hata!", ex);
        if (conn != null) try { conn.rollback(); } catch (Exception ignore) {}
    } finally {
        if (conn != null && pool != null) pool.free(conn);
    }
%>
