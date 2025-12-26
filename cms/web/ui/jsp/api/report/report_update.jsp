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
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
JsonObject jsonObject = new JsonObject();
JsonArray JsonArray	= new JsonArray(); 
String	sCampID	= request.getParameter("id");

try {
if ( (sCampID == null) || (sCampID.equals("")) ) throw new Exception ("Campaign ID required");

// === === ===

StringTokenizer st = new StringTokenizer(sCampID,",");

while (st.hasMoreTokens())
{

     jsonObject.put("camp_id", st.nextToken());
	 jsonObject.put("cust_id", cust.s_cust_id);
	 JsonArray.put(jsonObject);
	 jsonObject = new JsonObject();

}
StringTokenizer st2 = new StringTokenizer(sCampID,",");
while (st2.hasMoreTokens())
{
	String sSql =
		" EXEC usp_crpt_camp_report_update" +
		"  @camp_id = " + st2.nextToken() +
		", @cust_id = " + cust.s_cust_id +
		", @status_id = " + ReportStatus.QUEUED;

	BriteUpdate.executeUpdate(sSql);
}
 jsonObject.put("message", "The campaign report has been scheduled.");
 JsonArray.put(jsonObject);
 out.print(JsonArray.toString());
}
catch(Exception e) {
	throw e;
}

%>

