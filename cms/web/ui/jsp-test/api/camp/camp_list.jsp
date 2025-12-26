<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.adm.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.ctl.*,
                java.util.*,
                java.sql.*,
                java.io.*,
                java.net.*,
                java.text.DateFormat,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%

    //System.out.println("session camp" + session);

    response.setHeader("Expires", "0");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Cache-Control", "max-age=0");
    response.setContentType("text/html; charset=UTF-8");
%>
<%@ include file="header.jsp" %>
<%@ include file="validator.jsp" %>
<%@ page import="org.jcp.xml.dsig.internal.dom.DOMSubTreeData" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%! static Logger logger = null;%>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%

    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
    AccessPermission canRept = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

// ********** JM
    AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);

//Is it the standard ui?
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;
    if (sSelectedCategoryId == null) sSelectedCategoryId = "0";


    String TYPE_ID = request.getParameter("type_id");
    String scurPage = request.getParameter("curPage");
    String samount = request.getParameter("amount");

    String STATUS_ID = request.getParameter("status_id");
    String campaignType = "Error";

    int curPage = 1;
    int amount = 0;

    STATUS_ID = (STATUS_ID == null) ? "-1" : STATUS_ID;
    curPage = (scurPage == null) ? 1 : Integer.parseInt(scurPage);


    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();


    String sAutoQueueDailyFlag = request.getParameter("auto_queue_daily_flag");
    if (sAutoQueueDailyFlag == null) sAutoQueueDailyFlag = "0";

    String sCampTypeLabel = "Standard";
    String sFinishLabel = "Finish Date";
    boolean useEnd = false;
    if (samount == null) samount = ui.getSessionProperty("camp_list_page_size");
    if ((samount == null) || ("".equals(samount))) samount = "25";
    try {
        amount = Integer.parseInt(samount);
    } catch (Exception ex) {
        samount = "25";
        amount = 25;
    }
    ui.setSessionProperty("camp_list_page_size", samount);

    if (TYPE_ID == null) TYPE_ID = ui.getSessionProperty("camp_list_type_id");
    if ((TYPE_ID == null) || ("".equals(TYPE_ID))) TYPE_ID = "2";
    ui.setSessionProperty("camp_list_type_id", TYPE_ID);


    if (TYPE_ID.equals("5")) {
        sCampTypeLabel = "Web/DM/Call";
    } else if (TYPE_ID.equals("4")) {
        sCampTypeLabel = "Automated";
        sFinishLabel = "End Date";
        useEnd = true;
    } else if (TYPE_ID.equals("3")) {
        sCampTypeLabel = "Send To Friend";
        sFinishLabel = "End Date";
        useEnd = true;
    } else if (TYPE_ID.equals("2")) {
        sCampTypeLabel = "Standard";
    }


%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<%

    String s_origin_camp_id;
    String s_camp_id;
    String s_camp_name;
    String s_status_id;
    String s_status_name;
    String s_type_id;
    String s_type_id_name;
    String s_filter_name;
    String s_cont_name;
    String s_created_date;
    String s_modified_date;
    String s_start_date;
    String s_end_date;
    String s_finish_date;
    String d_created_date;
    String d_modified_date;
    String d_start_date;
    String d_end_date;
    String d_finish_date;
    String s_qty_queued;
    String s_qty_sent;
    String s_approval_flag;
    String s_queue_daily_flag;
    String s_sample_qty;
    String s_sample_qty_sent;
    String s_final_flag;
    String s_media_type_id;
    String s_media_type_id_name;

    int recAmount = 0;

    int campCount = 0;

    CampApproveDAO cDAO;
    String sActiveCampId = null;
    String sApproveRestart = null;
    String sCancelConfirm = null;

// added as a part of delivery 6.0 , new button 'Set Done' is added
    String sSetDoneConfirm = null;

    String sClassAppend = "";

// === === ===

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("camp_list.jsp");
        stmt = conn.createStatement();

        String sSql =
                "EXEC usp_cque_camp_list_get_all 1" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        "," + TYPE_ID;

        ResultSet rs = stmt.executeQuery(sSql);

        while (rs.next()) {
            if (campCount == 0) {

            }

            if (campCount % 2 != 0) sClassAppend = "_other";
            else sClassAppend = "";

            campCount++;

            s_origin_camp_id = rs.getString(1);
            s_camp_id = rs.getString(2);
            s_camp_name = new String(rs.getBytes(3), "UTF-8");
            s_status_id = rs.getString(4);
            s_status_name = rs.getString(5);
            s_type_id = rs.getString(6);
            s_type_id_name = rs.getString(7);
            s_filter_name = new String(rs.getBytes(8), "UTF-8");
            s_cont_name = new String(rs.getBytes(9), "UTF-8");
            d_created_date = rs.getString(10);
            d_modified_date = rs.getString(11);
            d_start_date = rs.getString(12);
            d_end_date = rs.getString(13);
            d_finish_date = rs.getString(14);
            s_created_date = rs.getString(15);
            s_modified_date = rs.getString(16);
            s_start_date = rs.getString(17);
            s_end_date = rs.getString(18);
            s_finish_date = rs.getString(19);
            s_qty_queued = rs.getString(20);
            s_qty_sent = rs.getString(21);
            s_approval_flag = rs.getString(22);
            s_queue_daily_flag = rs.getString(23);
            s_sample_qty = rs.getString(24);
            s_sample_qty_sent = rs.getString(25);
            s_final_flag = rs.getString(26);
            s_media_type_id = rs.getString(27);
            s_media_type_id_name = rs.getString(28);

            cDAO = new CampApproveDAO();
            sActiveCampId = cDAO.getActiveCamp(s_origin_camp_id, null);


            if (s_media_type_id_name.equals("Print")) {
                s_media_type_id_name = "SMS";
            }

            data = new JsonObject();

            data.put("s_origin_camp_id", s_origin_camp_id);
            data.put("s_camp_id", s_camp_id);
            data.put("s_camp_name", s_camp_name);
            data.put("s_status_id", s_status_id);
            data.put("s_status_name", s_status_name);
            data.put("s_type_id", s_type_id);
            data.put("s_type_id_name", s_type_id_name);
            data.put("s_filter_name", s_filter_name);
            data.put("s_cont_name", s_cont_name);
            data.put("d_created_date", d_created_date);
            data.put("d_modified_date", d_modified_date);
            data.put("d_created_date", d_created_date);
            data.put("d_start_date", d_start_date);
            data.put("d_end_date", d_end_date);
            data.put("d_finish_date", d_finish_date);
            data.put("s_created_date", s_created_date);
            data.put("s_modified_date", s_modified_date);
            data.put("s_start_date", s_start_date);
            data.put("s_end_date", s_end_date);
            data.put("s_finish_date", s_finish_date);
            data.put("s_qty_queued", s_qty_queued);
            data.put("s_qty_sent", s_qty_sent);
            data.put("s_qty_sent", s_qty_sent);
            data.put("s_approval_flag", s_approval_flag);
            data.put("s_queue_daily_flag", s_queue_daily_flag);
            data.put("s_sample_qty", s_sample_qty);
            data.put("s_sample_qty_sent", s_sample_qty_sent);
            data.put("s_final_flag", s_final_flag);
            data.put("s_media_type_id", s_media_type_id);
            data.put("s_media_type_id_name", s_media_type_id_name);


            array.put(data);

        }
        rs.close();
        if (campCount != 0) {
        }

        recAmount = 0;

        sSql =
                "EXEC usp_cque_camp_list_get_all 2" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        "," + TYPE_ID;

        rs = stmt.executeQuery(sSql);

        campCount = 0;

        s_origin_camp_id = null;
        s_camp_id = null;
        s_camp_name = null;
        s_status_id = null;
        s_status_name = null;
        s_type_id = null;
        s_type_id_name = null;
        s_filter_name = null;
        s_cont_name = null;
        d_created_date = null;
        d_modified_date = null;
        d_start_date = null;
        d_end_date = null;
        d_finish_date = null;
        s_created_date = null;
        s_modified_date = null;
        s_start_date = null;
        s_end_date = null;
        s_finish_date = null;
        s_qty_queued = null;
        s_qty_sent = null;
        s_approval_flag = null;
        s_queue_daily_flag = null;
        s_sample_qty = null;
        s_sample_qty_sent = null;
        s_final_flag = null;
        s_media_type_id = null;
        s_media_type_id_name = null;


        sClassAppend = "";

        while (rs.next()) {
            if (campCount % 2 != 0) sClassAppend = "_other";
            else sClassAppend = "";

            campCount++;

            s_origin_camp_id = rs.getString(1);
            s_camp_id = rs.getString(2);
            s_camp_name = new String(rs.getBytes(3), "UTF-8");
            s_status_id = rs.getString(4);
            s_status_name = rs.getString(5);
            s_type_id = rs.getString(6);
            s_type_id_name = rs.getString(7);
            s_filter_name = new String(rs.getBytes(8), "UTF-8");
            s_cont_name = new String(rs.getBytes(9), "UTF-8");
            d_created_date = rs.getString(10);
            d_modified_date = rs.getString(11);
            d_start_date = rs.getString(12);
            d_end_date = rs.getString(13);
            d_finish_date = rs.getString(14);
            s_created_date = rs.getString(15);
            s_modified_date = rs.getString(16);
            s_start_date = rs.getString(17);
            s_end_date = rs.getString(18);
            s_finish_date = rs.getString(19);
            s_qty_queued = rs.getString(20);
            s_qty_sent = rs.getString(21);
            s_approval_flag = rs.getString(22);
            s_queue_daily_flag = rs.getString(23);
            s_sample_qty = rs.getString(24);
            s_sample_qty_sent = rs.getString(25);
            s_final_flag = rs.getString(26);
            s_media_type_id = rs.getString(27);
            s_media_type_id_name = rs.getString(28);

            if (s_media_type_id_name.equals("Print")) {
                s_media_type_id_name = "SMS";
            }

            data = new JsonObject();

            data.put("s_origin_campId", s_origin_camp_id);
            data.put("s_camp_name", s_camp_name);
            data.put("s_type_id_name", s_type_id_name);
            data.put("s_filter_name", s_filter_name);
            data.put("s_cont_name", s_cont_name);
            data.put("s_modified_date", s_modified_date);
            data.put("s_media_type_id", s_media_type_id);
            data.put("s_media_type_id_name", s_media_type_id_name);
            data.put("s_camp_id", s_camp_id);
            data.put("s_status_id", s_status_id);
            data.put("s_status_name", s_status_name);
            data.put("s_type_id", s_type_id);
            data.put("d_modified_date", d_modified_date);
            data.put("d_created_date", d_created_date);
            data.put("d_start_date", d_start_date);
            data.put("d_end_date", d_end_date);
            data.put("d_finish_date", d_finish_date);
            data.put("s_created_date", s_created_date);
            data.put("s_qty_sent", s_qty_sent);
            data.put("s_end_date", s_end_date);
            data.put("s_finish_date", s_finish_date);
            data.put("s_qty_queued", s_qty_queued);
            data.put("s_start_date", s_start_date);
            data.put("s_approval_flag", s_approval_flag);
            data.put("s_queue_daily_flag", s_queue_daily_flag);
            data.put("s_sample_qty", s_sample_qty);
            data.put("s_final_flag", s_final_flag);
            data.put("s_sample_qty_sent", s_sample_qty_sent);

            array.put(data);


        }
        rs.close();
        if (campCount == 0) {
        }
        recAmount = 0;
        campCount = 0;

        s_origin_camp_id = null;
        s_camp_id = null;
        s_camp_name = null;
        s_status_id = null;
        s_status_name = null;
        s_type_id = null;
        s_type_id_name = null;
        s_filter_name = null;
        s_cont_name = null;
        d_created_date = null;
        d_modified_date = null;
        d_start_date = null;
        d_end_date = null;
        d_finish_date = null;
        s_created_date = null;
        s_modified_date = null;
        s_start_date = null;
        s_end_date = null;
        s_finish_date = null;
        s_qty_queued = null;
        s_qty_sent = null;
        s_approval_flag = null;
        s_queue_daily_flag = null;
        s_sample_qty = null;
        s_sample_qty_sent = null;
        s_final_flag = null;
        s_media_type_id = null;
        s_media_type_id_name = null;


        sSql =
                "EXEC usp_cque_camp_list_get_all 3" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        "," + TYPE_ID;

        rs = stmt.executeQuery(sSql);

        while (rs.next()) {
            if (campCount % 2 != 0) sClassAppend = "_other";
            else sClassAppend = "";

            campCount++;

            s_origin_camp_id = rs.getString(1);
            s_camp_id = rs.getString(2);
            s_camp_name = new String(rs.getBytes(3), "UTF-8");
            s_status_id = rs.getString(4);
            s_status_name = rs.getString(5);
            s_type_id = rs.getString(6);
            s_type_id_name = rs.getString(7);
            s_filter_name = new String(rs.getBytes(8), "UTF-8");
            s_cont_name = new String(rs.getBytes(9), "UTF-8");
            d_created_date = rs.getString(10);
            d_modified_date = rs.getString(11);
            d_start_date = rs.getString(12);
            d_end_date = rs.getString(13);
            d_finish_date = rs.getString(14);
            s_created_date = rs.getString(15);
            s_modified_date = rs.getString(16);
            s_start_date = rs.getString(17);
            s_end_date = rs.getString(18);
            s_finish_date = rs.getString(19);
            s_qty_queued = rs.getString(20);
            s_qty_sent = rs.getString(21);
            s_approval_flag = rs.getString(22);
            s_queue_daily_flag = rs.getString(23);
            s_sample_qty = rs.getString(24);
            s_sample_qty_sent = rs.getString(25);
            s_final_flag = rs.getString(26);
            s_media_type_id = rs.getString(27);
            s_media_type_id_name = rs.getString(28);

            if (s_media_type_id_name.equals("Print")) {
                s_media_type_id_name = "SMS";
            }

            data = new JsonObject();

            data.put("s_origin_camp_id", s_origin_camp_id);
            data.put("s_camp_id", s_camp_id);
            data.put("s_camp_name", s_camp_name);
            data.put("s_status_id", s_status_id);
            data.put("s_status_name", s_status_name);
            data.put("s_type_id", s_type_id);
            data.put("s_type_id_name", s_type_id_name);
            data.put("s_filter_name", s_filter_name);
            data.put("s_cont_name", s_cont_name);
            data.put("d_created_date", d_created_date);
            data.put("d_modified_date", d_modified_date);
            data.put("d_start_date", d_start_date);
            data.put("d_end_date", d_end_date);
            data.put("d_finish_date", d_finish_date);
            data.put("s_created_date", s_created_date);
            data.put("s_modified_date", s_modified_date);
            data.put("s_start_date", s_start_date);
            data.put("s_end_date", s_end_date);
            data.put("s_finish_date", s_finish_date);
            data.put("s_qty_queued", s_qty_queued);
            data.put("s_qty_sent", s_qty_sent);
            data.put("s_approval_flag", s_approval_flag);
            data.put("s_queue_daily_flag", s_queue_daily_flag);
            data.put("s_sample_qty", s_sample_qty);
            data.put("s_sample_qty_sent", s_sample_qty_sent);
            data.put("s_final_flag", s_final_flag);
            data.put("s_media_type_id", s_media_type_id);
            data.put("s_media_type_id_name", s_media_type_id_name);

            array.put(data);


            //Page logic

        }
        rs.close();
        if (campCount == 0) {
        }


        out.println(array);

    } catch (Exception ex) {
        throw ex;
    } finally {
        try {
            if (stmt != null) stmt.close();
        } catch (Exception ex) {
        }
        if (conn != null) cp.free(conn);
    }
%>

