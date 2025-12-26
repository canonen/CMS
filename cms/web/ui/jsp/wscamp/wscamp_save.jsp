<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.adm.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,java.net.*,java.io.*, java.text.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
if (logger == null) {
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if (!can.bWrite) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sWsCampId = BriteRequest.getParameter(request, "ws_camp_id");
String sWsSealId = BriteRequest.getParameter(request, "ws_seal_id");
String sWsFileName = BriteRequest.getParameter(request, "ws_file_name");
String sWsUnsubFileName = BriteRequest.getParameter(request, "ws_unsub_file_name");

ConnectionPool	cp   = null;
Connection		conn = null;
Statement		stmt = null;
ResultSet       rs   = null;
String          sql  = null;
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
	
	// error checking: ws camp id already used by other customer
	String otherCusts = "";
	sql =
		"SELECT cust_id" +
		"  FROM cxcs_ws_campaign" +
		" WHERE ws_camp_id = " + sWsCampId +
		"   AND cust_id <> " + cust.s_cust_id;
	rs = stmt.executeQuery(sql);
	while (rs.next()) {
		otherCusts += " " + rs.getInt(1);
	}
	rs.close();	
	if (otherCusts != null && otherCusts.length() > 0) {
		throw new Exception ("ERROR: This WS Camp ID is already used by cust id(s): " + otherCusts);  
	}
	
	// error checking: ws camp id already used within this customer
	int nWsCamp = 0;
	sql =
		"SELECT COUNT(cust_id)" +
		"  FROM cxcs_ws_campaign" +
		" WHERE status_id > 1" +
		"   AND ws_camp_id = " + sWsCampId +
		"   AND cust_id = " + cust.s_cust_id;
	rs = stmt.executeQuery(sql);
	if (rs.next()) {
		nWsCamp = rs.getInt(1);
	}
	rs.close();	
	if (nWsCamp > 0) {
		throw new Exception ("ERROR: This WS Camp ID is not in draft mode, can't save");  
	}
	
	// save content
	logger.info("saving content");
	Content cont = saveWsCont(cust, user, request);

	// set content to ready
	logger.info("setting content to ready");
	if (cont != null) {
		cont.s_status_id = "20"; 
		cont.save();
	}

	// make sure customer has 'auto_link_scan_templates' feature 
	CustFeature cs = new CustFeature();
	if (cs.exists(cust.s_cust_id, Feature.AUTO_LINK_SCAN_TEMPLATES)) {
		ContLinkScan cls = new ContLinkScan(cust.s_cust_id, cont.s_cont_id, null, true, true, true);
		boolean rc = cls.scanAndSave();
	}
	else {
		logger.info("auto link scan templates is disabled for customer " + cust.s_cust_id);
	}

	// create from address id if needed
	String sFromAddress = BriteRequest.getParameter(request, "from_address");
	String sFromAddressId = BriteRequest.getParameter(request, "from_address_id");
	FromAddress fa = new FromAddress();
	if ( sFromAddressId == null || sFromAddressId.equals("")) {
		String sFromPrefix = sFromAddress.substring(0, sFromAddress.indexOf('@'));
		String sFromDomain = sFromAddress.substring(1 + sFromAddress.indexOf('@'));
		// use vanity domain for inb if available
		sql =
			"SELECT top 1 vd.domain" +
			"  FROM cadm_vanity_domain vd, cadm_mod_inst mi" +
			" WHERE vd.cust_id="+cust.s_cust_id +
			"   AND vd.mod_inst_id = mi.mod_inst_id" +
			"   AND mi.mod_id = " + Module.AINB;
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			sFromDomain = rs.getString(1);
		}
		rs.close();	
		fa.s_cust_id = cust.s_cust_id;
		fa.s_prefix = sFromPrefix;
		fa.s_domain = sFromDomain;
		fa.saveWithSync();
		// for some mysterious reason, we may or may not get a valid FromAddress object
		sql =
			"SELECT fa.from_address_id" +
			"  FROM ccps_from_address fa" +
			" WHERE fa.cust_id="+cust.s_cust_id +
			"   AND lower(fa.domain) = lower('" + sFromDomain + "')" +
			"   AND lower(fa.prefix) = lower('" + sFromPrefix + "')";
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			sFromAddressId = rs.getString(1);
		}
		rs.close();
		if (sFromAddressId != null && sFromAddress.length() > 0) {
			fa = new FromAddress(sFromAddressId);
		}
		System.out.println("new from_address_id = " + fa.s_from_address_id);
	}

	// save campaign
	logger.info("saving content");
	Campaign camp = saveWsCamp(cust, user, cont, fa, request);

	if (camp != null) {
		String sLaunchDate = BriteRequest.getParameter(request, "launch_date");
		if (sLaunchDate == null || sLaunchDate.length() == 0) {
			java.util.Date now = new java.util.Date();
			SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd_HHmm");
			camp.s_camp_name = "ws_camp_" + sWsCampId + "_" + formatter.format(now);
		}
		else {
			java.util.Date launchDate = new java.util.Date(sLaunchDate);
			SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
			camp.s_camp_name = "ws_camp_" + sWsCampId + "_" + formatter.format(launchDate);
		}
		camp.save();
	}

	logger.info("change cont name");
	// change cont name
	if (cont != null) {
		cont.s_cont_name = "ws_cont_" + camp.s_camp_id; 
		cont.save();
	}

	sql = "DELETE FROM cxcs_ws_campaign WHERE cust_id = " + cust.s_cust_id + " AND ws_camp_id = " + sWsCampId;
	logger.info("sql=" + sql);
	BriteUpdate.executeUpdate(sql);

	sql = "INSERT INTO cxcs_ws_campaign (cust_id, ws_camp_id, ws_seal_id, camp_id, list_file_name, clickseal_file_name, create_date, modify_date, status_id)" +
    	  " VALUES ( " + cust.s_cust_id + "," +  sWsCampId + ",'" + sWsSealId + "'," + camp.s_camp_id + ",'" + sWsFileName + "','" + sWsUnsubFileName + "', getDate(), getDate(), 1)"; 
	logger.info("sql=" + sql);
	BriteUpdate.executeUpdate(sql);

%>
<HTML>
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>

<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>WS Campaign:</b> Saved</td>
	</tr>
</table>
<br>

<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="650">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p>The WS campaign was saved.</p>
						<p align="center">
							<%
							String sHref = "wscamp_list.jsp?type_id=2";
							%>
							<a href="<%=sHref%>">Back to List</a>
						</p>
						<p align="center">
							<a href="wscamp_edit.jsp?ws_camp_id=<%=sWsCampId%>">Back to Edit</a>
						</p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>
<%
}
catch(Exception ex) { 
	ErrLog.put(this,ex, "Problem with wscamp_save.jsp",out,1);
}
finally {
	if ( stmt != null ) stmt.close();
	if ( conn  != null ) cp.free(conn); 
}
%>
<%!

private static Content saveWsCont(Customer cust, User user, HttpServletRequest request) throws Exception
{
	Content cont = new Content();
	cont.s_cont_id = null;	
	cont.s_status_id = "10"; 
	cont.s_cust_id = cust.s_cust_id;
	cont.s_cont_name = "ws_cont_9999999"; 
	cont.s_charset_id = "1";
	cont.s_type_id = "20";

	ContBody cb = new ContBody();

	cb.s_cont_id = cont.s_cont_id;
	String sTmp = request.getParameter("text_body");
	cb.s_text_part = ((sTmp!=null) && (sTmp.trim().length()>0))?new String(sTmp.getBytes("ISO-8859-1"), "UTF-8"):null;
	sTmp = request.getParameter("html_body");
	cb.s_html_part = ((sTmp!=null) && (sTmp.trim().length()>0))?new String(sTmp.getBytes("ISO-8859-1"), "UTF-8"):null;
	cb.s_aol_part = cb.s_html_part;

	ContSendParam csp = new ContSendParam();
	csp.s_cont_id = cont.s_cont_id;
	csp.s_send_html_flag = (cb.s_html_part == null)?"0":"1";
	csp.s_send_text_flag = (cb.s_text_part == null)?"0":"1";
	csp.s_send_aol_flag = (cb.s_aol_part == null)?"0":"1";
    csp.s_unsub_msg_position= "1";
    
	ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
	cei.s_modifier_id = user.s_user_id; 
	cei.s_modify_date = null;  
	
	cont.m_ContSendParam = csp;
	cont.m_ContBody = cb;
	cont.m_ContEditInfo = cei;	
	cont.m_ContParts = new ContParts();
	cont.save();
	
	return cont;
}

// === === ===	
private static Campaign saveWsCamp(Customer cust, User user, Content cont, FromAddress fa, HttpServletRequest request) throws Exception
{
	String sCampId = BriteRequest.getParameter(request, "camp_id");
	
	Campaign camp = new Campaign();

	if (sCampId != null)
	{
		camp.s_camp_id = sCampId;
		if(camp.retrieve() < 1)
			throw new Exception("Campaign id = " + sCampId + "does not exist");
		if(!cust.s_cust_id.equals(camp.s_cust_id))
			throw new Exception("Campaign id = " + sCampId + "does not belong to customer id = " + cust.s_cust_id);
	}
	
	if(camp.s_cust_id == null) camp.s_cust_id = cust.s_cust_id;

	camp.s_filter_id  = BriteRequest.getParameter(request, "filter_id");
	camp.s_type_id = "2";
	camp.s_camp_name  = BriteRequest.getParameter(request, "camp_name");
	camp.s_cont_id  = cont.s_cont_id;
	camp.s_seed_list_id = BriteRequest.getParameter(request, "seed_list_id");

	if(camp.s_status_id == null) camp.s_status_id = String.valueOf(CampaignStatus.DRAFT);

	// CampSendParam object (table)

	CampSendParam csp = new CampSendParam(); // OR = new CampSendParam(camp._s_camp_id);

	csp.s_recip_qty_limit = BriteRequest.getParameter(request, "recip_qty_limit");
	csp.s_randomly = BriteRequest.getParameter(request, "randomly");
	csp.s_delay = BriteRequest.getParameter(request, "delay");
	csp.s_limit_per_hour = BriteRequest.getParameter(request, "limit_per_hour");
	csp.s_msg_per_recip_limit = BriteRequest.getParameter(request, "msg_per_recip_limit");
	csp.s_response_frwd_addr = BriteRequest.getParameter(request, "response_frwd_addr");
	csp.s_msg_per_email821_limit = BriteRequest.getParameter(request, "msg_per_email821_limit");
	csp.s_camp_frequency = BriteRequest.getParameter(request, "camp_frequency");
	csp.s_queue_date = BriteRequest.getParameter(request, "queue_date");
	csp.s_queue_daily_flag = BriteRequest.getParameter(request, "queue_daily_flag");
	csp.s_queue_daily_time = BriteRequest.getParameter(request, "queue_daily_time");
	csp.s_test_recip_qty_limit = BriteRequest.getParameter(request, "test_recip_qty_limit");
	csp.s_link_append_text = BriteRequest.getParameter(request, "link_append_text");

	if(csp.s_recip_qty_limit == null ) csp.s_recip_qty_limit = "0";
	csp.s_randomly  = ( csp.s_randomly == null ) ? "0" : "1";
	if(csp.s_delay == null ) csp.s_delay = "0";
	if(csp.s_limit_per_hour == null ) csp.s_limit_per_hour = "0";
	if(csp.s_msg_per_recip_limit != null ) csp.s_msg_per_recip_limit = "1";
	csp.s_msg_per_email821_limit = ( csp.s_msg_per_email821_limit == null )?"0":"1";
		
	Schedule sch = new Schedule();
	sch.s_start_date = BriteRequest.getParameter(request, "start_date");

	MsgHeader mh = new MsgHeader();
	mh.s_reply_to = BriteRequest.getParameter(request, "reply_to");
	mh.s_from_name = BriteRequest.getParameter(request, "from_name");
	if (fa != null && fa.s_from_address_id != null && fa.s_from_address_id.length() > 0) {
		mh.s_from_address_id = fa.s_from_address_id;		
	}
	else {
		String fai = BriteRequest.getParameter(request, "from_address_id");
		if (fai != null && fai.length() > 0) {
			mh.s_from_address_id = BriteRequest.getParameter(request, "from_address_id");	
		}
		else {
			mh.s_from_address = BriteRequest.getParameter(request, "from_address");
		} 
	}
	
	mh.s_subject_html = BriteRequest.getParameter(request, "subj_html");
	mh.s_subject_text = mh.s_subject_html;
	mh.s_subject_aol = mh.s_subject_html;

	CampList cl = new CampList();
	cl.s_test_list_id = BriteRequest.getParameter(request, "test_list_id");
	
	CampEditInfo cei = new CampEditInfo();
	cei.s_modifier_id = user.s_user_id; 

	// === FINALLY SAVE IT! === 

	camp.m_CampEditInfo = cei;
	camp.m_CampList = cl;
	camp.m_CampSendParam = csp;
	camp.m_MsgHeader = mh;
	camp.m_Schedule = sch;

	camp.save();

	return camp;
}

%>

