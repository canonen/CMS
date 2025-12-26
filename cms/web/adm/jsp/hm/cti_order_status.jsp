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
int nThreshold = 600;
String sThreshold = Registry.getKey("hmon_max_cti_order_test_elapsed_seconds");
if(sThreshold!=null)
{
	try { nThreshold = Integer.parseInt(sThreshold); }
	catch(Exception ex){ nThreshold = 600; }
}

String sBriteOrderId = null;
String sCustId = null;
String sCustOrderId = null;
String sStatusName = null;
String sStatusDate = null;

ConnectionPool	cp = null;
Connection	conn = null;
Statement	stmt = null;
ResultSet	rs = null;

String sSql =  "SELECT brite_order_id, o.cust_id, cust_order_id, os.status_name, status_date " +
                         " FROM cxcs_order o WITH(NOLOCK), cxcs_order_status os WITH(NOLOCK) " +
                         " WHERE " +
                         " o.status_id < 40 AND " +
                         " o.status_id = os.status_id AND " +
                         " ( DATEDIFF(ss, o.status_date, getdate()) > " + nThreshold + " ) " +
                         " ORDER BY o.status_date DESC, brite_order_id";
%>
<H4>Threshold: <%=nThreshold%> seconds for CTI Order to be processed and change status</H4>
SQL:<BR><%=sSql%>
<%
	try {
          cp = ConnectionPool.getInstance();
          conn = cp.getConnection("cti_order_status.jsp");
          stmt = conn.createStatement();

          rs = stmt.executeQuery(sSql);
          if (rs.next()) {
%>

<TABLE border=1 cellpadding=1 cellspacing=0>
	<TR>
		<TH>Brite Order ID</TH>
		<TH>Customer ID</TH>
		<TH>Customer Order ID</TH>
		<TH>Status</TH>		
		<TH>Last Status Change</TH>		
		<TH>Host monitor magic word</TH>		
	</TR>
<%
			do
			{
				sBriteOrderId = rs.getString(1);
				sCustId = rs.getString(2);
				sCustOrderId = rs.getString(3);
				sStatusName = rs.getString(4);
				sStatusDate = rs.getString(5);
%>
	<TR>
		<TD><%=sBriteOrderId%></TD>
		<TD><%=sCustId%></TD>
		<TD><%=sCustOrderId%></TD>
		<TD><%=sStatusName%></TD>
		<TD><%=sStatusDate%></TD>
		<TD>bad</TD>
	</TR>
<%
			} while(rs.next());
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
	finally
	{
		try { if ( stmt != null ) stmt.close(); }
		catch (SQLException se) { }
		if ( conn != null ) cp.free(conn); 
	}

%>

<H4>DONE!</H4>
</BODY>
</HTML>

