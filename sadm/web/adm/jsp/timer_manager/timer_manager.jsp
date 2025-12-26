<%@ page
	language="java"
	import="java.net.*" 
	import="java.util.*" 
	import="com.britemoon.*"
	import="com.britemoon.sas.delivery.*"
	contentType="text/html;charset=UTF-8"
%>
<HTML>
<HEAD>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
<SCRIPT>
	function start_timers()
	{
		timers.action = "timer_manager.jsp?action=start";
		timers.submit();
	}

	function stop_timers()
	{
		timers.action = "timer_manager.jsp?action=stop";
		timers.submit();
	}
	
	function get_status()
	{
		timers.action = "timer_manager.jsp";
		timers.submit();
	}
	
	function change_selection()
	{
		var v = timers.prototype.checked;
		var n = timers.timer_name.length;
		for(var i=0; i < n; i++) timers.timer_name[i].checked = v;
	}
</SCRIPT>
</HEAD>
<BODY>
<%
	BriteTimerGeneric btm = null;
	BriteTaskGeneric bt = null;

	String sAction = request.getParameter("action");
		
	if (sAction!=null)
	{
		String[] sTimerNames = request.getParameterValues("timer_name");

		int l = ( sTimerNames == null ) ? 0 : sTimerNames.length;
		
		for(int i=0; i<l ;i++)
		{
			btm = TimerManager.getTimer(sTimerNames[i]);

			if(btm!=null)
			{
				if(sAction.equals("start")) btm.start();
				if(sAction.equals("stop")) btm.stop();
			}
		}
		Thread.currentThread().sleep(1000);
		response.sendRedirect("timer_manager.jsp");
	}
%>
<B><%="Date: "+new Date()%></B>
<H4>Timer manager</H4>
<INPUT type=button value="Start selected" onclick="start_timers();">
<INPUT type=button value="Stop selected" onclick="stop_timers();">
<INPUT type=button value="Get status" onclick="get_status();">
<BR><BR>
<FORM method="POST" name="timers" action="">
<TABLE border="1" cellspacing="0" cellpadding="2">
	<TR>
		<TD align=center rowspan=2><INPUT type=checkbox name=prototype onclick="change_selection();"></TD>
		<TD align=center colspan=6>Timer</TD>
		<TD align=center colspan=7>Current Task</TD>
		<TH align=center rowspan=2>Task List</TH>
		<TH align=center rowspan=2>Task History</TH>
	</TR>
	<TR>
		<TH>Name</TH>
		<TH>Seq<BR>uen<BR>tial</TH>
		<TH>Started<BR>Stopped</TH>
		<TH>Working<BR>Sleeping</TH>
		<TH>Sleep<BR>Interval</TH>
		<TH>Stopping?</TH>
		<TH>Task Id</TH>
		<TH>Task Name</TH>
		<TH>Cust Id</TH>
		<TH>Id Name</TH>
		<TH>Id</TH>
		<TH>Start Date</TH>
		<TH>Comment</TH>
	</TR>
<%
		for (Enumeration e = TimerManager.getTimerNames().elements() ; e.hasMoreElements() ;)
		{
			btm = (BriteTimerGeneric) TimerManager.getTimer((String)e.nextElement());
			bt = btm.getCurrentTask();
			
			if(btm.isStarted())
			{
				if(btm.isStopping())
				{
%>
	<TR style="color: #8800FF">
<%
				}
				else
				{
%>
	<TR style="color: #009900">
<%
				}
			}
			else
			{
%>
	<TR>
<%
			}
%>
		<TD><INPUT type=checkbox name=timer_name value="<%=btm.getTimerName()%>"></TD>
		<TD>&nbsp;<%=btm.getTimerName()%></TD>
		<TD><INPUT type=checkbox<%=(btm.isSequential())?" checked":""%> disabled></TD>
		<TD>&nbsp;<%=(btm.isStarted())?"Started":"Stopped"%></TD>
		<TD>&nbsp;<%=(btm.isWorking())?"Working":"Sleeping"%></TD>
		<TD>&nbsp;<%=btm.getSleepInterval()%></TD>
		<TD>&nbsp;<%=btm.isStopping()%></TD>
<%
 			if(bt != null)
			{
%>
		<TD>&nbsp;<%=bt.getTaskId()%></TD>
		<TD>&nbsp;<%=bt.getTaskName()%></TD>
		<TD>&nbsp;<%=bt.getCustId()%></TD>
		<TD>&nbsp;<%=bt.getIdName()%></TD>
		<TD>&nbsp;<%=bt.getId()%></TD>
		<TD>&nbsp;<%=bt.getStartDate()%></TD>
		<TD>&nbsp;<%=bt.getStringComment()%></TD>
<%
 			}
			else
			{
%>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
<%
	  		}
%>
		<TD>&nbsp;<A href="task_list.jsp?timer=<%=URLEncoder.encode(btm.getTimerName(), "UTF-8")%>" target=_blank>Task list</A></TD>
<%
			if(btm.getTimerName().indexOf("rcp.") > -1)
			{
%>
		<TD>&nbsp;<A href="task_history.jsp?timer=<%=URLEncoder.encode(btm.getTimerName(), "UTF-8")%>" target=_blank>Task history</A></TD>
<%
			}
			else
			{
%>
		<TD>&nbsp;</TD>
<%
			}
%>
	</TR>
<%
		}
%>
</TABLE>
</FORM>

</BODY>
</HTML>