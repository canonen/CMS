<%@ page
        language="java"
        import="com.britemoon.cps.*,
                com.britemoon.*,
                com.britemoon.cps.ctl.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                org.apache.log4j.*"
        errorPage="../../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    System.out.println("----------------IMPORTLIST---------------");

    String sCustId = request.getParameter("custId");
    String sCategoryId = request.getParameter("categoryId");

    String sImportListGroupBy = ui.getSessionProperty("import_list_group_by");
    String sGroupBy = request.getParameter("group_by");
    if (sGroupBy == null)
    {
        if ((null != sImportListGroupBy) && ("" != sImportListGroupBy))
        {
            sGroupBy = sImportListGroupBy;
        }
        else
        {
            sGroupBy = "import";
        }
    }


    ui.setSessionProperty("import_list_group_by", sGroupBy);

    String sImportListOrderBy = ui.getSessionProperty("import_list_order_by");
    String sOrderBy = request.getParameter("order_by");
    if (sOrderBy == null)
    {
        if ((null != sImportListOrderBy) && ("" != sImportListOrderBy))
        {
            sOrderBy = sImportListOrderBy;
        }
        else
        {
            sOrderBy = "date";
        }
    }

    ui.setSessionProperty("import_list_order_by", sOrderBy);

    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;
%>
<%

    try {

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        Integer batchId = 0;
        String batchName = null;

        if (sCategoryId == null || sCategoryId.equals("0")) {

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

            resultSet = statement.executeQuery(batchListNonCategorySqlQuery);

            JSONArray array = new JSONArray();

            while (resultSet.next()) {
                batchId = resultSet.getInt(1);
                batchName = resultSet.getString(2);

                JSONObject data = new JSONObject();
                data.put("batch_id", batchId);
                data.put("batch_name", batchName);
                array.put(data);
            }
            JSONObject dataObject = new JSONObject();
            dataObject.put("BatchListNonCategory", array);

            resultSet.close();

            out.print(dataObject);

        } else {

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
                            "AND oc.cust_id =   "+sCustId+ " \n" +
                            "AND oc.category_id = " + sCategoryId + " ) \n" +
                            "AND b.cust_id =   " + sCustId + " \n" +
                            "ORDER BY b.batch_id DESC";


            resultSet = statement.executeQuery(batchListCategorySqlQuery);

            JSONArray array2 = new JSONArray();

            while (resultSet.next()) {
                batchId = resultSet.getInt(1);
                batchName = resultSet.getString(2);

                JSONObject data2 = new JSONObject();
                data2.put("batch_id", batchId);
                data2.put("batch_name", batchName);
                array2.put(data2);
            }
            JSONObject dataObject2 = new JSONObject();
            dataObject2.put("BatchList(Category)", array2);

            resultSet.close();

            out.print(dataObject2);

        }

        System.out.println("----------BatchList------------");

        String batchListSqlQuery = "SELECT DISTINCT batch_name FROM cupd_batch with (nolock) WHERE batch_id IN (SELECT DISTINCT i.batch_id \n" +
                "FROM cupd_import i with (nolock), cupd_batch b with (nolock) \n" +
                "WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE + "\n" +
                "AND i.batch_id = b.batch_id AND b.cust_id = " + sCustId + "  ) \n" +
                "AND cust_id =   " + sCustId + "  ORDER BY batch_name";

        resultSet = statement.executeQuery(batchListSqlQuery);

        JSONArray array3 = new JSONArray();
        while (resultSet.next()) {
            batchName = resultSet.getString(1);
            JSONObject data3 = new JSONObject();
            data3.put("batch_name", batchName);
            array3.put(data3);
        }
        JSONObject dataObject3 = new JSONObject();
        dataObject3.put("BatchList", array3);

        resultSet.close();

        out.print(dataObject3);

        System.out.println("-----------ImportList---------------");

        Integer importId = 0;
        String importName = null;
        String importDate = null;
        String statusName = null;

        String totRows = null;
        String badEmailsBadRows = null;
        String warningRecips = null;
        String fileDups = null;
        String dupRecips = null;
        String newRecips = null;
        String numCommitted = null;
        String leftToCommit = null;
        Integer statusId = 0;

        if (sCategoryId == null || sCategoryId.equals("0")) {

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

            resultSet = statement.executeQuery(importListNonCategorySqlQuery);

            JSONArray array4 = new JSONArray();

            while (resultSet.next()) {

                importId = resultSet.getInt(1);
                importName = resultSet.getString(2);
                importDate = resultSet.getString(3);
                statusName = resultSet.getString(4);
                batchName = resultSet.getString(5);
                totRows = resultSet.getString(6);
                badEmailsBadRows = resultSet.getString(7);
                warningRecips = resultSet.getString(8);
                fileDups = resultSet.getString(9);
                dupRecips = resultSet.getString(10);
                newRecips = resultSet.getString(11);
                numCommitted = resultSet.getString(12);
                leftToCommit = resultSet.getString(13);
                statusId = resultSet.getInt(14);

                JSONObject data4 = new JSONObject();
                data4.put("importId", importId);
                data4.put("importName", importName);
                data4.put("importDate", importDate);
                data4.put("statusName", statusName);
                data4.put("batchName", batchName);
                data4.put("totRows", totRows);
                data4.put("badEmailsBadRows", badEmailsBadRows);
                data4.put("warningRecips", warningRecips);
                data4.put("fileDups", fileDups);
                data4.put("dupRecips", dupRecips);
                data4.put("newRecips", newRecips);
                data4.put("numCommitted", numCommitted);
                data4.put("leftToCommit", leftToCommit);
                data4.put("statusId", statusId);
                array4.put(data4);
            }
            JSONObject dataObject4 = new JSONObject();
            dataObject4.put("ImportListNonCategory", array4);

            resultSet.close();

            out.print(dataObject4);

        } else {

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

            resultSet = statement.executeQuery(importListCategorySqlQuery);

            JSONArray array5 = new JSONArray();

            while (resultSet.next()) {

                importId = resultSet.getInt(1);
                importName = resultSet.getString(2);
                importDate = resultSet.getString(3);
                statusName = resultSet.getString(4);
                batchName = resultSet.getString(5);
                totRows = resultSet.getString(6);
                badEmailsBadRows = resultSet.getString(7);
                warningRecips = resultSet.getString(8);
                fileDups = resultSet.getString(9);
                dupRecips = resultSet.getString(10);
                newRecips = resultSet.getString(11);
                numCommitted = resultSet.getString(12);
                leftToCommit = resultSet.getString(13);
                statusId = resultSet.getInt(14);

                JSONObject data5 = new JSONObject();
                data5.put("importId", importId);
                data5.put("importName", importName);
                data5.put("importDate", importDate);
                data5.put("status_name", statusName);
                data5.put("batchName", batchName);
                data5.put("totRows", totRows);
                data5.put("badEmailsBadRows", badEmailsBadRows);
                data5.put("warningRecips", warningRecips);
                data5.put("fileDups", fileDups);
                data5.put("dupRecips", dupRecips);
                data5.put("newRecips", newRecips);
                data5.put("numCommitted", numCommitted);
                data5.put("leftToCommit", leftToCommit);
                data5.put("statusId", statusId);
                array5.put(data5);
            }
            JSONObject dataObject5 = new JSONObject();
            dataObject5.put("ImportListCategory", array5);

            resultSet.close();

            out.print(dataObject5);

        }

        String sSQL = "";

        if ( (sCategoryId == null) || (sCategoryId.equals("0")) ) {
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

            if (sGroupBy.equals("batch"))
            {
                sSQL += " INNER JOIN (cupd_batch b with (nolock) INNER JOIN cupd_import ii with (nolock) ON b.batch_id = ii.batch_id)";
            }
            else
            {
                sSQL += " INNER JOIN cupd_batch b with (nolock)";

            }
            sSQL += " ON (i.batch_id = b.batch_id"
                    + " AND b.type_id = 1"
                    + " AND b.cust_id = " + sCustId + ")"
                    + " INNER JOIN cupd_import_status s with (nolock) ON i.status_id = s.status_id"
                    + " LEFT OUTER JOIN cupd_import_statistics st with (nolock) ON i.import_id = st.import_id"
                    + " WHERE i.status_id >= 50" //ImportStatus.COMMIT_COMPLETE
                    + " AND i.status_id < 80"; //ImportStatus.DELETED

            if (sGroupBy.equals("batch"))
            {
                sSQL += " GROUP BY b.batch_name, b.batch_id, i.import_date, i.import_id, i.import_name, s.display_name, b.batch_name,"
                        + " st.tot_rows, st.bad_emails, st.bad_rows, st.warning_recips, st.file_dups, st.dup_recips, "
                        + " st.new_recips, st.num_committed, st.left_to_commit, s.status_id";

                if (sOrderBy.equals("name"))
                {
                    sSQL += "  ORDER BY b.batch_name, i.import_date DESC";
                }
                else
                {
                    sSQL += "  ORDER BY max(ii.import_date) DESC, b.batch_name, i.import_date DESC";
                }
            }
            else
            {
                if (sOrderBy.equals("name"))
                {
                    sSQL += "  ORDER BY i.import_name, i.import_date DESC";
                }
                else
                {
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

            if (sGroupBy.equals("batch"))
            {
                sSQL += " INNER JOIN (cupd_batch b with (nolock) INNER JOIN cupd_import ii with (nolock) ON b.batch_id = ii.batch_id)";
            }
            else
            {
                sSQL += " INNER JOIN cupd_batch b with (nolock)";

            }
            sSQL += " ON (i.batch_id = b.batch_id"
                    + " AND b.type_id = 1"
                    + " AND b.cust_id = " + sCustId + ")"
                    + " INNER JOIN ccps_object_category c"
                    + " ON (i.import_id = c.object_id"
                    + " AND c.cust_id = " + sCustId
                    + " AND c.type_id = " + ObjectType.IMPORT
                    + " AND c.category_id = " + sCategoryId + ")"
                    + " INNER JOIN cupd_import_status s with (nolock) ON i.status_id = s.status_id"
                    + " LEFT OUTER JOIN cupd_import_statistics st with (nolock) ON i.import_id = st.import_id"
                    + " WHERE i.status_id >= 50" //ImportStatus.COMMIT_COMPLETE
                    + " AND i.status_id < 80"; //ImportStatus.DELETED

            if (sGroupBy.equals("batch"))
            {
                sSQL += "  GROUP BY b.batch_name, b.batch_id, i.import_date, i.import_id, i.import_name, s.display_name, b.batch_name,"
                        + "  st.tot_rows, st.bad_emails, st.bad_rows, st.warning_recips, st.file_dups, st.dup_recips, "
                        + "  st.new_recips, st.num_committed, st.left_to_commit, s.status_id"
                        + "  ORDER BY max(ii.import_date) DESC, b.batch_name, i.import_date DESC";
            }
            else
            {
                sSQL += "  ORDER BY i.import_id DESC";
            }

        }

        resultSet = statement.executeQuery(sSQL);

        JSONArray array6 = new JSONArray();

        while(resultSet.next()){
            importId = resultSet.getInt(1);
            importName = resultSet.getString(2);
            importDate = resultSet.getString(3);
            statusName = resultSet.getString(4);
            batchName = resultSet.getString(5);
            totRows = resultSet.getString(6);
            badEmailsBadRows = resultSet.getString(7);
            warningRecips = resultSet.getString(8);
            fileDups = resultSet.getString(9);
            dupRecips = resultSet.getString(10);
            newRecips = resultSet.getString(11);
            numCommitted = resultSet.getString(12);
            leftToCommit = resultSet.getString(13);
            statusId = resultSet.getInt(14);
            batchId = resultSet.getInt(15);

            JSONObject data6 = new JSONObject();
            data6.put("import_id", importId);
            data6.put("import_name", importName);
            data6.put("import_date", importDate);
            data6.put("status_name", statusName);
            data6.put("batch_name", batchName);
            data6.put("tot_rows", totRows);
            data6.put("badEmails_badRows", badEmailsBadRows);
            data6.put("warning_recips", warningRecips);
            data6.put("file_dups", fileDups);
            data6.put("dup_recips", dupRecips);
            data6.put("new_recips", newRecips);
            data6.put("num_committed", numCommitted);
            data6.put("left_to_commit", leftToCommit);
            data6.put("status_id", statusId);
            data6.put("batch_id", batchId);
            array6.put(data6);
        }
            JSONObject data6Object = new JSONObject();
            data6Object.put("CompletedImportList", array6);

            resultSet.close();

            out.print(data6Object);

    } catch (Exception exception) {
        System.out.println(sCustId + exception.getMessage());
        exception.printStackTrace();

    } finally {
        if (statement != null) {
            statement.close();
            connection.close();
        }
    }


%>
<%
   response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
   response.setHeader("Access-Control-Allow-Credentials", "true");
%>