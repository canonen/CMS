
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

function NiftyCheck(){
if(!document.getElementById || !document.createElement)
    return(false);
var b=navigator.userAgent.toLowerCase();
if(b.indexOf("msie 5")>0 && b.indexOf("opera")==-1)
    return(false);
return(true);
}

function Rounded(selector,bk,color,size){
var i;
var v=getElementsBySelector(selector);
var l=v.length;
for(i=0;i<l;i++){
    AddTop(v[i],bk,color,size);
    AddBottom(v[i],bk,color,size);
    }
}

function RoundedTop(selector,bk,color,size){
var i;
var v=getElementsBySelector(selector);
for(i=0;i<v.length;i++)
    AddTop(v[i],bk,color,size);
}

function RoundedBottom(selector,bk,color,size){
var i;
var v=getElementsBySelector(selector);
for(i=0;i<v.length;i++)
    AddBottom(v[i],bk,color,size);
}

function AddTop(el,bk,color,size){
var i;
var d=document.createElement("b");
var cn="r";
var lim=4;
if(size && size=="small"){ cn="rs"; lim=2}
d.className="rtop";
d.style.backgroundColor=bk;
for(i=1;i<=lim;i++){
    var x=document.createElement("b");
    x.className=cn + i;
    x.style.backgroundColor=color;
    d.appendChild(x);
    }
el.insertBefore(d,el.firstChild);
}

function AddBottom(el,bk,color,size){
var i;
var d=document.createElement("b");
var cn="r";
var lim=4;
if(size && size=="small"){ cn="rs"; lim=2}
d.className="rbottom";
d.style.backgroundColor=bk;
for(i=lim;i>0;i--){
    var x=document.createElement("b");
    x.className=cn + i;
    x.style.backgroundColor=color;
    d.appendChild(x);
    }
el.appendChild(d,el.firstChild);
}

function getElementsBySelector(selector){
var i;
var s=[];
var selid="";
var selclass="";
var tag=selector;
var objlist=[];
if(selector.indexOf(" ")>0){  //descendant selector like "tag#id tag"
    s=selector.split(" ");
    var fs=s[0].split("#");
    if(fs.length==1) return(objlist);
    return(document.getElementById(fs[1]).getElementsByTagName(s[1]));
    }
if(selector.indexOf("#")>0){ //id selector like "tag#id"
    s=selector.split("#");
    tag=s[0];
    selid=s[1];
    }
if(selid!=""){
    objlist.push(document.getElementById(selid));
    return(objlist);
    }
if(selector.indexOf(".")>0){  //class selector like "tag.class"
    s=selector.split(".");
    tag=s[0];
    selclass=s[1];
    }
var v=document.getElementsByTagName(tag);  // tag selector like "tag"
if(selclass=="")
    return(v);
for(i=0;i<v.length;i++){
    if(v[i].className==selclass){
        objlist.push(v[i]);
        }
    }
return(objlist);
}