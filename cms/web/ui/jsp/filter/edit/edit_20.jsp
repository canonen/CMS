<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

//KU: Added for content logic ui
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
}
else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Report Filter";
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}
	
%>

<HTML>

<HEAD>
	<TITLE><%= sTargetGroupDisplay %>: Form Submission Calculations</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		function do_submit()
		{
			filter_name = filter_form.filter_name.value;
			if((filter_name==null)||(filter_name.length==0))
			{
				alert('Invalid name.')
				filter_form.filter_name.focus();
				return false;
			}
			
			main_count = filter_form.main_count.value;
			if ((main_count == "0") || (main_count == null) || (main_count.length == 0))
			{
				alert("Zero is not a valid number for the Form Submission Count. Only recipients who submitted forms can be used in calculations.")
				filter_form.main_count.focus();
				return false;
			}
			
			filter_form.action = "save_calc.jsp?usage_type_id=<%= sUsageTypeId %>";
			filter_form.submit();
			return true;
		}
		
		function setCalcInfo()
		{
			var countSubs;
			var countSpan;
			
			countSpan = document.all.item("sub_count");
			countSubs = filter_form.main_count.value;
			
			countSpan.innerText = countSubs;
		}
		
		function resizeWin()
		{
			top.window.resizeTo(700,600);
		}

		function resetWin()
		{
			top.window.resizeTo(700,300);
		}
	</SCRIPT>
</HEAD>

<BODY onload="resizeWin();" onunload="resetWin();">
<FORM name=filter_form method="POST">
<%
	String sFilterId = request.getParameter("filter_id");	
	String sFilterName = null;
	
	String sMode = null;	
	String sMainCountCompareOperation = null;
	String sMainCount = null;
	
	String sStartDate = null;
	String sFinishDate = null;
	
	String sDiffDate = null;
		
	String sDayCountCompareOperation = null;	
	String sDayCount = null;
	
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();

		sMainCountCompareOperation = fps.getStringValue("main_count_compare_operation");
		sMainCount = fps.getIntegerValue("main_count");

		sMode = fps.getStringValue("mode");

		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");
		sDiffDate = fps.getStringValue("diff_date");

		sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
		sDayCount = fps.getIntegerValue("day_count");
%>
<INPUT type=hidden name=filter_id value=<%=sFilterId%>>
<%
	}
	if(sMainCountCompareOperation == null) sMainCountCompareOperation = ">";
	if(sMainCount==null) sMainCount = "1";

	if(sMode == null) sMode = "date_diff";
		
	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";
	
	if(sDiffDate==null) sDiffDate = "TODAY";	

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sDayCount==null) sDayCount = "30";
%>
<INPUT type=hidden name=type_id value="<%=FilterType.FORM_SUBMIT_COUNT_WITHIN_TIME_INTERVAL%>">

<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=center width=100%>
			<table class=listTable cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<th align="center" valign="middle">
						<b>Form Submission Calculations</b><br>
						
					</th>
				</tr>					<tr>					<td align="center" valign="middle" >					
				Select recipients who submitted a specified number of form submissions during a specified time period.<br>
				The variable <font color="red">TODAY</font> can be used to create calculations based on the current date.<br>	
				Use the <font color="red">NOT</font> option on the main edit screen to select recipients who did not
				submit forms during the time periods specified below.					
				</td>				
				</tr>
			</table>
			<br>
			<table class=listTable  cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle">Start by selecting the number of form submissions</th>
				</tr>
				<tr>
					<td align="center" valign="middle">
						The recipient submitted a form or forms &nbsp;
						<select name="main_count_compare_operation">
							<option value="=" <%=("=".equals(sMainCountCompareOperation)?" selected":"")%>>Exactly (=)</option>
							<option value="&gt;" <%=(">".equals(sMainCountCompareOperation)?" selected":"")%>>More Than (&gt;)</option>
							<option value="&gt;=" <%=(">=".equals(sMainCountCompareOperation)?" selected":"")%>>More Than Or Exactly (&gt;=)</option>
							<option value="&lt;" <%=("<".equals(sMainCountCompareOperation)?" selected":"")%>>Fewer Than (&lt;)</option>
							<option value="&lt;" <%=("<=".equals(sMainCountCompareOperation)?" selected":"")%>>Fewer Than Or Exactly (&lt;=)</option>
						</select>
						&nbsp;<input type="text" name="main_count" value="<%= HtmlUtil.escape(sMainCount) %>" size="3" onkeyup="setCalcInfo();">&nbsp;times
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle" width="100%" colspan="2">Next, calculate the dates in which the recipient completed those <span id="sub_count"><%= HtmlUtil.escape(sMainCount) %></span> form submissions</th>
				</tr>
				<tr>
					<td align="center" valign="top" width="50%">
						<table cellspacing="0" cellpadding="2" border="0">
							<tr>
								<td align="center" valign="middle">
									<input type="radio" name="mode" value="date_diff"<%=(("date_diff".equals(sMode))?" checked":"")%>>
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									All recipients who submitted a form where the <b>difference</b> between the 
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									Form Submission Date and &nbsp;<input type="text" name="diff_date" value="<%= HtmlUtil.escape(sDiffDate) %>" onfocus="this.select();">&nbsp;is
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									<select name="day_count_compare_operation">
										<option value="=" <%=("=".equals(sDayCountCompareOperation)?" selected":"")%>>Equal To (=)</option>
										<option value="&gt;" <%=(">".equals(sDayCountCompareOperation)?" selected":"")%>>Greater Than (&gt;)</option>
										<option value="&gt;=" <%=(">=".equals(sDayCountCompareOperation)?" selected":"")%>>Greater Than Or Equal To (&gt;=)</option>
										<option value="&lt;" <%=("<".equals(sDayCountCompareOperation)?" selected":"")%>>Less Than (&lt;)</option>
										<option value="&lt;=" <%=("<=".equals(sDayCountCompareOperation)?" selected":"")%>>Less Than Or Equal To (&lt;=)</option>
									</select>
									&nbsp;
									<input type="text" name="day_count" value="<%=HtmlUtil.escape(sDayCount)%>" size="3">
									&nbsp;days
								</td>
							</tr>
						</table>
					</td>
					<td align="center" valign="top" width="50%">
						<table cellspacing="0" cellpadding="2" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" colspan="2">
									<input type="radio" name="mode" value="start_finish"<%=(("start_finish".equals(sMode))?" checked":"")%>>
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle" colspan="2">
									The form was submitted on dates 
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									between:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<input type="text" name="start_date" value="<%= HtmlUtil.escape(sStartDate) %>" onfocus="this.select();">
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									and:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<input type="text" name="finish_date" value="<%=HtmlUtil.escape(sFinishDate)%>" onfocus="this.select();">
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle">
						Finally, enter a name for this calculation: 
					</th>
				</tr>
				<tr>
					<td align="center" valign="middle"><input type="text" name="filter_name" size="80" value="<%= HtmlUtil.escape(sFilterName) %>">
				</tr>

				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<input type="button" class="subactionbutton" onclick="history.back();" value="<< Back">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" onclick="window.close();" value="Cancel">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" name="save" onclick="do_submit();" value="Save >>">&nbsp;&nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
</FORM>
</BODY>
</HTML>
