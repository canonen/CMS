<%@ page
	language="java"
	import="java.net.*, 
			java.sql.*, 
			java.util.*, 
			com.britemoon.*, 
			com.britemoon.cps.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String sTimerName = request.getParameter("timer");
	if(sTimerName == null) return;
	BriteTimerGeneric btm = TimerManager.getTimer(sTimerName);
	if(btm == null) return;

	String sTaskCount = request.getParameter("task_count");
	if(sTaskCount == null) sTaskCount = "30";
%>

<BODY>
<B><%="Date: "+new java.util.Date()%></B>
<H3>Timer: <%=sTimerName%></H3>
<A href="task_list.jsp?timer=<%=URLEncoder.encode(sTimerName, "ISO-8859-1")%>" target=_blank>Current task list</A>
<BR><BR>
<FORM method="POST" name="tasks" action="task_history.jsp">
	<INPUT type=hidden name="timer" value="<%=sTimerName%>">
	Get last 
	<INPUT type=text name="task_count" value="<%=sTaskCount%>">
	tasks 
	<INPUT type=submit value="Go">
</FORM>
<TABLE border="1" cellspacing="0" cellpadding="2">
	<TR>
		<TH>Task Id</TH>
		<TH>Task Name</TH>
		<TH>Cust_Id</TH>
		<TH>Cust_Name</TH>		
		<TH>Id_Name</TH>
		<TH>Id</TH>
		<TH>String Comment</TH>
		<TH>Number Comment</TH>
		<TH>Date Comment</TH>
		<TH>Create Date</TH>
		<TH>Start Date</TH>
		<TH>Finish Date</TH>
		<TH>Task Details</TH>
	</TR>
<%
	ConnectionPool cp = null;
	Connection conn = null;
	
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		
		PreparedStatement pstmt = null;
		try
		{
			String sSql =
				" SELECT TOP " + sTaskCount +
					" t.task_id," +
					" t.task_name," +
					" t.cust_id," +
					" c.cust_name," +				
					" t.id_name," +
					" t.id," +
					" t.number_comment," +
					" t.date_comment," +
					" t.string_comment," +
					" t.create_date," +
					" t.start_date," +
					" t.finish_date" +
				" FROM ccps_task t WITH(NOLOCK)
					" LEFT OUTER JOIN ccps_customer c WITH(NOLOCK)" +
						" ON t.cust_id = c.cust_id" +				
				" WHERE t.timer_name = ?" +
				" ORDER BY task_id DESC";

				String sTaskId = null;
				String sTaskName = null;
				String sCustId = null;
				String sCustName = null;				
				String sIdName = null;
				String sId = null;
				String sNumberComment = null;
				String sDateComment = null;
				String sStringComment = null;
				String sCreateDate = null;
				String sStartDate = null;
				String sFinishDate = null;

			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1, sTimerName);
			ResultSet rs = pstmt.executeQuery();
			while(rs.next())
			{
				sTaskId = rs.getString(1);
				sTaskName = rs.getString(2);
				sCustId = rs.getString(3);
				sCustName = rs.getString(4);				
				sIdName = rs.getString(5);
				sId = rs.getString(6);
				sNumberComment = rs.getString(7);
				sDateComment = rs.getString(8);
				sStringComment = rs.getString(9);
				sCreateDate = rs.getString(10);
				sStartDate = rs.getString(11);
				sFinishDate = rs.getString(12);
%>
	<TR>
		<TD>&nbsp;<%=sTaskId%></TD>
		<TD>&nbsp;<%=sTaskName%></TD>
		
		<TD>&nbsp;<%=sCustId%></TD>
		<TD>&nbsp;<%=("0".equals(sCustId))?"":sCustName%></TD>		
		<TD>&nbsp;<%=sIdName%></TD>
		<TD>&nbsp;<%=sId%></TD>

		<TD>&nbsp;<%=sStringComment%></TD>
		<TD>&nbsp;<%=sNumberComment%></TD>		
		<TD>&nbsp;<%=sDateComment%></TD>
		
		<TD>&nbsp;<%=sCreateDate%></TD>		
		<TD>&nbsp;<%=sStartDate%></TD>
		<TD>&nbsp;<%=sFinishDate%></TD>		
		<TD>&nbsp;<A href="task_details.jsp?task_id=<%=sTaskId%>" target=_blank>Task details</A></TD>
	</TR>
<%
			}
			rs.close();
		}
		catch(SQLException ex) { throw ex; }
		finally{ if(pstmt!=null) pstmt.close(); }
	}
	catch(SQLException ex) { throw ex; }
	finally{ if(conn!=null) cp.free(conn); }
%>
</FORM>
</BODY>
</HTML>