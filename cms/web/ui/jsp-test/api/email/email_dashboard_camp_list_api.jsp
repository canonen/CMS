<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.rcp.*,
                java.sql.*,
                java.io.*,
                java.util.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.util.Calendar,
                java.math.BigDecimal,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../../utilities/header.jsp"%>
<%@ include file="../../utilities/validator.jsp" %>
<%

boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    String sCustId = user.s_cust_id;
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;



    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sSql = "";
    String      queryId = request.getParameter("queryId");
    String		customerId		=sCustId;
    String		categoryId	= request.getParameter("categoryId");
    String		typeId		= request.getParameter("typeId");

    String s_origin_camp_id = null;
    String s_camp_id = null;
    String s_camp_name = null;
    String s_status_id = null;
    String s_status_name = null;
    String s_type_id = null;
    String s_type_id_name = null;
    String s_filter_name = null;
    String s_cont_name = null;
    String s_created_date = null;
    String s_modified_date = null;
    String s_start_date = null;
    String s_end_date = null;
    String s_finish_date = null;
    String d_created_date = null;
    String d_modified_date = null;
    String d_start_date = null;
    String d_end_date = null;
    String d_finish_date = null;
    String s_qty_queued = null;
    String s_qty_sent = null;
    String s_approval_flag = null;
    String s_queue_daily_flag = null;
    String s_sample_qty = null;
    String s_sample_qty_sent = null;
    String s_final_flag = null;
    String s_media_type_id = null;
    String s_media_type_id_name = null;

    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();


    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();


       if (typeId != null) { 
           sSql =
                   "EXEC usp_cque_camp_list_get_all "
                             + queryId +
                           "," + customerId +
                           "," + categoryId +
                           "," + typeId + " ";

           resultSet = statement.executeQuery(sSql);
           while (resultSet.next()) {
               s_origin_camp_id = resultSet.getString(1);
               s_camp_id = resultSet.getString(2);
               s_camp_name = new String(resultSet.getBytes(3), "UTF-8");
               s_status_id = resultSet.getString(4);
               s_status_name = resultSet.getString(5);
               s_type_id = resultSet.getString(6);
               s_type_id_name = resultSet.getString(7);
               s_filter_name = new String(resultSet.getBytes(8), "UTF-8");
               s_cont_name = new String(resultSet.getBytes(9), "UTF-8");
               d_created_date = resultSet.getString(10);
               d_modified_date = resultSet.getString(11);
               d_start_date = resultSet.getString(12);
               d_end_date = resultSet.getString(13);
               d_finish_date = resultSet.getString(14);
               s_created_date = resultSet.getString(15);
               s_modified_date = resultSet.getString(16);
               s_start_date = resultSet.getString(17);
               s_end_date = resultSet.getString(18);
               s_finish_date = resultSet.getString(19);
               s_qty_queued = resultSet.getString(20);
               s_qty_sent = resultSet.getString(21);
               s_approval_flag = resultSet.getString(22);
               s_queue_daily_flag = resultSet.getString(23);
               s_sample_qty = resultSet.getString(24);
               s_sample_qty_sent = resultSet.getString(25);
               s_final_flag = resultSet.getString(26);
               s_media_type_id = resultSet.getString(27);
               s_media_type_id_name = resultSet.getString(28);

               JsonObject jsonObject = new JsonObject();
               jsonObject.put("s_origin_camp_id",s_origin_camp_id);
               jsonObject.put("s_camp_id",s_camp_id);
               jsonObject.put("s_camp_name",s_camp_name);
               jsonObject.put("s_status_id",s_status_id);
               jsonObject.put("s_status_name",s_status_name);
               jsonObject.put("s_type_id",s_type_id);
               jsonObject.put("s_type_id_name",s_type_id_name);
               jsonObject.put("s_filter_name",s_filter_name);
               jsonObject.put("s_cont_name",s_cont_name);
               jsonObject.put("d_created_date",d_created_date);
               jsonObject.put("d_modified_date",d_modified_date);
               jsonObject.put("d_start_date",d_start_date);
               jsonObject.put("d_end_date",d_end_date);
               jsonObject.put("d_finish_date",d_finish_date);
               jsonObject.put("s_created_date",s_created_date);
               jsonObject.put("s_modified_date",s_modified_date);
               jsonObject.put("s_start_date",s_start_date);
               jsonObject.put("s_end_date",s_end_date);
               jsonObject.put("s_finish_date",s_finish_date);
               jsonObject.put("s_qty_queued",s_qty_queued);
               jsonObject.put("s_qty_sent",s_qty_sent);
               jsonObject.put("s_approval_flag",s_approval_flag);
               jsonObject.put("s_queue_daily_flag",s_queue_daily_flag);
               jsonObject.put("s_sample_qty",s_sample_qty);
               jsonObject.put("s_sample_qty_sent",s_sample_qty_sent);
               jsonObject.put("s_final_flag",s_final_flag);
               jsonObject.put("s_media_type_id",s_media_type_id);
               jsonObject.put("s_media_type_id_name",s_media_type_id_name);
               array.put(jsonObject);
           }


           resultSet.close();
       }else {
           sSql =
                   "EXEC usp_cque_camp_list_get_all " +
                          queryId +
                           "," + customerId +
                           "," + categoryId +
                           "," + 1;

           resultSet = statement.executeQuery(sSql);
           while (resultSet.next()) {
               s_origin_camp_id = resultSet.getString(1);
               s_camp_id = resultSet.getString(2);
               s_camp_name = new String(resultSet.getBytes(3), "UTF-8");
               s_status_id = resultSet.getString(4);
               s_status_name = resultSet.getString(5);
               s_type_id = resultSet.getString(6);
               s_type_id_name = resultSet.getString(7);
               s_filter_name = new String(resultSet.getBytes(8), "UTF-8");
               s_cont_name = new String(resultSet.getBytes(9), "UTF-8");
               d_created_date = resultSet.getString(10);
               d_modified_date = resultSet.getString(11);
               d_start_date = resultSet.getString(12);
               d_end_date = resultSet.getString(13);
               d_finish_date = resultSet.getString(14);
               s_created_date = resultSet.getString(15);
               s_modified_date = resultSet.getString(16);
               s_start_date = resultSet.getString(17);
               s_end_date = resultSet.getString(18);
               s_finish_date = resultSet.getString(19);
               s_qty_queued = resultSet.getString(20);
               s_qty_sent = resultSet.getString(21);
               s_approval_flag = resultSet.getString(22);
               s_queue_daily_flag = resultSet.getString(23);
               s_sample_qty = resultSet.getString(24);
               s_sample_qty_sent = resultSet.getString(25);
               s_final_flag = resultSet.getString(26);
               s_media_type_id = resultSet.getString(27);
               s_media_type_id_name = resultSet.getString(28);

               JsonObject jsonObject1 = new JsonObject();
               jsonObject1.put("s_origin_camp_id",s_origin_camp_id);
               jsonObject1.put("s_camp_id",s_camp_id);
               jsonObject1.put("s_camp_name",s_camp_name);
               jsonObject1.put("s_status_id",s_status_id);
               jsonObject1.put("s_status_name",s_status_name);
               jsonObject1.put("s_type_id",s_type_id);
               jsonObject1.put("s_type_id_name",s_type_id_name);
               jsonObject1.put("s_filter_name",s_filter_name);
               jsonObject1.put("s_cont_name",s_cont_name);
               jsonObject1.put("d_created_date",d_created_date);
               jsonObject1.put("d_modified_date",d_modified_date);
               jsonObject1.put("d_start_date",d_start_date);
               jsonObject1.put("d_end_date",d_end_date);
               jsonObject1.put("d_finish_date",d_finish_date);
               jsonObject1.put("s_created_date",s_created_date);
               jsonObject1.put("s_modified_date",s_modified_date);
               jsonObject1.put("s_start_date",s_start_date);
               jsonObject1.put("s_end_date",s_end_date);
               jsonObject1.put("s_finish_date",s_finish_date);
               jsonObject1.put("s_qty_queued",s_qty_queued);
               jsonObject1.put("s_qty_sent",s_qty_sent);
               jsonObject1.put("s_approval_flag",s_approval_flag);
               jsonObject1.put("s_queue_daily_flag",s_queue_daily_flag);
               jsonObject1.put("s_sample_qty",s_sample_qty);
               jsonObject1.put("s_sample_qty_sent",s_sample_qty_sent);
               jsonObject1.put("s_final_flag",s_final_flag);
               jsonObject1.put("s_media_type_id",s_media_type_id);
               jsonObject1.put("s_media_type_id_name",s_media_type_id_name);
               array.put(jsonObject1);

           }
           resultSet.close();
           sSql =
                   "EXEC usp_cque_camp_list_get_all " +
                            queryId +
                           "," + customerId +
                           "," + categoryId +
                           "," + 2;

           resultSet = statement.executeQuery(sSql);
           while (resultSet.next()) {
               s_origin_camp_id = resultSet.getString(1);
               s_camp_id = resultSet.getString(2);
               s_camp_name = new String(resultSet.getBytes(3), "UTF-8");
               s_status_id = resultSet.getString(4);
               s_status_name = resultSet.getString(5);
               s_type_id = resultSet.getString(6);
               s_type_id_name = resultSet.getString(7);
               s_filter_name = new String(resultSet.getBytes(8), "UTF-8");
               s_cont_name = new String(resultSet.getBytes(9), "UTF-8");
               d_created_date = resultSet.getString(10);
               d_modified_date = resultSet.getString(11);
               d_start_date = resultSet.getString(12);
               d_end_date = resultSet.getString(13);
               d_finish_date = resultSet.getString(14);
               s_created_date = resultSet.getString(15);
               s_modified_date = resultSet.getString(16);
               s_start_date = resultSet.getString(17);
               s_end_date = resultSet.getString(18);
               s_finish_date = resultSet.getString(19);
               s_qty_queued = resultSet.getString(20);
               s_qty_sent = resultSet.getString(21);
               s_approval_flag = resultSet.getString(22);
               s_queue_daily_flag = resultSet.getString(23);
               s_sample_qty = resultSet.getString(24);
               s_sample_qty_sent = resultSet.getString(25);
               s_final_flag = resultSet.getString(26);
               s_media_type_id = resultSet.getString(27);
               s_media_type_id_name = resultSet.getString(28);

               JsonObject jsonObject2 = new JsonObject();
               jsonObject2.put("s_origin_camp_id",s_origin_camp_id);
               jsonObject2.put("s_camp_id",s_camp_id);
               jsonObject2.put("s_camp_name",s_camp_name);
               jsonObject2.put("s_status_id",s_status_id);
               jsonObject2.put("s_status_name",s_status_name);
               jsonObject2.put("s_type_id",s_type_id);
               jsonObject2.put("s_type_id_name",s_type_id_name);
               jsonObject2.put("s_filter_name",s_filter_name);
               jsonObject2.put("s_cont_name",s_cont_name);
               jsonObject2.put("d_created_date",d_created_date);
               jsonObject2.put("d_modified_date",d_modified_date);
               jsonObject2.put("d_start_date",d_start_date);
               jsonObject2.put("d_end_date",d_end_date);
               jsonObject2.put("d_finish_date",d_finish_date);
               jsonObject2.put("s_created_date",s_created_date);
               jsonObject2.put("s_modified_date",s_modified_date);
               jsonObject2.put("s_start_date",s_start_date);
               jsonObject2.put("s_end_date",s_end_date);
               jsonObject2.put("s_finish_date",s_finish_date);
               jsonObject2.put("s_qty_queued",s_qty_queued);
               jsonObject2.put("s_qty_sent",s_qty_sent);
               jsonObject2.put("s_approval_flag",s_approval_flag);
               jsonObject2.put("s_queue_daily_flag",s_queue_daily_flag);
               jsonObject2.put("s_sample_qty",s_sample_qty);
               jsonObject2.put("s_sample_qty_sent",s_sample_qty_sent);
               jsonObject2.put("s_final_flag",s_final_flag);
               jsonObject2.put("s_media_type_id",s_media_type_id);
               jsonObject2.put("s_media_type_id_name",s_media_type_id_name);
               array.put(jsonObject2);


           }
           resultSet.close();
           sSql =
                   "EXEC usp_cque_camp_list_get_all " +
                           queryId +
                           "," + customerId +
                           "," + categoryId +
                           "," + 3;

           resultSet = statement.executeQuery(sSql);
           while (resultSet.next()) {
               s_origin_camp_id = resultSet.getString(1);
               s_camp_id = resultSet.getString(2);
               s_camp_name = new String(resultSet.getBytes(3), "UTF-8");
               s_status_id = resultSet.getString(4);
               s_status_name = resultSet.getString(5);
               s_type_id = resultSet.getString(6);
               s_type_id_name = resultSet.getString(7);
               s_filter_name = new String(resultSet.getBytes(8), "UTF-8");
               s_cont_name = new String(resultSet.getBytes(9), "UTF-8");
               d_created_date = resultSet.getString(10);
               d_modified_date = resultSet.getString(11);
               d_start_date = resultSet.getString(12);
               d_end_date = resultSet.getString(13);
               d_finish_date = resultSet.getString(14);
               s_created_date = resultSet.getString(15);
               s_modified_date = resultSet.getString(16);
               s_start_date = resultSet.getString(17);
               s_end_date = resultSet.getString(18);
               s_finish_date = resultSet.getString(19);
               s_qty_queued = resultSet.getString(20);
               s_qty_sent = resultSet.getString(21);
               s_approval_flag = resultSet.getString(22);
               s_queue_daily_flag = resultSet.getString(23);
               s_sample_qty = resultSet.getString(24);
               s_sample_qty_sent = resultSet.getString(25);
               s_final_flag = resultSet.getString(26);
               s_media_type_id = resultSet.getString(27);
               s_media_type_id_name = resultSet.getString(28);

               JsonObject jsonObject3 = new JsonObject();
               jsonObject3.put("s_origin_camp_id",s_origin_camp_id);
               jsonObject3.put("s_camp_id",s_camp_id);
               jsonObject3.put("s_camp_name",s_camp_name);
               jsonObject3.put("s_status_id",s_status_id);
               jsonObject3.put("s_status_name",s_status_name);
               jsonObject3.put("s_type_id",s_type_id);
               jsonObject3.put("s_type_id_name",s_type_id_name);
               jsonObject3.put("s_filter_name",s_filter_name);
               jsonObject3.put("s_cont_name",s_cont_name);
               jsonObject3.put("d_created_date",d_created_date);
               jsonObject3.put("d_modified_date",d_modified_date);
               jsonObject3.put("d_start_date",d_start_date);
               jsonObject3.put("d_end_date",d_end_date);
               jsonObject3.put("d_finish_date",d_finish_date);
               jsonObject3.put("s_created_date",s_created_date);
               jsonObject3.put("s_modified_date",s_modified_date);
               jsonObject3.put("s_start_date",s_start_date);
               jsonObject3.put("s_end_date",s_end_date);
               jsonObject3.put("s_finish_date",s_finish_date);
               jsonObject3.put("s_qty_queued",s_qty_queued);
               jsonObject3.put("s_qty_sent",s_qty_sent);
               jsonObject3.put("s_approval_flag",s_approval_flag);
               jsonObject3.put("s_queue_daily_flag",s_queue_daily_flag);
               jsonObject3.put("s_sample_qty",s_sample_qty);
               jsonObject3.put("s_sample_qty_sent",s_sample_qty_sent);
               jsonObject3.put("s_final_flag",s_final_flag);
               jsonObject3.put("s_media_type_id",s_media_type_id);
               jsonObject3.put("s_media_type_id_name",s_media_type_id_name);
               array.put(jsonObject3);


           }
           resultSet.close();
           sSql =
                   "EXEC usp_cque_camp_list_get_all " +
                            queryId +
                           "," + customerId +
                           "," + categoryId +
                           "," + 4;

           resultSet = statement.executeQuery(sSql);
           while (resultSet.next()) {
               s_origin_camp_id = resultSet.getString(1);
               s_camp_id = resultSet.getString(2);
               s_camp_name = new String(resultSet.getBytes(3), "UTF-8");
               s_status_id = resultSet.getString(4);
               s_status_name = resultSet.getString(5);
               s_type_id = resultSet.getString(6);
               s_type_id_name = resultSet.getString(7);
               s_filter_name = new String(resultSet.getBytes(8), "UTF-8");
               s_cont_name = new String(resultSet.getBytes(9), "UTF-8");
               d_created_date = resultSet.getString(10);
               d_modified_date = resultSet.getString(11);
               d_start_date = resultSet.getString(12);
               d_end_date = resultSet.getString(13);
               d_finish_date = resultSet.getString(14);
               s_created_date = resultSet.getString(15);
               s_modified_date = resultSet.getString(16);
               s_start_date = resultSet.getString(17);
               s_end_date = resultSet.getString(18);
               s_finish_date = resultSet.getString(19);
               s_qty_queued = resultSet.getString(20);
               s_qty_sent = resultSet.getString(21);
               s_approval_flag = resultSet.getString(22);
               s_queue_daily_flag = resultSet.getString(23);
               s_sample_qty = resultSet.getString(24);
               s_sample_qty_sent = resultSet.getString(25);
               s_final_flag = resultSet.getString(26);
               s_media_type_id = resultSet.getString(27);
               s_media_type_id_name = resultSet.getString(28);

               JsonObject jsonObject4 = new JsonObject();
               jsonObject4.put("s_origin_camp_id",s_origin_camp_id);
               jsonObject4.put("s_camp_id",s_camp_id);
               jsonObject4.put("s_camp_name",s_camp_name);
               jsonObject4.put("s_status_id",s_status_id);
               jsonObject4.put("s_status_name",s_status_name);
               jsonObject4.put("s_type_id",s_type_id);
               jsonObject4.put("s_type_id_name",s_type_id_name);
               jsonObject4.put("s_filter_name",s_filter_name);
               jsonObject4.put("s_cont_name",s_cont_name);
               jsonObject4.put("d_created_date",d_created_date);
               jsonObject4.put("d_modified_date",d_modified_date);
               jsonObject4.put("d_start_date",d_start_date);
               jsonObject4.put("d_end_date",d_end_date);
               jsonObject4.put("d_finish_date",d_finish_date);
               jsonObject4.put("s_created_date",s_created_date);
               jsonObject4.put("s_modified_date",s_modified_date);
               jsonObject4.put("s_start_date",s_start_date);
               jsonObject4.put("s_end_date",s_end_date);
               jsonObject4.put("s_finish_date",s_finish_date);
               jsonObject4.put("s_qty_queued",s_qty_queued);
               jsonObject4.put("s_qty_sent",s_qty_sent);
               jsonObject4.put("s_approval_flag",s_approval_flag);
               jsonObject4.put("s_queue_daily_flag",s_queue_daily_flag);
               jsonObject4.put("s_sample_qty",s_sample_qty);
               jsonObject4.put("s_sample_qty_sent",s_sample_qty_sent);
               jsonObject4.put("s_final_flag",s_final_flag);
               jsonObject4.put("s_media_type_id",s_media_type_id);
               jsonObject4.put("s_media_type_id_name",s_media_type_id_name);
               array.put(jsonObject4);


           }
           resultSet.close();
           sSql =
                   "EXEC usp_cque_camp_list_get_all " +
                            queryId +
                           "," + customerId +
                           "," + categoryId +
                           "," + 5;

           resultSet = statement.executeQuery(sSql);
           while (resultSet.next()) {
               s_origin_camp_id = resultSet.getString(1);
               s_camp_id = resultSet.getString(2);
               s_camp_name = new String(resultSet.getBytes(3), "UTF-8");
               s_status_id = resultSet.getString(4);
               s_status_name = resultSet.getString(5);
               s_type_id = resultSet.getString(6);
               s_type_id_name = resultSet.getString(7);
               s_filter_name = new String(resultSet.getBytes(8), "UTF-8");
               s_cont_name = new String(resultSet.getBytes(9), "UTF-8");
               d_created_date = resultSet.getString(10);
               d_modified_date = resultSet.getString(11);
               d_start_date = resultSet.getString(12);
               d_end_date = resultSet.getString(13);
               d_finish_date = resultSet.getString(14);
               s_created_date = resultSet.getString(15);
               s_modified_date = resultSet.getString(16);
               s_start_date = resultSet.getString(17);
               s_end_date = resultSet.getString(18);
               s_finish_date = resultSet.getString(19);
               s_qty_queued = resultSet.getString(20);
               s_qty_sent = resultSet.getString(21);
               s_approval_flag = resultSet.getString(22);
               s_queue_daily_flag = resultSet.getString(23);
               s_sample_qty = resultSet.getString(24);
               s_sample_qty_sent = resultSet.getString(25);
               s_final_flag = resultSet.getString(26);
               s_media_type_id = resultSet.getString(27);
               s_media_type_id_name = resultSet.getString(28);

               JsonObject jsonObject5 = new JsonObject();
               jsonObject5.put("s_origin_camp_id",s_origin_camp_id);
               jsonObject5.put("s_camp_id",s_camp_id);
               jsonObject5.put("s_camp_name",s_camp_name);
               jsonObject5.put("s_status_id",s_status_id);
               jsonObject5.put("s_status_name",s_status_name);
               jsonObject5.put("s_type_id",s_type_id);
               jsonObject5.put("s_type_id_name",s_type_id_name);
               jsonObject5.put("s_filter_name",s_filter_name);
               jsonObject5.put("s_cont_name",s_cont_name);
               jsonObject5.put("d_created_date",d_created_date);
               jsonObject5.put("d_modified_date",d_modified_date);
               jsonObject5.put("d_start_date",d_start_date);
               jsonObject5.put("d_end_date",d_end_date);
               jsonObject5.put("d_finish_date",d_finish_date);
               jsonObject5.put("s_created_date",s_created_date);
               jsonObject5.put("s_modified_date",s_modified_date);
               jsonObject5.put("s_start_date",s_start_date);
               jsonObject5.put("s_end_date",s_end_date);
               jsonObject5.put("s_finish_date",s_finish_date);
               jsonObject5.put("s_qty_queued",s_qty_queued);
               jsonObject5.put("s_qty_sent",s_qty_sent);
               jsonObject5.put("s_approval_flag",s_approval_flag);
               jsonObject5.put("s_queue_daily_flag",s_queue_daily_flag);
               jsonObject5.put("s_sample_qty",s_sample_qty);
               jsonObject5.put("s_sample_qty_sent",s_sample_qty_sent);
               jsonObject5.put("s_final_flag",s_final_flag);
               jsonObject5.put("s_media_type_id",s_media_type_id);
               jsonObject5.put("s_media_type_id_name",s_media_type_id_name);
               array.put(jsonObject5);


           }
           resultSet.close();
       }

    }
    catch (Exception exception){
        System.out.println(exception.getMessage());
        exception.printStackTrace();

    }
    
    data.put("data",array);
    

    out.print(data);


%>