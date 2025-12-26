<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*, 
			com.britemoon.*, 
			java.util.*,
			java.sql.*,
			java.util.Date,
			java.io.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%@ include file="/ui/jsp/header.jsp"%>
<HTML>

<HEAD>
	<BASE target="_self">
	<LINK rel="stylesheet" href="/ui/css/style.css" type="text/css">
</HEAD>
<BODY>


<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

String	sCampID	= null;
String	sCustID = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	int nCamp = 0;
	String sSql =
		" SELECT camp_id, cust_id FROM crpt_camp_summary" +
		" WHERE status_id < "+ReportStatus.COMPLETE;

	rs = stmt.executeQuery(sSql);
	while (rs.next())
	{
		sCampID = rs.getString(1);
		sCustID = rs.getString(2);

		StringWriter swXML = new StringWriter();
		swXML.write("<camp_reports>\r\n");
		swXML.write("<camp_report>\r\n");
		swXML.write("<camp_id>"+sCampID+"</camp_id>\r\n");
		swXML.write("<cust_id>"+sCustID+"</cust_id>\r\n");
		swXML.write("</camp_report>\r\n");
		swXML.write("</camp_reports>\r\n");

		String sMsg = Service.communicate(ServiceType.RRPT_CAMP_REPORT_SYNC, sCustID, swXML.toString());
		out.print(sMsg+" "+sCampID+"<BR>");
		nCamp++;
	}
	rs.close();
	
	out.print("done "+nCamp);

}
catch(Exception ex)
{ 
	ErrLog.put(this, ex, "Campaign Sync Error.",out,1);
} 
finally
{

	try { if( stmt != null ) stmt.close(); }
	catch (Exception ex2) {}
	if( conn != null ) cp.free(conn); 
}
%>
</BODY>
</HTML>
