<%@ page language="java" import="com.britemoon.*,
                                 com.britemoon.cps.*,
                                 com.britemoon.cps.imc.*,
                                 java.sql.*,
                                 java.net.*,
                                 java.io.*,
                                 java.util.*,
                                 java.text.DateFormat,
                                 org.apache.log4j.*" errorPage="../error_page.jsp"
         contentType="text/html;charset=UTF-8" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

<%

	String popupId = request.getParameter("popup_id");

	ConnectionPool connectionPool = null;
	Connection connection = null;
	PreparedStatement preparedStatement = null;
	Service service = null;
	ResultSet resultSet = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
	service = (Service) services.get(0);
	String rcpUrl = service.getURL().getHost();
	String custId = cust.s_cust_id;

    String configParam = null;
    JsonObject configParamObj = new JsonObject();
	JsonObject jsonObject = new JsonObject();
	JsonArray jsonArray = new JsonArray();
	try {
		connectionPool = ConnectionPool.getInstance();
		connection = connectionPool.getConnection(this);

		String sqlQuery = "SELECT swc.cust_id, swc.popup_id, swc.popup_name, swc.form_id, " +
				"swc.config_param, swc.create_date, swc.modify_date, swc.order_number, swc.status, " +
				"swc.rcp_link , swei.creator_id as user_create_id , swei.create_date as user_create_date , swei.modifier_id as user_modifier_id , swei.modify_date as user_modify_date " +
				"FROM c_smart_widget_config as swc " +
				"LEFT JOIN c_smart_widget_edit_info AS swei  ON  swei.smartwidget_id = swc.id " +
				"WHERE swc.cust_id = ? AND swc.popup_id = ?";
		preparedStatement = connection.prepareStatement(sqlQuery);
		preparedStatement.setString(1, custId);
		preparedStatement.setString(2, popupId);
		resultSet = preparedStatement.executeQuery();

		while (resultSet.next()) {
			jsonObject = new JsonObject();
			jsonObject.put("cust_id", resultSet.getString("cust_id"));
			jsonObject.put("popup_id", resultSet.getString("popup_id"));
			String originalString = resultSet.getString("popup_name");
//			jsonObject.put("popup_name", resultSet.getString("popup_name"));
			jsonObject.put("popup_name", editCharacter(originalString));
			jsonObject.put("form_id", resultSet.getString("form_id"));
			configParam =  resultSet.getString("config_param");
            configParamObj = new JsonObject(configParam);
            jsonObject.put("config_param",configParamObj);
			jsonObject.put("create_date", resultSet.getString("create_date"));
			jsonObject.put("modify_date", resultSet.getString("modify_date"));
			jsonObject.put("order_number", resultSet.getString("order_number"));
			jsonObject.put("status", resultSet.getString("status"));
			jsonObject.put("rcp_link", resultSet.getString("rcp_link"));
			User creatorUser = new User(resultSet.getString("user_create_id"));
			jsonObject.put("user_create", creatorUser.s_user_name + " " + creatorUser.s_last_name);
			jsonObject.put("user_create_date", resultSet.getString("user_create_date") == null ? "" : resultSet.getString("user_create_date"));
			User modifierUser = new User(resultSet.getString("user_modifier_id"));
			jsonObject.put("user_modifier", modifierUser.s_user_name + " " + modifierUser.s_last_name);
			jsonObject.put("user_modify_date", resultSet.getString("user_modify_date") == null ? "" : resultSet.getString("user_modify_date"));
			jsonArray.put(jsonObject);
		}
		resultSet.close();
		out.print(jsonArray);
	} catch (Exception exception) {
		exception.printStackTrace();
	} finally {
		try {
			if (resultSet != null) {
				resultSet.close();
			}
			if (preparedStatement != null) {
				preparedStatement.close();
			}
			if (connection != null) {
				connectionPool.free(connection);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
%>
<%!
	public static String editCharacter(String value) {
		value = value.replace("Ä\u009f", "ğ")
				.replace("Ä\u009e", "Ğ")
				.replace("Ã§", "ç")
				.replace("Ã\u0087", "Ç")
				.replace("Å\u009f", "ş")
				.replace("Å\u009e", "Ş")
				.replace("Ã¼", "ü")
				.replace("Ã\u009c", "Ü")
				.replace("Ã¶", "ö")
				.replace("Ã\u0096", "Ö")
				.replace("Ä±", "ı")
				.replace("Ä°", "İ");
		return value;
	}
%>
