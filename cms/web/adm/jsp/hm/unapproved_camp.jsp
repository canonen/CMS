<%@ page
	language="java"
	import="java.net.*, 
			java.util.*, 
			java.sql.*, 
			com.britemoon.*, 
			com.britemoon.cps.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}	
int nThreshold = 24;
String sThreshold = Registry.getKey("hmon_max_camp_unapproval_hours");
if (sThreshold!=null) {
	try { nThreshold = Integer.parseInt(sThreshold); }
	catch(Exception ex){ nThreshold = 24; }
}

String sCustId = null;
String sCustName = null;
String sCampId = null;
String sCampType = null;
String sCampName = null;
String sStartDate = null;

ConnectionPool	cp = null;
Connection	conn = null;
Statement	stmt = null;
ResultSet	rs = null;

String sSql =
	"SELECT c.cust_id, m.cust_name, c.camp_id, t.display_name, c.camp_name,	CONVERT(VARCHAR(32), s.start_date, 100)" +
	"  FROM cque_campaign c WITH(NOLOCK), cque_camp_type t WITH(NOLOCK), cque_camp_statistic s WITH(NOLOCK), ccps_customer m WITH(NOLOCK)" +
	" WHERE c.status_id = " + CampaignStatus.READY_TO_SEND +
	"   AND c.type_id = t.type_id " +
	"   AND c.camp_id = s.camp_id " +
	"   AND c.cust_id = m.cust_id " +
	"   AND (m.aprvl_workflow_flag IS NULL OR m.aprvl_workflow_flag = 0) " +
	"   AND (c.approval_flag IS NULL OR c.approval_flag = 0) " +
	"   AND (DATEDIFF(hh, s.start_date, getdate()) >= " + nThreshold + " ) " +
	"UNION " +
	"SELECT c.cust_id, m.cust_name, c.camp_id, t.display_name, c.camp_name,	CONVERT(VARCHAR(32), r.request_date, 100)" +
	"  FROM cque_campaign c WITH(NOLOCK), cque_camp_type t WITH(NOLOCK), ccps_customer m WITH(NOLOCK)," +
	"       ccps_aprvl_request r WITH(NOLOCK), ccps_aprvl_task k WITH(NOLOCK) " +
	" WHERE c.status_id = " + CampaignStatus.PENDING_APPROVAL +
	"   AND c.type_id = t.type_id " +
	"   AND c.cust_id = m.cust_id " +
	"   AND (m.aprvl_workflow_flag = 1) " +
	"   AND c.cust_id = k.cust_id " +
	"   AND c.camp_id = k.object_id " +
	"   AND k.object_type = " + ObjectType.CAMPAIGN +
	"   AND k.active_flag = 1 " +
    "   AND k.approval_id = r.aprvl_id " +
	"   AND r.active_flag = 1 " +
	"   AND (DATEDIFF(hh, r.request_date, getdate()) >= " + nThreshold + " ) ";
%>
<H4>The following campaigns have been started but not approved after <%=nThreshold%> hours</H4>
<BR>
<%
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("unapproved_camp.jsp");
	stmt = conn.createStatement();
	
	rs = stmt.executeQuery(sSql);
	if (rs.next()) {
%>

<TABLE border=1 cellpadding=1 cellspacing=0>
	<TR>
		<TH>Customer ID</TH>
		<TH>Customer Name</TH>
		<TH>Campaign ID</TH>
		<TH>Campaign Type</TH>		
		<TH>Campaign Name</TH>		
		<TH>Campaign Start Date</TH>		
		<TH>Comment</TH>		
	</TR>
<%
	     do {
			 sCustId = rs.getString(1);
			 sCustName = rs.getString(2);
			 sCampId = rs.getString(3);
			 sCampType = rs.getString(4);
			 sCampName = rs.getString(5);
			 sStartDate = rs.getString(6);
%>
	<TR>
		<TD><%=sCustId%></TD>
		<TD><%=sCustName%></TD>
		<TD><%=sCampId%></TD>
		<TD><%=sCampType%></TD>
		<TD><%=sCampName%></TD>
		<TD><%=sStartDate%></TD>
		<TD>warning</TD>
	</TR>
<%
		 } 
		 while(rs.next());
%>
</TABLE>
<HR>
<%	
	}
	rs.close();
}
catch(Exception ex)
{
	logger.error("Exception: ",ex);
}
finally {
	try { if ( stmt != null ) stmt.close(); }
	catch (SQLException se) { }
	if ( conn != null ) cp.free(conn); 
}

%>

<H4>DONE!</H4>
</BODY>
</HTML>

