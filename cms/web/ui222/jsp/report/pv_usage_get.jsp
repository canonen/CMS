<%@ page 
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="java.text.*"
	import="java.sql.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%	if (logger == null) {
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%
	AccessPermission canT = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);
	AccessPermission canS = user.getAccessPermission(ObjectType.PV_CONTENT_SCORER);
	AccessPermission canO =	user.getAccessPermission(ObjectType.PV_DESIGN_OPTIMIZER);
	boolean canViewReport = canT.bRead || canS.bRead || canO.bRead;


	if (!canViewReport) {
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
	String YEAR1	= request.getParameter("year1");
	String MONTH1	= request.getParameter("month1");
	String DAY1	    = request.getParameter("day1");
	String YEAR2	= request.getParameter("year2");
	String MONTH2	= request.getParameter("month2");
	String DAY2	    = request.getParameter("day2");
    String sDateFrom =  YEAR1 + "-" + MONTH1 + "-" + DAY1;
    String sDateTo =  YEAR2 + "-" + MONTH2 + "-" + DAY2;

	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;
	ResultSet		rs		= null; 

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("delivery_audit_usage.jsp");
		stmt = conn.createStatement();

		String sSql = null;

		boolean hasHistory = false;
		String temp_camp_name = "";
		String temp_test_camp_id = "";
		String temp_main_camp_id = "";
		String temp_test_type_id = "";
		String temp_test_type_name = "";
		String temp_test_date = "";
		String temp_pv_iq = "";
	
		sSql = 
			"SELECT	h.camp_id TestCampId," +
			"	    h.pv_test_type_id PvTestTypeId," +
			"       isnull(h.test_date,'') TestDate," +
			"	    isnull(h.pv_iq, '') PvIq," +
			"	    m.camp_name CampName," +
			"       m.camp_id MainCampId" +
			"  FROM cque_camp_pv_hist h," +
			"       cque_campaign c," +
			"	    cque_campaign m" +
			" WHERE h.cust_id = " + cust.s_cust_id +
			"   AND h.test_date >= '" + sDateFrom + "'" +
			"   AND h.test_date < DATEADD(DAY,1,'" + sDateTo + "')" +
			"   AND h.camp_id = c.camp_id" +
			"   AND c.status_id = " + CampaignStatus.DONE+
			"   AND h.origin_camp_id = m.camp_id" +
			"   AND (m.type_id = " + CampaignType.STANDARD + " OR m.type_id = " + CampaignType.AUTO_RESPOND + ")" +
			" UNION " +
			"SELECT	h.camp_id TestCampId," +
			"	    h.pv_test_type_id PvTestTypeId," +
			"       isnull(h.test_date,'') TestDate," +
			"	    isnull(h.pv_iq, '') PvIq," +
			"	    m.camp_name CampName," +
			"       m.camp_id MainCampId" +
			"  FROM cque_camp_pv_hist h," +
			"	    cque_campaign m" +
			" WHERE h.cust_id = " + cust.s_cust_id + 
			"   AND h.camp_id IS NULL" +
			"   AND h.test_date >= '" + sDateFrom + "'" +
			"   AND h.test_date < DATEADD(DAY,1,'" + sDateTo + "')" +
			"   AND (h.origin_camp_id = m.camp_id)" + 
			"   AND (m.type_id = " + CampaignType.STANDARD + " OR m.type_id = " + CampaignType.AUTO_RESPOND + ")" +
			" ORDER BY TestDate DESC";

		rs = stmt.executeQuery(sSql);
	
%>
<html>
	<head>
		<title></title>
		<%@ include file="../header.html" %>
		<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
		<script src="../../js/scripts.js"></script>
		<script>
			function pv_report_popup(pv_test_type_id, pv_iq) 
			{
				URL = '/cms/ui/jsp/report/pv_report_iframe.jsp?pv_test_type_id='+pv_test_type_id+'&pv_iq=' + pv_iq;
				windowName = 'pv_report_window';
				windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
				SmallWin = window.open(URL, windowName, windowFeatures);
			}
		</script>
	</head>
	<body>
		<table class="main" cellspacing="1" cellpadding="2" width="100%" border="0">
			<tr>
				<td align="left" valign="middle" nowrap class="CampHeader"><b>Campain Name:</b></td>
				<td align="left" valign="middle" nowrap class="CampHeader"><b>Test ID:</b></td>
				<td align="left" valign="middle" nowrap class="CampHeader"><b>Type</b></td>
				<td align="left" valign="middle" nowrap class="CampHeader"><b>Status</b></td>
				<td align="left" valign="middle" nowrap class="CampHeader"><b>Test Date</b></td>
				<td align="left" valign="middle" nowrap class="CampHeader"><b>PV IQ</b></td>
			</tr>
<%
		while (rs.next()) {
			hasHistory = true;
			temp_test_camp_id = rs.getString(1);
			if (temp_test_camp_id == null) temp_test_camp_id = "---";
		
			temp_test_type_id = rs.getString(2);
			if (temp_test_type_id.equals("1")) temp_test_type_name = "eDelivery Tracker";
			if (temp_test_type_id.equals("2")) temp_test_type_name = "eContent Scorer";
			if (temp_test_type_id.equals("3")) temp_test_type_name = "eDesign Optimizer";
				
			temp_test_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(3));
			if (temp_test_date.equals("Jan 1, 1900 12:00 AM")) temp_test_date = "";
		
			temp_pv_iq = rs.getString(4);
			temp_camp_name = rs.getString(5);
			temp_main_camp_id = rs.getString(6);
%>
			<tr>
				<td align="left" valign="middle"><%=temp_camp_name%></td>
				<td align="left" valign="middle"><%=temp_test_camp_id%></td>
				<td align="left" valign="middle"><%=temp_test_type_name%></td>
				<td align="left" valign="middle">Done</td>
				<td align="left" valign="middle" nowrap><%=temp_test_date.replaceAll(",","")%></td>
				<td align="left" valign="middle"><%=temp_pv_iq%>&nbsp;&nbsp;<a href="javascript:pv_report_popup('<%= temp_test_type_id%>', '<%=temp_pv_iq %>');" class="resourcebutton">View PV Report</a></td>
			</tr>
<%
		}
		rs.close();
		if (hasHistory == false) {
%>
			<tr>
				<td class="CampHeader" colspan="7">No data found</td>
			</tr>		
<%
		}
	}
	catch (Exception ex) { throw ex; }
	finally	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn); 
	}
%>
		</table>
	</body>
</html>

