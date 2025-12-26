<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.util.Date,java.io.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

StringWriter swXML = new StringWriter();
String sReportID = request.getParameter("report_id");
String sStartDate = request.getParameter("start_date");
String sEndDate = request.getParameter("end_date");

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("cust_report_create.jsp");
	stmt = conn.createStatement();

	String sSql = "EXEC usp_crpt_cust_report_update @cust_id = "+cust.s_cust_id
					+ ", @user_id = "+user.s_user_id
					+ ", @status_id = "+ReportStatus.QUEUED;

	if ( (sStartDate != null) && (sStartDate.length() > 0) ) 
		sSql += ", @start_date = '"+sStartDate+"'";
	if ( (sEndDate != null) && (sEndDate.length() > 0) ) 
		sSql += ", @end_date = '"+sEndDate+"'";
	if ( (sReportID != null) && (sReportID.length() > 0) ) 
		sSql += ", @report_id = '"+sReportID+"'";

	rs = stmt.executeQuery(sSql);

	if (rs.next()) sReportID = rs.getString(1);
	if (sReportID == null) throw new Exception ("Could not create customer report!");

	swXML.write("<cust_reports>\r\n");
	swXML.write("<cust_report>\r\n");
	swXML.write("<report_id>"+sReportID+"</report_id>\r\n");
	swXML.write("<cust_id>"+cust.s_cust_id+"</cust_id>\r\n");
	swXML.write("<user_id>"+user.s_user_id+"</user_id>\r\n");
	swXML.write("<start_date>"+sStartDate+"</start_date>\r\n");
	swXML.write("<end_date>"+sEndDate+"</end_date>\r\n");
	swXML.write("</cust_report>\r\n");
	swXML.write("</cust_reports>\r\n");

	String sMsg = Service.communicate(ServiceType.RRPT_CUST_REPORT_QUEUE, cust.s_cust_id, swXML.toString());

%>

<%

} catch(Exception ex) { 
	ErrLog.put(this, ex, "Report Error.",out,1);
} finally {

	try { 	
		if( stmt != null ) stmt.close(); 
	} catch (Exception ex2) {}
	if( conn != null ) cp.free(conn); 
}
%>
