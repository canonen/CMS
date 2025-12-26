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
			org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.*" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.CDL" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="sun.nio.ch.IOUtil" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="org.xml.sax.SAXException" %>
<%@ page import="org.xml.sax.SAXParseException" %>
<%@ page import="org.apache.axis.ConfigurationException" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
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

        public String queueCount 	  = null;
        public String completedCount  = null;
        public String rejectCount	  = null;
        public String errorCount	  = null;
        public String iysErrorCount	  = null;
        public String recipient	      = null;
        public String type	          = null;
        public String source 		  = null;
        public String status	      = null;
        public String recipient_type  = null;
        public String consent_date	  = null;
        public String iys_create_date = null;
        public String status_id	      = null;
        public String iys_error_msg	  = null;



        public XmlParse(Element element){

            queueCount 	      =  Deger(element.getElementsByTagName("queueCount")).equals("null") ? null : Deger(element.getElementsByTagName("queueCount"));
            completedCount    =  Deger(element.getElementsByTagName("completedCount")).equals("null") ? null : Deger(element.getElementsByTagName("completedCount"));
            rejectCount	      =  Deger(element.getElementsByTagName("rejectCount")).equals("null") ? null : Deger(element.getElementsByTagName("rejectCount"));
            errorCount        =  Deger(element.getElementsByTagName("errorCount")).equals("null") ? null : Deger(element.getElementsByTagName("errorCount"));
            iysErrorCount     =  Deger(element.getElementsByTagName("iysErrorCount")).equals("null") ? null : Deger(element.getElementsByTagName("iysErrorCount"));
            recipient	      =  Deger(element.getElementsByTagName("recipient")).equals("null") ? null : Deger(element.getElementsByTagName("recipient"));
            type	          =  Deger(element.getElementsByTagName("type")).equals("null") ? null : Deger(element.getElementsByTagName("type"));
            source 		      =  Deger(element.getElementsByTagName("source")).equals("null") ? null : Deger(element.getElementsByTagName("source"));
            status	          =  Deger(element.getElementsByTagName("status")).equals("null") ? null : Deger(element.getElementsByTagName("status"));
            recipient_type	  =  Deger(element.getElementsByTagName("recipient_type")).equals("null") ? null : Deger(element.getElementsByTagName("recipient_type"));
            consent_date	  =  Deger(element.getElementsByTagName("consent_date")).equals("null") ? null : Deger(element.getElementsByTagName("consent_date"));
            iys_create_date	  =  Deger(element.getElementsByTagName("iys_create_date")).equals("null") ? null : Deger(element.getElementsByTagName("iys_create_date"));
            status_id	      =  Deger(element.getElementsByTagName("status_id")).equals("null") ? null : Deger(element.getElementsByTagName("status_id"));
            iys_error_msg	  =  Deger(element.getElementsByTagName("iys_error_msg")).equals("null") ? null : Deger(element.getElementsByTagName("iys_error_msg"));




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

<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
<%!
    String maskString(String strText, int start, int end, char maskChar)
            throws Exception{

        if(strText == null || strText.equals(""))
            return "";

        if(start < 0)
            start = 0;

        if( end > strText.length() )
            end = strText.length();

        if(start > end)
            throw new Exception("End index cannot be greater than start index");

        int maskLength = end - start;

        if(maskLength == 0)
            return strText;

        StringBuilder sbMaskString = new StringBuilder(maskLength);

        for(int i = 0; i < maskLength; i++){
            sbMaskString.append(maskChar);
        }

        return strText.substring(0, start)
                + sbMaskString.toString()
                + strText.substring(start + maskLength);
    }

    String maskEmailAddress(String strEmail, char maskChar)
            throws Exception{

        String[] parts = strEmail.split("@");

        //mask two part
        String strId = "";
        if(parts[1].length() < 4)
            strId = maskString(parts[1], 0, parts[1].length(), '*');
        else
            strId = maskString(parts[1], 0, parts[1].length()-3, '*');

        return parts[0] + "@" + strId;
    }
%>
<%
    JsonArray reportIysDashboard = new JsonArray();
    JsonObject ıysData = new JsonObject();
    Calendar calendar = Calendar.getInstance();
    calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);

    int current_year;
    int current_month;
    int current_month_cal;
    int current_day;
    String last_week;

    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
	
    current_day = calendar.get(Calendar.DAY_OF_MONTH);
    calendar.add(Calendar.DATE, -7);
    Date lastWeekNotFormat = calendar.getTime();
    last_week = new SimpleDateFormat("yyyy-MM-dd").format(lastWeekNotFormat);

    String today = current_year + "-" + current_month_cal + "-" + current_day;
    String firstDate = last_week;

    JSONArray result;

    String sCustId = cust.s_cust_id;
    String date1 = (request.getParameter("lastDate") != null) ? request.getParameter("lastDate") : firstDate;
    String date2 = (request.getParameter("firstDate") != null) ? request.getParameter("firstDate") : today;
    String date1ForCount = (request.getParameter("date1") != null) ? request.getParameter("date1") : "2020-05-01";



    Statement stmt = null;
    ConnectionPool cp = null;
    Connection conn = null;

    Integer queueCount = 0;
    Integer completedCount = 0;
    Integer rejectCount = 0;
    Integer errorCount = 0;
    Integer iysErrorCount = 0;

    try {

        cp = ConnectionPool.getInstance();


        conn = cp.getConnection(this);
        stmt = conn.createStatement();


        NodeList nodeList = null;

        StringWriter sw = new StringWriter();
        sw.write("<root>");
        sw.write("<ccps_dashboard>\r\n");
        sw.write("<cust_id><![CDATA[" + sCustId + "]]></cust_id>\r\n");
        sw.write("<date1><![CDATA[" + date1 + "]]></date1>\r\n");
        sw.write("<date2><![CDATA[" + date2 + "]]></date2>\r\n");
        sw.write("</ccps_dashboard>\r\n");
        sw.write("</root>");



        String sResponse = Service.communicate(126, sCustId, sw.toString());


        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));

        JsonArray ıysDataArr = new JsonArray();

        nodeList = document.getElementsByTagName("rrcp_dashboard_count_report");

        if(nodeList !=null) {
            ıysData = new JsonObject();
            XmlParse report = new XmlParse((Element) nodeList.item(0));

            queueCount      = Integer.parseInt(report.queueCount);
            completedCount  = Integer.parseInt(report.completedCount);
            rejectCount     = Integer.parseInt(report.rejectCount);
            errorCount      = Integer.parseInt(report.errorCount);
            iysErrorCount   = Integer.parseInt(report.iysErrorCount);
            ıysData.put("queueCount",queueCount);
            ıysData.put("completedCount",completedCount);
            ıysData.put("rejectCount",rejectCount);
            ıysData.put("errorCount",errorCount);
            ıysData.put("iysErrorCount",iysErrorCount);
            ıysDataArr.put(ıysData);
            System.out.println("Iys error for cust:" + sCustId + queueCount+completedCount+errorCount);

        }
        reportIysDashboard.put(ıysDataArr);
        ıysDataArr = new JsonArray();
        nodeList = document.getElementsByTagName("rrcp_IysProcess_report");
        if(nodeList !=null) {
            for (int i = 0; i < nodeList.getLength(); i++) {
                 ıysData = new JsonObject();

                XmlParse report = new XmlParse((Element) nodeList.item(i));

                String recipient        = report.recipient;
                String type             = report.type;
                String source           = report.source;
                String status           = report.status;
                String recipientType    = report.recipient_type;
                String consentDate      = report.consent_date;
                String iysCreateDate    = report.iys_create_date;
                Integer statusId         = report.status_id.equals("")? 0 : Integer.parseInt(report.status_id);
                String iysErrorMsg      = report.iys_error_msg;

                queueCount      = report.queueCount.equals("")? 0 : Integer.parseInt(report.queueCount);
                completedCount  = report.completedCount.equals("")? 0 : Integer.parseInt(report.completedCount);
                rejectCount     = report.rejectCount.equals("")? 0 : Integer.parseInt(report.rejectCount);
                errorCount      = report.errorCount.equals("")? 0 : Integer.parseInt(report.errorCount);
                iysErrorCount   = report.iysErrorCount.equals("")? 0 : Integer.parseInt(report.iysErrorCount);


                ıysData.put("type",type);
                ıysData.put("source",source);
                ıysData.put("iysStatus",status);
                ıysData.put("recipientType",recipientType);
                ıysData.put("consentDate",consentDate);
                if(statusId==45){
                    ıysData.put("statusId",statusId);
                    ıysData.put("statusName","Hatali Veri");
                }
                else if(statusId==10){
                    ıysData.put("statusId",statusId);
                    ıysData.put("statusName","Olusturuldu");
                }
                else if(statusId==15){
                    ıysData.put("statusId",statusId);
                    ıysData.put("statusName","Kuyrukta");
                }
                else if(statusId==30){
                    ıysData.put("statusId",statusId);
                    ıysData.put("statusName","Basarili");
                }
                else if(statusId==40){
                    ıysData.put("statusId",statusId);
                    ıysData.put("statusName","Hatali Veri");
                }
                else if(statusId==70){
                    ıysData.put("statusId",statusId);
                    ıysData.put("statusName","IYS Hatasi");
                }
                else{
                    ıysData.put("statusId",statusId);
                    ıysData.put("statusName","Diger");
                }
                ıysData.put("queueCount",queueCount);
                ıysData.put("completedCount",completedCount);
                ıysData.put("rejectCount",rejectCount);
                ıysData.put("errorCount",errorCount);
                ıysData.put("iysErrorCount",iysErrorCount);


                if(iysErrorMsg == null){
                    iysErrorMsg = "---";
                    ıysData.put("iysErrorMsg",iysErrorMsg);
                }else{
                    ıysData.put("iysErrorMsg",iysErrorMsg);
                }
                if(iysCreateDate  == null ){
                    iysCreateDate = "---";
                    ıysData.put("iysCreateDate",iysCreateDate);
                }else{
                    ıysData.put("iysCreateDate",iysCreateDate);

                }

                Map<Integer, String> statusMap = new HashMap<Integer, String>(6);

                statusMap.put(45, "Hatali Veri");
                statusMap.put(10, "Olusturuldu");
                statusMap.put(15, "Kuyrukta");
                statusMap.put(30, "Basarili");
                statusMap.put(40, "Hatali Veri");
                statusMap.put(70, "IYS Hatasi");
               String  maskEmailAddress =  maskEmailAddress(recipient,'@');
                ıysData.put("recipient",maskEmailAddress);


                ıysDataArr.put(ıysData);



            }
        }
        reportIysDashboard.put(ıysDataArr);
            out.print(reportIysDashboard.toString());

        stmt.close();

    } catch (Exception ex) {
        System.out.println("Iys error for cust:" + sCustId + ex);
        throw ex;
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection for cust:" + sCustId, e);
        }
    }


%>

