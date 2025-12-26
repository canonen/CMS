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

<%!
	public class ProductListReport{		//++++

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


		public String Deger(NodeList g1) {
            JsonObject json = new JsonObject();

            if (g1.getLength() > 0) {
                Element g1_Element = (Element) g1.item(0);
                NodeList text_g1 = g1_Element.getChildNodes();
                if (text_g1.item(0) != null) {
                    String deger = ((Node) text_g1.item(0)).getNodeValue().trim();
                    json.put("", deger);
                }
            }

            return json.toString();
        }
	}
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	Statement stmt  = null;
	ConnectionPool connectionPool	=null;
	Connection connection			=null;

	StringBuilder TABLETR = new StringBuilder();
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
	StringWriter sw = new StringWriter();
	int iCount=0;
	try
	{

		connectionPool	= ConnectionPool.getInstance();
		connection		= connectionPool.getConnection("report_product_lists");
		String cust_id	= cust.s_cust_id;

		NodeList nodeList = null;
            
            sw.write("<root>");
			sw.write("<ccps_product_list>");
			sw.write("<cust_id><![CDATA[" + cust_id + "]]></cust_id>");
			sw.write("</ccps_product_list>");
			sw.write("</root>");

			String sResponse = Service.communicate(124, cust_id, sw.toString());


			sResponse = sResponse.substring(41);


			DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();


			Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));


			nodeList = document.getElementsByTagName("rrcp_product_list_report");
//		}
		if(nodeList !=null) {
            JsonObject productObject = new JsonObject();
            JsonArray  productArray = new JsonArray(); 
            String jsonStr = null; 
			for (int i = 0; i < nodeList.getLength(); i++) {
                productObject = new JsonObject();
				ProductListReport report = new ProductListReport((Element) nodeList.item(i));
                productObject.put("link",report.link);
                productObject.put("image_link",report.image_link);
                productObject.put("product_name",report.product_name);
                productObject.put("product_id",report.product_id);
                productObject.put("product_status",report.product_status);
                productObject.put("product_price",report.product_price);
                productObject.put("product_sales_price",report.product_sales_price);
                productArray.put(productObject);
			}
            
            jsonObject.put("data",productArray);
		}
        jsonArray.put(jsonObject);
        out.print(jsonArray);
	}
	catch (Exception e){
		logger.error("ProductListReport Update Error!\r\n", e);
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




