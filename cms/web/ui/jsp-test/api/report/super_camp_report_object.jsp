<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%!
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	static Logger logger = null;
	private JsonArray createJson (String sCampID, HttpServletRequest request, Customer cust) throws Exception {
		JsonArray createJson = new JsonArray();
		JsonArray campReportObjectArray = new JsonArray();
		JsonObject data = new JsonObject();
		JsonArray superCampListArray = new JsonArray();
		JsonArray lastQueryData = new JsonArray();
		JsonArray lastQueryData2 = new JsonArray();

		ConnectionPool cp = null;
		Connection conn = null;
		Connection conn2 = null;
		Statement stmt =null;			
		Statement stmt2 =null;			
		ResultSet rs=null;
		ResultSet rs2=null;
		byte[] bVal = new byte[255];

		try {

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();

			conn2 = cp.getConnection(this);
			stmt2 = conn2.createStatement();

			if (sCampID!=null) {			


				rs=stmt.executeQuery("Exec usp_crpt_super_camp_list @super_camp_id="+sCampID+", @cust_id="+cust.s_cust_id);
				while( rs.next() ) {

					data = new JsonObject();

					data.put("ıd",rs.getString("Id"));
					data.put("name",new String (rs.getBytes("CampName"),"UTF-8"));
					data.put("size",rs.getString("Sent"));
					data.put("bbacks",rs.getString("BBacks"));
					data.put("reaching",rs.getString("Reaching"));
					data.put("distinctReads",rs.getString("DistinctReads"));
					data.put("totalReads",rs.getString("TotalReads"));
					data.put("multiReaders",rs.getString("MultiReaders"));
					data.put("unsubs",rs.getString("Unsubs"));
					data.put("totalLinks",rs.getString("TotalLinks"));
					data.put("totalClicks",rs.getString("TotalClicks"));
					data.put("totalText",rs.getString("TotalText"));
					data.put("totalHtml",rs.getString("TotalHTML"));
					data.put("totalAOL",rs.getString("TotalAOL"));
					data.put("distinctClicks",rs.getString("DistinctClicks"));
					data.put("distinctText",rs.getString("DistinctText"));
					data.put("distinctHtml",rs.getString("DistinctHTML"));
					data.put("distinctAOL",rs.getString("DistinctAOL"));
					data.put("OneLinkMultiClickers",rs.getString("OneLinkMultiClickers"));
					data.put("MultiLinkClickers",rs.getString("MultiLinkClickers"));
					data.put("BBackPrc",rs.getString("BBackPrc"));
					data.put("ReachingPrc",rs.getString("ReachingPrc"));
					data.put("DistinctReadPrc",rs.getString("DistinctReadPrc"));
					data.put("UnsubPrc",rs.getString("UnsubPrc"));
					data.put("DistinctClickPrc",rs.getString("DistinctClickPrc"));
					data.put("TotalTextPrc",rs.getString("TotalTextPrc"));
					data.put("TotalHTMLPrc",rs.getString("TotalHTMLPrc"));
					data.put("TotalAOLPrc",rs.getString("TotalAOLPrc"));
					data.put("DistinctTextPrc",rs.getString("DistinctTextPrc"));
					data.put("DistinctHTMLPrc",rs.getString("DistinctHTMLPrc"));
					data.put("DistinctAOLPrc",rs.getString("DistinctAOLPrc"));

					campReportObjectArray.put(data);

					createJson.put(campReportObjectArray);
				}

				rs.close();




				rs=stmt.executeQuery("Exec usp_crpt_super_camp_links @super_camp_id="+sCampID);
				while( rs.next() ) {

					data = new JsonObject();
					data.put("SuperCampID",sCampID);
					data.put("SuperLinkID",new String(rs.getBytes("SuperLinkName"),"UTF-8"));
					String superLinkID = new String(rs.getBytes("SuperLinkName"),"UTF-8");
					data.put("TotalClicks",rs.getString("TotalClicks"));
					data.put("TotalText",rs.getString("TotalText"));
					data.put("TotalClicks",rs.getString("TotalClicks"));
					data.put("TotalText",rs.getString("TotalText"));
					data.put("TotalHTML",rs.getString("TotalHTML"));
					data.put("TotalAOL",rs.getString("TotalAOL"));
					data.put("DistinctClicks",rs.getString("DistinctClicks"));
					data.put("DistinctText",rs.getString("DistinctText"));
					data.put("DistinctHTML",rs.getString("DistinctHTML"));
					data.put("DistinctAOL",rs.getString("DistinctAOL"));
					data.put("TotalClickPrc",rs.getString("TotalClickPrc"));
					data.put("TotalTextPrc",rs.getString("TotalTextPrc"));
					data.put("TotalHTMLPrc",rs.getString("TotalHTMLPrc"));
					data.put("TotalAOLPrc",rs.getString("TotalAOLPrc"));
					data.put("DistinctClickPrc",rs.getString("DistinctClickPrc"));
					data.put("DistinctTextPrc",rs.getString("DistinctTextPrc"));
					data.put("DistinctHTMLPrc",rs.getString("DistinctHTMLPrc"));
					data.put("DistinctClickPrc",rs.getString("DistinctClickPrc"));





					int nNonLinkCamps = 0;
					rs2 = stmt2.executeQuery("SELECT count(c.camp_id) FROM cque_campaign c, cque_super_camp_camp s"
						+ " WHERE c.origin_camp_id = s.camp_id"
						+ " AND c.type_id > "+CampaignType.TEST
						+ " AND s.super_camp_id = "+sCampID
						+ " AND c.camp_id NOT IN (SELECT cc.camp_id"
							+ " FROM cque_campaign cc, cjtk_link l, crpt_super_link_link sl"
							+ " WHERE cc.cont_id = l.cont_id AND l.link_id = sl.link_id"
							+ " AND sl.super_link_id = "+superLinkID+" AND sl.super_camp_id = "+sCampID+")");
					if (rs2.next()) {
						nNonLinkCamps = rs2.getInt(1);
						data.put("nNonLinkCamps",nNonLinkCamps);
					}
					rs2.close();

					superCampListArray.put(data);

					createJson.put(superCampListArray);
				}

				rs.close();


	            String subCampID = null;
				rs=stmt.executeQuery("Exec usp_crpt_super_camp_camp_list @super_camp_id="+sCampID);
				while( rs.next() ) {
					data = new JsonObject();

					subCampID = rs.getString("CampID");
					bVal = rs.getBytes("CampName");


					data.put("subCampID",subCampID);
					data.put("CampName",new String (rs.getBytes("CampName"),"UTF-8"));

					lastQueryData.put(data);

					createJson.put(lastQueryData);
					rs2=stmt2.executeQuery("Exec usp_crpt_camp_list @camp_id="+subCampID+", @cust_id="+cust.s_cust_id);
					if ( rs2.next() ) {

						data = new JsonObject();
						data.put("StartDate",rs2.getString("StartDate"));
						data.put("Size",rs2.getString("Sent"));
						data.put("BBacks",rs2.getString("BBacks"));
						data.put("Unsubs",rs2.getString("Unsubs"));
						data.put("Clicks",rs2.getString("DistinctClicks"));
						data.put("BBackPrc",rs2.getString("BBackPrc"));
						data.put("UnsubPrc",rs2.getString("UnsubPrc"));
						data.put("ClickPrc",rs2.getString("DistinctClickPrc"));
						data.put("StartDate",rs2.getString("StartDate"));
						lastQueryData2.put(data);
					}
					rs2.close();

					createJson.put(lastQueryData2);
				}

				rs.close();


			}
		} catch (Exception ex) {
			throw ex;								
		} finally {
			try {
				if (stmt2!=null) stmt2.close();
			} catch (Exception ignore) { }
			if (conn2!=null) cp.free(conn2);
			try {
				if (stmt!=null) stmt.close();
			} catch (Exception ignore) { }
			if (conn!=null) cp.free(conn);
		}
		return createJson;
	}
%>
<%

%>
<%@ include file="../../utilities/validator.jsp"%>
<%@ include file="../header.jsp"%>

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
%>

<%
	JsonArray superCampReportObjectData = new JsonArray();
try
{

	String sCampList=null;

	if (request.getParameter("id")!=null){

		sCampList = request.getParameter("id");

		while (sCampList.indexOf(",") != -1){
			superCampReportObjectData.put(createJson(sCampList.substring(0,sCampList.indexOf(",")), request, cust));
			sCampList = sCampList.substring(sCampList.indexOf(",") + 1);
		}

		superCampReportObjectData.put(createJson(sCampList, request, cust));
		out.print(superCampReportObjectData.toString());
	}


}
catch(Exception ex)
{
	ErrLog.put(this,ex,"Error: "+ex.getMessage(),out,1);
}
finally
{
	out.flush();
}
	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin", "*");
%>
