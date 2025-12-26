<%@ page language="java"
		 import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>
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
<%

	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String subject = request.getParameter("subject");
	String originalIssue = request.getParameter("original_issue");
	String furtherInfo = request.getParameter("further_info");
	String originTicketId = request.getParameter("origin_ticket_id");
	boolean isOriginTicket = false;

	if (originTicketId != null && !originTicketId.equals("") && !originTicketId.equals("0")) {
		isOriginTicket = true;
	}
	String image = request.getParameter("image");

	if (subject != null && !subject.equals(""))
		subject = new String(subject.getBytes("ISO-8859-1"),"UTF-8");
	if (originalIssue != null && !originalIssue.equals(""))
		originalIssue = new String(originalIssue.getBytes("ISO-8859-1"),"UTF-8");
	if (image != null && !image.equals(""))
		image = new String(image.getBytes("ISO-8859-1"),"UTF-8");


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
		final  String dbUser = "revotasadm";
		final  String dbPassword = "abs0lut";

		sql = "INSERT INTO shlp_support_ticket (origin_ticket_id ,cust_id, user_id, status_id, subject, original_issue, further_info, image, create_date , modify_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
		ps.executeUpdate();

		rs = ps.getGeneratedKeys();
		if (rs.next()) {
			ticketId = rs.getInt(1);
		}

		rs.close();
		ps.close();

		if (isOriginTicket) {
			sql = "UPDATE shlp_support_ticket SET origin_ticket_id = ?  WHERE ticket_id = ?";
			ps = connection.prepareStatement(sql);
			ps.setInt(1, Integer.parseInt(originTicketId));
			ps.setInt(2, ticketId);
			ps.executeUpdate();

			sql = "UPDATE shlp_support_ticket SET modify_date = ?  WHERE ticket_id = ?";
			ps = connection.prepareStatement(sql);
			ps.setTimestamp(1, sqlTimestamp);
			ps.setInt(2, Integer.parseInt(originTicketId));
			ps.executeUpdate();
		}

	}catch(Exception ex) {
		out.println("Hata: " + ex.getMessage());
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
	arr.put(json);
	out.print(arr);

%>

