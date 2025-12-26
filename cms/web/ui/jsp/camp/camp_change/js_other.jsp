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
