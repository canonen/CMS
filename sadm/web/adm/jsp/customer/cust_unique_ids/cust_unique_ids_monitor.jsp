<%@ page language="java"%>
<%@ page import="com.britemoon.*"%>
<%@ page import="com.britemoon.sas.*"%>
<%@ page import="com.britemoon.sas.imc.*"%>" +
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="org.w3c.dom.*"%>
<%@ page import="org.apache.log4j.*"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>
<HTML>
<HEAD>
	<TITLE>Customer Unique IDs</TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>
<BODY>
<%
ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("mod_customer.jsp");
	stmt = conn.createStatement();

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

	String outXml = "<cust_unique_ids><cust_id></cust_id></cust_unique_ids>";
	String sInXml = null;

	ResultSet rs = stmt.executeQuery(sSql);
%>
<table cellpadding="3" cellspacing="0" border="0" class="listTable" width="350">
	<tr>
		<th colspan="4">Getting IDs</th>
	</tr>
<%
	while (rs.next())
	{
		String sModInstId = rs.getString(1);
		String sIPAddr = rs.getString(2);
		String sModule = rs.getString(3);
		
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

		logger.info("Cust Unique ID Monitor - updating IDs\r\nConnecting to "+sModule+" Module at "+sIPAddr);
%>
	<tr>
		<td class="listItem_Data"><b>Module: </b></td>
		<td class="listItem_Data"><%= sModule %></td>
		<td class="listItem_Data"><b>IP Address: </b></td>
		<td class="listItem_Data"><%= sIPAddr %></td>
	</tr>
<%
		try
		{
			service.connect();

			service.send(outXml);
			sInXml = service.receive();

			service.disconnect();
		
			Element eCustUniqueIds = XmlUtil.getRootElement(sInXml);
			CustUniqueIds cui = new CustUniqueIds(eCustUniqueIds);
			cui.save();
		}
		catch(Exception ex)
		{
%>
	<tr>
		<td class="listItem_Data"><b style="color:red;">Error: </b></td>
		<td class="listItem_Data" colspan="3"><%= ex.getMessage() %></td>
	</tr>
			<%
		}
	}
	rs.close();
%>
</table>
<br>
<table class="listTable" width="100%" cellspacing="0" cellpadding="2" border="0">
	<tr>
		<th nowrap>Customer</th>
<%
	sSql = 
		" SELECT t.type_id, t.type_name" +
		" FROM sadm_unique_id_type t" +
		" ORDER BY t.type_name";

	rs = stmt.executeQuery(sSql);
	while(rs.next())
	{
		int nTypeID = rs.getInt(1);
		String sTypeName = rs.getString(2);
%>
		<th nowrap><%=( sTypeName + " (" + nTypeID + ")" )%></th>
<%
	}
	rs.close();
%>
	</tr>
<%
	sSql  = 
		" SELECT ct.type_id, ct.type_name, ct.cust_id, ct.cust_name," +
		" ISNULL(u.min_id,0), ISNULL(u.max_id,0), ISNULL(u.next_id,0)" +
		" FROM (SELECT t.type_id, t.type_name, c.cust_id, c.cust_name" +
		" 		FROM sadm_unique_id_type t, sadm_customer c) AS ct" +
		" 	LEFT OUTER JOIN sadm_cust_unique_id u" +
		"		ON ( ct.type_id = u.type_id )" +
		" 		AND ( ct.cust_id = u.cust_id )" +
		" ORDER BY ct.cust_id, ct.type_name";

	rs = stmt.executeQuery(sSql);
	int nextCustID = 0;
	int curCustID = -1;
		
	int iCount = 0;
	String sClassAppend = "";

	while(rs.next())
	{
		int nTypeID = rs.getInt(1);
		String sTypeName = rs.getString(2);
		nextCustID = rs.getInt(3); 
		String sCustName = rs.getString(4);
		int nMinId = rs.getInt(5);
		int nMaxId = rs.getInt(6);
		int nNextId = rs.getInt(7);

		int nAllocated = nMaxId - nMinId + 1;
		int nLeft = nMaxId - nNextId;
		int nLeftPct = (100*nLeft)/nAllocated;		
		int nUsedPct = 100 - nLeftPct;

		if (nextCustID != curCustID)
		{
			if (iCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
			
			++iCount;
			
			if (curCustID > -1)
			{
%>
	</tr>
<%
			}
%>
	<tr>
		<td class="listItem_Title<%= sClassAppend %>"><%=sCustName%></td>
<%
		}
		curCustID = nextCustID;
%>
		<td class="listItem_Data<%= sClassAppend %>">
			nLeft = <%=nLeft%> (<%=nLeftPct%>%)<BR>
			nAllocated = <%=nAllocated%><BR>
			<NOBR>
			<%=(nUsedPct >= 90)?
			("<a href=\"cust_unique_id_edit.jsp?cust_id="+curCustID+"&type_id="+nTypeID+"\"><FONT color=red>"+nUsedPct+"% used</FONT></a>"):
			((nUsedPct >= 75)?("<FONT color=blue>"+nUsedPct+"% used</FONT>"):
			(nUsedPct+"% used"))%>
			</NOBR>
		</td>
<%
	}
	rs.close();
%>
	<%=(curCustID > -1)?"</tr>":""%>
</table>
<%
}
catch(Exception ex)
{
	ex.printStackTrace(response.getWriter());
}
finally
{
	try{if(stmt!=null) stmt.close();}
	catch(Exception ex) {}
	if(conn!=null) cp.free(conn);
}
%>
</BODY>
</HTML>
