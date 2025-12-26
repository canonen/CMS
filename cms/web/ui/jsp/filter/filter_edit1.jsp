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


boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);



AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sSelectedCategoryId = ui.s_category_id;

String sFilterId = BriteRequest.getParameter(request, "filter_id");

String referer = BriteRequest.getParameter(request, "referer");

String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");
String sLogicId = BriteRequest.getParameter(request, "logic_id");
String sParentContId = BriteRequest.getParameter(request, "parent_cont_id");

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
<link rel="stylesheet" href="/cms/ui/ooo/style1.css" TYPE="text/css">

<SCRIPT>
<%@ include file="filter_zaf1.js"%>

</SCRIPT>

<SCRIPT type="text/javascript">

	function lazyLoad(elem)
	{
		var e = document.getElementById('tgtgroupactions');
		var lazyload = document.getElementById('lazyload');
		lazyload.innerHTML = "<img src='/cms/ui/images/lazyload.gif'>";
		e.style.display = 'none';
	}

</SCRIPT>

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
			var s = document.all[i];

			if((s.id != null) && (s.id == 'formula_prototype')) break;

			if((s.tagName != null) && (s.tagName.toUpperCase() == 'SELECT'))
			{

				if((s.getAttribute('xml_tag')== null) || (s.getAttribute('xml_tag')!='attr_id')||typeof(s.getAttribute('xml_tag')) == "undefined") continue;

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
				if((s.getAttribute('xml_tag')== null) || (s.getAttribute('xml_tag')!='value1')||typeof(s.getAttribute('xml_tag')) == "undefined")continue;

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
        console.log(build_xml(),"build xml");
		<% if (referer==null){%>
		//filter_form.action = "filter_save.jsp";
		console.log(filter_form);
		<%}else{%>
		filter_form.action = "filter_save_webpush.jsp";
		<%}%>
		//filter_form.submit();


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

          <% if (referer!=null){%>
          filter_form.referer.value = 'webpush';
          <%}%>
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

	function checkValuesOperation(obj, opChange,id)
	{
		alert(id);
		obj[obj.id].setAttribute("selected", "selected");
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
	function checkValues(obj, opChange)
	{
		var attrID = obj[obj.selectedIndex].value;
		obj[obj.selectedIndex].setAttribute("selected", "selected");
		var i = 0;
		var sMatchID = "";
		var sFilterUse = "";
		var sSplit;

		var srcElem;
		var formula;
		var valList;
		var opList;
		var webFormulaOpList;
		var webFormulaTimeOpList;
		var time_val1, time_val2;
		var val1, val2;
		var opID;
		var typeId;

		srcElem = event.srcElement;
		var parentElem = getParentByXmlTag(srcElem, 'filter');
		var formulaType = getChildByXmlTag(parentElem, 'type_id');
		formula = getParentByXmlTag(srcElem, 'formula');
		valList = getChildByXmlTag(formula, 'values_list');
		opList = getChildByXmlTag(formula, 'operation_id');
		webFormulaOpList = getChildByXmlTag(formula, 'web_formula_operation_id');
		webFormulaTimeOpList = getChildByXmlTag(formula, 'web_formula_time_operation_id');
		time_val1 = getChildByXmlTag(formula, 'time_value1');
		time_val2 = getChildByXmlTag(formula, 'time_value2');
		val1 = getChildByXmlTag(formula, 'value1');
		val2 = getChildByXmlTag(formula, 'value2');
		typeId = getChildByXmlTag(formula, 'type_id');

		if(obj[obj.selectedIndex].getAttribute('custom_formula_type')) {
			typeId.value = obj[obj.selectedIndex].getAttribute('custom_formula_type');
			webFormulaOpList.parentElement.style.display = '';
			webFormulaTimeOpList.parentElement.style.display = '';
			if(webFormulaTimeOpList.value>10)time_val1.parentElement.style.display = '';
			if(webFormulaTimeOpList.value==30)time_val2.parentElement.style.display = '';
			formulaType.value = 101;
		} else {
			typeId.value = 0;
			webFormulaOpList.parentElement.style.display = 'none';
			webFormulaTimeOpList.parentElement.style.display = 'none';
			time_val1.parentElement.style.display = 'none';
			time_val2.parentElement.style.display = 'none';
			formulaType.value = 100;
		}

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
				<button class="savebutton" id="tgtsave"  onClick="filter_save(); return false;" >Save</button>
			</td>
     <% }
		if ( (!bWorkflow
				|| (bWorkflow && can.bApprove)
				|| (bWorkflow && !can.bApprove && ("0".equals(filter.s_aprvl_status_flag)))
				|| bIsNewFilter)
			&& bIsTargetGroup) {
     %>
			<td vAlign="middle" align="left">
				<a class="savebutton" href="#" id="tgtsu" onClick="filter_save_and_update(); return false;">Save & Update</a>
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
               <a class="savebutton" href="#" onClick="filter_clone(); return false;">Clone</a>
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
						<input type="hidden" name="referer" value=''>

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

<SCRIPT>
var selectList = Array.from(document.querySelectorAll('.formula select[xml_tag=attr_id]'));

selectList.forEach(select => {

	var selectedIndex = select.selectedIndex;

	var groups = {};

	Array.from(select.children).forEach((option,i) => {
		if(i==0)return;
	    var formulaType = option.getAttribute('custom_formula_type');
	    if(!formulaType)formulaType = 0;
		if(formulaType==0 && !groups[formulaType]) {
			var group = document.createElement('optgroup');
			group.label = 'Email Attribute';
			groups[formulaType] = group;
		}
		if(formulaType==1 && !groups[formulaType]) {
			var group = document.createElement('optgroup');
			group.label = 'Purchase History';
			groups[formulaType] = group;
		}
		if(formulaType==2 && !groups[formulaType]) {
			var group = document.createElement('optgroup');
			group.label = 'Link Activity';
			groups[formulaType] = group;
		}
		if(formulaType==3 && !groups[formulaType]) {
			var group = document.createElement('optgroup');
			group.label = 'Cart Activity';
			groups[formulaType] = group;
		}
		if(formulaType==4 && !groups[formulaType]) {
			var group = document.createElement('optgroup');
			group.label = 'Search Activity';
			groups[formulaType] = group;
		}

		if(formulaType==5 && !groups[formulaType]) {
			var group = document.createElement('optgroup');
			group.label = 'Store Purchase';
			groups[formulaType] = group;
		}

		groups[formulaType].appendChild(option);
	});

	Object.values(groups).forEach(group => {
		select.appendChild(group);
	});

	select.selectedIndex = selectedIndex;

});




</SCRIPT>
</BODY>
</HTML>


<%!

private static void drawFilter(String sCustId, String sFilterId, JspWriter out) throws Exception
{
	com.britemoon.cps.tgt.Filter fi = null;
	if(sFilterId != null)
	{
		fi = new com.britemoon.cps.tgt.Filter();
		fi.s_filter_id = sFilterId;
		if(fi.retrieve() < 1) return;
	}
	else
	{
		fi = getMultipartFilterPrototype(sCustId);
	}

	fi.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
	drawFilterGeneric(fi, out);
}

private static void drawFilterParts(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{

//boolean bSTANDARD_UI = (com.britemoon.cps.UIEnvironment.n_ui_type_id == com.britemoon.cps.UIType.STANDARD);


//com.britemoon.cps.tgt.Filter fi = new com.britemoon.cps.tgt.Filter();

//out.println("zzz" +bSTANDARD_UI);

//String sDebug =
//	" drawFilterParts():\t" +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

out.println("<!-- FILTER PARTS START -->");

// === === ===

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=0 class=filter_parts>");

out.println("	<tr>");
out.println("		<td>");
out.println("			<table cellspacing=0 cellpadding=4 border=0>");
out.println("				<tr>");
out.println("					<td align=left valign=middle>");
out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_part_add_formula(event);'>Add Field Filter</a>");
out.println("					</td>");


//if(com.britemoon.UIType.STANDARD == 200){

	out.println("					<td align=left valign=middle>");
	out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_part_select_filter(event);'>Select Advanced Filter</a>");
	out.println("					</td>");


	out.println("					<td align=left valign=middle>");
	out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_group(this,event);'>Group Items</a>");
	out.println("					</td>");
	out.println("					<td align=left valign=middle>");
	out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_ungroup(event);'>Ungroup Items</a>");
	out.println("					</td>");
	out.println("					<td align=left valign=middle>");
	out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_inex(this,event);'>Include/Exclude</a>");
	out.println("					</td>");
//}
out.println("				</tr>");
out.println("			</table>");
out.println("		</td>");
out.println("	</tr>");

out.println("	<tr>");
out.println("		<td xml_tag=filter_parts>");

// === === ===

drawFilterParts(null, filter, out);

// === === ===

out.println("		</td>");
out.println("	</tr>");
out.println("</table>");

// === === ===

out.println("<!-- FILTER PARTS END -->");

}

private static void drawFilterParts(String sWrappingBooleanOperation, com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawFilterParts():\t" +
//	" sWrappingBooleanOperation = " + sWrappingBooleanOperation +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

	FilterParts filter_parts = filter.m_FilterParts;

	if(filter_parts == null)
	{
		filter_parts = new FilterParts();
		if(filter.s_filter_id != null)
		{
			filter_parts.s_parent_filter_id = filter.s_filter_id;
			filter_parts.retrieve();
		}
		filter.m_FilterParts = filter_parts;
	}

	FilterPart filter_part = null;
	for (Enumeration e = filter_parts.elements() ; e.hasMoreElements() ;)
	{
		filter_part = (FilterPart) e.nextElement();
		drawFilterPart(sWrappingBooleanOperation, filter_part, out);
	}
}

private static void drawFilterPart(String sWrappingBooleanOperation, FilterPart filter_part, JspWriter out) throws Exception
{
//String sDebug =
//	" drawFilterPart():\t" +
//	" sWrappingBooleanOperation = " + sWrappingBooleanOperation +
//	" child_filter_id = " + filter_part.s_child_filter_id;
//System.out.println(sDebug);
//System.out.flush();

	com.britemoon.cps.tgt.Filter child_filter = filter_part.m_ChildFilter;
	if( child_filter == null )
	{
		child_filter = new com.britemoon.cps.tgt.Filter();
		if(filter_part.s_child_filter_id != null )
		{
			child_filter.s_filter_id = filter_part.s_child_filter_id;
			child_filter.retrieve();
		}
		filter_part.m_ChildFilter = child_filter;
	}

	if(sWrappingBooleanOperation != null)
	{
		drawFilterPart(sWrappingBooleanOperation, child_filter, out);
		return;
	}

	String sBooleanOperation = getBooleanOperation(child_filter);
	if("NOT".equals(sBooleanOperation)) // ||  "NOP".equals(sBooleanOperation))
	{
		drawFilterParts(sBooleanOperation, child_filter, out);
		return;
	}

	drawFilterPart("NOP", child_filter, out);
}

private static void drawFilterPart(String sWrappingBooleanOperation, com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawFilterPart():\t" +
//	" sWrappingBooleanOperation = " + sWrappingBooleanOperation +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

out.println("<!-- FILTER PART START -->");

// === === ===

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=2 class=filter_part xml_tag=filter_part>");
out.println("	<tr>");

// === === ===

out.println("		<td>");
out.println("<table border=0 width='100%' cellspacing=0 cellpadding=1 class=filter_part_capsule>");
out.println("	<tr>");

// === === ===

out.println("		<td width=1>");
out.println("			<input onchange=\"if(this.checked){this.setAttribute('checked','checked');}else{this.removeAttribute('checked');}\" type=checkbox xml_tag=group_ungroup_checkbox>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<INPUT type=hidden xml_tag=child_filter_id value='" + filter.s_filter_id + "'>");
out.println(" 			<select size=1 xml_tag=boolean_operation style='display:none;'>");
out.println("				<option value=NOP></option>");
out.println("				<option value=NOT" + ("NOT".equals(sWrappingBooleanOperation)?" selected":"") + ">NOT</option>");
out.println("			</select>");
out.println("			<span xml_tag=boolean_text>" + ("NOT".equals(sWrappingBooleanOperation)?"Exclude: ":"") + "</span>");
out.println("		</td>");

// === === ===

	int nTypeId = Integer.parseInt(filter.s_type_id);

	if(filter.s_usage_type_id == null) filter.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
	int nUsageTypeId = Integer.parseInt(filter.s_usage_type_id);

	if((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
	{
		drawMultipartFilterPart(filter, out);
	}
	else
	{
		drawSimpleFilterPart(filter, out);
	}

// === === ===

out.println("	</tr>");
out.println("</table>");
out.println("		</td>");

// === === ===

out.println("	</tr>");
out.println("</table>");

// === === ===

out.println("<!-- FILTER PART END -->");

}

private static void drawSimpleFilterPart(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawSimpleFilterPart():\t" +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

out.println("		<td>");

drawFilterGeneric(filter, out);

out.println("		</td>");
out.println("		<td width=1 align=right>");
out.println("<table border=0 width=1 align=right>");
out.println("	<tr>");
out.println("		<td class=filter_part_control onclick='filter_part_delete(this,event);'>");
out.println("			&nbsp;X&nbsp;");
out.println("		</td>");
out.println("	</tr>");
out.println("</table>");
out.println("		</td>");
}

private static void drawMultipartFilterPart(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawMultipartFilterPart():\t" +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

String sPartName = null;
if(filter.s_filter_name!=null) sPartName = filter.s_filter_name;
else if(filter.s_filter_id!=null) sPartName = "(" + filter.s_filter_id + ")";

out.println("		<td align=left>");
//out.println("			&nbsp;Subgroup:&nbsp;<INPUT type=text size=75 value='" + HtmlUtil.escape(sPartName) + "' onchange='filter_name_set(this);'>");
out.println("			&nbsp;Subgroup:&nbsp;" + HtmlUtil.escape(sPartName));
out.println("		</td>");
out.println("		<td align=right>");
out.println("<table border=0 width=1 align=right>");
out.println("	<tr>");
out.println("		<td class=filter_part_control onclick='filter_part_min_max(this,event);'>");
out.println("			&nbsp;_&nbsp;");
out.println("		</td>");
out.println("		<td class=filter_part_control onclick='filter_part_delete(this,event);'>");
out.println("			&nbsp;X&nbsp;");
out.println("		</td>");
out.println("	</tr>");
out.println("</table>");
out.println("		</td>");

out.println("	</tr>");

out.println("	<tr>");
out.println("		<td>&nbsp;</td>");
out.println("		<td colspan=3>");
			drawFilterGeneric(filter, out);
out.println("		</td>");
}

// === === ===

private static void drawFilterGeneric(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawFilterGeneric():\t" +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

out.println("<!-- FILTER GENERIC START -->");

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=0 class=filter_generic>");
out.println("	<tr>");

// === === ===

	int nTypeId = Integer.parseInt(filter.s_type_id);

	if(filter.s_usage_type_id == null) filter.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
	int nUsageTypeId = Integer.parseInt(filter.s_usage_type_id);

	if	(
			((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
			||
			(nTypeId == FilterType.FORMULA)
			||
			(nTypeId == FilterType.CUSTOM_FORMULA)
		)
	{
out.println("		<td xml_tag=filter>");
out.println("<input type=hidden xml_tag=filter_id value='" + HtmlUtil.escape(filter.s_filter_id) + "'>");
out.println("<input type=hidden xml_tag=filter_name value='" + HtmlUtil.escape(filter.s_filter_name) + "'>");
out.println("<input type=hidden xml_tag=type_id value='" + HtmlUtil.escape(filter.s_type_id) + "'>");
out.println("<input type=hidden xml_tag=cust_id value='" + HtmlUtil.escape(filter.s_cust_id) + "'>");
out.println("<input type=hidden xml_tag=status_id value='" + HtmlUtil.escape(filter.s_status_id) + "'>");
out.println("<input type=hidden xml_tag=origin_filter_id value='" + HtmlUtil.escape(filter.s_origin_filter_id) + "'>");
out.println("<input type=hidden xml_tag=usage_type_id value='" + HtmlUtil.escape(filter.s_usage_type_id) + "'>");
	}
	else
	{
out.println("		<td>");
	}

// === === ===

	if(nTypeId == FilterType.FORMULA || nTypeId == FilterType.CUSTOM_FORMULA)
		drawFormula(filter, out);
	else
		if((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
			drawMultipartFilter(filter, out);
	else
		drawSimpleFilter(filter, out);

// === === ===

out.println("		</td>");
out.println("	</tr>");
out.println("</table>");

out.println("<!-- FILTER GENERIC END -->");
}


private static void drawMultipartFilter(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawMultipartFilter():\t" +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

	String sBooleanOperation = getBooleanOperation(filter);

out.println("<!-- MULTIPART AND-OR FILTER START -->");

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=0 class=filter_multipart>");

//out.println("	<tr>");
//out.println("		<td align=center width=1>");
//out.println("		</td>");
//out.println("		<td>");
//out.println("			<table cellspacing=0 cellpadding=4 border=0>");
//out.println("				<tr>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_part_add_formula();'>Add Field Filter</a>");
//out.println("					</td>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_part_select_filter();'>Select Advanced Filter</a>");
//out.println("					</td>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_group();'>Group Items</a>");
//out.println("					</td>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_ungroup();'>Ungroup Items</a>");
//out.println("					</td>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_inex();'>Include/Exclude</a>");
//out.println("					</td>");
//out.println("				</tr>");
//out.println("			</table>");
//out.println("		</td>");
//out.println("	</tr>");

out.println("	<tr>");
out.println("		<td align=center valign=middle height=100% width=60>");
out.println("			<table border=0 height=100% cellpadding=0 cellspacing=0>");
out.println("				<tr>");
out.println("					<td style='padding:0px;' width=60 valign=bottom><img src=\"../../images/tgroup-upperbend.gif\"></td>");
out.println("				</tr>");
out.println("				<tr>");
out.println("					<td style='padding:0px;' height=100% background=\"../../images/tgroup-vertical.gif\">");
out.println(" 			<select size=1 xml_tag=boolean_operation>");
out.println("				<option value=NOP" + ("NOP".equals(sBooleanOperation)?" selected":"") + "></option>");
out.println("				<option value=OR" + ("OR".equals(sBooleanOperation)?" selected":"") + ">OR</option>");
out.println("				<option value=AND" + ("AND".equals(sBooleanOperation)?" selected":"") + ">AND</option>");
out.println("			</select>");
out.println("					</td>");
out.println("				</tr>");
out.println("				<tr>");
out.println("					<td style='padding:0px;' width=60 valign=top><img src=\"../../images/tgroup-lowerbend.gif\"></td>");
out.println("				</tr>");
out.println("			</table>");
out.println("		</td>");
out.println("		<td valign=middle align=left>");

	drawFilterParts(filter, out);

out.println("		</td>");
out.println("	</tr>");

out.println("</table>");

// === === ===

out.println("<!-- MULTIPART AND-OR FILTER END -->");
}

private static void drawFormula(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
out.println("<!-- FORMULA START -->");

// === === ===

	Formula formula = filter.m_Formula;
	CustomFormula customFormula = filter.m_CustomFormula;

	if( formula == null )
	{
		formula = new Formula();
		if(filter.s_filter_id != null)
		{
			formula.s_filter_id = filter.s_filter_id;
			formula.retrieve();
		}
		filter.m_Formula = formula;
	}

	if( customFormula == null )
	{
		customFormula = new CustomFormula();
		if(filter.s_filter_id != null)
		{
			customFormula.s_filter_id = filter.s_filter_id;
			customFormula.retrieve();
		}
		filter.m_CustomFormula = customFormula;
	}

	String disableValues = "";
	String showSelVals = " style='display:none'";

	AttrCalcProps acp = null;
	acp = new AttrCalcProps(filter.s_cust_id, formula.s_attr_id);

	String sFilterUse = acp.s_filter_usage;
	String sCalcValsFlag = acp.s_calc_values_flag;

	if (("1".equals(sFilterUse) || "2".equals(sFilterUse)) && ("1".equals(sCalcValsFlag) || "2".equals(sCalcValsFlag)))
	{
		showSelVals = "";

		if ("1".equals(sFilterUse))
		{
			disableValues = " disabled";
		}
	}



// === === ===

out.println("<table border=0 cellspacing=0 cellpadding=2 class=formula xml_tag=formula>");
out.println("	<tr>");
out.println("		<td width=1>");
out.println("			&nbsp;&nbsp;");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<input type=hidden value=" + formula.s_filter_id + " xml_tag=formula_id>");
out.println("			<select size=1 id=rmzn_select xml_tag=attr_id onchange='checkValues(this, false)'>");
out.println("				<option></option>");

CustAttrs formula_attrs = CustAttrsUtil.retrieve4filter(filter.s_cust_id, filter.s_filter_id);
out.println(CustAttrsUtil.toHtmlOptions(formula_attrs, formula.s_attr_id, customFormula.s_attr_id, customFormula.s_type_id, true));

int nTypeId = Integer.parseInt(filter.s_type_id);
boolean isCustom = nTypeId == FilterType.CUSTOM_FORMULA;

boolean bShowValue2 = false;
if(isCustom) {
	bShowValue2 = (String.valueOf(CompareOperation.BETWEEN).equals(customFormula.s_operation_id));
} else {
	bShowValue2 = (String.valueOf(CompareOperation.BETWEEN).equals(formula.s_operation_id));
}

String operationId = isCustom ? customFormula.s_operation_id : formula.s_operation_id;
String positiveFlag = isCustom ? customFormula.s_positive_flag: formula.s_positive_flag;
String webFormulaOperationId = isCustom ? customFormula.s_web_formula_operation_id : "";
String webFormulaTimeOperationId = isCustom ? customFormula.s_web_formula_time_operation_id : "";
String value1 = isCustom ? customFormula.s_value1 : formula.s_value1;
String value2 = isCustom ? customFormula.s_value2 : formula.s_value2;
String time_value1 = isCustom ? customFormula.s_time_value1 : "";
String time_value2 = isCustom ? customFormula.s_time_value2 : "";

out.println("			</select>");
out.println("		</td>");
out.println("		<td style='display:none;' width=1>");
out.println("			<input type=hidden size=1 xml_tag=type_id value='"+(isCustom ? customFormula.s_type_id : 0)+"'>");
out.println("		</td>");
out.println("		<td width=1 " + (!isCustom ? "style='display:none;'":"") + ">");
out.println("			<select size=1 xml_tag=web_formula_time_operation_id onchange='doTimeOperationChange(this)'>");
out.println("				<option value=10 " + ((isCustom && webFormulaTimeOperationId!=null && webFormulaTimeOperationId.equals("10")) ? "selected" : "") +">All Time</option>");
out.println("				<option value=20 " + (isCustom && webFormulaTimeOperationId!=null && webFormulaTimeOperationId.equals("20") ? "selected" : "") +">Last Days</option>");
out.println("				<option value=30 " + (isCustom && webFormulaTimeOperationId!=null && webFormulaTimeOperationId.equals("30") ? "selected" : "") +">Time Period</option>");
out.println("			</select>");
out.println("		</td>");
out.println("		<td width=1 " + ((isCustom && (webFormulaTimeOperationId!=null && !webFormulaTimeOperationId.equals("10"))) ? "":"style='display:none;'") + ">");
out.println("			<input type=text  onchange='input_rmzn(this,this.value)' xml_tag=time_value1 value='" + HtmlUtil.escape(time_value1) +"' size=15 maxlength=255>");
out.println("		</td>");
out.println("		<td width=1 " + ((isCustom && (webFormulaTimeOperationId!=null && webFormulaTimeOperationId.equals("30"))) ? "":"style='display:none;'") + ">");
out.println("			<input type=text onchange='input_rmzn(this,this.value)' xml_tag=time_value2 value='" + HtmlUtil.escape(time_value2) +"' size=15 maxlength=255>");
out.println("		</td>");
out.println("		<td width=1 " + (!isCustom ? "style='display:none;'":"") + ">");
out.println("			<select size=1 xml_tag=web_formula_operation_id>");
out.println("				<option value=10 " + (isCustom && webFormulaOperationId.equals("10") ? "selected" : "") +">Value</option>");
out.println("				<option value=20 " + (isCustom && webFormulaOperationId.equals("20") ? "selected" : "") +">Total</option>");
out.println("				<option value=30 " + (isCustom && webFormulaOperationId.equals("30") ? "selected" : "") +">Count</option>");
out.println("				<option value=40 " + (isCustom && webFormulaOperationId.equals("40") ? "selected" : "") +">Average</option>");
out.println("			</select>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<select size=1 xml_tag=positive_flag onchange='doOperationChange2(this)'>");
out.println("				<option value=1>IS</option>");
out.println("				<option value=-1" + (("-1".equals(positiveFlag))?" selected":"") + ">IS NOT</option>");
out.println("			</select>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<select size=1 xml_tag=operation_id onchange='doOperationChange(this)'>");
out.println("					" + CompareOperation.toHtmlOptions(operationId));
out.println("			</select>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<input type=text  onchange='input_rmzn(this,this.value)' xml_tag=value1 value='" + HtmlUtil.escape(value1) +"' size=30 maxlength=255" + disableValues + ">");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<input type=text onchange='input_rmzn(this,this.value)' xml_tag=value2 value='" + HtmlUtil.escape(value2) +"' size=30 maxlength=255" + disableValues + ""  + ((bShowValue2)?"":" style='display: none'") + ">");
out.println("		</td>");
out.println("		<td width=1 xml_tag=values_list" + showSelVals + " nowrap>");
out.println("			<nobr>&nbsp;<a class=subactionbutton href=# onclick='selectValuesList();'>Select Values</a>&nbsp;</nobr>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			&nbsp;&nbsp;");
out.println("		</td>");
out.println("	</tr>");
out.println("</table>");

// === === ===

out.println("<!-- FORMULA END -->");
}

private static void drawSimpleFilter(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
out.println("<!-- SIMPLE FILTER START -->");

// === === ===

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=0 class=filter_simple>");
out.println("	<tr>");
out.println("		<td nowrap>");
out.println("			" + HtmlUtil.escape(filter.s_filter_name));
out.println("		</td>");
out.println("		<td width=1>");

	int nTypeId = 0;
	if(filter.s_type_id != null) nTypeId = Integer.parseInt(filter.s_type_id);
	if((nTypeId < 31) || (nTypeId > 59)) // 31-50 - filters from reports, not editable
	{
out.println("			<table border=0 cellspacing=0 cellpadding=0 class=menu>");
out.println("				<tr>");
out.println("					<td align=center nowrap>");
out.println("						&nbsp;<a class=savebutton href='javascript:void(0);' onclick='filter_part_edit(event);'>Edit</a>&nbsp;");
out.println("					</td>");
out.println("				</tr>");
out.println("			</table>");
	}

out.println("		</td>");
out.println("	</tr>");
out.println("</table>");

// === === ===

out.println("<!-- SIMPLE FILTER END -->");

}

// === === ===

private static String getBooleanOperation(com.britemoon.cps.tgt.Filter filter) throws Exception
{
	String sBooleanOperation = null;

	if(Integer.parseInt(filter.s_type_id) != FilterType.MULTIPART)
		return sBooleanOperation;

	FilterParams fps = filter.m_FilterParams;
	if( fps == null )
	{
		fps = new FilterParams();
		if(filter.s_filter_id != null)
		{
			fps.s_filter_id = filter.s_filter_id;
			fps.retrieve();
		}
		filter.m_FilterParams = fps;
	}

	sBooleanOperation = fps.getStringValue("BOOLEAN OPERATION");
	if(sBooleanOperation == null) sBooleanOperation = "NOP";
	return sBooleanOperation;
}

// === === ===

private static com.britemoon.cps.tgt.Filter getFormulaPrototype(String sCustId) throws Exception
{
	Formula fo = new Formula();

	// === === ===

	com.britemoon.cps.tgt.Filter fi = new com.britemoon.cps.tgt.Filter();

	fi.s_filter_id = null;
	fi.s_filter_name = null;
	fi.s_type_id = String.valueOf(FilterType.FORMULA);
	fi.s_cust_id = sCustId;
	fi.s_status_id = String.valueOf(FilterStatus.NEW);
	fi.s_origin_filter_id = null;
	fi.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);

	fi.m_Formula = fo;

	// === === ===

	return fi;
}

private static com.britemoon.cps.tgt.Filter getMultipartFilterPrototype(String sCustId) throws Exception
{
	FilterParam fp = new FilterParam();

	fp.s_param_name = "BOOLEAN OPERATION";
	fp.s_string_value = "NOP";

	// === === ===

	FilterParams fps = new FilterParams();
	fps.add(fp);

	// === === ===

	com.britemoon.cps.tgt.Filter fi = new com.britemoon.cps.tgt.Filter();

	fi.s_filter_id = null;
	fi.s_filter_name = null;
	fi.s_type_id = String.valueOf(FilterType.MULTIPART);
	fi.s_cust_id = sCustId;
	fi.s_status_id = String.valueOf(FilterStatus.NEW);
	fi.s_origin_filter_id = null;
	fi.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);

	fi.m_FilterParams = fps;

	// === === ===

	return fi;
}

private static void drawFormulaPrototype(String sCustId, JspWriter out) throws Exception
{
	drawFilterPart("NOP", getFormulaPrototype(sCustId), out);
}

private static void drawMultipartFilterPrototype(String sCustId, JspWriter out) throws Exception
{
	drawFilterPart("NOP", getMultipartFilterPrototype(sCustId), out);
}

%>

