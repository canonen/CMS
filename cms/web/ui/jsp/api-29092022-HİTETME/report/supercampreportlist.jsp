<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,
			org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
	response.setContentType("text/html; charset=UTF-8");
%>
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

%>

<%

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("super_camp_report_list.jsp");
	stmt = conn.createStatement();
	String sSQL = null;
	
	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");

	JsonObject categoryData = new JsonObject();
	JsonArray categoryDataArray = new JsonArray();
	JsonObject campListData = new JsonObject();
	JsonArray  campListDataArray = new JsonArray();

	JsonArray superCampListData = new JsonArray();
	int			curPage			= 1;
	int			amount			= 0;
	
	curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);
	boolean isUpdateRptEnabled = ui.getFeatureAccess(Feature.UPDATE_AUTO_REPORT);
	if (samount == null) samount = ui.getSessionProperty("super_report_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("super_report_page_size", samount);

	String sSelectedCategoryID = request.getParameter("category_id");
	if ((sSelectedCategoryID == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryID = ui.s_category_id;


	sSQL = "SELECT category_id, category_name"
		+ " FROM ccps_category"
		+ " WHERE cust_id = "+cust.s_cust_id
		+ " ORDER BY category_name";
	rs = stmt.executeQuery(sSQL);

	String sCategoryID = null;
	String sCategoryName = null;
	while (rs.next()) {
		categoryData = new JsonObject();

		sCategoryID = rs.getString(1);
		sCategoryName = new String(rs.getBytes(2), "UTF-8");

		categoryData.put("categoryId",sCategoryID);
		categoryData.put("categoryName",sCategoryName);

		categoryDataArray.put(categoryData);


		superCampListData.put(categoryDataArray);


	}
	rs.close();

	
	// ********* KU
	int iCount = 0;
	String sClassAppend = "_other";

// Fields description for (already sent campaign) stored procedure: ????
//
// <Id>          - Campaign Id
// <Name>        - Campaign Name
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

	sSQL="EXEC usp_crpt_super_camp_list @cust_id="+cust.s_cust_id;

	if (sSelectedCategoryID!=null)
		sSQL +=",@category_id=" + sSelectedCategoryID;

	if (stmt.execute(sSQL))
	{
		rs = stmt.getResultSet();

		while (rs.next())
		{

			campListData = new JsonObject();
			if (iCount % 2 != 0)
			{
				sClassAppend = "_other";
			}
			else
			{
				sClassAppend = "";
			}
			
			iCount++;
			
			//Page logic
			if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;


			campListData.put("ıd",rs.getString(1));
			campListData.put("name",new String(rs.getBytes(2),"UTF-8"));
			campListData.put("size",rs.getString(3));
			campListData.put("bBacks",rs.getString(4));
			campListData.put("clicks",rs.getString(5));
			campListData.put("unsubs",rs.getString(6));
			campListData.put("updateDate",rs.getString(7));
			campListData.put("updateStatusId",rs.getString(8));
			campListData.put("updateStatus",rs.getString(9));
			campListData.put("bBackPrc",rs.getString(10));
			campListData.put("clickPrc",rs.getString(11));
			campListData.put("unsubPrc",rs.getString(12));
			campListData.put("styleClass",sClassAppend);

			campListDataArray.put(campListData);

			superCampListData.put(campListDataArray);


		}
		rs.close();


	}
	

out.print(campListDataArray.toString());

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

	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin", "*");

%>
