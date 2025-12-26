<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="javax.lang.model.element.Element" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>


<%! static Logger logger = null;%>

<%
        if (logger == null) {
            logger = Logger.getLogger(this.getClass().getName());
        }

        AccessPermission can = user.getAccessPermission(ObjectType.FILTER);
        boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);

        boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

        if (!can.bRead) {
            response.sendRedirect("../../access_denied.jsp");
            return;
        }

        String sCustId= request.getParameter("cust_id");

        AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

        String sSelectedCategoryId = request.getParameter("category_id");
        if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(sCustId))) //cust.s_cust_id
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
        if ((sAmount == null) || sAmount.trim().equals("")) sAmount = "25";

        int amount = 25;
        try {
            amount = Integer.parseInt(sAmount);
        } catch (Exception ex) {
        }

        ui.setSessionProperty("target_group_page_size", sAmount);
%>
<%
    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    System.out.println("burada");

    JsonArray array = new JsonArray();
    JsonObject allData = new JsonObject();

    int filterCount = 0;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {

            String sSql =
                    " EXEC usp_ctgt_filter_list_get_orderby" +
                            " @cust_id=?, @category_id=?, @start_record=?, @page_size=?, @orderby=?";

            pstmt = conn.prepareStatement(sSql);

            pstmt.setString(1, sCustId);
            pstmt.setString(2, sSelectedCategoryId);
            pstmt.setString(3, "1");
            pstmt.setString(4, "1");
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

            String sClassAppend = "";

            JsonObject data = new JsonObject();

            while (rs.next()) {
                if (filterCount % 2 != 0) sClassAppend = "_other";
                else sClassAppend = "";

                filterCount++;

                //Page logic
                if ((filterCount <= (curPage - 1) * amount) || (filterCount > curPage * amount))
                    continue;

                sFilterId = rs.getString(1);
                sFilterName = new String(rs.getBytes(2), "UTF-8");
                sFinishDate = rs.getString(3);
                sRecipQty = rs.getString(4);
                sPrintRecipQty = rs.getString(5);
                iStatusId = rs.getInt(6);
                sStatusName = rs.getString(7);
                sAprvlStatusFlag = rs.getString(8);

                data = new JsonObject();
                data.put("filter_id", sFilterId);
                data.put("filter_name", sFilterName);
                data.put("finish_date", sFinishDate);
                data.put("recip_qty", sRecipQty);
                data.put("print_recip_qty", sPrintRecipQty);
                data.put("status_id", iStatusId);
                data.put("status_name", sStatusName);
                data.put("aprvl_status_flag", sAprvlStatusFlag);
                array.put(data);
            }

            allData = new JsonObject();
            allData.put("Segmentation", array);

            System.out.println(allData.toString());
            out.print(allData.toString());
            rs.close();


        } catch (Exception ex) {
            System.out.println(ex.getMessage());
            throw ex;


        } finally {
            if (pstmt != null) pstmt.close();
        }
    } catch (SQLException sqlex) {
        throw sqlex;
    } finally {
        if (conn != null) cp.free(conn);
    }
%>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
    out.print(allData);
%>


