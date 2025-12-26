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
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

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
	
  	String strStatusId = null;
	String htmlFirstBox = "";
	String htmlContentRow = "";
	String htmlContentChild = "";
	String htmlContent = "";
	String htmlContentDT = "";

	// === === ===

	ConnectionPool connectionPool	= null;
	Connection 	connection	= null;
	Statement 	statement	= null;
	ResultSet 	resultSet		= null;
	Connection 	connection2	= null;
	Statement 	statement2	= null;
	ResultSet 	resultSet2		= null;
	Connection 	connection3	= null;
	Statement 	statement3	= null;
	ResultSet 	resultSet3		= null;



	try
	{
		connectionPool = ConnectionPool.getInstance();
		connection = connectionPool.getConnection(this);
		statement = connection.createStatement();


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
				
		 
			String  name=null;
			String  startDate=null;
			
			String  sent =null;
			String  reaching=null;
			String bBacks =null;
			
			String distinctReads =null;
			String  distinctReadPRC=null;
			
			String  distinctClicks=null;
			String  distinctClicksPRC=null;
			
			String  purchasers=null;
			String  purchases=null;
			String percentage =null;
			String  total=null;
			String  campId=null;


		    String  typeId=null;
			String  mediaId=null;
			String  queueDailyFlag=null;

			 
			
				
		// ============
				
 		 
		String sSql =
			" Exec dbo.zcs_ReportRevotrack" + 
			"  @Custid="+cust.s_cust_id;
		//cust.s_cust_id;

		JsonObject data = new JsonObject();
		JsonArray dataArray = new JsonArray();

 
		  
		resultSet = statement.executeQuery(sSql);
		while (resultSet.next())
		{
			
			data = new JsonObject();
	
			String Statusid = resultSet.getString(1);
			data.put("statusId",Statusid);
			name = new String(resultSet.getBytes(2),"UTF-8");
			data.put("name",name);
			 
			startDate = resultSet.getString(3);
			data.put("startDate",startDate);
			
			sent = resultSet.getString(4);
			data.put("sent",sent);
			reaching = resultSet.getString(5);
			data.put("reaching",reaching);
			bBacks =resultSet.getString(6);
			data.put("bBacks", bBacks);
			
			distinctReads = resultSet.getString(7);
			data.put("distReads", distinctReads);
			distinctReadPRC = resultSet.getString(8);
			data.put("distinctReadPRC",distinctReadPRC);
			distinctClicks = resultSet.getString(9);
			data.put("distinctClicks",distinctClicks);
			distinctClicksPRC = resultSet.getString(10);
			data.put("distinctClicksPRC",distinctClicksPRC);
			
			purchasers = resultSet.getString(11);
			data.put("purchasers",purchasers);
			purchases = resultSet.getString(12);
			data.put("purchases",purchases);
			
			percentage = resultSet.getString(13);
			data.put("percentage", percentage);
			total = resultSet.getString(14);
			data.put("total",total);
			campId = resultSet.getString(15);
			data.put("campId",campId);

			typeId = resultSet.getString(16);
			System.out.println("typeId" +typeId);
			data.put("typeId",typeId);
			mediaId = resultSet.getString(17);
			data.put("mediaId",mediaId);
			System.out.println("mediaId" + mediaId);
			queueDailyFlag = resultSet.getString(18);

			
			System.out.println("queueDailyFlag " + queueDailyFlag);

			String typeValue=null;
			

				if(typeId.equals("2") && mediaId.equals("1") && queueDailyFlag!=null ){
 						 typeValue="Automated Check Daily";

				}

			 	else if(typeId.equals("2") && mediaId.equals("1") && queueDailyFlag == null){

						 typeValue="Standard";

				}

				else if(typeId.equals("4") && mediaId.equals("1")  ){
						typeValue="Automated Triggered";

				}

				data.put("typeValue",typeValue);
				data.put("queueDailyFlag",queueDailyFlag);
				dataArray.put(data);

		}
		resultSet.close();

		out.print(dataArray.toString());


	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try
		{
			if (resultSet3!=null) resultSet3.close();
			if (resultSet2!=null) resultSet2.close();
			if (resultSet!=null) resultSet.close();
			if (statement3!=null) statement3.close();
			if (statement2!=null) statement2.close();
			if (statement!=null) statement.close();
		}
		catch (SQLException ignore) { }
		
		if (connection3!=null) connectionPool.free(connection3);
		if (connection2!=null) connectionPool.free(connection2);
		if (connection!=null) connectionPool.free(connection);
	}


%>
