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
<head></head>
<body>
<table cellpadding="5" border="1" cellspacing="0" style="border-collapse:collapse;">
<tr>
	<td>Cust Name</td>
	<td>Camp Id</td>
	<td>Camp Name</td>
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

		if(custID.length()==0)
		rs = stmt.executeQuery("select c.cust_name, cs.camp_id, cc.camp_name from cque_schedule cs with(nolock) left join cque_campaign cc with(nolock) on cs.camp_id=cc.camp_id left join ccps_customer c with(nolock) on cc.cust_id=c.cust_id where start_date> getdate() - "+showDay+" and cc.type_id=2 and cc.status_id > 10 and cc.status_id <=60 order by cust_name asc");
		else
		rs = stmt.executeQuery("select c.cust_name, cs.camp_id, cc.camp_name from cque_schedule cs with(nolock) left join cque_campaign cc with(nolock) on cs.camp_id=cc.camp_id left join ccps_customer c with(nolock) on cc.cust_id=c.cust_id where start_date> getdate() - "+showDay+" and cc.type_id=2 and cc.status_id > 10 and cc.status_id <=60  and c.cust_id="+custID+" order by cust_name asc");

	while (rs.next())
	{
		String custname = rs.getString("cust_name");
		String campid = rs.getString("camp_id");
		String campname = rs.getString("camp_name");
		
		out.println("<tr><td>"+custname+"</td><td>"+campid+"</td><td>"+campname+"</td></tr>");
		
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