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


        public String productStatus = null;
        public String productName = null;
        public String link	                  = null;
        public String imageLink = null;
        public String productId = null;
        public String productPrice = null;
        public String productSalesPrice = null;



    public ProductListReport(Element element){

        productStatus =  Deger(element.getElementsByTagName("product_status")).equals("null") ? null : Deger(element.getElementsByTagName("product_status"));
        productName =  Deger(element.getElementsByTagName("product_name")).equals("null") ? null : Deger(element.getElementsByTagName("product_name"));
        link	              =  Deger(element.getElementsByTagName("link")).equals("null") ? null : Deger(element.getElementsByTagName("link"));
        imageLink =  Deger(element.getElementsByTagName("image_link")).equals("null") ? null : Deger(element.getElementsByTagName("image_link"));
        productId =  Deger(element.getElementsByTagName("product_id")).equals("null") ? null : Deger(element.getElementsByTagName("product_id"));
        productPrice =  Deger(element.getElementsByTagName("product_price")).equals("null") ? null : Deger(element.getElementsByTagName("product_price"));
        productSalesPrice =  Deger(element.getElementsByTagName("product_sales_price")).equals("null") ? null : Deger(element.getElementsByTagName("product_sales_price"));

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

    Statement statement = null;
    ConnectionPool connectionPool	=null;
    Connection connection			=null;

    StringBuilder tableTR = new StringBuilder();

    JsonObject data = new JsonObject();
    JsonArray dataArray = new JsonArray();


    StringWriter stringWriter = new StringWriter();
    try {
        System.out.println("ProductListReport is loading...");

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection("product_list");
        String custId = "646";

        NodeList nodeList = null;


//			BufferedReader bufferedReader = new BufferedReader(new InputStreamReader((request.getInputStream()), "UTF-8"));
//			DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
//			DocumentBuilder builder = builderFactory.newDocumentBuilder();
//			Document document = builder.parse(new InputSource(bufferedReader));

        stringWriter.write("<root>");
        stringWriter.write("<ccps_product_list>\r\n");
        stringWriter.write("<cust_id><![CDATA[" + custId + "]]></cust_id>\r\n");
        stringWriter.write("</ccps_product_list>\r\n");
        stringWriter.write("</root>");
        


        String sResponse = Service.communicate(124, custId, stringWriter.toString());


        sResponse = sResponse.substring(41);

      //  System.out.println("Response:" + sResponse);

        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();


        Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));

        nodeList = document.getElementsByTagName("rrcp_product_list_report");

        if (nodeList != null && !nodeList.equals("null")) {
            for (int i = 0; i < nodeList.getLength(); i++) {
                data =  new JsonObject();
                ProductListReport report = new ProductListReport((Element) nodeList.item(i));

                data.put("prdoductName",report.productName);
                data.put("productStatus",report.productStatus);
                data.put("link",report.link);
                data.put("imageLink",report.imageLink);
                data.put("productId",report.productId);
                data.put("productPrice",report.productPrice);
                data.put("productSales_price",report.productSalesPrice);

                dataArray.put(data.toString());


            }

        }
    }	catch (Exception e){

        throw e;

    }finally {
        try {
            if (statement !=null) statement.close();
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
