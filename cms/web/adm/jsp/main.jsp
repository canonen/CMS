<html>
<HEAD><title>Inbound Email Check</title>
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
</head>



<body>

<center>
<h2>Inbound Email Check</h2>

<p><b>First Name:</b>
<%=request.getParameter("first_name")%>



	<%
	String first_name = "";
	%>
	<%
	
	first_name = request.getParameter("first_name");
	
	%>


</p>

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
"jdbc:jtds:sqlserver://78.135.110.4";
String id= "revotasadm";
String pass = "abs0lut";
try{

Class.forName("net.sourceforge.jtds.jdbc.Driver");
con = java.sql.DriverManager.getConnection(url, id, pass);

}catch(ClassNotFoundException cnfex){
cnfex.printStackTrace();

}
String sql = "use mail_pmta_accounting select * from mail_pmta_acct where emailTo ='"+first_name+"'";
try{
s = con.createStatement();
rs = s.executeQuery(sql);
%>


		<table class='listTable' style='border-collapse:collapse;border:1px solid #CCCCCC;' cellpadding='0' cellspacing='0' width='100%' id='example'>
		<thead>
		
			<th>Report Type</th>
				<th>Customer Id</th>		
				<th>Campaing Id</th>		
				<th>Time Delivered</th>		
				<th>Time Queued</th>	
				<th>Email To</th>		
				<th>Email From</th>
				<th>Ip To</th>
				<th>Ip From</th>		
				<th>Time Bounced</th>
				<th>Dsn Action</th>
				<th>Dsn Status</th>
				<th>Dsn Remote Mta</th>
		<th>Dsn Diagnostig</th>
		</thead>
<%
while( rs.next() )

{
%>

	<tr>
	<td><%= rs.getString("reportType") %></td>
			<td><%= rs.getString("custId") %></td>
			<td><%= rs.getString("campId") %></td>		
			<td><%= rs.getString("timeDelivered") %></td>
			<td><%= rs.getString("timeQueued") %></td>
			<td><%= rs.getString("emailTo") %></td>		
			<td><%= rs.getString("emailFrom") %></td>
			<td><%= rs.getString("ipTo") %></td>
			<td><%= rs.getString("ipFrom") %></td>		
			<td><%= rs.getString("timeBounced") %></td>
			<td><%= rs.getString("dsnAction") %></td>
			<td><%= rs.getString("dsnStatus") %></td>
			<td><%= rs.getString("dsnRemoteMta") %></td>
		<td><%= rs.getString("dsnDiagnostics") %></td>

		

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