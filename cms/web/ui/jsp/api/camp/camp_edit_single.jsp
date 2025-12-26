<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.adm.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.wfl.*,
                java.io.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                java.text.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="java.nio.charset.Charset" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ include file="camp_edit/functions.jsp" %>
<%@ include file="camp_edit/calendar.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    //kullanıcının kampanyaları okuma yetkisi olup olmadığını kontrol eder. Eğer yetkisi yoksa, "Erişim Reddedildi" sayfasına yönlendirilir.
    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

    // **********JM
    AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);
    CampApproveDAO cDAO = new CampApproveDAO();
    String sActiveCampId = null;
    boolean bWasSent = false;
    boolean bIsApproved = false;
    // ********** JM

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
    AccessPermission canUserPvDesignOptimizer = user.getAccessPermission(ObjectType.PV_DESIGN_OPTIMIZER);
    AccessPermission canUserPvContentScorer = user.getAccessPermission(ObjectType.PV_CONTENT_SCORER);
    AccessPermission canUserPvDeliveryTracker = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);
    boolean canPvDesignOptimizer = ui.getFeatureAccess(Feature.PV_DESIGN_OPTIMIZER);
    boolean canPvContentScorer = ui.getFeatureAccess(Feature.PV_CONTENT_SCORER);
    boolean canPvDeliveryTracker = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);


    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

    String sAutoQueueDailyFlag = request.getParameter("auto_queue_daily_flag");

    String sCampId = request.getParameter("camp_id");
    String sCampType = request.getParameter("type_id");
    String sMediaType = request.getParameter("media_type_id");

    String sAprvlRequestId = request.getParameter("aprvl_request_id");
    if (sAprvlRequestId == null)
        sAprvlRequestId = "";

    // === === ===

    Campaign camp = new Campaign();

    CampEditInfo camp_edit_info = null;
    CampList camp_list = null;
    CampSendParam camp_send_param = null;
    MsgHeader msg_header = null;
    Schedule schedule = null;
    LinkedCamp linked_camp = null;

    User creator = null;
    User modifier = null;

    if (sCampId == null) {
        if (sCampType == null) throw new Exception("Undefined campaign type ...");

        camp.s_type_id = sCampType;
        camp.s_media_type_id = sMediaType;

        camp_send_param = new CampSendParam();

        if ("1".equals(sAutoQueueDailyFlag))
            camp_send_param.s_queue_daily_flag = "1";

        schedule = new Schedule();
        msg_header = new MsgHeader();
        camp_list = new CampList();
        camp_edit_info = new CampEditInfo();
        linked_camp = new LinkedCamp();

        creator = user;
        modifier = user;

        // === === ===

        // DnB default frequency
        // if (cust.s_cust_id.equals("32") || cust.s_cust_id.equals("33")) // FOR TESTING ONLY
        if (cust.s_cust_id.equals("20") || cust.s_cust_id.equals("36")) // FOR PRODUCTION
        {
            if (camp.s_type_id.equals("2")) camp_send_param.s_camp_frequency = "15";
        }
    } else {
        camp = new Campaign();
        camp.s_camp_id = sCampId;
        if (camp.retrieve() < 1) throw new Exception("Campaign does not exist");

        camp_send_param = new CampSendParam(sCampId);
        schedule = new Schedule(sCampId);
        msg_header = new MsgHeader(sCampId);
        camp_list = new CampList(sCampId);
        camp_edit_info = new CampEditInfo(sCampId);
        linked_camp = new LinkedCamp(sCampId);

        creator = new User(camp_edit_info.s_creator_id);
        modifier = new User(camp_edit_info.s_modifier_id);
    }

    // === SET DEFAULTS ===

    if (camp.s_camp_name == null) camp.s_camp_name = "New campaign";
    if (camp.s_status_id == null) camp.s_status_id = String.valueOf(CampaignStatus.DRAFT);

    if (camp_send_param.s_recip_qty_limit == null) camp_send_param.s_recip_qty_limit = "0";
    if (camp_send_param.s_randomly == null) camp_send_param.s_randomly = "0";
    if (camp_send_param.s_delay == null) camp_send_param.s_delay = "0";
    if (camp_send_param.s_limit_per_hour == null) camp_send_param.s_limit_per_hour = "0";
    if (camp_send_param.s_msg_per_email821_limit == null) camp_send_param.s_msg_per_email821_limit = "0";
    if (camp_send_param.s_msg_per_recip_limit != null) camp_send_param.s_msg_per_recip_limit = "1";
    if (camp_send_param.s_queue_daily_weekday_mask == null) camp_send_param.s_queue_daily_weekday_mask = "127";

    if (schedule.s_start_daily_weekday_mask == null) schedule.s_start_daily_weekday_mask = "127";


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

    // === === ===

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("camp_edit.jsp");
        stmt = conn.createStatement();

        String sSql = null;

        // === === ===

        boolean isDone = false;
        boolean isTesting = false;
        boolean isSending = false;

        /* for workflow processing */
        boolean isPending = false;
        boolean isPendingEdits = false;
        boolean isApprover = false;
        ApprovalRequest arRequest = null;
        if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
            arRequest = new ApprovalRequest(sAprvlRequestId);
        } else {
            arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.CAMPAIGN), camp.s_camp_id);
        }
        if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
            sAprvlRequestId = arRequest.s_approval_request_id;
            isApprover = true;
        }
        /* *** */

        int tmpType = 0;
        int tmpStatus = 0;
        int tmpMode = 0;
        String StatusCampID = null;
        String SendCampApproved = "0";

        if (camp.s_camp_id != null) {
            //Find out what state this campaign is in based on camps with origin_camp_id
            sSql = "EXEC usp_cque_camp_get_status_single " + camp.s_camp_id;

            rs = stmt.executeQuery(sSql);
            while (rs.next()) {
                tmpType = rs.getInt(1);
                tmpStatus = rs.getInt(2);
                StatusCampID = rs.getString(3);
                SendCampApproved = rs.getString(4);
                tmpMode = rs.getInt(5);

                if (tmpType == 1) {
                    //Test, see if it is in the middle of testing
                    if (tmpStatus < CampaignStatus.DONE) {
                        isTesting = true;
                    } else {
                        tmpStatus = CampaignStatus.DRAFT;
                    }
                } else {
                    //Normal campaign
                    camp.s_status_id = String.valueOf(tmpStatus);
                    if (tmpStatus == CampaignStatus.DRAFT) {
                        //nothing
                    } else if (tmpStatus == CampaignStatus.PENDING_APPROVAL) {
                        isPending = true;
                    } else if (tmpStatus == CampaignStatus.PENDING_EDITS) {
                        isPendingEdits = true;
                    } else if (tmpStatus < CampaignStatus.DONE || tmpStatus == CampaignStatus.CANCELLED) {
                        isSending = true;
                    } else {
                        isDone = true;
                    }
                }

            }
            jsonObject.put("tmpType", tmpType);
            jsonObject.put("tmpStatus", tmpStatus);
            jsonObject.put("StatusCampID", StatusCampID);
            jsonObject.put("SendCampApproved", SendCampApproved);
            jsonObject.put("tmpMode", tmpMode);
			jsonObject.put("isSending",isSending);
            rs.close();

            isPendingEdits = (WorkflowUtil.getPendingEditsCampId(cust.s_cust_id, camp.s_camp_id, camp.s_sample_id) != null);
        }


        int editCampId = 0;
        //if( !isDone && isSending && !isTesting && cust.s_cust_id.equals("158"))
        if (!isDone && isSending && !isTesting) {
            String zSql = "SELECT " +
                    " c.camp_id " +
                    " FROM cque_campaign c WITH(NOLOCK)" +
                    " LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)" +
                    " ON c.camp_id = s.camp_id " +
                    " INNER JOIN cque_camp_edit_info e WITH(NOLOCK)" +
                    " ON c.camp_id = e.camp_id " +
                    " INNER JOIN cque_camp_type t WITH(NOLOCK)" +
                    " ON c.type_id = t.type_id " +
                    " INNER JOIN cque_camp_status a WITH(NOLOCK)" +
                    " ON c.status_id = a.status_id " +
                    " WHERE cust_id =" + cust.s_cust_id + " " +
                    " AND (c.type_id = " + camp.s_type_id + ") " +
                    " AND c.origin_camp_id = " + camp.s_camp_id + " " +
                    " ORDER BY modify_date DESC";

            rs = stmt.executeQuery(zSql);

            while (rs.next()) {
                editCampId = rs.getInt(1);
            }
            jsonObject.put("editCampId", editCampId);
            rs.close();
        }

        ///////////////////////////////////////////////////tab_1///////////////////////////////////////////////////
        jsonObject.put("campaignName", camp.s_camp_name);
        if (camp.s_type_id.equals("5")) {


        } else {
            if (isPrintCampaign) {

            } else {

                if (!STANDARD_UI && !isPrintCampaign) {


                    if (!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0"))) {
                        //  jsonObject.put("category", sSelectedCategoryId);
                    }
                    if (isDone && can.bWrite) {


                    }
                }
                jsonObject.put("fromName", msg_header.s_from_name);
                jsonObject.put("fromAdress", msg_header.s_from_address_id);
                jsonObject.put("fromAdressManuel", msg_header.s_from_address == null ? "" : msg_header.s_from_address);
                String msg = "";
                String mes = msg_header.s_subject_html;
                byte[] bytesSubject = mes.getBytes(StandardCharsets.UTF_8);
                String newSubject = new String(bytesSubject,StandardCharsets.UTF_8);
                jsonObject.put("Subject", newSubject);
                StringBuilder sw = new StringBuilder();
                StringBuilder sb = new StringBuilder();

                if (mes != null) {
                    char ch = 0;
                    int n = 0;
                    int len = mes.length();
                    for (int i = 0; i < len; i++) {
                        ch = mes.charAt(i);
                        n = ch;
                        if
                        (
                                (n == 32)
                                        ||
                                        ((n >= 48) && (n <= 57))
                                        ||
                                        ((n >= 65) && (n <= 90))
                                        ||
                                        ((n >= 97) && (n <= 122))
                        ) sb.append(ch);
                        else {
                            //sw.append("&#" + (int)ch + ";");
                            int c = mes.codePointAt(i);
                            if (!(Integer.toHexString(c).startsWith("d"))) {
                                sb.append("&#x" + Integer.toHexString(c) + ";");
                                // System.out.println(i+" "+"&#x"+Integer.toHexString(c)+";"+ch);
                            } else {
                                if (Integer.toHexString(c).equals("d6") || Integer.toHexString(c).equals("dc")) {
                                    sb.append("&#x" + Integer.toHexString(c) + ";");

                                }
                            }
                        }
                    }
                    msg = sb.toString();
                } else {
                    msg = "";
                }
//                byte[] bytesSubject = msg.getBytes(StandardCharsets.ISO_8859_1);
//                String newSubject = new String(bytesSubject,StandardCharsets.UTF_8);
//                jsonObject.put("Subject", newSubject);

            }
            jsonObject.put("Content", camp.s_cont_id);
            if (camp.s_type_id.equals("3")) {
                sSql =
                        " SELECT form_id, form_name" +
                                " FROM csbs_form" +
                                " WHERE cust_id = " + cust.s_cust_id +
                                " AND type_id = 3 ORDER BY form_id";
                String sFormId = null;
                String sFormName = null;
                rs = stmt.executeQuery(sSql);
                while (rs.next()) {
                    sFormId = rs.getString(1);
                    sFormName = new String(rs.getBytes(2), "UTF-8");
                }
                jsonObject.put("form_id", sFormId);
                jsonObject.put("form_name", sFormName);
                rs.close();
            }
        }

        jsonObject.put("targetGroup", camp.s_filter_id);

        if (!camp.s_type_id.equals("5") || !isPrintCampaign) {
            jsonObject.put("responseForwarding", camp_send_param.s_response_frwd_addr);
        }

        if (camp.s_type_id.equals("4")) {
            if (isPrintCampaign) {

            } else {

                sSql =
                        " SELECT list_id, CASE status_id WHEN " + EmailListStatus.DELETED + " THEN '*Deleted* ' + list_name ELSE list_name END, " +
                                " status_id, type_id" +
                                " FROM cque_email_list " +
                                " WHERE type_id IN (4,6)" +
                                " AND cust_id =" + cust.s_cust_id +
                                " AND (status_id = '" + EmailListStatus.ACTIVE + "'" +
                                ((camp_list.s_auto_respond_list_id != null) ? " OR list_id = " + camp_list.s_auto_respond_list_id : "") +
                                ") ORDER BY list_id DESC";
                String sArListId = null;
                String sArListName = null;
                String sStatusID = null;
                String sTypeID = null;
                int iStatusID = 0;

                rs = stmt.executeQuery(sSql);

                while (rs.next()) {
                    sArListId = rs.getString(1);
                    sArListName = new String(rs.getBytes(2), "UTF-8");
                    sStatusID = rs.getString(3);
                    sTypeID = rs.getString(4);

                    iStatusID = Integer.parseInt(sStatusID);

                }
                jsonObject.put("sArListId", sArListId);
                jsonObject.put("sArListName", sArListName);
                jsonObject.put("sStatusID", sStatusID);
                jsonObject.put("sTypeID", sTypeID);

                rs.close();
                ///////////////////////////////////
                sSql =
                        " SELECT email_type_id, email_type_name" +
                                " FROM ccps_email_type WHERE email_type_id <> 0";
                String email_type_id = null;
                String email_type_name = null;

                rs = stmt.executeQuery(sSql);
                while (rs.next()) {
                    email_type_id = rs.getString(1);
                    email_type_name = new String(rs.getBytes(2), "UTF-8");
                }
                jsonObject.put("email_type_id", email_type_id);
                jsonObject.put("email_type_name", email_type_name);

                rs.close();
                //////////////////////////////////
                sSql =
                        " SELECT attr_id, display_name " +
                                " FROM ccps_cust_attr" +
                                " WHERE cust_id = " + cust.s_cust_id +
                                " AND display_seq IS NOT NULL " +
                                " ORDER BY display_seq";
                String sArAttrId = null;
                String sArDisplayName = null;
                rs = stmt.executeQuery(sSql);
                while (rs.next()) {
                    sArAttrId = rs.getString(1);
                    sArDisplayName = new String(rs.getBytes(2), "UTF-8");
                }
                jsonObject.put("sArAttrId", sArAttrId);
                jsonObject.put("sArDisplayName", sArDisplayName);

                rs.close();
            }
        }
        jsonObject.put("replyTo", msg_header.s_reply_to);

        ////////////////////////////

        if (!STANDARD_UI && !isPrintCampaign) {


            if (!camp.s_type_id.equals("3")) { //Seed List won't work with S2F since only sends to friend recips

                jsonObject.put("seedList", camp.s_seed_list_id);

            }

            if (camp.s_type_id.equals("2")) {

                jsonObject.put("linkToSendFriend", linked_camp.s_linked_camp_id);
            }

            if (camp.s_type_id.equals("4")) {


            }

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
            jsonObject.put("nonEmailFinger", nonEmailFinger);

            rs.close();

            CustFeature cs = new CustFeature();
            boolean bHyatt = false;
            bHyatt = cs.exists(user.s_cust_id, Feature.HYATT);
            if (nonEmailFinger) {
                if (!bHyatt) {

                } else {

                }
            }

            boolean bFeat = false;
            bFeat = cs.exists(user.s_cust_id, Feature.BRITE_TRACK);

            if (!isPrintCampaign) {

                jsonObject.put("textToAppend", camp_send_param.s_link_append_text);
                jsonObject.put("campaignCode", camp.s_camp_code);

            }
        }

        if (canStep3) {
            jsonObject.put("exclusionList", camp_list.s_exclusion_list_id);

            if (!camp.s_type_id.equals("3")) {
                jsonObject.put("excludeRecipients", (camp_send_param.s_camp_frequency == null ? "" : camp_send_param.s_camp_frequency));

            }

            if (camp.s_type_id.equals("2")) {
                jsonObject.put("subsetSendout", camp_send_param.s_recip_qty_limit);
                jsonObject.put("randomly", "0".equals(camp_send_param.s_randomly) ? "" : "checked");

            }
        }
        ///////////////////////////////////////////////////tab_1///////////////////////////////////////////////////////

        ///////////////////////////////////////////////////tab_2///////////////////////////////////////////////////////
        if (!camp.s_type_id.equals("5") && !isPrintCampaign) {
            String sInTypes = "2,5,7";
            String sDeliverabilityInTypes = "10,11,12,13";
            if (!canSpecTest) sInTypes = "2";
            jsonObject.put("sInTypes", sInTypes);
            jsonObject.put("testingList", camp_list.s_test_list_id);

            if (!isDone && ((canPvDesignOptimizer && canUserPvDesignOptimizer.bExecute) ||
                    (canPvContentScorer && canUserPvContentScorer.bExecute) ||
                    (canPvDeliveryTracker && canUserPvDeliveryTracker.bExecute))) {

                if (!isDone && !isPending && can.bExecute && (!isPendingEdits || (isPendingEdits && isApprover))) {

                    if (canPvDesignOptimizer && canUserPvDesignOptimizer.bExecute) {
                        jsonObject.put("deliveryTracker", "javascript:pv_tracker_popup(FT.cont_id[FT.cont_id.selectedIndex].value)");
                    }
                    if (canPvContentScorer && canUserPvContentScorer.bExecute) {
                        jsonObject.put("eContentScorer", "javascript:pv_scorer_popup(FT.cont_id[FT.cont_id.selectedIndex].value)");
                    }
                    if (canPvDeliveryTracker && canUserPvDeliveryTracker.bExecute) {
                        jsonObject.put("eDesignOptimizer", "javascript:pv_optimizer_popup(FT.cont_id[FT.cont_id.selectedIndex].value)");
                    }
                }
            }

            String sCalcCampID = null;

            rs = stmt.executeQuery("SELECT max(camp_id) FROM cque_campaign"
                    + " WHERE type_id = " + CampaignType.TEST
                    + " AND status_id = " + CampaignStatus.DONE
                    + " AND mode_id = " + CampaignMode.CALC_ONLY
                    + " AND origin_camp_id = " + camp.s_camp_id);

            if (rs.next()) sCalcCampID = rs.getString(1);
            jsonObject.put("sCalcCampID", sCalcCampID);
            rs.close();

            if ((!isDone && !isSending && !isTesting && !isPending) || (sCalcCampID != null)) {

                if ((!isDone && !isSending && !isTesting && !isPending) && (can.bExecute)) {
                    jsonObject.put("calculateStatistics", "javascript:send_calc()");
                }

                if (sCalcCampID != null) {
                    String sCalcDate = null;
                    rs = stmt.executeQuery("SELECT convert(varchar(255), finish_date, 100) FROM cque_camp_statistic WHERE camp_id = " + sCalcCampID);
                    if (rs.next()) sCalcDate = rs.getString(1);
                    jsonObject.put("sCalcDate", sCalcDate);
                    rs.close();

                    CampStatDetails csds = new CampStatDetails();
                    csds.s_camp_id = sCalcCampID;
                    csds.retrieve();
                    boolean bHasStats = false;
                    if (csds.size() != 0) {
                        bHasStats = true;
                        jsonObject.put("viewCalculationDetails", bHasStats);
                        jsonObject.put("campIdForCalculation", sCalcCampID);
                    } else {
                        jsonObject.put("viewCalculationDetails", bHasStats);
                    }
                }
            }
        } else {
            String sExportName = null;
            String sFileUrl = null;
            String sDelimiter = null;
            rs = stmt.executeQuery("select export_name, delimiter, file_url FROM cque_camp_export WHERE camp_id = " + camp.s_camp_id);
            if (rs.next()) {
                sExportName = rs.getString(1);
                sDelimiter = rs.getString(2);
                sFileUrl = rs.getString(3);
            }
            if (sDelimiter == null || sDelimiter.equals("")) {
                sDelimiter = "\\t";
            }
            jsonObject.put("sExportName", sExportName);
            jsonObject.put("sFileUrl", sFileUrl);
            jsonObject.put("sDelimiter", sDelimiter);
            rs.close();


        }
        ///////////////////////////////////////////////////tab_2///////////////////////////////////////////////////////

        ///////////////////////////////////////////////////tab_3///////////////////////////////////////////////////////
        boolean bNowChecked = true;
        boolean bSpecificChecked = false;

        bNowChecked = (schedule.s_start_date == null);
        bSpecificChecked = (schedule.s_start_date != null);

        if (isHyatt) {
            if (sCampId == null) {
                bNowChecked = false;
                bSpecificChecked = true;
            }
        }
        String sDeliverabilityInTypes = "10,11,12,13,14";

        jsonObject.put("bNowChecked", ((bNowChecked) ? " checked" : ""));
        jsonObject.put("bSpecificChecked", ((bSpecificChecked) ? " checked" : ""));
        jsonObject.put("specificDate", schedule.s_start_date);


        if (!camp.s_type_id.equals("2") && !camp.s_type_id.equals("5")) {
            boolean bEndDateNever = true;
            if (schedule.s_end_date != null) bEndDateNever = false;
            else if ((camp.s_camp_id == null) && (camp.s_type_id.equals("3"))) bEndDateNever = false;

            jsonObject.put("bEndDateNever", ((bEndDateNever) ? " checked" : ""));

            if (schedule.s_end_date == null) {
                rs = stmt.executeQuery("SELECT DATEADD(month, 2, getdate())");
                if (rs.next()) schedule.s_end_date = rs.getString(1);
                rs.close();
                jsonObject.put("sEndDate", schedule.s_end_date);
            }
            jsonObject.put("end_date", schedule.s_end_date);
        }
        if (camp.s_type_id.equals("2")) {
            jsonObject.put("queueStartDate", (camp_send_param.s_queue_date == null) ? "":camp_send_param.s_queue_date);
            jsonObject.put("whenSending", (schedule.s_start_daily_time == null) ? "any time" : schedule.s_start_daily_time);
            if (!isPrintCampaign) {
                jsonObject.put("whenAllMessagesAreSent", ((schedule.s_end_date == null) ? " checked" : ""));
                jsonObject.put("endOnASpecificDateCheck", ((schedule.s_end_date != null) ? " checked" : ""));
                jsonObject.put("endOnASpecificDate", schedule.s_end_date);
                jsonObject.put("maximumSentOutPerHour", camp_send_param.s_limit_per_hour);
            }

        } else {
            if (!camp.s_type_id.equals("5")) {
                jsonObject.put("sendDelay", camp_send_param.s_delay);
                jsonObject.put("whenSending", (schedule.s_start_daily_time == null) ? "any time" : schedule.s_start_daily_time);
            }
        }
        int nSWeekdayMask = Integer.parseInt(schedule.s_start_daily_weekday_mask);
        jsonObject.put("sendOnlyOnMonday", ((nSWeekdayMask & 2) > 0) ? " checked" : "");
        jsonObject.put("sendOnlyOnTuesday", ((nSWeekdayMask & 4) > 0) ? " checked" : "");
        jsonObject.put("sendOnlyOnWednesday", ((nSWeekdayMask & 8) > 0) ? " checked" : "");
        jsonObject.put("sendOnlyOnThursday", ((nSWeekdayMask & 16) > 0) ? " checked" : "");
        jsonObject.put("sendOnlyOnFriday", ((nSWeekdayMask & 32) > 0) ? " checked" : "");
        jsonObject.put("sendOnlyOnSaturday", ((nSWeekdayMask & 64) > 0) ? " checked" : "");
        jsonObject.put("sendOnlyOnSunday", ((nSWeekdayMask & 1) > 0) ? " checked" : "");

        jsonObject.put("andOnlySendUntil", (schedule.s_end_daily_time == null) ? "end of the day" : schedule.s_end_daily_time);


        jsonObject.put("sDeliverabilityInTypes", sDeliverabilityInTypes);
        jsonObject.put("sCampId", sCampId);

        ///////////////////////////////////////////////////tab_3///////////////////////////////////////////////////////

        ///////////////////////////////////////////////////tab_4///////////////////////////////////////////////////////

        JsonArray logsJsonArray = new JsonArray();
        JsonObject logsJsonObject = new JsonObject();
        if (camp.s_camp_id != null) {
            String sCreateDate = null;
            String sStartDate = null;
            String sFinishDate = null;
            String sTypeDisplayName = null;
            String sStatusDisplayName = null;
            String sRecpQueuedQty = null;
            String sRecpSendQty = null;
            int nCampId = 0;
            String sApprovalFlag = null;
            String sTypeId = null;

            boolean hasHistory = false;

            //Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
            boolean oneHistory = false;
            boolean nonTestSent = false;

            sSql =
                    " SELECT " +
                            " isnull(e.create_date,''), " +
                            " isnull(s.start_date,''), " +
                            " isnull(s.finish_date,''), " +
                            " t.display_name, " +
                            " a.display_name, " +
                            " s.recip_queued_qty, " +
                            " s.recip_sent_qty, " +
                            " c.camp_id, " +
                            " c.approval_flag, " +
                            " t.type_id " +
                            " FROM cque_campaign c WITH(NOLOCK)" +
                            " LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)" +
                            " ON c.camp_id = s.camp_id " +
                            " INNER JOIN cque_camp_edit_info e WITH(NOLOCK)" +
                            " ON c.camp_id = e.camp_id " +
                            " INNER JOIN cque_camp_type t WITH(NOLOCK)" +
                            " ON c.type_id = t.type_id " +
                            " INNER JOIN cque_camp_status a WITH(NOLOCK)" +
                            " ON c.status_id = a.status_id " +
                            " WHERE cust_id =" + cust.s_cust_id + " " +
                            " AND (c.type_id = " + camp.s_type_id + ") " +
                            " AND c.origin_camp_id = " + camp.s_camp_id + " " +
                            " ORDER BY modify_date DESC";

            rs = stmt.executeQuery(sSql);
            while (rs.next()) {
                logsJsonObject = new JsonObject();
                oneHistory = true;
                sCreateDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(1));
                if (sCreateDate.equals("Jan 1, 1900 12:00 AM")) sCreateDate = "";
                sStartDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(2));
                if (sStartDate.equals("Jan 1, 1900 12:00 AM")) sStartDate = "";
                sFinishDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(3));
                if (sFinishDate.equals("Jan 1, 1900 12:00 AM")) sFinishDate = "";
                if (Integer.valueOf(camp.s_status_id).intValue() < CampaignStatus.DONE) sFinishDate = "";
                sTypeDisplayName = rs.getString(4);
                if (sTypeDisplayName == null) sTypeDisplayName = "";
                sStatusDisplayName = rs.getString(5);
                if (sStatusDisplayName == null) sStatusDisplayName = "";
                sRecpQueuedQty = rs.getString(6);
                if (sRecpQueuedQty == null) sRecpQueuedQty = "";
                sRecpSendQty = rs.getString(7);
                if (sRecpSendQty == null) sRecpSendQty = "";
                nCampId = rs.getInt(8);
                sApprovalFlag = rs.getString(9);
                if (sApprovalFlag == null || sApprovalFlag.equals("0"))
                    sApprovalFlag = "No";
                else
                    sApprovalFlag = "Yes";

                //type is > 1, nonTest campaign
                if (rs.getInt(10) > 1) nonTestSent = true;

                if (!isPrintCampaign) {

                    CampStatDetails csds = new CampStatDetails();
                    csds.s_camp_id = String.valueOf(nCampId);
                    csds.retrieve();

                    if (csds.size() != 0) {
                        //
                    }

                }

                logsJsonObject.put("oneHistory", oneHistory);
                logsJsonObject.put("sCreateDate", sCreateDate);
                logsJsonObject.put("sStartDate", sStartDate);
                logsJsonObject.put("sFinishDate", sFinishDate);
                logsJsonObject.put("sTypeDisplayName", sTypeDisplayName);
                logsJsonObject.put("sStatusDisplayName", sStatusDisplayName);
                logsJsonObject.put("sRecpQueuedQty", sRecpQueuedQty);
                logsJsonObject.put("sRecpSendQty", sRecpSendQty);
                logsJsonObject.put("nCampId", nCampId);
                logsJsonObject.put("sApprovalFlag", sApprovalFlag);
                logsJsonObject.put("nonTestSent", nonTestSent);

                logsJsonArray.put(logsJsonObject);
            }
            jsonObject.put("logs", logsJsonArray);
            rs.close();
        } else {
            jsonObject.put("CampHeader", "This area will show Campaign History information once you click the Save button.");
        }


        JsonArray historyLogsJsonArray = new JsonArray();
        JsonObject historyLogsJsonObject = new JsonObject();
        if (camp.s_camp_id != null) {
            //Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
            boolean oneHistory = false;
            boolean nonTestSent = false;
            String histTemp[] = new String[9];

            sSql =
                    " SELECT" +
                            " isnull(e.create_date,'')," +
                            " isnull(s.start_date,'')," +
                            " isnull(s.finish_date,'')," +
                            " t.display_name," +
                            " a.display_name," +
                            " s.recip_queued_qty," +
                            " s.recip_sent_qty," +
                            " c.camp_id," +
                            " c.approval_flag," +
                            " t.type_id " +
                            " FROM cque_campaign c WITH(NOLOCK)" +
                            " LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)" +
                            " ON c.camp_id = s.camp_id " +
                            " LEFT OUTER JOIN cque_camp_edit_info e WITH(NOLOCK)" +
                            " ON c.camp_id = e.camp_id " +
                            " INNER JOIN cque_camp_type t WITH(NOLOCK)" +
                            " ON c.type_id = t.type_id " +
                            " INNER JOIN cque_camp_status a WITH(NOLOCK)" +
                            " ON c.status_id = a.status_id " +
                            " WHERE c.cust_id =" + cust.s_cust_id + " " +
                            " AND (c.type_id = 1) " +
                            " AND ISNULL(c.mode_id,0) not in (20,30,40) " +
                            " AND c.origin_camp_id = " + camp.s_camp_id + " " +
                            " ORDER BY modify_date DESC";

            rs = stmt.executeQuery(sSql);
            while (rs.next()) {

                historyLogsJsonObject = new JsonObject();
                oneHistory = true;
                histTemp[0] = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(1));
                if (histTemp[0].equals("Jan 1, 1900 12:00 AM")) histTemp[0] = "";
                histTemp[1] = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(2));
                if (histTemp[1].equals("Jan 1, 1900 12:00 AM")) histTemp[1] = "";
                histTemp[2] = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(3));
                if (histTemp[2].equals("Jan 1, 1900 12:00 AM")) histTemp[2] = "";
                histTemp[3] = rs.getString(4);
                if (histTemp[3] == null) histTemp[3] = "";
                histTemp[4] = rs.getString(5);
                if (histTemp[4] == null) histTemp[4] = "";
                histTemp[5] = rs.getString(6);
                if (histTemp[5] == null) histTemp[5] = "";
                histTemp[6] = rs.getString(7);
                if (histTemp[6] == null) histTemp[6] = "";
                histTemp[7] = rs.getString(8);
                histTemp[8] = rs.getString(9);
                if (histTemp[8] == null || histTemp[8].equals("0"))
                    histTemp[8] = "No";
                else
                    histTemp[8] = "Yes";

                //type is > 1, nonTest campaign
                if (rs.getInt(10) > 1) nonTestSent = true;

                historyLogsJsonObject.put("historyOneHistory", oneHistory);
                historyLogsJsonObject.put("historyCreateDate", histTemp[0]);
                historyLogsJsonObject.put("historyStartDate", histTemp[1]);
                historyLogsJsonObject.put("historyFinishDate", histTemp[2]);
                historyLogsJsonObject.put("historyTypeDisplayName", histTemp[3]);
                historyLogsJsonObject.put("historyStatusDisplayName", histTemp[4]);
                historyLogsJsonObject.put("historyRecpQueuedQty", histTemp[5]);
                historyLogsJsonObject.put("historyRecpSendQty", histTemp[6]);
                historyLogsJsonObject.put("historyCampId", histTemp[7]);
                historyLogsJsonObject.put("historyApprovalFlag", histTemp[8]);
                historyLogsJsonObject.put("historyNonTestSent", nonTestSent);

                historyLogsJsonArray.put(historyLogsJsonObject);
            }
            jsonObject.put("historyLogs", historyLogsJsonArray);
            rs.close();
            if (oneHistory == false) {
                jsonObject.put("CampHeader", "No Tests Have Been Sent For This Campaign");
            }
        } else {
            jsonObject.put("CampHeader", "This area will show Campaign History information once you click the Save button.");
        }
        ///////////////////////////////////////////////////tab_4///////////////////////////////////////////////////////
        sSql =
                " SELECT c.category_id, c.category_name, oc.object_id" +
                        " FROM ccps_category c" +
                        " LEFT OUTER JOIN ccps_object_category oc" +
                        " ON (c.category_id = oc.category_id" +
                        " AND c.cust_id = oc.cust_id" +
                        " AND oc.object_id=" + camp.s_camp_id +
                        " AND oc.type_id=" + ObjectType.CAMPAIGN + ")" +
                        " WHERE c.cust_id=" + cust.s_cust_id;
        rs = stmt.executeQuery(sSql);

        String sCategoryId = null;
        String sCategoryName = null;
        String sObjectId = null;
        boolean isSelected = false;

        JsonArray categoryJsonArray = new JsonArray();
        JsonObject categoryJsonObject = new JsonObject();
        while (rs.next()) {
            categoryJsonObject = new JsonObject();
            sCategoryId = rs.getString(1);
            sCategoryName = new String(rs.getBytes(2), "UTF-8");
            sObjectId = rs.getString(3);
            isSelected =
                    (sObjectId != null) || ((sSelectedCategoryId != null) && (sSelectedCategoryId.equals(sCategoryId)));

            categoryJsonObject.put("sCategoryId", sCategoryId);
            categoryJsonObject.put("sCategoryName", sCategoryName);
            categoryJsonObject.put("sObjectId", sObjectId);
            categoryJsonObject.put("isSelected", isSelected);

            categoryJsonArray.put(categoryJsonObject);

        }
        rs.close();
        jsonObject.put("category", categoryJsonArray);
        ///////////////////////////////////////////////////tab_6///////////////////////////////////////////////////////

        jsonObject.put("created_by", creator.s_user_name + " " + creator.s_last_name);
        jsonObject.put("last_modified_by", modifier.s_user_name + " " + modifier.s_last_name);
        jsonObject.put("creation_date", camp_edit_info.s_create_date);
        jsonObject.put("last_modify_date", camp_edit_info.s_modify_date);
        ///////////////////////////////////////////////////tab_6///////////////////////////////////////////////////////
        //jsonObject.put("selectedCategoryId", sSelectedCategoryId);
        jsonArray.put(jsonObject);
        out.print(jsonArray);
    } catch (Exception ex) {
        throw ex;

    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }


%>

