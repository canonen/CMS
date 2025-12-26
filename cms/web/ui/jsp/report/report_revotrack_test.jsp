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
				
 		 

		if (htmlContent.length() == 0){
			htmlContent += "<tr><td colspan=\"5\" class=\"list_row\">There is currently no Content</td></tr>\n";
		}

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
%>

 


<head>
<title>Revotrack Report</title>






 

</head>
<BODY class="paging_body">




<div class="page_header">Revotrack List</div>
<div class="page_desc"> <%= cust.s_cust_id %></div>	
<div id="info">



		
		</td>
	</tr>
</table>



	 
			 
				 

</body>
</fmt:bundle>

</html>

