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

  if (sSelectedCategoryId == null){
    sSelectedCategoryId = "0";
  }

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

  JsonObject standardObj = new JsonObject();
  JsonArray standardArr = new JsonArray();
  JsonObject obj = new JsonObject();
  JsonObject obj2 = new JsonObject();
  JsonObject obj3 = new JsonObject();

  JsonArray arr1 = new JsonArray();
  JsonArray arr2 = new JsonArray();
  JsonArray arr3 = new JsonArray();
  String[] typeIds = {"2", "3", "4", "5"};
  String sSql=null;

  try {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);
    stmt = conn.createStatement();
    ResultSet rs=null;

    for (String TYPE_ID : typeIds) {
      sSql = "EXEC usp_cque_camp_list_get_all 1" +
              "," + cust.s_cust_id +
              "," + sSelectedCategoryId +
              "," + TYPE_ID;

      rs = stmt.executeQuery(sSql);

      while (rs.next()) {
        obj = new JsonObject();
        obj.put("s_origin_camp_id", rs.getString(1));
        obj.put("s_camp_id", rs.getString(2));
        obj.put("s_camp_name", new String(rs.getBytes(3), "UTF-8"));
        obj.put("s_status_id", rs.getString(4));
        obj.put("s_status_name", rs.getString(5));
        obj.put("s_type_id", rs.getString(6));
        obj.put("s_type_id_name", rs.getString(7));
        obj.put("s_filter_name", new String(rs.getBytes(8), "UTF-8"));
        obj.put("s_cont_name", new String(rs.getBytes(9), "UTF-8"));
        obj.put("d_created_date", rs.getString(10));
        obj.put("d_modified_date", rs.getString(11));
        obj.put("d_start_date", rs.getString(12));
        obj.put("d_end_date", rs.getString(13));
        obj.put("d_finish_date", rs.getString(14));
        obj.put("s_created_date", rs.getString(15));
        obj.put("s_modified_date", rs.getString(16));
        obj.put("s_start_date", rs.getString(17));
        obj.put("s_end_date", rs.getString(18));
        obj.put("s_finish_date", rs.getString(19));
        obj.put("s_qty_queued", rs.getString(20));
        obj.put("s_qty_sent", rs.getString(21));
        obj.put("s_approval_flag", rs.getString(22));
        obj.put("s_queue_daily_flag", rs.getString(23));
        obj.put("s_sample_qty", rs.getString(24));
        obj.put("s_sample_qty_sent", rs.getString(25));
        obj.put("s_final_flag", rs.getString(26));
        obj.put("s_media_type_id", rs.getString(27));
        obj.put("s_media_type_id_name", rs.getString(28));

        String categorySqlQuery = "SELECT category_id FROM ccps_object_category WHERE cust_id = ? AND object_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(categorySqlQuery);
        pstmt.setString(1, cust.s_cust_id);
        pstmt.setString(2, rs.getString(2));

        ResultSet categoryRs = pstmt.executeQuery();
        while (categoryRs.next()) {
          obj.put("category_id", categoryRs.getString(1));
        }
        arr1.put(obj);
      }
      rs.close();

      sSql = "EXEC usp_cque_camp_list_get_all 2" +
              "," + cust.s_cust_id +
              "," + sSelectedCategoryId +
              "," + TYPE_ID;

      rs = stmt.executeQuery(sSql);

      while (rs.next()) {
        obj2 = new JsonObject();
        obj2.put("s_origin_camp_id", rs.getString(1));
        obj2.put("s_camp_id", rs.getString(2));
        obj2.put("s_camp_name", new String(rs.getBytes(3), "UTF-8"));
        obj2.put("s_status_id", rs.getString(4));
        obj2.put("s_status_name", rs.getString(5));
        obj2.put("s_type_id", rs.getString(6));
        obj2.put("s_type_id_name", rs.getString(7));
        obj2.put("s_filter_name", new String(rs.getBytes(8), "UTF-8"));
        obj2.put("s_cont_name", new String(rs.getBytes(9), "UTF-8"));
        obj2.put("d_created_date", rs.getString(10));
        obj2.put("d_modified_date", rs.getString(11));
        obj2.put("d_start_date", rs.getString(12));
        obj2.put("d_end_date", rs.getString(13));
        obj2.put("d_finish_date", rs.getString(14));
        obj2.put("s_created_date", rs.getString(15));
        obj2.put("s_modified_date", rs.getString(16));
        obj2.put("s_start_date", rs.getString(17));
        obj2.put("s_end_date", rs.getString(18));
        obj2.put("s_finish_date", rs.getString(19));
        obj2.put("s_qty_queued", rs.getString(20));
        obj2.put("s_qty_sent", rs.getString(21));
        obj2.put("s_approval_flag", rs.getString(22));
        obj2.put("s_queue_daily_flag", rs.getString(23));
        obj2.put("s_sample_qty", rs.getString(24));
        obj2.put("s_sample_qty_sent", rs.getString(25));
        obj2.put("s_final_flag", rs.getString(26));
        obj2.put("s_media_type_id", rs.getString(27));
        obj2.put("s_media_type_id_name", rs.getString(28));

        String categorySqlQuery = "SELECT category_id FROM ccps_object_category WHERE cust_id = ? AND object_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(categorySqlQuery);
        pstmt.setString(1, cust.s_cust_id);
        pstmt.setString(2, rs.getString(2));

        ResultSet categoryRs = pstmt.executeQuery();
        while (categoryRs.next()) {
          obj2.put("category_id", categoryRs.getString(1));
        }
        arr2.put(obj2);
      }
      rs.close();

      sSql = "EXEC usp_cque_camp_list_get_all 3" +
              "," + cust.s_cust_id +
              "," + sSelectedCategoryId +
              "," + TYPE_ID;

      rs = stmt.executeQuery(sSql);

      while (rs.next()) {
        obj3 = new JsonObject();
        obj3.put("s_origin_camp_id", rs.getString(1));
        obj3.put("s_camp_id", rs.getString(2));
        obj3.put("s_camp_name", new String(rs.getBytes(3), "UTF-8"));
        obj3.put("s_status_id", rs.getString(4));
        obj3.put("s_status_name", rs.getString(5));
        obj3.put("s_type_id", rs.getString(6));
        obj3.put("s_type_id_name", rs.getString(7));
        obj3.put("s_filter_name", new String(rs.getBytes(8), "UTF-8"));
        obj3.put("s_cont_name", new String(rs.getBytes(9), "UTF-8"));
        obj3.put("d_created_date", rs.getString(10));
        obj3.put("d_modified_date", rs.getString(11));
        obj3.put("d_start_date", rs.getString(12));
        obj3.put("d_end_date", rs.getString(13));
        obj3.put("d_finish_date", rs.getString(14));
        obj3.put("s_created_date", rs.getString(15));
        obj3.put("s_modified_date", rs.getString(16));
        obj3.put("s_start_date", rs.getString(17));
        obj3.put("s_end_date", rs.getString(18));
        obj3.put("s_finish_date", rs.getString(19));
        obj3.put("s_qty_queued", rs.getString(20));
        obj3.put("s_qty_sent", rs.getString(21));
        obj3.put("s_approval_flag", rs.getString(22));
        obj3.put("s_queue_daily_flag", rs.getString(23));
        obj3.put("s_sample_qty", rs.getString(24));
        obj3.put("s_sample_qty_sent", rs.getString(25));
        obj3.put("s_final_flag", rs.getString(26));
        obj3.put("s_media_type_id", rs.getString(27));
        obj3.put("s_media_type_id_name", rs.getString(28));

        String categorySqlQuery = "SELECT category_id FROM ccps_object_category WHERE cust_id = ? AND object_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(categorySqlQuery);
        pstmt.setString(1, cust.s_cust_id);
        pstmt.setString(2, rs.getString(2));

        ResultSet categoryRs = pstmt.executeQuery();
        while (categoryRs.next()) {
          obj3.put("category_id", categoryRs.getString(1));
        }
        arr3.put(obj3);
      }
      rs.close();
    }

    standardObj.put("current_campaigns", arr1);
    standardObj.put("draft_campaigns",arr2);
    standardObj.put("completed_campaigns",arr3);
    standardArr.put(standardObj);
    out.print(standardArr);
  } catch (Exception ex) {
    throw ex;
  } finally {
    if (stmt != null) stmt.close();
    if (conn != null) cp.free(conn);
  }
%>
