<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.ctl.*,
                org.w3c.dom.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                java.io.*,
                java.text.DateFormat,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>

<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

    if (!can.bWrite) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
    String sExportName = BriteRequest.getParameter(request, "export_name");
    String sView = BriteRequest.getParameter(request, "view");
    String sDelimiter = BriteRequest.getParameter(request, "delimiter");
    sDelimiter = "";

    String MODE = BriteRequest.getParameter(request, "mode");
    System.out.println(MODE);
    String sDynamicCampFlag = BriteRequest.getParameter(request, "filter_flag");

    boolean bDoClone = ("clone".equals(MODE) || "clone2destination".equals(MODE));

    Campaign camp = saveCamp(cust, user, request, bDoClone);
    JsonObject obj = new JsonObject();
    JsonArray arr = new JsonArray();


    if ("clone2destination".equals(MODE)) {
        camp.s_cust_id = ui.getDestinationCustomer().s_cust_id;
        String sSql =
                " UPDATE cque_campaign" +
                        " SET cust_id=" + camp.s_cust_id +
                        " WHERE camp_id=" + camp.s_camp_id;
        BriteUpdate.executeUpdate(sSql);
    } else {
        CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.CAMPAIGN, camp.s_camp_id, request);
    }

    boolean bHasSampleSet = false;

    if (!bDoClone) {
        CampSampleset camp_sampleset = new CampSampleset();
        camp_sampleset.s_camp_id = camp.s_camp_id;
        if (camp_sampleset.retrieve() > 0) {
            bHasSampleSet = true;
            saveCampSamples(camp_sampleset, request);
        }
    }

    String actionText = null;

    if (MODE.equals("send_pv_receipt")) {
        CampPVHist pvhist = new CampPVHist();
        pvhist.s_cust_id = cust.s_cust_id;
        pvhist.s_pv_test_type_id = BriteRequest.getParameter(request, "pvhist_pv_test_type_id");
        pvhist.s_origin_camp_id = camp.s_camp_id;
        pvhist.s_pv_iq = BriteRequest.getParameter(request, "pvhist_pviq");
        pvhist.s_cont_id = BriteRequest.getParameter(request, "cont_id");
        pvhist.s_tester_id = user.s_user_id;
        pvhist.save();
        String sRedirectUrl = "camp_send.jsp?camp_id=" + camp.s_camp_id + "&mode=pv_receipt";
        //response.sendRedirect(sRedirectUrl);
        return;
    } else if (MODE.equals("send_test")) {
        obj.put("campId",camp.s_camp_id);
        arr.put(obj);
        String sRedirectUrl =
                "camp_send.jsp?camp_id=" + camp.s_camp_id + "&mode=test";
        String sSampleId = BriteRequest.getParameter(request, "sample_id");
        if (sSampleId != null) sRedirectUrl += ("&sample_id=" + sSampleId);

        //response.sendRedirect(sRedirectUrl);
    } else if (MODE.equals("send_pv_test")) {
        String sRedirectUrl =
                "camp_send.jsp?camp_id=" + camp.s_camp_id + "&mode=pv_test";
        String sSampleId = BriteRequest.getParameter(request, "sample_id");
        if (sSampleId != null) sRedirectUrl += ("&sample_id=" + sSampleId);

        String sPvTestListIds = BriteRequest.getParameter(request, "pv_test_list_ids");
        if (sPvTestListIds != null) sRedirectUrl += ("&pv_test_list_ids=" + sPvTestListIds);

        String sContId = BriteRequest.getParameter(request, "cont_id");
        if (sContId != null) sRedirectUrl += ("&cont_id=" + sContId);

        //response.sendRedirect(sRedirectUrl);
    } else if (MODE.equals("send_calc")) {
        System.out.println("hesaplıyor");




        String sRedirectUrl =
                "camp_send.jsp?camp_id=" + camp.s_camp_id + "&mode=calc_only";
        //response.sendRedirect(sRedirectUrl);

    } else if (MODE.equals("send_camp")) {
        String sRedirectUrl = null;
        if (camp.s_type_id.equals("5")) {
            sRedirectUrl = "camp_send.jsp?&approval_flag=1&camp_id=" + camp.s_camp_id + "&export_name=" + sExportName + "&view=" + sView + "&delimiter=" + sDelimiter;
        } else {
            sRedirectUrl = "camp_send_confirm.jsp?camp_id=" + camp.s_camp_id;
            if (sSelectedCategoryId != null)
                sRedirectUrl += "&category_id=" + sSelectedCategoryId;
            if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2"))
                sRedirectUrl += "&export_name=" + sExportName + "&view=" + sView + "&delimiter=" + sDelimiter;
            String sSampleId = BriteRequest.getParameter(request, "sample_id");

            String sPvTestListIds = BriteRequest.getParameter(request, "pv_test_list_ids");
            if (sPvTestListIds != null) sRedirectUrl += ("&pv_test_list_ids=" + sPvTestListIds);

            if (sSampleId != null)
                sRedirectUrl += ("&sample_id=" + sSampleId);
        }
        //response.sendRedirect(sRedirectUrl);
    } else if (MODE.equals("create_sampleset")) {
        String sRedirectUrl =
                "camp_sampleset_edit.jsp" +
                        "?camp_id=" + camp.s_camp_id;

        if (sDynamicCampFlag != null && sDynamicCampFlag.equals("1")) {
            sRedirectUrl += "&filter_flag=1";
        }
        if (sSelectedCategoryId != null) sRedirectUrl += "&category_id=" + sSelectedCategoryId;
        //response.sendRedirect(sRedirectUrl);
    } else if (MODE.equals("save")) actionText = "saved";
    else if (MODE.equals("clone")) actionText = "cloned";

    if (camp.s_type_id.equals("5") || (camp.s_media_type_id != null && camp.s_media_type_id.equals("2"))) {
        String sSql = "DELETE FROM cque_camp_export_attr WHERE camp_id = " + camp.s_camp_id;
        BriteUpdate.executeUpdate(sSql);

        sSql = "DELETE FROM cque_camp_export WHERE camp_id = " + camp.s_camp_id;
        BriteUpdate.executeUpdate(sSql);

        sSql = "INSERT cque_camp_export (camp_id, export_name, delimiter) VALUES (" + camp.s_camp_id + ",'" + sExportName + "','" + sDelimiter + "')";
        BriteUpdate.executeUpdate(sSql);

        if (sView != null) {
            StringTokenizer st = new StringTokenizer(sView, ",");
            int n = 0;
            while (st.hasMoreTokens()) {
                n++;
                sSql = " INSERT cque_camp_export_attr (camp_id, seq, attr_id) VALUES (" + camp.s_camp_id + "," + n + "," + st.nextToken() + ")";
                BriteUpdate.executeUpdate(sSql);
            }
        }
    }
obj.put("campId",camp.s_camp_id);
arr.put(obj);
 out.print(arr);

%>

<%@ include file="camp_save_functions.inc" %>

