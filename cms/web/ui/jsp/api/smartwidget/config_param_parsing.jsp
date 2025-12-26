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
				java.text.DecimalFormat,
				java.text.NumberFormat,
                org.json.JSONObject,
                org.w3c.dom.*"
		contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%


	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	String custId = user.s_cust_id;
	
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	
	FileWriter fileWriter = null;

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		stmt = conn.createStatement();

		String query = "SELECT id, cust_id, config_param FROM c_smart_widget_config";
		String insertionQuery = "INSERT INTO c_smart_widget_config_parsed (id, cust_id, config_param_type, config_param_enabled) VALUES (idPlaceHolder, custIdPlaceHolder, 'typePlaceHolder', enabledPlaceHolder);";
		
		rs = stmt.executeQuery(query);
		
		while (rs.next()) {
			JSONObject row = new JSONObject();
			
			Integer id = rs.getInt("id");
			String localCustId = rs.getString("cust_id");
			JSONObject configParamAsJson = new JSONObject(rs.getString("config_param"));
			
			String configParamType = configParamAsJson.getString("type");
			Boolean configParamEnabled = getConfigParamEnabledValue(configParamAsJson.get("enabled"));
						
			String insertionQueryFormatted = insertionQuery
												.replaceAll("idPlaceHolder", String.valueOf(id))
												.replaceAll("custIdPlaceHolder", String.valueOf(localCustId))
												.replaceAll("typePlaceHolder", configParamType)
												.replaceAll("enabledPlaceHolder", String.valueOf(configParamEnabled));
			
			out.println(insertionQueryFormatted);
		}
		if (fileWriter != null) fileWriter.close();
		rs.close();

	} catch (Exception exception) {
		out.println(exception.getMessage());
	} finally {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}

%>

<%!
    public String formatCurrency(double value) {
        DecimalFormat df = new DecimalFormat("###,###,###.##");

        return df.format(value);
    }
%>

<%!
    public String formatInteger(long value) {
        DecimalFormat df = new DecimalFormat("###,###,###");

        return df.format(value);
    }
%>

<%!
    public boolean getConfigParamEnabledValue(Object configParamEnabled) {
        if (configParamEnabled instanceof Boolean) {
			return (Boolean) configParamEnabled;
		}
		if (configParamEnabled instanceof String) {
			String configParamEnabledAsString = (String) configParamEnabled;
			
			return (configParamEnabledAsString != null && configParamEnabledAsString.equals("true"));
		}
		if (configParamEnabled instanceof Integer) {
			Integer configParamEnabledAsInteger = (Integer) configParamEnabled;
			
			return (configParamEnabledAsInteger != null && configParamEnabledAsInteger == 1);
		}
		throw new RuntimeException("The type of config_param_enabled could not be determined or is null: " + configParamEnabled.getClass());
    }
%>