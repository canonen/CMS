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
	<TITLE><%= sTargetGroupDisplay %>: Aggregate Calculations</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		function do_submit()
		{
			if(!is_valid(filter_form.filter_name, 'Invalid name.')) return false;
/*
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
*/
			filter_form.action = "save_22.jsp?usage_type_id=<%= sUsageTypeId %>";
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

	String sAggregateFunction = null;
	String sAggregateAttrId = null;

	String sCompareOperation = null;
	String sCompareValue = null;

	String sStartDate = null;
	String sFinishDate = null;
	
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();

		sAggregateFunction = fps.getStringValue("aggregate_function");
		sAggregateAttrId = fps.getStringValue("aggregate_attr_id");

		sCompareOperation = fps.getStringValue("compare_operation");
		sCompareValue = fps.getIntegerValue("compare_value");

		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");
%>
<INPUT type=hidden name=filter_id value=<%=sFilterId%>>
<%
	}
	if(sAggregateFunction==null) sAggregateFunction = "SUM";

	if(sCompareOperation == null) sCompareOperation = ">";
	if(sCompareValue==null) sCompareValue = "0";

	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";
%>
<INPUT type=hidden name=type_id value="<%=FilterType.ATTR_HISTORY_AGGREGATION_WITHIN_TIME_INTERVAL%>">

<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>

	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=center width=100%>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle">
						<b>Integer Field Aggregate Calculations</b><br>
						
					</th>
				</tr>
				<tr>
					<td align="center" valign="middle" >
						
						Select recipients who have a values in custom integer fields which match a specified aggregate criteria.<br>
						The variable <font color="red">TODAY</font> can be used to create calculations based on the current date.<br>
						Use the <font color="red">NOT</font> option on the main edit screen to select recipients who do not have matching values for the aggregate criteria specified below.
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle" width="100%" colspan="2">Start by selecting the aggregate criteria</th>
				</tr>
				<tr>
					<td align="center" valign="top" width="100%">
						<table cellspacing="0" cellpadding="2" border="0" width="100%">
							<tr>
								<td align="right" valign="middle" width="50%">
									Select all recipients where the following aggregate expression:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<select name="aggregate_function">
										<option value="SUM"	<%=("SUM".equals(sAggregateFunction)?" selected":"")%>>SUM</option>
										<option value="COUNT"	<%=("COUNT".equals(sAggregateFunction)?" selected":"")%>>COUNT</option>
										<option value="MIN"	<%=("MIN".equals(sAggregateFunction)?" selected":"")%>>MIN</option>
										<option value="MAX"	<%=("MAX".equals(sAggregateFunction)?" selected":"")%>>MAX</option>
									</select>
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									is calculated using values from the following custom integer field's historic data:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<select name="aggregate_attr_id">
										<option></option>
										<%
										CustAttrs attrs = CustAttrsUtil.retrieve4filter(cust.s_cust_id, sFilterId, DataType.INTEGER);
										out.println(CustAttrsUtil.toHtmlOptions(attrs, sAggregateAttrId));
										%>
									</select>
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									and where that calulated result is:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<select name="compare_operation">
										<option value="=" <%=("=".equals(sCompareOperation)?" selected":"")%>>Equal To (=)</OPTION>
										<option value="&gt;" <%=(">".equals(sCompareOperation)?" selected":"")%>>Greater Than (&gt;)</OPTION>
										<option value="&gt;=" <%=(">=".equals(sCompareOperation)?" selected":"")%>>Greater Than or Equal To (&gt;=)</OPTION>
										<option value="&lt;" <%=("<".equals(sCompareOperation)?" selected":"")%>>Less Than (&lt;)</OPTION>
										<option value="&lt;" <%=("<=".equals(sCompareOperation)?" selected":"")%>>Less Than or Equal To (&lt;=)</OPTION>
									</select>
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									the following value:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<INPUT type=text name="compare_value" value="<%=HtmlUtil.escape(sCompareValue)%>">
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle" width="100%" colspan="2">Next, determine the date range to apply to the aggregate criteria</th>
				</tr>
				<tr>
					<td align="center" valign="top" width="100%">
						<table cellspacing="0" cellpadding="2" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" colspan="2">
									All recipients who meet the above aggregate criteria, where the data in the field history was created  
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									between:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<INPUT type=text name=start_date value="<%=HtmlUtil.escape(sStartDate)%>" onfocus="this.select();">
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									and:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<INPUT type=text name=finish_date value="<%=HtmlUtil.escape(sFinishDate)%>" onfocus="this.select();">
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
