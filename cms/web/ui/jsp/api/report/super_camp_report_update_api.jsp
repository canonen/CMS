<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,java.util.*,
			java.sql.*,java.util.Date,
			java.io.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
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

	// Connection
	Statement		stmt	= null;
	Statement		stmt2	= null;
	ResultSet		rs		= null; 
	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Connection		conn2	= null;
	JsonObject data= new JsonObject();
	JsonArray array= new JsonArray();
	String	sSuperCampID	= request.getParameter("id");
	String  sCampID			= null;

	if ( (sSuperCampID == null) || (sSuperCampID.equals("")) )
		throw new Exception ("Super Campaign ID required");

	StringWriter swXML = new StringWriter();


	try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_update.jsp");
	stmt = conn.createStatement();
	conn2 = cp.getConnection("report_update.jsp 2");
	stmt2 = conn2.createStatement();

	rs = stmt2.executeQuery ("SELECT c.camp_id"
			+ " FROM cque_super_camp_camp s, cque_campaign c"
			+ " WHERE s.camp_id = c.origin_camp_id"
			+ " AND c.type_id <> 1"
			+ " AND c.status_id > "+CampaignStatus.READY_TO_SEND
			+ " AND c.status_id < "+CampaignStatus.ERROR
			+ " AND s.super_camp_id = "+sSuperCampID);

    data.put("camp_reports",swXML);
	while (rs.next()) {
		sCampID = rs.getString(1);
		data.put("sCampID",sCampID);
		data.put("camp_report",swXML);
		data.put("cust_id",cust.s_cust_id);
		data.put("camp_reports",swXML);
		stmt.executeUpdate("EXEC usp_crpt_camp_report_update @camp_id = "+sCampID
						+ ", @cust_id = "+cust.s_cust_id
						+ ", @status_id = "+ReportStatus.QUEUED);


	}
	data.put("camp_reports",swXML);
	array.put(data);
	out.print(array);
	
 //System.out.println(swXML.toString());
	
	if (swXML.toString().length() > 0) {
		//		Service service = null;
		//		Vector services = Services.getByCust(ServiceType.RRPT_CAMPAIGN_REPORT_QUEUE, cust.s_cust_id);
		//
		//		service = (Service) services.get(0);
		//		service.connect();
		//
		//		Msg msgOut = new Msg(swXML.toString());
		//		service.sendMsg(msgOut);
		//
		//		out.print(service.receive());
		//		service.disconnect();

		String sMsg = Service.communicate(ServiceType.RRPT_CAMPAIGN_REPORT_QUEUE, cust.s_cust_id, swXML.toString());
	}




	}
	catch(Exception ex) { 
		ErrLog.put(this, ex, "Campaign Update Error.",out,1);
	} finally {
		try { 	
			if( stmt != null ) stmt.close(); 
			if( stmt2 != null ) stmt2.close(); 
		} catch (Exception ex2) {}
		if( conn != null ) cp.free(conn); 
		if( conn2 != null ) cp.free(conn2); 
	}
%>
