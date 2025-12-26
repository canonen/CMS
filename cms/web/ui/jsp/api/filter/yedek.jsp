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
<%@ page import="com.fasterxml.jackson.dataformat.xml.XmlMapper" %>
<%@ page import="com.fasterxml.jackson.databind.JsonNode" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="org.apache.commons.lang.SerializationUtils" %>

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

    boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
    boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
    {
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

    //String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
    //String sFilterId = BriteRequest.getParameter(request, "filter_id");

    //String sSelectedCategoryId = "108";
    String sSelectedCategoryId = "";
    String sFilterId = "30357108";
    String sFilterXml = "";
    Formula form= new Formula();
    form = getFormula(sFilterId);
    System.out.println("formula : " + form.s_filter_id);


    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;


    ArrayList<String> filterIdList = new ArrayList();

    filterIdList = findAllChildFilterId(sFilterId);
    filterIdList.add(sFilterId); // tree yapisindaki en ust id de listeye eklenir

    com.britemoon.cps.tgt.Filter sFilterMain1 = createRecursiveFilter(sFilterId);
    sFilterXml = sFilterMain1.toXml();
    System.out.println("sFilterXml : ");
    System.out.println(sFilterXml);

/*    XmlMapper xmlMapper = new XmlMapper();
    JsonNode jsonNode = xmlMapper.readTree(sFilterXml);
    sFilterXml = jsonNode.toString();*/
    //System.out.println(sFilterXml);

//Sinan Celik 2018-08-18
    String referer = BriteRequest.getParameter(request, "referer");

// KO: Added for content filter support
    String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");
    String sLogicId = BriteRequest.getParameter(request, "logic_id");
    String sParentContId = BriteRequest.getParameter(request, "parent_cont_id");

//KU: Added for content logic ui
    boolean bIsTargetGroup = true;
    String sTargetGroupDisplay = "Target Group";
    if (String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId)) {
        sTargetGroupDisplay = "Logic Element";
        bIsTargetGroup = false;
    } else if (String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId)) {
        sTargetGroupDisplay = "Report Filter";
        bIsTargetGroup = false;
    } else {
        sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
    }

    boolean canSupReq = ui.getFeatureAccess(Feature.SUPPORT_REQUEST);

// === === ===
    com.britemoon.cps.tgt.Filter sFilterMain = new com.britemoon.cps.tgt.Filter(sFilterId);


    FilterParams filterParamsMain = new FilterParams();
    filterParamsMain=getFilterParams(sFilterId);
    sFilterMain.m_FilterParams= filterParamsMain;
    //System.out.println("filterParamsMain.s_filter_id: " + sFilterMain.m_FilterParams.toXml());

    com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter();

    FilterEditInfo filter_edit_info = new FilterEditInfo();
    User creator = null;
    User modifier = null;

    boolean bIsNewFilter = false;
    String s_recip_qty = null;
    String s_last_update_date = null;

    if (sFilterId == null) {
        filter.s_filter_name = "New " + sTargetGroupDisplay;
        filter.s_type_id = String.valueOf(FilterType.MULTIPART);
        filter.s_cust_id = cust.s_cust_id;
        filter.s_status_id = String.valueOf(FilterStatus.NEW);
        filter.s_usage_type_id = String.valueOf(FilterUsageType.REGULAR);

        creator = user;
        modifier = user;

        bIsNewFilter = true;
        s_recip_qty = "";
        s_last_update_date = "";
    } else {
        filter.s_filter_id = sFilterId;
        if (filter.retrieve() < 1) return;

        filter_edit_info.s_filter_id = filter.s_filter_id;
        filter_edit_info.retrieve();

        creator = new User(filter_edit_info.s_creator_id);
        modifier = new User(filter_edit_info.s_modifier_id);

        FilterStatistic filter_stat = new FilterStatistic(filter.s_filter_id);
        s_recip_qty = (filter_stat.s_recip_qty == null) ? "Unknown" : filter_stat.s_recip_qty;
        s_last_update_date = (filter_stat.s_finish_date == null) ? "Unknown" : filter_stat.s_finish_date;
    }

    int iStatusId = Integer.parseInt(filter.s_status_id);

    boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);
    String sAprvlRequestId = request.getParameter("aprvl_request_id");
    boolean isApprover = false;
    String sAprvlStatusFlag = null;
    if (sFilterId != null) {
        if (sAprvlRequestId == null)
            sAprvlRequestId = "";
        ApprovalRequest arRequest = null;
        if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
            arRequest = new ApprovalRequest(sAprvlRequestId);
        } else {
            arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.FILTER), sFilterId);
        }
        if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
            sAprvlRequestId = arRequest.s_approval_request_id;
            isApprover = true;
        }
    }

    boolean bCanEditParts = true;
    if ((bWorkflow && iStatusId == FilterStatus.PENDING_APPROVAL) || "-1".equals(filter.s_aprvl_status_flag)) {
        bCanEditParts = false;
    }

    JsonArray data = new JsonArray();
    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    String sSQL = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        sSQL =
                " SELECT attr_id, filter_usage" +
                        " FROM ccps_attr_calc_props" +
                        " WHERE cust_id = '" + cust.s_cust_id + "'" +
                        " AND calc_values_flag in (1,2) " +
                        " AND filter_usage in (1,2)";

        rs = stmt.executeQuery(sSQL);

        String sAttrID = "";
        String sFilterUsage = "";
        String saveArr = "";

        for (int i = 0; rs.next(); i++) {
            sAttrID = "";
            sFilterUsage = "";
            saveArr = "";

            sAttrID = rs.getString(1);
            sFilterUsage = rs.getString(2);

            saveArr = sAttrID + ";" + sFilterUsage;

            data.put(saveArr);
        }
        jsonObject.put("values", data);
        rs.close();
    } catch (Exception ex) {
        throw ex;
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
        if (rs != null) rs.close();
    }

    jsonObject.put("disposition_id", "0");
    jsonObject.put("object_type", String.valueOf(ObjectType.FILTER));
    jsonObject.put("object_id", (sFilterId != null) ? sFilterId : "0");
    jsonObject.put("usage_type_id", (sUsageTypeId != null) ? sUsageTypeId : String.valueOf(FilterUsageType.REGULAR));
    jsonObject.put("aprvl_request_id", sAprvlRequestId);
    jsonObject.put("usage_type_id", (sUsageTypeId != null) ? sUsageTypeId : "");
    jsonObject.put("logic_id", (sLogicId != null) ? sLogicId : "");
    jsonObject.put("parent_cont_id", (sParentContId != null) ? sParentContId : "");
    jsonObject.put("filter_xml", sFilterXml);
    jsonObject.put("referer", referer);
    if (filter.s_filter_id != null) {
        jsonObject.put("filter_id", filter.s_filter_id);
    }
    jsonObject.put("filter_name", (filter.s_filter_name != null) ? filter.s_filter_name : "");
    jsonObject.put("category_id", (sSelectedCategoryId != null) ? sSelectedCategoryId : "");
    if (bIsTargetGroup) {
        if (iStatusId == FilterStatus.NEW) {
            jsonObject.put("statusMessage", "Once you update this Target Group, either by clicking the Save &amp; Update button " +
                    "or clicking the Update link from the main target group list page, " +
                    "relevant information about the status of your target group will appear here.");

        } else if (iStatusId == FilterStatus.PENDING_APPROVAL) {
            jsonObject.put("statusMessage", "This Target Group is currently pending approval.");
        } else if (iStatusId == FilterStatus.QUEUED_FOR_PROCESSING || iStatusId == FilterStatus.PROCESSING) {
            jsonObject.put("statusMessage", "The Target Group is currently processing. You cannot make changes to it until after processing is completed.");
        } else if (iStatusId == FilterStatus.READY) {
            jsonObject.put("statusMessage", "When last updated, this Target Group included " + s_recip_qty + " records.<br><br>Click the Save &amp; Update button to recalculate the record count.");
            if (!("0".equals(s_recip_qty))) {
                if (canTGPreview) {

                }
            }
        } else if (iStatusId == FilterStatus.PROCESSING_ERROR) {
            if (canSupReq) {
            }
        }
        jsonObject.put("creator_user_name", creator.s_user_name);
        jsonObject.put("creator_last_name", creator.s_last_name);
        jsonObject.put("modifier_user_name", modifier.s_user_name);
        jsonObject.put("modifier_last_name", modifier.s_last_name);
        jsonObject.put("create_date", filter_edit_info.s_create_date);
        jsonObject.put("modify_date", filter_edit_info.s_modify_date);

        jsonArray.put(jsonObject);

       // out.println(jsonArray);
    }}
%>

<%!
    //Fatih Yavuz Gurel 2024-02-22

    FilterParts LfilterParts = new FilterParts();
    FilterParts finalFilterParts = new FilterParts();
    FilterPart LfilterPart = new FilterPart();
    com.britemoon.cps.tgt.Filter finalFilter = new com.britemoon.cps.tgt.Filter();
    com.britemoon.cps.tgt.Filter demoFilterBefore = new com.britemoon.cps.tgt.Filter();
    com.britemoon.cps.tgt.Filter demoFilterAfter = new com.britemoon.cps.tgt.Filter();
    com.britemoon.cps.tgt.Filter RecursiveParentFilter = new com.britemoon.cps.tgt.Filter();
    ArrayList<String> filterIdList = new ArrayList();
    String ListFilterId = null;
    String mainFilterId = null;
    String localFilterId = null;
    String localParentId = null;
    Boolean firstTimeFlag = true;
    Boolean mainFilterIdFlag = true;

    public com.britemoon.cps.tgt.Filter createRecursiveFilter (String filterId) {
        ConnectionPool cp3 = null;
        Connection conn3 = null;
        Statement stmt3 = null;
        ResultSet rs3 = null;

        if(mainFilterIdFlag){
            mainFilterId = filterId;
            mainFilterIdFlag = false;
        }
        try {
            cp3 = ConnectionPool.getInstance();
            conn3 = cp3.getConnection(this);
            stmt3 = conn3.createStatement();
            //Child i var mi kontrol ediliyor
            String FilterPartLocalSQL =
                    " SELECT child_filter_id," +
                            " display_seq " +
                            " FROM ctgt_filter_part" +
                            " WHERE parent_filter_id = '" + filterId + "'";
            rs3 = stmt3.executeQuery(FilterPartLocalSQL);
            while (rs3 != null && rs3.next()) {
                localFilterId = rs3.getString(1);
                //localParentId = filterId;
                createRecursiveFilter(localFilterId); //child i var ise metot child i olmayan son degere kadar yeniden cagrilir.En alttaki deger bulunur.
            }
            if(firstTimeFlag){
                LfilterPart = getFilterPart(filterId);// ilk filterpart olustu
                //Bir filter icinde hem formula hem filterparts olmamali.Varsa ayni filterin filterpartlarinin hem formulali hem de filterparts li olani ayri ayri olusturulur ve ayni ayni filterpats e eklenir
                if((LfilterPart.m_ChildFilter.m_Formula == null) || (LfilterPart.m_ChildFilter.m_FilterParts == null)){
                    LfilterParts.s_parent_filter_id = getParentId(filterId);
                    LfilterParts.add(LfilterPart);
                    localParentId = getParentId(filterId);
                }else{
                   // System.out.println("Girdi : ");
                    LfilterPart.m_ChildFilter.m_Formula = null; //once formula null yapilip filterpart olusturulur
                    LfilterParts.add(LfilterPart);
                    LfilterPart = getFilterPart(filterId);
                    LfilterPart.m_ChildFilter.m_FilterParts = null; //sonra filter_parts null yapilip filterpart olusturulur
                    LfilterParts.add(LfilterPart);
                    LfilterPart = getFilterPart(filterId);
                }

                finalFilter = createOnlyAFilter(mainFilterId);
                firstTimeFlag = false;
            }else{
                LfilterPart = getFilterPart(filterId);
                if(LfilterPart.s_parent_filter_id.equals(getParentId(filterId))){ // en son filterpart'in parent id'si ile kendi parent id'si ayni ise -- ayni parent id olanlar listeye eklenir
                    LfilterPart.m_ChildFilter = createOnlyAFilter(filterId); // ******
                    if((LfilterPart.m_ChildFilter.m_Formula == null) || (LfilterPart.m_ChildFilter.m_FilterParts == null)){
                        LfilterParts.add(LfilterPart);
                    }else{
                        LfilterPart.m_ChildFilter.m_Formula = null;
                        LfilterParts.add(LfilterPart);
                        LfilterPart = getFilterPart(filterId);
                        LfilterPart.m_ChildFilter.m_FilterParts = null;
                        LfilterParts.add(LfilterPart);
                        LfilterPart = getFilterPart(filterId);
                    }
                    localParentId = getParentId(filterId);
                }else{ //filterpart id ile kendi parent id'si farkli oldugu an filterparts yeni bir RecursiveParentFilter olusturulur ve filterparts RecursiveParentFilter a aktarilir
                    RecursiveParentFilter = createOnlyAFilter(filterId); // filterparts aktarilmak icin parent filter olusturulur
                    RecursiveParentFilter.m_FilterParts = LfilterParts; // eski filterparts aktarilir
                    LfilterPart = getFilterPart(filterId);
                    LfilterPart.m_ChildFilter = RecursiveParentFilter;

                    localParentId = getParentId(filterId);
                    LfilterParts = new FilterParts();
                    if(!getParentId(filterId).equals(mainFilterId)){
                        LfilterParts.add(LfilterPart);
                    }
                }
                if(getParentId(filterId).equals(mainFilterId)){
                    finalFilterParts.add(LfilterPart);
                }
                if(getParentId(filterId).equals("")){
                    finalFilter.m_FilterParts = finalFilterParts;
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR : " + e.getMessage());
            e.printStackTrace();

        } finally {
            if (conn3 != null) cp3.free(conn3);
        }
        return finalFilter;
    }
    //burada requestten gelen filterId nin altinda bulunan tüm child idleri listeler
    public ArrayList<String> findAllChildFilterId(String filterId) {
        ConnectionPool cp3 = null;
        Connection conn3 = null;
        Statement stmt3 = null;
        ResultSet rs3 = null;
        try {
            cp3 = ConnectionPool.getInstance();
            conn3 = cp3.getConnection(this);
            stmt3 = conn3.createStatement();
            if (ListFilterId != null) {
                if (!filterIdList.contains(ListFilterId)) {
                    filterIdList.add(ListFilterId);
                    System.out.println(ListFilterId + " eklendi.");
                } else {
                    System.out.println(ListFilterId + " zaten var, eklenmedi.");
                }
            }
            //Child i var mi kontrol ediliyor
            String FilterPartLocalSQL =
                    " SELECT child_filter_id," +
                            " display_seq " +
                            " FROM ctgt_filter_part" +
                            " WHERE parent_filter_id = '" + filterId + "'";
            rs3 = stmt3.executeQuery(FilterPartLocalSQL);
            while (rs3 != null && rs3.next()) {
                ListFilterId = rs3.getString(1);
                findAllChildFilterId(ListFilterId); //child i var ise metot child i olmayan son degere kadar yeniden cagrilir.En alttaki deger bulunur.
            }
        } catch (Exception e) {
            System.out.println("ERROR : " + e.getMessage());
            e.printStackTrace();

        } finally {
            if (conn3 != null) cp3.free(conn3);
        }
        return filterIdList; // agac yapisinda yer alan tum id leri filtreleyerek liste olarak doner
    }

    public com.britemoon.cps.tgt.Filter createOnlyAFilter (String filterId){
        com.britemoon.cps.tgt.Filter filter = null;
        try {
            filter = new com.britemoon.cps.tgt.Filter(filterId);
            FilterParams filterParams = new FilterParams();
            Formula formula = new Formula();
            PreviewAttrs previewAttrs = new PreviewAttrs();
            previewAttrs = getPreviewAttrs(filterId);
            formula = getFormula(filterId);
            filterParams=getFilterParams(filterId);

            if(formula != null){ filter.m_Formula = formula;}
            if(previewAttrs != null){ filter.m_PreviewAttrs = previewAttrs;}
            filter.m_FilterParams = filterParams;
        } catch (Exception e){
            System.out.println("hata : " + e.getMessage());
        }
        return filter;
    }

    public Formula getFormula(String filterId) {
        ConnectionPool cp5 = null;
        Connection conn5 = null;
        Statement stmt5 = null;
        ResultSet rs5 = null;
        Formula formula = null;
        try {
            cp5 = ConnectionPool.getInstance();
            conn5 = cp5.getConnection(this);
            stmt5 = conn5.createStatement();

            String FilterPartLocalSQL2 =
                    " SELECT filter_id," +
                            " attr_id ," +
                            " operation_id ," +
                            " value1 ," +
                            " positive_flag ," +
                            " value2 " +
                            " FROM ctgt_formula" +
                            " WHERE filter_id = '" + filterId + "'";
            rs5 = stmt5.executeQuery(FilterPartLocalSQL2);

            if (rs5.next()) {
                formula = new Formula(filterId);
                return formula;
            }
        } catch (Exception e) {
            System.out.println("ERROR : " + e.getMessage());
            e.printStackTrace();

        } finally {
            if (conn5 != null) cp5.free(conn5);
        }

        return formula;
    }

    public FilterParams getFilterParams(String filterId) {
        ConnectionPool cp5 = null;
        Connection conn5 = null;
        Statement stmt5 = null;
        ResultSet rs5 = null;
        ArrayList<FilterParam> filterParamList = new ArrayList();
        String paramId = null;
        String paramName = null;
        String stringValue = null;
        FilterParams filterParams = new FilterParams();
        filterParams.s_filter_id = filterId;
        try {
            cp5 = ConnectionPool.getInstance();
            conn5 = cp5.getConnection(this);
            stmt5 = conn5.createStatement();

            String FilterPartLocalSQL =
                    " SELECT param_id," +
                            " param_name," +
                            " string_value " +
                            " FROM ctgt_filter_param" +
                            " WHERE filter_id = '" + filterId + "'";

            rs5 = stmt5.executeQuery(FilterPartLocalSQL);
            while(rs5.next()){
                paramId = rs5.getString(1);
                paramName = rs5.getString(2);
                stringValue = rs5.getString(3);

                FilterParam filterParam = new FilterParam();
                filterParam.s_filter_id = filterId;
                filterParam.s_param_id = paramId;
                filterParam.s_param_name = paramName;
                filterParam.s_string_value = stringValue;
                filterParams.add(filterParam);
            }
        } catch (Exception e) {
            System.out.println("ERROR : " + e.getMessage());
            e.printStackTrace();

        } finally {
            if (conn5 != null) cp5.free(conn5);
        }

        return filterParams;
    }

    public FilterPart getFilterPart(String filterId) {
        ConnectionPool cp4 = null;
        Connection conn4 = null;
        Statement stmt4 = null;
        ResultSet rs4 = null;
        String LDispSeq = null;
        String LParentId = null;
        com.britemoon.cps.tgt.Filter LChildfilter = null;
        Formula LFormula;
        FilterPart LfilterPart = new FilterPart();
        try {
            cp4 = ConnectionPool.getInstance();
            conn4 = cp4.getConnection(this);
            stmt4 = conn4.createStatement();

            String FilterPartLocalSQL2 =
                    " SELECT parent_filter_id," +
                            " display_seq " +
                            " FROM ctgt_filter_part" +
                            " WHERE child_filter_id = '" + filterId + "'";
            rs4 = stmt4.executeQuery(FilterPartLocalSQL2);

            if (rs4.next()) {
                LParentId = rs4.getString(1);
                LDispSeq = rs4.getString(2);
                LChildfilter = new com.britemoon.cps.tgt.Filter(filterId);
                LFormula = getFormula(filterId);
                if (LFormula != null) {
                    LChildfilter.m_Formula = LFormula;
                }
                LfilterPart.m_ChildFilter = LChildfilter;
                LfilterPart.s_display_seq = LDispSeq;
                LfilterPart.s_parent_filter_id = LParentId;
                LfilterPart.retrieve();
            }
        } catch (Exception e) {
            System.out.println("ERROR : " + e.getMessage());
            e.printStackTrace();

        } finally {
            if (conn4 != null) cp4.free(conn4);
        }
        return LfilterPart;
    }

    public String getParentId(String filterId) {
        ConnectionPool cp4 = null;
        Connection conn4 = null;
        Statement stmt4 = null;
        ResultSet rs4 = null;
        String LParentId = "";
        com.britemoon.cps.tgt.Filter LChildfilter = null;
        Formula LFormula;
        FilterPart LfilterPart = new FilterPart();
        try {
            cp4 = ConnectionPool.getInstance();
            conn4 = cp4.getConnection(this);
            stmt4 = conn4.createStatement();

            String FilterPartLocalSQL2 =
                    " SELECT parent_filter_id," +
                            " display_seq " +
                            " FROM ctgt_filter_part" +
                            " WHERE child_filter_id = '" + filterId + "'";
            rs4 = stmt4.executeQuery(FilterPartLocalSQL2);

            if (rs4.next()) {
                LParentId = rs4.getString(1);
            }
        } catch (Exception e) {
            System.out.println("ERROR : " + e.getMessage());
            e.printStackTrace();

        } finally {
            if (conn4 != null) cp4.free(conn4);
        }
        return LParentId;
    }

    public PreviewAttrs getPreviewAttrs(String filterId) {
        ConnectionPool cp4 = null;
        Connection conn4 = null;
        Statement stmt4 = null;
        ResultSet rs4 = null;
        PreviewAttrs previewAttrs = new PreviewAttrs();
        String LDispSeq = "";
        String LAttrId = "";
        try {
            cp4 = ConnectionPool.getInstance();
            conn4 = cp4.getConnection(this);
            stmt4 = conn4.createStatement();

            String FilterPartLocalSQL2 =
                    " SELECT attr_id," +
                            " display_seq " +
                            " FROM ctgt_preview_attr" +
                            " WHERE filter_id = '" + filterId + "'";
            rs4 = stmt4.executeQuery(FilterPartLocalSQL2);

            while (rs4.next()) {
                previewAttrs.s_filter_id = filterId;
                LAttrId = rs4.getString(1);
                LDispSeq = rs4.getString(2);
                PreviewAttr previewAttr = new PreviewAttr();
                previewAttr.s_attr_id = LAttrId;
                previewAttr.s_display_seq = LDispSeq;
                previewAttrs.add(previewAttr);
            }
        } catch (Exception e) {
            System.out.println("ERROR : " + e.getMessage());
            e.printStackTrace();

        } finally {
            if (conn4 != null) cp4.free(conn4);
        }

        if(previewAttrs.s_filter_id == null) {
            previewAttrs = null;
        }
        return previewAttrs;
    }

%>

