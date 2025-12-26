package com.britemoon.cps.rest;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.adm.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.ctl.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.sql.*;

@Path("/campaign")
public class CamgaignList {

    @GET
    @Path("/recip/{categoryId}/{typeId}/{amount}/{custId}")
    @Produces(MediaType.APPLICATION_JSON)
    public JSONArray getRecipient(@PathParam("categoryId") int categoryId, @PathParam("typeId") int typeId, @PathParam("amount") String amount,
                                  @PathParam("custId") String custId) throws Exception {


/*        User user = null;


        AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
        AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
        AccessPermission canRept = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
        AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);*/

        int amountInt = 0;
        if ((amount == null) || ("".equals(amount))) amount = "25";
        try {
            amountInt = Integer.parseInt(amount);
        } catch (Exception ex) {
            amount = "25";
            amountInt = 25;
        }


        ConnectionPool cp = null;
        Connection conn = null;
        Statement stmt = null;
        int count = 0;

        JSONObject obj1 = new JSONObject();
        JSONArray arr1 = new JSONArray();

        JSONObject obj2 = new JSONObject();
        JSONArray arr2 = new JSONArray();

        JSONObject obj3 = new JSONObject();
        JSONArray arr3 = new JSONArray();

        JSONObject obj4 = new JSONObject();
        JSONArray arr4 = new JSONArray();

        JSONObject obj5 = new JSONObject();
        JSONArray arr5 = new JSONArray();

        JSONObject obj6 = new JSONObject();
        JSONArray arr6 = new JSONArray();

        JSONObject obj7 = new JSONObject();
        JSONArray arr7 = new JSONArray();

        JSONObject obj8 = new JSONObject();
        JSONArray arr8 = new JSONArray();

        JSONObject standardObj = new JSONObject();
        JSONArray standardArr = new JSONArray();


        JSONObject obj9 = new JSONObject();
        JSONArray arr9 = new JSONArray();


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
            conn = cp.getConnection(custId);
            stmt = conn.createStatement();

            String sSql =
                    "EXEC usp_cque_camp_list_get_all 2" +
                            "," + custId +
                            "," + categoryId +
                            ",2";

            ResultSet rs = stmt.executeQuery(sSql);
            count = 0;
            while (rs.next()) {
                count++;

                if (count <= amountInt * 10) {
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

                    obj1 = new JSONObject();


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
                    "EXEC usp_cque_camp_list_get_all 3" +
                            "," + custId +
                            "," + categoryId +
                            ",2";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                count++;

                if (count <= amountInt * 10) {
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

                    obj2 = new JSONObject();

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
            count = 0;
            sSql =
                    "EXEC usp_cque_camp_list_get_all 2" +
                            "," + custId +
                            "," + categoryId +
                            ",3";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                count++;

                if (count <= amountInt * 10) {
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

                    obj3 = new JSONObject();

                    obj3.put("s_origin_camp_id", s_origin_camp_id);
                    obj3.put("s_camp_id", s_camp_id);
                    obj3.put("s_camp_name", s_camp_name);
                    obj3.put("s_status_id", s_status_id);
                    obj3.put("s_status_name", s_status_name);
                    obj3.put("s_type_id", s_type_id);
                    obj3.put("s_type_id_name", s_type_id_name);
                    obj3.put("d_created_date", d_created_date);
                    obj3.put("s_modified_date", d_modified_date);
                    obj3.put("d_start_date", d_start_date);
                    obj3.put("d_end_date", d_end_date);
                    obj3.put("d_finish_date", d_finish_date);
                    obj3.put("s_qty_queued", s_qty_queued);
                    obj3.put("s_qty_sent", s_qty_sent);
                    obj3.put("s_approval_flag", s_approval_flag);
                    obj3.put("s_queue_daily_flag", s_queue_daily_flag);
                    obj3.put("s_sample_qty", s_sample_qty);
                    obj3.put("s_sample_qty_sent", s_sample_qty_sent);
                    obj3.put("s_final_flag", s_final_flag);
                    obj3.put("s_media_type_id", s_media_type_id);
                    obj3.put("s_media_type_id_name", s_media_type_id);
                    obj3.put("s_cont_name", s_cont_name);
                    obj3.put("s_filter_name", s_filter_name);
                    arr3.put(obj3);
                }
            }

            rs.close();
            count = 0;
            sSql =
                    "EXEC usp_cque_camp_list_get_all 3" +
                            "," + custId +
                            "," + categoryId +
                            ",3";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                count++;

                if (count <= amountInt * 10) {
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

                    obj4 = new JSONObject();

                    obj4.put("s_origin_camp_id", s_origin_camp_id);
                    obj4.put("s_camp_id", s_camp_id);
                    obj4.put("s_camp_name", s_camp_name);
                    obj4.put("s_status_id", s_status_id);
                    obj4.put("s_status_name", s_status_name);
                    obj4.put("s_type_id", s_type_id);
                    obj4.put("s_type_id_name", s_type_id_name);
                    obj4.put("d_created_date", d_created_date);
                    obj4.put("s_modified_date", d_modified_date);
                    obj4.put("d_start_date", d_start_date);
                    obj4.put("d_end_date", d_end_date);
                    obj4.put("d_finish_date", d_finish_date);
                    obj4.put("s_qty_queued", s_qty_queued);
                    obj4.put("s_qty_sent", s_qty_sent);
                    obj4.put("s_approval_flag", s_approval_flag);
                    obj4.put("s_queue_daily_flag", s_queue_daily_flag);
                    obj4.put("s_sample_qty", s_sample_qty);
                    obj4.put("s_sample_qty_sent", s_sample_qty_sent);
                    obj4.put("s_final_flag", s_final_flag);
                    obj4.put("s_media_type_id", s_media_type_id);
                    obj4.put("s_media_type_id_name", s_media_type_id);
                    obj4.put("s_cont_name", s_cont_name);
                    obj4.put("s_filter_name", s_filter_name);
                    arr4.put(obj4);
                }
            }
            rs.close();
            count = 0;
            sSql =
                    "EXEC usp_cque_camp_list_get_all 2" +
                            "," + custId +
                            "," + categoryId +
                            ",4";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                count++;

                if (count <= amountInt * 10) {
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

                    obj6 = new JSONObject();

                    obj6.put("s_origin_camp_id", s_origin_camp_id);
                    obj6.put("s_camp_id", s_camp_id);
                    obj6.put("s_camp_name", s_camp_name);
                    obj6.put("s_status_id", s_status_id);
                    obj6.put("s_status_name", s_status_name);
                    obj6.put("s_type_id", s_type_id);
                    obj6.put("s_type_id_name", s_type_id_name);
                    obj6.put("d_created_date", d_created_date);
                    obj6.put("s_modified_date", d_modified_date);
                    obj6.put("d_start_date", d_start_date);
                    obj6.put("d_end_date", d_end_date);
                    obj6.put("d_finish_date", d_finish_date);
                    obj6.put("s_qty_queued", s_qty_queued);
                    obj6.put("s_qty_sent", s_qty_sent);
                    obj6.put("s_approval_flag", s_approval_flag);
                    obj6.put("s_queue_daily_flag", s_queue_daily_flag);
                    obj6.put("s_sample_qty", s_sample_qty);
                    obj6.put("s_sample_qty_sent", s_sample_qty_sent);
                    obj6.put("s_final_flag", s_final_flag);
                    obj6.put("s_media_type_id", s_media_type_id);
                    obj6.put("s_media_type_id_name", s_media_type_id);
                    obj6.put("s_cont_name", s_cont_name);
                    obj6.put("s_filter_name", s_filter_name);
                    arr6.put(obj6);
                }
            }

            rs.close();
            count = 0;
            sSql =
                    "EXEC usp_cque_camp_list_get_all 3" +
                            "," + custId +
                            "," + categoryId +
                            ",4";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                count++;

                if (count <= amountInt * 10) {
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

                    obj5 = new JSONObject();

                    obj5.put("s_origin_camp_id", s_origin_camp_id);
                    obj5.put("s_camp_id", s_camp_id);
                    obj5.put("s_camp_name", s_camp_name);
                    obj5.put("s_status_id", s_status_id);
                    obj5.put("s_status_name", s_status_name);
                    obj5.put("s_type_id", s_type_id);
                    obj5.put("s_type_id_name", s_type_id_name);
                    obj5.put("d_created_date", d_created_date);
                    obj5.put("s_modified_date", d_modified_date);
                    obj5.put("d_start_date", d_start_date);
                    obj5.put("d_end_date", d_end_date);
                    obj5.put("d_finish_date", d_finish_date);
                    obj5.put("s_qty_queued", s_qty_queued);
                    obj5.put("s_qty_sent", s_qty_sent);
                    obj5.put("s_approval_flag", s_approval_flag);
                    obj5.put("s_queue_daily_flag", s_queue_daily_flag);
                    obj5.put("s_sample_qty", s_sample_qty);
                    obj5.put("s_sample_qty_sent", s_sample_qty_sent);
                    obj5.put("s_final_flag", s_final_flag);
                    obj5.put("s_media_type_id", s_media_type_id);
                    obj5.put("s_media_type_id_name", s_media_type_id);
                    obj5.put("s_cont_name", s_cont_name);
                    obj5.put("s_filter_name", s_filter_name);
                    arr5.put(obj5);
                }
            }
            rs.close();


            count = 0;
            sSql =
                    "EXEC usp_cque_camp_list_get_all 2" +
                            "," + custId +
                            "," + categoryId +
                            ",5";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                count++;

                if (count <= amountInt * 10) {
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

                    obj7 = new JSONObject();

                    obj7.put("s_origin_camp_id", s_origin_camp_id);
                    obj7.put("s_camp_id", s_camp_id);
                    obj7.put("s_camp_name", s_camp_name);
                    obj7.put("s_status_id", s_status_id);
                    obj7.put("s_status_name", s_status_name);
                    obj7.put("s_type_id", s_type_id);
                    obj7.put("s_type_id_name", s_type_id_name);
                    obj7.put("d_created_date", d_created_date);
                    obj7.put("s_modified_date", d_modified_date);
                    obj7.put("d_start_date", d_start_date);
                    obj7.put("d_end_date", d_end_date);
                    obj7.put("d_finish_date", d_finish_date);
                    obj7.put("s_qty_queued", s_qty_queued);
                    obj7.put("s_qty_sent", s_qty_sent);
                    obj7.put("s_approval_flag", s_approval_flag);
                    obj7.put("s_queue_daily_flag", s_queue_daily_flag);
                    obj7.put("s_sample_qty", s_sample_qty);
                    obj7.put("s_sample_qty_sent", s_sample_qty_sent);
                    obj7.put("s_final_flag", s_final_flag);
                    obj7.put("s_media_type_id", s_media_type_id);
                    obj7.put("s_media_type_id_name", s_media_type_id);
                    obj7.put("s_cont_name", s_cont_name);
                    obj7.put("s_filter_name", s_filter_name);
                    arr7.put(obj7);
                }
            }

            rs.close();
            count = 0;
            sSql =
                    "EXEC usp_cque_camp_list_get_all 3" +
                            "," + custId +
                            "," + categoryId +
                            ",4";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                count++;

                if (count <= amountInt * 10) {
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

                    obj8 = new JSONObject();

                    obj8.put("s_origin_camp_id", s_origin_camp_id);
                    obj8.put("s_camp_id", s_camp_id);
                    obj8.put("s_camp_name", s_camp_name);
                    obj8.put("s_status_id", s_status_id);
                    obj8.put("s_status_name", s_status_name);
                    obj8.put("s_type_id", s_type_id);
                    obj8.put("s_type_id_name", s_type_id_name);
                    obj8.put("d_created_date", d_created_date);
                    obj8.put("s_modified_date", d_modified_date);
                    obj8.put("d_start_date", d_start_date);
                    obj8.put("d_end_date", d_end_date);
                    obj8.put("d_finish_date", d_finish_date);
                    obj8.put("s_qty_queued", s_qty_queued);
                    obj8.put("s_qty_sent", s_qty_sent);
                    obj8.put("s_approval_flag", s_approval_flag);
                    obj8.put("s_queue_daily_flag", s_queue_daily_flag);
                    obj8.put("s_sample_qty", s_sample_qty);
                    obj8.put("s_sample_qty_sent", s_sample_qty_sent);
                    obj8.put("s_final_flag", s_final_flag);
                    obj8.put("s_media_type_id", s_media_type_id);
                    obj8.put("s_media_type_id_name", s_media_type_id);
                    obj8.put("s_cont_name", s_cont_name);
                    obj8.put("s_filter_name", s_filter_name);
                    arr8.put(obj8);
                }
            }
            rs.close();
            standardObj.put("draftStandard", arr1);
            standardObj.put("completedStandard", arr2);
            standardObj.put("draftS2f", arr3);
            standardObj.put("completedS2f", arr4);
            standardObj.put("draftCheck", arr6);
            standardObj.put("completedCheck", arr5);
            standardObj.put("draftWeb", arr7);
            standardObj.put("completedWeb", arr8);
            standardObj.put("controller", arr9);
            standardArr.put(standardObj);
            return standardArr;
        } catch (Exception ex) {
            System.out.println("Hataaaa: "+ ex.getMessage());

        }
        System.out.println("standardObj: " + standardObj);
        System.out.println("standardArr: " + standardArr);
        return standardArr;

    }
}
