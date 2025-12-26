<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.wfl.WorkflowUtil,
			java.util.*,java.sql.*,java.net.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sSelectedCategoryId = request.getParameter("category_id");

String finalMsg = "The campaign was deleted.";

Campaign camp = null;
String sPendingEditsCampID = null;

ConnectionPool 	cp		= null;
Connection		conn 	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 
String          sql     = "";
try	{
   	cp = ConnectionPool.getInstance();
   	conn = cp.getConnection("camp_pers.jsp");
   	stmt = conn.createStatement();
	String campID = request.getParameter("camp_id");
	if (campID != null) {
	   boolean hasWsCamp = false;
	   if (ui.getFeatureAccess(Feature.WS_CAMPAIGN)) {
		   sql = "SELECT ws_camp_id from cxcs_ws_campaign WHERE cust_id = " + cust.s_cust_id + " AND camp_id = " + campID;
		   rs = stmt.executeQuery(sql);
		   if (rs.next()) {
	   		  hasWsCamp = true;
			  finalMsg = "Cannot delete, there is an active ws campaign (ws camp id = " + rs.getString(1) + ") associated with this campaign.";
		   }
   		   rs.close();
   	   }
	   if (!hasWsCamp) {
          camp = new Campaign(campID); 
		  //Make sure this customer owns this campaign
          if (camp.s_cust_id.equalsIgnoreCase(cust.s_cust_id)) {
               //Set campaign to Delete 
               camp.s_status_id = String.valueOf(CampaignStatus.DELETED);
               camp.save();

               // for 'extra' campaign record if campaign is in Pending Edits status
               String sOriginCampID = camp.s_camp_id;
               if (camp.s_origin_camp_id != null)
                    sOriginCampID = camp.s_origin_camp_id;
               sPendingEditsCampID = WorkflowUtil.getPendingEditsCampId(camp.s_cust_id, sOriginCampID, camp.s_sample_id);
               if (sPendingEditsCampID != null) {
                    camp.s_camp_id = sPendingEditsCampID;
                    camp.retrieve();
                    camp.s_status_id = String.valueOf(CampaignStatus.DELETED);
                    camp.save();
               }
          }
   	   }
	}
	JsonObject jsonObject = new JsonObject();
	jsonObject.put("message", finalMsg);
	out.print(jsonObject.toString());
}
catch(Exception ex) {
	throw ex;
}
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>
