<%@ page
		language="java"
		import="com.britemoon.*"
		import="com.britemoon.cps.*"
		import="java.io.*"
		import="java.sql.*"
		import="java.util.*"
		import="org.apache.log4j.*"
%>
<%@include file="../header.jsp" %>
<%@include file="../validator.jsp" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%response.setContentType("application/json");%>

<%
	String sCustId = cust.s_cust_id;

	ConnectionPool connectionPool   =null;
	Connection connection       =null;
	Connection connection2       =null;
	Statement stmt = null;
	ResultSet rs = null;
	Statement statement = null;
	ResultSet resultSet = null;
	String sSQL = null;
	String sSQL2 = null;
	String ticketId = request.getParameter("ticketId");
	try
	{
		final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
		InetAddress ip = InetAddress.getLocalHost();
		final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
		final  String dbUser = "revotasadm";
		final  String dbPassword = "abs0lut";

		sSQL = "EXEC usp_shlp_support_ticket_details_get '" + ticketId + "'" ;
		sSQL2 = " SELECT s.ticket_id, " +
				"s.origin_ticket_id, " +
				"c.cust_name, " +
				"s.user_id," +
				"u.user_name + ' ' + u.last_name as 'user_name', " +
				"s.status_id," +
				"st.display_name, " +
				"s.level_id, " +
				"s.source_id," +
				"s.subject," +
				"s.original_issue," +
				"s.further_info, " +
				"s.support_diary, " +
				"s.issue_type," +
				"s.resolution_time," +
				"s.resolution_what, " +
				"s.resolution_solve, " +
				"s.resolution_prevent, " +
				"s.create_date, " +
				"s.modify_date " +
				" FROM shlp_support_ticket s with(nolock) " +
				"LEFT OUTER JOIN sadm_customer c ON s.cust_id = c.cust_id " +
				"LEFT OUTER JOIN scps_user u ON s.user_id = u.user_id " +
				"LEFT OUTER JOIN shlp_support_status st ON s.status_id = st.status_id " +
				"WHERE s.cust_id= " +sCustId + " AND ticket_id = " +ticketId;

		connection = DriverManager.getConnection(urdb,dbUser,dbPassword);
		stmt = connection.createStatement();
		rs=stmt.executeQuery(sSQL);


		statement = connection.createStatement();
		resultSet=statement.executeQuery(sSQL2);

		String sTicketId = null;
		String sOriginTicketId = null;
		String sCustName = null;
		String sUserId = null;
		String sUserName = null;
		String sStatusId =null;
		String sDisplayName = null;
		String sLevelId = null;
		String sSourceId=null;
		String sSubject = null;
		String sOriginalIsue = null;
		String sFurtherInfo = null;
		String sSupportDiary = null;
		String sIsueType = null;
		String sResolutionTime = null;
		String sResolutionWhat = null;
		String sResolutionSolve = null;
		String sResolutionPrevent = null;


		JsonObject originTicketData = new JsonObject();
		JsonObject ticketObjects = new JsonObject();
		JsonArray ticketArray = new JsonArray();
		JsonArray allDataArray = new JsonArray();
		while(resultSet.next()) {
			JsonObject originTicketJson = new JsonObject();

			sTicketId = resultSet.getString(1);
			sOriginTicketId = resultSet.getString(2);
			sCustName = new String(resultSet.getBytes(3), "UTF-8");
			sUserId = (resultSet.getString(4) != null) ? resultSet.getString(4) : "null";
			sUserName = (resultSet.getBytes(5) != null) ? new String(resultSet.getBytes(5), "UTF-8") : "null";
			sStatusId = (resultSet.getString(6) != null) ? resultSet.getString(6) : "null";
			sDisplayName = (resultSet.getBytes(7) != null) ? new String(resultSet.getBytes(7), "UTF-8") : "null";
			sLevelId = (resultSet.getString(8) != null) ? resultSet.getString(8) : "null";
			sSourceId = (resultSet.getString(9) != null) ? resultSet.getString(9) : "null";
			sSubject = (resultSet.getBytes(10) != null) ? new String(resultSet.getBytes(10), "UTF-8") : "null";
			sOriginalIsue = (resultSet.getString(11) != null) ? resultSet.getString(11) : "null";
			sFurtherInfo = (resultSet.getString(12) != null) ? resultSet.getString(12) : "null";
			sSupportDiary = (resultSet.getString(13) != null) ? resultSet.getString(13) : "null";
			sIsueType = (resultSet.getString(14) != null) ? resultSet.getString(14) : "null";
			sResolutionTime = (resultSet.getString(15) != null) ? resultSet.getString(15) : "null";
			sResolutionWhat = (resultSet.getString(16) != null) ? resultSet.getString(16) : "null";
			sResolutionSolve = (resultSet.getString(17) != null) ? resultSet.getString(17) : "null";
			sResolutionPrevent = (resultSet.getBytes(18) != null) ? new String(resultSet.getBytes(18), "UTF-8") : "null";
			//sCreateDate = (resultSet.getString(19) != null) ? resultSet.getString(19) : "null";
			//sModifyDate = (resultSet.getString(20) != null) ? resultSet.getString(20) : "null";

			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

			String createDateFromSQL = resultSet.getString(19);
			String modifyDateFromSQL = resultSet.getString(20);

			Date createDate = dateFormat.parse(createDateFromSQL);
			Date modifyDate = dateFormat.parse(modifyDateFromSQL);

			String formattedCreateDate = dateFormat.format(createDate);
			String formattedModifyDate = dateFormat.format(modifyDate);

			originTicketJson.put("sTicketId", sTicketId);
			originTicketJson.put("sOriginTicketId", sOriginTicketId);
			originTicketJson.put("sCustId", sCustId);
			originTicketJson.put("sCustName", sCustName);
			originTicketJson.put("sUserId", sUserId);
			originTicketJson.put("sUserName", sUserName);
			originTicketJson.put("sStatusId", sStatusId);
			originTicketJson.put("sDisplayName", sDisplayName);
			originTicketJson.put("sLevelId", sLevelId);
			originTicketJson.put("sSourceId", sSourceId);
			originTicketJson.put("sSubject", sSubject);
			originTicketJson.put("sOriginalIsue", sOriginalIsue);
			originTicketJson.put("sFurtherInfo", sFurtherInfo);
			originTicketJson.put("sSupportDiary", sSupportDiary);
			originTicketJson.put("sIsueType", sIsueType);
			originTicketJson.put("sResolutionTime", sResolutionTime);
			originTicketJson.put("sResolutionWhat", sResolutionWhat);
			originTicketJson.put("sResolutionSolve", sResolutionSolve);
			originTicketJson.put("sResolutionPrevent", sResolutionPrevent);
			originTicketJson.put("sCreateDate", formattedCreateDate);
			originTicketJson.put("sModifyDate", formattedModifyDate);

			originTicketData.put("originTicketData", originTicketJson);
		}

		while (rs.next()) {
			JsonObject json = new JsonObject();

			json.put("ticketId", rs.getString(1));
			json.put("originTicketId", rs.getString(2));
			json.put("custId", rs.getString(3));
			json.put("customer", rs.getString(4));
			json.put("userId", rs.getString(5));
			json.put("username", rs.getString(6));
			json.put("status", rs.getString(7));
			json.put("displayName", rs.getString(8));
			json.put("levelId", rs.getString(9));
			json.put("sourceId", rs.getString(10));
			json.put("subject", rs.getString(11));
			json.put("originalIssue", rs.getString(12));
			json.put("furtherInfo", rs.getString(13));
			json.put("supportDiary", rs.getString(14));
			json.put("issueType", rs.getString(15));
			json.put("resolutionTime", rs.getString(16));
			json.put("resolutionWhat", rs.getString(17));
			json.put("resolutionSolve", rs.getString(18));
			json.put("resolutionPrevent", rs.getString(19));

			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

			String createDateFromSQL = rs.getString(20);
			String modifyDateFromSQL = rs.getString(21);

			Date createDate = dateFormat.parse(createDateFromSQL);
			Date modifyDate = dateFormat.parse(modifyDateFromSQL);

			String formattedCreateDate = dateFormat.format(createDate);
			String formattedModifyDate = dateFormat.format(modifyDate);

			json.put("createDate", formattedCreateDate);
			json.put("modifyDate",formattedModifyDate);

			ticketArray.put(json);
		}
		ticketObjects.put("replies", ticketArray);
		allDataArray.put(ticketObjects);
		allDataArray.put(originTicketData);
		out.print(allDataArray);

	}catch(Exception ex) {
		out.println("Hata: " + ex.getMessage());
	}finally {
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (connection != null) connection.close();
			if (resultSet != null) resultSet.close();
			if (statement != null) statement.close();
			if (connection2 != null) connection2.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
%>