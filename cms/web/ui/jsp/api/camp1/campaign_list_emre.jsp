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
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="java.util.Date" %>

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

    JsonObject obj0 = new JsonObject();
    JsonArray arr0 = new JsonArray();

    JsonObject obj1 = new JsonObject();
    JsonArray arr1 = new JsonArray();

    JsonObject obj2 = new JsonObject();
    JsonArray arr2 = new JsonArray();

    JsonObject obj3 = new JsonObject();
    JsonArray arr3 = new JsonArray();

    JsonObject obj4 = new JsonObject();
    JsonArray arr4 = new JsonArray();

    JsonObject obj5 = new JsonObject();
    JsonArray arr5 = new JsonArray();

    JsonObject obj6 = new JsonObject();
    JsonArray arr6 = new JsonArray();

    JsonObject obj7 = new JsonObject();
    JsonArray arr7 = new JsonArray();

    JsonObject obj8 = new JsonObject();
    JsonArray arr8 = new JsonArray();

    JsonObject standardObj = new JsonObject();
    JsonArray standardArr = new JsonArray();

    boolean canS2F = ui.getFeatureAccess(Feature.S2F_CAMP);
    boolean canAutoCamp = ui.getFeatureAccess(Feature.AUTO_CAMP);
    boolean canWebDMCall = ui.getFeatureAccess(Feature.WEB_DM_CALL);
    boolean canPrint = ui.getFeatureAccess(Feature.PRINT_ENABLED);

    JsonObject obj9 = new JsonObject();
    JsonArray arr9 = new JsonArray();

    obj9.put("canS2F", canS2F);
    obj9.put("canAutoCamp", canAutoCamp);
    obj9.put("canWebDMCall", canWebDMCall);
    obj9.put("canPrint", canPrint);

    arr9.put(obj9);

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

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql =
                "EXEC usp_cque_camp_list_get_all_fast_2005 1" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        "," + TYPE_ID;

        ResultSet rs = stmt.executeQuery(sSql);
        count = 0;
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
            d_created_date = dateFormatter(rs.getString(10));
            d_modified_date = dateFormatter(rs.getString(11));
            d_start_date = dateFormatter(rs.getString(12));
            d_end_date = dateFormatter(rs.getString(13));
            d_finish_date = dateFormatter(rs.getString(14));
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
//            s_final_flag = rs.getString(26);
//            s_media_type_id = rs.getString(27);
            s_media_type_id_name = rs.getString(28);

            cDAO = new CampApproveDAO();
            sActiveCampId = cDAO.getActiveCamp(s_origin_camp_id, null);


            if (s_media_type_id_name.equals("Print")) {
                s_media_type_id_name = "SMS";
            }
            obj0 = new JsonObject();
            obj0.put("s_origin_camp_id", s_origin_camp_id);
            obj0.put("s_camp_id", s_camp_id);
            obj0.put("s_camp_name", s_camp_name);
            obj0.put("s_status_id", s_status_id);
            obj0.put("s_status_name", s_status_name);
            obj0.put("s_type_id", s_type_id);
            obj0.put("s_type_id_name", s_type_id_name);
            obj0.put("s_filter_name", s_filter_name);
            obj0.put("s_cont_name", s_cont_name);
            obj0.put("d_created_date", d_created_date);
            obj0.put("d_modified_date", d_modified_date);
            obj0.put("d_start_date", d_start_date);
            obj0.put("d_end_date", d_end_date);
            obj0.put("d_finish_date", d_finish_date);
            obj0.put("s_created_date", s_created_date);
            obj0.put("s_modified_date", s_modified_date);
            obj0.put("s_start_date", s_start_date);
            obj0.put("s_end_date", s_end_date);
            obj0.put("s_finish_date", s_finish_date);
            obj0.put("s_qty_queued", s_qty_queued);
            obj0.put("s_qty_sent", s_qty_sent);
            obj0.put("s_approval_flag", s_approval_flag);
            obj0.put("s_queue_daily_flag", s_queue_daily_flag);
            obj0.put("s_sample_qty", s_sample_qty);
            obj0.put("s_sample_qty_sent", s_sample_qty_sent);
//            obj0.put("s_final_flag", s_final_flag);
//            obj0.put("s_media_type_id", s_media_type_id);
            obj0.put("s_media_type_id_name", s_media_type_id_name);
            arr0.put(obj0);

        }
        rs.close();
        count = 0;
        sSql =
                "EXEC usp_cque_camp_list_get_all_fast_2005 2" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        "," + TYPE_ID;

        rs = stmt.executeQuery(sSql);
        while (rs.next()) {
            count++;

            if (count <= amount * 10) {
                s_origin_camp_id = rs.getString(1);
                s_camp_id = rs.getString(2);
                s_camp_name = new String(rs.getBytes(3), "UTF-8");
                s_status_id = rs.getString(4);
                s_status_name = rs.getString(5);
                s_type_id = rs.getString(6);
                s_type_id_name = rs.getString(7);
                s_filter_name = new String(rs.getBytes(8), "UTF-8");
                s_cont_name = new String(rs.getBytes(9), "UTF-8");
                d_created_date = dateFormatter(rs.getString(10));
                d_modified_date = dateFormatter(rs.getString(11));
                d_start_date = dateFormatter(rs.getString(12));
                d_end_date = dateFormatter(rs.getString(13));
                d_finish_date = dateFormatter(rs.getString(14));
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

                obj1 = new JsonObject();

                obj1.put("s_origin_camp_id", s_origin_camp_id);
                obj1.put("s_camp_id", s_camp_id);
                obj1.put("s_camp_name", s_camp_name);
                obj1.put("s_status_id", s_status_id);
                obj1.put("s_status_name", s_status_name);
                obj1.put("s_type_id", s_type_id);
                obj1.put("s_type_id_name", s_type_id_name);
                obj1.put("d_created_date", d_created_date);
                obj1.put("s_modified_date", d_modified_date);
                obj1.put("d_start_date", d_start_date);
                obj1.put("d_end_date", d_end_date);
                obj1.put("d_finish_date", d_finish_date);
                obj1.put("s_qty_queued", s_qty_queued);
                obj1.put("s_qty_sent", s_qty_sent);
                obj1.put("s_approval_flag", s_approval_flag);
                obj1.put("s_queue_daily_flag", s_queue_daily_flag);
                obj1.put("s_sample_qty", s_sample_qty);
                obj1.put("s_sample_qty_sent", s_sample_qty_sent);
                obj1.put("s_final_flag", s_final_flag);
                obj1.put("s_media_type_id", s_media_type_id);
                obj1.put("s_media_type_id_name", s_media_type_id);
                obj1.put("s_cont_name", s_cont_name);
                obj1.put("s_filter_name", s_filter_name);
                arr1.put(obj1);
            }
        }

        rs.close();
        count = 0;
        sSql =
                "EXEC usp_cque_camp_list_get_all_fast_2005 3" +
                        "," + cust.s_cust_id +
                        "," + sSelectedCategoryId +
                        "," + TYPE_ID;

        rs = stmt.executeQuery(sSql);

        while (rs.next()) {
            count++;

            if (count <= amount * 10) {
                s_origin_camp_id = rs.getString(1);
                s_camp_id = rs.getString(2);
                s_camp_name = new String(rs.getBytes(3), "UTF-8");
                s_status_id = rs.getString(4);
                s_status_name = rs.getString(5);
                s_type_id = rs.getString(6);
                s_type_id_name = rs.getString(7);
                s_filter_name = new String(rs.getBytes(8), "UTF-8");
                s_cont_name = new String(rs.getBytes(9), "UTF-8");
                d_created_date = dateFormatter(rs.getString(10));
                d_modified_date = dateFormatter(rs.getString(11));
                d_start_date = dateFormatter(rs.getString(12));
                d_end_date = dateFormatter(rs.getString(13));
                d_finish_date = dateFormatter(rs.getString(14));
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

                obj2 = new JsonObject();

                obj2.put("s_origin_camp_id", s_origin_camp_id);
                obj2.put("s_camp_id", s_camp_id);
                obj2.put("s_camp_name", s_camp_name);
                obj2.put("s_status_id", s_status_id);
                obj2.put("s_status_name", s_status_name);
                obj2.put("s_type_id", s_type_id);
                obj2.put("s_type_id_name", s_type_id_name);
                obj2.put("d_created_date", d_created_date);
                obj2.put("s_modified_date", d_modified_date);
                obj2.put("d_start_date", d_start_date);
                obj2.put("d_end_date", d_end_date);
                obj2.put("d_finish_date", d_finish_date);
                obj2.put("s_qty_queued", s_qty_queued);
                obj2.put("s_qty_sent", s_qty_sent);
                obj2.put("s_approval_flag", s_approval_flag);
                obj2.put("s_queue_daily_flag", s_queue_daily_flag);
                obj2.put("s_sample_qty", s_sample_qty);
                obj2.put("s_sample_qty_sent", s_sample_qty_sent);
                obj2.put("s_final_flag", s_final_flag);
                obj2.put("s_media_type_id", s_media_type_id);
                obj2.put("s_media_type_id_name", s_media_type_id);
                obj2.put("s_cont_name", s_cont_name);
                obj2.put("s_filter_name", s_filter_name);
                arr2.put(obj2);
            }
        }

        rs.close();

        standardObj.put("currentCampaign", arr0);
        standardObj.put("draftStandard", arr1);
        standardObj.put("completedStandard", arr2);
        standardObj.put("controller", arr9);
        standardArr.put(standardObj);
        out.print(standardArr);
    } catch (Exception ex) {
        throw ex;
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }

%>

<%!
    private static final SimpleDateFormat FORMATTER =
            new SimpleDateFormat("yyyy-MM-dd HH:mm");
    private static final SimpleDateFormat OUT_FMT =
            new SimpleDateFormat("yyyy-MM-dd HH:mm");

    private static final SimpleDateFormat[] IN_FMT = new SimpleDateFormat[]{
            new SimpleDateFormat("MMM d yyyy h:mma", Locale.ENGLISH),
            new SimpleDateFormat("MMM d yyyy hh:mma", Locale.ENGLISH),
            new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"),
            new SimpleDateFormat("yyyy-MM-dd HH:mm"),
            new SimpleDateFormat("yyyy/MM/dd HH:mm:ss"),
            new SimpleDateFormat("yyyy/MM/dd"),
            new SimpleDateFormat("yyyy-MM-dd")
    };


    private String dateFormatter(java.sql.Timestamp ts) {
        try {
            if (ts == null) return "";
            return FORMATTER.format(ts);
        } catch (Exception ex) {
            return "HATA: Tarih formatı dönüştürülemedi!";
        }
    }

    private String dateFormatter(String raw) {
        if (raw == null || raw.trim().isEmpty() || raw.equals("---"))
            return "---";

        raw = raw.trim().replaceAll("\\s{2,}", " ");
        raw = raw.replace("/", "-").replace(".", "-");

        for (int i = 0; i < IN_FMT.length; i++) {
            try {
                Date d = IN_FMT[i].parse(raw);
                return OUT_FMT.format(d);
            } catch (ParseException ignored) { }
        }

        return "HATA: Tarih formatı dönüştürülemedi! (" + raw + ")";
    }
%>
