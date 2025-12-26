<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.adm.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.wfl.*,
                com.britemoon.cps.ctl.*,
                java.io.*,
                java.sql.*,
                java.util.*,
                org.w3c.dom.*,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="javax.xml.transform.Transformer" %>
<%@ page import="javax.xml.transform.TransformerFactory" %>
<%@ page import="javax.xml.transform.dom.DOMSource" %>
<%@ page import="javax.xml.transform.stream.StreamResult" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }


    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
    boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

    String sSelectedCategoryId = "213";
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

    String sFilterId = "70804874";

//Sinan Celik 2018-08-18
    String referer = BriteRequest.getParameter(request, "referer");

// KO: Added for content filter support
    String sUsageTypeId = "500";
    String sLogicId = BriteRequest.getParameter(request, "logic_id");
    String sParentContId = BriteRequest.getParameter(request, "parent_cont_id");
    //com.britemoon.cps.tgt.Filter filter2 = new com.britemoon.cps.tgt.Filter(sFilterId);
    com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter();
    filter.s_filter_id = sFilterId;
    filter.retrieve();
    String sFilterXml = filter.toXml();
    //*****************************************************************
    com.britemoon.cps.tgt.FilterParts filterParts = new com.britemoon.cps.tgt.FilterParts();
    filterParts.s_parent_filter_id = sFilterId;
    filterParts.retrieve();
    String sFilterPartsXml = filterParts.toXml();
    //******************************************************************
    com.britemoon.cps.tgt.FilterParams filterParams = new com.britemoon.cps.tgt.FilterParams();
    filterParams.s_filter_id = sFilterId;
    filterParams.retrieve();
    String sFilterParamsXml = filterParts.toXml();
    sFilterXml = sFilterXml.replace("</filter>", sFilterPartsXml + sFilterParamsXml + "</filter>");
    //******************************************************************
    //out.println("sFilterXml : " + sFilterXml);
/*    out.println("sFilterPartsXml : " + sFilterPartsXml);
    out.println("sFilterParamsXml : " + sFilterParamsXml);*/
    out.println("sFilterXml : " + sFilterXml);


%>

