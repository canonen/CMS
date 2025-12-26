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
	//String custId = request.getParameter("custId");
	String custId = user.s_cust_id;
	JsonArray popupListData = new JsonArray();
	JsonObject data = new JsonObject();
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;

	String popupName = "";
	String popup_id = "";
	String modify_date = "";
	String create_date = "";
	String config_param = "";
	String order_number = "";
	String status = "";
	String click = "";
	String submit = "";
	String revenue = "";
	String impression = "";

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		stmt = conn.createStatement();

		String sSql = "SELECT c.popup_name, c.popup_id, c.modify_date, c.create_date, c.order_number, c.status, c.config_param,"
		
		+ " SUM(CASE WHEN a.type_name = 1 THEN a.activity ELSE 0 END) AS total_activity_type_1,"
		+ " SUM(CASE WHEN a.type_name = 2 THEN a.activity ELSE 0 END) AS total_activity_type_2,"
		+ " SUM(a.revenue) AS revenue,"
		+ " SUM(a.impression) AS impression"
		+ " FROM c_smart_widget_config AS c"
		+ " FULL OUTER JOIN ccps_smart_widget_activity_day AS a ON c.popup_id = a.popup_id"
		+ " WHERE c.status <> 90 AND c.cust_id = " + custId
		+ " GROUP BY c.popup_name, c.popup_id, c.modify_date, c.create_date, c.order_number, c.status, c.config_param"
		+ " ORDER BY c.order_number";

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
			config_param = rs.getString("config_param");
			
			data.put("popup_id", popup_id);
			data.put("popupName", popupName);
			data.put("modify_date", modify_date);
			data.put("create_date", create_date);
			data.put("order_number", order_number);
			data.put("status", status);
			data.put("config_param", config_param);
			data.put("click", click == null ? "0" : formatInteger(Long.parseLong(click)));
			data.put("submit", submit == null ? "0" : formatInteger(Long.parseLong(submit)));
			data.put("view", impression == null ? "0" : formatInteger(Long.parseLong(impression)));
			data.put("revenue", revenue == null ? "0 TL" : formatCurrency(Double.parseDouble(revenue)) + " TL");
			
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