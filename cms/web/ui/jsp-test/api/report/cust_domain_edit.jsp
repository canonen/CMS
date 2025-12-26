<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.io.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

	JsonObject data = new JsonObject();
	JsonArray dataArray = new JsonArray();
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
        
        
        int maxDomainsOnReport = 20;
        if ((cust.s_max_domains_on_report != null) && (cust.s_max_domains_on_report.length() > 0)) {
        	maxDomainsOnReport = Integer.parseInt(cust.s_max_domains_on_report); 
            }
        
 	CustDomains domains = new CustDomains(cust.s_cust_id);
	
	if (domains.size() == 0) domains = new CustDomains("0");
	int i = 0;
	String sClassAppend = "";
	for (Enumeration e = domains.elements(); e.hasMoreElements() ;) {
		CustDomain cd = (CustDomain)e.nextElement();
		i++;

		if (i % 2 == 0)
		{
			sClassAppend = "_other";
		}
		else
		{
			sClassAppend = "";
		}
		data = new JsonObject();
		data.put("s_domain",cd.s_domain);
		dataArray.put(data);

	

	}
	out.println(dataArray.toString());

%>
