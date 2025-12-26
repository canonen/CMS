<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>

<%@ include file="../../../utilities/validator.jsp" %>
<%@ include file="../header.jsp" %>
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

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt2	= null;
ResultSet		rs2		= null; 
Connection		conn2	= null;
JsonArray dataArray = new JsonArray();
JsonObject data = new JsonObject();
JsonObject dataItem = new JsonObject();
JsonArray allData = new JsonArray();
JsonArray dataItemArr = new JsonArray();
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_list.jsp");
	stmt = conn.createStatement();

	conn2 = cp.getConnection("report_list.jsp 2");
	stmt2 = conn2.createStatement();

	String sSQL=null;

	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");

	int			curPage			= 1;
	int			amount			= 0;
	
	curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

	if (samount == null) samount = ui.getSessionProperty("global_report_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("global_report_page_size", samount);

	int iCount = 0;
	int iRowCount = 0;


	byte[] bVal = new byte[255];
	
	sSQL = "Exec usp_crpt_cust_report_list_get @cust_id="+cust.s_cust_id;

	String val = null;
	{
		rs = stmt.executeQuery(sSQL);
		while (rs.next())
		{
			iRowCount++;
			data = new JsonObject();
			//Page logic
			if ((iRowCount <= (curPage-1)*amount) || (iRowCount > curPage*amount)) continue;

			String sReportId = rs.getString(1);
			data.put("report_id",sReportId);
			val = rs.getString(2);
			data.put("start_date",val);
			val = rs.getString(3);
			data.put("end_date",val);
			data.put("user_id",rs.getString(4));
			data.put("update_date",rs.getString(5));
			data.put("active",rs.getString(6));
			data.put("have_bback",rs.getString(7));
			data.put("are_bback",rs.getString(8));
			data.put("unsub",rs.getString(9));
			data.put("click",rs.getString(10));
			data.put("multi_click",rs.getString(11));
			data.put("camp_qty",rs.getString(12));
			data.put("sent",rs.getString(13));
			data.put("not_sent",rs.getString(14));
			data.put("detect_html",rs.getString(15));
			data.put("detect_text",rs.getString(16));
			data.put("detect_aol",rs.getString(17));
			data.put("unconfirmed",rs.getString(18));
			data.put("status",rs.getString(19));
			data.put("user_name",new String(rs.getBytes(20), "UTF-8"));
			iCount = 0;
			dataArray.put(data);
			rs2=stmt2.executeQuery("Exec usp_crpt_cust_report_bbacks @cust_id="+cust.s_cust_id+", @report_id="+sReportId);
			while( rs2.next() )
			{
				// ********* KU

				dataItem = new JsonObject();
				iCount++;
				dataItem.put("CategoryID",rs2.getString("CategoryID"));
				bVal = rs2.getBytes("CategoryName");
				dataItem.put("CategoryName",new String(bVal,"UTF-8"));
				dataItem.put("BBacks",rs2.getString("BBacks"));
				dataItem.put("BBackPrc",rs2.getString("BBackPrc"));
				dataItemArr.put(dataItem);

			}
			data.put("Bounceback",dataItemArr);
			rs2.close();
			
			// ********* KU
			iCount = 0;
			JsonArray dataItemArrDomain = new JsonArray();
			rs2=stmt2.executeQuery("Exec usp_crpt_cust_report_domains @cust_id="+cust.s_cust_id+", @report_id="+sReportId);
			while( rs2.next() )
			{
				
				iCount++;
				dataItem = new JsonObject();
				bVal = rs2.getBytes("Domain");
				dataItem.put("Domain",new String(bVal,"UTF-8"));
				dataItem.put("Sent",rs2.getString("Sent"));
				dataItem.put("BBacks",rs2.getString("BBacks"));
				dataItem.put("BBackPrc",rs2.getString("BBackPrc"));
				dataItemArrDomain.put(dataItem);
			}
			data.put("Domains",dataItemArrDomain);
			rs2.close();
			allData.put(data);
		}

		rs.close();



	}



}
catch(java.lang.Exception ex)
{		
	logger.error("Exception: ",ex);
}
finally
{
	if (stmt!=null) stmt.close();
	if (conn!=null) cp.free(conn);
	
	if (stmt2!=null) stmt2.close();
	if (conn2!=null) cp.free(conn2);
	out.flush();

}
	out.print(allData.toString());

%>
