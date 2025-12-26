<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
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
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">

<HEAD>
	<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</HEAD>
<%

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

try	{
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
	
%>

<BODY ONLOAD="setChecks();">
<div class="page_header"><fmt:message key="header_cust_report"/></div>
<div class="page_desc"><fmt:message key="header_cust_report_desc"/></div>
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

<FORM  METHOD="POST" NAME="FT" ACTION="report_settings_save.jsp" TARGET="_self">

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
<br><br>
<SCRIPT LANGUAGE="JavaScript">

function setChecks() {
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

	FT.submit();
}

</SCRIPT>
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
</body>
</fmt:bundle>


</HTML>
