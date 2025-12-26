<%@ page
		language="java"
		import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Calendar,
				java.util.Map,
				java.util.HashMap,
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
<%@ page import="java.time.format.DateTimeFormatter" %>
<%


	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	//String custId = request.getParameter("custId");
	String custId = user.s_cust_id;

	String firstDate = request.getParameter("first_date");
	String lastDate = request.getParameter("last_date");


	JsonArray popupListData = new JsonArray();
	JsonObject data = new JsonObject();
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;

	String popupName = "";
	String popupId = "";
	String modifyDate = "";
	String createDate = "";
	String configParam = "";
	String orderNumber = "";
	String status = "";
	String click = "";
	String submit = "";
	String revenue = "";
	String impression = "";

	try {
		Map<String, SmartConfiguration> map = new HashMap();
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		stmt = conn.createStatement();

		String query1 = "SELECT popup_name as popupName, popup_id as popupId, modify_date as modifyDate, create_date as createDate, order_number as orderNumber, status as status, config_param as configParam"
				+ " FROM c_smart_widget_config"
				+ " WHERE status <> 90 AND cust_id = " + custId;

		rs = stmt.executeQuery(query1);
		while (rs.next()) {
			SmartConfiguration nextConfiguration = new SmartConfiguration();

			popupName = rs.getString("popupName");
			popupId = rs.getString("popupId");
//			modifyDate = rs.getString("modifyDate");
//			createDate = rs.getString("createDate");

            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

            String modifyDateFormatted = (rs.getTimestamp("modifyDate") != null) ? rs.getTimestamp("modifyDate").toLocalDateTime().format(timeFormatter) : "-";
            String createDateFormatted = (rs.getTimestamp("createDate") != null) ? rs.getTimestamp("createDate").toLocalDateTime().format(timeFormatter) : "-";

            orderNumber = rs.getString("orderNumber");
			status = rs.getString("status");
			configParam = rs.getString("configParam");

			nextConfiguration.setPopupName(popupName);
			nextConfiguration.setPopupId(popupId);
			nextConfiguration.setModifyDate(modifyDateFormatted);
			nextConfiguration.setCreateDate(createDateFormatted);
			nextConfiguration.setOrderNumber(orderNumber);
			nextConfiguration.setStatus(status);
			nextConfiguration.setConfigParam(configParam);

			map.put(popupId, nextConfiguration);
		}
		rs.close();

		String query2 = "SELECT a.popup_id,"
				+ " SUM(CASE WHEN a.type_name = 1 THEN a.activity ELSE 0 END) AS total_activity_type_1,"
				+ " SUM(CASE WHEN a.type_name = 2 THEN a.activity ELSE 0 END) AS total_activity_type_2,"
				+ " SUM(a.revenue) AS revenue,"
				+ " SUM(a.impression) AS impression"
				+ " FROM ccps_smart_widget_activity_day AS a"
				+ " WHERE  a.cust_id = " + custId
				+ " GROUP BY a.popup_id";

		rs = stmt.executeQuery(query2);

		while (rs.next()) {
			String popupId2 = rs.getString("popup_id");
			System.out.println("popupId2: " + popupId2);
			SmartConfiguration row = map.get(popupId2);

			if (row != null) {
				String totalActivityType1 = rs.getString("total_activity_type_1");
				String totalActivityType2 = rs.getString("total_activity_type_2");
				revenue = rs.getString("revenue");
				impression = rs.getString("impression");

				row.setTotalActivityType1(totalActivityType1);
				row.setTotalActivityType2(totalActivityType2);
				row.setRevenue(revenue);
				row.setImpression(impression);

			}
		}
		if (firstDate != null && lastDate != null){
			//popup_id bazında activity bilgilerini map e dolduran sorgu(çalışması için tarih bilgisi requestten gelmelidir.).
			String queryForSumActivityBetweenDate = "SELECT a.popup_id,"
					+ " SUM(CASE WHEN a.type_name = 1 THEN a.activity ELSE 0 END) AS clickCount,"
					+ " SUM(CASE WHEN a.type_name = 2 THEN a.activity ELSE 0 END) AS submitCount,"
					+ " SUM(a.revenue) AS revenueCount,"
					+ " SUM(a.impression) AS viewCount"
					+ " FROM ccps_smart_widget_activity_day AS a"
					+ " WHERE  a.cust_id = " + custId
					+ " AND a.activity_date BETWEEN '" + firstDate + " 00:00:00' AND '" + lastDate + " 23:59:59' "
					+ " GROUP BY a.popup_id";

			rs = stmt.executeQuery(queryForSumActivityBetweenDate);

			while (rs.next()) {
				String popupId2 = rs.getString("popup_id");
				System.out.println("popupId2: " + popupId2);
				SmartConfiguration row = map.get(popupId2);

				if (row != null) {
					String clickBetweenDate = rs.getString("clickCount");
					String submitBetweenDate = rs.getString("submitCount");
					String revenueBetweenDate = rs.getString("revenueCount");
					String viewBetweenDate = rs.getString("viewCount");

					row.setClickBetweenDate(clickBetweenDate);
					row.setSubmitBetweenDate(submitBetweenDate);
					row.setViewBetweenDate(viewBetweenDate);
					row.setRevenueBetweenDate(revenueBetweenDate);
				}
			}
		}


		System.out.println("mapSize: " + map.size());
		for (Map.Entry<String, SmartConfiguration> entry : map.entrySet()) {
			data = new JsonObject();
			SmartConfiguration config23 = entry.getValue();

			data.put("popup_id", config23.getPopupId());
			data.put("popupName", editCharacter(config23.getPopupName()));
			data.put("modify_date", config23.getModifyDate());
			data.put("create_date", config23.getCreateDate());
			data.put("order_number", config23.getOrderNumber());
			data.put("status", config23.getStatus());
			data.put("config_param", config23.getConfigParam());

			click = config23.getTotalActivityType1();
			submit = config23.getTotalActivityType2();
			impression = config23.getImpression();
			revenue = config23.getRevenue();

			/*data.put("click", click == null || click.trim().isEmpty() ? "0" : formatInteger(Long.parseLong(click)));
			data.put("submit", submit == null || submit.trim().isEmpty() ? "0" : formatInteger(Long.parseLong(submit)));
			data.put("view", impression == null || impression.trim().isEmpty() ? "0" : formatInteger(Long.parseLong(impression)));
			data.put("revenue", revenue == null || revenue.trim().isEmpty() ? "0 TL" : formatCurrency(Double.parseDouble(revenue)) + " TL");*/

			data.put("click", config23.getClickBetweenDate());
			data.put("submit", config23.getSubmitBetweenDate());
			data.put("view", config23.getViewBetweenDate());
			data.put("revenue", config23.getRevenueBetweenDate() + " TL");

			popupListData.put(data);
		}
		out.print(popupListData);

	} catch (Exception exception) {
		System.out.println(exception.getMessage());
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
	public class SmartConfiguration {
		private String popupName = "";
		private String popupId = "";
		private String modifyDate = "";
		private String createDate = "";
		private String configParam = "";
		private String orderNumber = "";
		private String status = "";
		private String click = "";
		private String submit = "";
		private String revenue = "";
		private String impression = "";
		private String totalActivityType1 = "";
		private String totalActivityType2 = "";
		private String clickBetweenDate = "0";
		private String submitBetweenDate = "0";
		private String viewBetweenDate = "0";
		private String revenueBetweenDate = "0";

		public String getPopupName() {
			return popupName;
		}

		public void setPopupName(String popupName) {
			this.popupName = popupName;
		}

		public String getPopupId() {
			return popupId;
		}

		public void setPopupId(String popupId) {
			this.popupId = popupId;
		}

		public String getModifyDate() {
			return modifyDate;
		}

		public void setModifyDate(String modifyDate) {
			this.modifyDate = modifyDate;
		}

		public String getCreateDate() {
			return createDate;
		}

		public void setCreateDate(String createDate) {
			this.createDate = createDate;
		}

		public String getConfigParam() {
			return configParam;
		}

		public void setConfigParam(String configParam) {
			this.configParam = configParam;
		}

		public String getOrderNumber() {
			return orderNumber;
		}

		public void setOrderNumber(String orderNumber) {
			this.orderNumber = orderNumber;
		}

		public String getStatus() {
			return status;
		}

		public void setStatus(String status) {
			this.status = status;
		}

		public String getClick() {
			return click;
		}

		public void setClick(String click) {
			this.click = click;
		}

		public String getSubmit() {
			return submit;
		}

		public void setSubmit(String submit) {
			this.submit = submit;
		}

		public String getRevenue() {
			return revenue;
		}

		public void setRevenue(String revenue) {
			this.revenue = revenue;
		}

		public String getImpression() {
			return impression;
		}

		public void setImpression(String impression) {
			this.impression = impression;
		}

		public String getTotalActivityType1() {
			return totalActivityType1;
		}

		public void setTotalActivityType1(String totalActivityType1) {
			this.totalActivityType1 = totalActivityType1;
		}

		public String getTotalActivityType2() {
			return totalActivityType2;
		}

		public void setTotalActivityType2(String totalActivityType2) {
			this.totalActivityType2 = totalActivityType2;
		}

		public String getClickBetweenDate() {
			return clickBetweenDate;
		}

		public void setClickBetweenDate(String clickBetweenDate) {
			this.clickBetweenDate = clickBetweenDate;
		}

		public String getSubmitBetweenDate() {
			return submitBetweenDate;
		}

		public void setSubmitBetweenDate(String submitBetweenDate) {
			this.submitBetweenDate = submitBetweenDate;
		}

		public String getViewBetweenDate() {
			return viewBetweenDate;
		}

		public void setViewBetweenDate(String viewBetweenDate) {
			this.viewBetweenDate = viewBetweenDate;
		}
		public String getRevenueBetweenDate() {
			return revenueBetweenDate;
		}

		public void setRevenueBetweenDate(String revenueBetweenDate) {
			this.revenueBetweenDate = revenueBetweenDate;
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