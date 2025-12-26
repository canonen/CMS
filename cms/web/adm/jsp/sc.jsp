<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="shortcut icon" type="image/ico" href="http://www.revotas.com/v5/favicon.ico" />
<title>Delivery Monitor Dashboard</title></head>
<body>
<center>
<h2>s</h2>

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
"jdbc:jtds:sqlserver://rcp2.revotas.com";
String id= "revotasadm";
String pass = "l3br0nj4m3s";
try{

Class.forName("net.sourceforge.jtds.jdbc.Driver");
con = java.sql.DriverManager.getConnection(url, id, pass);

}catch(ClassNotFoundException cnfex){
cnfex.printStackTrace();

}
String sql = "SELECT u._camp_id FROM   untt_mbs_order u, rrcp_recipient r WHERE u._amount IS NOT NULL ";

try{
s = con.createStatement();
rs = s.executeQuery(sql);
%>







<%
while( rs.next() )

{
%>


<%= rs.getString(1) %>

ssss
  
   
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