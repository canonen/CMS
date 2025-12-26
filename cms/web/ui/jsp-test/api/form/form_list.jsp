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
<%@ include file="../../utilities/validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
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

//Sinan Celik 2018-08-18
String referer = BriteRequest.getParameter(request, "referer");

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
		<% if (referer==null){%>
		filter_form.action = "filter_save.jsp";
		<%}else{%>
		filter_form.action = "filter_save_webpush.jsp";
		<%}%>
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

          if (referer!=null){
          filter_form.referer.value = 'webpush';
          }
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

			arrValues[<%= String.valueOf(i) %>] = "<%= saveArr %>";

		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn!=null) cp.free(conn); }


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


if(can.bWrite)
{

	if((iStatusId != FilterStatus.QUEUED_FOR_PROCESSING)
		&& (iStatusId != FilterStatus.PROCESSING)
		&& (iStatusId != FilterStatus.PENDING_APPROVAL)
		&& !("-1".equals(filter.s_aprvl_status_flag)))
	{
		if (!bWorkflow
			|| (bWorkflow && can.bApprove)
			|| (bWorkflow && !can.bApprove && ("0".equals(filter.s_aprvl_status_flag)))
			|| bIsNewFilter ) {


    }
		if ( (!bWorkflow
				|| (bWorkflow && can.bApprove)
				|| (bWorkflow && !can.bApprove && ("0".equals(filter.s_aprvl_status_flag)))
				|| bIsNewFilter)
			&& bIsTargetGroup) {


		}
		if (bWorkflow && !can.bApprove && !bIsNewFilter && bIsTargetGroup) { %>

	}
		if (bWorkflow && !can.bApprove && !bIsNewFilter && !("0".equals(filter.s_aprvl_status_flag))) { %>

	}

     }

	if (!bIsNewFilter) {

     if(ui.getUIMode() != ui.SINGLE_CUSTOMER)
     {

     }
	}

     if (bWorkflow && can.bApprove && isApprover && iStatusId == FilterStatus.PENDING_APPROVAL) {

     }

     if (can.bDelete
	 	&& (sFilterId != null)
		&& !("-1".equals(filter.s_aprvl_status_flag)))  // only display Delete button if user exists and if this is not a brand new Filter
     {

     }

}

    String a = "<tbody class=EditBlock id=block2_Step1>"+
	"<tr>"+
		"<td valign=top align=center>"+
			"<table cellspacing=0 cellpadding=2 width="100%">"+
				"<tr>"+
					"<td align="left" valign="middle">"+
						"<DIV id='root'><% drawFilter(cust.s_cust_id, sFilterId, out); %></DIV>"+
					"</td>"+
				"</tr>"+
			"</table>"+
		"</td>"+
	"</tr>"+
	"</tbody>"+

	out.print(a);


<script>
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
		groups[formulaType].appendChild(option);
	});

	Object.values(groups).forEach(group => {
		select.appendChild(group);
	});

	select.selectedIndex = selectedIndex;

});

</script>
%>


