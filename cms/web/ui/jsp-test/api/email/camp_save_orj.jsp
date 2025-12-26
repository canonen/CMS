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
                org.json.JSONArray,
                org.json.JSONObject,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../utilities/header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>
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

    String sSelectedCategoryId = request.getParameter("category_id");
    String sExportName = request.getParameter("export_name");
    String sView = request.getParameter("view");
    String sDelimiter = request.getParameter("delimiter");
    sDelimiter = "";
%>


<%


    String MODE = request.getParameter("mode");
    String sDynamicCampFlag = request.getParameter("filter_flag");

    boolean bDoClone = ("clone".equals(MODE) || "clone2destination".equals(MODE));

    Campaign camp = saveCamp(cust, user,request, bDoClone);

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

    if (camp.s_type_id.equals("5") || (camp.s_media_type_id != null && camp.s_media_type_id.equals("2"))) {
        /* delete cque_camp_export_attr and cque_camp_export */       String sSql = "DELETE FROM cque_camp_export_attr WHERE camp_id = " + camp.s_camp_id;
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
    JSONObject obj = new JSONObject();
    JSONArray arr = new JSONArray();

    obj.put("camp_id",camp.s_camp_id);
    arr.put(obj);

    out.print(arr);
%>
<%@ include file="./camp_save_functions.inc" %>

