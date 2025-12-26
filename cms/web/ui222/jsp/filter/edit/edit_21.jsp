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
<%! static Logger logger = null;%>
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
	<TITLE><%= sTargetGroupDisplay %>: Date Field Calculations</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		function do_submit()
		{
			if(!is_valid(filter_form.filter_name, 'Invalid name.')) return false;

			if(filter_form.mode[0].checked)
			{
				if(!is_valid(filter_form.diff_date_attr_id, 'Invalid field.')) return false;
			}
			else if(filter_form.mode[1].checked)
			{
				if(!is_valid(filter_form.start_finish_attr_id, 'Invalid field.')) return false;
			}
			else
			{
				alert('Check one of radio buttons to specify function you want to use.')				
				 return false;
			}

			filter_form.action = "save_calc.jsp?usage_type_id=<%= sUsageTypeId %>";
			filter_form.submit();
			return true;
		}
		function is_valid(obj, err_msg)
		{
			if(obj == null) return false;
			if((obj.value == null)||(obj.value.length==0))
			{
				alert(err_msg)
				obj.focus();
				return false;
			}
			return true;
		}
		
		function setCalcInfo()
		{
			var countOpens;
			var countSpan;
			
			countSpan = document.all.item("open_count");
			countOpens = filter_form.main_count.value;
			
			countSpan.innerText = countOpens;
		}
		
		function resizeWin()
		{
			top.window.resizeTo(700,575);
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
	
	String sStartDate = null;
	String sFinishDate = null;
	String sStartFinishAttrId = null;
	
	String sDiffDate = null;
	String sDiffDateAttrId = null;
	
	String sDayCountCompareOperation = null;	
	String sDayCount = null;
	
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();

		sMode = fps.getStringValue("mode");

		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");

		sStartFinishAttrId = fps.getStringValue("start_finish_attr_id");

		sDiffDate = fps.getStringValue("diff_date");

		sDiffDateAttrId = fps.getStringValue("diff_date_attr_id");

		sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
		sDayCount = fps.getIntegerValue("day_count");
%>
<INPUT type=hidden name=filter_id value=<%=sFilterId%>>
<%
	}
	if(sMode == null) sMode = "date_diff";
		
	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";
	
	if(sDiffDate==null) sDiffDate = "TODAY";	

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sDayCount==null) sDayCount = "30";
%>
<INPUT type=hidden name=type_id value="<%=FilterType.DATE_ATTR_COMPARISON%>">

<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:5px;">
						<b>Date Field Calculations</b><br>
						Select recipients who have a value in a custom date field which matches a specified time period.<br>
						The variable <font color="red">TODAY</font> can be used to create calculations based on the current date.<br>
						Use the <font color="red">NOT</font> option on the main edit screen to select recipients who do not have a matching value for the time periods specified below.
					</td>
				</tr>
			</table>
			<br>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" width="100%" colspan="2">Start by selecting the date criteria</td>
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
									All recipients where the <b>difference</b> between the value in the following custom field: 
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									<select name="diff_date_attr_id">
										<option></option>
										<%
										CustAttrs attrs = CustAttrsUtil.retrieve4filter(cust.s_cust_id, sFilterId, DataType.DATETIME);
										out.println(CustAttrsUtil.toHtmlOptions(attrs, sDiffDateAttrId));
										%>
									</select>
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									and &nbsp;<input type="text" name="diff_date" value="<%= HtmlUtil.escape(sDiffDate) %>" onfocus="this.select();">&nbsp;is
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
								<td align="right" valign="middle" width="50%">
									The value in the following custom field:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<select name="start_finish_attr_id">
										<option></option>
										<%
										attrs = CustAttrsUtil.retrieve4filter(cust.s_cust_id, sFilterId, DataType.DATETIME);
										out.println(CustAttrsUtil.toHtmlOptions(attrs, sStartFinishAttrId));
										%>
									</select>
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									is between:&nbsp;&nbsp;
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
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle">
						Finally, enter a name for this calculation: 
					</td>
				</tr>
				<tr>
					<td align="center" valign="middle"><input type="text" name="filter_name" size="80" value="<%= HtmlUtil.escape(sFilterName) %>">
				</tr>
			</table>
			<br>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
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