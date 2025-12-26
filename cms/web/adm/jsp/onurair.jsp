<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="shortcut icon" type="image/ico" href="http://www.revotas.com/v5/favicon.ico" />
<title>Onur Air Smtp Dashboard</title></head>
<body>
<center>
<h2>Onur Air Smtp Dashboard</h2>

<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;border-color:#aaa;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#aaa;color:#333;background-color:#fff;border-top-width:1px;border-bottom-width:1px;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#aaa;color:#fff;background-color:#ff3333;border-top-width:1px;border-bottom-width:1px;}
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
String pass = "abs0lut";
try{

Class.forName("net.sourceforge.jtds.jdbc.Driver");
con = java.sql.DriverManager.getConnection(url, id, pass);

}catch(ClassNotFoundException cnfex){
cnfex.printStackTrace();

}
String sql = "use mail_pmta_accounting select emailFrom as id,count(*) as sayi from mail_pmta_acct with (nolock) where mtaDnsName like '%91.229.155.28%' or mtaDnsName like '%91.229.155.254%' or mtaDnsName like '%46.34.90.132%' or mtaDnsName like '%23.253.98.190%' or mtaDnsName like '%91.229.155.18%' or mtaDnsName like '%91.229.155.20%' or mtaDnsName like '%91.229.155.68%' or mtaDnsName like '%91.229.155.83%' or mtaDnsName like '%46.34.90.186%' or mtaDnsName like '%46.34.90.157%' or mtaDnsName like '%91.229.155.108%'  group by emailfrom order by sayi desc";   
try{
s = con.createStatement();
rs = s.executeQuery(sql);
%>


<table class="tg">
		<th width="14%">Email From </th>
		<th width="14%">Count</th>
	
<%
while( rs.next() )

{
%>
	<tr>
		<td center width="19%"><%= rs.getString("id") %></td>
		<td center width="19%"><%= rs.getString("sayi") %></td>
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