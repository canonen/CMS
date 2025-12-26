<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.adm.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.wfl.*,
                com.britemoon.cps.ctl.*,
                java.io.*,
                java.sql.*,
                java.util.*,
                java.util.*,
                java.sql.*,
                org.w3c.dom.*,
                org.apache.log4j.*"

        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="org.json.XML" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.FILTER);
    boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

// === === ===

    String sCurPage = request.getParameter("curPage");
    int curPage = curPage = (sCurPage == null) ? 1 : Integer.parseInt(sCurPage);

// === === ===

    String sTargetGroupOrderBy = ui.getSessionProperty("target_group_order_by");
    String sOrderBy = request.getParameter("order_by");
    if (sOrderBy == null) sOrderBy = sTargetGroupOrderBy;
    if ((sOrderBy == null) || sOrderBy.trim().equals("")) sOrderBy = "date";
    ui.setSessionProperty("target_group_order_by", sOrderBy);

// === === ===

    String sAmount = request.getParameter("amount");

    String sTargetGroupPageSize = ui.getSessionProperty("target_group_page_size");
    if (sAmount == null) sAmount = sTargetGroupPageSize;
    if ((sAmount == null) || sAmount.trim().equals("")) sAmount = "2500";
    int amount = 2500;
    try {
        amount = Integer.parseInt(sAmount);
    } catch (Exception ex) {
    }

    ui.setSessionProperty("target_group_page_size", sAmount);


    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;

    int filterCount = 0;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        JsonArray filterListData = new JsonArray();
        JsonObject data = new JsonObject();

        getStatistics(cust);

        try {
            sSql =
                    " EXEC usp_ctgt_filter_list_get_orderby_fast_2005" +
                            " @cust_id=?, @category_id=?, @start_record=?, @page_size=?, @orderby=?";

            pstmt = conn.prepareStatement(sSql);

            pstmt.setString(1, cust.s_cust_id);
            pstmt.setString(2, sSelectedCategoryId);
            pstmt.setString(3, "0");
            pstmt.setString(4, "999999");
            pstmt.setString(5, sOrderBy);

            rs = pstmt.executeQuery();

            String sFilterId = null;
            String sFilterName = null;
            String sFinishDate = null;
            String sRecipQty = null;
            String sPrintRecipQty = null;
            int iStatusId = -1;
            String sStatusName = null;
            String sAprvlStatusFlag = null;
            String value = "";

            String sClassAppend = "";
            List<String> filterList = new ArrayList<String>();
            while (rs.next()) {
                data = new JsonObject();
                if (filterCount % 2 != 0) sClassAppend = "_other";
                else sClassAppend = "";

                filterCount++;

                //Page logic
                if ((filterCount <= (curPage - 1) * amount) || (filterCount > curPage * amount)) continue;


                sFilterId = rs.getString(1);
                sFilterName = new String(rs.getBytes(2), "UTF-8");
                Timestamp sFinishDateTimestamp = rs.getTimestamp(3);
                if(sFinishDateTimestamp != null) {
                    sFinishDate =  sFinishDateTimestamp.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
                }

                sRecipQty = rs.getString(4);
                sPrintRecipQty = rs.getString(5);
                iStatusId = rs.getInt(6);
                sStatusName = rs.getString(7);
                sAprvlStatusFlag = rs.getString(8);
                filterList.add(sFilterId);

                data.put("sFilterId", sFilterId);
                data.put("sFilterName", sFilterName);
                data.put("sFinishDate", sFinishDate);
                data.put("sRecipQty", sRecipQty);
                data.put("sPrintRecipQty", sPrintRecipQty);
                data.put("sStatusName", sStatusName);
                data.put("iStatusId", iStatusId);
                data.put("sAprvlStatusFlag", sAprvlStatusFlag);


                if (canTGPreview) {
                    if ((sRecipQty != null) && (Integer.parseInt(sRecipQty) > 0)) {
                        value = "previewLink";
                        data.put("preview", value);

                    } else {

                        value = "---";
                        data.put("preview", value);
                    }
                }


                if ((iStatusId != FilterStatus.QUEUED_FOR_PROCESSING) && (iStatusId != FilterStatus.PROCESSING)) {

                    value = "updateLink";
                    data.put("filterStatus", value);

                } else if (iStatusId != FilterStatus.PROCESSING_ERROR) {

                    value = "Update";
                    data.put("filterStatus", value);
                } else {
                    value = "---";
                    data.put("filterStatus", value);

                }
                if ("0".equals(sAprvlStatusFlag)) {
                    value = "unapproved";
                    data.put("sAprvlStatusFlag", value);

                } else if ("-1".equals(sAprvlStatusFlag)) {
                    value = "pending campaign approval";
                    data.put("sAprvlStatusFlag", value);
                }

                filterListData.put(data);
            }

            String categorySqlQuery = "SELECT category_id FROM  ccps_object_category with(nolock) WHERE cust_id = ? AND object_id IN (" + String.join(",", filterList) + ")";
            PreparedStatement pstmt3 = conn.prepareStatement(categorySqlQuery);
            pstmt3.setString(1, cust.s_cust_id);

            ResultSet categoryRs = pstmt3.executeQuery();
            while (categoryRs.next()) {
                data.put("category_id", categoryRs.getString(1));
                filterListData.put(data);
            }


            rs.close();

            out.print(filterListData.toString());

        } catch (Exception sqlex) {
            throw sqlex;
        } finally {
            if (pstmt != null) pstmt.close();
        }
    } catch (Exception ex) {
        throw ex;
    } finally {
        if (conn != null) cp.free(conn);
    }
%>


<%!
    private void getStatistics(Customer cust) throws Exception {
        Vector services = Services.getByCust(ServiceType.RRCP_FILTER_STATISTIC_GET, cust.s_cust_id);
        Service service = (Service) services.get(0);

        ConnectionPool cp = null;
        Connection conn = null;
        JsonArray getStatiticArray = new JsonArray();

        try {

            cp = ConnectionPool.getInstance();
            conn = cp.getConnection(this);

            PreparedStatement pstmt = null;
            try {
                String sSql =
                        " SELECT f.filter_id" +
                                " FROM ctgt_filter f WITH(NOLOCK)" +
                                " WHERE f.origin_filter_id IS NULL" +
                                " AND f.type_id = " + FilterType.MULTIPART +
                                " AND f.cust_id = " + cust.s_cust_id +
                                " AND f.status_id IN (" +
                                FilterStatus.QUEUED_FOR_PROCESSING + ", " +
                                FilterStatus.PROCESSING + ")";

                pstmt = conn.prepareStatement(sSql);
                ResultSet rs = pstmt.executeQuery();

                String sFilterId = null;

                String sFilterXml = null;
                Element eFilter = null;

                com.britemoon.cps.tgt.Filter filter = null;

                int iStatus = 0;

                while (rs.next()) {
                    sFilterId = rs.getString(1);
                    filter = new com.britemoon.cps.tgt.Filter(sFilterId);

                    try {
                        sFilterXml = filter.toXml();
                        sFilterXml = service.communicate(sFilterXml);
                        eFilter = XmlUtil.getRootElement(sFilterXml);
                        filter = new com.britemoon.cps.tgt.Filter(eFilter);

                        JSONObject xmlJSONObj = XML.toJSONObject(sFilterXml);
                        String jsonPrettyPrintString = xmlJSONObj.toString(4);


                        if (filter.m_FilterStatistic != null)
                            filter.m_FilterStatistic.save();

                        iStatus = Integer.parseInt(filter.s_status_id);
                        if (iStatus != FilterStatus.PENDING_APPROVAL) {
                            filter.setStatus(iStatus);
                        }
                        getStatiticArray.put(jsonPrettyPrintString);

                    } catch (SQLException sqlex) {
                        throw sqlex;
                    } catch (Exception ex) {
                        logger.error("Exception: ", ex);
                        filter.setStatus(FilterStatus.PROCESSING_ERROR);
                    }
                }


            } catch (SQLException sqlex) {
                throw sqlex;
            } finally {
                if (pstmt != null) pstmt.close();
            }

        } catch (Exception ex) {
            throw ex;
        } finally {
            if (conn != null) cp.free(conn);
        }

    }

%>
