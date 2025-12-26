function setFormFlag(obj, value)
{
	FT.fr1.checked = false;
	FT.fr2.checked = false;
	obj.checked = true;
	FT.form_flag.value = value;
}

function disable_forms()
{
	var l = document.forms.length;
	for(var i=0; i < l; i++)
	{
		document.forms[i].action = null;
		var m = document.forms[i].elements.length;
		for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = true;
	}
}

function openexplanation()
{
	var popurl="../email_list/list_explanation.jsp?typeID=2"
	winpops=window.open(popurl,"","width=400,height=300,")
}

function checkFrom(obj1)
{
	FT.fa1.checked = false;
	FT.fa2.checked = false;

	obj1.checked = true;

}

function workflow_approve() {
     FT.action = "../workflow/approval_send.jsp"
     FT.disposition_id.value = "10"     // approve
     FT.submit()
}

function workflow_reject() {
     FT.action = "../workflow/approval_edit.jsp"
     FT.disposition_id.value = "90"     // reject
     FT.submit()
}

function workflow_approve_w_comments() {
     FT.action = "../workflow/approval_edit.jsp"
     FT.disposition_id.value = "10"     // approve
     FT.submit()
}

function workflow_edit() {
     FT.action = "../workflow/approval_send.jsp"
     FT.disposition_id.value = "50"     // approve
     FT.submit()
}

function addBriteTrack()
{
	if (FT.link_append_text.value.indexOf('&BrCs=<%=cust.s_cust_id%>&BrCg=!*CampaignID;*!&BrRc=!*RecipID;*!')>-1) return;
	FT.link_append_text.value += '&BrCs=<%=cust.s_cust_id%>&BrCg=!*CampaignID;*!&BrRc=!*RecipID;*!';
}

var _oPop;

function showCampDetails(camp_id, action)
{
	_oPop = window.open("camp_stat_details.jsp?a=" + action + "&camp_id=" + camp_id, "CampDetails", "resizable=yes, directories=0, location=0, menubar=0, scrollbars=1, status=0, toolbar=0, height=350, width=450");
}

function checkDynamic()
{
	if (document.getElementById("dynamicExtra") == null) return;
	if (FT.test_list_id[FT.test_list_id.selectedIndex].text.indexOf("Dynamic Content Test list") > -1)
		document.getElementById("dynamicExtra").style.display = "";
	else
		document.getElementById("dynamicExtra").style.display = "none";

}

checkDynamic();

function showNowAlert()
{
	<% if (isHyatt) { %>
	var chk = document.getElementById("start_date_switch_now");
	var obj = document.getElementById("nowAlert");
	if (chk.checked == true)
	{
		obj.style.display = "";
	}
	else
	{
		obj.style.display = "none";
	}
	<% } %>
}