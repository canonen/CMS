<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.upd.*, 
			java.io.*, 
			java.text.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String sTaskId = BriteRequest.getParameter(request,"task_id");
	if(sTaskId == null)
	{
		String sSetupId = BriteRequest.getParameter(request,"setup_id");
		sTaskId = sSetupId;
	}
	
	java.util.Date dDate = new java.util.Date();
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	String sDate = sdf.format(dDate);
	sdf = new SimpleDateFormat("HH:mm:ss");	
	String sTime = sdf.format(dDate);	
%>
<HTML>
<HEAD>
<title>FTP Import History</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
<SCRIPT language="javascript">
	function PrepSubmit()
	{
		FT.ResetList.value = '';
		var numChecks = 0;
		var TaskId='';

		if (FT.TCheck.length == undefined)
		{
			if (FT.TCheck.checked)
			{
				FT.ResetList.value += FT.TCheck.value + ",";
				if (TaskId !='') TaskId += ',';
				TaskId += FT.TCheck.value;
				numChecks++;
			}
		}
		else
		{
			for (i=0; i < FT.TCheck.length; i++)
			{
				if (FT.TCheck[i].checked)
				{
					FT.ResetList.value += FT.TCheck[i].value + ",";
					if (TaskId !='') TaskId += ',';
					TaskId += FT.TCheck[i].value;
					numChecks++;
				}
			}
		}
		
		if (TaskId != '')
		{
			FT.action += "?task_id=" + TaskId;
			FT.submit();
		}
		else
		{
			alert("Choose at least one task to reset.");
		}
	}
</SCRIPT>
</HEAD>
<BODY>
<%
	String sql = "EXEC usp_cftp_ftp_task_host_monitor @task_id=" + sTaskId;
%>
<PRE>SQL = <%=sql%></PRE>
<BR><BR>
<a href="#1" OnClick="PrepSubmit();" class="button">Reset Selected Tasks</a>
<BR><BR>
<form name="FT" id="FT" method="post" action="ftp_import_hm_reset.jsp">
<input type="hidden" name="ResetList" value=""/>
<TABLE border=1 cellspacing=0 cellpadding=1>
	<TR>
		<TH>Select</TH>	
		<TH>History</TH>	
		<TH>task_id</TH>
		<TH>days_ago</TH>
		<TH>download_date</TH>
		<TH>HM magic word</TH>		
	</TR>
<%
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	try
	{
		String sDaysAgo = null;
		String sDownloadDate = null;

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		ResultSet rs = stmt.executeQuery(sql);
		String sPrevTaskId = null;
		while(rs.next())
		{
			sTaskId = rs.getString(1);		
			sDaysAgo = rs.getString(2);
			sDownloadDate = rs.getString(3);
			boolean isNewTaskId = true;
			if (sPrevTaskId != null && sTaskId.equals(sPrevTaskId))
			{
				isNewTaskId = false;
			}
			sPrevTaskId = sTaskId;
%>
	<TR>
<%
			if (isNewTaskId)
			{
%>
		<TD><input type="checkbox" name="TCheck" value="<%= sTaskId %>"></TD>
<%
			}
			else
			{
%>
		<TD>&nbsp</TD>
<%
			}
%>
		<TD><A href="ftp_task_history.jsp?task_id=<%=sTaskId%>">History</A></TD>
		<TD nowrap><%=sTaskId%></TD>	
		<TD nowrap><%=sDaysAgo%></TD>
		<TD nowrap><%=sDownloadDate%></TD>
		<TD nowrap>ALERT</TD>
<%
		}
		rs.close();
	}
	catch (Exception ex)
	{
		logger.error("Exception: ", ex);
		out.println("<PRE>");
		ex.printStackTrace(new PrintWriter(out));
		out.println("</PRE>");
	}
	finally
	{
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn);			
	}
%>
</TABLE>
</form>

</BODY>
</HTML>
