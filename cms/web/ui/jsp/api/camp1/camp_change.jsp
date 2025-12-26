<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			java.text.*,org.apache.log4j.*"
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

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
boolean canStep2 = ui.getFeatureAccess(Feature.CAMP_STEP_2);
boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

// === === ===

ConnectionPool	cp		= null;
Connection		conn	= null;
PreparedStatement ps	= null;
ResultSet		rs		= null;

String sSql = "SELECT c.camp_id"
	+ " FROM cque_campaign c"
	+ " WITH(NOLOCK)"
	+ " LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK) ON c.camp_id = s.camp_id INNER JOIN cque_camp_edit_info e WITH(NOLOCK)"
	+ " ON c.camp_id = e.camp_id INNER JOIN cque_camp_type t WITH(NOLOCK) ON c.type_id = t.type_id INNER JOIN cque_camp_status a WITH(NOLOCK) ON c.status_id = a.status_id"
	+ " WHERE cust_id = ? AND (c.type_id = ?) AND c.origin_camp_id = ?"
	+ " ORDER BY modify_date DESC";

int changeCampId = -1;
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	ps = conn.prepareStatement(sSql);
	
	ps.setString(1, String.valueOf(cust.s_cust_id));
	ps.setString(2, request.getParameter("type_id"));
	ps.setString(3, request.getParameter("origin_camp_id"));
	
	rs = ps.executeQuery();
	
	while (rs.next()) {
		changeCampId = rs.getInt(1);
	}
} catch(Exception ex) {
	// throw ex;
	out.println(ex.getLocalizedMessage());
}
  finally {
	if (ps != null) ps.close();
	if (conn != null) cp.free(conn); 
  }
String sCampId = String.valueOf(changeCampId);

if(sCampId == null) {
	// throw new Exception("Campaign ID is null.");
	out.println("Campaign ID is null.");
}
if(sCampId.equals("1")) {
	// throw new Exception("Campaign id is -1.");
	out.println("Campaign id is -1.");
}
		
		
Campaign camp = new Campaign();
camp.s_camp_id = sCampId;
if(camp.retrieve() < 1) {
	// throw new Exception("Campaign id = " + sCampId + "does not exist");
	out.println("Campaign id = " + sCampId + "does not exist");
}	
if(!cust.s_cust_id.equals(camp.s_cust_id)) {
	// throw new Exception("Campaign id = " + sCampId + "does not belong to customer id = " + cust.s_cust_id);
	out.println("Campaign id = " + sCampId + "does not belong to customer id = " + cust.s_cust_id);
}
camp.s_camp_id = camp.s_origin_camp_id;

if(camp.retrieve() < 1) {
	// throw new Exception("Campaign id = " + sCampId + "does not exist");
	out.println("Campaign id = " + sCampId + "does not exist");
}
	
if(!cust.s_cust_id.equals(camp.s_cust_id)) {
	// throw new Exception("Campaign id = " + sCampId + "does not belong to customer id = " + cust.s_cust_id);
	out.println("Campaign id = " + sCampId + "does not belong to customer id = " + cust.s_cust_id);
}

// === === ===

CampSendParam 	camp_send_param = new CampSendParam(camp.s_camp_id);
Schedule 	schedule = new Schedule(camp.s_camp_id);
MsgHeader 	msg_header = new MsgHeader(camp.s_camp_id);

// === SET DEFAULTS ===

if(camp.s_camp_name == null) camp.s_camp_name = "New campaign";
if(camp.s_status_id == null) camp.s_status_id = String.valueOf(CampaignStatus.DRAFT);

if(camp_send_param.s_recip_qty_limit == null)			camp_send_param.s_recip_qty_limit			= "0";
if(camp_send_param.s_randomly == null)					camp_send_param.s_randomly					= "0";
if(camp_send_param.s_delay == null)						camp_send_param.s_delay						= "0";
if(camp_send_param.s_limit_per_hour == null)			camp_send_param.s_limit_per_hour			= "0";
if(camp_send_param.s_msg_per_email821_limit == null)	camp_send_param.s_msg_per_email821_limit	= "0";
if(camp_send_param.s_msg_per_recip_limit != null )		camp_send_param.s_msg_per_recip_limit 		= "1";
if(camp_send_param.s_queue_daily_weekday_mask == null )	camp_send_param.s_queue_daily_weekday_mask	= "127";

// === SET MEDIA TYPE DEFAULTS ===

boolean isPrintCampaign = false;
if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2")) {
	isPrintCampaign = true;
}
JsonObject result = new JsonObject();

result.put("change_camp_id", changeCampId);

out.print(result);
// === === ===
%>

<%@ include file="camp_change/functions.jsp"%>
<%@ include file="camp_change/calendar.jsp"%>