<%@ page
	language="java"
	import="com.jscape.inet.ftp.*, 
			com.britemoon.*, 
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

<FORM action='ftp_task_start.jsp' method=POST>
<INPUT type='hidden' name='task_id' value='<%=sTaskId%>'>
<TABLE border=1 cellspacing=0 cellpadding=1>
	<TR>
		<TD>
			<TABLE border=0 cellspacing=0 cellpadding=1>
				<TR>
					<TD colspan=2 align='center' valign='top'>
						<H5>To start ftp import manually:</H5>
					<TD>
				</TR>
				<TR>
					<TD valign='top'>1.</TD>
					<TD valign='top'>Select file to import from list below</TD>
				</TR>
				<TR>
					<TD valign='top'>2.</TD>
					<TD valign='top'>
						Set date to be formated and used as import name label,<BR>
						unless 'name_import_as_file_flag' is set
					</TD>
				</TR>
				<TR>
					<TD valign='top'></TD>
					<TD valign='top'>
						<TABLE border=0 cellspacing=0 cellpadding=1>
							<TR>					
								<TD>date (YYYY-MM-DD)</TD>
								<TD><INPUT type='text' name='date' value='<%=sDate%>'></TD>
							</TR>
							<TR>
								<TD>time (optional, HH:MM:SS)</TD>
								<TD><INPUT type='text' name='time' value='<%=sTime%>'></TD>
							</TR>
						</TABLE>
					</TD>
				</TR>											
				<TR>
					<TD valign='top'>3.</TD>				
					<TD valign='top'><INPUT type='submit' value='Start &gt;&gt;'></TD>
				</TR>
			</TABLE>
		</TD>	
		<TD>		
			<FONT color="#FF0000">
				Manual ftp import implies, that you know what are you doing<BR>
				It will start and will ignore:<BR>
				1. if file was already imported<BR>
				2. if import has already run for 'label' date or subsequent dates<BR>
				3. if linked ftp import ever succeeded or not<BR>
				It will not affect next start date for this import.<BR>
			</FONT>
		</TD>
	</TR>	
</TABLE>
<BR><BR>
<TABLE border=1 cellspacing=0 cellpadding=1>
	<TR>
		<TH>&nbsp;</TH>	
		<TH>Remote file name</TH>
	</TR>
<%
	FtpTask ft = new FtpTask(sTaskId);
	String sFileNameMask = "";
	/*
	if( ft.s_filename_prefix != null ) sFileNameMask += ft.s_filename_prefix;
	if( ft.s_filename_suffix != null ) sFileNameMask += ft.s_filename_suffix;
	*/
	if( "".equals(sFileNameMask) ) sFileNameMask ="*";
	
	Vector vFilesToDownload = FtpUtil.getFilesToDownload(ft, sFileNameMask);

	for(Enumeration e = vFilesToDownload.elements(); e.hasMoreElements();)
	{
		String sFileNameRemote = (String) e.nextElement();
%>
	<TR>
		<TD><INPUT type="radio" name="file_name_remote" value="<%=HtmlUtil.escape(sFileNameRemote)%>"></TD>
		<TD><%=HtmlUtil.escape(sFileNameRemote)%></TD>
	</TR>
<%
	}		
%>
</TABLE>
</FORM>

</BODY>
</HTML>
