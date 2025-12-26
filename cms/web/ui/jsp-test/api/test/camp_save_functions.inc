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
	mh.s_from_address_id = BriteRequest.getParameter(request, "from_address_id");
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

	camp.save();

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
