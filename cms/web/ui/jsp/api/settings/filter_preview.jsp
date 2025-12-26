<%@ page
    language="java"
    import="com.britemoon.*,
        com.britemoon.cps.*,
        com.britemoon.cps.adm.*,
        com.britemoon.cps.tgt.*,
        com.britemoon.cps.imc.*,
        java.io.*,java.sql.*,
        java.util.*,org.w3c.dom.*,
        org.apache.log4j.*"
    errorPage="../error_page.jsp"
    contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%
   // static Logger logger = null;

   // if(logger == null) {
    //    logger = Logger.getLogger(this.getClass().getName());
    //}

    AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

    if(!can.bExecute) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();
    JsonArray array2 = new JsonArray();
    JsonArray array3 = new JsonArray();

    String sFilterId = request.getParameter("filter_id");
    if (sFilterId == null) {
        return;
    }

    PreviewAttrs pas = new PreviewAttrs();
    pas.s_filter_id = sFilterId;
    if (pas.retrieve() < 1) {
        return;
    }

    PreviewAttr pa = null;
    String sAttrList = "";

    for (Enumeration e = pas.elements(); e.hasMoreElements();) {
        pa = (PreviewAttr)e.nextElement();
        if (!"".equals(sAttrList)) {
            sAttrList += ",";
        }
        sAttrList += pa.s_attr_id;
    }

    RecipList rl = new RecipList();
    rl.sAction = "TgtPreview";
    rl.s_cust_id = cust.s_cust_id;
    rl.s_filter_id = sFilterId;
    rl.s_num_recips = "200";
    rl.s_attr_list = sAttrList;

    String sRequestXml = rl.toRecipRequestXml();
    String sResponse = Service.communicate(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id, sRequestXml);

    CustAttr ca = null;
    Attribute a = null;
    for (Enumeration e = pas.elements(); e.hasMoreElements();) {
        data = new JsonObject();
        pa = (PreviewAttr)e.nextElement();
        ca = new CustAttr(cust.s_cust_id, pa.s_attr_id);
        data.put("displayName", ca.s_display_name);
        array3.put(data);
    }
    int column = array3.length();
    array = new JsonArray();
    data = new JsonObject();
    data.put("columnCount", column);
    array2.put(data);

    Element eRecipList = XmlUtil.getRootElement(sResponse);
    Element eRecipient = null;
    NodeList nl = XmlUtil.getChildrenByName(eRecipList, "recipient");
    int iLength = nl.getLength();

    JsonArray array1 = new JsonArray();
    for (int i = 0; i < iLength; i++) {
        eRecipient = (Element)nl.item(i);

        for (Enumeration e = pas.elements(); e.hasMoreElements();) {
            data = new JsonObject();
            pa = (PreviewAttr)e.nextElement();
            a = new Attribute(pa.s_attr_id);
            data.put("eRecipient", XmlUtil.getChildCDataValue(eRecipient, a.s_attr_name));
            array1.put(data);
        }
    }

    array.put(array1);
    array.put(array2);
    array.put(array3);
out.println(array);
%>