<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.sbs.*,
                java.sql.*,
                java.net.*,
                java.io.*,
                java.util.*,
                org.w3c.dom.*,
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
    try {
    Form f = new Form();
    f.s_form_id = BriteRequest.getParameter(request, "form_id");

    if (f.s_form_id == null) f.s_cust_id = cust.s_cust_id;
    else if (f.retrieve() < 1) return;

    f.s_type_id = BriteRequest.getParameter(request, "type_id");
    f.s_prefill_no_validate_flag = BriteRequest.getParameter(request, "prefill_no_validate_flag");
    f.s_post_validate_flag = BriteRequest.getParameter(request, "post_validate_flag");
    f.s_form_name = BriteRequest.getParameter(request, "form_name");
    f.s_update_incomplete_flag = BriteRequest.getParameter(request, "update_incomplete_flag");
    f.s_prefill_flag = BriteRequest.getParameter(request, "prefill_flag");
    f.s_high_priority_flag = BriteRequest.getParameter(request, "high_priority_flag");
    f.s_form_next_success = BriteRequest.getParameter(request, "form_next_success");
    f.s_form_alt_prefill_bad_recip = BriteRequest.getParameter(request, "form_alt_prefill_bad_recip");
    f.s_form_source = BriteRequest.getParameter(request, "form_source");
    f.s_form_alt_prefill_no_recip = BriteRequest.getParameter(request, "form_alt_prefill_no_recip");
    f.s_confirm_url = BriteRequest.getParameter(request, "confirm_url");

    f.s_upd_rule_id = BriteRequest.getParameter(request, "upd_rule_id");
    f.s_upd_hierarchy_id = BriteRequest.getParameter(request, "upd_hierarchy_id");
    f.s_unsub_hierarchy_id = BriteRequest.getParameter(request, "unsub_hierarchy_id");

    // === === ===

    String sActionSave = BriteRequest.getParameter(request, "ActionSave");
    if ("2".equals(sActionSave)) f.s_form_id = null;

    // === === ===

    FormEditInfo fei = new FormEditInfo();
    fei.s_modifier_id = user.s_user_id;
    f.m_FormEditInfo = fei;

    logger.info(f.s_form_id);
        f.save();

        logger.info(f.s_form_id);


        f.setupSBS();
        f.setupRCP();

        out.print(" Save is Succesful \n");
        out.print(" Form id = " +  f.s_form_id);
        // === === ===
    }catch (Exception e){
        out.print("Exception : " + e);
    }




%>
