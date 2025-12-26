<%@ page language="java"
         import="com.britemoon.cps.*,
            org.w3c.dom.*,
            javax.xml.parsers.*,
            java.sql.*,
            java.io.*,
            java.util.*,
            org.xml.sax.InputSource,
            org.apache.log4j.Logger"
         contentType="text/html;charset=UTF-8"
%>

<%! static Logger logger = Logger.getLogger("PersonalSearchReport"); %>

<%!
    public class PersonalSearchReport {

        private String getValue(Element parent, String tag) {
            NodeList nodes = parent.getElementsByTagName(tag);
            if (nodes.getLength() > 0 && nodes.item(0).hasChildNodes()) {
                return nodes.item(0).getTextContent().trim();
            }
            return null;
        }

        public void save(Element el) throws Exception {
            String cust_id = getValue(el, "cust_id");
            String search_keyword = getValue(el, "search_keyword");
            String count = getValue(el, "count");
            String conversion = getValue(el, "conversion");
            String revenue = getValue(el, "revenue");
            String search_result_count = getValue(el, "search_result_count");
            String activity = getValue(el, "activity");
            String activity_date = getValue(el, "activity_date");
            String last_update_date = getValue(el, "last_update_date");

            String sql = "INSERT INTO ccps_pers_search_activity_day " +
                    "(cust_id, search_keyword, count, conversion, revenue, search_result_count, activity, activity_date, last_update_date) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            try (Connection connection = ConnectionPool.getInstance().getConnection(this);
                 PreparedStatement stmt = connection.prepareStatement(sql)) {

                stmt.setString(1, cust_id);
                stmt.setString(2, search_keyword);
                stmt.setString(3, count);
                stmt.setString(4, conversion);
                stmt.setString(5, revenue);
                stmt.setString(6, search_result_count);
                stmt.setString(7, activity);
                stmt.setString(8, activity_date);
                stmt.setString(9, last_update_date);
                stmt.executeUpdate();

            } catch (Exception e) {
                logger.error("DB Save Error: ", e);
                throw e;
            }
        }
    }
%>

<%@ include file="header.jsp" %>

<%
    try {
        logger.info("PersonalSearchReport processing started...");

        BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(), "UTF-8"));
        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = builder.parse(new InputSource(reader));

        NodeList reports = document.getElementsByTagName("personal_search_report");
        PersonalSearchReport handler = new PersonalSearchReport();

        for (int i = 0; i < reports.getLength(); i++) {
            handler.save((Element) reports.item(i));
        }

        logger.info("PersonalSearchReport processing completed.");

    } catch (Exception e) {
        logger.error("PersonalSearchReport error:", e);
    }
%>
