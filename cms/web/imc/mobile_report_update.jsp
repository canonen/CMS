<%@ page language="java"
         import="com.britemoon.cps.*,
                 java.sql.*,
                 org.w3c.dom.*,
                 org.apache.log4j.Logger"
         contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>

<%! static Logger logger = Logger.getLogger("MobileReport"); %>
<%@ include file="header.jsp" %>

<%!
    class MobileReportClass {
        private final String custId;
        private final Map<String, String[]> clientData = new LinkedHashMap<String, String[]>();
        private final String totalReads, desktopReads, mobileReads;

        public MobileReportClass(Element root) {
            custId = XmlUtil.getChildCDataValue(root, "cust_id");

            clientData.put("iPhone", new String[]{
                    XmlUtil.getChildCDataValue(root, "iphone_count"),
                    XmlUtil.getChildCDataValue(root, "iphone_pct")
            });
            clientData.put("iPad", new String[]{
                    XmlUtil.getChildCDataValue(root, "ipad_count"),
                    XmlUtil.getChildCDataValue(root, "ipad_pct")
            });
            clientData.put("Android", new String[]{
                    XmlUtil.getChildCDataValue(root, "android_count"),
                    XmlUtil.getChildCDataValue(root, "android_pct")
            });
            clientData.put("Windows Mobile", new String[]{
                    XmlUtil.getChildCDataValue(root, "windowsmobile_count"),
                    XmlUtil.getChildCDataValue(root, "windowsmobile_pct")
            });
            clientData.put("BlackBerry", new String[]{
                    XmlUtil.getChildCDataValue(root, "blackberry_count"),
                    XmlUtil.getChildCDataValue(root, "blackberry_pct")
            });
            clientData.put("Symbian", new String[]{
                    XmlUtil.getChildCDataValue(root, "symbian_count"),
                    XmlUtil.getChildCDataValue(root, "symbian_pct")
            });
            clientData.put("Other", new String[]{
                    XmlUtil.getChildCDataValue(root, "other_count"),
                    XmlUtil.getChildCDataValue(root, "other_pct")
            });

            totalReads = XmlUtil.getChildCDataValue(root, "total_reads");
            desktopReads = XmlUtil.getChildCDataValue(root, "desktop_reads");
            mobileReads = XmlUtil.getChildCDataValue(root, "mobile_reads");
        }

        public void save(Connection conn) throws Exception {
            PreparedStatement pstmt = null;

            String sqlClient =
                    "IF NOT EXISTS(select 1 from z_mobile_reporting where cust_id = ? and mobile_client = ?) " +
                            "BEGIN " +
                            " INSERT INTO z_mobile_reporting (cust_id,mobile_client,mobile_count,mobile_pct,update_date) VALUES(?,?,?,?,getdate()) " +
                            "END " +
                            "ELSE " +
                            "BEGIN " +
                            " UPDATE z_mobile_reporting SET mobile_count=?, mobile_pct=?, update_date=getdate() WHERE cust_id=? and mobile_client=? " +
                            "END";

            String sqlSummary =
                    "IF NOT EXISTS(select 1 from z_rrpt_mobile_summary where cust_id = ?) " +
                            "BEGIN " +
                            " INSERT INTO z_rrpt_mobile_summary (cust_id,total_reads,desktop_reads,mobil_reads) VALUES(?,?,?,?) " +
                            "END " +
                            "ELSE " +
                            "BEGIN " +
                            " UPDATE z_rrpt_mobile_summary SET total_reads=?, desktop_reads=?, mobil_reads=? WHERE cust_id=? " +
                            "END";

            try {
                conn.setAutoCommit(false);

                // ---- Mobile Client bazlı kayıtlar
                pstmt = conn.prepareStatement(sqlClient);
                for (Map.Entry<String, String[]> entry : clientData.entrySet()) {
                    String client = entry.getKey();
                    String count = safe(entry.getValue()[0]);
                    String pct   = safe(entry.getValue()[1]);

                    int x = 1;
                    pstmt.setString(x++, custId);
                    pstmt.setString(x++, client);
                    pstmt.setString(x++, count);
                    pstmt.setString(x++, pct);
                    pstmt.setString(x++, count);
                    pstmt.setString(x++, pct);
                    pstmt.setString(x++, custId);
                    pstmt.setString(x++, client);

                    pstmt.executeUpdate();
                }
                pstmt.close();

                // ---- Summary tablo
                pstmt = conn.prepareStatement(sqlSummary);
                int y = 1;
                pstmt.setString(y++, custId);
                pstmt.setString(y++, safe(totalReads));
                pstmt.setString(y++, safe(desktopReads));
                pstmt.setString(y++, safe(mobileReads));
                pstmt.setString(y++, safe(totalReads));
                pstmt.setString(y++, safe(desktopReads));
                pstmt.setString(y++, safe(mobileReads));
                pstmt.setString(y++, custId);

                pstmt.executeUpdate();
                pstmt.close();

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (Exception ignore) {}
            }
        }

        private String safe(String v) {
            return (v == null || v.trim().isEmpty() || "null".equalsIgnoreCase(v)) ? "0" : v;
        }
    }
%>

<%
    ConnectionPool pool = null;
    Connection conn = null;
    try {
        if (logger == null) logger = Logger.getLogger(this.getClass().getName());

        Element e = XmlUtil.getRootElement(request);
        if (e == null) throw new Exception("Malformed Mobile Report xml.");

        MobileReportClass report = new MobileReportClass(e);

        pool = ConnectionPool.getInstance();
        conn = pool.getConnection(this);

        report.save(conn);

        logger.info("MobileReport güncellendi. cust_id=" + report.custId);
    } catch (Exception ex) {
        logger.error("Mobile Report Update Error!\r\n", ex);
    } finally {
        if (conn != null && pool != null) pool.free(conn);
    }
%>
