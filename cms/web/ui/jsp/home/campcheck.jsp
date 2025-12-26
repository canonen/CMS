<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.util.List,
			java.net.*,java.text.DateFormat,
			java.text.SimpleDateFormat,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<html>
<head>
   <style>
    	*, html, body {
    		font-family:Arial;
    		font-size:12px;
    	}
    	table td {
    		padding:6px;
    		border:1px solid #CCCCCC;
    	}
    </style>

</head>
<body>
<table align="center" cellpadding="5" border="1" cellspacing="0" style="border-collapse:collapse;">
<tr>
	<th>Cust Name</th>
	<th>Cust ID</th>
	<th>Camp Id</th>
	<th>Camp Name</th>
	<th>Start Date</th>
</tr>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 

String showDay = "1";
String custID="";

custID = request.getParameter("custID");

if(request.getParameter("d") != null)
{
	if(Integer.parseInt(request.getParameter("d")) > 10)
		showDay = "1";
	else
		showDay = request.getParameter("d");
}
	
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("campcheck.jsp");
	stmt = conn.createStatement();

		if(custID==null)
		rs = stmt.executeQuery("select c.cust_id,c.cust_name, cs.camp_id, cc.camp_name, cs.start_date from cque_schedule cs with(nolock) left join cque_campaign cc with(nolock) on cs.camp_id=cc.camp_id left join ccps_customer c with(nolock) on cc.cust_id=c.cust_id where start_date> getdate() - "+showDay+" and cc.type_id=2 and cc.status_id > 10 and cc.status_id <=60 and c.cust_id <> 619 order by cs.start_date asc");
		else
		rs = stmt.executeQuery("select c.cust_id,c.cust_name, cs.camp_id, cc.camp_name,cs.start_date from cque_schedule cs with(nolock) left join cque_campaign cc with(nolock) on cs.camp_id=cc.camp_id left join ccps_customer c with(nolock) on cc.cust_id=c.cust_id where start_date> getdate() - "+showDay+" and cc.type_id=2 and cc.status_id > 10 and cc.status_id <=60  and c.cust_id="+custID+" order by cs.start_date asc");

	while (rs.next())
	{
		String custname = rs.getString("cust_name");
		String campid = rs.getString("camp_id");
		String campname = rs.getString("camp_name");
		String custid = rs.getString("cust_id");
		String start_date = rs.getString("start_date");
		
		out.println("<tr><td>"+custname+"</td><td>"+custid+"</td><td>"+campid+"</td><td>"+campname+"</td><td>"+start_date+"</td></tr>");
		
	}
} 
catch(Exception ex)
{ 
	throw new Exception(ex);
}
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception e) {}
	if (conn != null) cp.free(conn);
}
%>
</table>
</body>
</html>