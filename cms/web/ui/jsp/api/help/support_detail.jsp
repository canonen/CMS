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
<%@ page import="java.nio.charset.StandardCharsets" %>
<%response.setContentType("application/json");%>

<%
	String sCustId = cust.s_cust_id;

	ConnectionPool connectionPool   =null;
	Connection connection       =null;
	Statement statement = null;
	ResultSet rs = null;
	String sSQL2 = null;
	String ticketId = request.getParameter("ticketId");
	try
	{
		final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
		InetAddress ip = InetAddress.getLocalHost();
		final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
		//final  String urdb = "jdbc:sqlserver://192.168.151.4:1433;databaseName=brite_sadm_500";
		final  String dbUser = "revotasadm";
		final  String dbPassword = "abs0lut";



		sSQL2 = " SELECT " +
				"s.ticket_id, " +
				"s.origin_ticket_id, " +
				"s.cust_id, " +
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
				"s.modify_date," +
				"s.image, " +
				"syu.first_name + ' ' + syu.last_name as 'system_user' , " +
				"u.email  as 'user_email', " +
				"syu.email_address  as 'system_user_email' ,  " +
				"s.file_name as 'file_name' ," +
				"s.categories as 'category' ," +
				"s.first_response_date as first_response_date " +
				" FROM shlp_support_ticket s with(nolock) " +
				"LEFT OUTER JOIN sadm_customer c ON s.cust_id = c.cust_id " +
				"LEFT OUTER JOIN scps_user u ON s.user_id = u.user_id " +
				"LEFT OUTER JOIN shlp_support_status st ON s.status_id = st.status_id " +
				"LEFT OUTER JOIN sadm_system_user syu ON s.system_user_id = syu.system_user_id " +
				"WHERE s.cust_id= " +sCustId + " AND (ticket_id = " +ticketId + "or origin_ticket_id = " +ticketId +")";

		connection = DriverManager.getConnection(urdb,dbUser,dbPassword);
		statement = connection.createStatement();
		rs=statement.executeQuery(sSQL2);

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
		JsonObject repliesTicketData = new JsonObject();
		JsonArray originTicketArray = new JsonArray();
		JsonArray repliesTicketArray = new JsonArray();
		JsonArray allDataArray = new JsonArray();

		while (rs.next()) {
			JsonObject ticketJson = new JsonObject();
			ticketJson.put("ticketId", rs.getString(1));
			ticketJson.put("originTicketId", rs.getString(2));
			ticketJson.put("custId", rs.getString(3));
			ticketJson.put("customer", fixTurkishCharacters(rs.getString(4)));
			ticketJson.put("userId", rs.getString(5));
			ticketJson.put("username",rs.getString("system_user") == null ? rs.getString(6) : rs.getString("system_user"));
			ticketJson.put("status", rs.getString(7));
			ticketJson.put("displayName", rs.getString(8));
			ticketJson.put("levelId", rs.getString(9));
			ticketJson.put("sourceId", rs.getString(10));
			ticketJson.put("subject", new String(rs.getString(11).getBytes("WINDOWS-1252"), StandardCharsets.ISO_8859_1));
			ticketJson.put("originalIssue", new String(rs.getString(12).getBytes("WINDOWS-1252"), StandardCharsets.ISO_8859_1));
			ticketJson.put("furtherInfo", rs.getString(13));
			ticketJson.put("supportDiary", rs.getString(14));
			ticketJson.put("issueType", rs.getString(15));
			ticketJson.put("resolutionTime", rs.getString(16));
			ticketJson.put("resolutionWhat", rs.getString(17));
			ticketJson.put("resolutionSolve", rs.getString(18));
			ticketJson.put("resolutionPrevent", rs.getString(19));


			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			String createDateFromSQL = rs.getString(20);
			String modifyDateFromSQL = rs.getString(21);

			Date createDate = dateFormat.parse(createDateFromSQL);
			Date modifyDate = dateFormat.parse(modifyDateFromSQL);

			String formattedCreateDate = dateFormat.format(createDate);
			String formattedModifyDate = dateFormat.format(modifyDate);

			ticketJson.put("createDate", formattedCreateDate);
			ticketJson.put("modifyDate",formattedModifyDate);
			ticketJson.put("category", rs.getString("category") == null ? "" : rs.getString("category"));
			ticketJson.put("first_response_date", rs.getString("first_response_date") == null ? "" : rs.getString("first_response_date"));


			String fileUploadName = "";

			String fileName = rs.getString("file_name");
			if(fileName != null && !fileName.isEmpty()){
				String fileExtensionName = (fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase());
				String file = fileName.substring(0, fileName.lastIndexOf("."));
				fileUploadName = file + "_" + ticketId + "." + fileExtensionName;
			}


			ticketJson.put("image", rs.getString(22));
			ticketJson.put("fileName", fileName == null || fileName.isEmpty() ? "" : fileName);
			ticketJson.put("fileUploadName", fileUploadName);
			ticketJson.put("fullFilePath", "C:/Revotas/cms/web/ui/jsp/api/help/admin-file/" + fileUploadName);
			




			if (rs.getString(2).equals("0")) {
				ticketJson.put("user_email", rs.getString("user_email"));
				originTicketArray.put(ticketJson);
			} else {
				ticketJson.put("user_email", rs.getString("user_email") == null ? rs.getString("system_user_email") : rs.getString("user_email"));
				repliesTicketArray.put(ticketJson);
			}

		}


		originTicketData.put("originTicketData", originTicketArray);
		repliesTicketData.put("repliesTicketData", repliesTicketArray);

		allDataArray.put(originTicketData);
		allDataArray.put(repliesTicketData);
		out.print(allDataArray);

	}catch(Exception ex) {
		out.println("Hata: " + ex.getMessage());
	}finally {
		try {
			if (rs != null) rs.close();
			if (statement != null) statement.close();
			if (connection != null) connection.close();
			if (statement != null) statement.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
%>
<%!    public  String fixTurkishCharacters(String input) {
	if (input == null) {
		return null;
	}
	String s = input;
	s = s.replace("Ã„Â±", "ı");
	s = s.replace("Ã„Â°", "İ");
	s = s.replace("Ã„ÂŸ", "ğ");
	s = s.replace("Ã„Âž", "Ğ");
	s = s.replace("Ã…ÅŸ", "ş");
	s = s.replace("Ã…Åž", "Ş");
	s = s.replace("ÃƒÂ¼", "ü");
	s = s.replace("ÃƒÂ–", "Ö");
	s = s.replace("ÃƒÂœ", "Ü");
	s = s.replace("Ãœ", "Ü");
	s = s.replace("ÃƒÂ§", "ç");
	s = s.replace("Ãƒâ€¹", "Ç");
	s = s.replace("Ã\\u2021", "Ç");
	s = s.replace("ÃƒÂ¶", "ö");
	s = s.replace("Ä±", "ı");
	s = s.replace("Ä°", "İ");
	s = s.replace("ÄŸ", "ğ");
	s = s.replace("Äž", "Ğ");
	s = s.replace("ÅŸ", "ş");
	s = s.replace("Åž", "Ş");
	s = s.replace("Ã¼", "ü");
	s = s.replace("Ãœ", "Ü");
	s = s.replace("Ã§", "ç");
	s = s.replace("Ã‡", "Ç");
	s = s.replace("Ã¶", "ö");
	s = s.replace("Ã–", "Ö");

	return s;
}
%>

