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
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.io.StringWriter" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="org.json.XML" %>
<%@ page import="com.google.gson.JsonObject, com.google.gson.JsonParser" %>
<%@ page import="com.fasterxml.jackson.databind.JsonNode" %>
<%@ page import="com.fasterxml.jackson.core.JsonProcessingException" %>
<%@ page import="com.fasterxml.jackson.databind.JsonNode" %>
<%@ page import="com.fasterxml.jackson.dataformat.xml.XmlMapper" %>
<%@ page import="javax.xml.transform.Transformer" %>
<%@ page import="javax.xml.transform.TransformerFactory" %>
<%@ page import="javax.xml.transform.dom.DOMSource" %>
<%@ page import="javax.xml.transform.stream.StreamResult" %>
<%@ page import="com.fasterxml.jackson.databind.SerializationFeature" %>
<%@ page import="java.io.PrintWriter" %>

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
    JsonArray jsonArray = new JsonArray();

//*************** Alinan JSON'in XML e cevrildigi kisim **********************************

    String sSelectedCategoryId = request.getParameter("category_id");
    String sAction = BriteRequest.getParameter(request, "save_type");
    String sFilterId = BriteRequest.getParameter(request, "filter_id");
    String sFilterName = BriteRequest.getParameter(request, "filter_name");
    String jsonString = BriteRequest.getParameter(request, "filter_xml"); // json string olarak alir

    JsonParser parser = new JsonParser();
    JsonObject jsonObject = parser.parse(jsonString).getAsJsonObject(); // string veri json a cevrilir
    //out.println(jsonObject.toString());

    JsonNode jsonNode = new com.fasterxml.jackson.databind.ObjectMapper().readTree(jsonString);

    String sFilterXml = new XmlMapper().configure(SerializationFeature.INDENT_OUTPUT, true)
            .writeValueAsString(jsonNode);// JSON XML e cevrilir

    XmlMapper xmlMapper = new XmlMapper();
    xmlMapper.configure(SerializationFeature.WRITE_CHAR_ARRAYS_AS_JSON_ARRAYS, true);
    sFilterXml = sFilterXml.replaceAll("<ObjectNode>", "").replaceAll("</ObjectNode>", ""); // ObjectNode basliklari ayristirilir
    sFilterXml = sFilterXml.replaceAll("<__cdata>", "<![CDATA[").replaceAll("</__cdata>", "]]>").replaceAll("<__cdata/>","<![CDATA[NOP]]>");
    sFilterXml = sFilterXml.replaceAll("<!\\[CDATA\\[BOOLEAN\\+OPERATION\\]\\]>", "<![CDATA[BOOLEAN OPERATION]]>");
//****************************************************************************************

    if (sFilterXml == null) {
        throw new Exception("No filter xml found");
    }

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


    // eFilter icerisindeki datalari goruntulemek icin kod blogu
/*    StringWriter stringWriter = new StringWriter();
    TransformerFactory transformerFactory = TransformerFactory.newInstance();
    Transformer transformer = transformerFactory.newTransformer();
    transformer.transform(new DOMSource(eFilter), new StreamResult(stringWriter));
    String xmlString1 = stringWriter.toString();
    out.println("XML String: " + xmlString1);*/
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
        jsonObject.addProperty("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        jsonObject.addProperty("filter_id", f.s_filter_id);
        jsonObject.addProperty("usage_type_id", (sUsageTypeId != null) ? sUsageTypeId : "");
    } else if ((sLogicId == null) && (sParentContId == null) && (!bIsLogic)) {
        jsonObject.addProperty("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        jsonObject.addProperty("filter_id", f.s_filter_id);
        jsonObject.addProperty("usage_type_id", (sUsageTypeId != null) ? sUsageTypeId : "");
    } else {
        jsonObject.addProperty("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        jsonObject.addProperty("filter_id", f.s_filter_id);
        jsonObject.addProperty("usage_type_id", (sUsageTypeId != null) ? sUsageTypeId : "");
        jsonObject.addProperty("logic_id", (sLogicId != null) ? sLogicId : "");
        jsonObject.addProperty("parent_cont_id", (sParentContId != null) ? sParentContId : "");
        if (sLogicId != null) {
            jsonObject.addProperty("logic_id", sLogicId);
            jsonObject.addProperty("parent_cont_id", (sParentContId != null) ? sParentContId : "");
            jsonObject.addProperty("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
        }
        if (sParentContId != null) {
            jsonObject.addProperty("parent_cont_id", sParentContId);
            jsonObject.addProperty("logic_id", (sLogicId != null) ? sLogicId : "");
            jsonObject.addProperty("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
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

