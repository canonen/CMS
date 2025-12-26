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
	<TITLE><%= sTargetGroupDisplay %>: Campaign Calculations</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		function do_submit()
		{
			filter_name = filter_form.filter_name.value;
			if((filter_name==null)||(filter_name.length==0))
			{
				alert("Please enter a display name.")
				filter_form.filter_name.focus();
				return false;
			}
			
			camp_id = filter_form.camp_id.value;
			if ((camp_id == "0") || (camp_id == null) || (camp_id.length == 0))
			{
				alert("Please select campaign. Only recipients who received a campaign can be used in calculations.")
				filter_form.camp_id.focus();
				return false;
			}				
			
			filter_form.action = "save_calc.jsp?usage_type_id=<%= sUsageTypeId %>";
			filter_form.submit();
			return true;
		}

		function resizeWin() { top.window.resizeTo(700,575); }
		function resetWin() { top.window.resizeTo(700,300); }
	</SCRIPT>
</HEAD>

<BODY onload="resizeWin();" onunload="resetWin();">
<FORM name=filter_form method="POST">
<%
	String sFilterId = request.getParameter("filter_id");	
	String sFilterName = null;
	
	String sCampId = null;

	String sMode = null;
		
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

		sCampId = fps.getIntegerValue("camp_id");

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
	if(sMode == null) sMode = "date_diff";
		
	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";
	
	if(sDiffDate==null) sDiffDate = "TODAY";	

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sDayCount==null) sDayCount = "30";
%>
<INPUT type=hidden name=type_id value="<%=FilterType.CAMP_SENT_WITHIN_TIME_INTERVAL%>">

<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td  valign=top align=center width=100%>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle" >
						<b>Campaign Calculations</b>
					</th>
				</tr>
				<tr>
						<td align="center" valign="middle">
							Select recipients who received a specified campaign during a specified time period.<br>
							The variable <font color="red">TODAY</font> can be used to create calculations based on the current date.<br>
							Use the <font color="red">NOT</font> option on the main edit screen to select recipients who did not receive campaigns during the time periods specified below.
						</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle">Start by selecting the number of campaigns a recipient received</th>
				</tr>
				<tr>
					<td align="center" valign="middle">
						The recipient received&nbsp;
						<select size="1" name="camp_id">
							<option>-----  Select A Campaign -----</option>
							<%=buildCampOptionsHtml(cust.s_cust_id, sCampId)%>
						</select>
						&nbsp;campaign
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle" width="100%" colspan="2">
						Next, calculate the dates in which the recipient received the above campaign
					</th>
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
									All recipients who received a campaign where the <b>difference</b> between the 
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									Campaign Send Date and &nbsp;<input type="text" name="diff_date" value="<%= HtmlUtil.escape(sDiffDate) %>" onfocus="this.select();">&nbsp;is
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
									All recipients who received a campaign where campaign send date is 
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

<%!
private static String buildCampOptionsHtml(String sCustId, String sSelectedCampId) throws Exception
{
	ConnectionPool cp = null;
	Connection conn = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("select.jsp.buildOptionsHtml()");
		Statement stmt = null;
		try
		{
			stmt = conn.createStatement();
			return buildOptionsHtml(sCustId,sSelectedCampId,stmt);
		}
		catch(Exception ex) { throw ex; }
		finally { if(stmt != null) stmt.close(); }
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn != null) cp.free(conn); }
}

private static String buildOptionsHtml(String sCustId, String sSelectedCampId, Statement stmt) throws Exception
{
	StringWriter sw = new StringWriter();
	
	String sId = null;
	byte[] b = null;	
	String sName = null;

	String sSql = 
		" SELECT camp_id, camp_name" +
		" FROM cque_campaign WITH(NOLOCK)" +
		" WHERE origin_camp_id IS NULL" +
		" AND cust_id = " + sCustId +
		" AND status_id <> " + CampaignStatus.DELETED +
		" ORDER BY camp_name";

	ResultSet rs = stmt.executeQuery(sSql);
	while (rs.next())
	{
		sId = rs.getString(1);
		b = rs.getBytes(2);
		sName = (b==null)?null:new String(b, "UTF-8");
		sw.write("<option value=\"" + sId + "\"" + (sId.equals(sSelectedCampId)?" selected":"")+ ">");
		sw.write(HtmlUtil.escape(sName));
		sw.write("</option>\r\n");
	}
	rs.close();

	return sw.toString();
}
%>