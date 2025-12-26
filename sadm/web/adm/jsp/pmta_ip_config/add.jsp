<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	
	import="java.text.SimpleDateFormat"	
	import="java.util.Calendar.*"
	import="java.util.Date"
    import="java.text.DateFormat"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>


<%

	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	String sSql = "";

	try
	{			
	
		if(request.getParameter("pmta") != null)
		{
			int pmtaId = Integer.parseInt(request.getParameter("pmta"));				
			String ipAdress = request.getParameter("ipAdd");
			int custId = Integer.parseInt(request.getParameter("custId"));
			String custName = request.getParameter("custName");
			String domain = request.getParameter("domain");
			int reputation = Integer.parseInt(request.getParameter("reputation"));
			String cust_type = request.getParameter("cust_type");
			int hotmail_volume = Integer.parseInt(request.getParameter("hotmail_volume"));
			int gmail_volume = Integer.parseInt(request.getParameter("gmail_volume"));
			String header_type = request.getParameter("header_type");
			
			cp = ConnectionPool.getInstance();	
			conn = cp.getConnection(this);			
			sSql = "insert into mail_pmta_ip_config (pmta_id, ipAdress, cust_id, cust_name, create_date, update_date, status, from_domain, reputation, cust_type, hotmail_volume, gmail_volume, header_type) values (?, ?,?,?,?,?,1,?,?,?,?,?,?)";


			
			pstmt = conn.prepareStatement(sSql);			
			pstmt.setInt(1, pmtaId);
			pstmt.setString(2, ipAdress);
			pstmt.setInt(3, custId);
			pstmt.setString(4, custName);
			pstmt.setTimestamp(5, new Timestamp(System.currentTimeMillis()));		
			pstmt.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
			pstmt.setString(7, domain);
			pstmt.setInt(8, reputation);
			pstmt.setString(9, cust_type);
			pstmt.setInt(10, hotmail_volume);
			pstmt.setInt(11, gmail_volume);
			pstmt.setString(12, header_type);
			pstmt.executeUpdate();
			
			response.sendRedirect("index.jsp");
			return;
		}																		
	
	 }
	 catch(Exception e) {
		e.printStackTrace();
	 }
	 finally
	 {
		if(pstmt != null) pstmt.close();
		if (conn != null) cp.free(conn);		 
	 }
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
<html>
	<head>
		<title>Revotas Administration</title>
		<meta content="text/html; charset=utf-8" http-equiv="Content-Type">
		<link href="http://twitter.github.io/bootstrap/assets/css/bootstrap.css" rel="stylesheet">
		<style>
		body {
			margin:15px;
		}
		</style>
	</head>
	<body>
		<form action="" method="POST">	
			<table class="table table-bordered">					
				<tr>
					<th>PMTA #: </th>
					<td><input type="text" name="pmta" value=""/></td>
				</tr>
				<tr>
					<th>IP Address: </th>
					<td><input type="text" name="ipAdd" value=""/></td>
				</tr>
				<tr>
					<th>Customer ID: </th>
					<td><input type="text" name="custId" value=""/></td>
				</tr>
				<tr>
					<th>Customer Name: </th>
					<td><input type="text" name="custName" value=""/></td>
				</tr>
				<tr>
					<th>Domain : </th>
					<td><input type="text" name="domain" value=""/></td>
				</tr>

				<tr>
					<th>Reputation : </th>
					<td><input type="text" name="reputation" value=""/></td>
				</tr>
				<tr>
					<th>Customer Type : </th>
					<td><input type="text" name="cust_type" value=""/></td>
				</tr>

				<tr>
					<th>Hotmail Volume : </th>
					<td><input type="text" name="hotmail_volume" value=""/></td>
				</tr>				
				<tr>
					<th>Gmail Volume : </th>
					<td><input type="text" name="gmail_volume" value=""/></td>
				</tr>
				<tr>
					<th>Header_type : </th>
					<td><input type="text" name="header_type" value=""/></td>
				</tr>				
				<tr>
					<td colspan=2><input type="submit" name="submit" value="submit"/></td>
				</tr>
			</table>		
		</form>
	</body>
</html>