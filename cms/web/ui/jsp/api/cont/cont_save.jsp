<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.jtk.*,
                com.britemoon.cps.ctl.*,
                com.britemoon.cps.xcs.cti.ContentClient,
                java.sql.*,
                java.io.*,
                javax.servlet.*,
                javax.servlet.http.*,
                org.xml.sax.*,
                javax.xml.transform.*,
                javax.xml.transform.stream.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
        errorPage="../error_page.jsp"
%>
<%--<%@ page import="com.google.gson.JsonObject, com.google.gson.JsonParser" %>--%>
<%--<%@ page import="com.google.gson.Gson" %>--%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.net.URLDecoder" %>
<%! static Logger logger = null;%>
<%

    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    if (!can.bWrite) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    String sContId = request.getParameter("contentId");
    String sSelectedCategoryId = request.getParameter("categoryId");
    String sStatuses = request.getParameter("Statuses");
    String sContentName = BriteRequest.getParameter(request, "ContentName");
    String sSendTypes = BriteRequest.getParameter(request, "SendTypes");
    String sContTypeId= BriteRequest.getParameter(request, "contTypeId");
    String sCtiDocId = BriteRequest.getParameter(request, "ctiDocId");
    String sUnsubId = request.getParameter("unsubId");
    String sUnsubPos = request.getParameter("unsubPos");

    if (sContentName == null || sContentName.trim().isEmpty()) {
       throw new Exception("Content name is required");
    }

    // === === ===
    Content cont = new Content();
    if (sContId != null && !sContId.trim().isEmpty()) {
        cont.s_cont_id = sContId;
        if (cont.retrieve() < 1) {
            throw new Exception("Cont id = " + sContId + " does not exist");
        }
        cont.s_status_id = sStatuses;
    } else {
        cont.s_cont_id = null;
        cont.s_status_id = "10";
    }
    BufferedReader reader = request.getReader();
    StringBuilder requestBody = new StringBuilder();
    String line;

    while ((line = reader.readLine()) != null) {
        requestBody.append(line);
    }
    String data = requestBody.toString();
    JSONObject jsonData = new JSONObject(data.isEmpty() ? "{}" : data);

    cont.s_cust_id = cust.s_cust_id;
    cont.s_cont_name = sContentName;
    cont.s_charset_id = sSendTypes;
    cont.s_type_id = sContTypeId;
    cont.s_cti_doc_id = sCtiDocId;

    if (cont.s_type_id.equals(String.valueOf(ContType.PRINT))) {
        ContentClient cc = new ContentClient();
        cont.s_cti_doc_id = cc.saveContentDocument(cont, 2);
        if ((cont.s_cti_doc_id == null) || (cont.s_cti_doc_id.trim().length() == 0))
            throw new Exception("Invalid doc id: " + cont.s_cti_doc_id);
    }

    // === === ===
    ContBody cb = new ContBody();
    cb.s_cont_id = cont.s_cont_id;
    String contentHtml = jsonData.optString("ContentHTML");
    String contentText = jsonData.optString("ContentText");
    String contentAOL = jsonData.optString("ContentAOL");
    String contentMJML =jsonData.optString("ContentMJML");
    cb.s_html_part = ((contentHtml != null) && (!contentHtml.trim().isEmpty())) ? new String(contentHtml.getBytes("ISO-8859-1"), "UTF-8") : null;
    cb.s_text_part = ((contentText != null) && (!contentText.trim().isEmpty())) ? new String(contentText.getBytes("ISO-8859-1"), "UTF-8") : null;
    cb.s_aol_part = ((contentAOL != null) && (!contentAOL.trim().isEmpty())) ? new String(contentAOL.getBytes("ISO-8859-1"), "UTF-8") : null;
    cb.s_mjml_part = ((contentMJML != null) && (!contentMJML.trim().isEmpty())) ? new String(contentMJML.getBytes("ISO-8859-1"), "UTF-8") : null;

    ContSendParam csp = new ContSendParam();
    csp.s_cont_id = cont.s_cont_id;
    csp.s_unsub_msg_id = sUnsubId;
    csp.s_unsub_msg_position = sUnsubPos;
    csp.s_send_html_flag = (cb.s_html_part == null || cb.s_html_part.equals("") || cb.s_html_part.equals("0")) ? "0" : "1";
    csp.s_send_text_flag = (cb.s_text_part == null) ? "0" : "1";
    csp.s_send_aol_flag = (cb.s_aol_part == null || cb.s_aol_part.equals("") || cb.s_aol_part.equals("0")) ? "0" : "1";
    csp.s_send_mjml_flag = (cb.s_mjml_part == null || cb.s_mjml_part.equals("") || cb.s_mjml_part.equals("0")) ? "0" : "1";

    ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
    cei.s_modifier_id = user.s_user_id;
    cei.s_modify_date = null;

    // === === ===
    cont.m_ContSendParam = csp;
    cont.m_ContBody = cb;
    cont.m_ContEditInfo = cei;

    Links links = new Links();
    String strTrackValues = jsonData.optString("TrackURLs");
    Pattern urlPattern = Pattern.compile("(https?://[^\\s]+)");
    Matcher matcher = urlPattern.matcher(strTrackValues);

    int lastEnd = 0;
    while (matcher.find()) {
        Link link = new Link();
        link.s_cust_id = cont.s_cust_id;
        link.s_cont_id = sContId;
        link.s_href = matcher.group(1);
        int start = matcher.start(1);
        String rawName = strTrackValues.substring(lastEnd, start).trim();
        link.s_link_name = URLDecoder.decode(rawName, "UTF-8");
        links.add(link);
        lastEnd = matcher.end(1);
    }

    cont.m_Links = links;
    cont.m_ContParts = new ContParts();
    cont.save();
//    System.out.println("cont_save.jsp: cont.s_cont_id = " + cont.s_cont_id);
//	String link_scanUrl = "link_scan.jsp?cont_id=" + cont.s_cont_id + "&use_anchor_name=" + sUseAnchorName + "&use_link_renaming=" + sUseLinkRenaming + "&replace_scanned_links=" + sReplaceScannedLinks;
//	response.sendRedirect(link_scanUrl);

    try {
        CategortiesControl.saveCategories(cont.s_cust_id, ObjectType.CONTENT, cont.s_cont_id, request);
    } catch (Exception ex) {
        logger.error("cont_save.jsp ERROR: unable to save categories.", ex);
    }
    if (sContId == null ) {
        jsonObject.put("saveType", "cloned");
    } else {
        jsonObject.put("saveType", "saved");
    }
    jsonObject.put("category_id", sSelectedCategoryId);
    jsonObject.put("cont_id", cont.s_cont_id);
    jsonArray.put(jsonObject);
    out.print(jsonArray);


%>
