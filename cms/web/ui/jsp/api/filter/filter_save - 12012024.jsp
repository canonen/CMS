<%@ page
        language="java"
        import="com.britemoon.*,
        		com.britemoon.cps.*,
        		com.britemoon.cps.tgt.*,
        		com.britemoon.cps.wfl.*,
        		com.britemoon.cps.ctl.*,
        		java.io.*,
        		java.sql.*,
        		java.util.*,
        		java.sql.*,
        		org.w3c.dom.*,
        		org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp" %>
<%
    response.setContentType("*/*");
    response.setHeader("Access-Control-Allow-Origin","https://cms.revotas.com:3001");
    response.setHeader("Access-Control-Allow-Methods","GET, POST, PATCH, PUT, DELETE, OPTIONS");
	response.setHeader("Access-Control-Allow-Credentials", "true");
%>

<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

    if (!can.bWrite) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);

    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    String sSelectedCategoryId = request.getParameter("category_id");
    String sAction = BriteRequest.getParameter(request, "save_type");
    String sFilterId = BriteRequest.getParameter(request, "filter_id");
    String sFilterName = BriteRequest.getParameter(request, "filter_name");
    String sFilterXml = BriteRequest.getParameter(request, "filter_xml");
    System.out.println("category: "+sSelectedCategoryId);
    System.out.println("sACTION"+sAction);
    System.out.println("sFilterId"+sFilterId);
    System.out.println("sFilterName"+sFilterName);
    System.out.print("filter xml :"+sFilterXml);
    if (sFilterXml == null) {
        throw new Exception("No filter xml found");
    }

// KO: Added for content filter support
    String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");
    String sLogicId = BriteRequest.getParameter(request, "logic_id");
    String sParentContId = BriteRequest.getParameter(request, "parent_cont_id");

    if (sUsageTypeId == null) {
        sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
    }

// === === ===

    Element eFilter = XmlUtil.getRootElement(sFilterXml);

    com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(eFilter);

// === === ===

    f.s_filter_id = sFilterId;
    f.s_filter_name = sFilterName;
    f.s_cust_id = cust.s_cust_id;
    f.s_type_id = String.valueOf(FilterType.MULTIPART);
    f.s_status_id = String.valueOf(FilterStatus.NEW);
    f.s_usage_type_id = sUsageTypeId;

    if (bWorkflow && can.bApprove) {
        f.s_aprvl_status_flag = "1";
    } else if (bWorkflow && !can.bApprove) {
        f.s_aprvl_status_flag = "0";
    }


    if ("clone".equals(sAction) || "clone2destination".equals(sAction)) setFilterIdsToNull(f);
    if ("clone2destination".equals(sAction)) f.s_cust_id = ui.getDestinationCustomer().s_cust_id;

    f.save();

// === === ===

    FilterStatistic fs = new FilterStatistic();
    fs.s_filter_id = f.s_filter_id;
    fs.delete();

// === === ===

    FilterEditInfo fei = new FilterEditInfo();
    fei.s_filter_id = f.s_filter_id;
    fei.s_modifier_id = user.s_user_id;
    fei.save();

// === === ===

    if (!"clone2destination".equals(sAction))
        CategortiesControl.saveCategories(f.s_cust_id, ObjectType.FILTER, f.s_filter_id, request);

// === === ===

    boolean bIsLogic = String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId);
    boolean bIsReport = String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId);
    String sTargetGroupDisplay = "Target Group";
    if (bIsLogic) sTargetGroupDisplay = "Logic Element";
    if (bIsReport) sTargetGroupDisplay = "Report Filter";

    if ("save_and_update".equals(sAction)) {
        try {
            FilterUtil.sendFilterUpdateRequestToRcp(f.s_filter_id);
        } catch (Exception ex) {
            logger.error("Exception: ", ex);
        }
    }

    if ("save_and_request_approval".equals(sAction)) {
        String sRedirUrl = "../workflow/approval_request_edit.jsp?object_type=" + ObjectType.FILTER + "&object_id=" + f.s_filter_id;
        response.sendRedirect(sRedirUrl);
    }

    if ((sLogicId == null) && (sParentContId == null) && (bIsReport)) {
        jsonObject.put("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        jsonObject.put("filter_id", f.s_filter_id);
        jsonObject.put("usage_type_id", (sUsageTypeId != null) ? sUsageTypeId : "");
    } else if ((sLogicId == null) && (sParentContId == null) && (!bIsLogic)) {
        jsonObject.put("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        jsonObject.put("filter_id", f.s_filter_id);
        jsonObject.put("usage_type_id", (sUsageTypeId != null) ? sUsageTypeId : "");
    } else {
        jsonObject.put("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        jsonObject.put("filter_id", f.s_filter_id);
        jsonObject.put("usage_type_id", (sUsageTypeId != null) ? sUsageTypeId : "");
        jsonObject.put("logic_id", (sLogicId != null) ? sLogicId : "");
        jsonObject.put("parent_cont_id", (sParentContId != null) ? sParentContId : "");
        if (sLogicId != null) {
            jsonObject.put("logic_id", sLogicId);
            jsonObject.put("parent_cont_id", (sParentContId != null) ? sParentContId : "");
            jsonObject.put("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        }
        if (sParentContId != null) {
            jsonObject.put("parent_cont_id", sParentContId);
            jsonObject.put("logic_id", (sLogicId != null) ? sLogicId : "");
            jsonObject.put("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        }

    }
    jsonArray.put(jsonObject);
    out.print(jsonArray);

%>
<%!
    private static void setFilterIdsToNull(com.britemoon.cps.tgt.Filter f) {
        if (f == null) return;

        int nTypeId = -1;
        try {
            nTypeId = Integer.parseInt(f.s_type_id);
        } catch (Exception ex) {
            return;
        }

        f.s_filter_id = null;

        if (nTypeId == FilterType.FORMULA || nTypeId == FilterType.CUSTOM_FORMULA) {
            if (f.m_Formula != null) f.m_Formula.s_filter_id = null;
            if (f.m_CustomFormula != null) f.m_CustomFormula.s_filter_id = null;
            return;
        }

        if (nTypeId == FilterType.MULTIPART) {
            FilterParts fps = f.m_FilterParts;
            if (fps == null) return;

            FilterPart fp = null;
            for (Enumeration e = fps.elements(); e.hasMoreElements(); ) {
                fp = (FilterPart) e.nextElement();
                setFilterIdsToNull(fp.m_ChildFilter);
            }
            return;
        }
    }
%>