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
<%@ page import="org.xml.sax.InputSource" %>

<%! static Logger logger = null;%>
<%!
	public class ProductAttrUpdate{		//++++

		public String attr_id = null;
		public String attr_name = null;
		public String attr_tag_name = null;
		public String attr_name_desc = null;
		public String type_id = null;
		public String cust_id= null;
		public String is_list = null;

		public String sql;

		ConnectionPool connectionPool=null;
		Connection connection=null;
		PreparedStatement statement=null;




		public ProductAttrUpdate(Element element){

			attr_id 		= Deger(element.getElementsByTagName("attr_id"));
			attr_name		= Deger(element.getElementsByTagName("attr_name"));
			attr_tag_name 	= Deger(element.getElementsByTagName("attr_tag_name"));
			attr_name_desc	= Deger(element.getElementsByTagName("attr_name_desc"));
			type_id 		= Deger(element.getElementsByTagName("type_id"));
			cust_id			= Deger(element.getElementsByTagName("cust_id"));
			is_list			= Deger(element.getElementsByTagName("is_list"));
		}

		public void save()throws Exception{

			try {

				connectionPool=ConnectionPool.getInstance();
				connection=connectionPool.getConnection(this);



				sql = "INSERT INTO ccps_product_attribute " +
						"(attr_id, attr_name, attr_tag_name, attr_name_desc,type_id, cust_id, is_list) " +
						"VALUES(?,?,?,?,?,?,?) ";    //++++
				statement = connection.prepareStatement(sql);
				int x = 1;

				statement.setString(x++, attr_id.equals("null") ? null : attr_id);
				statement.setString(x++, attr_name.equals("null") ? null : attr_name);
				statement.setString(x++, attr_tag_name.equals("null") ? null : attr_tag_name);
				statement.setString(x++, attr_name_desc.equals("null") ? null : attr_name_desc);
				statement.setString(x++, type_id.equals("null") ? null : type_id);
				statement.setString(x++, cust_id.equals("null") ? null : cust_id);
				statement.setString(x++, is_list.equals("null") ? null : is_list);

				statement.executeUpdate();


			}
			catch (Exception exception){
				System.out.println("Save Function for ProductAttrUpdate:"+exception);
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
		System.out.println("ProductAttrUpdate is loading...");


		BufferedReader bufferedReader         = new BufferedReader(new InputStreamReader((request.getInputStream()),"UTF-8"));
		DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder               = builderFactory.newDocumentBuilder();
		Document document                     = builder.parse(new InputSource(bufferedReader));


		try{

			NodeList nodeList = document.getElementsByTagName("rrcp_product_attr_report");


			for (int i=0;i<nodeList.getLength();i++){
				ProductAttrUpdate report = new ProductAttrUpdate((Element) nodeList.item(i));


				report.save();
			}


		}catch (Exception e){
			System.out.println("Nodelist initialize error"+e);
		}
	}
	catch (Exception ex) {
		logger.error("ProductAttrUpdate Update Error!\r\n", ex);
	}
%>