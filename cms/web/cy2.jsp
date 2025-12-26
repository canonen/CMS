<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.imc.*, 
			java.sql.*, 
			java.io.*, 
			java.util.*, 
			java.net.*, 
			org.w3c.dom.*, 
			javax.servlet.*, 
			javax.servlet.http.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
 
<HTML>
<HEAD>
<META HTTP-EQUIV="Expires" CONTENT="0">
<META HTTP-EQUIV="Caching" CONTENT="">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-store, no-cache"> <!--, max-age=0" -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html;charset=UTF-8">

<script type="text/javascript" src="http://cms.revotas.com/cms/ui/js/report/fusioncharts/js/fusioncharts.js"></script>
<script type="text/javascript" src="http://cms.revotas.com/cms/ui/js/report/fusioncharts/js/themes/fusioncharts.theme.fint.js"></script>

<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>
<link rel="stylesheet" href="http://cms.revotas.com/cms/ui/ooo/style.css" TYPE="text/css">
<link rel="stylesheet" href="http://cms.revotas.com/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
<style>
body
{
	font-family: Tahoma;
	font-size: 11px;
	color: #333333;
	background-color: #F9F9F9;
	margin: 10px;
	border: 0px;

}
.page_header
{
	font: 20px/25px Tahoma;

}

.page_desc
{
	color: #555555;
	    font: 13px/25px Tahoma;
margin-bottom: 10px;
}
</style>


</HEAD>

<BODY>

<%

				Statement			stmt = null;
				ResultSet			rs = null; 
				ConnectionPool		cp = null;
				Connection			conn = null;

try
{
					cp = ConnectionPool.getInstance();
					conn = cp.getConnection(this);
					stmt = conn.createStatement();

	
String sql = "SELECT * FROM sms_camp WHERE camp_status=5 ";

try{ 
rs = con.createStatement();
rss = rs.executeQuery(sql);

}  

}
catch(Exception ex)
{ 
	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
}
finally
{
	try
	{
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn_w);
	}
	catch (SQLException e)
	{
		logger.error("Could not clean db statement or connection", e);
	}
}

%>


</BODY>