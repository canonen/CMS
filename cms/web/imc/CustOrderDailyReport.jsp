<%@ page language="java"
         import="com.britemoon.cps.*,
            java.util.*,
            java.sql.*,
            org.w3c.dom.*,
            org.apache.log4j.Logger"
         contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.text.SimpleDateFormat" %>

<%! static Logger logger = Logger.getLogger("CustOrderDailyReport"); %>

<%@ include file="header.jsp" %>

<%!
    class CustOrderDailyReport {

        private String custId;
        private String orders;
        private String revenue;
        private String revenueCustomers;
        private String aov;
        private String conversionRate;
        private String pageView;
        private String users;
        private String pageViewUsers;
        private String typeName;
        private String activityDate;
        private String lastUpdateDate;

        public CustOrderDailyReport(Element root) {
            setCustId(XmlUtil.getChildCDataValue(root, "customers"));
            setOrders(XmlUtil.getChildCDataValue(root, "orders"));
            setRevenue(XmlUtil.getChildCDataValue(root, "revenue"));
            setRevenueCustomers(XmlUtil.getChildCDataValue(root, "revenue_customers"));
            setAov(XmlUtil.getChildCDataValue(root, "aov"));
            setConversionRate(XmlUtil.getChildCDataValue(root, "conversion_rate"));
            setPageView(XmlUtil.getChildCDataValue(root, "page_view"));
            setUsers(XmlUtil.getChildCDataValue(root, "users"));
            setPageViewUsers(XmlUtil.getChildCDataValue(root, "page_view_users"));
            setTypeName(XmlUtil.getChildCDataValue(root, "type_name"));
            setActivityDate(XmlUtil.getChildCDataValue(root, "activity_date"));
            setLastUpdateDate(XmlUtil.getChildCDataValue(root, "last_update_date"));
        }

        public void save(Connection conn) throws Exception {
            System.out.println("CUSTORDERDAILYREPORT çalıştı");
            logger.info("CUSTORDERDAILYREPORT çalıştı");
            PreparedStatement pstmt = null;
            try {
                String sql =
                        "IF EXISTS (SELECT 1 FROM cque_cust_order_day WHERE cust_id = ?) " +
                                "BEGIN " +
                                "   UPDATE cque_cust_order_day " +
                                "   SET orders=?, customers=?, revenue=?, revenue_customers=?, aov=?, conversion_rate=?, pageview=?, users=?, pageview_user=?, type_name=?, activity_date=?, last_update_date=? " +
                                "   WHERE cust_id=? " +
                                "END " +
                                "ELSE " +
                                "BEGIN " +
                                "   INSERT INTO cque_cust_order_day (cust_id, orders, customers, revenue, revenue_customers, aov, conversion_rate, pageview, users, pageview_user, type_name, activity_date, last_update_date) " +
                                "   VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?) " +
                                "END";

                pstmt = conn.prepareStatement(sql);
                int x = 1;

                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                java.util.Date activity = sdf.parse(getActivityDate());

                pstmt.setInt(x++, parseIntSafe(getCustId())); // 1

                // UPDATE parametreleri (12 sütun + WHERE cust_id)
                pstmt.setInt(x++, parseIntSafe(getOrders()));        // 2 orders
                pstmt.setInt(x++, parseIntSafe(getCustId()));     // 3 customers
                pstmt.setDouble(x++, parseDoubleSafe(getRevenue())); // 4
                pstmt.setDouble(x++, parseDoubleSafe(getRevenueCustomers())); // 5
                pstmt.setDouble(x++, parseDoubleSafe(getAov()));     // 6
                pstmt.setDouble(x++, parseDoubleSafe(getConversionRate())); // 7
                pstmt.setInt(x++, parseIntSafe(getPageView()));      // 8
                pstmt.setInt(x++, parseIntSafe(getUsers()));         // 9
                pstmt.setDouble(x++, parseDoubleSafe(getPageViewUsers())); // 10
                pstmt.setString(x++, getTypeName());                  // 11
                pstmt.setTimestamp(x++, new Timestamp(activity.getTime())); // 12
                pstmt.setTimestamp(x++, new Timestamp(System.currentTimeMillis())); // 13
                pstmt.setInt(x++, parseIntSafe(getCustId()));         // 14 WHERE cust_id

                // INSERT
                pstmt.setInt(x++, parseIntSafe(getCustId()));     // 15 cust_id
                pstmt.setInt(x++, parseIntSafe(getOrders()));     // 16 orders
                pstmt.setInt(x++, parseIntSafe(getCustId()));  // 17 customers
                pstmt.setDouble(x++, parseDoubleSafe(getRevenue())); // 18
                pstmt.setDouble(x++, parseDoubleSafe(getRevenueCustomers())); // 19
                pstmt.setDouble(x++, parseDoubleSafe(getAov())); // 20
                pstmt.setDouble(x++, parseDoubleSafe(getConversionRate())); // 21
                pstmt.setInt(x++, parseIntSafe(getPageView())); // 22
                pstmt.setInt(x++, parseIntSafe(getUsers())); // 23
                pstmt.setDouble(x++, parseDoubleSafe(getPageViewUsers())); // 24
                pstmt.setString(x++, getTypeName()); // 25
                pstmt.setTimestamp(x++, new Timestamp(activity.getTime())); // 26
                pstmt.setTimestamp(x++, new Timestamp(System.currentTimeMillis())); // 27

                pstmt.executeUpdate();
            }
            catch (Exception e){
                e.printStackTrace();
            }
            finally {
                if (pstmt != null) try { pstmt.close(); } catch (Exception ignore) {}
            }
        }

        private int parseIntSafe(String v) {
            try {
                if (v == null || v.trim().isEmpty() || "null".equalsIgnoreCase(v)) return 0;
                return Integer.parseInt(v);
            } catch (Exception e) { return 0; }
        }

        private double parseDoubleSafe(String v) {
            try {
                if (v == null || v.trim().isEmpty() || "null".equalsIgnoreCase(v)) return 0.0;
                return Double.valueOf(v);
            } catch (Exception e) { return 0.0; }
        }

        public String getCustId() { return custId; }
        public void setCustId(String custId) { this.custId = custId; }
        public String getOrders() { return orders; }
        public void setOrders(String orders) { this.orders = orders; }
        public String getRevenue() { return revenue; }
        public void setRevenue(String revenue) { this.revenue = revenue; }
        public String getRevenueCustomers() { return revenueCustomers; }
        public void setRevenueCustomers(String revenueCustomers) { this.revenueCustomers = revenueCustomers; }
        public String getAov() { return aov; }
        public void setAov(String aov) { this.aov = aov; }
        public String getConversionRate() { return conversionRate; }
        public void setConversionRate(String conversionRate) { this.conversionRate = conversionRate; }
        public String getPageView() { return pageView; }
        public void setPageView(String pageView) { this.pageView = pageView; }
        public String getUsers() { return users; }
        public void setUsers(String users) { this.users = users; }
        public String getPageViewUsers() { return pageViewUsers; }
        public void setPageViewUsers(String pageViewUsers) { this.pageViewUsers = pageViewUsers; }
        public String getTypeName() { return typeName; }
        public void setTypeName(String typeName) { this.typeName = typeName; }
        public String getActivityDate() { return activityDate; }
        public void setActivityDate(String activityDate) { this.activityDate = activityDate; }
        public String getLastUpdateDate() { return lastUpdateDate; }
        public void setLastUpdateDate(String lastUpdateDate) { this.lastUpdateDate = lastUpdateDate; }

    }
%>

<%
    ConnectionPool pool = null;
    Connection conn = null;
    try {
        logger.info("CustOrderDailyReport started...");

        Element e = XmlUtil.getRootElement(request);
        if (e == null) throw new Exception("CustOrderDailyReport xml boş geldi!");

        pool = ConnectionPool.getInstance();
        conn = pool.getConnection(this);
        conn.setAutoCommit(false);

        CustOrderDailyReport report = new CustOrderDailyReport(e);
        report.save(conn);

        conn.commit();
        logger.info("CustOrderDailyReport başarıyla güncellendi.");

    } catch (Exception ex) {
        logger.error("CustOrderDailyReport hata!", ex);
        if (conn != null) try { conn.rollback(); } catch (Exception ignore) {}
    } finally {
        if (conn != null && pool != null) pool.free(conn);
    }


%>
