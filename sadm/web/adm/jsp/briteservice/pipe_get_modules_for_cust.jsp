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
%><%
response.setHeader("Expires", "0");
response.setHeader("Pragma", "no-cache");
response.setHeader("Cache-Control", "no-store, no-cache, max-age=0");
response.setContentType("text/html;charset=UTF-8");

String cust_id = BriteRequest.getParameter(request, "cust_id");

if((cust_id == null) || ("".equals(cust_id)))
{
	cust_id = "0";
}

if (!"0".equals(cust_id))
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
		conn = cp.getConnection("pipe_get_modules_for_cust.jsp");
		stmt = conn.createStatement();
		
		sSQL = "select mi.mod_inst_id, mo.abbreviation, ma.ip_address" +
				" from sadm_customer c with(nolock)" +
				" left outer join sadm_cust_mod_inst cmi with(nolock) on c.cust_id = cmi.cust_id" +
				" left outer join sadm_mod_inst mi with(nolock) on mi.mod_inst_id = cmi.mod_inst_id" +
				" left outer join sadm_module mo with(nolock) on mo.mod_id = mi.mod_id" +
				" inner join sadm_machine ma with(nolock) on ma.machine_id = mi.machine_id" +
				" where c.cust_id = '" + cust_id + "' order by mo.abbreviation";
		
		String sModInstId = null;
		String sAbbr = null;
		String sIP = null;
		String sServ = null;
		String sDBName = null;
		String sUser = null;
		String sPass = null;
		int iCount = 0;
		
		sUser = m_Props.getProperty("default_userName");
		sPass = m_Props.getProperty("default_password");
		
		Vector services = null;
		Service service = null;
		
		String sRequest = null;
		String sResponse = null;
		Exception ex = null;

		rs = stmt.executeQuery(sSQL);

		while(rs.next())
		{
			if (iCount == 0)
			{
				out.print("abbreviation|ip_address|db_server|db_name|db_user|db_pwd\r\n");
			}
			
			iCount++;
			
			sModInstId = rs.getString(1);
			sAbbr = rs.getString(2);
			sIP = rs.getString(3);
			
			if ("RRCP".equals(sAbbr))
			{
				services = Services.get(ServiceType.RRCP_CUST_DBNAME, sModInstId, cust_id);
				service = (Service) services.get(0);
				
				sRequest = "<Customer><cust_id>" + cust_id + "</cust_id></Customer>";
				
				try
				{
					service.connect();
					service.send(sRequest);
					sResponse = service.receive();
					
					Element eResponse = XmlUtil.getRootElement(sResponse);

					sDBName = XmlUtil.getChildCDataValue(eResponse,"dbName");
				}
				catch(Exception e)
				{
					ex = e;
					sDBName = "brite_rrcp_500_common";
				}
				finally { service.disconnect();}
			}
			else
			{
				sDBName = m_Props.getProperty(sAbbr + "_dbName_" + sIP);
			}
			
			sServ = m_Props.getProperty(sAbbr + "_SQLIP_" + sIP);
			
			out.print(sAbbr + "|" + sIP + "|" + sServ + "|" + sDBName + "|" + sUser + "|" + sPass + "\r\n");
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
%><%@ include file="functions.jsp"%>