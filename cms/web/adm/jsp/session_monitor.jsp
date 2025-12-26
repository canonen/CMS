<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.sql.*,
			java.io.*,
			java.util.*,
			org.apache.log4j.*"
%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%! static Logger logger = null;%>
<HTML>

<HEAD>
<meta charset="utf-8">
<title>Revotas Session Monitor</title>
<META HTTP-EQUIV="refresh" CONTENT="20">
<meta http-equiv="Content-type" value="text/html; charset=utf-8">
<style>
	html, body {
		font-family:Arial;
		font-size:100%;
		margin:0px;
	}
	#listTable, #options {
		border-collapse:collapse;
	}
	#listTable td {
		background-color: #F3F6FF;
    border-bottom: 1px solid #C8D2F4;
    font-size: 70%;
    padding: 6px;
    text-align: left;
	}
	#listTable th {
		background-color: #B9C9FE;
		border-bottom: 1px solid #86A0F3;
		color: #062B83;
		font-size: 75%;
		font-weight: bold;
		padding: 6px;
		text-align: left;
	}
	#options td {
		padding:6px;
		font-size:70%;
		color:#000;
	}
	.inputs {
		border:1px solid #B9C9FE;
		padding:3px;
	}
	.button {
		background-color: #B9C9FE;
    border: 1px solid #86A0F3;
    font-family: arial;
    font-size: 100%;
    font-weight: bold;
    outline: medium none;
    padding: 3px;
	}
	#options {
		background-color: #F3F6FF;
    border: 1px solid #86A0F3;
    margin-right:10px
	}
</style>

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
<TABLE id="listTable" cellspacing="0" cellpadding="0" width="100%">
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
			int c = 0;
			String color = "";
			while(rs.next())
			{
				if(c % 2 == 0)
				{
						color = "FFFFFF";
				} else {
					color = "F3F6FF";
				}
				sSessionId = rs.getString(1);
				sCustId = rs.getString(2);
				
				b = rs.getBytes(3);
				sCustName = (b==null)?null:new String(b, "UTF-8");
				
				sUserId = rs.getString(4);

				b = rs.getBytes(5);
				sUserName = (b==null)?null:new String(b, "UTF-8");
				
				sLoginTime = rs.getString(6);
				sLastAccessTime = rs.getString(7);
				sIdleTime = rs.getString(8);
				
				b = rs.getBytes(9);
				sLastUrl = (b==null)?null:new String(b, "UTF-8");

				b = rs.getBytes(10);
				sPhone = (b==null)?null:new String(b, "UTF-8");
%>
	<TR>
		<TD style="background-color:#<%=color%>" nowrap><%=(sSessionId == null)?"":sSessionId%></TD>
		<TD style="background-color:#<%=color%>" nowrap><%=(sCustId == null)?"":sCustId%></TD> 
		<TD style="background-color:#e8edff" nowrap><b style="font-size:103%"><%=(sCustName == null)?"":sCustName%></b></TD>
		<TD style="background-color:#<%=color%>" nowrap><%=(sUserId == null)?"":sUserId%></TD>
		<TD style="background-color:#e9feed;font-weight:bold;" nowrap><%=(sUserName == null)?"":sUserName%></TD>
		<TD style="background-color:#<%=color%>" nowrap><%=(sPhone == null)?"":sPhone%></TD>
		<TD style="background-color:#<%=color%>" nowrap><%=(sLoginTime == null)?"":sLoginTime%></TD>
		<TD style="background-color:#<%=color%>" nowrap><%=(sLastAccessTime == null)?"":sLastAccessTime%></TD>
		<TD style="background-color:#fcf1f1" nowrap><b style="font-size:103%"><%=(sIdleTime == null)?"":sIdleTime%></b></TD>
		<TD style="background-color:#<%=color%>" nowrap><%=(sLastUrl == null)?"":sLastUrl%></TD>
	</TR>
<%
			c++;
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
<div style="padding-top:5px;font-size:70%;text-align:right;padding-right:5px">* Reloading every 20 seconds.</div>
<br><br>
<FORM method="POST" action="session_monitor.jsp">
	<TABLE id="options" cellpadding="0" cellspacing="0" align="right">
		<TR>
			<TD>I'd like to see all logins within last </TD>
			<TD><INPUT class="inputs" type="text" name="login_period" size="20" value="<%=sLoginPeriod%>"></TD>
			<TD> hours,</TD>
			</TR>
		<TR>
			<TD>and idle time less than </TD>
			<TD><INPUT class="inputs" type="text" name="idle_time" size="20" value="<%=sIdleTime%>"></TD>
			<TD> seconds</TD>
		</TR>
		<TR>
			<TD colspan="3">
				<INPUT class="button" type="submit" value="Submit" name="B1">
			</TD>
		</TR>
	</TABLE>
</FORM>
</BODY>
</HTML>
