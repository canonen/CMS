<%@ page
		language="java"
		import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.ctl.*,
                org.w3c.dom.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                java.io.*,
                java.text.DateFormat,
                org.apache.log4j.*"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.britemoon.cps.tgt.*" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
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

	JsonArray jsonArray = new JsonArray();
	JsonObject jsonObject = new JsonObject();

	String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
	String sExportName = BriteRequest.getParameter(request, "export_name");
	String sView = BriteRequest.getParameter(request, "view");
	String sDelimiter = BriteRequest.getParameter(request, "delimiter");
	sDelimiter = "";

	// === Save Main Campaign ===

	//"save";"clone";"clone2destination"; "send_test";"send_camp";
	String MODE = BriteRequest.getParameter(request, "mode");
	String sDynamicCampFlag = BriteRequest.getParameter(request, "filter_flag");

	boolean bDoClone = ("clone".equals(MODE) || "clone2destination".equals(MODE));

	Campaign camp = saveCamp(cust, user, request, bDoClone);

	System.out.println("CAMP_ID XXXXXXXXXXXXXXXXXX  :" +camp.s_camp_id);
	System.out.println("CAMP_TYPE_ID "+camp.s_type_id);
	System.out.println("CAMP_SAVE ICINDEYIMMMM");

	SeedList seed_list = new SeedList(camp.s_seed_list_id);
	camp.m_SeedList = seed_list;
	if ("clone2destination".equals(MODE)) {
		camp.s_cust_id = ui.getDestinationCustomer().s_cust_id;
		String sSql =
				" UPDATE cque_campaign" +
						" SET cust_id=" + camp.s_cust_id +
						" WHERE camp_id=" + camp.s_camp_id;
		BriteUpdate.executeUpdate(sSql);
	} else {
		CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.CAMPAIGN, camp.s_camp_id, request);
	}

	// === Save Sampleset ===

	boolean bHasSampleSet = false;

	if (!bDoClone) {
		CampSampleset camp_sampleset = new CampSampleset();
		camp_sampleset.s_camp_id = camp.s_camp_id;
		if (camp_sampleset.retrieve() > 0) {
			bHasSampleSet = true;
			saveCampSamples(camp_sampleset, request);
		}
	}

	// === === ===

	String actionText = null;
	if (MODE.equals("send_pv_receipt")) {
		// save test history
		CampPVHist pvhist = new CampPVHist();
		pvhist.s_cust_id = cust.s_cust_id;
		pvhist.s_pv_test_type_id = BriteRequest.getParameter(request, "pvhist_pv_test_type_id");
		pvhist.s_origin_camp_id = camp.s_camp_id;
		pvhist.s_pv_iq = BriteRequest.getParameter(request, "pvhist_pviq");
		pvhist.s_cont_id = BriteRequest.getParameter(request, "cont_id");
		pvhist.s_tester_id = user.s_user_id;
		pvhist.save();
		String sRedirectUrl = "camp_send.jsp?camp_id=" + camp.s_camp_id + "&mode=pv_receipt";
		response.sendRedirect(sRedirectUrl);
		return;
	} else if (MODE.equals("send_test")) {
		String sRedirectUrl =
				"camp_send.jsp?camp_id=" + camp.s_camp_id + "&mode=test";

		String sSampleId = BriteRequest.getParameter(request, "sample_id");
		if (sSampleId != null) sRedirectUrl += ("&sample_id=" + sSampleId);

		//response.sendRedirect(sRedirectUrl);
	} else if (MODE.equals("send_pv_test")) {
		String sRedirectUrl =
				"camp_send.jsp?camp_id=" + camp.s_camp_id + "&mode=pv_test";

		String sSampleId = BriteRequest.getParameter(request, "sample_id");
		if (sSampleId != null) sRedirectUrl += ("&sample_id=" + sSampleId);

		String sPvTestListIds = BriteRequest.getParameter(request, "pv_test_list_ids");
		if (sPvTestListIds != null) sRedirectUrl += ("&pv_test_list_ids=" + sPvTestListIds);

		String sContId = BriteRequest.getParameter(request, "cont_id");
		if (sContId != null) sRedirectUrl += ("&cont_id=" + sContId);

		response.sendRedirect(sRedirectUrl);
	} else if (MODE.equals("send_calc")) {
		String sRedirectUrl =
				"camp_send.jsp?camp_id=" + camp.s_camp_id + "&mode=calc_only";

		//	String sSampleId = BriteRequest.getParameter(request, "sample_id");
		//	if(sSampleId!=null) sRedirectUrl += ("&sample_id="+sSampleId);

		//response.sendRedirect(sRedirectUrl);
	} else if (MODE.equals("send_camp")) {
		String sRedirectUrl = null;
		if (camp.s_type_id.equals("5")) {  // non-email campaign
			sRedirectUrl = "camp_send.jsp?&approval_flag=1&camp_id=" + camp.s_camp_id + "&export_name=" + sExportName + "&view=" + sView + "&delimiter=" + sDelimiter;
		} else {  // any email campaign

			sRedirectUrl = "camp_send_confirm.jsp?camp_id=" + camp.s_camp_id;
			// JPM 03/03/04 added the following line to pass category info on to camp_send_confirm.
			if (sSelectedCategoryId != null)
				sRedirectUrl += "&category_id=" + sSelectedCategoryId;
			// handle print campaigns
			if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2"))
				sRedirectUrl += "&export_name=" + sExportName + "&view=" + sView + "&delimiter=" + sDelimiter;
			// add sample_id to the redirect URL if it exists
			String sSampleId = BriteRequest.getParameter(request, "sample_id");

			String sPvTestListIds = BriteRequest.getParameter(request, "pv_test_list_ids");
			if (sPvTestListIds != null) sRedirectUrl += ("&pv_test_list_ids=" + sPvTestListIds);

			if (sSampleId != null)
				sRedirectUrl += ("&sample_id=" + sSampleId);
		}
		//response.sendRedirect(sRedirectUrl);
	} else if (MODE.equals("create_sampleset")) {
		String sRedirectUrl =
				"camp_sampleset_edit.jsp" +
						"?camp_id=" + camp.s_camp_id;

		if (sDynamicCampFlag != null && sDynamicCampFlag.equals("1")) {
			sRedirectUrl += "&filter_flag=1";
		}
		if (sSelectedCategoryId != null) sRedirectUrl += "&category_id=" + sSelectedCategoryId;
		response.sendRedirect(sRedirectUrl);
	} else if (MODE.equals("save")) actionText = "saved";
	else if (MODE.equals("clone")) actionText = "cloned";

	// === 	Save export params for non-email campaign export ===

	if (camp.s_type_id.equals("5") || (camp.s_media_type_id != null && camp.s_media_type_id.equals("2"))) {
		/* delete cque_camp_export_attr and cque_camp_export */
		String sSql = "DELETE FROM cque_camp_export_attr WHERE camp_id = " + camp.s_camp_id;
		BriteUpdate.executeUpdate(sSql);

		sSql = "DELETE FROM cque_camp_export WHERE camp_id = " + camp.s_camp_id;
		BriteUpdate.executeUpdate(sSql);

		/* insert into cque_camp_export */
		sSql = "INSERT cque_camp_export (camp_id, export_name, delimiter) VALUES (" + camp.s_camp_id + ",'" + sExportName + "','" + sDelimiter + "')";
		BriteUpdate.executeUpdate(sSql);

		/* insert into cque_camp_export_attr */
		if (sView != null) {
			StringTokenizer st = new StringTokenizer(sView, ",");
			int n = 0;
			while (st.hasMoreTokens()) {
				n++;
				sSql = " INSERT cque_camp_export_attr (camp_id, seq, attr_id) VALUES (" + camp.s_camp_id + "," + n + "," + st.nextToken() + ")";
				BriteUpdate.executeUpdate(sSql);
			}
		}
	}
	System.out.println(camp.s_camp_id+"  ---------------------------new camp --------------------------");
	System.out.println("s_camp_id "+ camp.s_camp_id);
	System.out.println("MODE "+MODE);
	System.out.println("SeedList "+camp.m_SeedList.s_filter_name);
	System.out.println("actionText "+actionText);
	System.out.println("sSelectedCategoryId "+sSelectedCategoryId);
	System.out.println("bHasSampleSet "+bHasSampleSet);
	System.out.println("sExportName "+sExportName);
	System.out.println("sDelimiter "+sDelimiter);
	System.out.println("sView "+sView);

	jsonObject.put("s_camp_id", camp.s_camp_id);
	jsonObject.put("MODE", MODE);
	jsonObject.put("SeedList", camp.m_SeedList.s_filter_name);
	jsonObject.put("actionText", actionText);
	jsonObject.put("sSelectedCategoryId", sSelectedCategoryId);
	jsonObject.put("bHasSampleSet", bHasSampleSet);
	jsonObject.put("sExportName", sExportName);
	jsonObject.put("sDelimiter", sDelimiter);
	jsonObject.put("sView", sView);

	String sHref = "camp_list.jsp?type_id=" + camp.s_type_id;
	if (sSelectedCategoryId != null) sHref += "&category_id=" + sSelectedCategoryId;
	if (camp.m_CampSendParam.s_queue_daily_flag != null) sHref += "&auto_queue_daily_flag=1";
	jsonObject.put("sHref", sHref);

	jsonArray.put(jsonObject);
	out.println(jsonArray);
	//out.println("CAMP_ID  :" +camp.s_camp_id);
	//System.out.println("jsonArray  ****************** :" +jsonArray);
	//System.out.println("CAMP_ID  :" +camp.s_camp_id);


%>
<%!
	private static Campaign saveCamp(Customer cust, User user, HttpServletRequest request, boolean bDoClone) throws Exception
	{
		String sCampId = BriteRequest.getParameter(request, "camp_id");

		// === === ===

		String mode = BriteRequest.getParameter(request, "mode");
		boolean bDoPvTest = mode != null && mode.equals("send_pv_test");

		// === === ===
		Campaign camp = new Campaign();

		if(sCampId != null)
		{
			camp.s_camp_id = sCampId;
			if(camp.retrieve() < 1)
				throw new Exception("Campaign id = " + sCampId + "does not exist");
			if(!cust.s_cust_id.equals(camp.s_cust_id))
				throw new Exception("Campaign id = " + sCampId + "does not belong to customer id = " + cust.s_cust_id);

			// we shouldn't save camp for pv test
			if (bDoPvTest)
			{
				System.out.println("skip saving camp for send_pv_test");
				return camp;
			}
		}

		// === === ===

		if(bDoClone)
		{
			camp.s_camp_id = null;
			camp.s_status_id = String.valueOf(CampaignStatus.DRAFT);
		}

		if(camp.s_cust_id == null) camp.s_cust_id = cust.s_cust_id;

		// === === ===

		// Campaign object (table)

		camp.s_filter_id  = BriteRequest.getParameter(request, "filter_id");

		camp.s_type_id = BriteRequest.getParameter(request, "type_id");
		camp.s_media_type_id = BriteRequest.getParameter(request, "media_type_id");
		camp.s_camp_name  = BriteRequest.getParameter(request, "camp_name");
		camp.s_cont_id  = BriteRequest.getParameter(request, "cont_id");
		camp.s_seed_list_id = BriteRequest.getParameter(request, "seed_list_id");
		camp.s_camp_code = BriteRequest.getParameter(request, "camp_code");

		// camp.s_status_id = BriteRequest.getParameter(request, "status_id");
		// camp.s_origin_camp_id = BriteRequest.getParameter(request, "origin_camp_id");
		// camp.s_approval_flag = BriteRequest.getParameter(request, "approval_flag");

		if(camp.s_status_id == null) camp.s_status_id = String.valueOf(CampaignStatus.DRAFT);

		// CampSendParam object (table)

		CampSendParam csp = new CampSendParam(); // OR = new CampSendParam(camp._s_camp_id);

		csp.s_recip_qty_limit = BriteRequest.getParameter(request, "recip_qty_limit");
		csp.s_randomly = BriteRequest.getParameter(request, "randomly");
		csp.s_delay = BriteRequest.getParameter(request, "delay");
		String limitPerHour = BriteRequest.getParameter(request, "limit_per_hour");
		csp.s_limit_per_hour = limitPerHour.equals("NaN") ? null: limitPerHour;
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

		// === === ===

		String[] sQWeekdayMask = BriteRequest.getParameterValues(request, "queue_daily_weekday_mask");

		if((csp.s_queue_daily_flag!=null)&&(!"0".equals(csp.s_queue_daily_flag)))
		{
			if(sQWeekdayMask == null) csp.s_queue_daily_weekday_mask = "0";
			else
			{
				int nQWeekdayMask = 0;
				for(int i = 0; i < sQWeekdayMask.length; i++) nQWeekdayMask += Integer.parseInt(sQWeekdayMask[i]);
				csp.s_queue_daily_weekday_mask = String.valueOf(nQWeekdayMask);
			}
		}

		// === === ===

		// Schedule object (table)

		Schedule sch = new Schedule();

		sch.s_start_date = BriteRequest.getParameter(request, "start_date");
		sch.s_end_date = BriteRequest.getParameter(request, "end_date");
		sch.s_start_daily_time = BriteRequest.getParameter(request, "start_daily_time");
		sch.s_end_daily_time = BriteRequest.getParameter(request, "end_daily_time");

		String[] sSWeekdayMask = BriteRequest.getParameterValues(request, "start_daily_weekday_mask");

		if(sSWeekdayMask != null)
		{
			int nSWeekdayMask = 0;
			for(int i = 0; i < sSWeekdayMask.length; i++) nSWeekdayMask += Integer.parseInt(sSWeekdayMask[i]);
			sch.s_start_daily_weekday_mask = String.valueOf(nSWeekdayMask);
		}

		// === MsgHeader object (table) ===

		MsgHeader mh = new MsgHeader();

		mh.s_from_name = BriteRequest.getParameter(request, "from_name");
		mh.s_from_address = BriteRequest.getParameter(request, "from_address");
		String fromAddressId = BriteRequest.getParameter(request, "from_address_id");
		mh.s_from_address_id = fromAddressId == null  || fromAddressId.equals("undefined")  ? null : fromAddressId;
		mh.s_reply_to = BriteRequest.getParameter(request, "reply_to");

		mh.s_subject_html = BriteRequest.getParameter(request, "subj_html");
		mh.s_subject_text = mh.s_subject_html;
		mh.s_subject_aol = mh.s_subject_html;

		// === CampList object (table) ===

		CampList cl = new CampList();

		cl.s_exclusion_list_id = BriteRequest.getParameter(request, "exclusion_list_id");
		cl.s_test_list_id = BriteRequest.getParameter(request, "test_list_id");
		cl.s_auto_respond_list_id = BriteRequest.getParameter(request, "auto_respond_list_id");
		cl.s_auto_respond_attr_id = BriteRequest.getParameter(request, "auto_respond_attr_id");

		// CampEditInfo object (table)

		CampEditInfo cei = new CampEditInfo();
		cei.s_modifier_id = user.s_user_id; // should work with modifier only

		// LinkedCamp object (table)

		LinkedCamp lc = new LinkedCamp();
		lc.s_linked_camp_id = BriteRequest.getParameter(request, "linked_camp_id");
		lc.s_form_id = BriteRequest.getParameter(request, "form_id");

		// === Some magic from v4 === === === === === === === === ===

		String FORM_FLAG = request.getParameter("form_flag");
		if ((Integer.parseInt(camp.s_type_id) == CampaignType.SEND_TO_FRIEND) && (FORM_FLAG.trim().equals("1")))
			camp.s_filter_id = null;
		else
			lc.s_form_id = null;

		// === magic continues ===

		if ("4".equals(camp.s_type_id))
		{
			String AR_SEND_TYPE = request.getParameter("ar_send_type");
			//	0 = The Subscriber (Confirmation Email)
			//	1 = Emails On This List: (One email per subscriber or email everyone on the list)
			//	2 = One Email:   HTML Text Multipart AOL
			//	3 = Email from an attribute:

			cl.s_auto_respond_list_id = null;
			cl.s_auto_respond_attr_id = null;

			if (AR_SEND_TYPE.equals("1"))
			{
				cl.s_auto_respond_list_id = BriteRequest.getParameter(request,"auto_respond_list_id");
			}
			else if (AR_SEND_TYPE.equals("2"))
			{
				String email = BriteRequest.getParameter(request,"ar_send_list_one_email");
				String emailTypeID = BriteRequest.getParameter(request,"ar_send_list_one_type");
				cl.s_auto_respond_list_id = saveAutoNotificationList(email, emailTypeID, cust.s_cust_id);
			}
			else if (AR_SEND_TYPE.equals("3"))
			{
				cl.s_auto_respond_attr_id = BriteRequest.getParameter(request,"auto_respond_attr_id");
			}
		}

		// === FINALLY SAVE IT! ===

		camp.m_CampEditInfo = cei;
		camp.m_CampList = cl;
		camp.m_CampSendParam = csp;
		camp.m_MsgHeader = mh;
		camp.m_Schedule = sch;
		camp.m_LinkedCamp = lc;

		// === === ===

		//for debug
		//System.out.println("=== BEFORE SAVE() ===");
		//System.out.println(camp.toXmlNice());
		//System.out.flush();


		try {
			camp.save();
		} catch (Exception e) {
			if (e instanceof java.sql.SQLException) {
				java.sql.SQLException sqlException = (java.sql.SQLException) e;
				System.err.println("SQL Error: " + sqlException.getMessage());
				System.err.println("SQL State: " + sqlException.getSQLState());
				System.err.println("Error Code: " + sqlException.getErrorCode());
				sqlException.printStackTrace();
			}
			throw new RuntimeException(e);
		}


		// === Some magic from v4 ===

		if	(
				(lc.s_linked_camp_id == null)
						&&
						(
								(lc.s_form_id != null) || "3".equals(camp.s_type_id) || "4".equals(camp.s_type_id)
						)
		)
		{
			lc.s_linked_camp_id = camp.s_camp_id;
			lc.save();
		}

		// === === ===

		//for debug
		//System.out.println("=== AFTER SAVE() ===");
		//System.out.println(camp.toXmlNice());
		//System.out.flush();

		// === === ===

		return camp;
	}

	private static void saveCampSamples(CampSampleset camp_sampleset, HttpServletRequest request) throws Exception
	{
		int nCampQty = Integer.parseInt(camp_sampleset.s_camp_qty);

		CampSample cs = new CampSample();
		String sSampleId = null;

		for(int i=1; i <= nCampQty; i++)
		{
			sSampleId = String.valueOf(i);

			cs.s_camp_id = camp_sampleset.s_camp_id;
			cs.s_sample_id = sSampleId;
			cs.s_from_name = BriteRequest.getParameter(request, "from_name" + sSampleId);
			cs.s_from_address = BriteRequest.getParameter(request, "from_address" + sSampleId);
			cs.s_from_address_id = BriteRequest.getParameter(request, "from_address_id" + sSampleId);
			cs.s_subject_html = BriteRequest.getParameter(request, "subj_html" + sSampleId);
			cs.s_subject_text = cs.s_subject_html;
			cs.s_subject_aol = cs.s_subject_html;
			cs.s_cont_id = BriteRequest.getParameter(request, "cont_id" + sSampleId);
			cs.s_send_date = BriteRequest.getParameter(request, "start_date" + sSampleId);
			cs.s_test_list_id = BriteRequest.getParameter(request, "test_list_id" + sSampleId);
			cs.s_filter_id = BriteRequest.getParameter(request, "filter_id" + sSampleId);
			cs.s_reply_to = BriteRequest.getParameter(request, "reply_to" + sSampleId);
			cs.s_priority = BriteRequest.getParameter(request, "priority" + sSampleId);
			cs.save();
		}
	}

	private static String saveAutoNotificationList(String email, String emailTypeID, String custID) throws Exception
	{

		EmailListItems elis = new EmailListItems();
		String sEmail = null;

		EmailListItem eli = new EmailListItem();
		eli.s_email = email;
		eli.s_email_type_id = emailTypeID;
		elis.add(eli);

		// === === ===

		EmailList el = new EmailList();


		el.s_cust_id = custID;
		el.s_list_name = email;
		el.s_type_id = "4";
		el.s_status_id = String.valueOf(EmailListStatus.ACTIVE);
		el.m_EmailListItems = elis;
		el.save();

		// === === ===

		boolean bRcpSyncErr = false;

		try
		{
			String sRequest = el.toXml();
			String sResponse = Service.communicate(ServiceType.RQUE_LIST_SETUP, custID, sRequest);
			XmlUtil.getRootElement(sResponse);
		}
		catch(Exception ex)
		{
			bRcpSyncErr = true;
		}

		return el.s_list_id;
	}
%>

