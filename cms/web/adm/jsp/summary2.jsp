<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="shortcut icon" type="image/ico" href="http://www.revotas.com/v5/favicon.ico" />
<title>Delivery Monitor Dashboard</title></head>
<body>
<center>
<h2>Delivery Monitor Dashboard CPS/INB</h2>

<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;border-color:#aaa;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#aaa;color:#333;background-color:#fff;border-top-width:1px;border-bottom-width:1px;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#aaa;color:#fff;background-color:#f38630;border-top-width:1px;border-bottom-width:1px;}
.tg .tg-s6z2{text-align:center}
</style>
<table>
<%@ page import="java.util.*" %>
<%@ page import="javax.sql.*;" %>
<% 

java.sql.Connection con;
java.sql.Statement s;
java.sql.ResultSet rs;
java.sql.PreparedStatement pst;

con=null;
s=null;
pst=null;
rs=null;

// Revotas Inb Sql Connection
String url= 
"jdbc:jtds:sqlserver://inb.revotas.com";
String id= "revotasadm";
String pass = "l3br0nj4m3s";
try{

Class.forName("net.sourceforge.jtds.jdbc.Driver");
con = java.sql.DriverManager.getConnection(url, id, pass);

}catch(ClassNotFoundException cnfex){
cnfex.printStackTrace();

}
String sql = "use mail_pmta_accounting SELECT  Summary_1.cust_name,Summary.custId,Summary.camp_Id,Summary.recip_total_qty,Summary.recip_sent_qty,Summary.Delivered,Summary.Bounced FROM Summary with(nolock)INNER JOIN CPS.brite_ccps_500.dbo.ccps_customer AS Summary_1 ON Summary.custId = Summary_1.cust_id WHERE Summary_1.cust_id not in (120,121,122, 381,382, 451, 619) ";
try{
s = con.createStatement();
rs = s.executeQuery(sql);
%>


		<table class="tg">
		<th width="14%">Customer Name</th>
		<th width="14%">Customer Id</th>
		<th width="14%">Campaing Id</th>
		<th width="10%">Queued</th>
		<th width="10%">Sent</th>
		<th width="11%">Delivered</th>
		<th width="10%">BounceBacks</th>




<%
while( rs.next() )

{
%>

	<tr>
		<td width="19%"><%= rs.getString("cust_name") %></td>
		<td width="19%"><%= rs.getString("custId") %></td>
		<td width="19%"><%= rs.getString("camp_Id") %></td>
		<td width="15%"><%= rs.getString("recip_total_qty") %></td>
		<td width="15%"><%= rs.getString("recip_sent_qty") %></td>
		<td width="15%"><%= rs.getString("Delivered") %></td>
		<td width="15%"><%= rs.getString("Bounced") %></td>

	</tr>    
   
</tr>
<%
}
%>

<%

}
catch(Exception e){e.printStackTrace();}
finally{
if(rs!=null) rs.close();
if(s!=null) s.close();
if(con!=null) con.close();
}

%>
</table>
</body>
</html>