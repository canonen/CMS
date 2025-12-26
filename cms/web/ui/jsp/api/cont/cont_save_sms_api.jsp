<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.jtk.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.xcs.cti.ContentClient,
		java.sql.*,java.io.*,javax.servlet.*,
		javax.servlet.http.*,org.xml.sax.*,
		javax.xml.transform.*,
		javax.xml.transform.stream.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bWrite)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
	String sUseAnchorName = BriteRequest.getParameter(request,"use_anchor_name");
	String sUseLinkRenaming = BriteRequest.getParameter(request,"use_link_renaming");
	String sReplaceScannedLinks = BriteRequest.getParameter(request,"replace_scanned_links");
	// === === ===

	final int SAVE_TO_DEST=0, SAVE=1, SAVE_AS_NEW=2, SAVE_RETURN=3;
	final int SAVE_LINKS=4, DYNAMIC_PREVIEW=5, SAVE_LOGIC=6;
	final int SAVE_AND_REQUEST_APPROVAL=7;

	int iActionSave=-1;

	if (BriteRequest.getParameter(request, "ActionSave")!=null)
		iActionSave=new Integer(BriteRequest.getParameter(request, "ActionSave")).intValue();
			
	if (iActionSave < 0 || iActionSave > 7)
		throw new Exception ("Incorrect Action Code:"+BriteRequest.getParameter(request, "ActionSave"));

	// === === ===

	Content cont = new Content();
	String sContId = BriteRequest.getParameter(request, "contentID");
	
	if(sContId != null)
	{
		cont.s_cont_id = sContId;
		if(cont.retrieve() < 1) throw new Exception("Cont id = " + sContId + "does not exist");
	}

	// === === ===

	if (iActionSave==SAVE_AS_NEW || iActionSave==SAVE_TO_DEST)
	{
		cont.s_cont_id = null;	
		cont.s_status_id = "10";  //Set content to Draft during Cloning
	}
	else
		cont.s_status_id = BriteRequest.getParameter(request, "Statuses");

	if (iActionSave != SAVE_TO_DEST) cont.s_cust_id = cust.s_cust_id;
	else cont.s_cust_id = ui.getDestinationCustomer().s_cust_id;

	cont.s_cont_name = BriteRequest.getParameter(request, "ContentName");
	cont.s_charset_id = BriteRequest.getParameter(request, "SendTypes");
	cont.s_type_id = BriteRequest.getParameter(request, "contTypeID");
	cont.s_cti_doc_id = BriteRequest.getParameter(request, "ctiDocID");

	//if (cont.s_type_id.equals(String.valueOf(ContType.PRINT))) {
	//	ContentClient cc = new ContentClient();
	//	cont.s_cti_doc_id = cc.saveContentDocument(cont, iActionSave);
	//	if ((cont.s_cti_doc_id == null) || (cont.s_cti_doc_id.trim().length() == 0))
	//		throw new Exception ("Invalid doc id: "+cont.s_cti_doc_id);
	//}

	// === === ===

	ContBody cb = new ContBody();
	
	cb.s_cont_id = cont.s_cont_id;
	//KO - can't use BriteRequest here, should not trim content.
	String sTmp = request.getParameter("ContentHTML");
	
	
	String sTmp_source = sTmp.replaceAll("(?i)</body>", "");
	sTmp_source = sTmp_source.replaceAll("(?i)</html>", "");
	sTmp = sTmp_source;
	
	
	cb.s_html_part = ((sTmp!=null) && (sTmp.trim().length()>0))?new String(sTmp.getBytes("ISO-8859-1"), "UTF-8"):null;
	sTmp = request.getParameter("ContentText");
	cb.s_text_part = ((sTmp!=null) && (sTmp.trim().length()>0))?new String(sTmp.getBytes("ISO-8859-1"), "UTF-8"):null;
	sTmp = request.getParameter("ContentAOL");
	cb.s_aol_part = ((sTmp!=null) && (sTmp.trim().length()>0))?new String(sTmp.getBytes("ISO-8859-1"), "UTF-8"):null;

	ContSendParam csp = new ContSendParam();

	csp.s_cont_id = cont.s_cont_id;
	csp.s_unsub_msg_id = BriteRequest.getParameter(request, "unsubID");
	csp.s_unsub_msg_position = BriteRequest.getParameter(request, "unsubPos");
	csp.s_send_html_flag = (cb.s_html_part == null)?"0":"1";
	csp.s_send_text_flag = (cb.s_text_part == null)?"0":"1";
	csp.s_send_aol_flag = (cb.s_aol_part == null)?"0":"1";
	
	ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
	cei.s_modifier_id = user.s_user_id; // should work with modifier only
    cei.s_modify_date = null;     // setting s_modify_date to null will cause the content_edit_info_save stored procedure
                                  // to automatically set modify_date to the current date.
	
	// === === ===
		
	cont.m_ContSendParam = csp;
	cont.m_ContBody = cb;
	cont.m_ContEditInfo = cei;	
	cont.m_Links = getLinks(request, cont.s_cont_id, cont.s_cust_id);
	if (cont.m_Links == null && cont.s_cont_id != null) {
		// delete all existing links where no links is to be saved
		Links links = new Links();
		links.s_cont_id = cont.s_cont_id;
		if(links.retrieve() > 0) links.delete();
	}
	cont.m_ContParts = new ContParts(); // just to clean ContParts if any
	cont.save();

	// === === ===	

	if (iActionSave != SAVE_TO_DEST)
	{
		try
		{
			CategortiesControl.saveCategories(cont.s_cust_id, ObjectType.CONTENT, cont.s_cont_id, request);
		}
		catch(Exception ex)
		{
			logger.error("cont_save.jsp ERROR: unable to save categories.",ex);
		}
	}

	// === === ===

    String sRedirectUrl = null;
    String sendRedirectUrl = "";
    JsonObject resp = new JsonObject();

    if (iActionSave == SAVE_RETURN) {
        sendRedirectUrl = "cont_edit_sms_api.jsp?cont_id=" + cont.s_cont_id;
    } else if (iActionSave == DYNAMIC_PREVIEW) {
        sendRedirectUrl = "cont_edit_sms_api.jsp?popup=true&cont_id=" + cont.s_cont_id;
    } else if (iActionSave == SAVE_LINKS) {
        sendRedirectUrl = "link_scan.jsp?cont_id=" + cont.s_cont_id + "&use_anchor_name=" + sUseAnchorName + "&use_link_renaming=" + sUseLinkRenaming + "&replace_scanned_links=" + sReplaceScannedLinks;
    } else if (iActionSave == SAVE_AND_REQUEST_APPROVAL) {
        sendRedirectUrl = "../workflow/approval_request_edit.jsp?object_type=" + ObjectType.CONTENT + "&object_id=" + cont.s_cont_id;
    } else if (iActionSave == SAVE_LOGIC) {
        String destLogicID = BriteRequest.getParameter(request, "destLogicID");
        sendRedirectUrl = "logic_block_edit.jsp?parent_cont_id=" + cont.s_cont_id + ((destLogicID!=null)?"&logic_id="+destLogicID:"");
    }


    if (iActionSave == SAVE_RETURN) sRedirectUrl = "cont_edit_sms_api.jsp?cont_id=" + cont.s_cont_id;
	else if (iActionSave == DYNAMIC_PREVIEW) sRedirectUrl = "cont_edit_sms_api.jsp?popup=true&cont_id=" + cont.s_cont_id;
	else if (iActionSave == SAVE_LINKS) sRedirectUrl = "link_scan.jsp?cont_id=" + cont.s_cont_id + "&use_anchor_name=" + sUseAnchorName + "&use_link_renaming=" + sUseLinkRenaming + "&replace_scanned_links=" + sReplaceScannedLinks;
	else if (iActionSave == SAVE_AND_REQUEST_APPROVAL) sRedirectUrl = "../workflow/approval_request_edit.jsp?object_type=" + ObjectType.CONTENT + "&object_id=" + cont.s_cont_id;
	else if (iActionSave == SAVE_LOGIC) {
		String destLogicID = BriteRequest.getParameter(request, "destLogicID");
		sRedirectUrl = "logic_block_edit.jsp?parent_cont_id=" + cont.s_cont_id + ((destLogicID!=null)?"&logic_id="+destLogicID:"");
	}else {
        String actionLabel = (iActionSave==SAVE_AS_NEW || iActionSave==SAVE_TO_DEST) ? "cloned" : "saved";

        String backToList = "cont_list.jsp" + (sSelectedCategoryId!=null ? ("?category_id=" + sSelectedCategoryId) : "");

        String backToEdit = null;
        if (iActionSave != SAVE_TO_DEST) {
            StringBuilder sb = new StringBuilder("cont_edit_sms_api.jsp?cont_id=").append(cont.s_cont_id);
            if (sSelectedCategoryId != null) sb.append("&category_id=").append(sSelectedCategoryId);
            backToEdit = sb.toString();
        }

        sendRedirectUrl = backToList;

        resp.put("message", "The content was " + actionLabel + ".");
        resp.put("backToList", backToList);
        if (backToEdit != null) resp.put("backToEdit", backToEdit);
        resp.put("contentId", cont.s_cont_id == null ? "" : cont.s_cont_id);
    }

    resp.put("sendRedirectUrl", sendRedirectUrl);
    resp.put("statusCode", "200");
    response.setContentType("application/json;charset=UTF-8");
    out.print(resp.toString());

%>

<%!

private static Links getLinks(HttpServletRequest request, String sContId, String sCustId)
{
	Links links = null;

	String[] strTrackValues = BriteRequest.getParameterValues(request,"TrackURLs");
	if((strTrackValues==null)||(strTrackValues.length==0)) return links;

	String strTr = null;
	int pos;
	
	links = new Links();
	for (int i=0; i<strTrackValues.length; i++)
	{
		Link link = new Link();
		link.s_cust_id = sCustId;
		link.s_cont_id = sContId;

		strTr = strTrackValues[i];
		pos = strTr.indexOf("\n");
		link.s_link_name = strTr.substring(0,pos);
		link.s_href = strTr.substring(pos+1);
		links.add(link);
	}

	return links;
}
%>
