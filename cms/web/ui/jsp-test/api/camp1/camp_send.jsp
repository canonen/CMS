<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.que.*,
		com.britemoon.cps.tgt.*,
		com.britemoon.cps.wfl.*,
		com.britemoon.cps.jtk.*,
		org.w3c.dom.*,
		java.util.*,
		java.sql.*,
		java.net.*,
		java.io.*,
		java.text.DateFormat,
		org.apache.log4j.*"
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
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
String sCampId = BriteRequest.getParameter(request,"camp_id");
String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
String sContId = BriteRequest.getParameter(request,"cont_id");
String sPvTestListIds = BriteRequest.getParameter(request,"pv_test_list_ids");
String sMode = BriteRequest.getParameter(request,"mode");
String sSampleId = BriteRequest.getParameter(request,"sample_id");
String sExportName = BriteRequest.getParameter(request,"export_name");
String sView = BriteRequest.getParameter(request,"view");
String sDelimiter = BriteRequest.getParameter(request,"delimiter");
String sApprovalFlag = BriteRequest.getParameter(request,"approval_flag");
if (sApprovalFlag == null) sApprovalFlag = "0";
boolean isPendingEdits = false;
if (WorkflowUtil.getPendingEditsCampId(cust.s_cust_id, sCampId, sSampleId) != null) {
     isPendingEdits = true;
}

String sNewCampId = null;

Campaign camp = new Campaign(sCampId);
boolean bIsRunning = isCampAlreadyRunning(sCampId);
if (isPendingEdits && (!"test".equals(sMode)) && (!"pv_test".equals(sMode)) && (!"pv_receipt".equals(sMode)) && (!"calc_only".equals(sMode))) {
     WorkflowUtil.sendEditedCamp(cust.s_cust_id, sCampId, sApprovalFlag);
}
else if(!bIsRunning) {
	if("all_samples".equals(sSampleId))
	{
		CampSampleset cs = new CampSampleset();
		cs.s_camp_id = sCampId;

		if(cs.retrieve() > 0)
		{
			int nCampQty = Integer.parseInt(cs.s_camp_qty);

			// === Create super campaign for sampleset ===

			SuperCamp super_camp = null;
			SuperCampCamp super_camp_camp = null;
			if((!"test".equals(sMode)) && (!"pv_test".equals(sMode)) && (!"calc_only".equals(sMode)))
			{
				super_camp = new SuperCamp();
				super_camp.s_super_camp_name = camp.s_camp_name + " ( sampleset)";
				super_camp.s_cust_id = camp.s_cust_id;
				super_camp.save();

				super_camp_camp = new SuperCampCamp();
				super_camp_camp.s_super_camp_id = super_camp.s_super_camp_id;
				super_camp_camp.s_camp_id = sCampId;
				super_camp_camp.save();

			}

			// === === ===

			for(int i = 1; i <= nCampQty; i++)
			{
				String sPvTestListId = sPvTestListIds; // need to handle more than one 'pv test list'
				sNewCampId =
					sendCamp(sCampId, camp.s_type_id, i, sContId, sPvTestListId, sMode, sApprovalFlag,
							sExportName, sView, sDelimiter, sSelectedCategoryId, cust, user);
			}
		}
	}
	else if ("pv_test".equals(sMode))
	{
		// send selected PV tests
		if(sSampleId == null) sSampleId = "0";
		int nSampleId = Integer.parseInt(sSampleId);
		System.out.println("sPvTestListIds="+sPvTestListIds);
		if (sPvTestListIds != null && sPvTestListIds.length() > 0) {
			String arr[] = sPvTestListIds.split(",");
			for (int n=0; n < arr.length; n++) {
				String sPvTestListId = arr[n];
				sNewCampId =
					sendCamp(sCampId, camp.s_type_id, nSampleId, sContId, sPvTestListId, sMode, sApprovalFlag,
						sExportName, sView, sDelimiter, sSelectedCategoryId, cust, user);
				System.out.println("sending pv_test campaign = " + sNewCampId + " for pv test list id = " + sPvTestListId);
			}
		}
	}
	else if (!"pv_receipt".equals(sMode))
	{
		// send it!
		if(sSampleId == null) sSampleId = "0";
		int nSampleId = Integer.parseInt(sSampleId);
		sNewCampId =
			sendCamp(sCampId, camp.s_type_id, nSampleId, camp.s_cont_id, "", sMode, sApprovalFlag,
				sExportName, sView, sDelimiter, sSelectedCategoryId, cust, user);

		System.out.println("mode => '" + sMode + "', type => '" + camp.s_type_id + "', list ids => '" + sPvTestListIds + "', cont id => " + camp.s_cont_id);
		if (("send".equals(sMode)) && ("2".equals(camp.s_type_id) || "4".equals(camp.s_type_id)) && (sPvTestListIds != null) && (sPvTestListIds.length() > 0)) {
			System.out.println("sPvTestListIds="+sPvTestListIds);
			String arr[] = sPvTestListIds.split(",");
			for (int n=0; n < arr.length; n++) {
				String sPvTestListId = arr[n];
				String sPvCampType = String.valueOf(CampaignType.TEST);
				String sPvMode = "pv_sendout";
				String pvNewCampId =
					sendCamp(sCampId, sPvCampType, nSampleId, camp.s_cont_id, sPvTestListId, sPvMode, sApprovalFlag,
						sExportName, sView, sDelimiter, sSelectedCategoryId, cust, user);
				System.out.println("creating pv_sendout campaign = " + pvNewCampId + " for pv test list id = " + sPvTestListId);
			}
		}
	}
}
else if(bIsRunning) {
	if ("pv_test".equals(sMode))
	{
		// send selected PV tests
		if(sSampleId == null) sSampleId = "0";
		int nSampleId = Integer.parseInt(sSampleId);
		System.out.println("sPvTestListIds="+sPvTestListIds);
		if (sPvTestListIds != null && sPvTestListIds.length() > 0) {
			String arr[] = sPvTestListIds.split(",");
			for (int n=0; n < arr.length; n++) {
				String sPvTestListId = arr[n];
				sNewCampId =
					sendCamp(sCampId, camp.s_type_id, nSampleId, sContId, sPvTestListId, sMode, sApprovalFlag,
						sExportName, sView, sDelimiter, sSelectedCategoryId, cust, user);
				System.out.println("sending pv_test campaign = " + sNewCampId + " for pv test list id = " + sPvTestListId);
			}
		}
	}
}

String sWM = BriteRequest.getParameter(request,"wizard_mode");
if ("true".equals(sWM))
{
	String sRedirectUrl =
		"/cms/ui/jsp/wizard/wizard.jsp?step=5&camp_id=" + sCampId +
		"&category_id=" + sSelectedCategoryId;

	//response.sendRedirect(sRedirectUrl);
	return;
}


String TYPE_ID = ui.getSessionProperty("camp_list_type_id");
if ((TYPE_ID == null)||("".equals(TYPE_ID))) TYPE_ID = "2";


%>

<%!
private static String sendCamp
	(String sCampId, String sTypeId, int nSampleId,  String sPvContId, String sPvTestListId, String sMode, String sApprovalFlag,
		String sExportName, String sView, String sDelimiter, String sSelectedCategoryId, Customer cust, User user)
			throws Exception
{

	String sSql = null;
	String sNewCampId = null;

	System.out.println("sendCamp => " + sCampId + " mode=" + sMode);
	try
	{
		// Clone is done within CampSetupUtil.prepareCamp4Setup(sCampId, nSampleId);
		boolean bUseReservedCampId = false;
		if
		(
			(!"test".equals(sMode)) &&
			(!"pv_test".equals(sMode)) &&
			(!"calc_only".equals(sMode)) &&
			(!String.valueOf(CampaignType.TEST).equals(sTypeId)) &&
			(nSampleId == 0)
		) bUseReservedCampId = true;
        System.out.println(sCampId+"/"+nSampleId+"/"+bUseReservedCampId);
		sNewCampId = CampSetupUtil.prepareCamp4Setup(sCampId, nSampleId, true);

		if(nSampleId != 0)
		{

			boolean bIsDynamic = false;
			String sLabel = "Sample";
	        String sSampleFilterId = getSampleFilterId(sCampId, nSampleId);
	        String sSamplePriority = getSamplePriority(sCampId, nSampleId);
	        if (sSampleFilterId != null && sSampleFilterId != "")
	        {
	       		bIsDynamic = true;
	       		sLabel = "Campaign";
	        }

			sSql =
				" UPDATE cque_campaign" +
				" SET" +
				"	sample_id = " + nSampleId + "," +
				"	camp_name = camp_name + '" + " - " + sLabel + " " + nSampleId + "'" +
				" WHERE camp_id = " + sNewCampId;
			BriteUpdate.executeUpdate(sSql);

	        // create/setup filters used by dynamic campaign
	        if (bIsDynamic)
	        {
	        	String sFilterId = getFilterId(sCampId);
        		// create a new filter for this dynamic campaign
        		String sDynCampFilterId = createDynCampFilter(cust.s_cust_id, sSelectedCategoryId, sCampId, nSampleId, sFilterId, sSampleFilterId);
	        	try {
	        		// setup the logic element used by dynamic campaign just in case it's not setup
	        		FilterUtil.sendFilterUpdateRequestToRcp(sSampleFilterId);
	        		System.out.println("sendFilterUpdateRequestToRcp for sample filter id " + sSampleFilterId);
	        		FilterUtil.sendFilterUpdateRequestToRcp(sDynCampFilterId);
	        		System.out.println("sendFilterUpdateRequestToRcp for dynamic camp filter id " + sDynCampFilterId);
	        	}
	        	catch (Exception ex) {
	    			logger.error("Exception: ",ex);
	    		}

	        	sSql =
					"UPDATE cque_campaign" +
					"   SET sample_filter_id = " + sDynCampFilterId + ", sample_priority = " + sSamplePriority +
					" WHERE camp_id = " + sNewCampId;
				BriteUpdate.executeUpdate(sSql);
				System.out.println("done setting up filter for dynamic camp");

	        }

		}


		CampEditInfo cei = new CampEditInfo(sNewCampId);
		cei.s_creator_id = user.s_user_id;
		cei.s_modifier_id = user.s_user_id;
		cei.save();

        JsonObject obj = new JsonObject();
        JsonArray arr = new JsonArray();
		if(("test".equals(sMode)) || ("pv_test".equals(sMode)) ||  ("pv_sendout".equals(sMode)) || ("calc_only".equals(sMode)))
		{
			sApprovalFlag = "1";
			if("test".equals(sMode))
			{
				sSql =
					" UPDATE cque_campaign" +
					" SET type_id = " + CampaignType.TEST +
					" WHERE camp_id = " + sNewCampId;
			}
			else if("pv_test".equals(sMode))
			{
				sSql =
					" UPDATE cque_campaign" +
					" SET type_id = " + CampaignType.TEST + "," +
					" mode_id = " + CampaignMode.DELIVERABILITY_TEST +
					" WHERE camp_id = " + sNewCampId;
			}
			else if("pv_sendout".equals(sMode))
			{
				sSql =
					" UPDATE cque_campaign" +
					" SET type_id = " + CampaignType.TEST + "," +
					" mode_id = " + CampaignMode.DELIVERABILITY_SENDOUT +
					" WHERE camp_id = " + sNewCampId;
			}
			else if ("calc_only".equals(sMode))
			{

				sSql =
					" UPDATE cque_campaign " +
					" SET type_id = " + CampaignType.TEST + ", " +
					" mode_id = " + CampaignMode.CALC_ONLY +
					" WHERE camp_id = " + sNewCampId;

			}

			BriteUpdate.executeUpdate(sSql);

			sSql =
				" UPDATE cque_schedule SET " +
				" start_date=getdate()," +
				" end_date = null," +
				" start_daily_time = null," +
				" end_daily_time = null," +
				" start_daily_weekday_mask = null" +
				" WHERE camp_id = " + sNewCampId;

			BriteUpdate.executeUpdate(sSql);

			sSql =
				" UPDATE cque_camp_send_param SET" +
				" delay=0," +
				" queue_date=getdate()," +
				" queue_daily_flag = null," +
				" queue_daily_time = null," +
				" queue_daily_weekday_mask = null" +
				" WHERE camp_id = " + sNewCampId;

			BriteUpdate.executeUpdate(sSql);
		}
		else
		{

			sSql =
				" UPDATE cque_schedule SET start_date=ISNULL(start_date, getdate())" +
				" WHERE camp_id = " + sNewCampId;

			BriteUpdate.executeUpdate(sSql);

			sSql =
				" UPDATE cque_camp_send_param SET" +
				" queue_date=ISNULL(queue_date, getdate()), delay=ISNULL(delay,0)" +
				" WHERE camp_id = " + sNewCampId;

			BriteUpdate.executeUpdate(sSql);
		}


		LinkedCamp lc = new LinkedCamp(sCampId);
		if(lc.s_form_id != null)
		{
			String sFilterId = createCampFormFilter(cust.s_cust_id, lc);
			sSql =
				" UPDATE cque_campaign SET filter_id=" + sFilterId +
				" WHERE camp_id = " + sNewCampId;

			BriteUpdate.executeUpdate(sSql);
		}

		createReadLink(sNewCampId);

		createExportSetup(sNewCampId, sExportName, sView, sDelimiter);

		if (("pv_test".equals(sMode)) || ("pv_sendout".equals(sMode)))
		{
			sSql =
				"UPDATE cque_camp_list" +
				"   SET test_list_id = " + sPvTestListId +
				" WHERE camp_id = " + sNewCampId;
			BriteUpdate.executeUpdate(sSql);
			System.out.println("override test list id with pv_test_list_ids = " + sPvTestListId);

			String pv_iq = getPvIq(cust.s_cust_id, sPvTestListId, sNewCampId);
			sSql =
				"UPDATE cque_campaign" +
				"   SET pv_iq = '" + pv_iq + "'" +
				" WHERE camp_id = " + sNewCampId;
			BriteUpdate.executeUpdate(sSql);
			System.out.println("saved pv iq for camp id " + sNewCampId + " => " + pv_iq);

			Campaign camp = new Campaign(sNewCampId);
			CampPVHist pvhist = new CampPVHist();
			pvhist.s_cust_id = cust.s_cust_id;
			pvhist.s_pv_test_type_id = "1"; // 1 = PV delivery track test
			pvhist.s_camp_id = sNewCampId;
			pvhist.s_origin_camp_id = camp.s_origin_camp_id;
			pvhist.s_cont_id = sPvContId;
			pvhist.s_pv_iq = pv_iq;
			pvhist.s_tester_id = user.s_user_id;
			pvhist.save();
			System.out.println("saved pv hist => " + pvhist.s_pv_hist_id);

		}

		try
		{

			if ("pv_sendout".equals(sMode)) {
				// we don't want to send to rcp for 'pv sendout', it is postponed until the main campaign is done
				sSql =
					"UPDATE cque_campaign" +
					"   SET approval_flag = " + sApprovalFlag +
					" WHERE camp_id = " + sNewCampId;
				BriteUpdate.executeUpdate(sSql);
			}
			else {
				sSql =
					" UPDATE cque_campaign SET" +
					" status_id = " + CampaignStatus.SENT_TO_RCP +
					", approval_flag = " + sApprovalFlag +
					" WHERE camp_id = " + sNewCampId;

				BriteUpdate.executeUpdate(sSql);

				CampSetupUtil.doRcpSetup(sNewCampId);

				/* for non-email, the timer won't do the JtkSetup, so we have to do it manually */
				if (sTypeId.equals("5")) {
					CampSetupUtil.doJtkSetup(sNewCampId);
				}
			}

		}
		catch(Exception ex)
		{
			// it supposed to be like: do not care ... CampSetupTimer will grab it
			// ex.printStackTrace();
			// but it (CampSetupTimer) will not ... at least for now, so throw exception
			throw ex;
		}

	}
	catch(Exception ex)
	{
		sSql =
			" UPDATE cque_campaign" +
			" SET status_id = " + CampaignStatus.ERROR +
			" WHERE camp_id = " + sNewCampId;
		BriteUpdate.executeUpdate(sSql);
		throw ex;
	}

	return sNewCampId;
}

private static String createCampFormFilter(String sCustId, LinkedCamp lc) throws Exception
{
	String sFilterId = null;

	if(lc.s_form_id == null) return sFilterId;
	if(lc.s_camp_id == null) return sFilterId;


	FilterParam fpCamp = new FilterParam();
	fpCamp.s_param_id = "0";
	fpCamp.s_param_name = "camp_id";
	fpCamp.s_integer_value = lc.s_camp_id;

	FilterParam fpForm = new FilterParam();
	fpForm.s_param_id = "1";
	fpForm.s_param_name = "form_id";
	fpForm.s_integer_value = lc.s_form_id;

	FilterParams params = new FilterParams();
	params.add(fpCamp);
	params.add(fpForm);

	String sFilterName =
		"Campaign Form Filter for camp_id=" + lc.s_camp_id + " form_id=" + lc.s_form_id;

	com.britemoon.cps.tgt.Filter fCampForm = new com.britemoon.cps.tgt.Filter();
	fCampForm.s_filter_name = sFilterName;
	fCampForm.s_type_id = String.valueOf(FilterType.CAMPAIGN_FORM);
	fCampForm.s_status_id = String.valueOf(FilterStatus.NEW);
	fCampForm.s_cust_id = sCustId;

	fCampForm.m_FilterParams = params;

	FilterPart fp = new FilterPart();
	fp.m_ChildFilter = fCampForm;

	FilterParts parts = new FilterParts();
	parts.add(fp);

	com.britemoon.cps.tgt.Filter fTop = new com.britemoon.cps.tgt.Filter();
	fTop.s_filter_name = sFilterName;
	fTop.s_type_id = String.valueOf(FilterType.MULTIPART);
	fTop.s_cust_id = sCustId;
	fTop.s_status_id = String.valueOf(FilterStatus.NEW);

	fTop.m_FilterParts = parts;

	fTop.save();

	sFilterId = fTop.s_filter_id;

	String sSql =
		" UPDATE ctgt_filter" +
		" SET origin_filter_id = filter_id, usage_type_id = " + FilterUsageType.HIDDEN +
		" WHERE filter_id = " + sFilterId;
	BriteUpdate.executeUpdate(sSql);

	return sFilterId;
}

private static void createReadLink(String sCampId) throws Exception
{
	Campaign camp = new Campaign(sCampId);

	Link link = new Link();
	link.s_link_name = "read_link";
	link.s_cont_id = camp.s_cont_id;
	link.s_camp_id = camp.s_camp_id;
	link.s_cust_id = camp.s_cust_id;
	link.s_href = null;
	link.s_origin_link_id = null;
	link.save();
}

private static void createExportSetup(String sCampId, String sExportName, String sView, String sDelimiter) throws Exception
{
	if (sView == null) {
		return;
	}
	Campaign camp = new Campaign(sCampId);
    if (!camp.s_type_id.equals("5")) {
		if (camp.s_media_type_id == null || camp.s_media_type_id.equals("1")) {
			return;
		}
	}
	String sSql = "DELETE FROM cque_camp_export_attr WHERE camp_id = " + camp.s_origin_camp_id;
	BriteUpdate.executeUpdate(sSql);

	sSql = "DELETE FROM cque_camp_export WHERE camp_id = " + camp.s_origin_camp_id;
	BriteUpdate.executeUpdate(sSql);

	sSql = "INSERT cque_camp_export (camp_id, export_name, delimiter) VALUES (" + camp.s_origin_camp_id + ",'" + sExportName + "','" + sDelimiter + "')";
	BriteUpdate.executeUpdate(sSql);

	StringTokenizer st = new StringTokenizer(sView, ",");
	int n=0;
	while (st.hasMoreTokens())
	{
		n++;
		sSql =
			" INSERT cque_camp_export_attr (camp_id, seq, attr_id)" +
			" VALUES (" + camp.s_origin_camp_id + "," + n + "," + st.nextToken() + ")";
		BriteUpdate.executeUpdate(sSql);
	}
}

private static boolean isCampAlreadyRunning(String sCampId) throws Exception
{
	boolean bIsRunning = true;

	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("camp_send.jsp");
		stmt = conn.createStatement();

		String sSql =
			" SELECT TOP 1 camp_id" +
			" FROM cque_campaign WITH(NOLOCK)" +
			" WHERE origin_camp_id = " + sCampId +
			" AND status_id < 60 AND status_id <> 5";

		ResultSet rs = stmt.executeQuery(sSql);
		bIsRunning = rs.next();
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try { if(stmt!=null) stmt.close(); }
		catch (Exception ex)
		{
			logger.error("Exception: ",ex);
		}
		if(conn != null) cp.free(conn);
	}

	return bIsRunning;
}

private static String getPvIq(String sCustId, String sListId, String sCampId) throws Exception
{
	String pvIq = null;

	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("camp_send_2.jsp");
		stmt = conn.createStatement();
		System.out.println("getting pv iq for cust=" + sCustId + " list_id=" + sListId + " camp_id=" + sCampId);
		String sSql = "EXEC usp_ccps_next_pv_id_get @cust_id=" + sCustId + ", @list_id = " + sListId + ", @camp_id=" + sCampId;
		ResultSet rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			pvIq = rs.getString(1);
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try { if(stmt!=null) stmt.close(); }
		catch (Exception ex)
		{
			logger.error("Exception: ",ex);
		}
		if(conn != null) cp.free(conn);
	}

	return pvIq;
}

private static String getSampleFilterId(String sCampId, int nSampleId) throws Exception
{
	String sSampleFilterId = null;

	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("camp_send_3.jsp");
		stmt = conn.createStatement();
		String sSql = "SELECT filter_id" +
		              "  FROM cque_camp_sample" +
		              " WHERE camp_id = " + sCampId +
		              "   AND sample_id =" + nSampleId;
		ResultSet rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			sSampleFilterId = rs.getString(1);
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try { if(stmt!=null) stmt.close(); }
		catch (Exception ex)
		{
			logger.error("Exception: ",ex);
		}
		if(conn != null) cp.free(conn);
	}

	return sSampleFilterId;
}

private static String getSamplePriority(String sCampId, int nSampleId) throws Exception
{
	String sSamplePriority = null;

	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("camp_send_4.jsp");
		stmt = conn.createStatement();
		String sSql = "SELECT priority" +
		              "  FROM cque_camp_sample WITH(NOLOCK)" +
		              " WHERE camp_id = " + sCampId +
		              "   AND sample_id =" + nSampleId;
		ResultSet rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			sSamplePriority = rs.getString(1);
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try { if(stmt!=null) stmt.close(); }
		catch (Exception ex)
		{
			logger.error("Exception: ",ex);
		}
		if(conn != null) cp.free(conn);
	}

	return sSamplePriority;
}

private static String getFilterId(String sCampId) throws Exception
{
	String sFilterId = null;

	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("camp_send_5.jsp");
		stmt = conn.createStatement();
		String sSql = "SELECT filter_id" +
		              "  FROM cque_campaign WITH(NOLOCK)" +
		              " WHERE camp_id = " + sCampId;
		ResultSet rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			sFilterId = rs.getString(1);
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try { if(stmt!=null) stmt.close(); }
		catch (Exception ex)
		{
			logger.error("Exception: ",ex);
		}
		if(conn != null) cp.free(conn);
	}

	return sFilterId;
}

private static String createDynCampFilter(String sCustId, String sCategoryId, String sCampId, int nSampleId, String sFilterId, String sSampleFilterId) throws Exception
{

	FilterParams params = null;
	FilterParam param = null;

	com.britemoon.cps.tgt.Filter childFilter1 = new com.britemoon.cps.tgt.Filter(sFilterId);

	com.britemoon.cps.tgt.Filter childFilter2 = new com.britemoon.cps.tgt.Filter(sSampleFilterId);


	com.britemoon.cps.tgt.Filter parentFilter = new com.britemoon.cps.tgt.Filter();
	parentFilter.s_cust_id = sCustId;
	parentFilter.s_filter_name = "Dynamic Campaign filter for camp_id=" + sCampId + " and sample_id=" + nSampleId;
	parentFilter.s_type_id = String.valueOf(FilterType.MULTIPART);
	parentFilter.s_status_id = String.valueOf(FilterStatus.NEW);
	parentFilter.s_usage_type_id = String.valueOf(FilterUsageType.REGULAR);
	parentFilter.s_aprvl_status_flag = "1";
	param = new FilterParam();
	param.s_param_name = "BOOLEAN OPERATION";
	param.s_string_value = "AND";
	params = new FilterParams();
	params.add(param);
	parentFilter.m_FilterParams = params;

	FilterPart part1 = new FilterPart();
	part1.m_ChildFilter = childFilter1;
	FilterPart part2 = new FilterPart();
	part2.m_ChildFilter = childFilter2;
	FilterParts parts = new FilterParts();
	parts.add(part1);
	parts.add(part2);
	parentFilter.m_FilterParts = parts;

	parentFilter.save();
	System.out.println("Created filter  => " + parentFilter.s_filter_name + ", id = " + parentFilter.s_filter_id);
	System.out.println("        child 1 => " + childFilter1.s_filter_name + ", id = " + childFilter1.s_filter_id);
	System.out.println("        child 2 => " + childFilter2.s_filter_name + ", id = " + childFilter2.s_filter_id);
	ObjectCategories categories = new ObjectCategories();
	categories.s_cust_id = sCustId;
	categories.s_object_id = parentFilter.s_filter_id;
	categories.s_type_id = String.valueOf(ObjectType.FILTER);
	categories.s_category_id = sCategoryId;
	categories.save();
	System.out.println("Saved object category: " + sCategoryId);

	return parentFilter.s_filter_id;
}

%>
