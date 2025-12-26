<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
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
//
//	String sSelectedCategoryId = request.getParameter("category_id");
//	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
//		sSelectedCategoryId = ui.s_category_id;
//
//	// === === ===
//
//	String scurPage = request.getParameter("curPage");
//
//	int	curPage	= 1;
//	int contCount = 0;
//
//	curPage	= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);
//
//	// ********** KU
//
//	String samount = request.getParameter("amount");
//	int amount = 0;
//
//	if (samount == null) samount = ui.getSessionProperty("rept_list_page_size");
//	if ((samount == null)||("".equals(samount))) samount = "2000";
//	try { amount = Integer.parseInt(samount); }
//	catch (Exception ex) { samount = "25"; amount = 25; }
//	ui.setSessionProperty("rept_list_page_size", samount);



	// ********** KU
	
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

	String custId =request.getParameter("custId");

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();


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
			"  @Custid="+custId;
		//cust.s_cust_id;

		JsonObject data = new JsonObject();
		JsonArray dataArray = new JsonArray();

 
		  
		rs = stmt.executeQuery(sSql);		
		while (rs.next())
		{
			data = new JsonObject();
	
			String Statusid = rs.getString(1);
			data.put("statusId",Statusid);
			Name = new String(rs.getBytes(2),"UTF-8");
			data.put("name",Name);
			 
			Start_Date = rs.getString(3);
			data.put("startDate",Start_Date);
			
			Sent = rs.getString(4);
			data.put("sent",Sent);
			Reaching = rs.getString(5);
			data.put("reaching",Reaching);
			Bbacks=rs.getString(6);
			data.put("bbacks",Bbacks);
			
			Dist_Reads = rs.getString(7);
			data.put("distReads",Dist_Reads);
			Distinct_Read_PRC = rs.getString(8);
			data.put("distinctReadPRC",Distinct_Read_PRC);
			Distinct_Clicks = rs.getString(9);
			data.put("distinctClicks",Distinct_Clicks);
			Distinct_Clicks_PRC = rs.getString(10);
			data.put("distinctClicksPRC",Distinct_Clicks_PRC);
			
			Purchasers = rs.getString(11);
			data.put("purchasers",Purchasers);
			Purchases = rs.getString(12);
			data.put("purchases",Purchases);
			
			Yuzde = rs.getString(13);
			data.put("yuzde",Yuzde);
			Total = rs.getString(14);
			data.put("total",Total);
			Camp_id = rs.getString(15);
			data.put("campId",Camp_id);

			Type_id = rs.getString(16);
			data.put("typeId",Type_id);
			Media_id = rs.getString(17);
			data.put("mediaId",Media_id);
			Queue_daily_flag = rs.getString(18);
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


				dataArray.put(data);

		}
		rs.close();

		out.print(dataArray.toString());


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
