<%@ page language="java"
		 import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../validator.jsp"%>
<%@ include file="../header.jsp"%>
<%! static Logger logger = null;%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.nio.file.StandardCopyOption" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%

	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String subject = request.getParameter("subject");
	String originalIssue = request.getParameter("original_issue");
	String furtherInfo = request.getParameter("further_info");
	String originTicketId = request.getParameter("origin_ticket_id");
	//Status 0 new Status 100 Completed
	String completed = request.getParameter("completed");
	String dueDate = request.getParameter("due_date");
	String dateString = dueDate + " 00:00:00";
	String orgFileName = request.getParameter("file_name");
	String[] fileChars = orgFileName.split("\\.");
	String fileName = fileChars[0];
	String fileExtension = fileChars[1];
	boolean isOriginTicket = false;

	if (originTicketId != null && !originTicketId.equals("") && !originTicketId.equals("0")) {
		isOriginTicket = true;
	}
	String image = request.getParameter("image");
	String categories = request.getParameter("categories");

	if (subject != null && !subject.equals(""))
		subject = new String(subject.getBytes("ISO-8859-1"),"UTF-8");
	if (originalIssue != null && !originalIssue.equals(""))
		originalIssue = new String(originalIssue.getBytes("ISO-8859-1"),"UTF-8");
	if (image != null && !image.equals(""))
		image = new String(image.getBytes("ISO-8859-1"),"UTF-8");
	if( fileName != null && !fileName.equals(""))
		fileName = new String(fileName.getBytes("ISO-8859-1"),"UTF-8");
	if (categories != null && !categories.equals(""))
		categories = new String(categories.getBytes("ISO-8859-1"),"UTF-8");


	Customer user_cust = new Customer(user.s_cust_id);
	Customer cSuper = ui.getSuperiorCustomer();

	String s_ticket_id = "";
	String s_cust_id = "";
	String s_cust_name = "";
	String s_user_id = "";
	String s_user_name = "";
	String s_email_from = "";
	String s_email_to = "";
	String s_email_cc = "";
	String s_phone = "";
	String s_subject = "";
	String s_original_issue = "";
	String s_further_info = "";
	String s_resolution_info = "";
	String s_browser_info = "";
	s_cust_id		= user.s_cust_id;
	s_cust_name		= cSuper.s_cust_name;
	s_user_id		= user.s_user_id;
	s_user_name		= user.s_user_name + " " + user.s_last_name;
	s_phone			= user.s_phone;
	s_email_from	= user.s_email;
	s_email_to 		= ui.getProp("sup_level_1");
	s_email_cc 		= ui.getProp("sup_level_2");
	s_subject = subject;
	s_original_issue = originalIssue;
	s_further_info = furtherInfo;
	s_browser_info = request.getHeader("user-agent");
	String sRequest = "";
	JsonObject json = new JsonObject();
	JsonArray arr = new JsonArray();
	String sql;
	int ticketId = -1;
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");

	Connection connection       =null;
	PreparedStatement ps = null;
	ResultSet rs = null;

	try
	{
		Date utilDate = new Date();
		java.sql.Timestamp sqlTimestamp = new java.sql.Timestamp(utilDate.getTime());

		final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
		InetAddress ip = InetAddress.getLocalHost();
		final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
		//  String urdb = "jdbc:sqlserver://192.168.151.4:1433;databaseName=brite_sadm_500";
		final  String dbUser = "revotasadm";
		final  String dbPassword = "abs0lut";

		sql = "INSERT INTO shlp_support_ticket (origin_ticket_id ,cust_id, user_id, status_id, subject, original_issue, further_info, image, create_date , modify_date , first_response_date , due_date ,completed_date , file_name , categories) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?, ? , ? , ? , ?)";
		connection = DriverManager.getConnection(urdb,dbUser,dbPassword);
		ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
		ps.setInt(1, 0);
		ps.setString(2, s_cust_id);
		ps.setString(3, s_user_id);
		ps.setInt(4, 0);
		ps.setString(5, s_subject);
		ps.setString(6, s_original_issue);
		ps.setString(7, s_further_info);
		ps.setString(8, image);
		ps.setTimestamp(9, sqlTimestamp);
		ps.setTimestamp(10, sqlTimestamp);
//		if(user.s_login_name.equals("radmin") && isOriginTicket == false){
//			ps.setTimestamp(11, sqlTimestamp);
//		}else{
//			ps.setTimestamp(11, null);
//		}
		ps.setTimestamp(11, null);
		if(dueDate != null && !dueDate.equals("") && isOriginTicket == false){
			//Convert String dueDate to Date
			Date date = sdf.parse(dateString);
			ps.setTimestamp(12, new java.sql.Timestamp(date.getTime()));
		}else{
			ps.setTimestamp(12, null);
		}
		if(completed!= null && completed.equals("true")) {
			ps.setTimestamp(13, sqlTimestamp);
		}else {
			ps.setTimestamp(13, null);
		}
		ps.setString(14, turkishToEnglish(fileName).toUpperCase(Locale.ENGLISH) + "." + fileExtension);
		ps.setString(15, categories);
		ps.executeUpdate();

		rs = ps.getGeneratedKeys();
		if (rs.next()) {
			ticketId = rs.getInt(1);
		}

		rs.close();
		ps.close();

		if (isOriginTicket) {
			String sql1 = "UPDATE shlp_support_ticket SET origin_ticket_id = ?  WHERE ticket_id = ?";
			ps = connection.prepareStatement(sql1);
			ps.setInt(1, Integer.parseInt(originTicketId));
			ps.setInt(2, ticketId);
			ps.executeUpdate();


			String sql2 = "UPDATE shlp_support_ticket SET modify_date = ? WHERE ticket_id = ?";
			ps = connection.prepareStatement(sql2);
			ps.setTimestamp(1, sqlTimestamp);
			ps.setInt(2, Integer.parseInt(originTicketId));
			ps.executeUpdate();

			String sqlInsertHistory = "INSERT INTO shlp_support_ticket_history (ticket_id, update_system_user_id, update_scps_user_id, action_type, old_value, new_value, action_date) values (? ,null ,? ,? ,? ,? ,getdate())";
			ps = connection.prepareStatement(sqlInsertHistory);
			ps.setInt(1, Integer.parseInt(originTicketId));
			ps.setString(2, user.s_user_id);
			ps.setString(3, "REPLY_TICKET");
			ps.setString(4, "Ticket replied by " + user.s_user_name);
			ps.setString(5, "Ticket replied by " + s_subject);
			ps.executeUpdate();

			if(completed != null && completed.equals("true")) {

				String sql3 = "UPDATE shlp_support_ticket SET completed_date = ?  WHERE ticket_id = ?";
				ps = connection.prepareStatement(sql3);
				ps.setTimestamp(1, sqlTimestamp);
				ps.setInt(2, ticketId);
				ps.executeUpdate();
			}

			if(dueDate != null && !dueDate.equals("")){
				Date date = sdf.parse(dateString);

				String sql5 = "UPDATE shlp_support_ticket SET due_date = ?  WHERE ticket_id = ?";
				ps = connection.prepareStatement(sql5);
				ps.setTimestamp(1, new java.sql.Timestamp(date.getTime()));
				ps.setInt(2, Integer.parseInt(originTicketId));
				ps.executeUpdate();
			}

			boolean isFirstResponse = false;
			String sql7 = "SELECT COUNT(*) as count FROM shlp_support_ticket  WHERE origin_ticket_id = ?";
			ps = connection.prepareStatement(sql7);
			ps.setInt(1, Integer.parseInt(originTicketId));
			rs = ps.executeQuery();
			if(rs.next()) {
				int count = rs.getInt("count");
				if(count == 1) {
					isFirstResponse = true;
				}
			}
			if (isFirstResponse){
				String sql6 = "UPDATE shlp_support_ticket SET first_response_date = ? WHERE ticket_id = ?";
				ps = connection.prepareStatement(sql6);
				ps.setTimestamp(1, sqlTimestamp);
				ps.setInt(2, Integer.parseInt(originTicketId));
				ps.executeUpdate();
			}
		}

	}catch(Exception ex) {
		out.println("Hata: " + ex.getMessage());
		throw new RuntimeException(ex);
	}

	json.put("cust_id", s_cust_id);
	json.put("ticket_id", ticketId);
	if (ticketId != -1) {
		json.put("status", "success");
	} else {
		json.put("status", "fail");
	}
	if (isOriginTicket) {
		json.put("origin_ticket_id", originTicketId);
	}


	String supportEmail = null;
	PreparedStatement ps2 = null;
	ResultSet rs2 = null;
	String sqlRegistry = "SELECT key_value FROM  sadm_registry WHERE key_name = ?";
	try {
		ps = connection.prepareStatement(sqlRegistry);
		ps.setString(1, "support_email");
		rs2 = ps.executeQuery();
		if (rs2.next()) {
			supportEmail = rs2.getString("key_value");
			json.put("support_email", supportEmail);
		}

		arr.put(json);
		out.print(arr);

	} catch (Exception ex) {
		out.println("Hata: " + ex.getMessage());
		throw new RuntimeException(ex);
	}

%>


<%!
	public  String fixTurkishCharacters(String input) {
		if (input == null) {
			return null;
		}

		String s = input;


		s = s.replace("Ã„Â±", "ı");
		s = s.replace("Ã„ÂŸ", "ğ");
		s = s.replace("Ã„Âž", "Ğ");
		s = s.replace("Ã…ÅŸ", "ş");
		s = s.replace("Ã…Åž", "Ş");
		s = s.replace("ÃƒÂ¼", "ü");
		s = s.replace("ÃƒÂ–", "Ö");
		s = s.replace("ÃƒÂœ", "Ü");
		s = s.replace("ÃƒÂ§", "ç");
		s = s.replace("Ãƒâ€¹", "Ç");

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


	public static String turkishToEnglish(String text) {
		return text.replace("ç", "c")
				.replace("Ç", "C")
				.replace("ğ", "g")
				.replace("Ğ", "G")
				.replace("ı", "i")
				.replace("İ", "I")
				.replace("ö", "o")
				.replace("Ö", "O")
				.replace("ş", "s")
				.replace("Ş", "S")
				.replace("ü", "u")
				.replace("Ü", "U");
	}

%>

