<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			java.text.*,org.apache.log4j.*"
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
if(!can.bRead || !can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
boolean canStep2 = ui.getFeatureAccess(Feature.CAMP_STEP_2);
boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);
%>
<%
String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

// === === ===

String sCampId = request.getParameter("camp_id");
if(sCampId == null) 
		throw new Exception("Campaign id = " + sCampId + "does not exist");
		
Campaign camp = new Campaign();
camp.s_camp_id = sCampId;
if(camp.retrieve() < 1)
	throw new Exception("Campaign id = " + sCampId + "does not exist");
if(!cust.s_cust_id.equals(camp.s_cust_id))
	throw new Exception("Campaign id = " + sCampId + "does not belong to customer id = " + cust.s_cust_id);
	
camp.s_camp_id = camp.s_origin_camp_id;
if(camp.retrieve() < 1)
	throw new Exception("Campaign id = " + sCampId + "does not exist");
if(!cust.s_cust_id.equals(camp.s_cust_id))
	throw new Exception("Campaign id = " + sCampId + "does not belong to customer id = " + cust.s_cust_id);

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

// === === ===

ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	String sSql = null;
%>

<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<TITLE>Campaign Edit With Samples</TITLE>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript" src="../../js/tab_script.js" type="text/javascript"></script>
</HEAD>

<BODY>
<FORM METHOD="POST" NAME="FT" ACTION="camp_change_save.jsp" TARGET="_self">
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="subactionbutton" href="javascript:history.go(-1);"><< Return to Campaign Edit</a>
		</td>
	</tr>
</table>
<br>

	<INPUT TYPE="hidden" NAME="camp_id" value="<%=HtmlUtil.escape(sCampId)%>">
<% if(sSelectedCategoryId!=null) { %>
	<INPUT TYPE="hidden" NAME="category_id" value="<%=sSelectedCategoryId%>">
<% } %>

	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Change Your Campaign</td>
		</tr>
	</table>
	<br>
	
<%@ include file="camp_change/step_2.jsp"%>

	<br><br>
	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Re-Launch Campaign</td>
		</tr>
	</table>
	<br>
	
<%@ include file="camp_change/step_4.jsp"%>

</FORM>
<br><br>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<%@ include file="camp_change/js_camp_init.jsp"%>
<%@ include file="camp_change/js_camp_change.jsp"%>
<%@ include file="camp_change/js_date.jsp"%>
<%@ include file="camp_change/js_popup.jsp"%>
<%@ include file="camp_change/js_other.jsp"%>
</SCRIPT>

</BODY>
</HTML>
<%	
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn); 
}
%>

<%@ include file="camp_change/functions.jsp"%>
<%@ include file="camp_change/calendar.jsp"%>