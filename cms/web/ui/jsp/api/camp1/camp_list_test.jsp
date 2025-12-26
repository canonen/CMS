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
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>

<%! static Logger logger = null;%>


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
    AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);

    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    String sSelectedCategoryId = request.getParameter("category_id");

    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;
    if (sSelectedCategoryId == null) sSelectedCategoryId = "0";

    String TYPE_ID = request.getParameter("type_id");
    String samount = request.getParameter("amount");

    int amount = 0;

    if ((samount == null) || ("".equals(samount))) samount = "25";

    try {
        amount = Integer.parseInt(samount);
    } catch (Exception ex) {
        samount = "25";
        amount = 25;
    }

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    int count = 0;

    CampApproveDAO cDAO;
    String sActiveCampId = null;

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
     
    JsonObject draftStandardObject = new JsonObject();
    JsonArray draftStandardArr = new JsonArray();

    JsonObject currentStandardObj = new JsonObject();
    JsonArray currentStandardArr = new JsonArray();

    JsonObject doneStandardObj = new JsonObject();
    JsonArray doneStandardArr = new JsonArray();

    JsonObject currentAutomatedObj = new JsonObject();
    JsonArray currentAutomatedArr = new JsonArray();

    JsonObject draftAutomatedObj = new JsonObject();
    JsonArray draftAutomatedArr = new JsonArray();

    JsonObject doneAutomatedObj = new JsonObject();
    JsonArray doneAutomatedArr = new JsonArray();

    JsonArray allCurrent = new JsonArray();
    JsonArray allDraft = new JsonArray();
    JsonArray allDone = new JsonArray();

    JsonObject allData = new JsonObject();
    JsonArray allData1 = new JsonArray();  
    

        try{

            cp = ConnectionPool.getInstance();
            conn = cp.getConnection(this);
            stmt = conn.createStatement();
            count = 0;
            String sSql =
                "EXEC usp_cque_camp_list_get_all 2" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        ",2";
            ResultSet rs = stmt.executeQuery(sSql);

            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        
            while (rs.next()) {


      
                s_origin_camp_id = rs.getString(1);
                s_camp_id = rs.getString(2);
                s_camp_name = new String(rs.getBytes(3), "UTF-8");
                s_status_id = rs.getString(4);
                s_status_name = rs.getString(5);
                s_type_id = rs.getString(6);
                s_type_id_name = rs.getString(7);
                s_filter_name = new String(rs.getBytes(8), "UTF-8");
                s_cont_name = new String(rs.getBytes(9), "UTF-8");
//                d_created_date = rs.getString(10);
                d_created_date = dateFormatter(rs.getTimestamp(10));
                d_modified_date = dateFormatter(rs.getTimestamp(11));
                d_start_date = dateFormatter(rs.getTimestamp(12));
                d_end_date = dateFormatter(rs.getTimestamp(13));
                d_finish_date = dateFormatter(rs.getTimestamp(14));
                s_created_date = dateFormatter(rs.getString(15));
                s_modified_date = dateFormatter(rs.getString(16));
                s_start_date = dateFormatter(rs.getString(17));
                s_end_date = dateFormatter(rs.getString(18));
                s_finish_date = dateFormatter(rs.getString(19));
                s_qty_queued = rs.getString(20);
                s_qty_sent = rs.getString(21);
                s_approval_flag = rs.getString(22);
                s_queue_daily_flag = rs.getString(23);
                s_sample_qty = rs.getString(24);
                s_sample_qty_sent = rs.getString(25);
                s_final_flag = rs.getString(26);
                s_media_type_id = rs.getString(27);
                s_media_type_id_name = rs.getString(28);

                draftStandardObject = new JsonObject();

                draftStandardObject.put("s_origin_camp_id", s_origin_camp_id);
                draftStandardObject.put("s_camp_id", s_camp_id);
                draftStandardObject.put("s_camp_name", s_camp_name);
                draftStandardObject.put("s_status_id", s_status_id);
                draftStandardObject.put("s_status_name", s_status_name);
                draftStandardObject.put("s_type_id", s_type_id);
                draftStandardObject.put("s_type_id_name", s_type_id_name);
                draftStandardObject.put("d_created_date", d_created_date);
                draftStandardObject.put("s_modified_date", d_modified_date);
                draftStandardObject.put("d_start_date", d_start_date);
                draftStandardObject.put("d_end_date", d_end_date);
                draftStandardObject.put("d_finish_date", d_finish_date);
                draftStandardObject.put("s_qty_queued", s_qty_queued);
                draftStandardObject.put("s_qty_sent", s_qty_sent);
                draftStandardObject.put("s_approval_flag", s_approval_flag);
                draftStandardObject.put("s_queue_daily_flag", s_queue_daily_flag);
                draftStandardObject.put("s_sample_qty", s_sample_qty);
                draftStandardObject.put("s_sample_qty_sent", s_sample_qty_sent);
                draftStandardObject.put("s_final_flag", s_final_flag);
                draftStandardObject.put("s_media_type_id", s_media_type_id);
                draftStandardObject.put("s_media_type_id_name", s_media_type_id);
                draftStandardObject.put("s_cont_name", s_cont_name);
                draftStandardObject.put("s_filter_name", s_filter_name);
                draftStandardArr.put(draftStandardObject);
            
            }
            rs.close();

            sSql = "EXEC usp_cque_camp_list_get_all 1" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        ",2";
            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                count++;

                s_origin_camp_id = rs.getString(1);
                s_camp_id = rs.getString(2);
                s_camp_name = new String(rs.getBytes(3), "UTF-8");
                s_status_id = rs.getString(4);
                s_status_name = rs.getString(5);
                s_type_id = rs.getString(6);
                s_type_id_name = rs.getString(7);
                s_filter_name = new String(rs.getBytes(8), "UTF-8");
                s_cont_name = new String(rs.getBytes(9), "UTF-8");
                d_created_date = dateFormatter(rs.getTimestamp(10));
                d_modified_date = dateFormatter(rs.getTimestamp(11));
                d_start_date = dateFormatter(rs.getTimestamp(12));
                d_end_date = dateFormatter(rs.getTimestamp(13));
                d_finish_date = dateFormatter(rs.getTimestamp(14));
                s_created_date = dateFormatter(rs.getString(15));
                s_modified_date = dateFormatter(rs.getString(16));
                s_start_date = dateFormatter(rs.getString(17));
                s_end_date = dateFormatter(rs.getString(18));
                s_finish_date = dateFormatter(rs.getString(19));
                s_qty_queued = rs.getString(20);
                s_qty_sent = rs.getString(21);
                s_approval_flag = rs.getString(22);
                s_queue_daily_flag = rs.getString(23);
                s_sample_qty = rs.getString(24);
                s_sample_qty_sent = rs.getString(25);
                s_final_flag = rs.getString(26);
                s_media_type_id = rs.getString(27);
                s_media_type_id_name = rs.getString(28);


                currentStandardObj = new JsonObject();
                currentStandardObj.put("s_origin_camp_id", s_origin_camp_id);
                currentStandardObj.put("s_camp_id", s_camp_id);
                currentStandardObj.put("s_camp_name", s_camp_name);
                currentStandardObj.put("s_status_id", s_status_id);
                currentStandardObj.put("s_status_name", s_status_name);
                currentStandardObj.put("s_type_id", s_type_id);
                currentStandardObj.put("s_type_id_name", s_type_id_name);
                currentStandardObj.put("s_filter_name", s_filter_name);
                currentStandardObj.put("s_cont_name", s_cont_name);
                currentStandardObj.put("d_created_date", d_created_date);
                currentStandardObj.put("d_modified_date", d_modified_date);
                currentStandardObj.put("d_start_date", d_start_date);
                currentStandardObj.put("d_end_date", d_end_date);
                currentStandardObj.put("d_finish_date", d_finish_date);
                currentStandardObj.put("s_created_date", s_created_date);
                currentStandardObj.put("s_modified_date", s_modified_date);
                currentStandardObj.put("s_start_date", s_start_date);
                currentStandardObj.put("s_end_date", s_end_date);
                currentStandardObj.put("s_finish_date", s_finish_date);
                currentStandardObj.put("s_qty_queued", s_qty_queued);
                currentStandardObj.put("s_qty_sent", s_qty_sent);
                currentStandardObj.put("s_approval_flag", s_approval_flag);
                currentStandardObj.put("s_queue_daily_flag", s_queue_daily_flag);
                currentStandardObj.put("s_sample_qty", s_sample_qty);
                currentStandardObj.put("s_sample_qty_sent", s_sample_qty_sent);
                currentStandardObj.put("s_final_flag", s_final_flag);
                currentStandardObj.put("s_media_type_id", s_media_type_id);
                currentStandardObj.put("s_media_type_id_name", s_media_type_id_name);
                currentStandardArr.put(currentStandardObj);

            }
            rs.close();

            sSql =
                "EXEC usp_cque_camp_list_get_all 3" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        ",2";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                s_origin_camp_id = rs.getString(1);
                s_camp_id = rs.getString(2);
                s_camp_name = new String(rs.getBytes(3), "UTF-8");
                s_status_id = rs.getString(4);
                s_status_name = rs.getString(5);
                s_type_id = rs.getString(6);
                s_type_id_name = rs.getString(7);
                s_filter_name = new String(rs.getBytes(8), "UTF-8");
                s_cont_name = new String(rs.getBytes(9), "UTF-8");
                d_created_date = dateFormatter(rs.getTimestamp(10));
                d_modified_date = dateFormatter(rs.getTimestamp(11));
                d_start_date = dateFormatter(rs.getTimestamp(12));
                d_end_date = dateFormatter(rs.getTimestamp(13));
                d_finish_date = dateFormatter(rs.getTimestamp(14));
                s_created_date = dateFormatter(rs.getString(15));
                s_modified_date = dateFormatter(rs.getString(16));
                s_start_date = dateFormatter(rs.getString(17));
                s_end_date = dateFormatter(rs.getString(18));
                s_finish_date = dateFormatter(rs.getString(19));
                s_qty_queued = rs.getString(20);
                s_qty_sent = rs.getString(21);
                s_approval_flag = rs.getString(22);
                s_queue_daily_flag = rs.getString(23);
                s_sample_qty = rs.getString(24);
                s_sample_qty_sent = rs.getString(25);
                s_final_flag = rs.getString(26);
                s_media_type_id = rs.getString(27);
                s_media_type_id_name = rs.getString(28);

                doneStandardObj = new JsonObject();

                doneStandardObj.put("s_origin_camp_id", s_origin_camp_id);
                doneStandardObj.put("s_camp_id", s_camp_id);
                doneStandardObj.put("s_camp_name", s_camp_name);
                doneStandardObj.put("s_status_id", s_status_id);
                doneStandardObj.put("s_status_name", s_status_name);
                doneStandardObj.put("s_type_id", s_type_id);
                doneStandardObj.put("s_type_id_name", s_type_id_name);
                doneStandardObj.put("d_created_date", d_created_date);
                doneStandardObj.put("s_modified_date", d_modified_date);
                doneStandardObj.put("d_start_date", d_start_date);
                doneStandardObj.put("d_end_date", d_end_date);
                doneStandardObj.put("d_finish_date", d_finish_date);
                doneStandardObj.put("s_qty_queued", s_qty_queued);
                doneStandardObj.put("s_qty_sent", s_qty_sent);
                doneStandardObj.put("s_approval_flag", s_approval_flag);
                doneStandardObj.put("s_queue_daily_flag", s_queue_daily_flag);
                doneStandardObj.put("s_sample_qty", s_sample_qty);
                doneStandardObj.put("s_sample_qty_sent", s_sample_qty_sent);
                doneStandardObj.put("s_final_flag", s_final_flag);
                doneStandardObj.put("s_media_type_id", s_media_type_id);
                doneStandardObj.put("s_media_type_id_name", s_media_type_id);
                doneStandardObj.put("s_cont_name", s_cont_name);
                doneStandardObj.put("s_filter_name", s_filter_name);
                doneStandardArr.put(doneStandardObj);
            }
            rs.close();

            sSql =
                "EXEC usp_cque_camp_list_get_all 1" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        ",4";
            rs = stmt.executeQuery(sSql);
        
            while (rs.next()) {
                s_origin_camp_id = rs.getString(1);
                s_camp_id = rs.getString(2);
                s_camp_name = new String(rs.getBytes(3), "UTF-8");
                s_status_id = rs.getString(4);
                s_status_name = rs.getString(5);
                s_type_id = rs.getString(6);
                s_type_id_name = rs.getString(7);
                s_filter_name = new String(rs.getBytes(8), "UTF-8");
                s_cont_name = new String(rs.getBytes(9), "UTF-8");
                d_created_date = dateFormatter(rs.getTimestamp(10));
                d_modified_date = dateFormatter(rs.getTimestamp(11));
                d_start_date = dateFormatter(rs.getTimestamp(12));
                d_end_date = dateFormatter(rs.getTimestamp(13));
                d_finish_date = dateFormatter(rs.getTimestamp(14));
                s_created_date = dateFormatter(rs.getString(15));
                s_modified_date = dateFormatter(rs.getString(16));
                s_start_date = dateFormatter(rs.getString(17));
                s_end_date = dateFormatter(rs.getString(18));
                s_finish_date = dateFormatter(rs.getString(19));
                s_qty_queued = rs.getString(20);
                s_qty_sent = rs.getString(21);
                s_approval_flag = rs.getString(22);
                s_queue_daily_flag = rs.getString(23);
                s_sample_qty = rs.getString(24);
                s_sample_qty_sent = rs.getString(25);
                s_final_flag = rs.getString(26);
                s_media_type_id = rs.getString(27);
                s_media_type_id_name = rs.getString(28);

                currentAutomatedObj = new JsonObject();

                currentAutomatedObj.put("s_origin_camp_id", s_origin_camp_id);
                currentAutomatedObj.put("s_camp_id", s_camp_id);
                currentAutomatedObj.put("s_camp_name", s_camp_name);
                currentAutomatedObj.put("s_status_id", s_status_id);
                currentAutomatedObj.put("s_status_name", s_status_name);
                currentAutomatedObj.put("s_type_id", s_type_id);
                currentAutomatedObj.put("s_type_id_name", s_type_id_name);
                currentAutomatedObj.put("d_created_date", d_created_date);
                currentAutomatedObj.put("s_modified_date", d_modified_date);
                currentAutomatedObj.put("d_start_date", d_start_date);
                currentAutomatedObj.put("d_end_date", d_end_date);
                currentAutomatedObj.put("d_finish_date", d_finish_date);
                currentAutomatedObj.put("s_qty_queued", s_qty_queued);
                currentAutomatedObj.put("s_qty_sent", s_qty_sent);
                currentAutomatedObj.put("s_approval_flag", s_approval_flag);
                currentAutomatedObj.put("s_queue_daily_flag", s_queue_daily_flag);
                currentAutomatedObj.put("s_sample_qty", s_sample_qty);
                currentAutomatedObj.put("s_sample_qty_sent", s_sample_qty_sent);
                currentAutomatedObj.put("s_final_flag", s_final_flag);
                currentAutomatedObj.put("s_media_type_id", s_media_type_id);
                currentAutomatedObj.put("s_media_type_id_name", s_media_type_id);
                currentAutomatedObj.put("s_cont_name", s_cont_name);
                currentAutomatedObj.put("s_filter_name", s_filter_name);
                currentAutomatedArr.put(currentAutomatedObj);
            
            }
            rs.close();

            sSql =
                "EXEC usp_cque_camp_list_get_all 2" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        ",4";
            rs = stmt.executeQuery(sSql);
        
            while (rs.next()) {

                s_origin_camp_id = rs.getString(1);
                s_camp_id = rs.getString(2);
                s_camp_name = new String(rs.getBytes(3), "UTF-8");
                s_status_id = rs.getString(4);
                s_status_name = rs.getString(5);
                s_type_id = rs.getString(6);
                s_type_id_name = rs.getString(7);
                s_filter_name = new String(rs.getBytes(8), "UTF-8");
                s_cont_name = new String(rs.getBytes(9), "UTF-8");
                d_created_date = dateFormatter(rs.getTimestamp(10));
                d_modified_date = dateFormatter(rs.getTimestamp(11));
                d_start_date = dateFormatter(rs.getTimestamp(12));
                d_end_date = dateFormatter(rs.getTimestamp(13));
                d_finish_date = dateFormatter(rs.getTimestamp(14));
                s_created_date = dateFormatter(rs.getString(15));
                s_modified_date = dateFormatter(rs.getString(16));
                s_start_date = dateFormatter(rs.getString(17));
                s_end_date = dateFormatter(rs.getString(18));
                s_finish_date = dateFormatter(rs.getString(19));
                s_qty_queued = rs.getString(20);
                s_qty_sent = rs.getString(21);
                s_approval_flag = rs.getString(22);
                s_queue_daily_flag = rs.getString(23);
                s_sample_qty = rs.getString(24);
                s_sample_qty_sent = rs.getString(25);
                s_final_flag = rs.getString(26);
                s_media_type_id = rs.getString(27);
                s_media_type_id_name = rs.getString(28);

                draftAutomatedObj = new JsonObject();

                draftAutomatedObj.put("s_origin_camp_id", s_origin_camp_id);
                draftAutomatedObj.put("s_camp_id", s_camp_id);
                draftAutomatedObj.put("s_camp_name", s_camp_name);
                draftAutomatedObj.put("s_status_id", s_status_id);
                draftAutomatedObj.put("s_status_name", s_status_name);
                draftAutomatedObj.put("s_type_id", s_type_id);
                draftAutomatedObj.put("s_type_id_name", s_type_id_name);
                draftAutomatedObj.put("d_created_date", d_created_date);
                draftAutomatedObj.put("s_modified_date", d_modified_date);
                draftAutomatedObj.put("d_start_date", d_start_date);
                draftAutomatedObj.put("d_end_date", d_end_date);
                draftAutomatedObj.put("d_finish_date", d_finish_date);
                draftAutomatedObj.put("s_qty_queued", s_qty_queued);
                draftAutomatedObj.put("s_qty_sent", s_qty_sent);
                draftAutomatedObj.put("s_approval_flag", s_approval_flag);
                draftAutomatedObj.put("s_queue_daily_flag", s_queue_daily_flag);
                draftAutomatedObj.put("s_sample_qty", s_sample_qty);
                draftAutomatedObj.put("s_sample_qty_sent", s_sample_qty_sent);
                draftAutomatedObj.put("s_final_flag", s_final_flag);
                draftAutomatedObj.put("s_media_type_id", s_media_type_id);
                draftAutomatedObj.put("s_media_type_id_name", s_media_type_id);
                draftAutomatedObj.put("s_cont_name", s_cont_name);
                draftAutomatedObj.put("s_filter_name", s_filter_name);
                draftAutomatedArr.put(draftAutomatedObj);
            
            }
            rs.close();

            sSql =  "EXEC usp_cque_camp_list_get_all 3" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        ",4";
            rs = stmt.executeQuery(sSql);
        
            while (rs.next()) {

                s_origin_camp_id = rs.getString(1);
                s_camp_id = rs.getString(2);
                s_camp_name = new String(rs.getBytes(3), "UTF-8");
                s_status_id = rs.getString(4);
                s_status_name = rs.getString(5);
                s_type_id = rs.getString(6);
                s_type_id_name = rs.getString(7);
                s_filter_name = new String(rs.getBytes(8), "UTF-8");
                s_cont_name = new String(rs.getBytes(9), "UTF-8");
                d_created_date = dateFormatter(rs.getTimestamp(10));
                d_modified_date = dateFormatter(rs.getTimestamp(11));
                d_start_date = dateFormatter(rs.getTimestamp(12));
                d_end_date = dateFormatter(rs.getTimestamp(13));
                d_finish_date = dateFormatter(rs.getTimestamp(14));
                s_created_date = dateFormatter(rs.getString(15));
                s_modified_date = dateFormatter(rs.getString(16));
                s_start_date = dateFormatter(rs.getString(17));
                s_end_date = dateFormatter(rs.getString(18));
                s_finish_date = dateFormatter(rs.getString(19));
                s_qty_queued = rs.getString(20);
                s_qty_sent = rs.getString(21);
                s_approval_flag = rs.getString(22);
                s_queue_daily_flag = rs.getString(23);
                s_sample_qty = rs.getString(24);
                s_sample_qty_sent = rs.getString(25);
                s_final_flag = rs.getString(26);
                s_media_type_id = rs.getString(27);
                s_media_type_id_name = rs.getString(28);

                doneAutomatedObj = new JsonObject();

                doneAutomatedObj.put("s_origin_camp_id", s_origin_camp_id);
                doneAutomatedObj.put("s_camp_id", s_camp_id);
                doneAutomatedObj.put("s_camp_name", s_camp_name);
                doneAutomatedObj.put("s_status_id", s_status_id);
                doneAutomatedObj.put("s_status_name", s_status_name);
                doneAutomatedObj.put("s_type_id", s_type_id);
                doneAutomatedObj.put("s_type_id_name", s_type_id_name);
                doneAutomatedObj.put("d_created_date", d_created_date);
                doneAutomatedObj.put("s_modified_date", d_modified_date);
                doneAutomatedObj.put("d_start_date", d_start_date);
                doneAutomatedObj.put("d_end_date", d_end_date);
                doneAutomatedObj.put("d_finish_date", d_finish_date);
                doneAutomatedObj.put("s_qty_queued", s_qty_queued);
                doneAutomatedObj.put("s_qty_sent", s_qty_sent);
                doneAutomatedObj.put("s_approval_flag", s_approval_flag);
                doneAutomatedObj.put("s_queue_daily_flag", s_queue_daily_flag);
                doneAutomatedObj.put("s_sample_qty", s_sample_qty);
                doneAutomatedObj.put("s_sample_qty_sent", s_sample_qty_sent);
                doneAutomatedObj.put("s_final_flag", s_final_flag);
                doneAutomatedObj.put("s_media_type_id", s_media_type_id);
                doneAutomatedObj.put("s_media_type_id_name", s_media_type_id);
                doneAutomatedObj.put("s_cont_name", s_cont_name);
                doneAutomatedObj.put("s_filter_name", s_filter_name);
                doneAutomatedArr.put(doneAutomatedObj);
            
            }
            rs.close();

            //allCurrent = mergeJsonArrays(currentStandardArr,currentAutomatedArr);
            //allDraft = mergeJsonArrays(draftStandardArr,draftAutomatedArr);
            //allDone = mergeJsonArrays(doneStandardArr,doneAutomatedArr);

            allData.put("draftStandard",draftStandardArr);
            allData.put("currentStandard",currentStandardArr);
            allData.put("doneStandard",doneStandardArr);
            allData.put("currentAutomated",currentAutomatedArr);
            allData.put("draftAutomated",draftAutomatedArr);
            allData.put("doneAutomated",doneAutomatedArr);
            allData1.put(allData);
            //allData.put("allCurrent",allCurrent);
            //allData.put("allDraft",allDraft);
            //allData.put("allDone",allDone);

            out.print(allData1);
        }catch (Exception ex) {
        throw ex;
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
    
    
%>

<%!
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private String dateFormatter(Timestamp ts) {
        try {
            return (ts != null) ? ts.toLocalDateTime().format(formatter) : null;
        } catch (Exception ex) {
            // Tarih formatlama hatası için belirgin mesaj
            return "HATA: Tarih formatı dönüştürülemedi! (" + ex.getMessage() + ")";
        }
    }
%>

<%!
    private static final DateTimeFormatter IN =
            DateTimeFormatter.ofPattern("MMM d yyyy h:mma", Locale.ENGLISH);

    private static final DateTimeFormatter OUT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private String dateFormatter(String raw) {
        if (raw == null || raw.isEmpty() || raw.equals("---"))
            return "---";

        try {

            String cleanedRaw = raw.trim().replaceAll("\\s{2,}", " ");
            return LocalDateTime.parse(cleanedRaw, IN).format(OUT);
        } catch (Exception ex) {
            // Hata durumunda mesaj döndür
            return "HATA: Tarih formatı dönüştürülemedi! (" + ex.getMessage() + ")";
        }
    }
%>