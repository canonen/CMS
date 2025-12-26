<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.util.Date,java.io.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</HEAD>
<%

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;
boolean hasSalesAndOrder=false;

try	{
    // check Sales and Order column 
     
	ReportUtil    reportUtil=new ReportUtil();
	hasSalesAndOrder= reportUtil.isMbsRevenueReportcustomer(cust.s_cust_id);
	
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_settings_edit.jsp");
	stmt = conn.createStatement();

	int	nTotalsSecFlag = 1;
	int	nGeneralSecFlag = 1;
	int	nBBackSecFlag = 1;
	int	nActionSecFlag = 1;
	int	nDistClickSecFlag = 1;
	int	nTotClickSecFlag = 0;
	int	nFormSecFlag = 1;
	int	nTotReadFlag = 0;
	int	nMultiReadFlag = 1;
	int	nTotClickFlag = 1;
	int	nMultiLinkClickFlag = 1;
	int	nLinkMultiClickFlag = 1;
	int	nDomainFlag = 1;
	int	nOptoutFlag = 0;
	
	rs = stmt.executeQuery("EXEC usp_crpt_report_settings_get @cust_id = "+cust.s_cust_id);
	if (rs.next()) {
		nTotalsSecFlag = rs.getInt(1);
		nGeneralSecFlag = rs.getInt(2);
		nBBackSecFlag = rs.getInt(3);
		nActionSecFlag = rs.getInt(4);
		nDistClickSecFlag = rs.getInt(5);
		nTotClickSecFlag = rs.getInt(6);
		nFormSecFlag = rs.getInt(7);
		nTotReadFlag = rs.getInt(8);
		nMultiReadFlag = rs.getInt(9);
		nTotClickFlag = rs.getInt(10);
		nMultiLinkClickFlag = rs.getInt(11);
		nLinkMultiClickFlag = rs.getInt(12);
		nDomainFlag = rs.getInt(13);
		nOptoutFlag = rs.getInt(14);
	}
	rs.close();
	//Report Dashboard columns
	 
	 int nCampIdColFlag=1;
	 int nCampTypeColFlag=1;
	 int nStartDateColFlag=1;
	 int nSubjectLineColFlag=1;
	 int nContentNameColFlag=1;
	 int nTargetGroupNameColFlag=1;
	 int nCampCodeColFlag=1;
	 int nSentColFlag=1;
	 int nBBackColFlag=1;
	 int nOpenColFlag=1;
	 int nClicksThroughColFlag=1;
	 int nUnsubscribesColFlag=1;
	 int nOrdersColFlag=1;
	 int nSalesColFlag=1;
	
	
	rs = stmt.executeQuery("EXEC usp_crpt_report_settings_column_get @cust_id = "+cust.s_cust_id);
	if (rs.next()) 
	{
		nCampIdColFlag = rs.getInt(1);
		nCampTypeColFlag = rs.getInt(2);
		nStartDateColFlag= rs.getInt(3);
		nSubjectLineColFlag = rs.getInt(4);
		nContentNameColFlag = rs.getInt(5);
		nTargetGroupNameColFlag= rs.getInt(6);
		nCampCodeColFlag = rs.getInt(7);
		nSentColFlag = rs.getInt(8);
		nBBackColFlag = rs.getInt(9);
		nOpenColFlag = rs.getInt(10);
		nClicksThroughColFlag = rs.getInt(11);
		nUnsubscribesColFlag=rs.getInt(12);
		nOrdersColFlag = rs.getInt(13);
		nSalesColFlag = rs.getInt(14);
	}
	rs.close();
	
	//Define Thresholds for metrics
	 
	float nBBackThreshold=0;
	float nOpenThreshold=0;
 	float nClickThroughThreshold=0;
 	 
 	rs = stmt.executeQuery("EXEC usp_crpt_report_threshold_levels_get @cust_id = " + cust.s_cust_id);
	if (rs.next()) 
	{
		nBBackThreshold = rs.getFloat(1);
		nOpenThreshold = rs.getFloat(2);
		nClickThroughThreshold = rs.getFloat(3);
	}
	rs.close();
%>

<BODY ONLOAD="setChecks();">
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
				<a class="savebutton" href="#" onClick="trySubmit();">Save</a>
		</td>

		<td align="left" valign="middle">
			View: <A class="subactionbutton" href="cust_domains_edit.jsp"><B>Report Domains</B></A>
		</td>
	</tr>
</table>
<br>

<FORM  METHOD="POST" NAME="FT" ACTION="report_settings_save_cy.jsp" TARGET="_self">

<INPUT TYPE="hidden" NAME="totals_sec_flag" value="<%=nTotalsSecFlag%>">
<INPUT TYPE="hidden" NAME="general_sec_flag" value="<%=nGeneralSecFlag%>">
<INPUT TYPE="hidden" NAME="bback_sec_flag" value="<%=nBBackSecFlag%>">
<INPUT TYPE="hidden" NAME="action_sec_flag" value="<%=nActionSecFlag%>">
<INPUT TYPE="hidden" NAME="dist_click_sec_flag" value="<%=nDistClickSecFlag%>">
<INPUT TYPE="hidden" NAME="tot_click_sec_flag" value="<%=nTotClickSecFlag%>">
<INPUT TYPE="hidden" NAME="form_sec_flag" value="<%=nFormSecFlag%>">
<INPUT TYPE="hidden" NAME="tot_read_flag" value="<%=nTotReadFlag%>">
<INPUT TYPE="hidden" NAME="multi_read_flag" value="<%=nMultiReadFlag%>">
<INPUT TYPE="hidden" NAME="tot_click_flag" value="<%=nTotClickFlag%>">
<INPUT TYPE="hidden" NAME="multi_link_click_flag" value="<%=nMultiLinkClickFlag%>">
<INPUT TYPE="hidden" NAME="link_multi_click_flag" value="<%=nLinkMultiClickFlag%>">
<INPUT TYPE="hidden" NAME="domain_flag" value="<%=nDomainFlag%>">
<INPUT TYPE="hidden" NAME="optout_flag" value="<%=nOptoutFlag%>">

<!--Report Dashboard columns-->

<INPUT TYPE="hidden" NAME="camp_id_col_flag" value="<%=nCampIdColFlag%>">
<INPUT TYPE="hidden" NAME="camp_type_col_flag" value="<%=nCampTypeColFlag%>">
<INPUT TYPE="hidden" NAME="start_date_col_flag" value="<%=nStartDateColFlag%>">
<INPUT TYPE="hidden" NAME="subject_line_col_flag" value="<%=nSubjectLineColFlag%>">
<INPUT TYPE="hidden" NAME="content_name_col_flag" value="<%=nContentNameColFlag%>">
<INPUT TYPE="hidden" NAME="target_group_name_col_flag" value="<%=nTargetGroupNameColFlag%>">
<INPUT TYPE="hidden" NAME="camp_code_col_flag" value="<%=nCampCodeColFlag%>">
<INPUT TYPE="hidden" NAME="sent_col_flag" value="<%=nSentColFlag%>">
<INPUT TYPE="hidden" NAME="bback_col_flag" value="<%=nBBackColFlag%>">
<INPUT TYPE="hidden" NAME="open_col_flag" value="<%=nOpenColFlag%>">
<INPUT TYPE="hidden" NAME="clicks_through_col_flag" value="<%=nClicksThroughColFlag%>">
<INPUT TYPE="hidden" NAME="unsubscribes_col_flag" value="<%=nUnsubscribesColFlag%>">
<INPUT TYPE="hidden" NAME="orders_col_flag" value="<%=nOrdersColFlag%>">
<INPUT TYPE="hidden" NAME="sales_col_flag" value="<%=nSalesColFlag%>">

<!--Define Thresholds for metrics-->
<INPUT TYPE="hidden" NAME="bback_threshold_percent" value="<%=nBBackThreshold%>">
<INPUT TYPE="hidden" NAME="open_threshold_percent" value="<%=nOpenThreshold%>">
<INPUT TYPE="hidden" NAME="click_threshold_percent" value="<%=nClickThroughThreshold%>">

<table class=listTable cellspacing=0 cellpadding=2 width="325">
	<tr>
		<th colspan="2">Report Sections</th>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="tsf" type="checkbox"></td>
		<td class="listItem_Data">Header</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="gsf" type="checkbox"></td>
		<td class="listItem_Data_Alt">General Campaign Statistics</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="bsf" type="checkbox"></td>
		<td class="listItem_Data">Bounceback Categories</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="asf" type="checkbox"></td>
		<td class="listItem_Data_Alt">Recipient Actions</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="dcsf" type="checkbox"></td>
		<td class="listItem_Data">Detailed Clickthroughs (Distinct)</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="tcsf" type="checkbox"></td>
		<td class="listItem_Data_Alt">Detailed Clickthroughs (Aggregate)</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="fsf" type="checkbox"></td>
		<td class="listItem_Data">Form Submissions</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="dsf" type="checkbox"></td>
		<td class="listItem_Data_Alt">Domain Deliverability</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="osf" type="checkbox"></td>
		<td class="listItem_Data">Newsletter Opt-outs</td>
	</tr>
</table>
<br>
<table class=listTable cellspacing=0 cellpadding=2 width="325">
	<tr>
		<th colspan="2">Additional Metrics</th>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="trf" type="checkbox"></td>
		<td class="listItem_Data">Total HTML Email views</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="mrf" type="checkbox"></td>
		<td class="listItem_Data_Alt">Opened HTML Email more than once</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="tcf" type="checkbox"></td>
		<td class="listItem_Data">Aggregate Clickthroughs</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="mlcf" type="checkbox"></td>
		<td class="listItem_Data_Alt">Clicked on more than one link</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="lmcf" type="checkbox"></td>
		<td class="listItem_Data">Clicked on one link multiple times</td>
	</tr>
</table>

<br>
<table class=listTable cellspacing=0 cellpadding=2 width="325">
	<tr>
		<th colspan="2">Report Dashboard Columns</th>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="cid" type="checkbox"></td>
		<td class="listItem_Data">Campaign ID</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="ctype" type="checkbox"></td>
		<td class="listItem_Data_Alt">Campaign Type</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="stDate" type="checkbox"></td>
		<td class="listItem_Data">Start Date</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="subLine" type="checkbox"></td>
		<td class="listItem_Data_Alt">Subject Line</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="conName" type="checkbox"></td>
		<td class="listItem_Data">Content Name</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="trGrpName" type="checkbox"></td>
		<td class="listItem_Data_Alt">Target Group Name</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="cCode" type="checkbox"></td>
		<td class="listItem_Data">Campaign Code</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="sen" type="checkbox"></td>
		<td class="listItem_Data_Alt">Sent</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="bBacks" type="checkbox"></td>
		<td class="listItem_Data">Bounce Backs</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="ope" type="checkbox"></td>
		<td class="listItem_Data_Alt">Open</td>
	</tr>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="cThrough" type="checkbox"></td>
		<td class="listItem_Data">Click Through</td>
	</tr>
	<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="uScribes" type="checkbox"></td>
		<td class="listItem_Data_Alt">Unsubscribes</td>
	</tr>
	
	<% if(hasSalesAndOrder){%>
	<tr>
		<td class="listItem_Data" width="20" align="center"><input name="ord" type="checkbox"></td>
		<td class="listItem_Data">Orders</td>
	</tr>
		<tr>
		<td class="listItem_Data_Alt" width="20" align="center"><input name="sal" type="checkbox"></td>
		<td class="listItem_Data_Alt">Sales</td>
	</tr>
	<%}%>
</table>

<br>
<table class=listTable cellspacing=0 cellpadding=2 width="325">
	<tr>
		<th colspan="2">Define Threshold Metrics</th>
	<tr>
		<td class="listItem_Data">Bounce Back Threshold</td>
		<td class="listItem_Data" width="5" align="center"><input name="bbackth" type="textbox">&nbsp;%&nbsp;</td>
	</tr>
	<tr>
		<td class="listItem_Data">Open Threshold</td>
		<td class="listItem_Data" width="5" align="center"><input name="openth" type="textbox">&nbsp;%&nbsp;</td>
	</tr>
	<tr>
		<td class="listItem_Data">Click Throughs Threshold</td>
		<td class="listItem_Data" width="5" align="center"><input name="clickth" type="textbox">&nbsp;%&nbsp;</td>
	</tr>
</table>

<br><br>
<SCRIPT LANGUAGE="JavaScript">

function setChecks() 
{     
	if (FT.totals_sec_flag.value == 1) FT.tsf.checked = true;
	if (FT.general_sec_flag.value == 1) FT.gsf.checked = true;
	if (FT.bback_sec_flag.value == 1) FT.bsf.checked = true;
	if (FT.action_sec_flag.value == 1) FT.asf.checked = true;
	if (FT.dist_click_sec_flag.value == 1) FT.dcsf.checked = true;
	if (FT.tot_click_sec_flag.value == 1) FT.tcsf.checked = true;
	if (FT.form_sec_flag.value == 1) FT.fsf.checked = true;
	if (FT.tot_read_flag.value == 1) FT.trf.checked = true;
	if (FT.multi_read_flag.value == 1) FT.mrf.checked = true;
	if (FT.tot_click_flag.value == 1) FT.tcf.checked = true;
	if (FT.multi_link_click_flag.value == 1) FT.mlcf.checked = true;
	if (FT.link_multi_click_flag.value == 1) FT.lmcf.checked = true;
	if (FT.domain_flag.value == 1) FT.dsf.checked = true;
	if (FT.optout_flag.value == 1) FT.osf.checked = true;
	
	
	if (FT.camp_id_col_flag.value == 1) FT.cid.checked = true;
	if (FT.camp_type_col_flag.value == 1) FT.ctype.checked = true;
	if (FT.start_date_col_flag.value == 1) FT.stDate.checked = true;
	if (FT.subject_line_col_flag.value == 1) FT.subLine.checked = true;
	if (FT.content_name_col_flag.value == 1) FT.conName.checked = true;
	if (FT.target_group_name_col_flag.value == 1) FT.trGrpName.checked = true;
	if (FT.camp_code_col_flag.value == 1) FT.cCode.checked = true;
	if (FT.sent_col_flag.value == 1) FT.sen.checked = true;
	if (FT.bback_col_flag.value == 1) FT.bBacks.checked = true;
	if (FT.open_col_flag.value == 1) FT.ope.checked = true;
	if (FT.clicks_through_col_flag.value == 1) FT.cThrough.checked = true;
	if (FT.unsubscribes_col_flag.value == 1) FT.uScribes.checked = true;
<%
	if (hasSalesAndOrder) {
%>
	if (FT.orders_col_flag.value == 1) FT.ord.checked = true;
	if (FT.sales_col_flag.value == 1) FT.sal.checked = true;
<%
	}
%>
	FT.bbackth.value = FT.bback_threshold_percent.value;
	FT.openth.value = FT.open_threshold_percent.value;
	FT.clickth.value = FT.click_threshold_percent.value;
}

function trySubmit()
{   
	if (FT.tsf.checked == true) FT.totals_sec_flag.value = 1;
	else FT.totals_sec_flag.value = 0;
	if (FT.gsf.checked == true) FT.general_sec_flag.value = 1;
	else FT.general_sec_flag.value = 0;
	if (FT.bsf.checked == true) FT.bback_sec_flag.value = 1;
	else FT.bback_sec_flag.value = 0;
	if (FT.asf.checked == true) FT.action_sec_flag.value = 1;
	else FT.action_sec_flag.value = 0;
	if (FT.dcsf.checked == true) FT.dist_click_sec_flag.value = 1;
	else FT.dist_click_sec_flag.value = 0;
	if (FT.tcsf.checked == true) FT.tot_click_sec_flag.value = 1;
	else FT.tot_click_sec_flag.value = 0;
	if (FT.fsf.checked == true) FT.form_sec_flag.value = 1;
	else FT.form_sec_flag.value = 0;
	if (FT.trf.checked == true) FT.tot_read_flag.value = 1;
	else FT.tot_read_flag.value = 0;
	if (FT.mrf.checked == true) FT.multi_read_flag.value = 1;
	else FT.multi_read_flag.value = 0;
	if (FT.tcf.checked == true) FT.tot_click_flag.value = 1;
	else FT.tot_click_flag.value = 0;
	if (FT.mlcf.checked == true) FT.multi_link_click_flag.value = 1;
	else FT.multi_link_click_flag.value = 0;
	if (FT.lmcf.checked == true) FT.link_multi_click_flag.value = 1;
	else FT.link_multi_click_flag.value = 0;
	if (FT.dsf.checked == true) FT.domain_flag.value = 1;
	else FT.domain_flag.value = 0;
	if (FT.osf.checked == true) FT.optout_flag.value = 1;
	else FT.optout_flag.value = 0;
     
     
    if (FT.cid.checked == true) FT.camp_id_col_flag.value = 1;
	else FT.camp_id_col_flag.value = 0;
	if (FT.ctype.checked == true) FT.camp_type_col_flag.value = 1;
	else FT.camp_type_col_flag.value = 0;
	if (FT.stDate.checked == true) FT.start_date_col_flag.value = 1;
	else FT.start_date_col_flag.value = 0;
	if (FT.subLine.checked == true) FT.subject_line_col_flag.value = 1;
	else FT.subject_line_col_flag.value = 0;
	if (FT.conName.checked == true) FT.content_name_col_flag.value = 1;
	else FT.content_name_col_flag.value = 0;
	if (FT.trGrpName.checked == true) FT.target_group_name_col_flag.value = 1;
	else FT.target_group_name_col_flag.value = 0;
	if (FT.cCode.checked == true) FT.camp_code_col_flag.value = 1;
	else FT.camp_code_col_flag.value = 0;
	if (FT.sen.checked == true) FT.sent_col_flag.value = 1;
	else FT.sent_col_flag.value = 0;
	if (FT.bBacks.checked == true) FT.bback_col_flag.value = 1;
	else FT.bback_col_flag.value = 0;
	if (FT.ope.checked == true) FT.open_col_flag.value = 1;
	else FT.open_col_flag.value = 0;
	if (FT.cThrough.checked == true) FT.clicks_through_col_flag.value = 1;
	else FT.clicks_through_col_flag.value = 0;
	if (FT.uScribes.checked == true) FT.unsubscribes_col_flag.value = 1;
	else FT.unsubscribes_col_flag.value = 0;
<%
	if (hasSalesAndOrder) {
%>
	if (FT.ord.checked == true) FT.orders_col_flag.value = 1;
	else FT.orders_col_flag.value = 0;
	if (FT.sal.checked == true) FT.sales_col_flag.value = 1;
	else FT.sales_col_flag.value = 0; 
<%
	}
%>

    var RegExPatternFloat= new RegExp("[0-9]*\.?[0-9]?");
	FT.bback_threshold_percent.value = FT.bbackth.value;
	FT.open_threshold_percent.value = FT.openth.value;
	FT.click_threshold_percent.value = FT.clickth.value;
	
	FT.bback_threshold_percent.value = FT.bback_threshold_percent.value.replace(/(^\s*)|(\s*$)/g, '');
	if (!RegExPatternFloat.test(FT.bback_threshold_percent.value)) {
		alert("The <Bounce Back Threshold> value must be a number with one decimal place ...");
		return false;
	}
	/*
	if( !isInteger(FT.bback_threshold_percent.value) )
	{
		alert("The <Bounce Back Threshold> value must be an integer ...");
		return false;
	}
	*/

	FT.open_threshold_percent.value = FT.open_threshold_percent.value.replace(/(^\s*)|(\s*$)/g, '');
	if (!RegExPatternFloat.test(FT.open_threshold_percent.value)) 
	{
		alert("The <Open Threshold> value must be a number with one decimal place ...");
		return false;
	}

	FT.click_threshold_percent.value = FT.click_threshold_percent.value.replace(/(^\s*)|(\s*$)/g, '');
	if (!RegExPatternFloat.test(FT.click_threshold_percent.value) )
	{
		alert("The <Click Through Threshold> value must be a number with one decimal place ...");
		return false;
	}

	FT.submit();
}

function isInteger (s)
{
	if (!isEmpty(s)) 
	{
     	var i;
		for (i = 0; i < s.length; i++)
		{
			var c = s.charAt(i);
			if (!isDigit(c)) return false;
		}
	}
	
	return true;
}

function isEmpty(s)
{
	return ((s == null) || (s.length == 0));
}

function isDigit (c)
{
	return ((c >= "0") && (c <= "9"));
}


</SCRIPT>
</BODY>

</HTML>
<%
} catch(Exception ex) { 
	ErrLog.put(this, ex, "Report Error.",out,1);
} finally {

	try { 	
		if( stmt != null ) stmt.close(); 
	} catch (Exception ex2) {}
	if( conn != null ) cp.free(conn); 
}
%>
