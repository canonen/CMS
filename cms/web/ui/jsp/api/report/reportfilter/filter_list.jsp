<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.ctl.*,
                java.io.*,
                java.sql.*,
                java.util.*,
                java.util.*,
                java.sql.*,
                org.w3c.dom.*,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.FILTER);
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;


// ********** KU
    String scurPage = request.getParameter("curPage");
    String samount = request.getParameter("amount");

    int curPage = 1;
    int amount = 0;

    curPage = (scurPage == null) ? 1 : Integer.parseInt(scurPage);


// ********** KU
    String sLogicElemOrderBy = ui.getSessionProperty("logic_element_order_by");
    String sOrderBy = request.getParameter("order_by");
    if (sOrderBy == null) {
        if ((null != sLogicElemOrderBy) && ("" != sLogicElemOrderBy)) sOrderBy = sLogicElemOrderBy;
        else sOrderBy = "date";
    }
    ui.setSessionProperty("logic_element_order_by", sOrderBy);

    String sLogicElemPageSize = ui.getSessionProperty("logic_element_page_size");
    if (samount == null) {
        if ((null != sLogicElemPageSize) && ("" != sLogicElemPageSize)) samount = sLogicElemPageSize;
        else samount = "25";
    }
    amount = (samount == null) ? 25 : Integer.parseInt(samount);
    ui.setSessionProperty("logic_element_page_size", samount);

    ui.setSessionProperty("dynamic_elements_section", "3");

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;

    JsonObject data = new JsonObject();
    JsonArray filterList = new JsonArray();

    int filterCount = 0;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        getStatistics(cust);

        try {
            sSql = "EXEC usp_ctgt_filter_list_get_report @cust_id=?, @category_id=?, @start_record=?, @page_size=?, @orderby=?";

            pstmt = conn.prepareStatement(sSql);

            pstmt.setString(1, cust.s_cust_id);
            pstmt.setString(2, sSelectedCategoryId);
            pstmt.setString(3, "1");
            pstmt.setString(4, "1");
            pstmt.setString(5, sOrderBy);

            rs = pstmt.executeQuery();

            String sFilterId = null;
            String sFilterName = null;
            String sModifyDate = null;

            String sClassAppend = "";

            while (rs.next()) {
                if (filterCount % 2 != 0) {
                    sClassAppend = "_other";
                } else {
                    sClassAppend = "";
                }

                filterCount++;

                //Page logic
                if ((filterCount <= (curPage - 1) * amount) || (filterCount > curPage * amount)) continue;

                sFilterId = rs.getString(1);
                sFilterName = new String(rs.getBytes(2), "UTF-8");
                sModifyDate = rs.getString(3);

                data.put("sFilterId", sFilterId);
                data.put("sFilsFilterNamerId", sFilterName);
                data.put("sModifyDate", sModifyDate);

                filterList.put(data);

            }
            rs.close();

            System.out.println("okey");
            out.print(filterList.toString());

        } catch (SQLException sqlex) {
            throw sqlex;
        } finally {
            if (pstmt != null) pstmt.close();
        }
    } catch (Exception ex) {
        throw ex;
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
    }
%>

<%!
    private void getStatistics(Customer cust) throws Exception {
        Vector services = Services.getByCust(ServiceType.RRCP_FILTER_STATISTIC_GET, cust.s_cust_id);
        Service service = (Service) services.get(0);

        ConnectionPool cp = null;
        Connection conn = null;

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
                        if (filter.m_FilterStatistic != null) filter.m_FilterStatistic.save();

                        iStatus = Integer.parseInt(filter.s_status_id);
                        filter.setStatus(iStatus);
                    } catch (SQLException sqlex) {
                        throw sqlex;
                    } catch (Exception ex) {
                        logger.error("Exception", ex);
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
