<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,javax.xml.transform.stream.*,
			org.apache.log4j.*"
		errorPage="../error_page.jsp"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp"%>
<%@ include file="../header.jsp"%>



<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
	boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);
// release 5.9 Auto-Update Report Controls
	boolean isUpdateRptEnabled = ui.getFeatureAccess(Feature.UPDATE_AUTO_REPORT);
	System.out.println("isUpdateRptEnabled = " + isUpdateRptEnabled);

	boolean canRecipView = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
	String sRecipView = "0";
	if (canRecipView) sRecipView = "1";


// Connection
	Statement		stmt	= null;
	ResultSet		rs		= null;
	ConnectionPool	cp		= null;
	Connection		conn	= null;

	JsonObject  data = new JsonObject();
	JsonArray  reportListData = new JsonArray();
	JsonArray 	reportListCategory = new JsonArray();

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		String sSQL = null;

		String scurPage = request.getParameter("curPage");
		String samount = request.getParameter("amount");

		int curPage = 1;
		int amount = 0;

		curPage = (scurPage == null) ? 1 : Integer.parseInt(scurPage);

		if (samount == null) samount = ui.getSessionProperty("rept_list_page_size");
		if ((samount == null) || ("".equals(samount))) samount = "25";
		try {
			amount = Integer.parseInt(samount);
		} catch (Exception ex) {
			samount = "25";
			amount = 25;
		}
		ui.setSessionProperty("rept_list_page_size", samount);

		String sSelectedCategoryID = request.getParameter("category_id");
		if ((sSelectedCategoryID == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
			sSelectedCategoryID = ui.s_category_id;




		sSQL = "SELECT category_id, category_name"
				+ " FROM ccps_category"
				+ " WHERE cust_id = " + cust.s_cust_id
				+ " ORDER BY category_name";
		rs = stmt.executeQuery(sSQL);


		String sCategoryID = null;
		String sCategoryName = null;

		while (rs.next()) {
			data = new JsonObject();
			sCategoryID = rs.getString(1);
			sCategoryName = new String(rs.getBytes(2), "UTF-8");

			data.put("categoryId", rs.getString(1));
			data.put("sCategoryName", new String(rs.getBytes(2), "UTF-8"));

			reportListCategory.put(data);


		}
		rs.close();


		// ********* KU
		int iCount = 0;
		String sClassAppend = "_other";


		// Fields description for (already sent campaign) stored procedure: ????
		//
		// <Id>          - Campaign Id
		// <Name>        - Campaign Name
		// <TypeId>      - Campaign Type Id
		// <StartDate>   - Date when the campaign started
		// <Size>        - Number of recipients for that campaign
		// <BBacks>      - Number of Bounce Backs
		// <BBackPrc>    - % of Bounce Backs = (<BBacks> / <Size>) * 100
		// <Clicks>      - Number of Click Throughs
		// <ClickPrc>    - % of Click Throughs = (<CThrough> / <Size>) * 100
		// <Unsubs>      - Number of unsubscribers
		// <UnsubsPrc>   - % of unsubscribers = (<Unsubscr> / <Size>) * 100
		// <UpdateDate>     - date when report last updated
		// <UpdateStatusId> - status of report update
		// <UpdateStatus>   - status of report update
		//

		sSQL = "EXEC usp_crpt_camp_list @cust_id=" + cust.s_cust_id;

		if (sSelectedCategoryID != null)
			sSQL += ",@category_id=" + sSelectedCategoryID;

		if (stmt.execute(sSQL)) {
			rs = stmt.getResultSet();


			while (rs.next()) {
				data = new JsonObject();
				if (iCount % 2 != 0) {
					sClassAppend = "_other";
				} else {
					sClassAppend = "";
				}

				iCount++;

				//Page logic
				if ((iCount <= (curPage - 1) * amount) || (iCount > curPage * amount)) continue;


				data.put("id", rs.getString(1));
				data.put("name", new String(rs.getBytes(2), "UTF-8"));
                                if(rs.getString(3).equals("2")){
                                   data.put("typeId", "Standard");
                                }
				else if(rs.getString(3).equals("4")){
                                   data.put("typeId", "Automated");
                                }

				else{
				   data.put("typeId", rs.getString(3));
				}
				
				data.put("mediaTypeId", rs.getString(4));
				data.put("startDate", rs.getString(5).replace("AM", " AM").replace("PM", " PM"));
				data.put("size", rs.getString(6));
				data.put("tReads", rs.getString(17) + " ("+rs.getString(18)+"%)");
				data.put("tReadsPrc", rs.getString(18));
				data.put("bbacks", rs.getString(7) + " ("+rs.getString(13)+"%)");
				data.put("clicks", rs.getString(8) + " ("+rs.getString(14)+"%)");
				data.put("unsubs", rs.getString(9) + " ("+rs.getString(15)+"%)");
				data.put("updateDate", rs.getString(10));
				data.put("UpdateStatusId", rs.getString(11));
				data.put("UpdateStatus", rs.getString(12));
				data.put("BBackPrc", rs.getString(13));
				data.put("ClickPrc", rs.getString(14));
				data.put("UnsubPrc", rs.getString(15));
				data.put("Cache", rs.getString(16));
				data.put("StyleClass", sClassAppend);

				reportListData.put(data);

			}

		}
	}

	catch(Exception ex)
	{
		ErrLog.put(this,ex,"Error: "+ex.getMessage(),out,1);
	}
	finally
	{
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn);
		out.flush();
	}
	out.print(reportListData.toString());

%>
