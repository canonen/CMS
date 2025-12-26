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
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


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
