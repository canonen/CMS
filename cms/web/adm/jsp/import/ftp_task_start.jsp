<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.ftp.*, 
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
	String sFileNameRemote = BriteRequest.getParameter(request,"file_name_remote");	
	String sDate = BriteRequest.getParameter(request,"date");
	String sTime = BriteRequest.getParameter(request,"time");	

	if(sTime != null) sDate = sDate + " " + sTime;
	
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	java.util.Date dDate4ImportName = sdf.parse(sDate);
%>

<HTML>
<HEAD>
<title>FTP Import Start</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<H3>
	FtpImportTask<BR>
&nbsp;&nbsp;&nbsp;	task_id=<%=sTaskId%><BR>
&nbsp;&nbsp;&nbsp;	file_name_remote=<%=sFileNameRemote%><BR>
&nbsp;&nbsp;&nbsp;	Date4ImportName=<%=dDate4ImportName%><BR>
	has just started.
</H3>
<H3>Do not close the window till it is done!</H3>
<%
if((sTaskId == null)||(sFileNameRemote == null))
{
%>
<H3>ERROR: (sTaskId == null) OR (sFileNameRemote == null) !</H3>
<%
	return;
}
out.flush();
try
{	
	FtpImportTask fit = new FtpImportTask(sTaskId);
	fit.startFtpImportTask(sTaskId, sFileNameRemote, dDate4ImportName);
%>
<BR><BR>
<H1>Done!</H1>
<%
}
catch(Exception ex)
{
	logger.error("Exception: ", ex);
	out.println("<PRE>");
	ex.printStackTrace(new PrintWriter(out));
	out.println("</PRE>");
}
%>
<BR><BR>
<H1><A href="ftp_task_history.jsp?task_id=<%=sTaskId%>">Go to history page</A></H1>
</BODY>
</HTML>
