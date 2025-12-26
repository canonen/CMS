<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.upd.*, 
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
	String sCustId = BriteRequest.getParameter(request,"cust_id");

	// === === ===
	
	FtpTask ft = new FtpTask();
	
	ft.s_task_id = BriteRequest.getParameter(request,"task_id");
	ft.s_task_name = BriteRequest.getParameter(request,"task_name");
	ft.s_cust_id = BriteRequest.getParameter(request,"cust_id");	
	ft.s_server = BriteRequest.getParameter(request,"server");
	ft.s_directory = BriteRequest.getParameter(request,"directory");
	ft.s_username = BriteRequest.getParameter(request,"username");
	ft.s_password = BriteRequest.getParameter(request,"password");
	ft.s_filename_prefix = BriteRequest.getParameter(request,"filename_prefix");
	ft.s_filename_suffix = BriteRequest.getParameter(request,"filename_suffix");
	ft.s_date_format = BriteRequest.getParameter(request,"date_format");
	ft.s_pgp_flag = BriteRequest.getParameter(request,"pgp_flag");
	ft.s_type_id = BriteRequest.getParameter(request,"task_type_id");

	ft.save();
	
	// === === ===
	
	FtpTaskSchedule fts = new FtpTaskSchedule();

	fts.s_task_id = ft.s_task_id;
	fts.s_linked_task_id = BriteRequest.getParameter(request,"linked_task_id");
	fts.s_next_start_date = BriteRequest.getParameter(request,"next_start_date");
	fts.s_next_start_interval = BriteRequest.getParameter(request,"next_start_interval");
                
        String[] sSWeekdayMask = BriteRequest.getParameterValues(request, "hm_daily_weekday_mask");
	if(sSWeekdayMask != null)
	{
		int nSWeekdayMask = 0;
		for(int i = 0; i < sSWeekdayMask.length; i++) nSWeekdayMask += Integer.parseInt(sSWeekdayMask[i]);	
		fts.s_hm_daily_weekday_mask = String.valueOf(nSWeekdayMask);
	}
	
	fts.save();
	
	// === === ===
	
	FtpTaskImportTemplate ftit = new FtpTaskImportTemplate();
	
	ftit.s_task_id = ft.s_task_id;
	ftit.s_recip_import_template_id = BriteRequest.getParameter(request,"recip_import_template_id");
	ftit.s_entity_import_template_id = BriteRequest.getParameter(request,"entity_import_template_id");
	
	ftit.save();
	
	// === === ===
%>
<%@ include file="../header.jsp"%>
<HTML>
<HEAD>
<title>FTP Imports</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<BR><BR>
<A href="ftp_task_edit.jsp?task_id=<%=ft.s_task_id%>">Edit saved Ftp Task</A>
<BR><BR>
<A href="ftp_task_list.jsp">Ftp Task List</A>
</BODY>
</HTML>