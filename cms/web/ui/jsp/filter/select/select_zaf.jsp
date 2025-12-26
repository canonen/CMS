<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sSaved = request.getParameter("saved");
if (sSaved == null) sSaved = "false";

String sCategoryId = request.getParameter("category_id");
if ((sCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sCategoryId = ui.s_category_id;
if("0".equals(sCategoryId)) sCategoryId = null;

String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

//KU: Added for content logic ui
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
<TITLE>Select <%= sTargetGroupDisplay %> Criteria</TITLE>
<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT>
function resizeWin()
{
	top.window.resizeTo(700,550);
}

function resetWin()
{
	top.window.resizeTo(700,300);
}

function showHideSections(event,item)
{
	var elem = event.srcElement? event.srcElement : event.target;
	var elemRow = elem;
	
	while (elemRow.tagName != "TR")
	{
		elemRow = elemRow.parentNode;
	}
	
	var elemTable = document.all.item("filterTable");
	var elemDetails = elem;
	var specRow = document.all.item(item);
	
	if (specRow.style.display == "none")
	{
		specRow.style.display = "";

		if (elemDetails.tagName == "A")
		{
			elemDetails.innerText = "[-]";
		}
	}
	else
	{
		specRow.style.display = "none";

		if (elemDetails.tagName == "A")
		{
			elemDetails.innerText = "[+]";
		}
	}
}

function validate_form(item)
{
	switch( item )
	{
		case 8:
			//Content blocks
			var ops = filter_8.integer_value.options;
			var si = filter_8.integer_value.selectedIndex;		
			
			filter_8.filter_name.value = "(CONTENT BLOCK) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_8.submit();
			}
			break;
		case 7:
			//Imports
			var ops = filter_7.integer_value.options;
			var si = filter_7.integer_value.selectedIndex;		
			
			filter_7.filter_name.value = "(IMPORT) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_7.submit();
			}
			break;
			
		case 7.1:
			//Imports
			var ops = filter_7_1.integer_value.options;
			var si = filter_7_1.integer_value.selectedIndex;		
			
			filter_7_1.filter_name.value = "(IMPORT) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_7_1.submit();
			}
			break;
			
		case 3:
			//Batches
			var ops = filter_3.integer_value.options;
			var si = filter_3.integer_value.selectedIndex;		
			
			filter_3.filter_name.value = "(BATCH) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_3.submit();
			}
			break;
			
		case 3.1:
			//Batches
			var ops = filter_3_1.integer_value.options;
			var si = filter_3_1.integer_value.selectedIndex;		
			
			filter_3_1.filter_name.value = "(BATCH) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_3_1.submit();
			}
			break;
			
		case 1:
			//Campaigns
			var ops = filter_1.integer_value.options;
			var si = filter_1.integer_value.selectedIndex;		
			
			filter_1.filter_name.value = "(CAMPAIGN) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_1.submit();
			}
			break;
			
		case 1.1:
			//Campaign Options
			var ops = filter_1_1.integer_value.options;
			var si = filter_1_1.integer_value.selectedIndex;
			
			if (filter_1_1.type_id.value == <%=FilterType.CAMPAIGN%>)
			{
				filter_1_1.filter_name.value = "(CAMPAIGN) " + ops[si].text;
			}
			else if (filter_1_1.type_id.value == <%=FilterType.LINK_READ%>)
			{
				filter_1_1.filter_name.value = "(OPEN HTML) " + ops[si].text;
			}
			else if (filter_1_1.type_id.value == <%=FilterType.BBACK_FROM_CAMPAIGN%>)
			{
				filter_1_1.filter_name.value = "(BBACK FROM CAMPAIGN) " + ops[si].text;
			}
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_1_1.submit();
			}
			break;
			
		case 14:
			//Forms
			var ops = filter_14.integer_value.options;
			var si = filter_14.integer_value.selectedIndex;		
			
			filter_14.filter_name.value = "(FORM) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_14.submit();
			}
			break;
			
		case 14.1:
			//Forms
			var ops = filter_14_1.integer_value.options;
			var si = filter_14_1.integer_value.selectedIndex;		
			
			filter_14_1.filter_name.value = "(FORM) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_14_1.submit();
			}
			break;
			
		case 24:
			//Newsletters
			var ops = filter_24.integer_value.options;
			var si = filter_24.integer_value.selectedIndex;		
			
			filter_24.filter_name.value = "(NEWSLETTER) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_24.submit();
			}
			break;
			
		case 24.1:
			//Newsletters
			var ops = filter_24_1.integer_value.options;
			var si = filter_24_1.integer_value.selectedIndex;		
			
			filter_24_1.filter_name.value = "(NEWSLETTER) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_24_1.submit();
			}
			break;

		case 5:
			//Link Clicks
			var ops = filter_5.integer_value.options;
			var si = filter_5.integer_value.selectedIndex;		
			
			filter_5.filter_name.value = "(LINK) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_5.submit();
			}
			break;
			
		case 0:
			//Target Groups
			var ops = filter_0.new_filter_id.options;
			var si = filter_0.new_filter_id.selectedIndex;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_0.submit();
			}
			break;
		case 64:
			//Brite Track Action
			var ops = filter_64.integer_value.options;
			var si = filter_64.integer_value.selectedIndex;
			filter_64.filter_name.value = "(ACTION) " + ops[si].text;
			
			var id_val = ops[si].value;
			if((id_val == null)||(id_val == ""))
			{
				return;
			}
			else
			{
				filter_64.submit();
			}
			break;	
	}
}
</SCRIPT>
</HEAD>

<BODY onload="resizeWin();" onunload="resetWin();">

<% if (sSaved.equals("true")) { %>

<table cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table cellspacing="0" cellpadding="4" border="0" class="main" width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p><font color="red"><b>Advanced Criteria Added to <%= sTargetGroupDisplay %></b></font>
						<br>Choose another criteria or click Cancel to return to the <%= sTargetGroupDisplay %></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>

<% } %>

<table cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Quick <%= sTargetGroupDisplay %>s&nbsp;
			<br><br>
			
<!-- === === === -->

<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
<!--
////////////////////////////
IMPORTS -- 7
////////////////////////////
//-->
<%
can = user.getAccessPermission(ObjectType.IMPORT);
if (can.bRead) {
%>
	<tr>
		<td align="left" valign="middle" class="listItem_Data" style="padding-left:10px;" nowrap><b>Import:</b> </td>
		<td align="left" valign="middle" class="listItem_Data" style="padding-left:10px;" width="100%">
			<form name="filter_7" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
				<input type="hidden" name="type_id" value="<%=FilterType.IMPORT%>">
				<input type="hidden" name="filter_name" value="">
				<input type="hidden" name="param_name" value="import_id">
				<input type="hidden" name="string_value" value="">
				<input type="hidden" name="date_value" value="">
				<select size="1" name="integer_value">
					<option>-----  Select An Import -----</option>
					<%=buildImportOptionsHtml(cust.s_cust_id, sCategoryId)%>
				</select>
			</form>
		</td>
		<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(7)">Save &gt;&gt;</a></td>
	</tr>
<!--
////////////////////////////
BATCHES -- 3
////////////////////////////
//-->
	<tr>
		<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" nowrap><b>Batch:</b> </td>
		<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" width="100%">
			<form name="filter_3" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
				<input type="hidden" name="type_id" value="<%=FilterType.BATCH%>">
				<input type="hidden" name="filter_name" value="">
				<input type="hidden" name="param_name" value="batch_id">
				<input type="hidden" name="string_value" value="">
				<input type="hidden" name="date_value" value="">
				<select size="1" name="integer_value">
					<option>-----  Select A Batch -----</option>
					<%=buildBatchOptionsHtml(cust.s_cust_id, sCategoryId)%>
				</select>
			</form>
		</td>
		<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(3);">Save &gt;&gt;</a></td>
	</tr>
<% } %>
<!--
////////////////////////////
CAMPAIGNS -- 1
////////////////////////////
//-->
<%
can = user.getAccessPermission(ObjectType.CAMPAIGN);
if (can.bRead) {
%>
	<tr>
		<td align="left" valign="middle" class="listItem_Data" style="padding-left:10px;" nowrap><b>Campaign:</b> </td>
		<td align="left" valign="middle" class="listItem_Data" style="padding-left:10px;" width="100%">
			<form name="filter_1" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
				<input type="hidden" name="type_id" value="<%=FilterType.CAMPAIGN%>">
				<input type="hidden" name="filter_name" value="">
				<input type="hidden" name="param_name" value="camp_id">
				<input type="hidden" name="string_value" value="">
				<input type="hidden" name="date_value" value="">
				<select size="1" name="integer_value">
					<option>-----  Select A Campaign -----</option>
					<%=buildCampOptionsHtml(cust.s_cust_id, sCategoryId)%>
				</select>
			</form>
		</td>
		<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(1);">Save &gt;&gt;</a></td>
	</tr>
<% } %>
<!--
////////////////////////////
FORMS -- 14
////////////////////////////
//-->
<%
can = user.getAccessPermission(ObjectType.FORM);
if (can.bRead) {
%>
	<tr>
		<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" nowrap><b>Form:</b> </td>
		<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" width="100%">
			<form name="filter_14" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
				<input type="hidden" name="type_id" value="<%=FilterType.FORM_SUBMIT%>">
				<input type="hidden" name="filter_name" value="">
				<input type="hidden" name="param_name" value="form_id">
				<input type="hidden" name="string_value" value="">
				<input type="hidden" name="date_value" value="">
				<select size="1" name="integer_value">
					<option>-----  Select A Form -----</option>
					<%=buildFormOptionsHtml(cust.s_cust_id, sCategoryId)%>					
				</select>				
			</form>
		</td>
		<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(14);">Save &gt;&gt;</a></td>
	</tr>
<% } %>
<!--
////////////////////////////
NEWSLETTERS -- 24
////////////////////////////
//-->
	<tr>
		<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" nowrap><b>Newsletter:</b> </td>
		<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" width="100%">
			<form name="filter_24" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
				<input type="hidden" name="type_id" value="<%=FilterType.NEWSLETTER%>">
				<input type="hidden" name="filter_name" value="">
				<input type="hidden" name="param_name" value="attr_id">
				<input type="hidden" name="string_value" value="">
				<input type="hidden" name="date_value" value="">
				<select size="1" name="integer_value">
					<option>-----  Select A Newsletter -----</option>
					<%=buildNewsletterOptionsHtml(cust.s_cust_id, sCategoryId)%>					
				</select>				
			</form>
		</td>
		<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(24);">Save &gt;&gt;</a></td>
	</tr>
<!--
////////////////////////////
CONTENT BLOCKS -- 8
////////////////////////////
//-->
	<tr>
		<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" nowrap><b>Content Block:</b> </td>
		<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" width="100%">
			<form name="filter_8" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
				<input type="hidden" name="type_id" value="<%=FilterType.CONTENT_BLOCK%>">
				<input type="hidden" name="filter_name" value="">
				<input type="hidden" name="param_name" value="cont_id">
				<input type="hidden" name="string_value" value="">
				<input type="hidden" name="date_value" value="">
				<select size="1" name="integer_value">
					<option>-----  Select A Content Block -----</option>
					<%=buildContentBlockOptionsHtml(cust.s_cust_id, sCategoryId)%>					
				</select>				
			</form>
		</td>
		<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(8);">Save &gt;&gt;</a></td>
	</tr>	
</table>
<br>
In-Depth <%= sTargetGroupDisplay %> Creation&nbsp;
<br><br>
<table class="listTable" width="100%" cellpadding="2" cellspacing="0" id="filterTable">
	<!--
	////////////////////////////
	CAMPAIGN OPTIONS -- 1.1
	////////////////////////////
	//-->
	<%
	can = user.getAccessPermission(ObjectType.CAMPAIGN);
	if (can.bRead) {
	%>
	<tr>
		<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="javascript:void(0);" onclick="showHideSections(event,'select_10');">[+]</a></td>
		<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap>Campaign Activity Information</td>
	</tr>
	<tr id="select_10" style="display:none;">
		<td align="left" valign="middle" class="listItemData" colspan="2" nowrap style="padding:0px;">
			<table class="main" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" nowrap>Campaigns: </td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap>
						<form name="filter_1_1" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
							<input type="hidden" name="filter_name" value="">
							<input type="hidden" name="param_name" value="camp_id">
							<input type="hidden" name="string_value" value="">
							<input type="hidden" name="date_value" value="">
							<select size="1" name="integer_value">
								<option>-----  Select A Campaign -----</option>
								<%=buildCampOptionsHtml(cust.s_cust_id, sCategoryId)%>
							</select>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<select size="1" name="type_id">
								<option value="<%=FilterType.CAMPAIGN%>">Who Received The Campaign</option>
								<option value="<%=FilterType.LINK_READ%>">Who Opened the HTML</option>
								<option value="<%=FilterType.BBACK_FROM_CAMPAIGN%>">Who Bounced Back</option>
							</select>
						</form>
					</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(1.1);">Save &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data" nowrap>Link Click: </td>
					<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap>
						<form name="filter_5" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
							<input type="hidden" name="type_id" value="<%=FilterType.LINK_CLICK%>">
							<input type="hidden" name="filter_name" value="">
							<input type="hidden" name="param_name" value="link_id">
							<input type="hidden" name="string_value" value="">
							<input type="hidden" name="date_value" value="">
				<!--
				////////////////////////////
				LINK CLICK -- 5
				////////////////////////////
				//-->
							<select size="1" name="integer_value">
								<option>-----  Select A Link -----</option>
								<%=buildLinkOptionsHtml(cust.s_cust_id, sCategoryId)%>
							</select>
						</form>
					</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(5);">Save &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Received a specified number of campaigns during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_16.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap colspan="2">Received a specified campaign during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_23.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Clicked on a specified number of links during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_17.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap colspan="2">Opened a specified number of HTML emails during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_18.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Bounced back from a specified number of campaigns during a specified time period</td>
					<td align="center" valign="middle" class="listItem_AltData" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_19.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Clicked on links in a specified number of campaigns during a specified time period</td>
					<td align="center" valign="middle" class="listItem_AltData" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_27.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Clicked on links in a specified percentage of campaigns during a specified time period</td>
					<td align="center" valign="middle" class="listItem_AltData" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_28.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Opened HTML emails from a specified number of Campaigns during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_62.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Opened HTML emails from a specified percentage of Campaigns during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_63.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
			</table>
		</td>
	</tr>
	<% } %>
	<tr>
		<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="javascript:void(0);" onclick="showHideSections(event,'select_20');">[+]</a></td>
		<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap>Database Information</td>
	</tr>
	<tr id="select_20" style="display:none;">
		<td align="left" valign="middle" class="listItem_Data_Alt" colspan="2" nowrap style="padding:0px;">
			<table class="main" width="100%" cellpadding="2" cellspacing="0">
				<!--
				////////////////////////////
				TARGET GROUPS -- 0
				////////////////////////////
				//-->
				<%
				can = user.getAccessPermission(ObjectType.FILTER);
				if (can.bRead) {
				%>
				<tr>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data" nowrap>Target Groups: </td>
					<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap>
						<form name="filter_0" method="post" action="../edit/save_0.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
							<input type="hidden" name="type_id" value="<%=FilterType.MULTIPART%>">
							<select size="1" name="new_filter_id">
								<option>-----  Select A Target Group -----</option>
								<%=buildFilterOptionsHtml(cust.s_cust_id, sCategoryId)%>
							</select>
						</form>
					</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(0);">Save &gt;&gt;</a></td>
				</tr>
				<% } %>
				<!--
				////////////////////////////
				IMPORTS -- 7.1
				////////////////////////////
				//-->
				<%
				can = user.getAccessPermission(ObjectType.IMPORT);
				if (can.bRead) {
				%>
				<tr>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data" nowrap>Imports: </td>
					<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap>
						<form name="filter_7_1" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
							<input type="hidden" name="type_id" value="<%=FilterType.IMPORT%>">
							<input type="hidden" name="filter_name" value="">
							<input type="hidden" name="param_name" value="import_id">
							<input type="hidden" name="string_value" value="">
							<input type="hidden" name="date_value" value="">
							<select size="1" name="integer_value">
								<option>-----  Select An Import -----</option>
								<%=buildImportOptionsHtml(cust.s_cust_id, sCategoryId)%>				
							</select>				
						</form>
					</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(7.1)">Save &gt;&gt;</a></td>
				</tr>
				<!--
				////////////////////////////
				BATCHES -- 3.1
				////////////////////////////
				//-->
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" nowrap>Batches: </td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap>
						<form name="filter_3_1" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
							<input type="hidden" name="type_id" value="<%=FilterType.BATCH%>">
							<input type="hidden" name="filter_name" value="">
							<input type="hidden" name="param_name" value="batch_id">
							<input type="hidden" name="string_value" value="">
							<input type="hidden" name="date_value" value="">
							<select size="1" name="integer_value">
								<option>-----  Select A Batch -----</option>
								<%=buildBatchOptionsHtml(cust.s_cust_id, sCategoryId)%>								
							</select>
						</form>
					</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(3.1);">Save &gt;&gt;</a></td>
				</tr>
				<% } %>
				<!--
				////////////////////////////
				NEWSLETTERS -- 24
				////////////////////////////
				//-->
				<tr>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data" nowrap>Newsletters: </td>
					<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap>
						<form name="filter_24_1" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
							<input type="hidden" name="type_id" value="<%=FilterType.NEWSLETTER%>">
							<input type="hidden" name="filter_name" value="">
							<input type="hidden" name="param_name" value="attr_id">
							<input type="hidden" name="string_value" value="">
							<input type="hidden" name="date_value" value="">
							<select size="1" name="integer_value">
								<option>-----  Select A Newsletter -----</option>
								<%=buildNewsletterOptionsHtml(cust.s_cust_id, sCategoryId)%>					
							</select>				
						</form>
					</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(24.1)">Save &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Calculated results using Date fields</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_21.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap colspan="2">Aggregate functions using Historical data</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_22.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
			</table>
		</td>
	</tr>
	<!--
	////////////////////////////
	FORM SUBMISSIONS -- 14.1
	////////////////////////////
	//-->
	<%
	can = user.getAccessPermission(ObjectType.FORM);
	if (can.bRead) {
	%>
	<tr>
		<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="javascript:void(0);" onclick="showHideSections(event,'select_30');">[+]</a></td>
		<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap colspan="2">Form Submission Information</td>
	</tr>
	<tr id="select_30" style="display:none;">
		<td align="left" valign="middle" class="listItemData" colspan="2" nowrap style="padding:0px;">
			<table class="main" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" nowrap>Form Submissions: </td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap>
						<form name="filter_14_1" method="post" action="../edit/save_zaf.jsp?usage_type_id=<%= sUsageTypeId %>" style="display:inline;">
							<input type="hidden" name="type_id" value="<%=FilterType.FORM_SUBMIT%>">
							<input type="hidden" name="filter_name" value="">
							<input type="hidden" name="param_name" value="form_id">
							<input type="hidden" name="string_value" value="">
							<input type="hidden" name="date_value" value="">
							<select size="1" name="integer_value">
								<option>-----  Select A Form -----</option>
								<%=buildFormOptionsHtml(cust.s_cust_id, sCategoryId)%>
							</select>
						</form>
					</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="validate_form(14.1);">Save &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap colspan="2">Recipients who submitted a Form in association with a Campaign</td>
					<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_2.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Submitted a form a specified number of times during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_20.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Submitted a specified form during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_26.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Submitted Forms from a specified number of Campaigns during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_60.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Submitted Forms from a specified percentage of Campaigns during a specified time period</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_61.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
			</table>
		</td>
	</tr>
	<% } %>
	<!--
	////////////////////////////
	ENTITIES -- 15.1
	////////////////////////////
	//-->
	<tr>
		<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="javascript:void(0);" onclick="showHideSections(event,'select_40');">[+]</a></td>
		<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap colspan="2">Entity based</td>
	</tr>
	<tr id="select_40" style="display:none;">
		<td align="left" valign="middle" class="listItemData" colspan="2" nowrap style="padding:0px;">
			<table class="main" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" nowrap>Entities referencing recipient: </td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap>
						<form name="filter_15_1" method="post" action="../edit/edit_25.jsp" style="display:inline;">
							<input type="hidden" name="usage_type_id" value="<%= sUsageTypeId %>">							
							<select size="1" name="entity_id">
								<option>-----  Select an Entity -----</option>
								<%=buildEntityOptionsHtml(cust.s_cust_id)%>
							</select>
						</form>
					</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="#" onclick="filter_15_1.submit();">Next &gt;&gt;</a></td>
				</tr>
			</table>
		</td>
	</tr>
<!--
////////////////////////////
REVOTRACK
//////////////////////////// 
-->

<tr>
		<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="javascript:void(0);" onclick="showHideSections(event,'select_50');">[+]</a></td>
		<td align="left" valign="middle" class="listItem_Data" width="100%" nowrap colspan="2">RevoTrack Information</td>
	</tr>
	<tr id="select_50" style="display:none;">
		<td align="left" valign="middle" class="listItemData" colspan="2" nowrap style="padding:0px;">
			<table class="main" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Recipient performed a specified action</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_64.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Recipient performed a specified action with a specified parameter</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_65.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
				<tr>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;">&nbsp;</td>
					<td align="left" valign="middle" class="listItem_Data_Alt" width="100%" nowrap colspan="2">Recipient performed two actions with specified parameters</td>
					<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="../edit/edit_66.jsp?usage_type_id=<%= sUsageTypeId %>">Next &gt;&gt;</a></td>
				</tr>
			</table>
		</td>
	</tr>
<!-- === === === -->


</table>
			


			
			<br>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<input type="button" class="subactionbutton" onclick="window.close();" value="Close">
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>

<%!
private static String buildImportOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
	if (sCategoryId == null)
	{
		sSql =
			" SELECT i.import_id, i.import_name" +
			" FROM cupd_import i WITH(NOLOCK), cupd_batch b WITH(NOLOCK)" +
			" WHERE i.batch_id = b.batch_id" +
			" AND b.cust_id = " + sCustId +
			" AND i.status_id = " + ImportStatus.COMMIT_COMPLETE +
			" ORDER BY i.import_name";
	}
	else
	{
		sSql =
			" SELECT i.import_id, i.import_name" +
			" FROM cupd_import i WITH(NOLOCK), cupd_batch b WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE i.batch_id = b.batch_id" +
			" AND b.cust_id = " + sCustId +
			" AND i.status_id = " + ImportStatus.COMMIT_COMPLETE +
			" AND oc.object_id = i.import_id" +
			" AND oc.type_id = " + ObjectType.IMPORT +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = "+sCategoryId + 
			" ORDER BY i.import_name";
	}
	return buildOptionsHtml(sSql);
}

private static String buildBatchOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
	if (sCategoryId == null)
	{
		sSql =
			" SELECT b.batch_id, b.batch_name" +
			" FROM cupd_batch b WITH(NOLOCK)" + 
			" WHERE ( (b.type_id = 1" + 
			" AND b.batch_id IN" +
				" (SELECT DISTINCT i.batch_id" +
				" FROM cupd_import i WITH(NOLOCK), cupd_batch b WITH(NOLOCK)" +
				" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
				" AND i.batch_id = b.batch_id" +
				" AND b.cust_id = " + sCustId + "))" +
			" OR (b.type_id > 1) )" +
			" AND b.cust_id = " + sCustId +
			" ORDER BY b.type_id, b.batch_name";
	}
	else
	{
		sSql =
			" SELECT b.batch_id, b.batch_name" +
			" FROM cupd_batch b WITH(NOLOCK)" + 
			" WHERE ( (b.type_id = 1" + 
			" AND b.batch_id IN" +
				" (SELECT DISTINCT i.batch_id" +
				" FROM cupd_import i WITH(NOLOCK), cupd_batch b WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
				" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
				" AND i.batch_id = b.batch_id" +
				" AND b.cust_id = " + sCustId + 
				" AND oc.object_id = i.import_id" +
				" AND oc.type_id = " + ObjectType.IMPORT +
				" AND oc.cust_id = " + sCustId +
				" AND oc.category_id = "+sCategoryId + "))" +
			" OR (b.type_id > 1) )" +
			" AND b.cust_id = " + sCustId +
			" ORDER BY b.type_id, b.batch_name";
	}
	return buildOptionsHtml(sSql);
}

private static String buildCampOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
	if (sCategoryId == null)
	{
		sSql  =
			" SELECT camp_id, camp_name" +
			" FROM cque_campaign WITH(NOLOCK)" +
			" WHERE origin_camp_id IS NULL" +
			" AND cust_id = " + sCustId +
			" AND status_id <> " + CampaignStatus.DELETED +
			" ORDER BY camp_name";
	}
	else
	{
		sSql  =
			" SELECT c.camp_id, c.camp_name" +
			" FROM cque_campaign c WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE c.origin_camp_id IS NULL" +
			" AND c.cust_id = " + sCustId +
			" AND c.status_id <> " + CampaignStatus.DELETED +
			" AND c.camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY c.camp_name";
	}
	return buildOptionsHtml(sSql);	
}

private static String buildFormOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql =
		" SELECT form_id, form_name" +
		" FROM csbs_form WITH(NOLOCK)" +
		" WHERE cust_id = " + sCustId +
		" ORDER BY form_name";
	return buildOptionsHtml(sSql);	
}

private static String buildNewsletterOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql =
		" SELECT attr_id, display_name" +
		" FROM ccps_cust_attr WITH(NOLOCK)" +
		" WHERE cust_id = " + sCustId +
		" AND newsletter_flag IS NOT NULL" +
		" ORDER BY display_seq";
	
	return buildOptionsHtml(sSql);	
}

private static String buildContentBlockOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
	if (sCategoryId == null)
	{
		sSql  =
			" SELECT cont_id, cont_name" +
			" FROM ccnt_content WITH(NOLOCK)" +
			" WHERE origin_cont_id IS NULL" +
			" AND cust_id = " + sCustId +
			" AND type_id = " + ContType.PARAGRAPH +
			" AND status_id <> " + ContStatus.DELETED +
			" ORDER BY cont_name";
	}
	else
	{
		sSql  =
			" SELECT c.cont_id, c.cont_name" +
			" FROM ccnt_content c WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE c.origin_cont_id IS NULL" +
			" AND c.cust_id = " + sCustId +
			" AND c.type_id = " + ContType.PARAGRAPH +
			" AND c.status_id <> " + ContStatus.DELETED +
			" AND c.cont_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CONTENT +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY c.cont_name";
	}
 	return buildOptionsHtml(sSql);	
}

private static String buildLinkOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
						
	if (sCategoryId == null)
	{
		sSql =
			" SELECT link_id, '[' + c.camp_name + '] ' + link_name" +
			" FROM cjtk_link l WITH(NOLOCK), cque_campaign c WITH(NOLOCK)" +
			" WHERE" +
			//" (l.origin_link_id IS NULL) AND" +
			" l.href IS NOT NULL AND" +
			" l.cust_id = " + sCustId + " AND" +
			" l.cont_id = c.cont_id AND" +
			" c.origin_camp_id IS NOT NULL AND" +
			" c.type_id != 1" +
			" ORDER BY '[' + c.camp_name + '] ' + link_name";
	}
	else
	{
		sSql =
			" SELECT link_id, '[' + c.camp_name + '] ' + link_name" +
			" FROM cjtk_link l WITH(NOLOCK), cque_campaign c WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE" +
			//" l.parent_link_id IS NULL AND" +
			" l.href IS NOT NULL" +
			" AND l.cust_id = " + sCustId +
			" AND l.cont_id = c.cont_id" +
			" AND c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != 1" +
			" AND c.camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY '[' + c.camp_name + '] ' + link_name";
	}
	return buildOptionsHtml(sSql);	
}

private static String buildFilterOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;

	if (sCategoryId == null)
	{
		sSql  =
			" SELECT filter_id, filter_name" +
			" FROM ctgt_filter WITH(NOLOCK)" +
			" WHERE origin_filter_id IS NULL" +
			" AND len(filter_name) > 0" +
			" AND type_id = " + FilterType.MULTIPART +
			" AND cust_id = " + sCustId +
			" AND status_id != " + FilterStatus.DELETED +
			" AND ISNULL(usage_type_id,500) = " + FilterUsageType.REGULAR +
			" ORDER BY filter_name";
	}
	else
	{
		sSql  =
			" SELECT f.filter_id, f.filter_name" +
			" FROM ctgt_filter f WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE f.origin_filter_id IS NULL" +
			" AND len(filter_name) > 0" +			
			" AND f.type_id = " + FilterType.MULTIPART +
			" AND f.cust_id = " + sCustId +
			" AND f.status_id != " + FilterStatus.DELETED +
			" AND ISNULL(f.usage_type_id,500) = " + FilterUsageType.REGULAR +
			" AND f.filter_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY f.filter_name";
	}
	return buildOptionsHtml(sSql);	
}

private static String buildEntityOptionsHtml(String sCustId) throws Exception
{
	String sSql  =
			" SELECT e.entity_id, e.entity_name" +
			" FROM" +
			"	cntt_entity e," +
			"	cntt_entity_attr ea" +
			" WHERE e.cust_id = " + sCustId +
			" AND e.entity_id = ea.entity_id" +
			" AND ea.type_id = 1000";
        
	return buildOptionsHtml(sSql);	
}

private static String buildOptionsHtml(String sSql) throws Exception
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
			return buildOptionsHtml(sSql,stmt);
		}
		catch(Exception ex) { throw ex; }
		finally { if(stmt != null) stmt.close(); }
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn != null) cp.free(conn); }
}

private static String buildOptionsHtml(String sSql, Statement stmt) throws Exception
{
	StringWriter sw = new StringWriter();
	
	String sId = null;
	byte[] b = null;	
	String sName = null;

	ResultSet rs = stmt.executeQuery(sSql);
	while (rs.next())
	{
		sId = rs.getString(1);
		b = rs.getBytes(2);
		sName = (b==null)?null:new String(b, "UTF-8");
		sw.write("<option value=\"" + sId + "\">");
		sw.write(HtmlUtil.escape(sName));
		sw.write("</option>\r\n");
	}
	rs.close();

	return sw.toString();
}
%>
