<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>

<HTML>

<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>

<BODY>

STARTING TEST!<BR>

<%
ConnectionPool cp = null;
Connection conn = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	
	Statement	stmt = null;
	
	try
	{
		String sSql =
			" SELECT" +
			"	DISTINCT mi.mod_inst_id, ma.ip_address, mo.abbreviation" +
			" FROM" +
			" 	sadm_cust_mod_inst cmi," +
			" 	sadm_mod_inst mi," +
			" 	sadm_mod_inst_service mis," +
			" 	sadm_machine ma," +
			" 	sadm_module mo" +
			" WHERE" +
			" 	mi.mod_inst_id = cmi.mod_inst_id AND" +
			" 	mis.mod_inst_id = mi.mod_inst_id AND" +
			" 	mi.mod_id = mo.mod_id AND" +
			" 	mi.machine_id = ma.machine_id AND" +
			" 	mis.service_type_id = " + ServiceType.CUST_UNIQUE_ID_MONITOR;

		String outXml =
			"<cust_unique_ids>\r\n" +
			"<cust_id></cust_id>\r\n" +
			"</cust_unique_ids>\r\n";

		String sInXml = null;

		stmt = conn.createStatement();
		ResultSet rs = stmt.executeQuery(sSql);

		String sModInstId = null;
		String sIPAddr = null;
		String sModule = null;
		CustUniqueId cui = null;
		
		int nMinId = 0;
		int nMaxId = 0;
		int nNextId = 0;
		
		int nPercentLeft = 0;		

		while (rs.next())
		{
			sModInstId = rs.getString(1);
			sIPAddr = rs.getString(2);
			sModule = rs.getString(3);
			
			Vector services = null;
			Service service = null;
			try
			{
				services = Services.getByModInst(ServiceType.CUST_UNIQUE_ID_MONITOR, sModInstId);
				service = (Service) services.get(0);
			}
			catch(Exception ex)
			{
%>
ServiceType.CUST_UNIQUE_ID_MONITOR is absent on ModInstId = <%=sModInstId%> (sIPAddr=<%=sIPAddr%>)
<%
				continue;
			}

%>
Checking URL: <%=service.getURL()%><BR>
<%

			CustUniqueIds cuis = null;
			try
			{
				service.connect();

				service.send(outXml);
				sInXml = service.receive();

				service.disconnect();
			
				Element e = XmlUtil.getRootElement(sInXml);
				cuis = new CustUniqueIds(e);
				if(cuis.size() < 1) continue;				
			}
			catch(Exception ex)
			{
				logger.info("ERROR: "+service.getURL()+" - "+ex.getMessage());
%>
ALERT ERROR: <%=ex.getMessage()%><BR>
<%
				continue;
			}

			for (Enumeration en = cuis.elements() ; en.hasMoreElements() ;)
			{
				cui = (CustUniqueId) en.nextElement();

				if( cui.s_min_id == null ) cui.s_min_id = "0";
				if( cui.s_max_id == null ) cui.s_max_id = "0";
				if( cui.s_next_id == null ) cui.s_next_id = "0";
				
				nMinId = Integer.parseInt(cui.s_min_id);
				nMaxId = Integer.parseInt(cui.s_max_id);
				if (Integer.parseInt(cui.s_type_id) == UniqueIdType.RECIP_ID) nMaxId = 2147483646;
				nNextId = Integer.parseInt(cui.s_next_id);

				nPercentLeft = (Double.valueOf((nMaxId - nNextId)/((nMaxId - nMinId)/100.0))).intValue();

				if(nPercentLeft < 15)
				{
%>
<TABLE cellspacing=0 cellpadding=1 border=1>
<TR>
<TD>ALERT<TD>
<TD>Left: <%=nPercentLeft%>%<TD>
<TD>Customer id: <%=cui.s_cust_id%><TD>
<TD>ID type id: <%=cui.s_type_id%><TD>
<TD>Min ID: <%=cui.s_min_id%><TD>
<TD>Max ID: <%=cui.s_max_id%><TD>
<TD>Next ID: <%=cui.s_next_id%><TD>
<TD>sModInstId: <%=sModInstId%><TD>
<TD>URL: <%=service.getURL()%><TD>
</TR>
<TABLE>
<%
					logger.info("UNIQUE ID ALERT - Left: " + nPercentLeft + "% - Customer id: " + cui.s_cust_id 
							+ " - ID type id: " + cui.s_type_id + " - Min ID: " + cui.s_min_id
							+ " - Max ID: " + cui.s_max_id + " - Next ID: " + cui.s_next_id 
							+ " - ModInstId: " + sModInstId + " - URL:" + service.getURL());
				}
			}
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally { if(stmt!=null) stmt.close(); }
}
catch(Exception ex) {
	logger.error("Exception: ", ex);
%>
ALERT ERROR: <%=ex.getMessage()%><BR>
<%
}
finally { if(conn!=null) cp.free(conn); }
%>

TEST IS DONE!

</BODY>

</HTML>
