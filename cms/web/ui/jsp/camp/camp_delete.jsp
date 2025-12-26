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
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>
<HTML>
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=95% class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Campaign</b></th>
	</tr>
	<tr>
		<td valign=top align=center width=100%>
			<table cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b><%= finalMsg %></b>
						<br><br>
						<p align="center">
							<a href="camp_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">
								Back to List
							</a>
						</p>
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