<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.*,
                javax.xml.parsers.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                java.io.*,
                org.w3c.dom.*,
                org.xml.sax.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="static java.lang.System.out" %>
<%! static Logger logger = null;%>
<%!
    public class WebpushDashboardReport {

        private Element s_webpushDashboardReportXml = null;
        public String cust_id = null;
        public String recipientSubCount = null;
        public String recipientUnsubCount = null;
        public String recipientDay = null;
        public String deviceType = null;
        public String deviceActiveCount = null;
        public String devicePassiveCount = null;
        public String deviceTablet = null;
        public String deviceTabletActiveCount = null;
        public String deviceTabletPassiveCount = null;
        public String deviceMobile = null;
        public String deviceMobileActiveCount = null;
        public String deviceMobilePassiveCount = null;
        public String deviceDesktop = null;
        public String deviceDesktopActiveCount = null;
        public String deviceDesktopPassiveCount = null;
        public String browserOpera = null;
        public String browserOperaActiveCount = null;
        public String browserOperaPassiveCount = null;
        public String browserEdge = null;
        public String browserEdgeActiveCount = null;
        public String browserEdgePassiveCount = null;
        public String browserFirefox = null;
        public String browserFirefoxActiveCount = null;
        public String browserFirefoxPassiveCount = null;
        public String browserChrome = null;
        public String browserChromeActiveCount = null;
        public String browserChromePassiveCount = null;
        public String browserSafari = null;
        public String browserSafariActiveCount = null;
        public String browserSafariPassiveCount = null;
        public String unknownBrowser = null;
        public String browserUnknownActiveCount = null;
        public String browserUnknownPassiveCount = null;

        public WebpushDashboardReport(Element webpushDashboardReportXml) {
            System.out.println("webpushDashboardReportXml sout ");
            System.out.println("webpushDashboardReportXml sout ");
            System.out.println("webpushDashboardReportXml sout ");
            System.out.println("webpushDashboardReportXml sout ");
            System.out.println("webpushDashboardReportXml sout ");
            System.out.println("webpushDashboardReportXml sout ");
            System.out.println("webpushDashboardReportXml sout ");
            System.out.println("webpushDashboardReportXml sout ");
            System.out.println("webpushDashboardReportXml sout ");

            s_webpushDashboardReportXml = webpushDashboardReportXml;

            cust_id = Deger(s_webpushDashboardReportXml.getElementsByTagName("cust_id"));
            recipientSubCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("recipient_sub_count"));
            recipientUnsubCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("recipient_unsubsub_count"));
            recipientDay = Deger(s_webpushDashboardReportXml.getElementsByTagName("recipient_day"));
            deviceTablet = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_tablet"));
            deviceTabletActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_tablet_active_count"));
            deviceTabletPassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_tablet_passive_count"));
            deviceMobile = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_mobile"));
            deviceMobileActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_mobile_passive_count"));
            deviceMobilePassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_mobile_passive_count"));
            deviceDesktop = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_mobile_passive_count"));
            deviceDesktopActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_desktop_active_count"));
            deviceDesktopPassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("device_desktop_passive_count"));
            browserOpera = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_opera"));
            browserOperaActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_opera_active_count"));
            browserOperaPassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_opera_passive_count"));
            browserEdge = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_edge"));
            browserEdgeActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_edge_active_count"));
            browserEdgePassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_edge_passive_count"));
            browserFirefox = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_firefox"));
            browserFirefoxActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_firefox_active_count"));
            browserFirefoxPassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_firefox_passive_count"));
            browserChrome = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_chrome"));
            browserChromeActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_chrome_active_count"));
            browserChromePassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_chrome_passive_count"));
            browserSafari = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_safari"));
            browserSafariActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_safari_active_count"));
            browserSafariPassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_safari_passive_count"));
            unknownBrowser = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_unknown"));
            browserUnknownActiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_unknown_active_count"));
            browserUnknownPassiveCount = Deger(s_webpushDashboardReportXml.getElementsByTagName("browser_unknown_passive_count"));
        }


        public void save() throws Exception {
            ConnectionPool connectionPool = null;
            Connection connection = null;
            PreparedStatement statement = null;
            PreparedStatement statement2 = null;

            try {
                connectionPool = ConnectionPool.getInstance();
                connection = connectionPool.getConnection(this);
                System.out.print("before insert");


                String sql = " insert into ccps_webpush_device_type (cust_id,tablet_active_count,tablet_passive_count,desktop_active_count," +
                        " desktop_passive_count,mobile_active_count, mobile_passive_count) VALUES (?, ?, ?, ?, ?, ?, ?)";

                String sql2 = " insert into ccps_webpush_browser (cust_id,opera_active_count,opera_passive_count,edge_active_count," +
                        " edge_passive_count,firefox_active_count, firefox_passive_count ,chrome_active_count, chrome_passive_count" +
                        ",safari_active_count, safari_passive_count,unknown_active_count, unknown_passive_count) VALUES (?, ?, ?, ?, ?, ?, ?, ? ,?, ?,?,?,?)";
                System.out.print("after insert");
                statement = connection.prepareStatement(sql);
                statement2 = connection.prepareStatement(sql2);

                int x = 1;
                System.out.println("cust_id:  " + cust_id);
                System.out.println("deviceType" + deviceType);
                System.out.println("deviceActiveCount" + deviceActiveCount);
                System.out.println("devicePassiveCount" + devicePassiveCount);
                statement.setString(x++, cust_id);
                statement.setString(x++, deviceTabletActiveCount);
                statement.setString(x++, deviceTabletPassiveCount);
                statement.setString(x++, deviceDesktopActiveCount);
                statement.setString(x++, deviceDesktopPassiveCount);
                statement.setString(x++, deviceMobileActiveCount);
                statement.setString(x++, deviceMobilePassiveCount);
                statement2.setString(x++, cust_id);
                statement2.setString(x++, browserOperaActiveCount);
                statement2.setString(x++, browserOperaPassiveCount);
                statement2.setString(x++, browserEdgeActiveCount);
                statement2.setString(x++, browserEdgePassiveCount);
                statement2.setString(x++, browserFirefoxActiveCount);
                statement2.setString(x++, browserFirefoxPassiveCount);
                statement2.setString(x++, browserFirefoxActiveCount);
                statement2.setString(x++, browserFirefoxPassiveCount);
                statement.executeUpdate();
                System.out.print("after statement");
            } catch (Exception exception) {
                System.out.println("Save Function:" + exception);
                throw new Exception(exception);
            } finally {
                if (statement != null) statement.close();
                if (connection != null) connectionPool.free(connection);
            }
        }

        public String Deger(NodeList g1) {

            String deger = null;

            if (g1.getLength() > 0) {
                Element g1_Element = (Element) g1.item(0);
                NodeList text_g1 = g1_Element.getChildNodes();
                if (text_g1.item(0) != null) {
                    deger = ((Node) text_g1.item(0)).getNodeValue().trim();
                }
                System.out.println("DOLU : " + deger);
            } else {
                System.out.println("BOS : " + deger);
            }

            return MysqlRealScapeString(deger);
        }

        public String MysqlRealScapeString(String str) {
            String data = "";
            if (str != null && str.length() > 0) {
                str = str.replace("\\", "\\\\");
                str = str.replace("'", "");
                str = str.replace("\0", "\\0");
                str = str.replace("\n", "\\n");
                str = str.replace("\r", "\\r");
                str = str.replace("\"", "\\\"");
                str = str.replace("\\x1a", "\\Z");
                data = str;
            }
            return data;
        }

        @Override
        public String toString() {
            return super.toString();
        }
    }

%>
<%@ include file="header.jsp" %>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    try {
        System.out.println("WebPush Dashboard Report is loading...");
        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader((request.getInputStream()), "UTF-8"));
        DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = builderFactory.newDocumentBuilder();
        Document document = builder.parse(new InputSource(bufferedReader));

        try {
            NodeList nodeList = document.getElementsByTagName("rrcp_webpush_dashboard");
            System.out.println("getlength: "+ nodeList.getLength());
            System.out.println("getlength: "+ nodeList.getLength());
            System.out.println("getlength: "+ nodeList.getLength());
            System.out.println("getlength: "+ nodeList.getLength());
            System.out.println("getlength: "+ nodeList.getLength());
            for (int i = 0; i < nodeList.getLength(); i++) {

                WebpushDashboardReport report1 = new WebpushDashboardReport((Element) nodeList.item(i));
                System.out.println("Webpushhh Dashboardd Reporttt");
                System.out.println("Webpushhh Dashboardd Reporttt");
                System.out.println("Webpushhh Dashboardd Reporttt");
                System.out.println("Webpushhh Dashboardd Reporttt");
                System.out.println("Webpushhh Dashboardd Reporttt");
                System.out.println("deviceType: " +report1.deviceType);
                System.out.println("deviceActiveCount: " +report1.deviceActiveCount);
                System.out.println("devicePassiveCount: " +report1.devicePassiveCount);
                System.out.println("deviceType: " +report1.browserChrome);
                System.out.println("deviceActiveCount: " +report1.browserChromeActiveCount);
                System.out.println("devicePassiveCount: " +report1.browserChromePassiveCount);
                System.out.println();
                System.out.println(report1);
                report1.save();
            }

        } catch (Exception e) {
            System.out.println("Nodelist initialize error" + e);
        }
    } catch (Exception ex) {
        logger.error("WebPush Dashboard Report Error!\r\n", ex);
    }
%>
