<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.tgt.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
String sCampId = request.getParameter("camp_id");
String sDynamicCampFlag = request.getParameter("filter_flag");
Campaign camp = new Campaign();
camp.s_camp_id = sCampId;
if(camp.retrieve() < 1) return;
com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter(camp.s_filter_id);
FilterStatistic filter_statistic = new FilterStatistic(camp.s_filter_id);

CampSampleset cs = new CampSampleset();
cs.s_camp_id = camp.s_camp_id;
int nRetrieve = cs.retrieve();
if(nRetrieve < 1) {
	cs.s_recip_percentage = "100";
	cs.s_filter_flag = sDynamicCampFlag;
}

// === SET MEDIA TYPE DEFAULTS ===
boolean isPrintCampaign = false;
if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2")) {
	isPrintCampaign = true;
}

boolean isDynamicCampaign = false;
if (cs.s_filter_flag != null && cs.s_filter_flag.equals("1")) {
	isDynamicCampaign = true;
}
%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	
	<script language="javascript">
	
	function doSubmit()
	{
		var qty = FT.camp_qty;
		if ((qty != null) && (qty.value != "") && parseInt(qty.value) > 0)
		{
			FT.submit();
		}
		else {
			alert("You must create at least one campaign");
		}
	}
	
	</script>
</HEAD>



<BODY>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="subactionbutton" href="camp_edit.jsp?camp_id=<%=HtmlUtil.escape(camp.s_camp_id)%>">Cancel &amp; Return to Campaign</a>
		</td>
	</tr>
</table>
<br>
<FORM METHOD="POST" NAME="FT" ACTION="camp_sampleset_save.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="camp_id" value="<%=HtmlUtil.escape(camp.s_camp_id)%>">
<INPUT TYPE="hidden" NAME="filter_flag" value="<%=HtmlUtil.escape(cs.s_filter_flag)%>">	
	<table width="650" class="main" cellspacing="0" cellpadding="0">
		<tr>
			<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Campaign Information</td>
		</tr>
	</table>
	<br>
<%@ include file="camp_sampleset_edit/step_1.jsp"%>
	<br><br>

	<table width="650" class="main" cellspacing="0" cellpadding="0">
		<tr>
			<td class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Distribute recipients among <%=(isDynamicCampaign?"dynamic":"sample") %> campaigns and final campaign</td>
		</tr>
	</table>
	<br>
<%@ include file="camp_sampleset_edit/step_2.jsp"%>
	<br><br>

	<table width="650" class="main" cellspacing="0" cellpadding="0">
		<tr>
			<td class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Define variable parameters in <%=(isDynamicCampaign?"dynamic":"sample") %> campaigns</td>
		</tr>
	</table>
	<br>
<%@ include file="camp_sampleset_edit/step_3.jsp"%>
	<br><br>

<%
if( can.bWrite)
{
	%>
	<table width="650" class="main" cellspacing="0" cellpadding="0">
		<tr>
			<td class="sectionheader">&nbsp;<b class="sectionheader">Step 4:</b> Create <%=(isDynamicCampaign?"Dynamic":"Sample Set") %> Campaigns</td>
		</tr>
	</table>
	<br>
	<table id="Tabs_Table5" cellspacing="0" cellpadding="0" width="650" border="0">
		<tr>
			<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height="2" src="../../images/blank.gif" width="1"></td>
		</tr>
		<tr>
			<td class="fillTabbuffer" valign="top" align="left" width="650"><img height="2" src="../../images/blank.gif" width="1"></td>
		</tr>
		<tbody class="EditBlock">
		<tr>
			<td class="fillTab" valign="top" align="center" width="650">
				<table class="main" cellspacing="1" cellpadding="2" width="100%">
					<tr>
						<td align="center" valign="middle" style="padding:10px;">
							<a class="actionbutton" href="javascript:doSubmit();">CREATE <%=(isDynamicCampaign?"DYNAMIC CAMPAIGNS":"SAMPLE SETS") %></a>&nbsp;&nbsp;&nbsp;
						</td>
					</tr>
				</table>
			</td>
		</tr>
		</tbody>
	</table>	
	<br><br>
	<%
}
%>
</FORM>
</BODY>
</HTML>
