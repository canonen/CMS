<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.wfl.*,
                org.w3c.dom.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                java.io.*,
                java.text.DateFormat,
                java.text.SimpleDateFormat,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
    boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.CAMPAIGN);


    if (!can.bWrite) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);

    boolean canFromAddrPers = ui.getFeatureAccess(Feature.FROM_ADDR_PERS);
    boolean canFromNamePers = ui.getFeatureAccess(Feature.FROM_NAME_PERS);
    boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
    boolean canSampleSet = ui.getFeatureAccess(Feature.SAMPLE_SET);
    boolean canStep2 = ui.getFeatureAccess(Feature.CAMP_STEP_2);
    boolean canStep3 = ui.getFeatureAccess(Feature.CAMP_STEP_3);
    boolean canQueueStep = ui.getFeatureAccess(Feature.QUEUE_STEP);
    boolean canSpecTest = ui.getFeatureAccess(Feature.SPECIFIED_TEST);
    boolean canTestHelp = ui.getFeatureAccess(Feature.TESTING_HELP);
    boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);

%>

<%
    // First get Campaign ID/Sample ID and mode info from the Request object.

    String sCampId = request.getParameter("camp_id");
    String sMode = request.getParameter("mode");
    if (sMode == null) sMode = "send";
    String sSampleId = request.getParameter("sample_id");
    String sCategoryId = BriteRequest.getParameter(request, "category_id");
    String sPvTestListIds = BriteRequest.getParameter(request, "pv_test_list_ids");

// Get all component objects needed to display all Campaign data

    Campaign camp = new Campaign(sCampId);
    CampSendParam csp = new CampSendParam(sCampId);
    Content cont = new Content(camp.s_cont_id);
    MsgHeader msghdr = new MsgHeader(sCampId);
    Schedule sch = new Schedule(sCampId);
    CampList camplist = new CampList(sCampId);
    LinkedCamp linkcamp = new LinkedCamp(sCampId);
    com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter(camp.s_filter_id);
    com.britemoon.cps.tgt.Filter seed_list = new com.britemoon.cps.tgt.Filter(camp.s_seed_list_id);
    FilterStatistic filter_stat = new FilterStatistic(camp.s_filter_id);
    Vector vSamples = null;
    Iterator iSamples = null;
    int iNumberOfSamples = 0;


    boolean isPrintCampaign = false;
    if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2")) {
        isPrintCampaign = true;
    }
    boolean bHasSampleset = false;
    boolean bDisplayingFinal = false;
    boolean bDisplayingSamples = false;
    CampSampleset sampleset = new CampSampleset();
    sampleset.s_camp_id = sCampId;

    if (sampleset.retrieve() > 0) bHasSampleset = true;

    bDisplayingFinal = (bHasSampleset && sSampleId == null);
    bDisplayingSamples = (bHasSampleset && sSampleId != null);
    String sSampleLabel = "&nbsp;Samples";
    boolean isDynamicCampaign = false;
    if (sampleset.s_filter_flag != null && sampleset.s_filter_flag.equals("1")) {
        isDynamicCampaign = true;
        sSampleLabel = "&nbsp;Dynamic Campaigns";
    }

    boolean templateRequiresApproval = WorkflowUtil.getTemplateAppovalFlag(sCampId);

    boolean bCantSendOffers = false;
    Vector offers = WorkflowUtil.getOffersLastSendDate(sCampId);
    Iterator it = offers.iterator();
    while (it.hasNext()) {
        HashMap offer = (HashMap) it.next();
        String sName = (String) offer.get("offer_name");
        String sLastSendDate = (String) offer.get("last_send_date");
        bCantSendOffers = true;
    }
    System.out.println(" workflow parameters: bWorkflow = " + bWorkflow + " can.bApprove = " + can.bApprove + " bCantSendOffers = " + bCantSendOffers + " templateRequiresApproval = " + templateRequiresApproval);

/*
System.out.println("=====");
System.out.println("sCampId:" + sCampId);
if (sSampleId == null) System.out.println("sSampleId is NULL");
else System.out.println("sSampleId:" + sSampleId);
System.out.println("bHasSampleset:"+bHasSampleset);
System.out.println("bDisplayingFinal:"+bDisplayingFinal);
System.out.println("bDisplayingSamples:"+bDisplayingSamples);
*/

    if (bDisplayingSamples) {
        vSamples = new Vector();
        iNumberOfSamples = Integer.parseInt(sampleset.s_camp_qty);
        for (int i = 1; i <= iNumberOfSamples; i++) {
            vSamples.addElement(new CampSampleBean(sCampId, String.valueOf(i)));
        }
        iSamples = vSamples.iterator();
    }


// Variables for data items not found directly in any component objects
    String s_recip_qty = null;
    String s_from_address = null;
    String s_linked_camp_name = null;
    String s_form_name = null;
    String s_exclusion_list_name = null;
    String s_test_list_name = null;
    String s_last_test_date = null;
    String s_send_to_list_name = null;
    String s_send_to_attr_name = null;
    System.out.println("camp.s_type_id : " + camp.s_type_id);

    int iCampTypeId = new Integer(camp.s_type_id).intValue();

    boolean bTested = false;

    s_recip_qty = (filter_stat.s_recip_qty == null) ? "???" : filter_stat.s_recip_qty;

    if (isPrintCampaign) {
        s_recip_qty = (filter_stat.s_print_recip_qty == null) ? "???" : filter_stat.s_print_recip_qty;
    }

// === === ===

// As needed retrieve data from the database for data items not found directly in component objects.
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;

    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

    String sSql = null;

    boolean bWasFinalCampSent = false;
    boolean bWasSamplesetSent = false;
    boolean bWasAnythingSent = false;

    boolean bShowRow = true;
    String sSampleCampName = "";
    int nTypeId = -1;
    int nStatusId = -1;
    int nAprovalFlag = -1;
    int nIsSample = -1;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("camp_send_confirm.jsp");

        sSql =
                " SELECT" +
                        " camp_name," +
                        " type_id," +
                        " status_id," +
                        " ISNULL(approval_flag,0)," +
                        " SIGN(ISNULL(sample_id,0)) " +
                        " FROM cque_campaign" +
                        " WHERE origin_camp_id = ?" +
                        " AND ISNULL(mode_id,0) <> ?" + // Don't display any calc_only test campaigns
                        " ORDER BY type_id, status_id, ISNULL(approval_flag,0), SIGN(ISNULL(sample_id,0))";

        pstmt = conn.prepareStatement(sSql);
        pstmt.setString(1, sCampId);
        pstmt.setInt(2, CampaignMode.CALC_ONLY);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            bWasAnythingSent = true;

            do {
                bShowRow = true;

                sSampleCampName = rs.getString(1);
                nTypeId = rs.getInt(2);
                nStatusId = rs.getInt(3);
                nAprovalFlag = rs.getInt(4);
                nIsSample = rs.getInt(5);

                if ((nIsSample == 0) && (nTypeId != CampaignType.TEST)) {
                    bWasFinalCampSent = true;
                } else {
                    if (nTypeId != CampaignType.TEST) {
                        bWasSamplesetSent = true;
                    }
                }

            } while (rs.next());
        }

        rs.close();

        // get from_address
        if (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_from_address_flag == null)) {
            // from_address is not a sample data item, use from_address from main campaign
            if (msghdr.s_from_address != null) {
                s_from_address = msghdr.s_from_address;
            } else {
                sSql = "Select prefix +'@' + domain " +
                        "from ccps_from_address " +
                        "where from_address_id = ?";

                pstmt = conn.prepareStatement(sSql);
                pstmt.setString(1, msghdr.s_from_address_id);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    s_from_address = rs.getString(1);
                } else {
                    s_from_address = "";
                }
                rs.close();
                pstmt.close();
            }
        }

        // get linked_campaign info
        if (linkcamp.s_linked_camp_id != null) {
            sSql =
                    " SELECT camp.camp_name " +
                            " FROM cque_campaign camp " +
                            " WHERE type_id in (3,4)" +
                            " AND status_id > 0 " +
                            " AND camp.origin_camp_id = ? ";

            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1, linkcamp.s_linked_camp_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                s_linked_camp_name = rs.getString(1);
            }
            rs.close();
            pstmt.close();
        }

        // get form info
        if (linkcamp.s_form_id != null) {
            sSql =
                    " Select form_name " +
                            " from csbs_form " +
                            " where form_id = ? ";

            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1, linkcamp.s_form_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                s_form_name = rs.getString(1);
            }
            rs.close();
            pstmt.close();
        }

        //get test info

        sSql =
                " SELECT camp.camp_name, ISNULL(stat.start_date, '1/1/00') AS start " +
                        " FROM  cque_campaign camp " +
                        " INNER JOIN cque_camp_type type ON " +
                        " camp.type_id = type.type_id " +
                        " INNER JOIN cque_camp_statistic stat ON" +
                        " camp.camp_id = stat.camp_id " +
                        " WHERE (camp.origin_camp_id = ?) " +
                        " AND (UPPER(type.type_name) = 'TEST')";

        pstmt = conn.prepareStatement(sSql);
        pstmt.setString(1, sCampId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            bTested = true;
            s_last_test_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp("start"));
            if (s_last_test_date.equals("Jan 1, 1900 12:00 AM")) {
                s_last_test_date = null;
            }
        } else {
            bTested = false;
        }
        rs.close();
        pstmt.close();


        // get Exlusion List info
        if (camplist.s_exclusion_list_id != null) {
            sSql =
                    " SELECT isnull(list_name,'null') " +
                            " FROM cque_email_list list, " +
                            " cque_list_type type " +
                            " WHERE list.type_id = type.type_id " +
                            " AND UPPER(type.type_name) = 'CAMPAIGN EXCLUSION LIST' " +
                            " AND list_id = ?";

            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1, camplist.s_exclusion_list_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                s_exclusion_list_name = rs.getString(1);
            }
            rs.close();
            pstmt.close();
        }

        // get Test List info
        if (!bHasSampleset || sSampleId == null) {
            if (camplist.s_test_list_id != null) {
                sSql =
                        " SELECT isnull(list_name,'null') " +
                                " FROM cque_email_list list, " +
                                " cque_list_type type " +
                                " WHERE list.type_id = type.type_id " +
                                " AND UPPER(type.type_name) like '% TEST %' " +
                                " AND list_id = ?";

                pstmt = conn.prepareStatement(sSql);
                pstmt.setString(1, camplist.s_test_list_id);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    s_test_list_name = rs.getString(1);
                }
                rs.close();
                pstmt.close();
            }
        }

        // get Send To Attribute info
        if (camplist.s_auto_respond_attr_id != null) {
            sSql =
                    " SELECT display_name " +
                            " FROM ccps_cust_attr " +
                            " WHERE attr_id = ?";

            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1, camplist.s_auto_respond_attr_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                s_send_to_attr_name = rs.getString(1);
            }
            rs.close();
            pstmt.close();
        }


        // get Send To List info
        if (camplist.s_auto_respond_list_id != null) {
            sSql =
                    " SELECT list_name " +
                            " FROM cque_email_list " +
                            " WHERE list_id = ?";

            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1, camplist.s_auto_respond_list_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                s_send_to_list_name = rs.getString(1);
            }
            rs.close();
            pstmt.close();
        }


    } catch (SQLException sqlex) {
        logger.error("SQLException thrown from camp_send_confirm.jsp.", sqlex);
        throw sqlex;
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
    }
// done with database retrieval
    jsonObject.put("sMode", (sMode.equals("test")) ? "Test" : "Send");

    jsonObject.put("campaignTypeDisplayName", CampaignType.getDisplayName(iCampTypeId));
    jsonObject.put("iCampTypeId", iCampTypeId);
    jsonObject.put("isPrintCampaign", isPrintCampaign);
    jsonObject.put("sSampleId", (sSampleId != null) ? sSampleLabel : "&nbsp;Campaign");

    jsonObject.put("campaignName", (camp.s_camp_name));


    if (!isPrintCampaign && (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && (sampleset.s_from_address_flag == null) || (sampleset.s_from_name_flag == null)))) {

        if (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_from_name_flag == null)) {
            jsonObject.put("fromName", msghdr.s_from_name);
        }
        if (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_from_address_flag == null)) {
            jsonObject.put("fromAdress", s_from_address);
        }
        //else { System.out.println("sampleset.sfromaddrflag=" + sampleset.s_from_address_flag); }

    }

    if (!isPrintCampaign && (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_subject_flag == null))) {
        String msg = "";
        String mes = msghdr.s_subject_html;
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
        if ((msghdr.s_subject_text != null) && !(msghdr.s_subject_text.equals(""))) {
            jsonObject.put("subjectText", msghdr.s_subject_text);
        }
        if ((msghdr.s_subject_aol != null) && !(msghdr.s_subject_aol.equals(""))) {
            jsonObject.put("subjectAol", msghdr.s_subject_aol);
        }
    }
    if (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_cont_flag == null)) {
        jsonObject.put("contentName", cont.s_cont_name);
        jsonObject.put("contentId", cont.s_cont_id);

        if (!isPrintCampaign) {
            jsonObject.put("responseForwarding",csp.s_response_frwd_addr);
        }
    }
    int showTG = 1;

    if (iCampTypeId == CampaignType.SEND_TO_FRIEND) {
        if (s_form_name != null) {
            showTG = 0;
            jsonObject.put("s_form_name", s_form_name);
        }
    }

    if (showTG == 1) {
        jsonObject.put("targetGroup", filter.s_filter_name);
        jsonObject.put("recipients", s_recip_qty);
        if (canTGPreview) {
            jsonObject.put("filter_s_filter_id", filter.s_filter_id);
        }

        String sCalcCampID = null;

        sSql = "SELECT max(camp_id) FROM cque_campaign"
                + " WHERE type_id = " + CampaignType.TEST
                + " AND status_id = " + CampaignStatus.DONE
                + " AND mode_id = " + CampaignMode.CALC_ONLY
                + " AND origin_camp_id = ?";

        pstmt = conn.prepareStatement(sSql);
        pstmt.setString(1, camp.s_camp_id);
        rs = pstmt.executeQuery();

        if (rs.next()) sCalcCampID = rs.getString(1);
        rs.close();

        if (sCalcCampID != null) {
            CampStatDetails csds = new CampStatDetails();
            csds.s_camp_id = sCalcCampID;
            csds.retrieve();

            if (csds.size() != 0) {
                jsonObject.put("sCalcCampID", sCalcCampID);
            }
        }
        if (!filter.s_status_id.equals("40")) {
        }
        if (bDisplayingFinal && !bWasSamplesetSent) {
            jsonObject.put("sSampleLabel", sSampleLabel);
        }
    }
//    if (!isPrintCampaign) {
//        jsonObject.put("s_response_frwd_addr", s_response_frwd_addr);
//    }
    if (iCampTypeId == CampaignType.AUTO_RESPOND) {
        if (s_send_to_list_name != null) {
            // Send to Notification List
            jsonObject.put("s_send_to_list_name", s_send_to_list_name);
        } else if (s_send_to_attr_name != null) {
            // Send to email from attribute
            jsonObject.put("s_send_to_attr_name", s_send_to_attr_name);
        }
    }
    if (canStep2) {
        if (!isPrintCampaign) {
            if ((msghdr.s_reply_to != null) && (!msghdr.s_reply_to.equals(""))) {
                jsonObject.put("replyTo", (msghdr.s_reply_to!=null)?msghdr.s_reply_to:"NO");
            }
        }
        if (iCampTypeId != CampaignType.SEND_TO_FRIEND) {
            if ((seed_list.s_filter_name != null) && !(seed_list.s_filter_name.equals(""))) {
                jsonObject.put("seedList", seed_list.s_filter_name);
            }
        }
        if (iCampTypeId == CampaignType.STANDARD && !isPrintCampaign) {
            jsonObject.put("linkedCampaignName", (s_linked_camp_name!=null)?s_linked_camp_name:"NO");
        }
    }

    if (canStep3) {
        if ((s_exclusion_list_name != null) && (!s_exclusion_list_name.equals("null"))) {
            jsonObject.put("exclusionList", (s_exclusion_list_name!=null)?s_exclusion_list_name:"NO");
        }
        if (iCampTypeId != CampaignType.SEND_TO_FRIEND) {
            jsonObject.put("frequencyExclusion", (csp.s_camp_frequency!=null)?csp.s_camp_frequency:"NO");
        }
        if (iCampTypeId == CampaignType.STANDARD && !isPrintCampaign) {
            if ((csp.s_recip_qty_limit != null) && (!csp.s_recip_qty_limit.equals("0"))) {
                jsonObject.put("subsetSendout", (csp.s_recip_qty_limit!=null)?csp.s_recip_qty_limit:"NO");
            }
        }
        if (!isPrintCampaign && iCampTypeId == CampaignType.STANDARD) {
            jsonObject.put("maximumMessagesToBeSentPerHour", (!csp.s_limit_per_hour.equals("0")) ? csp.s_limit_per_hour : "NO");
        }
    }

    if (bDisplayingSamples) {
        while (iSamples.hasNext()) {
            CampSampleBean csbTmp = (CampSampleBean) iSamples.next();
            jsonObject.put("csbTmp.getSampleId", csbTmp.getSampleId());

            if (sampleset.s_from_name_flag != null) {
                jsonObject.put("csbTmp.getFromName", csbTmp.getFromName());
            }

            if (sampleset.s_from_address_flag != null) {
                jsonObject.put("csbTmp.getFromAddress", csbTmp.getFromAddress());
            }

            if (sampleset.s_reply_to_flag != null) {
                jsonObject.put("csbTmp.getReplyTo", csbTmp.getReplyTo());
            }

            if (sampleset.s_filter_flag != null) {
                com.britemoon.cps.tgt.Filter sampleFilter = new com.britemoon.cps.tgt.Filter(csbTmp.getFilterId());
                jsonObject.put("sampleFilter_s_filter_name", sampleFilter.s_filter_name);
                jsonObject.put("csbTmp.getPriority", csbTmp.getPriority());
            }

            if (sampleset.s_subject_flag != null) {
                if (csbTmp.getSubjectHtml() != null) {
                    jsonObject.put("csbTmp.getSubjectHtml", csbTmp.getSubjectHtml());
                }

                if (csbTmp.getSubjectText() != null) {
                    jsonObject.put("csbTmp.getSubjectText", csbTmp.getSubjectText());
                }

                if (csbTmp.getSubjectAol() != null) {
                    jsonObject.put("csbTmp.getSubjectAol", csbTmp.getSubjectAol());
                }
            }

            if (sampleset.s_cont_flag != null) {
                jsonObject.put("csbTmp.getContName", csbTmp.getContName());
                jsonObject.put("csbTmp.getContId", csbTmp.getContId());
            }

            if (sampleset.s_send_date_flag != null) {
                if (csbTmp.getSendDate() != null && !csbTmp.getSendDate().equals("")) {
                    jsonObject.put("csbTmp.getSendDate", csbTmp.getSendDate());
                }
            }
            if (!isPrintCampaign) {
                if (csbTmp.getTestListName() != null && !csbTmp.getTestListName().equals("")) {
                    jsonObject.put(",csbTmp.getTestListName", csbTmp.getTestListName());
                }
                if (csbTmp.getTested() && csbTmp.getLastTestDate() != null) {
                    jsonObject.put("csbTmp.getLastTestDate", csbTmp.getLastTestDate());
                }
            }
        }

    } else {
        if (!isPrintCampaign) {
            if (bTested) {
                jsonObject.put("s_last_test_date", s_last_test_date);
            }
        }
    }

    if (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_send_date_flag == null)) {
        jsonObject.put("sendStartDate", (sch.s_start_date == null) ? "NOW" : sch.s_start_date);
        if (iCampTypeId != CampaignType.STANDARD) {
            jsonObject.put("s_end_date", (sch.s_end_date != null) ? sch.s_end_date : "NO End date specified");
        }
        if (canQueueStep) {
            jsonObject.put("queueStartDate", (csp.s_queue_date != null) ? csp.s_queue_date : "NO Queue Start Date specified");
        }
    }
    if (bCantSendOffers) {
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat sdf = new SimpleDateFormat("yyy-MM-dd");
        it = offers.iterator();
        JsonArray array = new JsonArray();
        while (it.hasNext()) {
            jsonObject = new JsonObject();
            HashMap offer = (HashMap) it.next();
            String sName = (String) offer.get("offer_name");
            String sLastSendDate = (String) offer.get("last_send_date");
            java.util.Date dSendDate = df.parse(sLastSendDate);

            sdf.applyPattern("MMMM d yyyy ");
            String sSendDate = sdf.format(dSendDate);

            jsonObject.put("sName", sName);
            jsonObject.put("sSendDate", sSendDate);
            array.put(jsonObject);
        }
        jsonArray.put(array);
        System.out.println("past the table displaying expired offers");
    }

    jsonObject.put("campaignId", camp.s_camp_id);
    jsonObject.put("sSampleId", sSampleId);
    jsonObject.put("sMode", sMode);
    jsonObject.put("camp_s_type_id", camp.s_type_id);

    if (sCategoryId != null) {
        jsonObject.put("sCategoryId", sCategoryId);
    }
    if (sPvTestListIds != null) {
        jsonObject.put("sPvTestListIds", sPvTestListIds);
    }
    jsonArray.put(jsonObject);
    out.println(jsonArray);

%>