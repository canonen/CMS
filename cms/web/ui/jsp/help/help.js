function on(o)
{
	//o.runtimeStyle.color = "#0000ff";
}
function off(o)
{
	o.runtimeStyle.color = "";
}
function expand(o)
{
	if (o.nextSibling.style.display == "none")
	{
		o.firstChild.src = "../imgs/d.gif";
		o.nextSibling.style.display = "inline";
		//o.style.color = "#0000ff";
	}
	else
	{
		o.firstChild.src = "../imgs/r.gif";
		o.nextSibling.style.display = "none";
		//o.style.color = "#000000";
	}
}

function document.oncontextmenu()
{
	var s = event.srcElement.tagName;
	
	if (s && s != "INPUT" || event.srcElement.disabled || document.selection.createRange().text.length == 0)
	{
		//event.returnValue = false;
	}
}
