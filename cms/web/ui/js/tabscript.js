
var b_iFadeTimer;
var curNav;

var b_iInterval;
b_iInterval = 10;

function ShowHide(nav)
{
	curNav = nav;
	
	if (curNav.style.display == 'none')
	{
		ShowMenu();
	}
	else
	{
		HideMenu();
	}

}

function FadeLoop(method, perc, rate)
{
	var moveTo = 0;
	var destFn = "";
	
	if (method == "hide")
	{
		moveTo = (perc - rate);
		
		if (moveTo >= 1)
		{
			destFn = "FadeLoop('hide', " + moveTo + ", " + rate + ")";
	
			FadeMenu(destFn, perc);
		}
		else
		{
			window.clearTimeout(b_iFadeTimer);
			curNav.style.filter = "alpha(opacity=0)";
			curNav.style.display = "none";
		}
	}
	else
	{
		moveTo = (perc + rate);
		
		if (moveTo <= 99)
		{
			destFn = "FadeLoop('show', " + moveTo + ", " + rate + ")";
	
			FadeMenu(destFn, perc);
		}
		else
		{
			window.clearTimeout(b_iFadeTimer);
			curNav.style.filter = "alpha(opacity=100)";
			curNav.style.display = "";
		}
	}
}

function FadeMenu(destFn, perc)
{
	curNav.style.filter = "alpha(opacity=" + perc + ")";
	b_iFadeTimer = window.setTimeout(destFn, b_iInterval);
	curNav.style.display = "";
}

function HideMenu()
{
	FadeLoop("hide", 0, 0);
}

function ShowMenu()
{
	FadeLoop("show", 100, 100);
}

var curTab;

function do_effect(className)
{
	var source = event.srcElement;
	
	while(source.tagName != "TBODY")
	{
		source = source.parentElement;
	}
	
	if ((source.className != "navon") && (source.className != "navheader"))
	{
		source.className = className;
	}
}



function switch_tab(url)
{
	if (curTab.className == "navon")
	{
		curTab.className = "navoff";
	}
	else if (curTab.className == "TopNavOn")
	{
		curTab.className = "TopNavOff";
	}
	
	var tab_switch = event.srcElement;
	
	while(tab_switch.tagName != "TD")
	{
		tab_switch = tab_switch.parentElement;
	}
	
	if ((tab_switch.className != "navon") && (tab_switch.className != "navheader"))
	{
		if (tab_switch.className == "navoff" || tab_switch.className == "navhover")
		{
			tab_switch.className = "navon";
		}
		else if (tab_switch.className == "TopNavOff")
		{
			tab_switch.className = "TopNavOn";
		}
		curTab = tab_switch;
	}
	
	if (url != "" && url != undefined && url != "undefined")
	{
		frame_body.location.href = url;
	}
}


function tab_steps(id, page_id, body_id)
{
	if (id == "" || page_id == "" || body_id == "") return;

	disable_tab(id);

	var tab_page_header = eval(page_id);
	var tab_page_body = eval(body_id);

	tab_page_header.className = "Tab_ON";
	tab_page_body.style.display = "";
}

function disable_tab(id)
{
	var tab = eval(id);

	for (i=0; i < tab.cells.length; i++)
		if (tab.cells(i).className == "Tab_ON")
			tab.cells(i).className = "Tab_OFF";

	for (i=0; i < tab.tBodies.length; i++)
		if (tab.tBodies(i).className == "Edit")
			tab.tBodies(i).style.display = "none";
}


/* 28 June 2011 Zafer Akyel */
function toggleTabs(tabString,tabContentStr,activeTabNum,tabSize,onClass,offClass) {
	for(var i=1;i<tabSize+1;i++) 
	{
		var tabdoc=document.getElementById(tabString+''+i);
		var contdoc=document.getElementById(tabContentStr+''+i);
		
		if(i!=activeTabNum) 
		{
			tabdoc.className=""+offClass;
			contdoc.style.display="none";
		}
		else 
		{
			tabdoc.className=""+onClass;
			contdoc.style.display="";
		}
		
	}
}