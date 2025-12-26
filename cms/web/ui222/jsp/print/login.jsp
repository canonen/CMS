<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.net.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

	boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);
	boolean isPrintDemo = ui.getFeatureAccess(Feature.PRINT_DEMO);
	
	if (isPrintDemo)
	{
		response.sendRedirect("doc_step_1.jsp");
	}
	else
	{
		//LOG IN LOGIC TO CTI
		String sContID = request.getParameter("cont_id");
		String sAction = request.getParameter("action");
		Content cont = new Content(sContID);
		String sDocID = cont.s_cti_doc_id;
		
		String sPartnerID = Registry.getKey("brite_cti_partner_id");
		String sGroupID = cust.s_cti_group_id;
//		String sGroupID = "FE4E4B87-6FCB-4A2D-BA3D-488AED9BD6A8";
//System.out.println(sDocID);
//System.out.println(sAction);
//System.out.println(sPartnerID);
//System.out.println(sGroupID);

		Vector services = Services.getByCust(ServiceType.CXCS_CONT_LOGIN, cust.s_cust_id);		
		Service service = (Service) services.get(0);

		URL url = service.getURL();
		
		if ( (sDocID == null) || (sAction == null) || (sPartnerID == null) || (sGroupID == null) )
		{
			throw new Exception("Insufficient data for print login");
		}

//String sUrl = url.toString();
//sUrl += "?PartnerID="+sPartnerID;
//sUrl += "&Page="+sAction;
//sUrl += "&BM="+"GroupID="+sGroupID+",DocumentID="+sDocID;
//System.out.println(sUrl);
//
//response.sendRedirect(sUrl);
%>
<html>
<head>
<title>Print Login Page</title>
</head>
<body onLoad="FT.submit()">
<FORM method="GET" action="<%=url.toString()%>" name="FT">
<input type="hidden" name="PartnerID" value="<%=sPartnerID%>">
<input type="hidden" name="Page" value="<%=sAction%>">
<input type="hidden" name="BM" value="GroupID=<%=sGroupID%>,DocumentID=<%=sDocID%>">
</form>
</body>
</html>
<%
	}

%>