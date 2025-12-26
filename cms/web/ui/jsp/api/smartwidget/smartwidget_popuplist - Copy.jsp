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
<%@ page import="org.json.JSONObject" %>

<%


	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	//String custId = request.getParameter("custId");
	String custId = user.s_cust_id;
	JsonObject data = new JsonObject();
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;

	JsonArray popupListData = new JsonArray();
	String popupName = "";
	String popup_id = "";
	String modify_date = "";
	String create_date = "";
	JSONObject config_param = null;
	String order_number = "";
	String status = "";
	String click = "";
	String submit = "";
	String revenue = "";
	String impression = "";
	String varType = "";
	String enabled = "";

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		stmt = conn.createStatement();

		String sSql = "SELECT c.popup_name, c.popup_id, c.modify_date, c.create_date, c.order_number, c.status, c.config_param, " +
				"SUM(CASE WHEN a.type_name = 1 THEN a.activity ELSE 0 END) AS total_activity_type_1, SUM(CASE WHEN a.type_name = 2 THEN a.activity ELSE 0 END) AS total_activity_type_2," +
				"SUM(a.revenue) AS revenue,SUM(a.impression) AS impression, " +
				"CAST(JSON_UNQUOTE(JSON_EXTRACT(config_param, '$.enabled')) AS UNSIGNED) AS enabled, JSON_UNQUOTE(JSON_EXTRACT(config_param, '$.type')) AS type " +
				"FROM c_smart_widget_config AS c LEFT JOIN ccps_smart_widget_activity_day AS a ON c.popup_id = a.popup_id WHERE c.status <> 90 AND c.cust_id ="+custId+"  " +
				"GROUP BY c.popup_name, c.popup_id, c.modify_date, c.create_date, c.order_number, c.status, c.config_param ORDER BY c.order_number";

		rs = stmt.executeQuery(sSql);
		while (rs.next()) {
			data = new JsonObject();

			popupName = rs.getString("popup_name");
			popup_id = rs.getString("popup_id");
			modify_date = rs.getString("modify_date");
			create_date = rs.getString("create_date");
			order_number = rs.getString("order_number");
			status = rs.getString("status");
			revenue = rs.getString("revenue");
			impression = rs.getString("impression");
			click = rs.getString("total_activity_type_1");
			submit = rs.getString("total_activity_type_2");
			enabled = rs.getString("enabled");
			varType = rs.getString("type");
			
			config_param = new JSONObject(rs.getString("config_param"));
			varType = config_param.getString("type");
			enabled = config_param.getString("enabled");
			
			if (revenue != null) {
				data.put("revenue", formatCurrency(Double.parseDouble(revenue)) + " TL");
			} else {
				data.put("revenue", "0 TL"); 
			}

			if (impression != null) {
				data.put("view", formatInteger(Long.parseLong(impression)));
			} else {
				data.put("view", "0"); 
			}

			data.put("popupName", popupName);
			data.put("popup_id", popup_id);
			data.put("modify_date", modify_date);
			data.put("create_date", create_date);
			data.put("order_number", order_number);
			data.put("status", status);
			data.put("click", click);
			data.put("submit", submit);
			data.put("revenue", revenue);
			data.put("type", varType);
			data.put("enabled", enabled);
			
			popupListData.put(data);

		}
		rs.close();
		out.print(popupListData);

	} catch (Exception exception) {
		exception.getMessage();
	} finally {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}

%>

<%!
    public String formatCurrency(double value) {
        NumberFormat formatter = NumberFormat.getInstance();

        String formattedNumber = formatter.format(value);
	int indexOfComma = -1;

	for (int i = 0; i < formattedNumber.length(); i++) {
	    if (formattedNumber.charAt(i) == '.') {
	        indexOfComma = i;
                break;
	    }	    
        }
	if (indexOfComma == -1) {
	    return formattedNumber;
        }
	return formattedNumber.substring(0, indexOfComma + 3);
    }
%>

<%!
    public String formatInteger(long value) {
        DecimalFormat df = new DecimalFormat("###,###,###");

        return df.format(value);
    }
%>