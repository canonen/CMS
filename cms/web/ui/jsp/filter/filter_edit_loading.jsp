<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,java.util.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"	
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sSelectedCategoryId = ui.s_category_id;

String sFilterId = BriteRequest.getParameter(request, "filter_id");

// KO: Added for content filter support
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");
String sLogicId = BriteRequest.getParameter(request, "logic_id");
String sParentContId = BriteRequest.getParameter(request, "parent_cont_id");

//KU: Added for content logic ui
boolean bIsTargetGroup = true;
String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
	bIsTargetGroup = false;
}
else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Report Filter";
	bIsTargetGroup = false;
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}

boolean canSupReq = ui.getFeatureAccess(Feature.SUPPORT_REQUEST);

// === === ===

com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter();

FilterEditInfo filter_edit_info = new FilterEditInfo();
User creator = null;
User modifier = null;

boolean bIsNewFilter = false;
String s_recip_qty = null;
String s_last_update_date = null;

if(sFilterId == null)
{
	filter.s_filter_name = "New " + sTargetGroupDisplay;
	filter.s_type_id = String.valueOf(FilterType.MULTIPART);
	filter.s_cust_id = cust.s_cust_id;
	filter.s_status_id = String.valueOf(FilterStatus.NEW);
	filter.s_usage_type_id = String.valueOf(FilterUsageType.REGULAR);
	
	creator = user;
	modifier = user;

     bIsNewFilter = true;
	s_recip_qty = "";
	s_last_update_date = "";
}
else
{
	filter.s_filter_id = sFilterId;
	if(filter.retrieve() < 1) return;

	filter_edit_info.s_filter_id = filter.s_filter_id;
	filter_edit_info.retrieve();

	creator = new User(filter_edit_info.s_creator_id);
	modifier = new User(filter_edit_info.s_modifier_id);
	
	FilterStatistic filter_stat = new FilterStatistic(filter.s_filter_id);
	s_recip_qty = (filter_stat.s_recip_qty == null) ?"Unknown": filter_stat.s_recip_qty;
	s_last_update_date = (filter_stat.s_finish_date == null) ?"Unknown": filter_stat.s_finish_date;
}

int iStatusId = Integer.parseInt(filter.s_status_id);

boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);
String sAprvlRequestId = request.getParameter("aprvl_request_id");
boolean isApprover = false;
String sAprvlStatusFlag = null;
if (sFilterId != null) {
     if (sAprvlRequestId == null)
          sAprvlRequestId = "";
     ApprovalRequest arRequest = null;
     if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
          arRequest = new ApprovalRequest(sAprvlRequestId);
     } else {
          arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.FILTER),sFilterId);
     }
     if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
          sAprvlRequestId = arRequest.s_approval_request_id;
          isApprover = true;
     }
}

boolean bCanEditParts = true;
if ((bWorkflow && iStatusId == FilterStatus.PENDING_APPROVAL) || "-1".equals(filter.s_aprvl_status_flag)) {
     bCanEditParts = false;
}

%>

<HTML>

<HEAD>
<TITLE></TITLE>
<!-- <LINK rel="stylesheet" href="filter.css" type="text/css"> -->
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">

<SCRIPT>
<%@ include file="filter_zaf.js"%>
</SCRIPT>

<script type="text/javascript">

	function lazyLoad(elem)
	{
		var e = document.getElementById('tgtgroupactions');		
		var lazyload = document.getElementById('lazyload');
		lazyload.innerHTML = "<img src='/cms/ui/images/lazyload.gif'>";
		e.style.display = 'none';	
	}

</script>

<SCRIPT>

function showFilterDetails(filter_id, action)
{ 
	_oPop = window.open("filter_stat_details.jsp?a=" + action + "&filter_id=" + <%= filter.s_filter_id %>, "FilterDetails", "resizable=yes, directories=0, location=0, menubar=0, scrollbars=1, status=0, toolbar=0, height=350, width=450");
}

	function isFilterValid()
	{
		if (document.all.filter_name.value.length == 0)
		{
			alert("Please enter a Name for this <%= sTargetGroupDisplay %>");
			return false;
		}
		
		// === === ===

		for(i = 0; i < document.all.length; i++)
		{
			var s = document.all(i)
			if((s.id != null) && (s.id == 'formula_prototype')) break;		
			if((s.tagName != null) && (s.tagName.toUpperCase() == 'SELECT'))
			{
				if((s.xml_tag == null) || (s.xml_tag != 'attr_id')) continue;
				if((s.value == null ) || (s.value == ''))
				{
					s.focus();
					var sMsg =
						"Invalid field!\r\n\r\n" +
						"Select field from drop down list\r\n" +
						"OR\r\n" +
						"remove criteria using [ X ] button to the right of the criteria";
						
					alert(sMsg);
					return false;					
				}
			}
			else if((s.tagName != null) && (s.tagName.toUpperCase() == 'INPUT'))
			{
				if((s.xml_tag == null) || (s.xml_tag != 'value1')) continue;
				if((s.value == null) || (s.value == ''))
				{
					s.focus();
					var sMsg = 
						"Invalid field!\r\n\r\n" +
						"Enter a value in the text box.";
					
					alert(sMsg);
					return false;
				}
			}
		}
		
		return is_filter_structure_valid(null);
	}
	
	function reset_draft_status()
	{
		filter_save()
	}

	function filter_save()
	{
		if(!isFilterValid())
		{
			filter_form.save_type.value = '';			
			return;
		}
		
		undisable_forms();       // just in case
		build_xml();
		
		filter_form.action = "filter_save.jsp";
		filter_form.submit();
	}

	function filter_save_and_update()
	{
		filter_form.save_type.value = 'save_and_update';
		filter_save();
	}

	function filter_clone()
	{
          filter_form.save_type.value = 'clone';
		filter_save();
	}

	function filter_clone2destination()
	{
		filter_form.save_type.value = 'clone2destination';
		filter_save();
	}

	function filter_delete()
	{
		var sMsg =
			'Deleting this <%= sTargetGroupDisplay %> will effect' +
			' any active Campaigns to which it is assigned.\n' +
			'Are you sure you want to proceed?';
		if (!confirm(sMsg)) return;
          undisable_forms();  // just in case
		filter_form.action = "filter_delete.jsp";
		filter_form.submit();
	}

	function show_hide_important_notice()
	{
		if(important_notice.style.display == '')
			important_notice.style.display = 'none';
		else
			important_notice.style.display = '';

		return false;
	}

     function RequestApproval() {

		filter_form.save_type.value = 'save_and_request_approval';			
          filter_save()

     }

     function workflow_approve() {
          undisable_forms()
          filter_form.action = "../workflow/approval_send.jsp"
          filter_form.disposition_id.value = "10"     // approve
          filter_form.submit()
     }

     function workflow_reject() {
          undisable_forms()
          filter_form.action = "../workflow/approval_edit.jsp"
          filter_form.disposition_id.value = "90"     // reject
          filter_form.submit()
     }

     function workflow_approve_w_comments() {
          undisable_forms()
          filter_form.action = "../workflow/approval_edit.jsp"
          filter_form.disposition_id.value = "10"     // approve
          filter_form.submit()
     }

     function undisable_forms()
     {
          var l = document.forms.length;
          for(var i=0; i < l; i++)
          {
               var m = document.forms[i].elements.length;
               for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = false;
          }
     }

     function disable_forms()
     {
          var l = document.forms.length;
          for(var i=0; i < l; i++)
          {
               document.forms[i].action = null;
               var m = document.forms[i].elements.length;
               for(var j=0; j < m; j++) {
                         document.forms[i].elements[j].disabled = true;
               }
          }
     }
	 
	var arrValues = new Array();
	
	<%
	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null; 
	String sSQL = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		sSQL =
			" SELECT attr_id, filter_usage" +
			" FROM ccps_attr_calc_props" +
			" WHERE cust_id = '" + cust.s_cust_id + "'" + 
			" AND calc_values_flag in (1,2) " + 
			" AND filter_usage in (1,2)";

			rs = stmt.executeQuery(sSQL);

		String sAttrID = "";
		String sFilterUsage = "";
		String saveArr = "";
					
		for(int i = 0; rs.next(); i++)
		{
			sAttrID = "";
			sFilterUsage = "";
			saveArr = "";
			
			sAttrID = rs.getString(1);
			sFilterUsage = rs.getString(2);
			
			saveArr = sAttrID + ";" + sFilterUsage;
			%>
			arrValues[<%= String.valueOf(i) %>] = "<%= saveArr %>";
			<%
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn!=null) cp.free(conn); }
	%>
	
	function checkValues(obj, opChange)
	{
		var attrID = obj[obj.selectedIndex].value;
		
		var i = 0;
		var sMatchID = "";
		var sFilterUse = "";
		var sSplit;
		
		var srcElem;
		var formula;
		var valList;
		var opList;
		var val1, val2;
		var opID;
		
		srcElem = event.srcElement;
		formula = getParentByXmlTag(srcElem, 'formula');
		valList = getChildByXmlTag(formula, 'values_list');
		opList = getChildByXmlTag(formula, 'operation_id');
		val1 = getChildByXmlTag(formula, 'value1');
		val2 = getChildByXmlTag(formula, 'value2');
		
		opID = opList[opList.selectedIndex].value;
		
		valList.style.display = "none";
		val1.disabled = false;
		val2.disabled = false;
		val1.style.display = "";
		
		if (opID == "<%= CompareOperation.BETWEEN %>")
		{
			val2.style.display = "";
		}
		
		for (i=0; i < arrValues.length; i++)
		{
			sMatchID = "";
			sFilterUse = "";
			
			sSplit = arrValues[i].split(";");
			sMatchID = sSplit[0];
			sFilterUse = sSplit[1];
			
			if (sMatchID == attrID)
			{
				valList.style.display = "";
				val1.value = "";
				val2.value = "";
				if (sFilterUse == "1")
				{
					val1.disabled = true;
					val2.disabled = true;
					val1.style.display = "none";
					val2.style.display = "none";
				}
			}
		}
	}
	
	var curFormula = null;
	
	function selectValuesList()
	{
		var srcElem;
		var formula;
		var attrList;
		var opList;
		var val1;
		var val2;
		
		var attrID;
		var opID;
		
		srcElem = event.srcElement;
		formula = getParentByXmlTag(srcElem, 'formula');
		attrList = getChildByXmlTag(formula, 'attr_id');
		opList = getChildByXmlTag(formula, 'operation_id');
		val1 = getChildByXmlTag(formula, 'value1');
		val2 = getChildByXmlTag(formula, 'value2');
		
		curFormula = formula;
		
		attrID = attrList[attrList.selectedIndex].value;
		opID = opList[opList.selectedIndex].value;
		
		var sURL = "values_select.jsp?" + 
					"attr_id=" + attrID + 
					"&operation_id=" + opID + 
					"&val1=" + escape(val1.value) + 
					"&val2=" + escape(val2.value);
		
		var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,location=no,status=yes,height=500,width=600';
		window.open(sURL,'FilterSelectValuesWin',window_features);
	} 
	
	function PreviewURL(freshurl)
	{
		var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,location=no,status=yes,height=600,width=400';
		window.open(freshurl,'FilterPreviewWin',window_features);
	}

</SCRIPT>
</HEAD>

<BODY <%= (!can.bWrite || (bWorkflow && iStatusId == FilterStatus.PENDING_APPROVAL) || "-1".equals(filter.s_aprvl_status_flag))?" onload='disable_forms()'":" " %>>
<%
if(can.bWrite)
{
%>
	<div id="tgtgroupactions">
	<table cellpadding="2" cellspacing="0" border="0">
		<tr>
<%
	if((iStatusId != FilterStatus.QUEUED_FOR_PROCESSING) 
		&& (iStatusId != FilterStatus.PROCESSING) 
		&& (iStatusId != FilterStatus.PENDING_APPROVAL) 
		&& !("-1".equals(filter.s_aprvl_status_flag)))
	{
		if (!bWorkflow 
			|| (bWorkflow && can.bApprove) 
			|| (bWorkflow && !can.bApprove && ("0".equals(filter.s_aprvl_status_flag))) 
			|| bIsNewFilter ) {
%>
			<td vAlign="middle" align="left">
				<a class="savebutton" id="tgtsave" href="#" onClick="lazyLoad('tgtsave');filter_save(); return false;">Save</a>
			</td>
     <% } 
		if ( (!bWorkflow
				|| (bWorkflow && can.bApprove) 
				|| (bWorkflow && !can.bApprove && ("0".equals(filter.s_aprvl_status_flag))) 
				|| bIsNewFilter) 
			&& bIsTargetGroup) {
     %>
			<td vAlign="middle" align="left">
				<a class="savebutton" href="#" id="tgtsu" onClick="lazyLoad('tgtsu');filter_save_and_update(); return false;">Save & Update</a>
			</td>
	<%	} 
		if (bWorkflow && !can.bApprove && !bIsNewFilter && bIsTargetGroup) { %>
			<td vAlign="middle" align="left">
				<a class="savebutton" href="#" onClick="RequestApproval()" >Request Approval</a>
			</td>
	<%	} 
		if (bWorkflow && !can.bApprove && !bIsNewFilter && !("0".equals(filter.s_aprvl_status_flag))) { %>
			<td vAlign="middle" align="left">
				<a class="savebutton" href="#" onClick="reset_draft_status()" >Set status back to New & Save</a>
			</td>
	<%	} %>
<%
     }
	
	if (!bIsNewFilter) {
%>
          <td vAlign="middle" align="left">			
               <a class="savebutton" href="#" id="tgtclone" onClick="lazyLoad('tgtclone');filter_clone(); return false;">Clone</a>
          </td>
<%
     if(ui.getUIMode() != ui.SINGLE_CUSTOMER)
     {
%>
               <td vAlign="middle" align="left">
                    <a class=savebutton href="#" onClick="filter_clone2destination(); return false;">Clone to Destination</a>
               </td>
<%
     }
	}

     if (bWorkflow && can.bApprove && isApprover && iStatusId == FilterStatus.PENDING_APPROVAL) {
%>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="workflow_approve()">Approve</a>
		</td>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="workflow_approve_w_comments()">Approve w/ Comments</a>
		</td>
		<td vAlign="middle" align="left">
			<a class="deletebutton" href="#" onclick="workflow_reject()">Reject</a>
		</td>

<%
     }
		
     if (can.bDelete 
	 	&& (sFilterId != null) 
		&& !("-1".equals(filter.s_aprvl_status_flag)))  // only display Delete button if user exists and if this is not a brand new Filter
     {
%>
               <td vAlign="middle" align="left">
                    <a class="deletebutton" id="tgtdelete" href="#" onClick="lazyLoad('tgtdelete');filter_delete(); return false;">Delete</a>
               </td>
<%
     }
%>
			
		</tr>
	</table>
	</div>
	<span id="lazyload"></span>
	<br>
<%
}
%>		

<FORM method="POST" action="" name="filter_form">

<input type="hidden" name="disposition_id" value="0"/>
<input type="hidden" name="object_type" value="<%=String.valueOf(ObjectType.FILTER)%>"/>
<input type="hidden" name="object_id" value="<%=(sFilterId != null)?sFilterId:"0"%>"/>
<input type="hidden" name="usage_type_id" value="<%= (sUsageTypeId!=null)?sUsageTypeId:String.valueOf(FilterUsageType.REGULAR) %>"/>
<INPUT TYPE="hidden" NAME="aprvl_request_id"	value="<%=sAprvlRequestId%>">


<table cellspacing="0" cellpadding="2" border="0" width=750>
<tr>
<td>
<table cellpadding="0" cellspacing="0" class="listTable" width="100%">
	<tr>
		<th colspan=3 class="sectionheader"><B class="sectionheader">Step 1:</B> Name your <%= sTargetGroupDisplay %></th>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td  class="" valign="top" align="center" width="275">
			<table  cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<td nowrap><%= sTargetGroupDisplay %> Name&nbsp;:&nbsp;</td>
					<td nowrap>
						<input type="hidden" name="save_type" value=''>

						<!-- KO: Added for content filters support -->
						<input type="hidden" name="usage_type_id" value="<%=(sUsageTypeId!=null)?sUsageTypeId:""%>">
						<input type="hidden" name="logic_id" value="<%=(sLogicId!=null)?sLogicId:""%>">
						<input type="hidden" name="parent_cont_id" value="<%=(sParentContId!=null)?sParentContId:""%>">
						<!-- --- -->
<% if (filter.s_filter_id !=null ) { %>
							<input type="hidden" name="filter_id" value="<%=filter.s_filter_id%>">
<% } %>
						<input type="text" name="filter_name" size="40" value="<%=(filter.s_filter_name==null)?"New " + sTargetGroupDisplay:filter.s_filter_name%>">
						<%=(sSelectedCategoryId!=null)?"<input type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
						<TEXTAREA name="filter_xml" style="display: none;"></TEXTAREA>					
					</td>
				</tr>
				<tr<%=!canCat.bRead?" style=\"display:none\"":""%>>
					<td nowrap>Categories</td>
					<td nowrap>
						<select multiple name="categories" size="5">
							<%=CategortiesControl.toHtmlOptions(cust.s_cust_id, ObjectType.FILTER, filter.s_filter_id, sSelectedCategoryId)%>
						</select>
					</td>
				</tr>
			</table>
		</td>
		<td valign="top" align="center" width="15">&nbsp;&nbsp;&nbsp;</td>
		<td valign="top" align="center" width="360">
			<table class="listTable" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<th align="center" valign="middle"><%= sTargetGroupDisplay %>:&nbsp;<%= FilterStatus.getDisplayName(iStatusId) %></th>
				</tr>
				<% if (bIsTargetGroup) { %>
				<tr>
					<td valign="top" align="center" style="padding:10px;" width="100%">
					<% if( iStatusId == FilterStatus.NEW ) { %>
						Once you update this Target Group, either by clicking the Save &amp; Update button 
						or clicking the Update link from the main target group list page, 
						relevant information about the status of your target group will appear here.
					<% } else if ( iStatusId == FilterStatus.PENDING_APPROVAL ) { %>
						This Target Group is currently pending approval.
					<% } else if ( iStatusId == FilterStatus.QUEUED_FOR_PROCESSING || iStatusId == FilterStatus.PROCESSING ) { %>
						The Target Group is currently processing. You cannot make changes to it until after processing is completed.
					<% } else if ( iStatusId == FilterStatus.READY ) { %>
						When last updated, this Target Group included 
						<b><%= s_recip_qty %></b> 
						records.<br><br>
						Click the Save &amp; Update button to recalculate the record count.
						<br><br>
					<% if (!("0".equals(s_recip_qty))) { %> 						
						<% if (canTGPreview) { %><a class="resourcebutton" href="#" onclick="PreviewURL('filter_preview.jsp?filter_id=<%= filter.s_filter_id %>');">Preview</a><% } %>
						<% } %>						
						<a class="resourcebutton" href="javascript:showFilterDetails('<%= sFilterId %>', 'stats');">View Calculation Details</a>
					
					<% } else if ( iStatusId == FilterStatus.PROCESSING_ERROR ) { %>
						There was an error while processing the Target Group. 
						<% if (canSupReq) { %>
						Please contact <a href="../index.jsp?tab=Help&sec=4" target="_parent">Technical Support</a> 
						with any questions.
						<% } %>
					<% } %>
					</td>
				</tr>
				<% } %>
			</table>
		</td>
	</tr>
	</tbody>
	
	</table>
<BR>
	<table class="listTable" cellspacing="0" cellpadding="2" width="100%" border="0">
	<tr>
		<th class="sectionheader"><B class="sectionheader">Step 2:</B> Build <%= sTargetGroupDisplay %></th>
	</tr>

	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td valign=top align=center>
			<table cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<td align="left" valign="middle">
						<DIV id='root'><% drawFilter(cust.s_cust_id, sFilterId, out); %></DIV>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	</table>
<BR>
<table class="listTable" cellspacing="0" cellpadding="2" width="100%" border="0">
<DIV name="view_fields"<%= (!canTGPreview || String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))?" style=\"display: 'none'\"":"" %>>

	<tr>
		<th class="sectionheader"><B class="sectionheader">Step 3:</B> Add fields to Preview</th>
	</tr>

	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td  valign=top align=center width=100%>
			<table cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<td align="left" valign="middle">
						<%@ include file="filter_preview_attrs_zaf.inc"%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</DIV>

	
</table>
<BR>
<table class="listTable" cellspacing="0" cellpadding="2" width="100%" border="0">
<tr>
		<th colspan=4 class="sectionheader"><B class="sectionheader">Update History</B></th>
	</tr>
	<tr>
		<td class="CampHeader"><b>Created by</b></td>
		<td><%= HtmlUtil.escape(creator.s_user_name + " " + creator.s_last_name) %></td>
		<td class="CampHeader"><b>Last Modified by</b></td>
		<td><%= HtmlUtil.escape(modifier.s_user_name + " " + modifier.s_last_name) %></td>
	</tr>
	<tr>
		<td class="CampHeader"><b>Creation date</b></td>
		<td><%= HtmlUtil.escape(filter_edit_info.s_create_date) %></td>
		<td class="CampHeader"><b>Last Modify date</b></td>
		<td><%= HtmlUtil.escape(filter_edit_info.s_modify_date) %></td>
	</tr>
</table>
<br><br>
</FORM>

<SCRIPT>Init();</SCRIPT>

<BR>

<DIV style='display: none;'>

<DIV id=formula_prototype>
<%drawFormulaPrototype(cust.s_cust_id, out);%>
</DIV>

<DIV id=group_prototype>
<%drawMultipartFilterPrototype(cust.s_cust_id, out);%>
</DIV>

</BODY>
</HTML>

<%@ include file="filter_functions_zaf.inc"%>
