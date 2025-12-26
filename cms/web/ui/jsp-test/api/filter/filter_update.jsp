<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.imc.*,
                java.sql.*,
                java.util.*,
                org.w3c.dom.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

    if (!can.bExecute) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
%>

<%
    String sSelectedCategoryId = request.getParameter("category_id");
    String referer = request.getParameter("referer");
    try {
        if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
            sSelectedCategoryId = ui.s_category_id;

        String sFilterId = request.getParameter("filter_id");
        FilterUtil.sendFilterUpdateRequestToRcp(sFilterId);
    } catch (Exception ex) {
        // Probably this is CPS - RCP communication problem
        // Do not bother customer by throwing exception
        logger.error("Exception: ", ex);
    }

    JsonArray jsonArray = new JsonArray();
    JsonObject jsonObject = new JsonObject();

    if (referer == null) {
        jsonObject.put("referer", "filter_list.jsp ' ye yönlendiriniz.");
    } else {
        Service service = null;
        Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
        service = (Service) services.get(0);
        jsonObject.put("referer", "webpush/segment_list.jsp ' ye yönlendiriniz.");
    }

    jsonArray.put(jsonObject);
    out.print(jsonArray);
%>

