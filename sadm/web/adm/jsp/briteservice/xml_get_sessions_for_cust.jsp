<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*" 
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*" 
	import="org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%
response.setHeader("Expires", "0");
response.setHeader("Pragma", "no-cache");
response.setHeader("Cache-Control", "no-store, no-cache, max-age=0");
response.setContentType("text/xml;charset=UTF-8");
%>
<%@ include file="functions.jsp"%>
<%

String cust_id = BriteRequest.getParameter(request, "cust_id");
String login_period = BriteRequest.getParameter(request, "login_period");
String idle_time = BriteRequest.getParameter(request, "idle_time");
if((cust_id == null) || ("".equals(cust_id)))
{
	cust_id = "0";
}
out.print("<machine>");

if (!"0".equals(cust_id))
{
	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null; 
	String sSQL = null;
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();
		
		sSQL = "select mi.mod_inst_id, ma.ip_address" +
			   "  from sadm_customer c with(nolock)" +
			   "  left outer join sadm_cust_mod_inst cmi with(nolock) on c.cust_id = cmi.cust_id" +
			   "  left outer join sadm_mod_inst mi with(nolock) on mi.mod_inst_id = cmi.mod_inst_id" +
			   "  left outer join sadm_module mo with(nolock) on mo.mod_id = mi.mod_id" +
			   " inner join sadm_machine ma with(nolock) on ma.machine_id = mi.machine_id" +
			   " where c.cust_id = '" + cust_id + "' and mo.abbreviation = 'CCPS'"+
			   " order by mo.abbreviation";

		String sModInstId = null;
		String sIP = null;
		Vector services = null;
		Service service = null;
		String sRequest = null;
		String sResponse = null;
		Exception ex = null;

		rs = stmt.executeQuery(sSQL);
		rs.next();
		sModInstId = rs.getString(1);
		sIP = rs.getString(2);
		rs.close();
		
		// now we have the cps instance id
		sRequest = "<Request>" +
				   "  <cust_id>"+cust_id+"</cust_id>" +
				   "  <cps>"+sIP+"</cps>" +
				   "  <login_period>"+login_period+"</login_period>" +
				   "  <idle_time>"+idle_time+"</idle_time>" +
				   "</Request>";
		services = Services.get(ServiceType.CCPS_SESSION_MONITOR_REPORT, sModInstId, cust_id);
		service = (Service) services.get(0);
		try	
		{
			service.connect();
			service.send(sRequest);
			sResponse = service.receive();
			out.print(sResponse);
		}
		catch(Exception e) {
			ex = e;
		}
		finally { service.disconnect();}		
	}
	catch(Exception ex)
	{
		ex.printStackTrace(response.getWriter());
	}
	finally
	{
		if(conn!=null) cp.free(conn);
	}
}

out.print("</machine>");

%>