<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.que.*,
                org.w3c.dom.*,
                java.util.*,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);

    if (!can.bExecute) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
%>

<%
    String sCampId = BriteRequest.getParameter(request, "camp_id");
    String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
    String sAction = BriteRequest.getParameter(request, "action");

    CampApproveDAO cDAO = new CampApproveDAO();
    int iResults;

    if (sAction != null) {
        if (sAction.equals("suspendsamples")) {
            iResults = cDAO.doDbUpdateSamples(sCampId, "suspend");
            //System.out.println("camp_approve.jsp-->suspendsamples");
        } else if (sAction.equals("approvesamples")) {
            iResults = cDAO.doDbUpdateSamples(sCampId, "approve");
            //System.out.println("camp_approve.jsp-->approvesamples");
        } else if (sAction.equals("cancel") || sAction.equals("setdone")) {
            //System.out.println("in campapprove.jsp, cancel");
            String sCustId = BriteRequest.getParameter(request, "cust_id");
            if (sCustId == null) {
                throw new Exception("Could not cancel requested campaign.  Customer ID parameter missing.");
            }
            iResults = cDAO.doCancelCamp(sCustId, sCampId, sAction);
        } else {  //sAction is either suspend or approve a single campaign
            iResults = cDAO.doDbUpdate(sCampId, sAction);
        }

        if (iResults != 1) {
            throw new Exception("Error occurred or unexpected results were returned from database while updating campaign status to '" + sAction + "'.");
        }
    }

//for now, don't bother showing the camp_approve page.  Just return them to whence they came.
    String sOriginCampId = null;
    Campaign camp = new Campaign(sCampId);
    if (camp.s_origin_camp_id == null)
        sOriginCampId = sCampId;
    else
        sOriginCampId = camp.s_origin_camp_id;

    String sReferer = request.getHeader("Referer");
//System.out.println(sReferer);
    String sRedirectUrl = null;
    if (sReferer != null && sReferer.indexOf("camp_edit") != -1) {
        sRedirectUrl =
                "camp_edit.jsp?camp_id=" + sOriginCampId +
                        ((sSelectedCategoryId != null) ? "&category_id=" + sSelectedCategoryId : "");
    } else {
        sRedirectUrl = "camp_list.jsp";
        int nCampTypeId = Integer.parseInt(camp.s_type_id);
        if (nCampTypeId == CampaignType.STANDARD) {
            CampSendParam csp = new CampSendParam(camp.s_camp_id);
            if (csp.s_queue_daily_flag != null) {
                sRedirectUrl += "?type_id=" + CampaignType.AUTO_RESPOND + "&auto_queue_daily_flag=1";
            } else {
                sRedirectUrl += "?type_id=" + camp.s_type_id;
            }
        } else {
            sRedirectUrl += "?type_id=" + camp.s_type_id;
        }
        if (sSelectedCategoryId != null) sRedirectUrl += "&category_id=" + sSelectedCategoryId;
    }
    //response.sendRedirect(sRedirectUrl);
%>
