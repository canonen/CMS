<%@ page
		language="java"
		import="com.britemoon.*"
		import="com.britemoon.cps.*"
		import="java.io.*"
		import="java.sql.*"
		import="java.util.*"
		import="org.apache.log4j.*"
		contentType="text/html;charset=UTF-8"
%>
<%@include file="../header.jsp" %>
<%@include file="../validator.jsp" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%
	String sCustId = cust.s_cust_id;

	ConnectionPool connectionPool   =null;
	Connection connection       =null;
	Statement statement = null;
	ResultSet resultSet = null;
	String sSQL = null;

	try
	{
		final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
		InetAddress ip = InetAddress.getLocalHost();
		final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
		final  String dbUser = "revotasadm";
		final  String dbPassword = "abs0lut";

		sSQL = " SELECT s.ticket_id, " +
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
				"CONVERT(varchar(100), s.create_date, 100) as 'create_date_txt', " +
				"s.modify_date, " +
				"CONVERT(varchar(100), s.modify_date, 100) as 'modify_date_txt' " +
				"FROM shlp_support_ticket s with(nolock) " +
				"LEFT OUTER JOIN sadm_customer c ON s.cust_id = c.cust_id " +
				"LEFT OUTER JOIN scps_user u ON s.user_id = u.user_id " +
				"LEFT OUTER JOIN shlp_support_status st ON s.status_id = st.status_id " +
				"WHERE s.cust_id= " +sCustId + " AND s.origin_ticket_id = 0 ORDER BY create_date DESC";

		connection = DriverManager.getConnection(urdb,dbUser,dbPassword);

		statement = connection.createStatement();
		resultSet=statement.executeQuery(sSQL);

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
		String sCreateDate = null;
		String sModifyDate = null;

		JsonArray arr = new JsonArray();

		while(resultSet.next())
		{
			JsonObject json = new JsonObject();

			sTicketId = resultSet.getString(1);
			sOriginTicketId = resultSet.getString(2);
			sCustName = new String(resultSet.getBytes(3),"UTF-8");
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
			sCreateDate = (resultSet.getString(19) != null) ? resultSet.getString(19) : "null";
			sModifyDate = (resultSet.getString(20) != null) ? resultSet.getString(20) : "null";

			json.put("sTicketId",sTicketId);
			json.put("sOriginTicketId",sOriginTicketId);
			json.put("sCustId",sCustId);
			json.put("sCustName",sCustName);
			json.put("sUserId",sUserId);
			json.put("sUserName",sUserName);
			json.put("sStatusId",sStatusId);
			json.put("sDisplayName",sDisplayName);
			json.put("sLevelId",sLevelId);
			json.put("sSourceId",sSourceId);
			json.put("sSubject",sSubject);
			json.put("sOriginalIsue",sOriginalIsue);
			json.put("sFurtherInfo",sFurtherInfo);
			json.put("sSupportDiary",sSupportDiary);
			json.put("sIsueType",sIsueType);
			json.put("sResolutionTime",sResolutionTime);
			json.put("sResolutionWhat",sResolutionWhat);
			json.put("sResolutionSolve",sResolutionSolve);
			json.put("sResolutionPrevent",sResolutionPrevent);
			json.put("sDisplayName",sDisplayName);
			json.put("sCreateDate",sCreateDate);
			json.put("sModifyDate",sModifyDate);

			arr.put(json);
		}
		out.print(arr);

	}catch(Exception ex) {
		out.println("Hata: " + ex.getMessage());
	}
%>