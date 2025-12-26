<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.io.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
JsonObject data= new JsonObject();
JsonArray array= new JsonArray();

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
String	sCampID	= request.getParameter("id");
if ( (sCampID == null) || (sCampID.equals("")) ) throw new Exception ("Campaign ID required");

// === === ===

StringTokenizer st = new StringTokenizer(sCampID,",");

StringWriter swXML = new StringWriter();
data.put("camp_reports",swXML);
while (st.hasMoreTokens())
{
	data.put("camp_report",swXML);
	data.put("camp_id",st.nextToken()+"camp_id");
	data.put("cust_id",cust.s_cust_id+"cust_id");
	data.put("camp_reports",swXML);
}
data.put("camp_reports",swXML);
array.put(data);

String sMsg =
	Service.communicate(ServiceType.RRPT_CAMPAIGN_REPORT_QUEUE, cust.s_cust_id, swXML.toString());

// === === ===

StringTokenizer st2 = new StringTokenizer(sCampID,",");
while (st2.hasMoreTokens())
{
	String sSql =
		" EXEC usp_crpt_camp_report_update" +
		"  @camp_id = " + st2.nextToken() +
		", @cust_id = " + cust.s_cust_id +
		", @status_id = " + ReportStatus.QUEUED;
		data.put("camp_id",sCampID);
		data.put("cust_id",cust.s_cust_id);
		data.put("status_id",cust.s_status_id);
	BriteUpdate.executeUpdate(sSql);
}
data.put("updated","The campaing succesfully updated.");
array.put(data);
out.print(array.toString());
%>
