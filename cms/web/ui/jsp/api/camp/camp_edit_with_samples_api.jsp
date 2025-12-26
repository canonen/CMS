<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			java.text.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
  if(logger == null)
  {
    logger = Logger.getLogger(this.getClass().getName());
  }

  AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
  if(!can.bRead)
  {
    response.sendRedirect("../access_denied.jsp");
    return;
  }
  AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

  AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);

  boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
  boolean canFromAddrPers = ui.getFeatureAccess(Feature.FROM_ADDR_PERS);
  boolean canFromNamePers = ui.getFeatureAccess(Feature.FROM_NAME_PERS);
  boolean canSubjectPers = ui.getFeatureAccess(Feature.SUBJECT_PERS);
  boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
  boolean canSampleSet = ui.getFeatureAccess(Feature.SAMPLE_SET);
  boolean canStep2 = ui.getFeatureAccess(Feature.CAMP_STEP_2);
  boolean canStep3 = ui.getFeatureAccess(Feature.CAMP_STEP_3);
  boolean canQueueStep = ui.getFeatureAccess(Feature.QUEUE_STEP);
  boolean canSpecTest = ui.getFeatureAccess(Feature.SPECIFIED_TEST);
  boolean canTestHelp = ui.getFeatureAccess(Feature.TESTING_HELP);
  boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);

  boolean bUseSampleset = true;

  String sSelectedCategoryId = request.getParameter("category_id");
  if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
    sSelectedCategoryId = ui.s_category_id;

  String sCampId = request.getParameter("camp_id");
  String sCampType = request.getParameter("type_id");

  String sAprvlRequestId = request.getParameter("aprvl_request_id");
  if (sAprvlRequestId == null)
    sAprvlRequestId = "";

  Campaign camp = new Campaign();

  CampEditInfo camp_edit_info = null;
  CampList camp_list = null;
  CampSendParam camp_send_param = null;
  MsgHeader msg_header = null;
  Schedule schedule = null;
  LinkedCamp linked_camp = null;
  FilterStatistic filter_statistic = null;

  User creator = null;
  User modifier = null;

  CampSampleset camp_sampleset = null;

  if(sCampId == null)
  {
    if(sCampType == null) throw new Exception("Undefined campaign type ...");

    camp.s_type_id = sCampType;

    camp_send_param = new CampSendParam();
    schedule = new Schedule();
    msg_header = new MsgHeader();
    camp_list = new CampList();
    camp_edit_info = new CampEditInfo();
    linked_camp = new LinkedCamp();
    filter_statistic = new FilterStatistic();

    creator = user;
    modifier = user;

    // === === ===

    // DnB default frequency
    if (cust.s_cust_id.equals("20") || cust.s_cust_id.equals("36")) // FOR PRODUCTION
    {
//	if (cust.s_cust_id.equals("32") || cust.s_cust_id.equals("33"))  // FOR TESTING ONLY
//	{
      if (camp.s_type_id.equals("2")) camp_send_param.s_camp_frequency = "15";
    }
  }
  else
  {
    camp = new Campaign();
    camp.s_camp_id = sCampId;
    if(camp.retrieve() < 1) throw new Exception("Campaign does not exist");

    camp_send_param = new CampSendParam(sCampId);
    schedule = new Schedule(sCampId);
    msg_header = new MsgHeader(sCampId);
    camp_list = new CampList(sCampId);
    camp_edit_info = new CampEditInfo(sCampId);
    linked_camp = new LinkedCamp(sCampId);
    filter_statistic = new FilterStatistic(camp.s_filter_id);

    creator = new User(camp_edit_info.s_creator_id);
    modifier = new User(camp_edit_info.s_modifier_id);

    camp_sampleset = new CampSampleset(sCampId);
  }

// === SET DEFAULTS ===

  if(camp.s_camp_name == null) camp.s_camp_name = "New campaign";
  if(camp.s_status_id == null) camp.s_status_id = String.valueOf(CampaignStatus.DRAFT);

  if(camp_send_param.s_recip_qty_limit == null)			camp_send_param.s_recip_qty_limit			= "0";
  if(camp_send_param.s_randomly == null)					camp_send_param.s_randomly					= "0";
  if(camp_send_param.s_delay == null)						camp_send_param.s_delay						= "0";
  if(camp_send_param.s_limit_per_hour == null)			camp_send_param.s_limit_per_hour			= "0";
  if(camp_send_param.s_msg_per_email821_limit == null)	camp_send_param.s_msg_per_email821_limit	= "0";
  if(camp_send_param.s_msg_per_recip_limit != null )		camp_send_param.s_msg_per_recip_limit 		= "1";

// === SET MEDIA TYPE DEFAULTS ===

  boolean isPrintCampaign = false;
  if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2")) {
    isPrintCampaign = true;
    canFromAddrPers = false;
    canFromNamePers = false;
    canSubjectPers = false;
    canSpecTest = false;
    canTestHelp = false;
  }

  boolean isDynamicCampaign = false;
  if (camp_sampleset.s_filter_flag != null && camp_sampleset.s_filter_flag.equals("1")) {
    isDynamicCampaign = true;
  }
// === === ===

  ConnectionPool	cp		= null;
  Connection		conn	= null;
  Statement		stmt	= null;
  ResultSet		rs		= null;

  try{
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection("camp_edit.jsp");
    stmt = conn.createStatement();
    String sSql="";
    boolean bWasFinalCampSent = false;
    boolean bWasSamplesetSent = false;
    boolean bWasAnythingSent = false;
    boolean bHasUnapprovedCamps = false;

    String sShowSampleStatus = "&nbsp;";

    boolean isTesting = false;
    boolean isSending = false;
    boolean bIsDone = false;

    /* for workflow processing */
    boolean finalIsPending = false;
    boolean samplesArePending = false;
    boolean isFinalApprover = false;
    boolean isSamplesApprover = false;
    ApprovalRequest arRequest = null;
    ApprovalRequest arRequestSamples = null;
    if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
//          System.out.println("getting approval request dealy for:" + sAprvlRequestId);
      arRequest = new ApprovalRequest(sAprvlRequestId);
      ApprovalTask at = new ApprovalTask(arRequest.s_aprvl_id);
      if (at.s_camp_sample_flag != null && at.s_camp_sample_flag.equals("1")) {
        arRequestSamples = arRequest;
        arRequest = null;
      }
    } else {
      arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.CAMPAIGN),camp.s_camp_id,"0");
      arRequestSamples = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.CAMPAIGN),camp.s_camp_id,"1");
    }
    if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
//          sAprvlRequestId = arRequest.s_approval_request_id;
      isFinalApprover = true;
    }
    if (arRequestSamples != null && arRequestSamples.s_approver_id != null && arRequestSamples.s_approver_id.equals(user.s_user_id)) {
//          sAprvlRequestId = arRequestSamples.s_approval_request_id;
      isSamplesApprover = true;
    }
    JsonObject jsonResponse = new JsonObject();
    JsonArray categoriesArray = new JsonArray();
    sSql =
            " SELECT c.category_id, c.category_name, oc.object_id" +
                    " FROM ccps_category c" +
                    " LEFT OUTER JOIN ccps_object_category oc" +
                    " ON (c.category_id = oc.category_id" +
                    " AND c.cust_id = oc.cust_id" +
                    " AND oc.object_id = " + camp.s_camp_id +
                    " AND oc.type_id = " + ObjectType.CAMPAIGN + ")" +
                    " WHERE c.cust_id = " + cust.s_cust_id;
    rs=stmt.executeQuery(sSql);
    while (rs.next()) {
      String sCategoryId = rs.getString(1);
      String sCategoryName = new String(rs.getBytes(2), "UTF-8");
      String sObjectId = rs.getString(3);

      boolean isSelected = (sObjectId != null) || ((sSelectedCategoryId != null) && sSelectedCategoryId.equals(sCategoryId));

      JsonObject categoryJson = new JsonObject();
      categoryJson.put("id", sCategoryId);
      categoryJson.put("name", sCategoryName);
      categoryJson.put("selected", isSelected);

      categoriesArray.put(categoryJson);
    }
    rs.close();
    jsonResponse.put("categories",categoriesArray);


    jsonResponse.put("campaignName", camp.s_camp_name);
    jsonResponse.put("canSaveCategories", can.bWrite && bWasFinalCampSent && bWasSamplesetSent && canSampleSet);
    jsonResponse.put("isPrintCampaign", isPrintCampaign);
    jsonResponse.put("isDynamicCampaign", isDynamicCampaign);
    jsonResponse.put("isFinalApprover", isFinalApprover);
    jsonResponse.put("isSamplesApprover", isSamplesApprover);

    /////STATUS DESC.
      int nTypeId = -1;
      int nStatusId = -1;
      int nAprovalFlag = -1;
      int nIsSample = -1;
      int nCampCount = -1;
      int nModeId = -1;
      String sSampleCampName = "";
      String sTypeName = "";

      boolean bAllSamplesDone = true;
      boolean bShowRow = true;
      boolean bHasSendingCamps = false;
      String sClassAppend = "";
      int sampleCount = 0;

      sSql =
              " SELECT" +
                      " camp_name," +
                      " type_id," +
                      " status_id," +
                      " ISNULL(approval_flag,0)," +
                      " SIGN(ISNULL(sample_id,0)) " +
                      " FROM cque_campaign" +
                      " WHERE origin_camp_id = " + camp.s_camp_id +
                      " AND ISNULL(mode_id,0) <> " + CampaignMode.CALC_ONLY +                                                            // Don't display any calc_only test campaigns
                      " ORDER BY type_id, status_id, ISNULL(approval_flag,0), SIGN(ISNULL(sample_id,0))";

      rs = stmt.executeQuery(sSql);

      if(rs.next()){
        bWasAnythingSent = true;

        do {
          bShowRow = true;

          sSampleCampName = rs.getString(1);
          nTypeId = rs.getInt(2);
          nStatusId = rs.getInt(3);
          nAprovalFlag = rs.getInt(4);
          nIsSample = rs.getInt(5);



          if((nIsSample == 0) && (nTypeId != CampaignType.TEST))
          {
            bWasFinalCampSent = true;
            if ( (nStatusId == CampaignStatus.PENDING_APPROVAL))
            {
              finalIsPending = true;
            }

          }
          else
          {
            if (nTypeId != CampaignType.TEST)
            {
              bWasSamplesetSent = true;
              if ( (nStatusId == CampaignStatus.PENDING_APPROVAL))
              {
                samplesArePending = true;
              }
            }
          }

          if (nIsSample != 0 && nStatusId < CampaignStatus.DONE)
          {
            bAllSamplesDone = false;
          }

          if (!bHasUnapprovedCamps && (nAprovalFlag == 0))
          {
            bHasUnapprovedCamps = true;
          }

          if (!bHasSendingCamps && (nStatusId == CampaignStatus.BEING_PROCESSED))
          {
            bHasSendingCamps = true;
          }

          if (nTypeId == CampaignType.TEST)
          {
            //Test, see if it is in the middle of testing
            if (nStatusId < CampaignStatus.DONE)
            {
              isTesting = true;
            }
            if ((nStatusId >= CampaignStatus.DONE) && (nStatusId != CampaignStatus.ERROR))
            {
              bShowRow = false;
            }

            sTypeName = "Test";
          }
          else
          {
            //Normal campaign
            if ((nIsSample == 0) && (nStatusId < CampaignStatus.DONE) && (nStatusId != CampaignStatus.PENDING_APPROVAL))
            {
              isSending = true;
            }


            if (nIsSample == 0)
            {
              sTypeName = "Final";
            }
            else
            {
              if (isDynamicCampaign) {
                sTypeName = "Campaign";
              }
              else {
                sTypeName = "Sample";
              }
            }
          }
          jsonResponse.put("sSampleCampName_status",sSampleCampName);
          jsonResponse.put("nTypeId_status",nTypeId);
          jsonResponse.put("nStatusId_status",nStatusId);
          jsonResponse.put("nAprovalFlag_status",nAprovalFlag);
          jsonResponse.put("nIsSample_status",nIsSample);
          jsonResponse.put("sTypeName_status",sTypeName);

        }while (rs.next());
      }
      rs.close();



    /////////////TAB 1 _STEP1
    jsonResponse.put("campaign_Name_st1_tab1",camp.s_camp_name);
    if(sSelectedCategoryId!=null){
      jsonResponse.put("sSelectedCategoryId",sSelectedCategoryId);
    }


    jsonResponse.put("camp_id",camp.s_camp_id);
    jsonResponse.put("mutiple_name_st1_tab1",!canCat.bExecute?" disabled":"");
    if(camp.s_camp_id !=null){
      jsonResponse.put("sShowSampleStatus",sShowSampleStatus);
    }
  ////////////TAB2
    if (!isPrintCampaign && camp_sampleset.s_from_name_flag == null){
      jsonResponse.put("from_name_st2_tab1",msg_header.s_from_name);

    }

    if (!isPrintCampaign && camp_sampleset.s_from_address_flag == null){
      jsonResponse.put("fromAddress_st2_tab1",msg_header.s_from_address);

      sSql =
              " SELECT from_address_id, prefix+'@'+[domain]" +
                      " FROM ccps_from_address" +
                      " WHERE cust_id = " + cust.s_cust_id +
                      " ORDER BY from_address_id DESC";

      String sFromAddressId = null;
      String sFromName_Step2_tab1=null;
      rs = stmt.executeQuery(sSql);
      JsonArray st2_tab1_arr = new JsonArray();
      while( rs.next() )
      {
        JsonObject st2_tab1 = new JsonObject();

        sFromAddressId = rs.getString(1);
        sFromName_Step2_tab1 = rs.getString(2);
        st2_tab1.put("sFromAddressId_st2_tab1",sFromAddressId);
        st2_tab1.put("sFromName_st2_tab1",sFromName_Step2_tab1);
        st2_tab1_arr.put(st2_tab1);
      }
      jsonResponse.put("st2_tab1",st2_tab1_arr);
      rs.close();

      jsonResponse.put("fromAddressId_st2_tab1",msg_header.s_from_address_id);
    }


    if (!isPrintCampaign && camp_sampleset.s_subject_flag == null){
      String msg="";
      String mes=msg_header.s_subject_html;
      StringBuilder sw = new StringBuilder();
      StringBuilder sb=new StringBuilder();

      if(mes!=null)
      {
        char ch = 0;
        int n = 0;
        int len = mes.length();
        for(int i = 0; i < len; i ++)
        {
          ch = mes.charAt(i);
          n = ch;
          if
          (
                  (n == 32)
                          ||
                          ((n >= 48)&&(n <= 57))
                          ||
                          ((n >= 65)&&(n <= 90))
                          ||
                          ((n >= 97)&&(n <= 122))
          ) sb.append(ch);
          else
          {
            //sw.append("&#" + (int)ch + ";");
            int c=mes.codePointAt(i);
            if(!(Integer.toHexString(c).startsWith("d")))
            {
              sb.append("&#x"+Integer.toHexString(c)+";");
              // System.out.println(i+" "+"&#x"+Integer.toHexString(c)+";"+ch);

            }
            else
            {
              if(Integer.toHexString(c).equals("d6") || Integer.toHexString(c).equals("dc"))
              {
                sb.append("&#x"+Integer.toHexString(c)+";");

              }



            }



          }
        }

        msg= sb.toString();
      }
      else
      {
        msg="";
      }
      jsonResponse.put("Subject_st2_tab1", msg);

    }
    //119
    if (camp_sampleset.s_cont_flag == null){
      if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
      {
        String sTypeCond = " AND type_id = 20 AND origin_cont_id IS NULL";
        if (isPrintCampaign) {
          sTypeCond = " AND type_id = 40 AND origin_cont_id IS NULL AND cti_doc_id IS NOT NULL";
        }
        sSql =
                " SELECT cont_id, cont_name" +
                        " FROM ccnt_content" +
                        " WHERE cust_id = " + cust.s_cust_id  +
                        " AND status_id = 20" +
                        sTypeCond +
                        ((camp.s_cont_id!=null)?" OR cont_id = " + camp.s_cont_id:"") +
                        " ORDER BY cont_id DESC";
      }
      else {
        String sTypeCond = " AND c.type_id = 20 AND c.origin_cont_id IS NULL";
        if (isPrintCampaign) {
          sTypeCond = " AND c.type_id = 40 AND c.origin_cont_id IS NULL AND c.cti_doc_id IS NOT NULL";
        }
        sSql =
                " SELECT DISTINCT c.cont_id, c.cont_name" +
                        " FROM ccnt_content c, ccps_object_category oc" +
                        " WHERE (c.cust_id = " + cust.s_cust_id +
                        " AND c.status_id = 20" +
                        sTypeCond +
                        " AND c.cont_id = oc.object_id" +
                        " AND oc.type_id = " + ObjectType.CONTENT +
                        " AND oc.cust_id = " + cust.s_cust_id +
                        " AND oc.category_id = " + sSelectedCategoryId + ")" +
                        ((camp.s_cont_id!=null)?" OR c.cont_id = " + camp.s_cont_id:"") +
                        " ORDER BY c.cont_id DESC";
      }

      String sContId_st2_tab1 = null;
      String cont_name_st2_tab1 = null;
      rs = stmt.executeQuery(sSql);
      JsonArray st2_tab1_arr2 = new JsonArray();
      while(rs.next()){
        JsonObject st2_tab1 = new JsonObject();
        sContId_st2_tab1 = rs.getString(1);
        cont_name_st2_tab1 = rs.getString(2);
        st2_tab1.put("sContId_st2_tab1",sContId_st2_tab1);
        st2_tab1.put("cont_name_st2_tab1",cont_name_st2_tab1);
        st2_tab1_arr2.put(st2_tab1);
      }
      jsonResponse.put("st2_tab1_arr2",st2_tab1_arr2);
      rs.close();
    }
    /// functions.jsp getFilterOptionsHtml
    String sSelectedFilterId =camp.s_filter_id;
    if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
    {
      sSql =
              " SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
                      " CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
                      " FROM ctgt_filter" +
                      " WHERE cust_id = " + cust.s_cust_id +
                      " AND origin_filter_id IS NULL" +
                      " AND filter_name IS NOT NULL" +
                      " AND type_id=" + FilterType.MULTIPART +
                      " AND usage_type_id=" + FilterUsageType.REGULAR +
                      " AND status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
                      " AND ISNULL(aprvl_status_flag,1) <> 0" + // Don't display Filters that are unapproved
                      ((sSelectedFilterId!=null)?" OR filter_id = " + sSelectedFilterId:"") +
                      " ORDER BY 1 DESC";
    }
    else
    {
      sSql =
              " SELECT DISTINCT f.filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + f.filter_name ELSE f.filter_name END," +
                      " CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
                      " FROM ctgt_filter f, ccps_object_category oc" +
                      " WHERE (f.cust_id = " + cust.s_cust_id +
                      " AND f.origin_filter_id IS NULL" +
                      " AND f.filter_name IS NOT NULL" +
                      " AND f.type_id=" + FilterType.MULTIPART +
                      " AND f.filter_id = oc.object_id" +
                      " AND f.usage_type_id=" + FilterUsageType.REGULAR +
                      " AND f.status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
                      " AND ISNULL(aprvl_status_flag,1) <> 0" + // Don't display Filters that are unapproved
                      " AND oc.type_id = " + ObjectType.FILTER +
                      " AND oc.cust_id = " + cust.s_cust_id +
                      " AND oc.category_id = " + sSelectedCategoryId + ")" +
                      ((sSelectedFilterId!=null)?" OR f.filter_id = " + sSelectedFilterId:"") +
                      " ORDER BY 1 DESC";
    }

    String sFilterId = "";
    String sFilterName = "";
    String sDeleted = "0";
    rs = stmt.executeQuery(sSql);
    JsonArray targe_arr = new JsonArray();
    while (rs.next()){
      JsonObject target = new JsonObject();
      sFilterId = rs.getString(1);
      sFilterName = new String(rs.getBytes(2),"UTF-8");
      sDeleted = rs.getString(3);
      target.put("sFilterId_target",sFilterId);
      target.put("sFilterName_target",sFilterName);
      target.put("sDeleted_target",sDeleted);
      targe_arr.put(target);

    }
 //   jsonResponse.put("targetGroup_arr", targe_arr);
    jsonResponse.put("targetGropup_name",sFilterName);
    jsonResponse.put("responseForwarding_st2_tab1", camp_send_param.s_response_frwd_addr);
    rs.close();
    /////////////////STEP_2_TAB_1 SONN
    /////////////////STEP_2_TAB_2
    if (!isPrintCampaign && camp_sampleset.s_reply_to_flag == null){
      jsonResponse.put("replyTo_st2_tab2",msg_header.s_reply_to);
    }

    if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
    {
      sSql =
              " SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
                      " CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
                      " FROM ctgt_filter" +
                      " WHERE cust_id = " + cust.s_cust_id +
                      " AND origin_filter_id IS NULL" +
                      " AND filter_name IS NOT NULL" +
                      " AND type_id=" + FilterType.MULTIPART +
                      " AND usage_type_id=" + FilterUsageType.REGULAR +
                      " AND status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
                      " AND ISNULL(aprvl_status_flag,1) <> 0" + // Don't display Filters that are unapproved
                      ((sSelectedFilterId!=null)?" OR filter_id = " + sSelectedFilterId:"") +
                      " ORDER BY 1 DESC";
    }
    else
    {
      sSql =
              " SELECT DISTINCT f.filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + f.filter_name ELSE f.filter_name END," +
                      " CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
                      " FROM ctgt_filter f, ccps_object_category oc" +
                      " WHERE (f.cust_id = " + cust.s_cust_id +
                      " AND f.origin_filter_id IS NULL" +
                      " AND f.filter_name IS NOT NULL" +
                      " AND f.type_id=" + FilterType.MULTIPART +
                      " AND f.filter_id = oc.object_id" +
                      " AND f.usage_type_id=" + FilterUsageType.REGULAR +
                      " AND f.status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
                      " AND ISNULL(aprvl_status_flag,1) <> 0" + // Don't display Filters that are unapproved
                      " AND oc.type_id = " + ObjectType.FILTER +
                      " AND oc.cust_id = " + cust.s_cust_id +
                      " AND oc.category_id = " + sSelectedCategoryId + ")" +
                      ((sSelectedFilterId!=null)?" OR f.filter_id = " + sSelectedFilterId:"") +
                      " ORDER BY 1 DESC";
    }

    String sSeedId = "";
    String sSeedName = "";
    String sSeedDelete = "0";
    rs = stmt.executeQuery(sSql);
    JsonArray seed_arr = new JsonArray();
    while (rs.next()){
      JsonObject seed = new JsonObject();
      sSeedId = rs.getString(1);
      sSeedName = new String(rs.getBytes(2),"UTF-8");
      sSeedDelete = rs.getString(3);
      seed.put("sSeedId",sSeedId);
      seed.put("sSeedName",sSeedName);
      seed.put("sSeedDelete",sSeedDelete);
      seed_arr.put(seed);

    }
   // jsonResponse.put("seed_list_arr_st2_tab2",seed_arr);
    jsonResponse.put("seed_list_name",sSeedName);
    jsonResponse.put("linked_camp_id",linked_camp.s_linked_camp_id);
    rs.close();


    boolean nonEmailFinger = false;
    sSql =
            " SELECT attr_name" +
                    " FROM ccps_attribute a, ccps_cust_attr c " +
                    " WHERE a.attr_id = c.attr_id" +
                    " AND c.cust_id = " + cust.s_cust_id +
                    " AND fingerprint_seq IS NOT NULL";

    rs = stmt.executeQuery(sSql);
    while (rs.next()) {
      if (!rs.getString(1).equals("email_821")) {
        nonEmailFinger = true;
      }
    }
    jsonResponse.put("nonEmailFinger_st2_tab2", nonEmailFinger);

    rs.close();

    if(nonEmailFinger){
      jsonResponse.put("dublicate_email_address", "0".equals(camp_send_param.s_msg_per_email821_limit)?"":" checked");
    }

    CustFeature cs = new CustFeature();
    boolean bFeat = false;
    bFeat = cs.exists(user.s_cust_id, Feature.BRITE_TRACK);

    if (!isPrintCampaign){
      jsonResponse.put("link_append_text_st2_tab2",camp_send_param.s_link_append_text);
      jsonResponse.put("camp_code_st2_tab2",camp.s_camp_code);
    }
    /////////////////STEP_2_TAB_2 SON
    /////////////////STEP_2_TAB_3
    jsonResponse.put("exclusion_list",camp_list.s_exclusion_list_id);
    jsonResponse.put("camp_frequency_st2_tab3",camp_send_param.s_camp_frequency);
    jsonResponse.put("recip_qty_limit_st2_tab3",camp_send_param.s_recip_qty_limit);
    jsonResponse.put("randomly_st2_tab3", "0".equals(camp_send_param.s_randomly) ? "" : "checked");
    jsonResponse.put("limit_per_hour_st2_tab3",camp_send_param.s_limit_per_hour);

/////////////////STEP3
    CampSample camp_sample = null;
    String sSampleId = "";

// ********** JM
    CampApproveDAO cDAO = new CampApproveDAO();
    boolean bWasSent = false;
    boolean bIsApproved = false;
    String sActiveCampId = null;
    String sActiveCampIdMain = null;
    String sApproveRestart = null;
    String sCancelConfirm = null;

    String tabHeading = "";
    String tabQty = "";
    String sInTypes = "2,5,7";

    // added as a part of release 6.0 (New button added 'Set Done' similar action as cancel
    String sSetDoneConfirm = null;
    boolean bIsCancelled = false;

    jsonResponse.put("final_camp_flag",(camp_sampleset.s_final_camp_flag == null)?" style='display: none'":"");

    camp_sample = new CampSample();
    camp_sample.s_camp_id = camp.s_camp_id;
    camp_sample.s_sample_id = "0";
    camp_sample.s_from_name = msg_header.s_from_name;
    camp_sample.s_from_address = msg_header.s_from_address;
    camp_sample.s_from_address_id = msg_header.s_from_address_id;
    camp_sample.s_subject_html = msg_header.s_subject_html;
    camp_sample.s_subject_text = msg_header.s_subject_text;
    camp_sample.s_subject_aol = msg_header.s_subject_aol;
    camp_sample.s_cont_id = camp.s_cont_id;
    camp_sample.s_send_date = schedule.s_start_date;
    camp_sample.s_test_list_id = camp_list.s_test_list_id;

    int nRecipPct = (camp_sampleset.s_recip_percentage!=null)?Integer.parseInt(camp_sampleset.s_recip_percentage):0;
    nRecipPct = 100 - nRecipPct;
    int nRecipQty = (camp_sampleset.s_recip_qty!=null)?Integer.parseInt(camp_sampleset.s_recip_qty):0;
    int nFilterQty = (filter_statistic.s_recip_qty!=null)?Integer.parseInt(filter_statistic.s_recip_qty):0;
    nRecipQty = nFilterQty - nRecipQty;
    tabHeading = "Final";
    if (isDynamicCampaign)
    {
      tabQty = "";
    }
    else
    {
      tabQty = (nRecipPct < 100)?nRecipPct+"%":"";
    }
    tabQty += (nRecipQty <= 0)?"Remaining recipients":"";
    tabQty += ((nRecipQty < nFilterQty) && (nRecipQty > 0))?nRecipQty+" recipients":"";

    jsonResponse.put("campSample", new JsonObject()
            .put("campId_st3", camp_sample.s_camp_id)
            .put("sampleId_st3", camp_sample.s_sample_id)
            .put("fromName_st3", camp_sample.s_from_name)
            .put("from_address_st3", camp_sample.s_from_address)
            .put("fromAddressId_st3", camp_sample.s_from_address_id)
            .put("subjectHtml_st3", camp_sample.s_subject_html)
            .put("subjectText_st3", camp_sample.s_subject_text)
            .put("subjectAol_st3", camp_sample.s_subject_aol)
            .put("contentId_st3", camp_sample.s_cont_id)
            .put("sendDate_st3", camp_sample.s_send_date)
            .put("testListId_st3", camp_sample.s_test_list_id)
            .put("recipPct_st3", nRecipPct)
            .put("recipQty_st3", nRecipQty)
            .put("filterQty_st3", nFilterQty)
            .put("tabHeading_st3", tabHeading)
            .put("tabQty_st3", tabQty)
    );
///////////STEP_TAB_3 -->> STEP_3_TAB_1
    if (isDynamicCampaign && !tabHeading.equals("Final")){
      jsonResponse.put("logicBlockOptions_st3_tab1", getLogicBlockOptionsJson(stmt, cust.s_cust_id, camp_sample.s_filter_id, sSelectedCategoryId));

      if (!tabHeading.equals("Final")){
        if (camp_sampleset.s_camp_qty != null){
          int samplePriority = -1;
          try { samplePriority = Integer.parseInt(camp_sample.s_priority); }
          catch (Exception e) {};
          if (samplePriority == -1) {
            try { samplePriority = Integer.parseInt(sSampleId); }
            catch (Exception e) {};
          }
          int nMaxPriority = Integer.parseInt(camp_sampleset.s_camp_qty);
          JsonArray priorityOptions = new JsonArray();

          for (int p = 1; p <= nMaxPriority; p++) {
            JsonObject priorityOption = new JsonObject();
            priorityOption.put("value", p);
            priorityOption.put("selected", (samplePriority == p));
            priorityOptions.put(priorityOption);
          }

          jsonResponse.put("priorityOptions", priorityOptions);
        }
      }
    }
    if(!isPrintCampaign && camp_sampleset.s_from_name_flag != null){
      jsonResponse.put("camp_sample_from_name_st3_tab1",HtmlUtil.escape(camp_sample.s_from_name));
    }

    if(!isPrintCampaign && camp_sampleset.s_from_address_flag != null){
      jsonResponse.put("getFromAddressOptions_st3_tab1",getFromAddressOptionsJson(stmt, cust.s_cust_id,  camp_sample.s_from_address_id));
      jsonResponse.put("camp_sample_from_address_st3_tab1",HtmlUtil.escape(camp_sample.s_from_address));
    }

    if (camp_sampleset.s_subject_flag != null){
      String msg = "";
      String mes = camp_sample.s_subject_html;
      StringBuilder sb = new StringBuilder();

      if (mes != null) {
        int len = mes.length();
        for (int r = 0; r < len; r++) {
          char ch = mes.charAt(r);
          int n = ch;
          if (Character.isWhitespace(ch) || Character.isLetterOrDigit(ch)) {
            sb.append(ch);
          } else {
            int c = Character.codePointAt(mes, r);
            if (!Integer.toHexString(c).startsWith("d")) {
              sb.append("&#x" + Integer.toHexString(c) + ";");
            } else {
              if (Integer.toHexString(c).equals("d6") || Integer.toHexString(c).equals("dc")) {
                sb.append("&#x" + Integer.toHexString(c) + ";");
              }
            }
          }
        }
        msg = sb.toString();
      }
      jsonResponse.put("msg_st3_tab1",HtmlUtil.escape(msg));
      if (!isPrintCampaign && camp_sampleset.s_cont_flag == null) {
        JsonObject scoreData = new JsonObject();
        scoreData.put("link_st3_tab1", "javascript:score_popup(document.all.cont_id[document.all.cont_id.selectedIndex].value," + (sSampleId.equals("") ? "''" : sSampleId) + ")");
        jsonResponse.put("score_link_st3_tab1", scoreData);
      }

    }
    if (isDynamicCampaign && camp_sampleset.s_reply_to_flag != null){
        jsonResponse.put("reply_to_st3_tab1",HtmlUtil.escape(camp_sample.s_reply_to));
    }
    if(camp_sampleset.s_cont_flag != null){
      jsonResponse.put("getContOptions_st3_tab1",getContOptionsJson(stmt, cust.s_cust_id, camp_sample.s_cont_id, sSelectedCategoryId, isPrintCampaign));
    }

    sInTypes = "2,5,7";

    if (!canSpecTest) sInTypes = "2";
    if (!isPrintCampaign){
      jsonResponse.put("getTestListOptions_st3_tab1",getTestListOptionsJson(stmt, cust.s_cust_id, camp_sample.s_test_list_id, sInTypes));
      jsonResponse.put("s_test_recip_qty_limit_st3_tab1",HtmlUtil.escape(camp_send_param.s_test_recip_qty_limit));
    }
    ////// STEP3_TAB_1 SONU -->> STEP3

    if (canApprove.bExecute && bWasFinalCampSent && !finalIsPending) {

      sActiveCampId = cDAO.getActiveCamp(camp.s_camp_id, null);
      sActiveCampIdMain = sActiveCampId;
      bIsApproved = cDAO.getApprovedStatus(sActiveCampId);
      Campaign campTmp = new Campaign(sActiveCampId);
      int iStatusId;
      if (campTmp == null || campTmp.s_status_id == null) {
        iStatusId = 0;
        jsonResponse.put("iStatusId_st3", iStatusId);
      } else {
        iStatusId = Integer.parseInt(campTmp.s_status_id);
        jsonResponse.put("iStatusId_st3", iStatusId);
      }
      bIsDone = (iStatusId >= 60);

      // added as a part of release 6.0 (New button added 'Set Done' similar action as cancel
      bIsCancelled = (iStatusId == 80);
      // release 6.0 end

      if (iStatusId <= 50) {
        //Campaign hasn't begun yet.
        sApproveRestart = "Approve";
        jsonResponse.put("sApproverestart_st3",sApproveRestart);
        sCancelConfirm = "You are cancelling a campaign that has not been sent to any recipients.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
        jsonResponse.put("sCancelconfirm_st3",sCancelConfirm);
        // added as a part of Release 6.0 (New button 'Set done' is added
        sSetDoneConfirm =
                "You are setting campaign to Done status and has not been sent to any recipients. To perform any edits to this campaign you will need to clone it first. " +
                        "Continue with Set Done?";
        jsonResponse.put("sSetDoneconfirm_st3",sSetDoneConfirm);
      } else {
        //Campaign is processing
        sApproveRestart = "Restart";
        jsonResponse.put("sApproverestart_st3",sApproveRestart);
        sCancelConfirm = "You are about to cancel this campaign.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
        jsonResponse.put("sCancelconfirm_st3",sCancelConfirm);
        // added as a part of Release 6.0 (New button 'Set done' is added
        sSetDoneConfirm =
                "You are setting campaign to Done status. To perform any edits to this campaign you will need to clone it first. " +
                        "Continue with Set Done?";
        jsonResponse.put("sSetDoneconfirm_st3",sSetDoneConfirm);
      }
      if (!bIsDone){
        if (bIsApproved){
          jsonResponse.put("active_camp_id_st3",sActiveCampId);
        }
      }else{
        jsonResponse.put("Status_st3",CampaignStatus.getDisplayName(iStatusId ));
      }
    }else{

    }
    if(camp_sampleset.s_camp_qty != null){
      int nSampleCount = Integer.parseInt(camp_sampleset.s_camp_qty);
      jsonResponse.put("nSampleCount_st3_s1",camp_sampleset.s_camp_qty);
      nRecipQty = (camp_sampleset.s_recip_qty!=null)?Integer.parseInt(camp_sampleset.s_recip_qty)/nSampleCount:0;
      nRecipPct = (camp_sampleset.s_recip_percentage!=null)?Integer.parseInt(camp_sampleset.s_recip_percentage)/nSampleCount:0;

      for(int i=1; i < nSampleCount + 1; i++){
        sSampleId = String.valueOf(i);
        camp_sample = new CampSample(camp.s_camp_id, sSampleId);

        jsonResponse.put("camp_sample_st3_s1",camp_sample);
        if (!isDynamicCampaign)
        {
          tabHeading = "Sample" + i;
          tabQty = (nRecipQty > 0)?nRecipQty+" recipients":"";
          tabQty += (nRecipPct > 0)?nRecipPct+"%":"";
          jsonResponse.put("tabHeading_st3_s1",tabHeading);
          jsonResponse.put("tabQty_st3_s1",tabQty);
        }
        else
        {
          tabHeading = "Campaign&nbsp;" + i;
          tabQty = (nRecipQty > 0)?nRecipQty+" recipients":"";
          tabQty += "";
          jsonResponse.put("tabHeading_st3_s1",tabHeading);
          jsonResponse.put("tabQty_st3_s1",tabQty);
        }
        jsonResponse.put("campSample "+i, new JsonObject()
                .put("campId_st3", camp_sample.s_camp_id)
                .put("sampleId_st3", camp_sample.s_sample_id)
                .put("fromName_st3", camp_sample.s_from_name)
                .put("from_address_st3", camp_sample.s_from_address)
                .put("fromAddressId_st3", camp_sample.s_from_address_id)
                .put("subjectHtml_st3", camp_sample.s_subject_html)
                .put("subjectText_st3", camp_sample.s_subject_text)
                .put("subjectAol_st3", camp_sample.s_subject_aol)
                .put("contentId_st3", camp_sample.s_cont_id)
                .put("sendDate_st3", camp_sample.s_send_date)
                .put("testListId_st3", camp_sample.s_test_list_id)
                .put("reply_to_st3",camp_sample.s_reply_to)
                .put("priority_st3",camp_sample.s_priority)
                .put("recipPct_st3", nRecipPct)
                .put("recipQty_st3", nRecipQty)
                .put("filterQty_st3", nFilterQty)
                .put("tabHeading_st3", tabHeading)
                .put("tabQty_st3", tabQty)
        );
        sActiveCampId = cDAO.getActiveCamp(camp.s_camp_id, String.valueOf(i));
        bWasSent = cDAO.getSentStatus(sActiveCampId);
        bIsApproved = cDAO.getApprovedStatus(sActiveCampId);
        Campaign campTmp = new Campaign(sActiveCampId);
        jsonResponse.put("bWasSent_st3_s1",bWasSent);
        jsonResponse.put("bIsApproved_st3_s1",bIsApproved);
        jsonResponse.put("campTmp_st3_s1",campTmp);
        int iStatusId;
        if (campTmp == null || campTmp.s_status_id == null) {
          iStatusId = 0;
          jsonResponse.put("iStatuSid_st3_s1", iStatusId);
        } else {
          iStatusId = Integer.parseInt(campTmp.s_status_id);
          jsonResponse.put("iStatusid_st3_s1", iStatusId);
        }
        bIsDone = (iStatusId >= 60);

///////////STEP_TAB_3 -->> STEP_3_TAB_1
        if (isDynamicCampaign && !tabHeading.equals("Final")){
          jsonResponse.put("logicBlockOptions_st3_tab11", getLogicBlockOptionsJson(stmt, cust.s_cust_id, camp_sample.s_filter_id, sSelectedCategoryId));

          if (!tabHeading.equals("Final")){
            if (camp_sampleset.s_camp_qty != null){
              int samplePriority = -1;
              try { samplePriority = Integer.parseInt(camp_sample.s_priority); }
              catch (Exception e) {};
              if (samplePriority == -1) {
                try { samplePriority = Integer.parseInt(sSampleId); }
                catch (Exception e) {};
              }
              int nMaxPriority = Integer.parseInt(camp_sampleset.s_camp_qty);
              JsonArray priorityOptions = new JsonArray();

              for (int p = 1; p <= nMaxPriority; p++) {
                JsonObject priorityOption = new JsonObject();
                priorityOption.put("value", p);
                priorityOption.put("selected", (samplePriority == p));
                priorityOptions.put(priorityOption);
              }

              jsonResponse.put("priorityOptions_st3_tab11", priorityOptions);
            }
          }
        }
        if(!isPrintCampaign && camp_sampleset.s_from_name_flag != null){
          jsonResponse.put("camp_sample_from_name_st3_tab11",HtmlUtil.escape(camp_sample.s_from_name));
        }

        if(!isPrintCampaign && camp_sampleset.s_from_address_flag != null){
          jsonResponse.put("getFromAddressOptions_st3_tab11",getFromAddressOptionsJson(stmt, cust.s_cust_id,  camp_sample.s_from_address_id));
          jsonResponse.put("camp_sample_from_address_st3_tab11",HtmlUtil.escape(camp_sample.s_from_address));
        }

        if (camp_sampleset.s_subject_flag != null){
          String msg = "";
          String mes = camp_sample.s_subject_html;
          StringBuilder sb = new StringBuilder();

          if (mes != null) {
            int len = mes.length();
            for (int r = 0; r < len; r++) {
              char ch = mes.charAt(r);
              int n = ch;
              if (Character.isWhitespace(ch) || Character.isLetterOrDigit(ch)) {
                sb.append(ch);
              } else {
                int c = Character.codePointAt(mes, r);
                if (!Integer.toHexString(c).startsWith("d")) {
                  sb.append("&#x" + Integer.toHexString(c) + ";");
                } else {
                  if (Integer.toHexString(c).equals("d6") || Integer.toHexString(c).equals("dc")) {
                    sb.append("&#x" + Integer.toHexString(c) + ";");
                  }
                }
              }
            }
            msg = sb.toString();
          }
          jsonResponse.put("msg_st3_tab11",HtmlUtil.escape(msg));
          if (!isPrintCampaign && camp_sampleset.s_cont_flag == null) {
            JsonObject scoreData = new JsonObject();
            scoreData.put("link_st3_tab11", "javascript:score_popup(document.all.cont_id[document.all.cont_id.selectedIndex].value," + (sSampleId.equals("") ? "''" : sSampleId) + ")");
            jsonResponse.put("score_link_st3_tab11", scoreData);
          }

        }
        if (isDynamicCampaign && camp_sampleset.s_reply_to_flag != null){
          jsonResponse.put("reply_to_st3_tab11",HtmlUtil.escape(camp_sample.s_reply_to));
        }
        if(camp_sampleset.s_cont_flag != null){
          jsonResponse.put("getContOptions_st3_tab11",getContOptionsJson(stmt, cust.s_cust_id, camp_sample.s_cont_id, sSelectedCategoryId, isPrintCampaign));
        }

        sInTypes = "2,5,7";

        if (!canSpecTest) sInTypes = "2";
        if (!isPrintCampaign){
          jsonResponse.put("getTestListOptions_st3_tab11",getTestListOptionsJson(stmt, cust.s_cust_id, camp_sample.s_test_list_id, sInTypes));
          jsonResponse.put("s_test_recip_qty_limit_st3_tab11",HtmlUtil.escape(camp_send_param.s_test_recip_qty_limit));
        }
        ////// STEP3_TAB_1 SONU -->> STEP3

        if (canApprove.bExecute && bWasSamplesetSent && !samplesArePending){
          if (iStatusId <= 50)
          {
            //Campaign hasn't begun yet.
            sApproveRestart = "Approve";
            jsonResponse.put("sApproveRestart_st3_s11",sApproveRestart);
            sCancelConfirm = "You are cancelling a campaign that has not been sent to any recipients.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
            jsonResponse.put("sCancelConfirm_st3_s11",sCancelConfirm);
            //Added as a part of release 6.0,
            sSetDoneConfirm = "You are setting campaign to Done status that has not been sent to any recipients.  To perform any edits to this campaign you will need to clone it first.  Continue with Set Done?";
            jsonResponse.put("sSetDoneConfirm_st3_s11",sSetDoneConfirm);
          }
          else
          {
            //Campaign is processing
            sApproveRestart = "Restart";
            jsonResponse.put("sApproveRestart_st3_s11",sApproveRestart);
            sCancelConfirm = "You are about to cancel this campaign.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
            jsonResponse.put("sCancelConfirm_st3_s11",sCancelConfirm);
            //Added as a part of release 6.0,
            sSetDoneConfirm = "You are setting campaign to Done status. To perform any edits to this campaign you will need to clone it first.  Continue with Set Done?";
            jsonResponse.put("sSetDoneConfirm_st3_s11",sSetDoneConfirm);
          }
          if (bWasSent && !bIsDone){
            if (!(isPrintCampaign && (iStatusId == CampaignStatus.BEING_PROCESSED))){
              if (bIsApproved){

              }
            }
          }else{
            jsonResponse.put("status_st3_s11",CampaignStatus.getDisplayName(iStatusId ));
          }
        }

      }
    }
      ////STEP_3_B
    String sCalcCampID = null;
    rs = stmt.executeQuery("SELECT max(camp_id) FROM cque_campaign"
            + " WHERE type_id = "+CampaignType.TEST
            + " AND status_id = "+CampaignStatus.DONE
            + " AND mode_id = "+CampaignMode.CALC_ONLY
            + " AND origin_camp_id = "+camp.s_camp_id);
// while dönecez
    if (rs.next()) sCalcCampID = rs.getString(1);
    jsonResponse.put("sCalcCampID_st3_b",sCalcCampID);
    rs.close();
    if ((!bIsDone && !isSending && !isTesting && !isPrintCampaign) || (sCalcCampID != null)){
      if (sCalcCampID != null){
        String sCalcDate = null;
        rs = stmt.executeQuery("SELECT convert(varchar(255), finish_date, 100) FROM cque_camp_statistic WHERE camp_id = "+sCalcCampID);
        if (rs.next()) sCalcDate = rs.getString(1);
        jsonResponse.put("last_calculation_date_st3_b",sCalcDate);
        rs.close();

        CampStatDetails csds = new CampStatDetails();
        csds.s_camp_id = sCalcCampID;
        csds.retrieve();
      }
    }
    ////STEP_3_B SONNNN

      if(bIsCancelled){
        jsonResponse.put("sSetDoneConfirm",sSetDoneConfirm);
        jsonResponse.put("sActiveCampIdMain",sActiveCampIdMain);
      }

    //////// STEP_3 SONU

    //////// STEP_3_MAPP
    String sExportName = null;
    String sFileUrl = null;
    String sDelimiter = null;
    rs = stmt.executeQuery(	"select export_name, delimiter, file_url FROM cque_camp_export WHERE camp_id = " + camp.s_camp_id);
    if  (rs.next()) {
      sExportName = rs.getString(1);
      sDelimiter = rs.getString(2);
      sFileUrl = rs.getString(3);
    }
    if (sDelimiter == null || sDelimiter.equals("")) {
      sDelimiter = "\\t";
    }
    rs.close();
    jsonResponse.put("exportName", sExportName);
    jsonResponse.put("delimiter", sDelimiter);
    jsonResponse.put("fileUrl", sFileUrl);

    if (sFileUrl != null && sFileUrl.length() > 0){
      rs = stmt.executeQuery("SELECT export_name, file_url " +
              "  FROM cque_camp_export " +
              " WHERE camp_id in (SELECT camp_id " +
              "                     FROM cque_campaign " +
              "                    WHERE origin_camp_id = " + camp.s_camp_id +
              "                  )");
      JsonArray arr = new JsonArray();
      while (rs.next()){
        JsonObject obj = new JsonObject();
        String sampleName = rs.getString(1);
        String sampleUrl = rs.getString(2);
        obj.put("sampleName",sampleName);
        obj.put("sampleUrl",sampleUrl);
        arr.put(obj);
      }
      jsonResponse.put("file_Url_st3_map",arr);
      rs.close();
    }else{
      jsonResponse.put("export_name_st3_map",(sExportName!=null)?sExportName:"");
    }

    int i,j;
    String p1,p2,p3, pp;
    i = 0;
    j = 0;

    String selectedAttrList = new String(":");
    rs = stmt.executeQuery("SELECT attr_id " +
            "  FROM cque_camp_export_attr a" +
            " WHERE a.camp_id = " + camp.s_camp_id);
    JsonArray arr22 = new JsonArray();
    while( rs.next() ) {
      JsonObject oobb = new JsonObject();
      selectedAttrList += rs.getString(1) + ":";
      oobb.put("attr_listtt",selectedAttrList);
      arr22.put(oobb);

    }
    jsonResponse.put("selectedAttrList_st3_map",arr22);
    rs.close();

    String fingerprint = "isnull(c.fingerprint_seq,0)";
    if (isPrintCampaign) {
      fingerprint = "0"; // the fingerprint is not required for print campaigns
     // jsonResponse.put("fingerprint_st3_map",fingerprint);
    }

    rs = stmt.executeQuery("SELECT c.display_name, c.attr_id, " + fingerprint +
            "  FROM ccps_cust_attr c " +
            " WHERE c.cust_id = " + cust.s_cust_id +
            " ORDER BY ISNULL(c.display_seq,9999)");
    JsonArray arr2 = new JsonArray();
    while (rs.next()){
      p1 = new String(rs.getBytes(1), "ISO-8859-1");
      p2 = rs.getString(2);
      p3 = rs.getString(3);
      pp = new String(":" + p2 + ":");
      JsonObject obj2 = new JsonObject();
      obj2.put("p1",p1);
      obj2.put("p2",p2);
      obj2.put("p3",p3);
      obj2.put("pp",pp);
      arr2.put(obj2);
    }
    jsonResponse.put("fingerPrint_st3_map",arr2);
    //////// STEP_3_MAPP SONNNN

    //////// STEP_4_TAB_1
    if(camp_sampleset.s_send_date_flag == null){
      boolean bNowChecked = true;
      boolean bSpecificChecked = false;

      bNowChecked = (schedule.s_start_date==null);
      bSpecificChecked = (schedule.s_start_date!=null);
      jsonResponse.put("bNowChecked_st4_tab1",bNowChecked);
      jsonResponse.put("bSpecificChecked_st4_tab1",bSpecificChecked);

      jsonResponse.put("start_date_switch_now_st4_tab1",((bNowChecked)?" checked":""));
      jsonResponse.put("start_date_switch_specified_st4_tab1",((bSpecificChecked)?" checked":""));
      jsonResponse.put("send_start_date_st4_tab1",schedule.s_start_date);
    }

    if(can.bExecute){
      if((!bWasFinalCampSent) && (!bWasSamplesetSent) && (!isSending) && (!isTesting)){
        jsonResponse.put("send_st4_tab1",(isDynamicCampaign?"DYNAMIC CAMPAIGNS":"SAMPLESET"));
      }
      if((camp_sampleset.s_final_camp_flag != null)&&(!bWasFinalCampSent)){

      }
    }
    //////// STEP_4_TAB_1 SONNNN

    //////// STEP_4_TAB_2
    jsonResponse.put("queue_date_switch_now_st4_tab2",((camp_send_param.s_queue_date==null)?" checked":""));
    jsonResponse.put("queue_date_switch_specified_st4_tab2",((camp_send_param.s_queue_date!=null)?" checked":""));
    jsonResponse.put("queue_start_date_st4_tab2",camp_send_param.s_queue_date);
    //////// STEP_4_TAB_2 SONNN

    //////// STEP_5_TAB_1
    if( camp.s_camp_id != null ){
      int nCampId = 0;
      int nSampleId = 0;
      String sCampName = null;
      String sTypeId = null;
      String sTypeDisplayName = null;
      nStatusId = 0;
      String sStatusDisplayName = null;
      String sApprovalFlag = null;
      String sStartDate = null;
      String sFinishDate = null;
      String sRecpTotalQty = null;
      String sRecpQueuedQty = null;
      String sRecpSendQty = null;
      String sCreateDate = null;

      boolean hasHistory = false;
      boolean hasSamples = false;
      String sampleQueueId = "";

      CampStatDetails csds = null;

      sSql =
              " SELECT" +
                      " c.camp_id," +
                      " c.camp_name, " +
                      " t.type_id, " +
                      " t.display_name," +
                      " a.status_id," +
                      " a.display_name," +
                      " c.approval_flag," +
                      " CONVERT(varchar(32),s.start_date,100)," +
                      " CONVERT(varchar(32),s.finish_date,100)," +
                      " s.recip_total_qty," +
                      " s.recip_queued_qty," +
                      " s.recip_sent_qty," +
                      " CONVERT(varchar(32),e.create_date,100)," +
                      " ISNULL(c.sample_id,0)" +
                      " FROM cque_campaign c WITH(NOLOCK)" +
                      " LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)" +
                      " ON c.camp_id = s.camp_id " +
                      " LEFT OUTER JOIN cque_camp_edit_info e WITH(NOLOCK)" +
                      " ON c.camp_id = e.camp_id " +
                      " INNER JOIN cque_camp_type t WITH(NOLOCK)" +
                      " ON c.type_id = t.type_id " +
                      " INNER JOIN cque_camp_status a WITH(NOLOCK)" +
                      " ON c.status_id = a.status_id " +
                      " WHERE c.type_id != 1" +
                      " AND c.origin_camp_id = " + camp.s_camp_id +
                      " ORDER BY e.create_date DESC";

      rs = stmt.executeQuery(sSql);
      byte[] b = null;
      JsonArray jsonArray = new JsonArray();
      while (rs.next()){
        nCampId = rs.getInt(1);

        b = rs.getBytes(2);
        sCampName = (b==null)?null:new String(b, "UTF-8");

        sTypeId = rs.getString(3);
        sTypeDisplayName = rs.getString(4);
        nStatusId = rs.getInt(5);
        sStatusDisplayName = rs.getString(6);
        sApprovalFlag = rs.getString(7);
        sStartDate = rs.getString(8);
        sFinishDate = rs.getString(9);
        sRecpTotalQty = rs.getString(10);
        sRecpQueuedQty = rs.getString(11);
        sRecpSendQty = rs.getString(12);
        sCreateDate = rs.getString(13);
        nSampleId = rs.getInt(14);

        if("1".equals(sTypeId)) sCampName += " (Test)";
        if (!(nSampleId == 0)) hasSamples = true;
        if (!isPrintCampaign){
          csds = new CampStatDetails();
          csds.s_camp_id = String.valueOf(nCampId);
          csds.retrieve();
          if (csds.size() != 0){
            sampleQueueId = String.valueOf(nCampId);
            jsonResponse.put("sample_queue_id",sampleQueueId);
            if (nSampleId == 0){
              jsonResponse.put("details",(nCampId+" queue"));
            }
          }
        }

        JsonObject jsonObject = new JsonObject();
        jsonObject.put("camp_Idd_st5_tab1", nCampId);
        jsonObject.put("camp_name_st5_tab1", sCampName);
        jsonObject.put("type_id_st5_tab1", sTypeId);
        jsonObject.put("type_display_name_st5_tab1", sTypeDisplayName);
        jsonObject.put("status_id_st5_tab1", nStatusId);
        jsonObject.put("status_display_name_st5_tab1", sStatusDisplayName);
        jsonObject.put("approval_flag_st5_tab1", sApprovalFlag);
        jsonObject.put("start_date_st5_tab1", sStartDate);
        jsonObject.put("finish_date_st5_tab1", sFinishDate);
        jsonObject.put("recp_total_qty_st5_tab1", sRecpTotalQty);
        jsonObject.put("recp_queued_qty_st5_tab1", sRecpQueuedQty);
        jsonObject.put("recp_sent_qty_st5_tab1", sRecpSendQty);
        jsonObject.put("create_date_st5_tab1", sCreateDate);
        jsonObject.put("sample_id_st5_tab1", nSampleId);
        jsonObject.put("hasSamples_st5_tab1",hasSamples);
        jsonArray.put(jsonObject);

        hasHistory = true;
      }

      jsonResponse.put("st5_tab1_arr",jsonArray);
      rs.close();
      if (hasSamples == true){
        if (!isPrintCampaign){
          jsonResponse.put("dynamic_camp_st5_tab1",(isDynamicCampaign?"Dynamic Campaigns ":"Sample Set "));
          csds = new CampStatDetails();
          csds.s_camp_id = sampleQueueId;
          csds.retrieve();
          if (csds.size() != 0){
            jsonResponse.put("details",(nCampId+" queue"));
          }
        }
      }

    }
    //////// STEP_5_TAB_1 SONN
    //////// STEP_5_TAB_2
    if( camp.s_camp_id != null ){
      int nCampId = 0;
      String sCampName = null;
      String sTypeId = null;
      String sTypeDisplayName = null;
      nStatusId = 0;
      String sStatusDisplayName = null;
      String sApprovalFlag = null;
      String sStartDate = null;
      String sFinishDate = null;
      String sRecpTotalQty = null;
      String sRecpQueuedQty = null;
      String sRecpSendQty = null;
      String sCreateDate = null;

      boolean hasHistory = false;
      sSql =
              " SELECT" +
                      " c.camp_id," +
                      " c.camp_name, " +
                      " t.type_id, " +
                      " t.display_name," +
                      " a.status_id," +
                      " a.display_name," +
                      " c.approval_flag," +
                      " CONVERT(varchar(32),s.start_date,100)," +
                      " CONVERT(varchar(32),s.finish_date,100)," +
                      " s.recip_total_qty," +
                      " s.recip_queued_qty," +
                      " s.recip_sent_qty," +
                      " CONVERT(varchar(32),e.create_date,100)" +
                      " FROM cque_campaign c WITH(NOLOCK)" +
                      " LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)" +
                      " ON c.camp_id = s.camp_id " +
                      " LEFT OUTER JOIN cque_camp_edit_info e WITH(NOLOCK)" +
                      " ON c.camp_id = e.camp_id " +
                      " INNER JOIN cque_camp_type t WITH(NOLOCK)" +
                      " ON c.type_id = t.type_id " +
                      " INNER JOIN cque_camp_status a WITH(NOLOCK)" +
                      " ON c.status_id = a.status_id " +
                      " WHERE c.type_id = 1" +
                      " AND ISNULL(c.mode_id,0) != 20  " +
                      " AND c.origin_camp_id = " + camp.s_camp_id +
                      " ORDER BY e.create_date DESC";

      rs = stmt.executeQuery(sSql);
      byte[] b = null;
      JsonArray jsonArray = new JsonArray();
      while (rs.next()){
        nCampId = rs.getInt(1);

        b = rs.getBytes(2);
        sCampName = (b==null)?null:new String(b, "UTF-8");

        sTypeId = rs.getString(3);
        sTypeDisplayName = rs.getString(4);
        nStatusId = rs.getInt(5);
        sStatusDisplayName = rs.getString(6);
        sApprovalFlag = rs.getString(7);
        sStartDate = rs.getString(8);
        sFinishDate = rs.getString(9);
        sRecpTotalQty = rs.getString(10);
        sRecpQueuedQty = rs.getString(11);
        sRecpSendQty = rs.getString(12);
        sCreateDate = rs.getString(13);

        JsonObject jsonObject = new JsonObject();
        jsonObject.put("camp_id", nCampId);
        jsonObject.put("camp_name", sCampName);
        jsonObject.put("type_id", sTypeId);
        jsonObject.put("type_display_name", sTypeDisplayName);
        jsonObject.put("statusId", nStatusId);
        jsonObject.put("status_display_name", sStatusDisplayName);
        jsonObject.put("approval_flag", sApprovalFlag);
        jsonObject.put("start_date", sStartDate);
        jsonObject.put("finish_date", (nStatusId < CampaignStatus.DONE)?"":HtmlUtil.escape(sFinishDate));
        jsonObject.put("recp_total_qty", sRecpTotalQty);
        jsonObject.put("recp_queued_qty", sRecpQueuedQty);
        jsonObject.put("recp_sent_qty", sRecpSendQty);
        jsonObject.put("create_date", sCreateDate);


        jsonArray.put(jsonObject);
        hasHistory = true;
      }
      rs.close();
      jsonResponse.put("step5_tab2_arr",jsonArray);
    }
    //////// STEP_5_TAB_2

    //////// STEP_5_TAB_3
    jsonResponse.put("created_name_st5_tab3",(creator.s_user_name + " " + creator.s_last_name));
    jsonResponse.put("last_modified_st5_tab3",(modifier.s_user_name + " " + modifier.s_last_name));
    jsonResponse.put("creation_date_st5_tab3",(camp_edit_info.s_create_date));
    jsonResponse.put("last_modify_date_st5_tab3",(camp_edit_info.s_modify_date));
    //////// STEP_5_TAB_3 SON

    JsonArray responseArr = new JsonArray();
    responseArr.put(jsonResponse);
    out.println(responseArr.toString());






  }catch(Exception ex) { throw ex; }
  finally
  {
    if (stmt != null) stmt.close();
    if (conn != null) cp.free(conn);
  }
%>

<%!

  private static String buildCategoriesJson(Statement stmt, String CUST_ID, String CAMP_ID, String sSelectedCategoryId) throws Exception {
    JsonArray categoriesArray = new JsonArray();
    String sSql =
            " SELECT c.category_id, c.category_name, oc.object_id" +
                    " FROM ccps_category c" +
                    " LEFT OUTER JOIN ccps_object_category oc" +
                    " ON (c.category_id = oc.category_id" +
                    " AND c.cust_id = oc.cust_id" +
                    " AND oc.object_id = " + CAMP_ID +
                    " AND oc.type_id = " + ObjectType.CAMPAIGN + ")" +
                    " WHERE c.cust_id = " + CUST_ID;

    ResultSet rs = stmt.executeQuery(sSql);

    while (rs.next()) {
      String sCategoryId = rs.getString(1);
      String sCategoryName = new String(rs.getBytes(2), "UTF-8");
      String sObjectId = rs.getString(3);

      boolean isSelected = (sObjectId != null) || ((sSelectedCategoryId != null) && sSelectedCategoryId.equals(sCategoryId));

      JsonObject categoryJson = new JsonObject();
      categoryJson.put("id", sCategoryId);
      categoryJson.put("name", sCategoryName);
      categoryJson.put("selected", isSelected);

      categoriesArray.put(categoryJson);
    }
    rs.close();

    return categoriesArray.toString();
  }

  private static JsonArray getLogicBlockOptionsJson(Statement stmt, String sCustId, String sSelectedFilterId, String sSelectedCategoryId)
          throws Exception
  {
    JsonArray jsonArray = new JsonArray();

    String sSql = null;

    if ((sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")))
    {
      sSql =
              " SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
                      " CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
                      " FROM ctgt_filter" +
                      " WHERE cust_id = " + sCustId +
                      " AND origin_filter_id IS NULL" +
                      " AND filter_name IS NOT NULL" +
                      " AND type_id=" + FilterType.MULTIPART +
                      " AND usage_type_id=" + FilterUsageType.CONTENT +
                      " AND status_id <> " + FilterStatus.DELETED +
                      " AND ISNULL(aprvl_status_flag,1) <> 0" +
                      ((sSelectedFilterId != null) ? " OR filter_id = " + sSelectedFilterId : "") +
                      " ORDER BY 1 DESC";
    }
    else
    {
      sSql =
              " SELECT DISTINCT f.filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + f.filter_name ELSE f.filter_name END," +
                      " CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
                      " FROM ctgt_filter f, ccps_object_category oc" +
                      " WHERE (f.cust_id = " + sCustId +
                      " AND f.origin_filter_id IS NULL" +
                      " AND f.filter_name IS NOT NULL" +
                      " AND f.type_id=" + FilterType.MULTIPART +
                      " AND f.filter_id = oc.object_id" +
                      " AND f.usage_type_id=" + FilterUsageType.CONTENT +
                      " AND f.status_id <> " + FilterStatus.DELETED +
                      " AND ISNULL(aprvl_status_flag,1) <> 0" +
                      " AND oc.type_id = " + ObjectType.FILTER +
                      " AND oc.cust_id = " + sCustId +
                      " AND oc.category_id = " + sSelectedCategoryId + ")" +
                      ((sSelectedFilterId != null) ? " OR f.filter_id = " + sSelectedFilterId : "") +
                      " ORDER BY 1 DESC";
    }

    ResultSet rs = stmt.executeQuery(sSql);
    while (rs.next())
    {
      JsonObject jsonObject = new JsonObject();
      String sFilterId = rs.getString(1);
      String sFilterName = new String(rs.getBytes(2), "UTF-8");
      String sDeleted = rs.getString(3);
      jsonObject.put("filterId", sDeleted.equals("1") ? "" : sFilterId);
      jsonObject.put("filterName", sFilterName);
      jsonObject.put("selected", sFilterId.equals(sSelectedFilterId));
      jsonArray.put(jsonObject);
    }
    rs.close();
    return jsonArray;
  }

  private static JsonArray getFromAddressOptionsJson(Statement stmt, String sCustId, String sSelectedFromAddressId)
          throws Exception
  {
    JsonArray jsonArray = new JsonArray();

    String sSql =
            " SELECT from_address_id, prefix+'@'+[domain]" +
                    " FROM ccps_from_address" +
                    " WHERE cust_id = " + sCustId +
                    " ORDER BY from_address_id DESC";

    ResultSet rs = stmt.executeQuery(sSql);
    while (rs.next())
    {
      JsonObject jsonObject = new JsonObject();
      String sFromAddressId = rs.getString(1);
      String fromAddress = new String(rs.getBytes(2), "UTF-8");
      jsonObject.put("fromAddressId", sFromAddressId);
      jsonObject.put("fromAddress", fromAddress);
      jsonObject.put("selected", sFromAddressId.equals(sSelectedFromAddressId));
      jsonArray.put(jsonObject);
    }
    rs.close();
    return jsonArray;
  }

  private static JsonArray getContOptionsJson(Statement stmt, String sCustId, String sSelectedContId, String sSelectedCategoryId, boolean isPrintContent)
          throws Exception
  {
    JsonArray jsonArray = new JsonArray();

    String sSql = null;

    if ((sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")))
    {
      String sTypeCond = " AND type_id = 20 AND origin_cont_id IS NULL";
      if (isPrintContent) {
        sTypeCond = " AND type_id = 40 AND origin_cont_id IS NULL AND cti_doc_id IS NOT NULL";
      }
      sSql =
              " SELECT cont_id, cont_name" +
                      " FROM ccnt_content" +
                      " WHERE cust_id = " + sCustId +
                      " AND status_id = 20" +
                      sTypeCond +
                      ((sSelectedContId != null) ? " OR cont_id = " + sSelectedContId : "") +
                      " ORDER BY cont_id DESC";
    }
    else {
      String sTypeCond = " AND c.type_id = 20 AND c.origin_cont_id IS NULL";
      if (isPrintContent) {
        sTypeCond = " AND c.type_id = 40 AND c.origin_cont_id IS NULL AND c.cti_doc_id IS NOT NULL";
      }
      sSql =
              " SELECT DISTINCT c.cont_id, c.cont_name" +
                      " FROM ccnt_content c, ccps_object_category oc" +
                      " WHERE (c.cust_id = " + sCustId +
                      " AND c.status_id = 20" +
                      sTypeCond +
                      " AND c.cont_id = oc.object_id" +
                      " AND oc.type_id = " + ObjectType.CONTENT +
                      " AND oc.cust_id = " + sCustId +
                      " AND oc.category_id = " + sSelectedCategoryId + ")" +
                      ((sSelectedContId != null) ? " OR c.cont_id = " + sSelectedContId : "") +
                      " ORDER BY c.cont_id DESC";
    }

    ResultSet rs = stmt.executeQuery(sSql);
    while (rs.next())
    {
      JsonObject jsonObject = new JsonObject();
      String sContId = rs.getString(1);
      String contName = new String(rs.getBytes(2), "UTF-8");
      jsonObject.put("contId", sContId);
      jsonObject.put("contName", contName);
      jsonObject.put("selected", sContId.equals(sSelectedContId));
      jsonArray.put(jsonObject);
    }
    rs.close();
    return jsonArray;
  }

  private static JsonArray getTestListOptionsJson(Statement stmt, String sCustId, String sSelectedListId, String sInTypes)
          throws Exception
  {
    JsonArray jsonArray = new JsonArray();

    String sSql =
            "SELECT l.list_id, CASE l.status_id WHEN " + EmailListStatus.DELETED + " THEN '*Deleted* ' + l.list_name ELSE l.list_name END, " +
                    " t.type_name, l.status_id" +
                    "  FROM cque_email_list l, cque_list_type t " +
                    " WHERE l.type_id = t.type_id AND l.type_id in (" + sInTypes + ") " +
                    "   AND l.cust_id = '" + sCustId + "'" +
                    "   AND l.list_name not like 'ApprovalRequest(%)' " +
                    "   AND l.status_id = '" + EmailListStatus.ACTIVE + "'" +
                    " ORDER BY l.list_id DESC";

    ResultSet rs = stmt.executeQuery(sSql);
    while (rs.next())
    {
      JsonObject jsonObject = new JsonObject();
      String sTestListId = rs.getString(1);
      String sTestListName = new String(rs.getBytes(2), "UTF-8");
      String sTypeName = new String(rs.getBytes(3), "UTF-8");
      String sStatusID = rs.getString(4);
      int iStatusID = Integer.parseInt(sStatusID);

      jsonObject.put("testListId", iStatusID == EmailListStatus.DELETED ? "" : sTestListId);
      jsonObject.put("testListName", sTestListName);
      jsonObject.put("typeName", sTypeName);
      jsonObject.put("selected", sTestListId.equals(sSelectedListId));
      jsonArray.put(jsonObject);
    }
    rs.close();
    return jsonArray;
  }


%>