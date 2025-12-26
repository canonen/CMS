<html>
<head>

<META http-equiv=Expires content=0>
<META http-equiv=Caching content="">
<META http-equiv=Pragma content=no-cache>
<META http-equiv=Cache-Control content=no-cache>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="http://cms.revotas.com/cms/ui/ooo/style.css" TYPE="text/css">
<link rel="stylesheet" href="http://cms.revotas.com/cms/ui/css/demo_table_jui.css" TYPE="text/css">
<link rel="stylesheet" href="http://cms.revotas.com/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
<script src="http://code.jquery.com/jquery-1.8.3.js"></script>
<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>
<SCRIPT src="http://cms.revotas.com/cms/ui/js/jquery.dataTables.min_new.js"></SCRIPT>
                <script type="text/javascript">
                                $(document).ready(function() {
                                                $("#checkboxall").click(function()
                                                {
                                                                var checked_status = this.checked;
                                                                $(".check_me").each(function(){
                                                                                this.checked = checked_status;
                                                                });
                                                });

                                                $('#example tbody td').hover( function() {
                                                                $(this).siblings().addClass('highlighted');
                                                                $(this).addClass('highlighted');
                                                }, function() {
                                                                $(this).siblings().removeClass('highlighted');
                                                                $(this).removeClass('highlighted');
                                                } );
                                                $('#example2 tbody td').hover( function() {
                                                                $(this).siblings().addClass('highlighted');
                                                                $(this).addClass('highlighted');
                                                }, function() {
                                                                $(this).siblings().removeClass('highlighted');
                                                                $(this).removeClass('highlighted');
                                                } );
                                                oTable = $('#example').dataTable( {
                                                                                                                "bJQueryUI": true,
                                                                                                                "sPaginationType": "full_numbers"
                                                                } );
                                                oTable2 = $('#example2').dataTable({
                                                                "sDom": "tlrip",
                                                                "aoColumns": [null,null,null,null,null,null,null],
                                                                "aaSorting": [[ 0, "desc" ]]
                                                });

                                                $('#filter').change( function(){
                                                                filter_string = $('#filter').val();
                                                                oTable.fnFilter( filter_string , 4);
                                                                filter_string = $('#filter').val();
                                                                oTable2.fnFilter( filter_string , 3);
                                                });
                                } );
                </script>



<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="shortcut icon" type="image/ico" href="http://www.revotas.com/v5/favicon.ico" />
<title>Weekly Top 5 ISP Errors</title>


</head>
<body>
<center>
<h2>Daily Top 100.000 ISP Errors </h2>

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
String sql = "use mail_pmta_accounting select * from topdsn where custid <> 620 ";
try{
s = con.createStatement();
rs = s.executeQuery(sql);
%>


		<table class='listTable' style='border-collapse:collapse;border:1px solid #CCCCCC;' cellpadding='0' cellspacing='0' width='100%' id='example'>
		<thead>
		
		<th width="10%">Customer</th>
		<th width="10%">Status</th>
		<th width="10%">Mta Code</th>
		<th width="10%">Dsn Errors</th>
		<th width="10%">Piece</th>
		
		
		</thead>




<%
while( rs.next() )

{
%>

	<tr>
		<td width="19%"><%= rs.getString("custid") %></td>
		<td width="19%"><%= rs.getString("dsnStatus") %></td>
		<td width="19%"><%= rs.getString("dsnRemoteMta") %></td>
		<td width="19%"><%= rs.getString("Dsn") %></td>
		<td width="19%"><%= rs.getString("piece") %></td>

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