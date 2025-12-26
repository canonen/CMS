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

function checkFrom(obj1, i)
{
	var fa1 = eval ('FT.fa1' + i);
	var fa2 = eval ('FT.fa2' + i);
	fa1.checked = false;
	fa2.checked = false;
	obj1.checked = true;
}

function workflow_approve(sRequestId) {
     FT.action = "../workflow/approval_send.jsp"
     FT.aprvl_request_id.value = sRequestId
     FT.disposition_id.value = "10"     // approve
     FT.submit()
}

function workflow_reject(sRequestId) {
     FT.action = "../workflow/approval_edit.jsp"
     FT.aprvl_request_id.value = sRequestId
     FT.disposition_id.value = "90"     // reject
     FT.submit()
}

function workflow_approve_w_comments(sRequestId) {
     FT.action = "../workflow/approval_edit.jsp"
     FT.aprvl_request_id.value = sRequestId
     FT.disposition_id.value = "10"     // approve
     FT.submit()
}

function addBriteTrack()
{
	if (FT.link_append_text.value.indexOf('&BrCs=<%=cust.s_cust_id%>&BrCg=!*CampaignID;*!&BrRc=!*RecipID;*!&BrKy=!*recip_key;*!')>-1) return;
	FT.link_append_text.value += '&BrCs=<%=cust.s_cust_id%>&BrCg=!*CampaignID;*!&BrRc=!*RecipID;*!&BrKy=!*recip_key;*!';
}

function checkDynamic(i)
{
	if (i == 0) i = '';
	if (document.getElementById("dynamicExtra" + i) == null) return;
	var fl = eval ('FT.test_list_id' + i);
	if (fl[fl.selectedIndex].text.indexOf("Dynamic Content Test list") > -1)
		document.all.item("dynamicExtra" + i).style.display = "";
	else
		document.all.item("dynamicExtra" + i).style.display = "none";

}

var ll = FT.camp_qty.value;
for(var ii=0; ii <= ll; ii++)
{
	checkDynamic(ii);
}

var _oPop;

function showCampDetails(camp_id, action)
{
	_oPop = window.open("camp_stat_details.jsp?a=" + action + "&camp_id=" + camp_id, "CampDetails", "resizable=yes, directories=0, location=0, menubar=0, scrollbars=1, status=0, toolbar=0, height=350, width=450");
}

