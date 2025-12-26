<%@ page

	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,java.util.Date,
			java.io.*,org.apache.log4j.*"
%>
<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../../access_denied.jsp");
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
	<SCRIPT src="../../../js/scripts.js"></SCRIPT>
</HEAD>
<%

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("bback_settings_edit.jsp");
	stmt = conn.createStatement();

%>

<BODY>
<div class="page_header"><fmt:message key="header_bounce_settings"/> </div>
<div class="page_desc"><fmt:message key="header_bounce_settings_desc"/></div>

<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onClick="trySubmit();">Save</a>
		</td>
	</tr>
</table>
<br>

<FORM  METHOD="POST" NAME="FT" ACTION="bback_settings_save.jsp" TARGET="_self">
<%
	String sSql = "SELECT max_bbacks, max_bback_days, max_consec_bbacks, max_consec_bback_days FROM ccps_customer"
		+ " WHERE cust_id = "+cust.s_cust_id;
	
	String sMaxBBacks = null;
	String sMaxBBackDays = null;
	String sMaxConsecBBacks = null;
	String sMaxConsecBBackDays = null;
	rs = stmt.executeQuery(sSql);
	if (rs.next()) {
		sMaxBBacks = rs.getString(1);
		sMaxBBackDays = rs.getString(2);
		sMaxConsecBBacks = rs.getString(3);
		sMaxConsecBBackDays = rs.getString(4);
	}
	boolean bBBacks = false;
	boolean bConsecBBacks = false;
	if (sMaxBBacks != null) {
		bBBacks = true;
	}
	if (sMaxConsecBBacks != null) {
		bConsecBBacks = true;
	}
%>
<TABLE cellpadding="0" cellspacing="0" class="listTable" width="400">
<thead>
					<th><B class="sectionheader">Step 1:</B> Soft Bounce Back Retry Parameters</th>

				</thead>

	<tr>
		<td>
			<table cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td WIDTH="60" align="left" valign="middle" rowspan="4">
						Sample <br> campaigns<br> will<br> use:
					</td>
					<td WIDTH="40" align="left" valign="middle" rowspan="2" nowrap>
						<input name="bounce_method" id="bounce_method_total" type="checkbox" <%= (bBBacks?"checked":"") %> onClick="doEdit();"> <br>total bounces
					</td>
					<td>Maximum Total Number of Bounce Backs</td>
					<td><input type="text" name="max_bbacks" id="max_bbacks" size="3" value="<%=HtmlUtil.escape(sMaxBBacks)%>" <%= (bBBacks?"":"disabled") %> ></td>
				</tr>
				<tr>
					<td>Number of Days to Use when Calculating Total Bounce Back Quantity</td>
					<td><input type="text" name="max_bback_days" id="max_bback_days" size="3" value="<%=HtmlUtil.escape(sMaxBBackDays)%>" <%= (bBBacks?"":"disabled") %> ></td>
				</tr>
				<tr>
					<td WIDTH="10" align="left" valign="middle" rowspan="2">
						<input name="bounce_method" id="bounce_method_consec" type="checkbox" <%= (bConsecBBacks?"checked":"") %> onClick="doEdit2();"><br>consecutive bounces
					</td>
					</td>
					<td>Maximum Number of Consecutive Bounce Backs</td>
					<td><input type="text" name="max_consec_bbacks" id="max_consec_bbacks"  size="3" value="<%=HtmlUtil.escape(sMaxConsecBBacks)%>" <%= (bConsecBBacks?"":"disabled") %> ></td>
				</tr>
				<tr>
					<td>Number of Days to Use when Calculating Consecutive Bounce Back Quantity</td>
					<td><input type="text" name="max_consec_bback_days" id="max_consec_bback_days" size="3" value="<%=HtmlUtil.escape(sMaxConsecBBackDays)%>" <%= (bConsecBBacks?"":"disabled") %> ></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<br>
<TABLE cellpadding="0" cellspacing="0" class="listTable" width="400">
<thead>
					<th><B class="sectionheader"Step 2:</B> Hard Bounceback Categories</th>

				</thead>

	<tr>
		<td>
			<table cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						Bouncebacks defined as a "Hard Bounceback" will be excluded from all future sendouts 
						after the first bounce back, bypassing the settings above.
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<th>&nbsp;</th>
					<th>Category</th>
				</tr>
			<%
				sSql = "SELECT c.category_id, c.category_name, h.bback_category_id" +
					" FROM crpt_bback_category c" +
						" LEFT OUTER JOIN ccps_cust_hard_bback h" +
							" ON c.category_id = h.bback_category_id" +
							" AND h.cust_id = "+cust.s_cust_id +
					" ORDER BY c.category_id";

				rs = stmt.executeQuery(sSql);
				int iRow = 0;
				while (rs.next()) {
					iRow++;
					String sBBackCatId = rs.getString(1);
					String sBBackCatName = rs.getString(2);
					String sHardBBackCatId = rs.getString(3);
			%>
				<tr>
					<td class="listItem_Data<%=((iRow%2)!=0)?"":"_Alt"%>" width="20" align="center">
						<input name="bback_category_id" type="checkbox" value="<%=sBBackCatId%>"<%=(sHardBBackCatId!=null)?" checked":""%>>
					</td>
					<td class="listItem_Data<%=((iRow%2)!=0)?"":"_Alt"%>"><%=sBBackCatName%></td>
				</tr>
			<%
				}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
<SCRIPT LANGUAGE="JavaScript">

function trySubmit()
{
	if (!FT.bounce_method_total.checked && !FT.bounce_method_consec.checked) {
		alert("You must select at least one bounce method in step 1");
		return;
	}
	
	if (FT.bounce_method_total.checked && (FT.max_bbacks.value == "" || FT.max_bback_days.value == "")) {
	 	alert("Invalid values in Step 1, total bounces");
	 	return;
	}
	
	if (FT.bounce_method_consec.checked && (FT.max_consec_bbacks.value == "" || FT.max_consec_bback_days.value == "")) {
	 	alert("Invalid values in Step 1, consecutive bounces");
	 	return;
	}
	
	FT.submit();
}

function doEdit()
{
	if (FT.bounce_method_total.checked) {
		FT.max_bbacks.disabled = false;
		FT.max_bback_days.disabled = false;
	}
	else {
		FT.max_bbacks.disabled = true;
		FT.max_bback_days.disabled = true;
		FT.max_bbacks.value = "";
		FT.max_bback_days.value = "";
	}
}

function doEdit2()
{
	if (FT.bounce_method_consec.checked) {
		FT.max_consec_bbacks.disabled = false;
		FT.max_consec_bback_days.disabled = false;
	}
	else {
		FT.max_consec_bbacks.disabled = true;
		FT.max_consec_bback_days.disabled = true;
		FT.max_consec_bbacks.value = "";
		FT.max_consec_bback_days.value = "";
	}
	
}

</SCRIPT>

</HTML>
<%
} catch(Exception ex) { 
	throw ex;
} finally {

	try { 	
		if( stmt != null ) stmt.close(); 
	} catch (Exception ex2) {}
	if( conn != null ) cp.free(conn); 
}
%>
</body>
</fmt:bundle>
