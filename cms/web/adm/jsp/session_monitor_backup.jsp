<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.sql.*,
			java.io.*,
			java.util.*,
			org.apache.log4j.*"
%>
<%! static Logger logger = null;%>
<HTML>

<HEAD>
	<LINK rel="stylesheet" href="../css/style.css" type="text/css">
</HEAD>

<BODY>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());	
	}
	String sLoginPeriod = request.getParameter("login_period");
	String sIdleTime = request.getParameter("idle_time");

	sLoginPeriod = (sLoginPeriod == null) ? "24" : sLoginPeriod;
	sIdleTime = (sIdleTime == null) ? "1800" : sIdleTime;
	
%>
<P>&nbsp</P>
<FORM method="POST" action="session_monitor.jsp">
	<TABLE border="0" cellspacing="0">
		<TR>
			<TD>I'd like to see all logins within last </TD>
			<TD><INPUT type="text" name="login_period" size="20" value="<%=sLoginPeriod%>"></TD>
			<TD> hours,</TD>
			</TR>
		<TR>
			<TD>and idle time less than </TD>
			<TD><INPUT type="text" name="idle_time" size="20" value="<%=sIdleTime%>"></TD>
			<TD> seconds</TD>
		</TR>
		<TR>
			<TD colspan="3" align="center">
				<INPUT type="submit" value="Submit" name="B1">
			</TD>
		</TR>
	</TABLE>
</FORM>
<BR>
<TABLE border="1" cellspacing="0">
	<TR>
		<TH>Session Id</TH>
		<TH>Customer Id</TH> 
		<TH>Customer Name</TH>
		<TH>User Id</TH>
		<TH>User Name</TH>
		<TH>Phone</TH>
		<TH>Login Time</TH>
		<TH>Last Access Time</TH>
		<TH>Idle Time (sec)</TH>
		<TH>Last URL</TH>
	</TR>
<%
	ConnectionPool cp = null;
	Connection conn = null;

	String sSql =
			" SELECT session_id, cust_id, cust_name, user_id, user_name," +
			" login_time, last_access_time, DATEDIFF(ss, last_access_time, getdate()) as idle_time," +
			" last_url, phone" +
			" FROM cadm_session_log" +
			" WHERE DATEDIFF(hh, login_time, getdate()) <= " + sLoginPeriod +
			" AND DATEDIFF(ss, last_access_time, getdate()) <= " + sIdleTime +
			" ORDER BY idle_time";

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("session_monitor.jsp");
		
		Statement stmt = null;
		ResultSet rs = null;
		try
		{
			stmt = conn.createStatement();
			rs = stmt.executeQuery(sSql);

			String sSessionId = null;
			String sCustId = null;
			String sCustName = null;
			String sUserId = null;
			String sUserName = null;
			String sLoginTime = null;
			String sLastAccessTime = null;
			String sLastUrl = null;
			String sPhone = null;

			byte[] b = null;
			while(rs.next())
			{
				sSessionId = rs.getString(1);
				sCustId = rs.getString(2);
				
				b = rs.getBytes(3);
				sCustName = (b==null)?null:new String(b, "ISO-8859-1");
				
				sUserId = rs.getString(4);

				b = rs.getBytes(5);
				sUserName = (b==null)?null:new String(b, "ISO-8859-1");
				
				sLoginTime = rs.getString(6);
				sLastAccessTime = rs.getString(7);
				sIdleTime = rs.getString(8);
				
				b = rs.getBytes(9);
				sLastUrl = (b==null)?null:new String(b, "ISO-8859-1");

				b = rs.getBytes(10);
				sPhone = (b==null)?null:new String(b, "ISO-8859-1");
%>
	<TR>
		<TD nowrap>&nbsp;<%=(sSessionId == null)?"":sSessionId%></TD>
		<TD nowrap>&nbsp;<%=(sCustId == null)?"":sCustId%></TD> 
		<TD nowrap>&nbsp;<%=(sCustName == null)?"":sCustName%></TD>
		<TD nowrap>&nbsp;<%=(sUserId == null)?"":sUserId%></TD>
		<TD nowrap>&nbsp;<%=(sUserName == null)?"":sUserName%></TD>
		<TD nowrap>&nbsp;<%=(sPhone == null)?"":sPhone%></TD>
		<TD nowrap>&nbsp;<%=(sLoginTime == null)?"":sLoginTime%></TD>
		<TD nowrap>&nbsp;<%=(sLastAccessTime == null)?"":sLastAccessTime%></TD>
		<TD nowrap>&nbsp;<%=(sIdleTime == null)?"":sIdleTime%></TD>
		<TD nowrap>&nbsp;<%=(sLastUrl == null)?"":sLastUrl%></TD>
	</TR>
<%
			}
			rs.close();
		}
		catch(Exception ex) { throw ex;	}
		finally { if(stmt!=null) stmt.close(); }
	}
	catch(Exception ex) { ex.printStackTrace(response.getWriter()); }
	finally { if(conn!=null) cp.free(conn); }
%>

</TABLE>
</BODY>
</HTML>
