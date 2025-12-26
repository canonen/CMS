<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,
			java.sql.*,
			java.lang.*,
			java.io.*,
			java.net.*,
			java.text.DateFormat,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
Statement	  	stmt	= null;
ResultSet	  	rs		= null; 
ConnectionPool	cp		= null;
Connection	  	conn	= null;

String	DAY1	= request.getParameter("day1");
String	MONTH1	= request.getParameter("month1");
String	YEAR1	= request.getParameter("year1");
String	DAY2	= request.getParameter("day2");
String	MONTH2	= request.getParameter("month2");
String	YEAR2	= request.getParameter("year2");
String	SORT	= request.getParameter("sort");
if (SORT == null)	SORT = "customer";

String CUSTOMER = request.getParameter("customer");
String PARTNER =  request.getParameter("partner");
String SQL_CUSTOMER, htmlString = "";
String SQLselect   = "";

if ((CUSTOMER.length() == 0) && (PARTNER.length() == 0)) {
%>
<h3>You must select either a partner or a customer!</h3> 
Please back up your browser.
<%
	return;
}
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("admin_camp_report_form.jsp");
	stmt = conn.createStatement();

	if (CUSTOMER.length() == 0) {
		//Need to load all of the customers for that partner into the SQL_CUSTOMER string
		rs = stmt.executeQuery ("SELECT DISTINCT cust_id FROM ccps_cust_partner" +
			( (PARTNER.equals("0")) ? "" : (" WHERE partner_id = "+PARTNER) ));
		String custList = "";
		while (rs.next()) {
			custList += ","+rs.getString(1);
		}
		if (custList.length() == 0) {
			%>
			<h3> That partner has no customers assigned to it!</h3>
			Please add customers to that partner and try again.
			<%
			return;
		}

		SQL_CUSTOMER = "("+custList.substring(1)+")";
		htmlString = (PARTNER.equals("0")) ? "all partners" : "partner #" + PARTNER;
		
	} else {
		SQL_CUSTOMER = "("+CUSTOMER+")";
		htmlString = (CUSTOMER.equals("0")) ? "all customers" : "customer #" + CUSTOMER;
	}

String [] SQLarray = new String [2];
String SQLorder    = "";
String SQLselectPartStart = 
	" FROM cque_campaign g, ccps_customer c, cque_camp_type t, cque_camp_statistic s, cque_camp_send_param p, cque_msg_header m" +
	" WHERE g.camp_id = s.camp_id AND g.camp_id = p.camp_id AND g.camp_id = m.camp_id" +
		" AND g.cust_id = c.cust_id" + 
		" AND s.start_date >= '"+YEAR1+"-"+MONTH1+"-"+DAY1+"'" +
		" AND s.start_date <= '"+YEAR2+"-"+MONTH2+"-"+DAY2+"'" +
		" AND g.status_id > " + CampaignStatus.DRAFT +
		" AND t.type_id = g.type_id" +
	( (CUSTOMER.equals("0")) ?   " AND c.cust_id > 0" : (" AND c.cust_id IN " + SQL_CUSTOMER));
String SQLselectPartFinish = 
	" FROM cque_campaign g, ccps_customer c, cque_camp_type t, cque_camp_statistic s, cque_camp_send_param p, cque_msg_header m" +
	" WHERE g.camp_id = s.camp_id AND g.camp_id = p.camp_id AND g.camp_id = m.camp_id" +
		" AND g.cust_id = c.cust_id" + 
		" AND s.finish_date >= '"+YEAR1+"-"+MONTH1+"-"+DAY1+"'" +
		" AND s.finish_date <= '"+YEAR2+"-"+MONTH2+"-"+DAY2+"'" +
		" AND g.status_id > " + CampaignStatus.DRAFT +
		" AND t.type_id = g.type_id" +
	( (CUSTOMER.equals("0")) ?   " AND c.cust_id > 0" : (" AND c.cust_id IN " + SQL_CUSTOMER));

%>
<H3>Revotas Internal Report on <%= htmlString %>
for the period between <%=MONTH1%>/<%=DAY1%>/<%=YEAR1%> and <%=MONTH2%>/<%=DAY2%>/<%=YEAR2%> 
</H3>


<TABLE cellpadding=1 cellspacing=1 border=1><TR>
<TH>Customer (<a href="#1" ONCLICK="sortbyCustomer()">sort</a>)</TH>
<TH>Campaign date (<a href="#1" ONCLICK="sortbyDate()">sort</a>)</TH>
<TH>Campaign name</TH>
<TH>QueueID</TH>
<TH>Response Forwarding</TH>
<TH>Subject</TH>
<TH>Recipients Queued</TH>
<TH>Recipients Sent</TH>
</TR>
<TR><TD COLSPAN=8><H3>Standard campaigns</H3></TD></TR>
<%


	String sDate=null, sCustomer=null, sCampName=null, sCampID=null, sRespForw=null, sSubject=null;
	int nQueuedRecs, nQueuedTotal, nRecs, nTotal, nCamps;
	//-------------------------
	if (SORT.equals ("date"))	
	{
		SQLarray [0] = "finish_date DESC";
		SQLarray [1] = "cust_name";
	}
	else
	{
		SQLarray [0] = "cust_name";
		SQLarray [1] = "finish_date DESC";
	}
	SQLorder = SQLarray [0] + ", " + SQLarray [1];

	SQLselect = "SELECT c.cust_name, s.start_date, g.camp_name, g.camp_id," + 
		" ISNULL (p.response_frwd_addr, '---'), ISNULL (m.subject_html, '---'), s.recip_queued_qty, s.recip_sent_qty " + 
		SQLselectPartFinish + " AND g.type_id = "+CampaignType.STANDARD+" ORDER BY " + SQLorder;

	rs = stmt.executeQuery (SQLselect);
	nTotal = 0; nQueuedTotal = 0; nCamps = 0;
	while ( rs.next() ) { 
		sCustomer = (new String(rs.getBytes(1),"ISO-8859-1"));
		sDate = rs.getString(2);
		sCampName = (new String(rs.getBytes(3),"ISO-8859-1"));
		sCampID = rs.getString(4);
		sRespForw = rs.getString(5);
		sSubject = (new String(rs.getBytes(6),"ISO-8859-1"));
		nQueuedRecs = rs.getInt(7);
		nQueuedTotal += nQueuedRecs;
		nRecs = rs.getInt(8);
		nTotal += nRecs;
		nCamps ++;
		%><TR>	<TD><%=sCustomer%></TD>
			<TD><%=sDate%></TD>
			<TD><%=sCampName%></TD>
			<TD><%=sCampID%></TD>
			<TD><%=sRespForw%></TD>
			<TD><%=sSubject%></TD>
			<TD><CENTER><%=nQueuedRecs%></CENTER></TD>
			<TD><CENTER><%=nRecs%></CENTER></TD></TR><%		
	}
	rs.close();
	%><TR>	<TD COLSPAN=6>TOTAL CAMPAIGNS:</TD>
		<TD COLSPAN=2><CENTER><b><%=nCamps%></b></CENTER></TD></TR>
	  <TR>	<TD COLSPAN=6>TOTAL RECIPIENTS QUEUED:</TD>
		<TD COLSPAN=2><CENTER><b><%=nQueuedTotal%></b></CENTER></TD></TR>
	  <TR>	<TD COLSPAN=6>TOTAL RECIPIENTS SENT:</TD>
		<TD COLSPAN=2><CENTER><b><%=nTotal%></b></CENTER></TD></TR>

	<TR><TD COLSPAN=8><H3>Send to Friend campaigns</H3></TD></TR><%
	//-------------------------
	if (SORT.equals ("date"))	
	{
		SQLarray [0] = "start_date DESC";
		SQLarray [1] = "cust_name";
	}
	else
	{
		SQLarray [0] = "cust_name";
		SQLarray [1] = "start_date DESC";
	}
	SQLorder = SQLarray [0] + ", " + SQLarray [1];

	SQLselect = "SELECT c.cust_name, s.start_date, g.camp_name, g.camp_id," + 
		" ISNULL (p.response_frwd_addr, '---'), ISNULL (m.subject_html, '---'), s.recip_queued_qty, s.recip_sent_qty " + 
		SQLselectPartStart + " AND g.type_id = "+CampaignType.SEND_TO_FRIEND+" ORDER BY " + SQLorder;

	rs = stmt.executeQuery (SQLselect);
	nTotal = 0; nQueuedTotal = 0; nCamps = 0;
	while ( rs.next() ) { 
		sCustomer = (new String(rs.getBytes(1),"ISO-8859-1"));
		sDate = rs.getString(2);
		sCampName = (new String(rs.getBytes(3),"ISO-8859-1"));
		sCampID = rs.getString(4);
		sRespForw = rs.getString(5);
		sSubject = (new String(rs.getBytes(6),"ISO-8859-1"));
		nQueuedRecs = rs.getInt(7);
		nQueuedTotal += nQueuedRecs;
		nRecs = rs.getInt(8);
		nTotal += nRecs;
		nCamps ++;
		%><TR>	<TD><%=sCustomer%></TD>
			<TD><%=sDate%></TD>
			<TD><%=sCampName%></TD>
			<TD><%=sCampID%></TD>
			<TD><%=sRespForw%></TD>
			<TD><%=sSubject%></TD>
			<TD><CENTER><%=nQueuedRecs%></CENTER></TD>
			<TD><CENTER><%=nRecs%></CENTER></TD></TR><%		
	}
	rs.close();
	%><TR>	<TD COLSPAN=6>TOTAL CAMPAIGNS:</TD>
		<TD COLSPAN=2><CENTER><b><%=nCamps%></b></CENTER></TD></TR>
	  <TR>	<TD COLSPAN=6>TOTAL RECIPIENTS QUEUED:</TD>
		<TD COLSPAN=2><CENTER><b><%=nQueuedTotal%></b></CENTER></TD></TR>
	  <TR>	<TD COLSPAN=6>TOTAL RECIPIENTS SENT:</TD>
		<TD COLSPAN=2><CENTER><b><%=nTotal%></b></CENTER></TD></TR>

	<TR><TD COLSPAN=8><H3>Auto-respond campaigns</H3></TD></TR><%
	//-------------------------

	SQLselect = "SELECT c.cust_name, s.start_date, g.camp_name, g.camp_id," + 
		" ISNULL (p.response_frwd_addr, '---'), ISNULL (m.subject_html, '---'), s.recip_queued_qty, s.recip_sent_qty " + 
		SQLselectPartStart + " AND g.type_id = "+CampaignType.AUTO_RESPOND+" ORDER BY " + SQLorder;

	rs = stmt.executeQuery (SQLselect);
	nTotal = 0; nQueuedTotal = 0; nCamps = 0;
	while ( rs.next() ) { 
		sCustomer = (new String(rs.getBytes(1),"ISO-8859-1"));
		sDate = rs.getString(2);
		sCampName = (new String(rs.getBytes(3),"ISO-8859-1"));
		sCampID = rs.getString(4);
		sRespForw = rs.getString(5);
		sSubject = (new String(rs.getBytes(6),"ISO-8859-1"));
		nQueuedRecs = rs.getInt(7);
		nQueuedTotal += nQueuedRecs;
		nRecs = rs.getInt(8);
		nTotal += nRecs;
		nCamps ++;
		%><TR>	<TD><%=sCustomer%></TD>
			<TD><%=sDate%></TD>
			<TD><%=sCampName%></TD>
			<TD><%=sCampID%></TD>
			<TD><%=sRespForw%></TD>
			<TD><%=sSubject%></TD>
			<TD><CENTER><%=nQueuedRecs%></CENTER></TD>
			<TD><CENTER><%=nRecs%></CENTER></TD></TR><%		
	}
	rs.close();
	%><TR>	<TD COLSPAN=6>TOTAL CAMPAIGNS:</TD>
		<TD COLSPAN=2><CENTER><b><%=nCamps%></b></CENTER></TD></TR>
	  <TR>	<TD COLSPAN=6>TOTAL RECIPIENTS QUEUED:</TD>
		<TD COLSPAN=2><CENTER><b><%=nQueuedTotal%></b></CENTER></TD></TR>
	  <TR>	<TD COLSPAN=6>TOTAL RECIPIENTS SENT:</TD>
		<TD COLSPAN=2><CENTER><b><%=nTotal%></b></CENTER></TD></TR>

</TABLE>


<SCRIPT>

function sortbyCustomer()
{
window.location.href = window.location.pathname + "?day1=<%=DAY1%>&month1=<%=MONTH1%>&year1=<%=YEAR1%>" + 
	"&day2=<%=DAY2%>&month2=<%=MONTH2%>&year2=<%=YEAR2%>&customer=<%=CUSTOMER%>&sort=customer";
}

function sortbyDate()
{
window.location.href = window.location.pathname + "?day1=<%=DAY1%>&month1=<%=MONTH1%>&year1=<%=YEAR1%>" + 
	"&day2=<%=DAY2%>&month2=<%=MONTH2%>&year2=<%=YEAR2%>&customer=<%=CUSTOMER%>&sort=date";
}

</SCRIPT>
<%
} catch(Exception ex) { 

	ErrLog.put(this,ex,"Admin Report Error\r\n"+SQLselect,out,1);

} finally {
	try {
		if ( stmt != null ) stmt.close();
	} catch (SQLException se) { }
	if ( conn  != null ) cp.free (conn); 
}



%>
<!--<%=SQLselect%>-->
</BODY>
</HTML>

