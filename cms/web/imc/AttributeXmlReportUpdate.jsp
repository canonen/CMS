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
	public class AttributeXmlReport{		//++++
		private Element s_AttributeXmlReport=null;

		public String cust_id= null;
		public String task_name = null;
		public String start_date = null;
		public String finish_date = null;
		public String record_count = null;
		public String status = null;
		public String sql = null;


		ConnectionPool connectionPool=null;
		Connection connection=null;
		PreparedStatement statement=null;




		public AttributeXmlReport(Element element){

			cust_id	= Deger(element.getElementsByTagName("cust_id"));
			task_name = Deger(element.getElementsByTagName("task_name"));
			start_date= 	Deger(element.getElementsByTagName("start_date"));
			finish_date = 	Deger(element.getElementsByTagName("finish_date"));
			record_count= 	Deger(element.getElementsByTagName("record_count"));
			status = 	Deger(element.getElementsByTagName("status"));

		}

		public void save(boolean is_first)throws Exception{

			try {

				connectionPool=ConnectionPool.getInstance();
				connection=connectionPool.getConnection(this);

				if(is_first) {
					sql = "delete from ccps_attribute_xml_summary where cust_id = ?";
					statement = connection.prepareStatement(sql);
					statement.setString(1, cust_id);
					statement.executeUpdate();
				}

				sql = "INSERT INTO ccps_attribute_xml_summary (cust_id,task_name,start_date,finish_date,record_count,status) VALUES(?,?,?,?,?,?)";    //++++
				statement = connection.prepareStatement(sql);
				int x = 1;

				statement.setString(x++, cust_id.equals("null") ? null : cust_id);
				statement.setString(x++, task_name.equals("null") ? null : task_name);
				statement.setString(x++, start_date.equals("null") ? null : start_date);
				statement.setString(x++, finish_date.equals("null") ? null : finish_date);
				statement.setString(x++, record_count.equals("null") ? null : record_count);
				statement.setString(x++, status.equals("null") ? null : status);

				statement.executeUpdate();


			}
			catch (Exception exception){
				System.out.println("Save Function for ccps_attribute_xml_summary:"+exception);
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
            if (str != null && str.length() > 0 && !str.isEmpty()) {
                str = str.replace("\\", "\\\\");
                str = str.replace("\"", "");
                str = str.replace("&quot;", " ");
                str = str.replace("\0", "\\0");
                str = str.replace("\n", "\\n");
                str = str.replace("\r", "\\r");
                str = str.replace("\"", "\\\"");
                str = str.replace("\\x1a", "\\Z");
                str = str.replace("Ã„Â±", "ı");
                str = str.replace("Ã„Â°", "İ");
                str = str.replace("Ã„ÂŸ", "ğ");
                str = str.replace("Ã„Âž", "Ğ");
                str = str.replace("Ã…ÅŸ", "ş");
                str = str.replace("Ã…Åž", "Ş");
                str = str.replace("ÃƒÂ¼", "ü");
                str = str.replace("ÃƒÂ–", "Ö");
                str = str.replace("ÃƒÂœ", "Ü");
                str = str.replace("Ãœ", "Ü");
                str = str.replace("ÃƒÂ§", "ç");
                str = str.replace("Ãƒâ€¹", "Ç");
                str = str.replace("Ã\u2021", "Ç");
                str = str.replace("ÃƒÂ¶", "ö");
                str = str.replace("Ä±", "ı");
                str = str.replace("Ä°", "İ");
                str = str.replace("ÄŸ", "ğ");
                str = str.replace("Äž", "Ğ");
                str = str.replace("ÅŸ", "ş");
                str = str.replace("Å\u009f", "ş");
                str = str.replace("Åž", "Ş");
                str = str.replace("Ã¼", "ü");
                str = str.replace("Ãœ", "Ü");
                str = str.replace("Ã§", "ç");
                str = str.replace("ã§", "ç");
                str = str.replace("Ã‡", "Ç");
                str = str.replace("Ã¶", "ö");
                str = str.replace("Ã–", "Ö");
                str = str.replace("Ã§", "ç");
                str = str.replace("Ã‡", "Ç");
                str = str.replace("Ã\u0087", "Ç");
                str = str.replace("Ã„ÂŸ", "ğ");
                str = str.replace("Ã„Âž", "Ğ");
                str = str.replace("Ã…ÅŸ", "ş");
                str = str.replace("Ã…Åž", "Ş");
                str = str.replace("ÃƒÂ¼", "ü");
                str = str.replace("ã¼", "ü");
                str = str.replace("ÃƒÂœ", "Ü");
                str = str.replace("ÃƒÂ¶", "ö");
                str = str.replace("ÃƒÂ–", "Ö");
                str = str.replace("Ã„Â±", "ı");
                str = str.replace("Ã„Â°", "İ");
                str = str.replace("Â±", "ı");
                str = str.replace("Â§", "Ş");
                str = str.replace("Âş", "ş");
                str = str.replace("Ì\u0087", "");
                str = str.replace("Â", "");
                str = str.replace("Ã", "");
                str = str.replace("Å", "");
            }
            return str;
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
		System.out.println("ccps_attribute_xml_summary is loading...");


		BufferedReader bufferedReader         = new BufferedReader(new InputStreamReader((request.getInputStream()),"UTF-8"));
		DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder               = builderFactory.newDocumentBuilder();
		Document document                     = builder.parse(new InputSource(bufferedReader));


		try{

			NodeList nodeList = document.getElementsByTagName("rrcp_attribute_xml_summary");


			boolean is_first= true;
			for (int i=0;i<nodeList.getLength();i++){
				AttributeXmlReport report = new AttributeXmlReport((Element) nodeList.item(i));


				report.save(is_first);
				is_first =false;
			}


		}catch (Exception e){
			System.out.println("Nodelist initialize error"+e);
		}
	}
	catch (Exception ex) {
		logger.error("ccps_attribute_xml_summary Update Error!\r\n", ex);
	}
%>