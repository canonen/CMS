<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
			    com.britemoon.cps.*,
                java.sql.*,
                org.apache.log4j.Logger"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.w3c.dom.NodeList" %>
<%@ page import="org.w3c.dom.Element" %>
<%@ page import="org.w3c.dom.Node" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="java.io.StringWriter" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="java.io.ByteArrayInputStream" %>
<%@ page import="com.britemoon.cps.imc.*" %>
<%@ page import="com.britemoon.cps.imc.Service" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>

<%!
    public class XmlParse{		//++++

        public String orderId 	    = null;
        public String email         = null;
        public String productId	    = null;
        public String productName	= null;
        public String link	        = null;
        public String qty	        = null;
        public String sumAmt	    = null;
        public String source 		= null;
        public String rvsSource	    = null;
        public String rvsMedium     = null;
        public String insertDate	= null;


        public XmlParse(Element element){

            orderId 	    =  Deger(element.getElementsByTagName("orderId")).equals("null") ? null : Deger(element.getElementsByTagName("orderId"));
            email           =  Deger(element.getElementsByTagName("email")).equals("null") ? null : Deger(element.getElementsByTagName("email"));
            productId	    =  Deger(element.getElementsByTagName("productId")).equals("null") ? null : Deger(element.getElementsByTagName("productId"));
            productName     =  Deger(element.getElementsByTagName("productName")).equals("null") ? null : Deger(element.getElementsByTagName("productName"));
            link            =  Deger(element.getElementsByTagName("link")).equals("null") ? null : Deger(element.getElementsByTagName("link"));
            qty	            =  Deger(element.getElementsByTagName("qty")).equals("null") ? "0" : Deger(element.getElementsByTagName("qty"));
            sumAmt	        =  Deger(element.getElementsByTagName("sumAmt")).equals("null") ? "0" : Deger(element.getElementsByTagName("sumAmt"));
            source 		    =  Deger(element.getElementsByTagName("source")).equals("null") ? null : Deger(element.getElementsByTagName("source"));
            rvsSource	    =  Deger(element.getElementsByTagName("rvsSource")).equals("null") ? null : Deger(element.getElementsByTagName("rvsSource"));
            rvsMedium	    =  Deger(element.getElementsByTagName("rvsMedium")).equals("null") ? null : Deger(element.getElementsByTagName("rvsMedium"));
            insertDate	    =  Deger(element.getElementsByTagName("insertDate")).equals("null") ? null : Deger(element.getElementsByTagName("insertDate"));

        }


        public String Deger(NodeList g1){

            String deger=null;

            if(g1.getLength()>0){
                Element g1_Element		= (Element)g1.item(0);
                NodeList text_g1 		= g1_Element.getChildNodes();
                if(text_g1.item(0) != null ){
                    deger					=((Node)text_g1.item(0)).getNodeValue().trim();
                }
            }

            return MysqlRealScapeString(deger)  ;
        }

        public String MysqlRealScapeString(String str){
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
    }
%>

<%!
    String maskString(String strText, int start, int end, char maskChar)
            throws Exception {

        if (strText == null || strText.equals(""))
            return "";

        if (start < 0)
            start = 0;

        if (end > strText.length())
            end = strText.length();

        if (start > end)
            throw new Exception("End index cannot be greater than start index");

        int maskLength = end - start;

        if (maskLength == 0)
            return strText;

        StringBuilder sbMaskString = new StringBuilder(maskLength);

        for (int i = 0; i < maskLength; i++) {
            sbMaskString.append(maskChar);
        }

        return strText.substring(0, start)
                + sbMaskString.toString()
                + strText.substring(start + maskLength);
    }

    String maskEmailAddress(String strEmail, char maskChar) throws Exception {

        String[] parts = strEmail.split("@");

        //mask two part
        String strId = "";
        if (parts[1].length() < 4)
            strId = maskString(parts[1], 0, parts[1].length(), '*');
        else
            strId = maskString(parts[1], 0, parts[1].length() - 3, '*');

        return parts[0] + "@" + strId;
    }
%>

<%
    String sCustIdNullCheck = request.getParameter("custId");
    String sCustId = "";
    if (sCustIdNullCheck != null && !sCustIdNullCheck.equals("null") && sCustIdNullCheck != "null"){
        sCustId= sCustIdNullCheck;
    }
    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);

    service = (Service) services.get(0);

    String rcpUrl = service.getURL().getHost();

    Calendar calendar = Calendar.getInstance();
    calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
    JsonObject  jsonObject = new JsonObject();
    JsonArray   data = new JsonArray();




    int current_year;
    int current_month;
    int current_month_cal;
    int current_day;
    String last_week;


    calendar.add(Calendar.DATE, +4);
    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
    current_day = calendar.get(Calendar.DAY_OF_MONTH);
    calendar.add(Calendar.DATE, -6);
    Date lastWeekNotFormat = calendar.getTime();
    last_week = new SimpleDateFormat("yyyy-MM-dd").format(lastWeekNotFormat);

    String today = current_year + "-" + current_month_cal + "-" + current_day;
    String firstDate = last_week;

    String date1 = (request.getParameter("firstDate") != null) ? request.getParameter("firstDate") : firstDate;
    String date2 = (request.getParameter("lastDate") != null) ? request.getParameter("lastDate") : today;

    Statement stmt = null;
    ConnectionPool cp = null;
    Connection conn = null;
    double totalQty = 0;
    double totalAmt = 0;



    System.out.println("sales_performance loading...");
    try {


        cp = ConnectionPool.getInstance();


        conn = cp.getConnection(this);
        stmt = conn.createStatement();


        NodeList nodeList = null;

        StringWriter sw = new StringWriter();

        sw.write("<root>");
        sw.write("<ccps_sales_performance>\r\n");
        sw.write("<cust_id><![CDATA[" + sCustId + "]]></cust_id>\r\n");
        sw.write("<date1><![CDATA[" + date1 + "]]></date1>\r\n");
        sw.write("<date2><![CDATA[" + date2 + "]]></date2>\r\n");
        sw.write("</ccps_sales_performance>\r\n");
        sw.write("</root>");


        String sResponse = Service.communicate(127, sCustId, sw.toString());


        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));




        nodeList = document.getElementsByTagName("rrcp_sales_performance_report");
        if(nodeList !=null) {
            for (int i = 0; i < nodeList.getLength(); i++) {

                XmlParse report = new XmlParse((Element) nodeList.item(i));

                String orderId      = report.orderId;
                String email        = report.email;
                String productId    = report.productId;
                String productName  = report.productName;
                String link         = report.link;
                double qty          = Double.parseDouble(report.qty);
                double sumAmt       = Double.parseDouble(report.sumAmt);
                String source       = report.source;
                String rvsSource    = report.rvsSource;
                String rvsMedium    = report.rvsMedium;
                String insertDate   = report.insertDate;


                if (!email.equals("")) {
                    email = maskEmailAddress(email, '@');
                }

                totalQty += qty;
                totalAmt += sumAmt;

                jsonObject = new JsonObject();
                jsonObject.put("orderId", orderId);
                jsonObject.put("email", email);
                jsonObject.put("productId", productId);
                jsonObject.put("productName", productName);
                jsonObject.put("link", link);
                jsonObject.put("qty", qty);
                jsonObject.put("sumAmt", sumAmt);
                jsonObject.put("insertDate", insertDate);
                jsonObject.put("source", source);
                jsonObject.put("rvsSource", rvsSource);
                jsonObject.put("rvsMedium", rvsMedium);
                data.put(jsonObject);
            }
        }

        stmt.close();
        out.print(data.toString());


    } catch (Exception ex) {
        System.out.println("sales_performance error for cust:"+sCustId+ex);
     } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection", e);
        }
    }
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");


%>
