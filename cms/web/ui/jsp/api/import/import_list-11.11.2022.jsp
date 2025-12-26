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

<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectWriter" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp" %>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

//Is it the standard ui?
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


	String sBatchID = request.getParameter("batch_id");

	int nBatchID = Integer.parseInt((sBatchID == null)?"0":sBatchID);

	boolean bCanExecute = can.bExecute;

// === === ===

	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");

	int			curPage			= 1;
	int			amount			= 0;

	curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

// === === ===

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

	String sImportListPageSize = ui.getSessionProperty("import_list_page_size");
	if (samount == null)
	{
		if ((null != sImportListPageSize) && ("" != sImportListPageSize))
		{
			samount = sImportListPageSize;
		}
		else
		{
			samount = "25";
		}
	}

	amount = (samount==null)? 25 : Integer.parseInt(samount);

	ui.setSessionProperty("import_list_page_size", samount);


	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	ConnectionPool	connectionPool= null;
	Connection		connection = null;
	Statement		statement = null;
	ResultSet resultSet = null;
%>
<%

	try {

		connectionPool = ConnectionPool.getInstance();
		connection = connectionPool.getConnection(this);
		statement = connection.createStatement();

		JsonObject data = new JsonObject();
		JsonArray batchArray = new JsonArray();
		JsonArray tableDataArray =new JsonArray();
		JsonObject importList = new JsonObject();
	

		Integer batchId = 0;
		String batchName = null;

		if (sSelectedCategoryId == null || sSelectedCategoryId.equals("0")) {

			String batchListNonCategorySqlQuery =
					"SELECT DISTINCT b.batch_id, b.batch_name \n" +
							"FROM cupd_batch b with (nolock) \n" +
							"WHERE b.type_id = 1  \n" +
							"AND b.batch_id IN (SELECT DISTINCT i.batch_id \n" +
							"FROM cupd_import i with (nolock), cupd_batch b with (nolock) \n" +
							"WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE + "\n" +
							"AND i.batch_id = b.batch_id AND b.cust_id =" + cust.s_cust_id + "  ) \n" +
							"AND b.cust_id =" + cust.s_cust_id + " \n" +
							"ORDER BY b.batch_id DESC";

			resultSet = statement.executeQuery(batchListNonCategorySqlQuery);



			while (resultSet.next()) {

				data=new JsonObject();
				batchId = resultSet.getInt(1);
				batchName = resultSet.getString(2);



				data.put("batch_id", batchId);
				data.put("batch_name", batchName);

				batchArray.put(data);


			}
			importList.put("batchListdata",batchArray);
			resultSet.close();







		} else {

			String batchListCategorySqlQuery =
					"SELECT DISTINCT b.batch_id, b.batch_name \n" +
							"FROM cupd_batch b with (nolock) \n" +
							"WHERE b.type_id = 1  \n" +
							"AND b.batch_id IN (SELECT DISTINCT i.batch_id \n" +
							"FROM cupd_import i with (nolock), cupd_batch b with (nolock), ccps_object_category oc with (nolock) \n" +
							"WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE + "\n" +
							"AND i.batch_id = b.batch_id \n" +
							"AND b.cust_id =   " + cust.s_cust_id + " \n" +
							"AND oc.object_id = i.import_id \n" +
							"AND oc.type_id =   " + ObjectType.IMPORT + "\n" +
							"AND oc.cust_id =   "+cust.s_cust_id+ " \n" +
							"AND oc.category_id = " + sSelectedCategoryId + " ) \n" +
							"AND b.cust_id =   " + cust.s_cust_id + " \n" +
							"ORDER BY b.batch_id DESC";


			resultSet = statement.executeQuery(batchListCategorySqlQuery);


		
			while (resultSet.next()) {
				data = new JsonObject();

				batchId = resultSet.getInt(1);
				batchName = resultSet.getString(2);


				data.put("batch_id", batchId);
				data.put("batch_name", batchName);

				batchArray.put(data);

			}
			importList.put("batchListdata",batchArray);


			resultSet.close();



		}

		System.out.println("----------BatchList------------");

		String batchListSqlQuery = "SELECT DISTINCT batch_name FROM cupd_batch with (nolock) WHERE batch_id IN (SELECT DISTINCT i.batch_id \n" +
				"FROM cupd_import i with (nolock), cupd_batch b with (nolock) \n" +
				"WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE + "\n" +
				"AND i.batch_id = b.batch_id AND b.cust_id = " + cust.s_cust_id + "  ) \n" +
				"AND cust_id =   " + cust.s_cust_id + "  ORDER BY batch_name";

		resultSet = statement.executeQuery(batchListSqlQuery);

	
		while (resultSet.next()) {

			data = new JsonObject();
			batchName = resultSet.getString(1);

			data.put("batch_name", batchName);
			batchArray.put(data);
		}
		importList.put("batchListdata",batchArray);
		resultSet.close();


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

		if (sSelectedCategoryId == null || sSelectedCategoryId.equals("0")) {

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
							"AND b.type_id = 1 AND b.cust_id =  " + cust.s_cust_id + "\n" +
							"INNER JOIN cupd_import_status s with (nolock) ON i.status_id = s.status_id\n" +
							"LEFT OUTER JOIN cupd_import_statistics st with (nolock) ON i.import_id = st.import_id\n" +
							"WHERE i.status_id < " + ImportStatus.COMMIT_COMPLETE + " ORDER BY b.batch_name, i.import_id DESC";

			resultSet = statement.executeQuery(importListNonCategorySqlQuery);

			
			while (resultSet.next()) {
				data = new JsonObject();

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


				data.put("importId", importId);
				data.put("importName", importName);
				data.put("importDate", importDate);
				data.put("statusName", statusName);
				data.put("batchName", batchName);
				data.put("totRows", totRows);
				data.put("badEmailsBadRows", badEmailsBadRows);
				data.put("warningRecips", warningRecips);
				data.put("fileDups", fileDups);
				data.put("dupRecips", dupRecips);
				data.put("newRecips", newRecips);
				data.put("numCommitted", numCommitted);
				data.put("leftToCommit", leftToCommit);
				data.put("statusId", statusId);
				
				tableDataArray.put(data);
			}
			importList.put("tableData",tableDataArray);
			//  dataArray.put(array);
//
//            JsonParser parser = new JsonParser();
//            Gson gson = new GsonBuilder().setPrettyPrinting().create();
//
//            JsonElement el = parser.parse(dataObject.toString());
//            out.println(gson.toJson(el));

			resultSet.close();



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
							"AND b.cust_id =   " + cust.s_cust_id + "  )\n" +
							"INNER JOIN ccps_object_category c with (nolock)\n" +
							"ON (i.import_id = c.object_id\n" +
							"AND c.cust_id =   " + cust.s_cust_id + "\n" +
							"AND c.type_id =   " + ObjectType.IMPORT + "\n" +
							"AND c.category_id =   " + sSelectedCategoryId + "  )\n" +
							"INNER JOIN cupd_import_status s with (nolock) ON i.status_id = s.status_id\n" +
							"LEFT OUTER JOIN cupd_import_statistics st with (nolock) ON i.import_id = st.import_id\n" +
							"WHERE i.status_id < " + ImportStatus.COMMIT_COMPLETE + "\n" +
							"ORDER BY b.batch_name, i.import_id DESC";

			resultSet = statement.executeQuery(importListCategorySqlQuery);


		
			while (resultSet.next()) {
				data = new JsonObject();

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


				data.put("importId", importId);
				data.put("importName", importName);
				data.put("importDate", importDate);
				data.put("status_name", statusName);
				data.put("batchName", batchName);
				data.put("totRows", totRows);
				data.put("badEmailsBadRows", badEmailsBadRows);
				data.put("warningRecips", warningRecips);
				data.put("fileDups", fileDups);
				data.put("dupRecips", dupRecips);
				data.put("newRecips", newRecips);
				data.put("numCommitted", numCommitted);
				data.put("leftToCommit", leftToCommit);
				data.put("statusId", statusId);

				tableDataArray.put(data);
			}

			importList.put("tableData",tableDataArray);
			resultSet.close();



		}

		String sSQL = "";

		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
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
					+ " AND b.cust_id = " + cust.s_cust_id + ")"
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
					+ " AND b.cust_id = " + cust.s_cust_id + ")"
					+ " INNER JOIN ccps_object_category c"
					+ " ON (i.import_id = c.object_id"
					+ " AND c.cust_id = " + cust.s_cust_id
					+ " AND c.type_id = " + ObjectType.IMPORT
					+ " AND c.category_id = " + sSelectedCategoryId + ")"
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


		
		while(resultSet.next()){
			
			data = new JsonObject();

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


			data.put("import_id", importId);
			data.put("import_name", importName);
			data.put("import_date", importDate);
			data.put("status_name", statusName);
			data.put("batch_name", batchName);
			data.put("tot_rows", totRows);
			data.put("badEmails_badRows", badEmailsBadRows);
			data.put("warning_recips", warningRecips);
			data.put("file_dups", fileDups);
			data.put("dup_recips", dupRecips);
			data.put("new_recips", newRecips);
			data.put("num_committed", numCommitted);
			data.put("left_to_commit", leftToCommit);
			data.put("status_id", statusId);
			data.put("batch_id", batchId);
			
			tableDataArray.put(data);
		}
		importList.put("tableData",tableDataArray);
		resultSet.close();

		
		out.print(importList.toString());
		
	} catch (Exception exception) {
		System.out.println(cust.s_cust_id + exception.getMessage());
		exception.printStackTrace();

	} finally {
		if (statement != null) {
			statement.close();
			connection.close();
		}
	}



%>