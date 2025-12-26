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
	public class ListActivityReport{		//++++
		private Element s_listActivityReport=null;

		public String cust_id= null;
		public String camp_id= null;
		public String sent = null;
		public String bbacks = null;
		public String dist_reads = null;
		public String dist_clicks = null;
		public String start_date = null;

		public String send_date = null;
		public String rque_count = null;

		public String click_time = null;
		public String type_id = null;
		public String rjtk_count = null;

		public String sql = null;



		ConnectionPool connectionPool=null;
		Connection connection=null;
		PreparedStatement statement=null;




		public ListActivityReport(Element element, String table){

			if(table == "rrpt_camp_summary_and_rque_campaign") {
				cust_id = Deger(element.getElementsByTagName("cust_id"));
				sent = Deger(element.getElementsByTagName("sent"));
				bbacks = Deger(element.getElementsByTagName("bbacks"));
				dist_reads = Deger(element.getElementsByTagName("dist_reads"));
				dist_clicks = Deger(element.getElementsByTagName("dist_clicks"));
				start_date = Deger(element.getElementsByTagName("start_date"));
			}

			if(table == "rrcp_rque_message") {
				cust_id = Deger(element.getElementsByTagName("cust_id"));
				send_date = Deger(element.getElementsByTagName("send_date"));
				rque_count = Deger(element.getElementsByTagName("rque_count"));
			}

			if(table == "rrcp_rjtk_link_activity") {
				cust_id = Deger(element.getElementsByTagName("cust_id"));
				camp_id = Deger(element.getElementsByTagName("camp_id"));
				click_time = Deger(element.getElementsByTagName("click_time"));
				type_id = Deger(element.getElementsByTagName("type_id"));
				rjtk_count = Deger(element.getElementsByTagName("rjtk_count"));
			}
		}

		public void save(boolean is_first, String table)throws Exception{

			try {

				connectionPool=ConnectionPool.getInstance();
				connection=connectionPool.getConnection(this);

				if(table == "rrpt_camp_summary_and_rque_campaign"){
					if (is_first) {
						sql = "delete from ccps_rrpt_camp_summary_and_rque_campaign where cust_id = ?";
						statement = connection.prepareStatement(sql);
						statement.setString(1, cust_id);
						statement.executeUpdate();
					}

					sql = "INSERT INTO ccps_rrpt_camp_summary_and_rque_campaign (cust_id, sent , bbacks, dist_reads, dist_clicks, start_date) VALUES(?,?,?,?,?,?)";    //++++
					statement = connection.prepareStatement(sql);
					int x = 1;

					statement.setString(x++, cust_id.equals("null") ? null : cust_id);
					statement.setString(x++, sent.equals("null") ? null : sent);
					statement.setString(x++, bbacks.equals("null") ? null : bbacks);
					statement.setString(x++, dist_reads.equals("null") ? null : dist_reads);
					statement.setString(x++, dist_clicks.equals("null") ? null : dist_clicks);
					statement.setString(x++, start_date.equals("null") ? null : start_date);

					statement.executeUpdate();
				}

				if(table == "rrcp_rque_message"){
					if (is_first) {

						sql = "delete from ccps_rque_message where cust_id = ?";
						statement = connection.prepareStatement(sql);
						statement.setString(1, cust_id);
						statement.executeUpdate();

					}

					sql = "INSERT INTO ccps_rque_message (cust_id , send_date, rque_count) VALUES(?,?,?)";    //++++
					statement = connection.prepareStatement(sql);
					int x = 1;

					statement.setString(x++, cust_id.equals("null") ? null : cust_id);
					statement.setString(x++, send_date.equals("null") ? null : send_date);
					statement.setString(x++, rque_count.equals("null") ? null : rque_count);

					statement.executeUpdate();
				}

				if(table == "rrcp_rjtk_link_activity"){
					if (is_first) {
						sql = "delete from ccps_rjtk_link_activity where cust_id = ?";
						statement = connection.prepareStatement(sql);
						statement.setString(1, cust_id);
						statement.executeUpdate();
					}

					sql = "INSERT INTO ccps_rjtk_link_activity (cust_id, camp_id, click_time, type_id, rjtk_count) VALUES(?,?,?,?,?)";    //++++
					statement = connection.prepareStatement(sql);
					int x = 1;

					statement.setString(x++, cust_id.equals("null") ? null : cust_id);
					statement.setString(x++, camp_id.equals("null") ? null : camp_id);
					statement.setString(x++, click_time.equals("null") ? null : click_time);
					statement.setString(x++, type_id.equals("null") ? null : type_id);
					statement.setString(x++, rjtk_count.equals("null") ? null : rjtk_count);

					statement.executeUpdate();
				}


			}
			catch (Exception exception){
				System.out.println("Save Function for ccps_list_activity :"+exception);
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
		System.out.println("list_activity_report is loading...");


		BufferedReader bufferedReader         = new BufferedReader(new InputStreamReader((request.getInputStream()),"UTF-8"));
		DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder               = builderFactory.newDocumentBuilder();
		Document document                     = builder.parse(new InputSource(bufferedReader));


		try{

			NodeList nodeList = document.getElementsByTagName("rrpt_camp_summary_and_rque_campaign");


			boolean is_first= true;
			for (int i=0;i<nodeList.getLength();i++){
				ListActivityReport report = new ListActivityReport((Element) nodeList.item(i),"rrpt_camp_summary_and_rque_campaign");


				report.save(is_first,"rrpt_camp_summary_and_rque_campaign");
				is_first =false;
			}


			nodeList = document.getElementsByTagName("rrcp_rque_message");

			is_first= true;
			for (int i=0;i<nodeList.getLength();i++){
				ListActivityReport report = new ListActivityReport((Element) nodeList.item(i),"rrcp_rque_message");


				report.save(is_first,"rrcp_rque_message");
				is_first =false;
			}


			nodeList = document.getElementsByTagName("rrcp_rjtk_link_activity");

			is_first= true;
			for (int i=0;i<nodeList.getLength();i++){
				ListActivityReport report = new ListActivityReport((Element) nodeList.item(i),"rrcp_rjtk_link_activity");


				report.save(is_first,"rrcp_rjtk_link_activity");
				is_first =false;
			}


		}catch (Exception e){
			System.out.println("Nodelist initialize error"+e);
		}
	}
	catch (Exception ex) {
		logger.error("list_activity_report Update Error!\r\n", ex);
	}
%>