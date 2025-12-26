<%@ page language="java"
         import="com.britemoon.cps.*,
            java.sql.*,
            org.w3c.dom.*,
            org.apache.log4j.Logger"
         contentType="text/html;charset=UTF-8"
%>

<%! static Logger logger = Logger.getLogger("WebpushSummaryReport"); %>
<%@ include file="header.jsp" %>

<%!
    class WebpushSummaryReportClass {

        public Integer cust_id;
        public Integer total;
        public Integer active;
        public Integer mobile;
        public Integer desktop;
        public String update_date;

        public WebpushSummaryReportClass(Element root) {
            try { cust_id = Integer.parseInt(XmlUtil.getChildCDataValue(root, "cust_id")); } catch (Exception e) { cust_id = 0; }
            try { total = Integer.parseInt(XmlUtil.getChildCDataValue(root, "total")); } catch (Exception e) { total = 0; }
            try { active = Integer.parseInt(XmlUtil.getChildCDataValue(root, "active")); } catch (Exception e) { active = 0; }
            try { mobile = Integer.parseInt(XmlUtil.getChildCDataValue(root, "mobile")); } catch (Exception e) { mobile = 0; }
            try { desktop = Integer.parseInt(XmlUtil.getChildCDataValue(root, "desktop")); } catch (Exception e) { desktop = 0; }
            update_date = XmlUtil.getChildCDataValue(root, "update_date");
        }

        public void save(Connection conn) throws Exception {
            PreparedStatement pstmt = null;
            try {
                // Eğer dummy tarih geldiyse atla
                if ("2099-01-01 00:00:00.000".equals(update_date)) {
                    logger.info("Dummy tarih geldi, kayıt atlandı. cust_id=" + cust_id);
                    return;
                }

                String sql =
                        "IF EXISTS (SELECT 1 FROM crpt_cust_webpush_summary WHERE cust_id = ?) " +
                                "BEGIN " +
                                "   UPDATE crpt_cust_webpush_summary " +
                                "   SET total=?, active=?, mobile=?, desktop=?, update_date=? " +
                                "   WHERE cust_id=? " +
                                "END " +
                                "ELSE " +
                                "BEGIN " +
                                "   INSERT INTO crpt_cust_webpush_summary (cust_id,total,active,mobile,desktop,update_date) " +
                                "   VALUES (?,?,?,?,?,?) " +
                                "END";

                pstmt = conn.prepareStatement(sql);
                int x = 1;

                // UPDATE için
                pstmt.setInt(x++, cust_id != null ? cust_id : 0);
                pstmt.setInt(x++, total != null ? total : 0);
                pstmt.setInt(x++, active != null ? active : 0);
                pstmt.setInt(x++, mobile != null ? mobile : 0);
                pstmt.setInt(x++, desktop != null ? desktop : 0);
                pstmt.setTimestamp(x++, new Timestamp(System.currentTimeMillis())); // update_date
                pstmt.setInt(x++, cust_id != null ? cust_id : 0);

                // INSERT için
                pstmt.setInt(x++, cust_id != null ? cust_id : 0);
                pstmt.setInt(x++, total != null ? total : 0);
                pstmt.setInt(x++, active != null ? active : 0);
                pstmt.setInt(x++, mobile != null ? mobile : 0);
                pstmt.setInt(x++, desktop != null ? desktop : 0);
                pstmt.setTimestamp(x++, new Timestamp(System.currentTimeMillis()));

                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (Exception ignore) {}
            }
        }
    }
%>

<%
    ConnectionPool pool = null;
    Connection conn = null;
    try {
        if (logger == null) {
            logger = Logger.getLogger(this.getClass().getName());
        }

        Element e = XmlUtil.getRootElement(request);
        if (e == null) throw new Exception("WebpushSummaryReport xml boş!");

        pool = ConnectionPool.getInstance();
        conn = pool.getConnection(this);
        conn.setAutoCommit(false);

        WebpushSummaryReportClass report = new WebpushSummaryReportClass(e);
        report.save(conn);

        conn.commit();
        logger.info("WebpushSummaryReport güncellendi. cust_id=" + report.cust_id);

    } catch (Exception ex) {
        logger.error("WebpushSummaryReport hata!", ex);
        if (conn != null) try { conn.rollback(); } catch (Exception ignore) {}
    } finally {
        if (conn != null && pool != null) pool.free(conn);
    }
%>
