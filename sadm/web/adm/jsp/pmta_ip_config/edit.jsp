<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
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
		<%
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sSql = null;

		try
		{
			cp = ConnectionPool.getInstance();	
			conn = cp.getConnection(this);
						
			try
			{	
				int id = Integer.parseInt(request.getParameter("id"));
				if(request.getParameter("update") != null)
				{					
					int pmtaIdUpdate = Integer.parseInt(request.getParameter("pmta"));
					String ipAddUpdate = request.getParameter("ipAdd");
					int custIdUpdate = Integer.parseInt(request.getParameter("custId"));
					String custNameUpdate = request.getParameter("custName");
					int statusUpdate = Integer.parseInt(request.getParameter("status"));
					String domainUpdate = request.getParameter("domain");
					
					//out.print(id +" "+pmtaIdUpdate+" "+ipAddUpdate+" "+custIdUpdate+" "+custNameUpdate+" "+statusUpdate);
					
					sSql = "Update mail_pmta_ip_config Set pmta_id = ?, ipAdress = ?, cust_id = ?, cust_name = ?, update_date = ?, status = ?, from_domain = ?  where id = ?";
					pstmt = conn.prepareStatement(sSql);			
					pstmt.setInt(1, pmtaIdUpdate);
					pstmt.setString(2, ipAddUpdate);
					pstmt.setInt(3, custIdUpdate);
					pstmt.setString(4, custNameUpdate);
					pstmt.setTimestamp(5, new Timestamp(System.currentTimeMillis()));	
					pstmt.setInt(6, statusUpdate);
					pstmt.setString(7, domainUpdate);
					pstmt.setInt(8, id);									
					pstmt.executeUpdate();			
					
					response.sendRedirect("index.jsp");
					return;
					
				}
				
				sSql = null;
				sSql = "select * from mail_pmta_ip_config with(nolock) where id = ?";					
				pstmt = conn.prepareStatement(sSql);
				pstmt.setInt(1, id);
				rs = pstmt.executeQuery();			


				byte[] b = null;
				while (rs.next())
				{
					String a = "";
				%>	<form action="" method="POST">
						<input type="hidden" name="update" value="U" />
						<input type="hidden" name="id" value="<% out.print(rs.getInt(1));%>" />
						<table class="table table-bordered">
							<tr>
								<th>PMTA #: </th>
								<td><input type="text" name="pmta" value="<% out.print(rs.getInt(2)); %>" /></td>
							</tr>
							<tr>
								<th>IP Address: </th>
								<td><input type="text" name="ipAdd" value="<%=rs.getString(3)%>" /></td>
							</tr>
							<tr>
								<td>Customer ID: </th>
								<td><input type="text" name="custId" value="<% out.print(rs.getInt(4)); %>" /></td>
							</tr>
							<tr>
								<th>Customer Name: </th>
								<td>
									<%   
										b = rs.getBytes(5); 
										a = (b==null)?null:new String(b, "UTF-8");								
									%>
									<input type="text" name="custName" value="<% out.print(a); %>" />						
								</td>
							</tr>
							<tr>
								<td>Domain : </td>
								<td>
									<%   
										b = rs.getBytes(9); 
										a = (b==null)?null:new String(b, "UTF-8");								
									%>
									<input type="text" name="domain" value="<% out.print(a); %>" />								
								</td>
							</tr>
							<tr>
								<th>Status: </th>
								<td><input type="text" name="status" value="<% out.print(rs.getInt(8)); %>"/></td>
							</tr>
							<tr>
								<td colspan="2"><input type="submit" name="submit" value="Update" /></td>
							</tr>							
						</table>					
					</form>
				<%
				}
				rs.close();							
			}
			catch(Exception ex)
			{
				throw new Exception(sSql+"\r\n"+ex.getMessage());
			}
			finally
			{
				if(pstmt != null) pstmt.close();
			}
		 }
		 catch(Exception e) {
			e.printStackTrace();
		 }
		 finally
		 {
			if (conn != null) cp.free(conn);		 
		 }
		%>
	</body>
</html>