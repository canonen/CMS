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
</HEAD>
<BODY>

<FORM action='ftp_task_start_select.jsp' method=POST>
<INPUT type='hidden' name='task_id' value='<%=sTaskId%>'>
<INPUT type='submit' value='Start manually &gt;&gt;'>
</FORM>

<TABLE border=1 cellspacing=0 cellpadding=1>
	<TR>
		<TH>file_id</TH>	
		<TH>task_id</TH>
		<TH>file_name_remote</TH>
		<TH>file_name_local</TH>
		<TH>start_date</TH>
		<TH>finish_date</TH>
		<TH>status_id</TH>
		<TH>recip_import_id</TH>
		<TH>entity_import_id</TH>
		<TH>days_ago</TH>		
		<TH>error_msg</TH>		
	</TR>
<%
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	String sql =
		"SELECT ff.file_id," +		
			" ff.task_id," +
			" ff.file_name_remote," +
			" ff.file_name_local," +
			" ff.start_date," +
			" ff.finish_date," +
			" ff.status_id," +
			" ffa.recip_import_id," +
			" ffa.entity_import_id," +
			" DATEDIFF(dd, ISNULL(start_date,getdate()), getdate())," +
			" ff.error_msg" +
		" FROM cftp_ftp_file ff" +
			" LEFT OUTER JOIN cftp_ftp_file_assignments ffa" +		
				" ON ff.file_id = ffa.file_id" +
		" WHERE (ff.task_id=" + sTaskId + " OR 0=" + sTaskId + ")" + 
		" ORDER BY ff.start_date DESC";

	try
	{
		String sDownloadId = null;
		String sFileNameRemote = null;
		String sFileNameLocal = null;
		String sStartDate = null;
		String sFinishDate = null;
		String sStatusId = null;
		String sRecipImportId = null;
		String sEntityImportId = null;
		String sDaysAgo = null;		
		String sErrorMsg = null;
		
		boolean bAlert = false;

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		ResultSet rs = stmt.executeQuery(sql);
		while(rs.next())
		{
			sDownloadId = rs.getString(1);		
			sTaskId = rs.getString(2);
			sFileNameRemote = rs.getString(3);
			sFileNameLocal = rs.getString(4);
			sStartDate = rs.getString(5);
			sFinishDate = rs.getString(6);
			sStatusId = rs.getString(7);
			sRecipImportId = rs.getString(8);
			sEntityImportId = rs.getString(9);
			sDaysAgo = rs.getString(10);
			sErrorMsg = rs.getString(11);			
%>
	<TR>
		<TD nowrap><%=sDownloadId%></TD>	
		<TD nowrap><%=sTaskId%></TD>
		<TD nowrap><%=sFileNameRemote%></TD>
		<TD nowrap><%=sFileNameLocal%></TD>
		<TD nowrap><%=sStartDate%></TD>
		<TD nowrap><%=sFinishDate%></TD>
		<TD nowrap><%=sStatusId%></TD>
		<TD nowrap><%=sRecipImportId%></TD>
		<TD nowrap><%=sEntityImportId%></TD>
		<TD nowrap><%=sDaysAgo%></TD>		
		<TD nowrap><%=sErrorMsg%></TD>		
	</TR>
<%
		}
		rs.close();
	}
	catch (Exception ex)
	{
		ex.printStackTrace();
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

</BODY>
</HTML>
