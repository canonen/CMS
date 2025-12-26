<%@ page
	language="java"
	import="java.net.*, 
			java.util.*, 
			com.britemoon.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<HTML>
<HEAD>
	<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
<SCRIPT>
	function get_status()
	{
		tasks.action = "task_manager.jsp";
		tasks.submit();
	}
</SCRIPT>
</HEAD>
<BODY>
<B><%="Date: "+new Date()%></B>
<H4>Task manager</H4>
<INPUT type=button value="Get status" onclick="get_status();">
<BR><BR>
<FORM method="POST" name="tasks" action="">
<TABLE border="1" cellspacing="0" cellpadding="2">
	<TR>
		<TH>Task Id</TH>
		<TH>Task Name</TH>
		<TH>Started by timer</TH>
		<TH>Cust_Id</TH>
		<TH>Id_Name</TH>
		<TH>Id</TH>
		<TH>String Comment</TH>
		<TH>Number Comment</TH>
		<TH>Date Comment</TH>
		<TH>Create Date</TH>
		<TH>Start Date</TH>
		<TH>Finish Date</TH>
	</TR>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}	
	BriteTimerGeneric btm = null;
	BriteTaskGeneric bt = null;

	for (Enumeration e = TaskManager.getTasks().elements() ; e.hasMoreElements() ;)
	{
		bt = (BriteTaskGeneric) e.nextElement();
		btm = bt.getTimer();
			
		String sTimerName = (btm==null)?"":btm.getTimerName();
%>
	<TR>
		<TD>&nbsp;<%=HtmlUtil.escape(bt.getTaskId())%></TD>
		<TD>&nbsp;<%=HtmlUtil.escape(bt.getTaskName())%></TD>
		<TD>&nbsp;<%=HtmlUtil.escape(sTimerName)%></TD>
		
		<TD>&nbsp;<%=HtmlUtil.escape(bt.getCustId())%></TD>
		<TD>&nbsp;<%=HtmlUtil.escape(bt.getIdName())%></TD>
		<TD>&nbsp;<%=HtmlUtil.escape(bt.getId())%></TD>

		<TD>&nbsp;<%=HtmlUtil.escape(bt.getStringComment())%></TD>
		<TD>&nbsp;<%=HtmlUtil.escape(bt.getNumberComment())%></TD>
		<TD>&nbsp;<%=HtmlUtil.escape(bt.getDateComment())%></TD>
		
		<TD>&nbsp;<%=bt.getCreateDate()%></TD>
		<TD>&nbsp;<%=bt.getStartDate()%></TD>
		<TD>&nbsp;<%=bt.getFinishDate()%></TD>
	</TR>
<%
	}
%>
</TABLE>
</FORM>

</BODY>
</HTML>