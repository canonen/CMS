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

String machine_id = BriteRequest.getParameter(request, "machine_id");

if((machine_id == null) || ("".equals(machine_id)))
{
	machine_id = "0";
}

out.print("<MachineModules>");

if (!"0".equals(machine_id))
{
	Properties m_Props = null;
	m_Props = loadProps(session, "props.conf");

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
		
		sSQL = "select mo.abbreviation, ma.ip_address" +
				" from sadm_machine ma with(nolock)" +
				" left outer join sadm_mod_inst mi with(nolock) on ma.machine_id = mi.machine_id" +
				" left outer join sadm_module mo with(nolock) on mo.mod_id = mi.mod_id" +
				" where ma.machine_id = '" + machine_id + "'" +
				" order by mo.abbreviation";

		String sAbbr = null;
		String sIP = null;
		String sServ = null;
		String sDBName = null;
		String sUser = null;
		String sPass = null;
		
		sUser = m_Props.getProperty("default_userName");
		sPass = m_Props.getProperty("default_password");
		
		Vector services = null;
		Service service = null;
		
		String sRequest = null;
		String sResponse = null;
		Exception ex = null;

		rs = stmt.executeQuery(sSQL);

		byte[] b = null;
		while(rs.next())
		{
			sAbbr = rs.getString(1);
			sIP = rs.getString(2);
			
			sServ = m_Props.getProperty(sAbbr + "_SQLIP_" + sIP);
			sDBName = m_Props.getProperty(sAbbr + "_dbName_" + sIP);
			
			out.print("<module><module_abbr>" + sAbbr + "</module_abbr>");
			out.print("<machine_ip>" + sIP + "</machine_ip>");
			out.print("<sql_ip>" + sServ + "</sql_ip>");
			out.print("<db_name>" + sDBName + "</db_name>");
			out.print("<db_user>" + sUser + "</db_user>");
			out.print("<db_pass>" + sPass + "</db_pass></module>");
		}
		rs.close();
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

out.print("</MachineModules>");

%>