<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.net.*,java.sql.*,
			java.util.*,java.io.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>


<%! static Logger logger = null;%>
<%
//	if(logger == null)
//	{
//		logger = Logger.getLogger(this.getClass().getName());
//	}
//
//	AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
//
//	if(!can.bRead)
//	{
//		response.sendRedirect("../access_denied.jsp");
//		return;
//	}
//
//	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
//	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
//	boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);

	String sSelectedCategoryId = request.getParameter("category_id");
	String sCustId = request.getParameter("custId");
//	if ((sSelectedCategoryId == null) && ((user.sCustId).equals(cust.sCustId)))
//		sSelectedCategoryId = ui.s_category_id;

	// === === ===

	String scurPage = request.getParameter("curPage");

	int	curPage	= 1;
	int contCount = 0;

	curPage	= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);

	// ********** KU

	String samount = request.getParameter("amount");
	int amount = 0;

	if (samount == null) samount = ui.getSessionProperty("rept_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "2000";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("rept_list_page_size", samount);

	// ********** KU
	JsonObject data = new JsonObject();
	JsonArray arrayData = new JsonArray();

  	String strStatusId = null;
	String htmlFirstBox = "";
	String htmlContentRow = "";
	String htmlContentChild = "";
	String htmlContent = "";
	String htmlContentDT = "";

	// === === ===

	ConnectionPool cp	= null;
	Connection 	conn	= null;
	Statement 	stmt	= null;
	ResultSet 	rs		= null;
	Connection 	conn2	= null;
	Statement 	stmt2	= null;
	ResultSet 	rs2		= null;
	Connection 	conn3	= null;
	Statement 	stmt3	= null;
	ResultSet 	rs3		= null;

	try
	{


		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("report_revotrack.jsp");
		stmt = conn.createStatement();



		// === === ===

		String sClassAppend = "";
		String sOldContID = "0";
		String sNewContID = "0";

		String sOldLogicID = "0";
		String sNewLogicID = "0";

		String sOldBlockID = "0";
		String sNewBlockID = "0";

		int blockCount = 0;

		String contID = null;
		String wizardString = null;
		String contName = null;
		String wizardID = null;
		int typeID;
		String typeName = null;
		String modifyDateTxt = null;
		int statusID;
		String statusName = null;
		String userName = null;
		String modifyDate = null;

		// === === ===


			String  Name=null;
			String  Start_Date=null;

			String  Sent =null;
			String  Reaching=null;
			String  Bbacks=null;

			String  Dist_Reads=null;
			String  Distinct_Read_PRC=null;

			String  Distinct_Clicks=null;
			String  Distinct_Clicks_PRC=null;

			String  Purchasers=null;
			String  Purchases=null;
			String  Yuzde=null;
			String  Total=null;
			String  Camp_id=null;


		    String  Type_id=null;
			String  Media_id=null;
			String  Queue_daily_flag=null;




		// ============


		String sSql =
			" Exec dbo.zcs_ReportRevotrack" +
			"  @Custid="+sCustId;




		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			data = new JsonObject();

			if (contCount % 2 != 0) sClassAppend = "_other";
			else sClassAppend = "";

			++contCount;

			//Page logic
			if (contCount <= (curPage-1)*amount) continue;
			else if (contCount > curPage*amount) continue;

			String Statusid = rs.getString(1);

			Name = new String(rs.getBytes(2),"UTF-8");

			Start_Date = rs.getString(3);

			Sent = rs.getString(4);
			Reaching = rs.getString(5);
			Bbacks=rs.getString(6);

			Dist_Reads = rs.getString(7);
			Distinct_Read_PRC = rs.getString(8);

			Distinct_Clicks = rs.getString(9);
			Distinct_Clicks_PRC = rs.getString(10);

			Purchasers = rs.getString(11);
			Purchases = rs.getString(12);

			Yuzde = rs.getString(13);
			Total = rs.getString(14);
			Camp_id = rs.getString(15);

			Type_id = rs.getString(16);
			Media_id = rs.getString(17);
			Queue_daily_flag = rs.getString(18);

			data.put("statusId",Statusid);
			data.put("name",Name);
			data.put("startDate",Start_Date);
			data.put("sent",Sent);
			data.put("reaching",Reaching);
			data.put("bbacks",Bbacks);
			data.put("distReads",Dist_Reads);
			data.put("disctinctReadPrc",Distinct_Read_PRC);
			data.put("disctinctClicks",Distinct_Clicks);
			data.put("distinctClicksPrc",Distinct_Clicks_PRC);
			data.put("purchasers",Purchasers);
			data.put("purchases",Purchases);
			data.put("yuzde",Yuzde);
			data.put("total",Total);
			data.put("campId",Camp_id);
			data.put("typeId",Type_id);
			data.put("medıaId",Media_id);
			data.put("queueDailyFlag",Queue_daily_flag);

			String TYPE_VALUE=null;


				if(Type_id.equals("2") && Media_id.equals("1") && Queue_daily_flag!=null ){
 						 TYPE_VALUE="Automated Check Daily";
						  data.put("typeValue",TYPE_VALUE);
				}

			 	if(Type_id.equals("2") && Media_id.equals("1") && Queue_daily_flag==null){

						 TYPE_VALUE="Standard";
					data.put("typeValue",TYPE_VALUE);
				}

				if(Type_id.equals("4") && Media_id.equals("1")  ){
						TYPE_VALUE="Automated Triggered";
					data.put("typeValue",TYPE_VALUE);
				}


			htmlFirstBox = "<tr>"
							+" "
							+"<td class=\"list_row" + sClassAppend + "\"> "
							+"<a href=\"javascript:goToEdit('" + Camp_id + "' )\">" + Name + "</a></td>\n";

			// === === ===
			if ((contCount - 1) % 2 != 0) sClassAppend = "_other";
			else sClassAppend = "";

			arrayData.put(data);

		}
           rs.close();
		out.print(arrayData.toString());


	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try
		{
			if (stmt3!=null) stmt3.close();
			if (stmt2!=null) stmt2.close();
			if (stmt!=null) stmt.close();
		}
		catch (SQLException ignore) { }

		if (conn3!=null) cp.free(conn3);
		if (conn2!=null) cp.free(conn2);
		if (conn!=null) cp.free(conn);
	}

	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin", "*");

%>
