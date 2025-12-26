<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.imc.*,
			java.util.*,java.util.Date,
			java.text.DateFormat,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection
Statement			stmt			= null;
ConnectionPool		cp		= null;
Connection			conn 	= null;

String sSql = null;
boolean bAutoCommit = true;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("cust_domains_save.jsp");
	bAutoCommit = conn.getAutoCommit();
	conn.setAutoCommit(false);
	stmt = conn.createStatement();

        int maxDomainsOnReport = 20;
	        if ((cust.s_max_domains_on_report != null) && (cust.s_max_domains_on_report.length() > 0)) {
	        	maxDomainsOnReport = Integer.parseInt(cust.s_max_domains_on_report); 
            }
        
	CustDomains domains = new CustDomains();
	domains.s_cust_id = cust.s_cust_id;

	for (int i=1; i <= maxDomainsOnReport; i++) {
		CustDomain cd = new CustDomain();
		cd.s_domain_id = String.valueOf(i);
		cd.s_cust_id = cust.s_cust_id;
		cd.s_domain = BriteRequest.getParameter(request, "domain"+i);
		
		if (cd.s_domain != null) domains.add(cd);
	}

logger.info(domains.toXml());

	String sRcpResponse = Service.communicate(ServiceType.RRPT_CUST_DOMAINS_SETUP, cust.s_cust_id, domains.toXml());

	//Just validate response
	XmlUtil.getRootElement(sRcpResponse);

	sSql = "DELETE crpt_cust_domain WHERE cust_id = "+cust.s_cust_id;
	stmt.executeUpdate(sSql);

	domains.save(conn);
	conn.commit();	
%>
<HTML>

<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Domains Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center"><b>The domains were saved.</b></p>
						<p align="center"><a href="cust_domains_edit.jsp">Back to Edit</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>
<%
}
catch(Exception ex)
{ 
	if (conn != null) conn.rollback();
	throw ex;
}
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception ex) { logger.error("Exception: ",ex); }
	if (conn != null)
	{
		try { conn.setAutoCommit(bAutoCommit); }
		catch(Exception ex) { logger.error("Exception: ",ex); }
		cp.free(conn);
	}
}
%>
