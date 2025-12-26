<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.jtk.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,java.net.*,
			java.io.*,java.text.DateFormat,
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
// The campaign ID 30338262 for the customer with ID 420 can be used for testing purposes.
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
%>

<%
String sCampId = BriteRequest.getParameter(request, "camp_id");

// === === ===

Campaign camp = new Campaign();
camp.s_camp_id = sCampId;

if(camp.retrieve() < 1)
	throw new Exception("Campaign id = " + sCampId + " does not exist");
if(!cust.s_cust_id.equals(camp.s_cust_id))
	throw new Exception("Campaign id = " + sCampId + " does not belong to customer id = " + cust.s_cust_id);

// === === ===

Campaign origin_camp = new Campaign();
origin_camp.s_camp_id = camp.s_origin_camp_id;

if(origin_camp.retrieve() < 1)
	throw new Exception("Origin Campaign id = " + origin_camp.s_camp_id + " does not exist");
if(!cust.s_cust_id.equals(origin_camp.s_cust_id))
	throw new Exception("Origin Campaign id = " + origin_camp.s_camp_id + " does not belong to customer id = " + cust.s_cust_id);

// === === ===

// Campaign object (table)

String sContId = BriteRequest.getParameter(request, "cont_id");

// CampSendParam object (table)

String sLimitPerHour = BriteRequest.getParameter(request, "limit_per_hour");
String sResponseFrwdAddr = BriteRequest.getParameter(request, "response_frwd_addr");

if(sLimitPerHour == null ) sLimitPerHour = "0";

CampSendParam ocsp = new CampSendParam(origin_camp.s_camp_id);
CampSendParam csp = new CampSendParam(camp.s_camp_id);

boolean bLimitPerHourChanged = !sLimitPerHour.equals(csp.s_limit_per_hour);
boolean bResponseFrwdAddrChanged = !sResponseFrwdAddr.equals(csp.s_response_frwd_addr);

ocsp.s_limit_per_hour = sLimitPerHour;
csp.s_limit_per_hour = sLimitPerHour;

ocsp.s_response_frwd_addr = sResponseFrwdAddr;
csp.s_response_frwd_addr = sResponseFrwdAddr;

// === === ===
	
// Schedule object (table)

String sStartDate = BriteRequest.getParameter(request, "start_date");
String sEndDate = BriteRequest.getParameter(request, "end_date");

Schedule osch = new Schedule(origin_camp.s_camp_id);
Schedule sch = new Schedule(camp.s_camp_id);

osch.s_start_date = sStartDate;
sch.s_start_date = sStartDate;

osch.s_end_date = sEndDate;
sch.s_end_date = sEndDate;

// === MsgHeader object (table) ===

String sFromName = BriteRequest.getParameter(request, "from_name");
String sFromAddress = BriteRequest.getParameter(request, "from_address");
String sFromAddressId = BriteRequest.getParameter(request, "from_address_id");
String sReplyTo = BriteRequest.getParameter(request, "reply_to");
String sSubject = BriteRequest.getParameter(request, "subj_html");

MsgHeader omh = new MsgHeader(origin_camp.s_camp_id);

omh.s_from_name = sFromName;
omh.s_from_address = sFromAddress;
omh.s_from_address_id = sFromAddressId;
omh.s_reply_to = sReplyTo;

omh.s_subject_html = sSubject;
omh.s_subject_text = omh.s_subject_html;
omh.s_subject_aol = omh.s_subject_html;

MsgHeader mh = new MsgHeader(camp.s_camp_id);

mh.s_from_name = sFromName;
mh.s_from_address = sFromAddress;
mh.s_from_address_id = sFromAddressId;
mh.s_reply_to = sReplyTo;

mh.s_subject_html = sSubject;
mh.s_subject_text = mh.s_subject_html;
mh.s_subject_aol = mh.s_subject_html;

// CampEditInfo object (table)

CampEditInfo ocei = new CampEditInfo();
CampEditInfo cei = new CampEditInfo();

ocei.s_camp_id = origin_camp.s_camp_id;
cei.s_camp_id = camp.s_camp_id;

ocei.s_modifier_id = user.s_user_id;
cei.s_modifier_id = user.s_user_id;

int nNewLinkCount = 0;

// === FINALLY SAVE IT! === 

ConnectionPool cp = null;
Connection conn = null;
boolean bAutoCommit = true;
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	try
	{
		bAutoCommit = conn.getAutoCommit();
		conn.setAutoCommit(false);

		csp.save(conn);
		sch.save(conn);
		mh.save(conn);
		cei.save(conn);

		ocsp.save(conn);
		osch.save(conn);
		omh.save(conn);
		ocei.save(conn);

		String sSql =
			" UPDATE cque_schedule SET start_date=ISNULL(start_date, getdate())" +
			" WHERE camp_id = " + camp.s_camp_id;

		BriteUpdate.executeUpdate(sSql, conn);

		sSql =
			" UPDATE cque_campaign SET cont_id = " + sContId +
			" WHERE camp_id = " + origin_camp.s_camp_id;
		BriteUpdate.executeUpdate(sSql, conn);


		conn.commit();
	}
	catch(Exception ex)
	{
		if (conn != null) conn.rollback();
		throw ex;
	}
	finally { if (conn != null) conn.setAutoCommit(bAutoCommit); }
	
	// === === ===
	if (ContUtil.isContSimple(camp.s_cont_id))
	{
	Statement stmt = null;
	try
	{
		stmt = conn.createStatement();
		
		String sSql =
			"EXEC usp_cque_camp_cont_substitute " + camp.s_camp_id + "," + sContId;
			
		ResultSet rs = stmt.executeQuery(sSql);
		if(rs.next()) nNewLinkCount = rs.getInt(1);
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally { if (stmt != null) stmt.close(); }
}
}
finally { if (conn != null) cp.free(conn); }

// === rcp setup ===

if((nNewLinkCount > 0)||(bLimitPerHourChanged))
{
	if(nNewLinkCount > 0)
	{
		Links links = new Links();
		links.s_camp_id = camp.s_camp_id;
		if(links.retrieve() > 0)
		{
			Content cont = new Content();
			cont.m_Links = links;
			camp.m_Content = cont;
		}
	}
	
	if(bLimitPerHourChanged) camp.m_CampSendParam = csp;

	camp.s_status_id =
		"THIS_IS_MAGIC_STATUS_TO_RECOGNIZE_CAMP_UPDATE_ON_RCP_AND_PREVENT_IT_FROM_SAVING_AS_IT_IS";

	String sRcpSetupXml = camp.toXml();
	String sResponse = Service.communicate(ServiceType.RQUE_CAMPAIGN_SETUP, camp.s_cust_id, sRcpSetupXml);
	XmlUtil.getRootElement(sResponse);
}

// === === ===

// if camp.s_camp_id >= CampaignStatus.RECIPS_QUEUED,
// (in fact camp.s_camp_id >= CampaignStatus.READY_TO_SEND)
// then jtk, inb and mailer setup was done, so redo it
// otherwise campaign was not queued yet
// and setup will be done regular way by CampSetupTimer after campaign is queued

if((camp.s_camp_id != null) && (Integer.parseInt(camp.s_camp_id) >= CampaignStatus.RECIPS_QUEUED))
{
	// === jtk & inbound setup === 

	if(nNewLinkCount > 0) CampSetupUtil.doJtkSetup(camp.s_camp_id);
	if(bResponseFrwdAddrChanged) CampSetupUtil.doInbSetup(camp.s_camp_id);

	// === mailer setup === 

	String sXml = CampSetupUtil.buildCampXml4Mailer(sCampId);
	XmlUtil.getRootElement("<some_wrapping_tag>" + sXml + "</some_wrapping_tag>");

	CampXml camp_xml = new CampXml();
	camp_xml.s_camp_id = camp.s_camp_id;

	if((camp_xml.retrieve() > 0) && !sXml.equals(camp_xml.s_camp_xml))
	{
		CampXmlHist camp_xml_hist = new CampXmlHist();
		camp_xml_hist.s_camp_id = camp_xml.s_camp_id;
		camp_xml_hist.s_camp_xml = camp_xml.s_camp_xml;
		camp_xml_hist.save();

		camp_xml.s_camp_xml = sXml;
		camp_xml.save();
	}
}
String queryForResult = "SELECT *"
						+ " FROM cque_campaign AS cc"
						+ " WITH (NOLOCK)"
						+ " LEFT JOIN cque_schedule AS cs"
						+ " ON cc.camp_id = cs.camp_id"
						+ " WHERE cc.camp_id = " + camp.s_camp_id;

Statement stmt = null;
ResultSet rs = null;

try {
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
	
	rs = stmt.executeQuery(queryForResult);
	JsonArray resultArray = new JsonArray();
	JsonObject resultObject = new JsonObject();
	
	while (rs.next()) {
		resultObject.put("campId", rs.getInt("camp_id"));
		resultObject.put("typeId", rs.getInt("type_id"));
		resultObject.put("statusId", rs.getInt("status_id"));
		resultObject.put("campName", rs.getString("camp_name"));
		resultObject.put("contId", rs.getInt("cont_id"));
		resultObject.put("filterId", rs.getInt("filter_id"));
		resultObject.put("seedListId", rs.getInt("seed_list_id"));
		resultObject.put("originCampId", rs.getInt("origin_camp_id"));
		resultObject.put("approvalFlag", rs.getInt("approval_flag"));
		resultObject.put("sampleId", rs.getInt("sample_id"));
		resultObject.put("modeId", rs.getInt("mode_id"));
		resultObject.put("mediaTypeId", rs.getInt("media_type_id"));
		resultObject.put("pvIq", rs.getString("pv_iq"));
		resultObject.put("sampleFilterId", rs.getInt("sample_filter_id"));
		resultObject.put("samplePriority", rs.getInt("sample_priority"));
		resultObject.put("campCode", rs.getString("camp_code"));
		resultObject.put("programTypeId", rs.getInt("program_type_id"));
		resultObject.put("startDate", rs.getString("start_date"));
		resultObject.put("endDate", rs.getString("end_date"));
		resultObject.put("startDailyTime", rs.getString("start_daily_time"));
		resultObject.put("endDailyTime", rs.getString("end_daily_time"));
		resultObject.put("startDailyWeekdayMask", rs.getInt("start_daily_weekday_mask"));
		
		resultArray.put(resultObject);
		
		resultObject = new JsonObject();
	}
	out.println(resultArray);
} catch (Exception exception) {
	throw exception;
} finally {
	try {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	} catch (Exception finalException) {
		throw finalException;
	}
	
	
}
%>
