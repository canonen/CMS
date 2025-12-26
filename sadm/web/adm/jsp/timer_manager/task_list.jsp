<%@ page
	language="java"
	import="java.io.*,
		java.net.*, 
		java.util.*, 
		com.britemoon.*"
	contentType="text/html;charset=UTF-8"
%>

<HTML>
<HEAD>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
<SCRIPT>
	function skip_tasks()
	{
		tasks.action = "task_list.jsp?action=skip";
		tasks.submit();
	}

	function unskip_tasks()
	{
		tasks.action = "task_list.jsp?action=unskip";
		tasks.submit();
	}
	
	function get_status()
	{
		tasks.action = "task_list.jsp";
		tasks.submit();
	}
	
	function change_selection()
	{
		var v = tasks.prototype.checked;
		var n = tasks.task_fingerprint.length;
		for(var i=0; i < n; i++) tasks.task_fingerprint[i].checked = v;
	}
</SCRIPT>
</HEAD>
<BODY>

<%
	String sTimerName = request.getParameter("timer");
	String sAction = request.getParameter("action");
	String[] sTaskFingerprints = request.getParameterValues("task_fingerprint");	

	if(sTimerName == null) return;
	BriteTimerGeneric btm = TimerManager.getTimer(sTimerName);
	if(btm == null) return;
%>
<B><%="Date: "+new Date()%></B>
<H4>Task list for timer: <%=sTimerName%></H4>
<%	if(btm.getTimerName().indexOf("rcp.") > -1) { %>
<A href="task_history.jsp?timer=<%=URLEncoder.encode(sTimerName, "UTF-8")%>" target=_blank>Task history</A>
<%	} %>
<BR><BR>
<% if(!btm.isStarted()) { %>
<H3>Timer is not started.</H3>
<% return; }%>	
<INPUT type=button value="Skip selected" onclick="skip_tasks();">
<INPUT type=button value="Unskip selected" onclick="unskip_tasks();">
<INPUT type=button value="Get status" onclick="get_status();">
<BR><BR>
<FORM method="POST" name="tasks" action="">
<INPUT type=hidden name=timer value="<%=sTimerName%>">
<TABLE border="1" cellspacing="0" cellpadding="2">
	<TR>
		<TD align=center>
			<INPUT type=checkbox name=prototype onclick="change_selection();">
		</TD>
		<TH>Task Id</TH>
		<TH>Task Name</TH>
		<TH>Running?</TH>
		<TH>Skip?</TH>
		<TH>Cust_Id</TH>
		<TH>Id_Name</TH>
		<TH>Id</TH>
		<TH>String Comment</TH>
		<TH>Number Comment</TH>
		<TH>Date Comment</TH>
		<TH>Create Date</TH>
		<TH>Start Date</TH>
		<TH>Finish Date</TH>
		<TH>Exception</TH>
		<!-- TH>Task Details</TH -->
	</TR>

<%
	Vector vTaskList = btm.getTaskList();
			
	if(vTaskList!=null)
	{
		BriteTaskGeneric bt = null;
		String sTaskFingerprint = null;
		int i=0;
		
		for (Enumeration e = vTaskList.elements() ; e.hasMoreElements();)
		{
			bt = (BriteTaskGeneric)e.nextElement();
			sTaskFingerprint =
				String.valueOf(i) + "_" +
				String.valueOf(bt.hashCode()) + "_" +
				bt.getClass().getName();
			i++;
			
			if (sAction!=null)
			{
				int l = ( sTaskFingerprints == null ) ? 0 : sTaskFingerprints.length;
				
				for(int j=0; j<l ;j++)
				{
					if(sTaskFingerprint.equals(sTaskFingerprints[j]))
					{
						if(sAction.equals("skip")) bt.skip();
						if(sAction.equals("unskip")) bt.unskip();
						break;
					}
				}
			}
			else
			{
%>
	<TR <%=(bt.isRunning())?"style=\"color: #FF0088\"":""%>>
		<TD align=center>
			<INPUT type=checkbox name=task_fingerprint value="<%=sTaskFingerprint%>">
		</TD>
		<TD>&nbsp;<%=bt.getTaskId()%></TD>
		<TD>&nbsp;<%=bt.getTaskName()%></TD>
		<TD>&nbsp;<%=bt.isRunning()%></TD>
		<TD>&nbsp;<%=bt.isSkipped()%></TD>		
		
		<TD>&nbsp;<%=bt.getCustId()%></TD>
		<TD>&nbsp;<%=bt.getIdName()%></TD>
		<TD>&nbsp;<%=bt.getId()%></TD>

		<TD>&nbsp;<%=bt.getStringComment()%></TD>
		<TD>&nbsp;<%=bt.getNumberComment()%></TD>		
		<TD>&nbsp;<%=bt.getDateComment()%></TD>		
		
		<TD>&nbsp;<%=bt.getCreateDate()%></TD>		
		<TD>&nbsp;<%=bt.getStartDate()%></TD>
		<TD>&nbsp;<%=bt.getFinishDate()%></TD>
		<TD><%
			Exception ex = bt.getException();
			if(ex!=null)
			{
				StringWriter sw = new StringWriter(); 
				PrintWriter pw = new PrintWriter(sw);
				ex.printStackTrace(pw);
				pw.close();
				out.println("<PRE>" + sw.toString() + "</PRE>");
			}
			else out.println("&nbsp;");
		%></TD>
		<!-- TD>&nbsp;<A href="task_details.jsp?task_id=<%=bt.getTaskId()%>" target=_blank>Task details</A></TD -->
	</TR>
<%
			}
		}
		if (sAction!=null)
			response.sendRedirect("task_list.jsp?timer="+URLEncoder.encode(sTimerName,"UTF-8"));
	}
%>
</TABLE>
</FORM>
</BODY>
</HTML>