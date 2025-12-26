<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.ctl.*,
                com.britemoon.cps.adm.*,
                com.britemoon.cps.wfl.*,
                org.json.JSONException,
                org.json.JSONObject,
                org.json.XML,
                org.json.JSONArray,
                java.sql.*,
                java.net.*,
                org.apache.log4j.*"
        errorPage="../../utilities/error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>
<%! static Logger logger = null;%>
<%


    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    System.out.println("----------------IMPORTLIST---------------");


    String sCustId = request.getParameter("custId");
    String sCategoryId = request.getParameter("categoryId");

    String sGroupBy = request.getParameter("group_by");

    if (sGroupBy == null) {
        sGroupBy = "import";
    }

    String sOrderBy = request.getParameter("order_by");

    if (sOrderBy == null) {

        sOrderBy = "date";

    }

%>
<%

    System.out.println("burada");

    JSONArray array = new JSONArray();
    JSONArray array2 = new JSONArray();
    JSONArray array3 = new JSONArray();
    JSONArray array4 = new JSONArray();
    JSONObject allData = new JSONObject();

    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {
            Integer batch_id = 0;
            String batch_name = null;


            String batchListNonCategorySqlQuery =
                    "SELECT DISTINCT b.batch_id, b.batch_name \n" +
                            "FROM cupd_batch b with (nolock) \n" +
                            "WHERE b.type_id = 1  \n" +
                            "AND b.batch_id IN (SELECT DISTINCT i.batch_id \n" +
                            "FROM cupd_import i with (nolock), cupd_batch b with (nolock) \n" +
                            "WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE + "\n" +
                            "AND i.batch_id = b.batch_id AND b.cust_id =" + sCustId + "  ) \n" +
                            "AND b.cust_id =" + sCustId + " \n" +
                            "ORDER BY b.batch_id DESC";

            String batchListCategorySqlQuery =
                    "SELECT DISTINCT b.batch_id, b.batch_name \n" +
                            "FROM cupd_batch b with (nolock) \n" +
                            "WHERE b.type_id = 1  \n" +
                            "AND b.batch_id IN (SELECT DISTINCT i.batch_id \n" +
                            "FROM cupd_import i with (nolock), cupd_batch b with (nolock), ccps_object_category oc with (nolock) \n" +
                            "WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE + "\n" +
                            "AND i.batch_id = b.batch_id \n" +
                            "AND b.cust_id =   " + sCustId + " \n" +
                            "AND oc.object_id = i.import_id \n" +
                            "AND oc.type_id =   " + ObjectType.IMPORT + "\n" +
                            "AND oc.cust_id =   " + sCustId + " \n" +
                            "AND oc.category_id = " + sCategoryId + " ) \n" +
                            "AND b.cust_id =   " + sCustId + " \n" +
                            "ORDER BY b.batch_id DESC";


            if (sCategoryId == null || sCategoryId.equals("0")) {

                pstmt = conn.prepareStatement(batchListNonCategorySqlQuery);
                rs = pstmt.executeQuery();

            } else {

                pstmt = conn.prepareStatement(batchListCategorySqlQuery);
                rs = pstmt.executeQuery();

            }

            JSONObject data = new JSONObject();
            while (rs.next()) {

                batch_id = rs.getInt(1);
                batch_name = rs.getString(2);

                data = new JSONObject();
                data.put("batch_id", batch_id);
                data.put("batch_name", batch_name);
                array.put(data);
            }
            rs.close();


            System.out.println("----------BatchList------------");

            String batchListSqlQuery = "SELECT DISTINCT batch_name FROM cupd_batch with (nolock) WHERE batch_id IN (SELECT DISTINCT i.batch_id \n" +
                    "FROM cupd_import i with (nolock), cupd_batch b with (nolock) \n" +
                    "WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE + "\n" +
                    "AND i.batch_id = b.batch_id AND b.cust_id = " + sCustId + "  ) \n" +
                    "AND cust_id =   " + sCustId + "  ORDER BY batch_name";

            pstmt = conn.prepareStatement(batchListSqlQuery);
            rs = pstmt.executeQuery();

            JSONObject data2 = new JSONObject();
            while (rs.next()) {
                batch_name = rs.getString(1);

                data2 = new JSONObject();
                data2.put("batch_name", batch_name);
                array2.put(data2);
            }

            rs.close();


            System.out.println("-----------ImportList---------------");

            Integer import_id = 0;
            String import_name = null;
            String import_date = null;
            String status_name = null;

            String tot_rows = null;
            String badEmails_badRows = null;
            String warning_recips = null;
            String file_dups = null;
            String dup_recips = null;
            String new_recips = null;
            String num_committed = null;
            String left_to_commit = null;
            Integer status_id = 0;

            String importListNonCategorySqlQuery =
                    "SELECT  i.import_id, " +
                            "i.import_name, " +
                            "isnull(convert(varchar(50),i.import_date,100),'') as import_date,\n" +
                            "s.display_name, " +
                            "b.batch_name, " +
                            "ISNULL(st.tot_rows,0) as tot_rows,\n" +
                            "ISNULL(st.bad_emails,0) + ISNULL(st.bad_rows,0) as bad_emails_bad_rows,\n" +
                            "ISNULL(st.warning_recips,0) as warning_recips, " +
                            "ISNULL(st.file_dups,0) as file_dups,\n" +
                            "ISNULL(st.dup_recips,0) as dup_recips, " +
                            "ISNULL(st.new_recips,0) as new_recips,\n" +
                            "ISNULL(st.num_committed,0) as nun_commited, " +
                            "ISNULL(st.left_to_commit,0) as left_to_commit,\n" +
                            "s.status_id FROM cupd_import i with (nolock) \n" +
                            "INNER JOIN cupd_batch b with (nolock) ON i.batch_id = b.batch_id\n" +
                            "AND b.type_id = 1 AND b.cust_id =  " + sCustId + "\n" +
                            "INNER JOIN cupd_import_status s with (nolock) ON i.status_id = s.status_id\n" +
                            "LEFT OUTER JOIN cupd_import_statistics st with (nolock) ON i.import_id = st.import_id\n" +
                            "WHERE i.status_id < " + ImportStatus.COMMIT_COMPLETE + " ORDER BY b.batch_name, i.import_id DESC";

            String importListCategorySqlQuery =
                    "SELECT i.import_id,\n" +
                            "i.import_name,\n" +
                            "isnull(convert(varchar(50),i.import_date,100),'') as import_date,\n" +
                            "s.display_name,\n" +
                            "b.batch_name,\n" +
                            "ISNULL(st.tot_rows,0) as tot_rows,\n" +
                            "ISNULL(st.bad_emails,0) + ISNULL(st.bad_rows,0) as bad_emails_bad_rows,\n" +
                            "ISNULL(st.warning_recips,0) as warning_recips,\n" +
                            "ISNULL(st.file_dups,0) as file_dups,\n" +
                            "ISNULL(st.dup_recips,0) as dup_recips,\n" +
                            "ISNULL(st.new_recips,0) as new_recips,\n" +
                            "ISNULL(st.num_committed,0) as num_committed,\n" +
                            "ISNULL(st.left_to_commit,0) as left_to_commit,\n" +
                            "s.status_id\n" +
                            "FROM cupd_import i with (nolock) \n" +
                            "INNER JOIN cupd_batch b with (nolock) \n" +
                            "ON (i.batch_id = b.batch_id\n" +
                            "AND b.type_id = 1\n" +
                            "AND b.cust_id =   " + sCustId + "  )\n" +
                            "INNER JOIN ccps_object_category c with (nolock)\n" +
                            "ON (i.import_id = c.object_id\n" +
                            "AND c.cust_id =   " + sCustId + "\n" +
                            "AND c.type_id =   " + ObjectType.IMPORT + "\n" +
                            "AND c.category_id =   " + sCategoryId + "  )\n" +
                            "INNER JOIN cupd_import_status s with (nolock) ON i.status_id = s.status_id\n" +
                            "LEFT OUTER JOIN cupd_import_statistics st with (nolock) ON i.import_id = st.import_id\n" +
                            "WHERE i.status_id < " + ImportStatus.COMMIT_COMPLETE + "\n" +
                            "ORDER BY b.batch_name, i.import_id DESC";


            if (sCategoryId == null || sCategoryId.equals("0")) {

                pstmt = conn.prepareStatement(importListNonCategorySqlQuery);
                rs = pstmt.executeQuery();

            } else {

                pstmt = conn.prepareStatement(importListCategorySqlQuery);
                rs = pstmt.executeQuery();

            }

            JSONObject data3 = new JSONObject();
            while (rs.next()) {

                import_id = rs.getInt(1);
                import_name = rs.getString(2);
                import_date = rs.getString(3);
                status_name = rs.getString(4);
                batch_name = rs.getString(5);
                tot_rows = rs.getString(6);
                badEmails_badRows = rs.getString(7);
                warning_recips = rs.getString(8);
                file_dups = rs.getString(9);
                dup_recips = rs.getString(10);
                new_recips = rs.getString(11);
                num_committed = rs.getString(12);
                left_to_commit = rs.getString(13);
                status_id = rs.getInt(14);

                data3 = new JSONObject();
                data3.put("import_id", import_id);
                data3.put("import_name", import_name);
                data3.put("import_date", import_date);
                data3.put("status_name", status_name);
                data3.put("batch_name", batch_name);
                data3.put("tot_rows", tot_rows);
                data3.put("badEmails_badRows", badEmails_badRows);
                data3.put("warning_recips", warning_recips);
                data3.put("file_dups", file_dups);
                data3.put("dup_recips", dup_recips);
                data3.put("new_recips", new_recips);
                data3.put("num_committed", num_committed);
                data3.put("left_to_commit", left_to_commit);
                data3.put("status_id", status_id);
                array3.put(data3);
            }
            rs.close();


            String sSQL = "";

            if ((sCategoryId == null) || (sCategoryId.equals("0"))) {
                sSQL = "SELECT	i.import_id, \n"
                        + " i.import_name, \n"
                        + " isnull(convert(varchar(50),i.import_date,100),'') as show_date, \n "
                        + " s.display_name, \n"
                        + " b.batch_name, \n"
                        + " ISNULL(st.tot_rows,0) as tot_rows, \n"
                        + " ISNULL(st.bad_emails,0) + ISNULL(st.bad_rows,0)as bad_emails_bad_rows, \n"
                        + " ISNULL(st.warning_recips,0) as warning_recips, \n"
                        + " ISNULL(st.file_dups,0) as file_dups, \n"
                        + " ISNULL(st.dup_recips,0) as dup_recips, \n"
                        + " ISNULL(st.new_recips,0) as new_recips, \n"
                        + " ISNULL(st.num_committed,0) as num_commited, \n"
                        + " ISNULL(st.left_to_commit,0) as left_to_commit, \n"
                        + " s.status_id,"
                        + " b.batch_id"
                        + " FROM cupd_import i with (nolock)";


                if (sGroupBy.equals("batch")) {

                    sSQL += " INNER JOIN (cupd_batch b with (nolock) INNER JOIN cupd_import ii with (nolock) ON b.batch_id = ii.batch_id) \n";

                } else {
                    sSQL += " INNER JOIN cupd_batch b with (nolock)";

                }
                sSQL += " ON (i.batch_id = b.batch_id \n"
                        + " AND b.type_id = 1 \n"
                        + " AND b.cust_id = " + sCustId + ") \n"
                        + " INNER JOIN cupd_import_status s with (nolock) ON i.status_id = s.status_id \n"
                        + " LEFT OUTER JOIN cupd_import_statistics st with (nolock) ON i.import_id = st.import_id \n"
                        + " WHERE i.status_id >= " + ImportStatus.COMMIT_COMPLETE
                        + " AND i.status_id <" + ImportStatus.DELETED;

                if (sGroupBy.equals("batch")) {
                    sSQL += " GROUP BY b.batch_name, b.batch_id, i.import_date, i.import_id, i.import_name, s.display_name, b.batch_name, \n"
                            + " st.tot_rows, st.bad_emails, st.bad_rows, st.warning_recips, st.file_dups, st.dup_recips, \n "
                            + " st.new_recips, st.num_committed, st.left_to_commit, s.status_id";

                    if (sOrderBy.equals("name")) {
                        sSQL += "  ORDER BY b.batch_name, i.import_date DESC";

                    } else {
                        sSQL += "  ORDER BY max(ii.import_date) DESC, b.batch_name, i.import_date DESC";

                    }
                } else {
                    if (sOrderBy.equals("name")) {
                        sSQL += "  ORDER BY i.import_name, i.import_date DESC";
                    } else {
                        sSQL += "  ORDER BY i.import_date DESC";
                    }
                }

            } else {

                sSQL = "SELECT	i.import_id,"
                        + " i.import_name,"
                        + " isnull(convert(varchar(50),i.import_date,100),'') as show_date,"
                        + " s.display_name,"
                        + " b.batch_name,"
                        + " ISNULL(st.tot_rows,0),"
                        + " ISNULL(st.bad_emails,0) + ISNULL(st.bad_rows,0),"
                        + " ISNULL(st.warning_recips,0),"
                        + " ISNULL(st.file_dups,0),"
                        + " ISNULL(st.dup_recips,0),"
                        + " ISNULL(st.new_recips,0),"
                        + " ISNULL(st.num_committed,0),"
                        + " ISNULL(st.left_to_commit,0),"
                        + " s.status_id,"
                        + " b.batch_id"
                        + " FROM cupd_import i with (nolock)";

                if (sGroupBy.equals("batch")) {
                    sSQL += " INNER JOIN (cupd_batch b with (nolock) INNER JOIN cupd_import ii with (nolock) ON b.batch_id = ii.batch_id)";
                } else {
                    sSQL += " INNER JOIN cupd_batch b with (nolock)";

                }
                sSQL += " ON (i.batch_id = b.batch_id \n"
                        + " AND b.type_id = 1 \n"
                        + " AND b.cust_id = " + sCustId + ") \n"
                        + " INNER JOIN ccps_object_category c \n"
                        + " ON (i.import_id = c.object_id \n"
                        + " AND c.cust_id = " + sCustId
                        + " AND c.type_id = " + ObjectType.IMPORT
                        + " AND c.category_id = " + sCategoryId + ") \n"
                        + " INNER JOIN cupd_import_status s with (nolock) ON i.status_id = s.status_id \n"
                        + " LEFT OUTER JOIN cupd_import_statistics st with (nolock) ON i.import_id = st.import_id \n"
                        + " WHERE i.status_id >= " + ImportStatus.COMMIT_COMPLETE
                        + " AND i.status_id < " + ImportStatus.DELETED;

                if (sGroupBy.equals("batch")) {
                    sSQL += "  GROUP BY b.batch_name, b.batch_id, i.import_date, i.import_id, i.import_name, s.display_name, b.batch_name, \n"
                            + "  st.tot_rows, st.bad_emails, st.bad_rows, st.warning_recips, st.file_dups, st.dup_recips, \n"
                            + "  st.new_recips, st.num_committed, st.left_to_commit, s.status_id \n"
                            + "  ORDER BY max(ii.import_date) DESC, b.batch_name, i.import_date DESC";
                } else {
                    sSQL += "  ORDER BY i.import_id DESC";
                }

            }
            pstmt = conn.prepareStatement(sSQL);
            rs = pstmt.executeQuery();

            JSONObject data4 = new JSONObject();

            while (rs.next()) {

                import_id = rs.getInt(1);
                import_name = rs.getString(2);
                import_date = rs.getString(3);
                status_name = rs.getString(4);
                batch_name = rs.getString(5);
                tot_rows = rs.getString(6);
                badEmails_badRows = rs.getString(7);
                warning_recips = rs.getString(8);
                file_dups = rs.getString(9);
                dup_recips = rs.getString(10);
                new_recips = rs.getString(11);
                num_committed = rs.getString(12);
                left_to_commit = rs.getString(13);
                status_id = rs.getInt(14);
                batch_id = rs.getInt(15);

                data4 = new JSONObject();
                data4.put("import_id", import_id);
                data4.put("import_name", import_name);
                data4.put("import_date", import_date);
                data4.put("status_name", status_name);
                data4.put("batch_name", batch_name);
                data4.put("tot_rows", tot_rows);
                data4.put("badEmails_badRows", badEmails_badRows);
                data4.put("warning_recips", warning_recips);
                data4.put("file_dups", file_dups);
                data4.put("dup_recips", dup_recips);
                data4.put("new_recips", new_recips);
                data4.put("num_committed", num_committed);
                data4.put("left_to_commit", left_to_commit);
                data4.put("status_id", status_id);
                data4.put("batch_id", batch_id);
                array4.put(data4);
            }

            rs.close();


            allData = new JSONObject();
            allData.put("batchNameAndBatchId", array);
            allData.put("batchList", array2);
            allData.put("importList", array3);
            allData.put("completedImportList", array4);


        } catch (Exception ex) {
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
