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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
<html>
	<head>
		<title>Revotas Administration</title>
		<meta content="text/html; charset=utf-8" http-equiv="Content-Type">
		
		<link rel="shortcut icon" type="image/ico" href="http://www.datatables.net/media/images/favicon.ico" />
		<link href="http://twitter.github.io/bootstrap/assets/css/bootstrap.css" rel="stylesheet">
		<style type="text/css" title="currentStyle">
			@import "js/demo_page.css";
			@import "js/demo_table.css";
		</style>
		<script type="text/javascript" language="javascript" src="js/jquery.js"></script>
		<script type="text/javascript" language="javascript" src="js/jquery.dataTables.js"></script>
		<script type="text/javascript" charset="utf-8">
			/* Define two custom functions (asc and desc) for string sorting */
			jQuery.fn.dataTableExt.oSort['string-case-asc']  = function(x,y) {
				return ((x < y) ? -1 : ((x > y) ?  1 : 0));
			};
			
			jQuery.fn.dataTableExt.oSort['string-case-desc'] = function(x,y) {
				return ((x < y) ?  1 : ((x > y) ? -1 : 0));
			};
			
			$(document).ready(function() {
				/* Build the DataTable with third column using our custom sort functions */
				$('#example').dataTable( {
					"aaSorting": [ [0,'asc'], [1,'asc'] ],
					"aoColumnDefs": [
						{ "sType": 'string-case', "aTargets": [ 2 ] }
					]
				} );
			} );
		</script>
	</head>
<body id="dt_example">
<div id="container">
		<%
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sSql = null;
		
		String ip=null;
		ip=request.getParameter("ip");
		
		try
		{
			cp = ConnectionPool.getInstance();	
			conn = cp.getConnection(this);
			if(ip==null)
			sSql = "select * from mail_pmta_ip_config with(nolock) order by status, update_date desc";
			else
			sSql = "select * from mail_pmta_ip_config with(nolock) where ipAdress='"+ip+"'order by status, update_date desc";
			try
			{				
				pstmt = conn.prepareStatement(sSql);
				rs = pstmt.executeQuery();			
				byte[] b = null;
				%>	
				<a class="btn btn-primary" href="add.jsp">ADD</a>
				<div id="demo">
				<table  align="center" class="display" style="border-collapse:collapse;border:1px solid #CCCCCC;" cellpadding="0" cellspacing="0" width="100%" id="example">					
					<thead>
					<tr>
						<th>PMTA #</th>
						<th>IP Address</th>
						<th>Customer ID</th>
						<th>Customer Name</th>
						<th>Create Date</th>
						<th>Update Date</th>
						<th>Domain</th>
						<th>Reputation</th>
						<th>Customer Type</th>
						<th>Hotmail Vol.</th>
						<th>Gmail Vol.</th>
						<th>Header</th>
						<th>Status</th>
						<th>Options</th>
					</tr>	
						</thead>
					
					<tbody>
				<%
				while (rs.next())
				{
					String a = "";
					%>
					<tr class="A">
						<td><% out.print(rs.getInt(2)); %></td>
						<td>
							<%=rs.getString(3)%>
						</td>
						<td><a href="http://cms.revotas.com/cms/ui/jsp/home/campcheck.jsp?d=2&custID=<%= rs.getInt(4)%>" target="_blank"><%= rs.getInt(4)%></a></td>
						
						<td>
							<%   
								b = rs.getBytes(5); 
								a = (b==null)?null:new String(b, "UTF-8");		
								out.print(a);
							%>
						</td>
						<td><%=rs.getString(6)%></td>
						<td><%=rs.getString(7)%></td>
						<td><%=rs.getString(9)%></td>
						<td><%=rs.getString(10)%></td>
						<td><%=rs.getString(11)%></td>
						<td><%=rs.getString(12)%></td>
						<td><%=rs.getString(13)%></td>
						<td><%=rs.getString(14)%></td>
						<td><% if(rs.getInt(8) == 0){out.print("Passive");}else{out.print("Active");} %></td>
						<td><a class="btn btn-small" href="edit.jsp?id=<% out.print(rs.getInt(1)); %>">Edit</a> <a class="btn btn-danger" href="delete.jsp?id=<% out.print(rs.getInt(1)); %>">Delete</td>
					</tr>
					<%
				}
				%>
						</tbody>		
				</table>
				</div>
					<div class="spacer"></div>		
				<%
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
		</div>
	</body>
</html>