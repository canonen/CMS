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
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="sun.nio.ch.IOUtil" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="org.xml.sax.SAXException" %>
<%@ page import="org.xml.sax.SAXParseException" %>
<%@ page import="org.apache.axis.ConfigurationException" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
//+++
<%! static Logger logger = null;%>
<%!
	public class XmlParse{		//++++

		public String cust_id= null;
		public String date = null;
		public String orders = null;
		public String customers = null;
		public String camp_id   = null;
		public String amount_sum = null;

		public String sql = null;



		ConnectionPool connectionPool=null;
		Connection connection=null;
		PreparedStatement statement=null;




		public XmlParse(Element element ){

			cust_id = Deger(element.getElementsByTagName("cust_id"));
			date = Deger(element.getElementsByTagName("date"));
			orders = Deger(element.getElementsByTagName("orders"));
			customers = Deger(element.getElementsByTagName("customers"));
			camp_id = Deger(element.getElementsByTagName("camp_id"));
			amount_sum = Deger(element.getElementsByTagName("amount_sum"));

		}

		public void save(boolean is_first)throws Exception{

			try {
				connectionPool=ConnectionPool.getInstance();
				connection=connectionPool.getConnection(this);
				if (is_first) {

					sql = "delete from untt_mbs_order_date where cust_id = ?";
					statement = connection.prepareStatement(sql);
					statement.setString(1, cust_id);
					statement.executeUpdate();
				}


				sql = "INSERT INTO untt_mbs_order_date (cust_id, date ,orders, customers, camp_id, amount_sum) VALUES(?,?,?,?,?,?)";    //++++
				statement = connection.prepareStatement(sql);
				int x = 1;

				statement.setString(x++, cust_id.equals("null") ? null : cust_id);
				statement.setString(x++, date.equals("null") ? null : date);
				statement.setString(x++, orders.equals("null") ? null : orders);
				statement.setString(x++, customers.equals("null") ? null : customers);
				statement.setString(x++, camp_id.equals("null") ? null : camp_id);
				statement.setString(x++, amount_sum.equals("null") ? null : amount_sum);

				statement.executeUpdate();

			}
			catch (Exception exception){
				System.out.println("Save Function for mbs_order_date for cust :"+cust_id+exception);
				throw exception;
			}finally {
				if (statement != null) {
					statement.close();

				}
				if(connection!=null) {
					connectionPool.free(connection);

				}
			}
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
<%@ include file="header.jsp" %>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	try
	{
		System.out.println("untt_mbs_order_date is loading...");


		BufferedReader bufferedReader         = new BufferedReader(new InputStreamReader((request.getInputStream()),"UTF-8"));
		DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder               = builderFactory.newDocumentBuilder();
		Document document                     = builder.parse(new InputSource(bufferedReader));


		try{

			NodeList nodeList = document.getElementsByTagName("rrcp_untt_mbs_order_date");


			boolean is_first= true;
			for (int i=0;i<nodeList.getLength();i++){
				XmlParse report = new XmlParse((Element) nodeList.item(i));


				report.save(is_first);
				is_first =false;
			}



		}catch (Exception e){
			System.out.println("Nodelist initialize error"+e);
		}
	}
	catch (Exception ex) {
		logger.error("Update_untt_mbs_order_date Update Error!\r\n", ex);
	}
%>