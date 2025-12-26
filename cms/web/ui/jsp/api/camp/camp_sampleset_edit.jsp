<%@ page
    language="java"
    import="com.britemoon.*,
        com.britemoon.cps.*,
        com.britemoon.cps.que.*,
        com.britemoon.cps.tgt.*,
        java.util.*, java.sql.*,
        java.net.*, java.text.*,
        org.apache.log4j.*"
    errorPage="../error_page.jsp"
    contentType="application/json;charset=UTF-8" %>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%! static Logger logger = null; %>

<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

  
    String sCampId = request.getParameter("camp_id");
    String sDynamicCampFlag = request.getParameter("filter_flag");

    Campaign camp = new Campaign();
    camp.s_camp_id = sCampId;
    if (camp.retrieve() < 1) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Campaign Not Found");
        return;
    }

    com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter(camp.s_filter_id);
    FilterStatistic filter_statistic = new FilterStatistic(camp.s_filter_id);

    CampSampleset cs = new CampSampleset();
    cs.s_camp_id = camp.s_camp_id;
    int nRetrieve = cs.retrieve();
    if (nRetrieve < 1) {
        cs.s_recip_percentage = "100";
        cs.s_filter_flag = sDynamicCampFlag;
    }

     boolean isPrintCampaign = false;
    if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2")) {
        isPrintCampaign = true;
    }

    boolean isDynamicCampaign = false;
    if (cs.s_filter_flag != null && cs.s_filter_flag.equals("1")) {
        isDynamicCampaign = true;
    }
    JsonObject jsonResponse = new JsonObject();

    jsonResponse.put("campaign_name", camp.s_camp_name);
    jsonResponse.put("target_group", isDynamicCampaign ? "Default" : "");
    jsonResponse.put("target_group_name", filter.s_filter_name);

    if (filter_statistic.s_finish_date != null) {
        jsonResponse.put("recipients_count", filter_statistic.s_recip_qty);
        jsonResponse.put("update_info", "Based on the " + (isDynamicCampaign ? "Default" : "") + " Target Group's last update information");
    } else {
        jsonResponse.put("recipients_count", "Unknown");
        jsonResponse.put("update_info", "Target Group has not been updated");
    }

    jsonResponse.put("number_of_campaigns", cs.s_camp_qty);
    jsonResponse.put("split_type_percentage", cs.s_recip_percentage != null ? cs.s_recip_percentage : "N/A");
    jsonResponse.put("split_type_quantity", cs.s_recip_qty != null ? cs.s_recip_qty : "N/A");

    boolean finalCampaignFlag = cs.s_final_camp_flag != null || nRetrieve < 1;
    jsonResponse.put("final_campaign_flag", finalCampaignFlag);
    jsonResponse.put("final_campaign_info", isDynamicCampaign ? "Un-matched recipients of default target group" : "Remainder of target group for that final campaign");

    boolean targetGroupUpdated = filter_statistic.s_finish_date != null;
    jsonResponse.put("target_group_update_status", targetGroupUpdated ? "Target Group has been updated" : "Target Group has not been updated");
    if (!targetGroupUpdated) {
        jsonResponse.put("warning", "Some calculations will not work without updated target group counts");
    }

    JsonObject variablesSelection = new JsonObject();
    if (!isPrintCampaign) {
        variablesSelection.put("from_name_flag", cs.s_from_name_flag != null);
        variablesSelection.put("from_address_flag", cs.s_from_address_flag != null);
        variablesSelection.put("subject_flag", cs.s_subject_flag != null);
        variablesSelection.put("reply_to_flag", isDynamicCampaign && cs.s_reply_to_flag != null);
    }
    variablesSelection.put("content_flag", cs.s_cont_flag != null);
    variablesSelection.put("send_date_flag", cs.s_send_date_flag != null);

    jsonResponse.put("variables_selection", variablesSelection);


    JsonArray arr = new JsonArray();
    arr.put(jsonResponse);
    out.println(arr.toString());
%>
