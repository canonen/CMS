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
<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

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

		String sqlQuery = "SELECT cust_id, popup_id, popup_name, form_id, config_param, create_date, modify_date, order_number, status, rcp_link FROM c_smart_widget_config WHERE cust_id = ? AND popup_id = ?";
		preparedStatement = connection.prepareStatement(sqlQuery);
		preparedStatement.setString(1, custId);
		preparedStatement.setString(2, popupId);
		resultSet = preparedStatement.executeQuery();

		while (resultSet.next()) {
			jsonObject = new JsonObject();
			jsonObject.put("cust_id", resultSet.getString("cust_id"));
			jsonObject.put("popup_id", resultSet.getString("popup_id"));
			jsonObject.put("popup_name", resultSet.getString("popup_name"));
			jsonObject.put("form_id", resultSet.getString("form_id"));
			configParam =  resultSet.getString("config_param");
            configParamObj = new JsonObject(configParam);
            jsonObject.put("config_param",configParamObj);
			jsonObject.put("create_date", resultSet.getString("create_date"));
			jsonObject.put("modify_date", resultSet.getString("modify_date"));
			jsonObject.put("order_number", resultSet.getString("order_number"));
			jsonObject.put("status", resultSet.getString("status"));
			jsonObject.put("rcp_link", resultSet.getString("rcp_link"));
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

