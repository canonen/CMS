<%@ page
		language="java"
		import="com.britemoon.*,
		        com.britemoon.cps.*,
		        com.britemoon.cps.adm.*,
		        com.britemoon.cps.que.*,
		        com.britemoon.cps.ctl.*,
		        java.util.*,
		        java.sql.*,
		        java.io.*,
		        java.net.*,
		        java.text.DateFormat,
		        org.apache.log4j.*"
		errorPage="../error_page.jsp"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin", "http://cms.revotas.com:3001");
	response.setHeader("Access-Control-Allow-Credentials", "true");
%>

<%@ include file="../validator.jsp" %>

<%! static Logger logger = null;%>
<%
	if (logger == null) {
		logger = Logger.getLogger(this.getClass().getName());
	}

	String custId = user.s_cust_id;

	String templateId = "";
	String category = "";
	String customerId = "";
	String name = "";
	String sections = "";
	String smallImage = "";
	String largeImage = "";
	String globalFlag = "";
	String active = "";
	String approvalFlag = "";

	JsonObject jsonObject = new JsonObject();
	JsonArray jsonArray = new JsonArray();

	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	ResultSet resultSet = null;
	InputStream inputStream = null;


	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		String query =
				"select  template_id,category,customer_id,name,sections_n,template_html,template_txt,template_mjml,small_image,large_image" +
						" ,global_flag,active,approval_flag from ctm_templates where customer_id = '" + custId + "' " +
						" UNION ALL select template_id,category,customer_id,name,sections_n,template_html,template_txt," +
						" template_mjml,small_image,large_image,global_flag,active,approval_flag FROM ctm_templates;";
		resultSet = stmt.executeQuery(query);
		while (resultSet.next()) {
			out.print("test");
			jsonObject = new JsonObject();
			templateId = resultSet.getString("template_id");
			jsonObject.put("templateId", templateId);
			category = resultSet.getString("category");
			jsonObject.put("category", category);
			customerId = resultSet.getString("customer_id");
			jsonObject.put("customerId", customerId);
			name = resultSet.getString("name");
			jsonObject.put("name", name);
			sections = resultSet.getString("sections_n");
			jsonObject.put("sections", sections);

			out.print(jsonObject);
			inputStream = resultSet.getBinaryStream("template_html");
			ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
			int bytesRead;
			byte[] buffer = new byte[4096];
			while ((bytesRead = inputStream.read(buffer)) != -1) {
				byteArrayOutputStream.write(buffer, 0, bytesRead);
			}
			byte[] blobData = byteArrayOutputStream.toByteArray();
			String templateHTMLString = new String(blobData, "UTF-8");
			jsonObject.put("templateHTML", templateHTMLString);


			inputStream = resultSet.getBinaryStream("template_txt");
			byteArrayOutputStream = new ByteArrayOutputStream();
			bytesRead = 0;
			buffer = new byte[4096];
			while ((bytesRead = inputStream.read(buffer)) != -1) {
				byteArrayOutputStream.write(buffer, 0, bytesRead);
			}
			byte[] templateTXTData = byteArrayOutputStream.toByteArray();
			String templateTXTString = new String(templateTXTData, "UTF-8");
			jsonObject.put("templateTEXT", templateTXTString);

			inputStream = resultSet.getBinaryStream("template_mjml");
			if(inputStream != null){
				byteArrayOutputStream = new ByteArrayOutputStream();
				bytesRead = 0;
				buffer = new byte[4096];

				while ((bytesRead = inputStream.read(buffer)) != -1) {
					byteArrayOutputStream.write(buffer, 0, bytesRead);
				}

				byte[] templateMJMLData = byteArrayOutputStream.toByteArray();

				String templateMJMLString = new String(templateMJMLData, "UTF-8");
				jsonObject.put("templateMJML", templateMJMLString);
			}
			else {
				jsonObject.put("templateMJML", "");
			}

			smallImage = resultSet.getString("small_image");
			jsonObject.put("smallImage", smallImage);
			largeImage = resultSet.getString("large_image");
			jsonObject.put("largeImage", largeImage);
			globalFlag = resultSet.getString("global_flag");
			jsonObject.put("globalFlag", globalFlag);
			active = resultSet.getString("active");
			jsonObject.put("active", active);
			approvalFlag = resultSet.getString("approval_flag");
			jsonObject.put("approvalFlag", approvalFlag);

			jsonArray.put(jsonObject);
		}
		out.print(jsonArray);
		resultSet.close();


	} catch (Exception exception) {
		exception.printStackTrace();
	} finally {
		if (resultSet != null) {
			resultSet.close();
		}
		if (stmt != null) {
			stmt.close();
		}
		if (conn != null) {
			cp.free(conn);
		}
	}
%>

