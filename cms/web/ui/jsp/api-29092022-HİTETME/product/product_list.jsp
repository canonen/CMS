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

<%!
    public class ProductListReport{


        public String product_status 		  = null;
        public String product_name	          = null;
        public String link	                  = null;
        public String image_link	          = null;
        public String product_id	          = null;
        public String product_price	          = null;
        public String product_sales_price	  = null;



    public ProductListReport(Element element){

        product_status 		  =  Deger(element.getElementsByTagName("product_status")).equals("null") ? null : Deger(element.getElementsByTagName("product_status"));
        product_name	      =  Deger(element.getElementsByTagName("product_name")).equals("null") ? null : Deger(element.getElementsByTagName("product_name"));
        link	              =  Deger(element.getElementsByTagName("link")).equals("null") ? null : Deger(element.getElementsByTagName("link"));
        image_link	          =  Deger(element.getElementsByTagName("image_link")).equals("null") ? null : Deger(element.getElementsByTagName("image_link"));
        product_id	          =  Deger(element.getElementsByTagName("product_id")).equals("null") ? null : Deger(element.getElementsByTagName("product_id"));
        product_price	      =  Deger(element.getElementsByTagName("product_price")).equals("null") ? null : Deger(element.getElementsByTagName("product_price"));
        product_sales_price	  =  Deger(element.getElementsByTagName("product_sales_price")).equals("null") ? null : Deger(element.getElementsByTagName("product_sales_price"));

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

<%

    Statement stmt  = null;
    ConnectionPool connectionPool	=null;
    Connection connection			=null;

    StringBuilder TABLETR = new StringBuilder();

    JsonObject data = new JsonObject();
    JsonArray dataArray = new JsonArray();


    StringWriter sw = new StringWriter();
    try {
        System.out.println("ProductListReport is loading...");

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection("product_list");
        String cust_id = "646";

        NodeList nodeList = null;


//			BufferedReader bufferedReader = new BufferedReader(new InputStreamReader((request.getInputStream()), "UTF-8"));
//			DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
//			DocumentBuilder builder = builderFactory.newDocumentBuilder();
//			Document document = builder.parse(new InputSource(bufferedReader));

        sw.write("<root>");
        sw.write("<ccps_product_list>\r\n");
        sw.write("<cust_id><![CDATA[" + cust_id + "]]></cust_id>\r\n");
        sw.write("</ccps_product_list>\r\n");
        sw.write("</root>");
        


        String sResponse = Service.communicate(124, cust_id, sw.toString());


        sResponse = sResponse.substring(41);

      //  System.out.println("Response:" + sResponse);

        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();


        Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));

        nodeList = document.getElementsByTagName("rrcp_product_list_report");

        if (nodeList != null && !nodeList.equals("null")) {
            for (int i = 0; i < nodeList.getLength(); i++) {
                data =  new JsonObject();
                ProductListReport report = new ProductListReport((Element) nodeList.item(i));

                data.put("prdoductName",report.product_name);
                data.put("productStatus",report.product_status);
                data.put("link",report.link);
                data.put("imageLink",report.image_link);
                data.put("productId",report.product_id);
                data.put("productPrice",report.product_price);
                data.put("productSales_price",report.product_sales_price);

                dataArray.put(data.toString());


            }

        }
    }	catch (Exception e){

        throw e;

    }finally {
        try {
            if (stmt!=null) stmt.close();
            if (connection!=null) connectionPool.free(connection);
        }catch (SQLException e){
            System.out.println(e);
        }
    }

    

    


%>

<%

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
    out.print(dataArray.toString());
%>
