<%@ page
		language="java"
		import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Calendar,
                java.io.*,
                org.apache.log4j.Logger,
                java.text.DateFormat,
                org.json.JSONArray,
                org.json.JSONObject,
                org.w3c.dom.*"
		errorPage="../../utilities/error_page.jsp"
		contentType="text/html;charset=UTF-8"
%>
<%
	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin", "*");
%>
<%
	System.out.println("--------------FROMADDRESS------------");

	String sCustId = request.getParameter("custId");
	Statement statement = null;
	ResultSet resultSet = null;
	ConnectionPool connectionPool = null;
	Connection connection = null;
%>
<%
	try {
		connectionPool = ConnectionPool.getInstance();
		connection = connectionPool.getConnection(this);
		statement = connection.createStatement();

		Integer fromAddressId = 0;
		String prefix = null;
		String domain = null;

		String fromAddressSqlQuery = "select from_address_id, prefix, domain from ccps_from_address where cust_id=" + sCustId + " order by  prefix";

		resultSet = statement.executeQuery(fromAddressSqlQuery);

		JSONArray array = new JSONArray();


		while (resultSet.next()) {

			fromAddressId = resultSet.getInt(1);
			prefix = resultSet.getString(2);
			domain = resultSet.getString(3);

			JSONObject data = new JSONObject();
			data.put("from_address_id", fromAddressId);
			data.put("prefix", prefix+"@"+domain);
			data.put("domain", domain);
			array.put(data);
		}
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("FromAddress", array);

		resultSet.close();

		out.print(jsonObject);

	} catch (Exception exception) {
		System.out.println(sCustId + exception.getMessage());
		exception.printStackTrace();
	} finally {
		if (statement != null) {
			statement.close();
			connection.close();
		}
	}


%>

