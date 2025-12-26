

function _disable_forms()
{
	var l = document.forms.length;
	for(var i=0; i < l; i++)
	{
		document.forms[i].action = null;
		var m = document.forms[i].elements.length;
		for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = true;
	}
}

function filterReveal(width, e)
{
	var filterSection = document.getElementById("filterBox");
	
	if (!e) var e = window.event;
	
	var clickX = e.clientX - width;
	var clickY = e.clientY + 20;
	
	filterSection.style.left = clickX;
	filterSection.style.top = clickY;
	
	if (filterSection.style.display == "none")
	{
		filterSection.style.display = "";
	}
	else
	{
		filterSection.style.display = "none";
	}
}

function loadHelp(desc)
{
	var helpDoc = new HelpDocument(desc);
	
	var sUrl = "/ccps/ui/jsp/help/help_display.jsp?winState=pop&topic=" + helpDoc.topic + "&help_doc_id=" + helpDoc.help_doc_id;
	
	var sHeight = window.screen.availHeight - 50;
	var sWidth = "325";
	var sTop = "0";
	var sLeft = window.screen.availWidth - 340;
	
	var sFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=" + sHeight + ", width=" + sWidth + ", top=" + sTop + ", left=" + sLeft;
	
	window.open(sUrl, "HelpDoc", sFeatures);
}

function HelpDocument(desc)
{
	this.topic = "";
	this.help_doc_id = "";
	
	if (desc == "BBack Settings")
	{
		this.topic = "vl1185-ch1188";
		this.help_doc_id = "1195";
	}
	else if (desc == "Standard Campaign")
	{
		this.topic = "vl1166-ch1171";
		this.help_doc_id = "1171";
	}
	else if (desc == "Viral Marketing")
	{
		this.topic = "vl1166-ch1176";
		this.help_doc_id = "1176";
	}
	else if (desc == "Triggered Campaign")
	{
		this.topic = "vl1166-ch1182";
		this.help_doc_id = "1182";
	}
}


/*
 Please leave this notice.
 DHTML tip message version 1.2 copyright Essam Gamal 2003 (http://migoicons.tripod.com, migoicons@hotmail.com)
 All modifications are done in the style.js you should not modify this file.  Created on : 06/03/2003
 Script featured on and can be found at Dynamic Drive (http://www.dynamicdrive.com)
*/ 

var ua = navigator.userAgent
var ps = navigator.productSub 
var dom = (document.getElementById)? 1:0
var ie4 = (document.all&&!dom)? 1:0
var ie5 = (document.all&&dom)? 1:0
var nn4 =(navigator.appName.toLowerCase() == "netscape" && parseInt(navigator.appVersion) == 4)
var nn6 = (dom&&!ie5)? 1:0
var sNav = (nn4||nn6||ie4||ie5)? 1:0
var cssFilters = ((ua.indexOf("MSIE 5.5")>=0||ua.indexOf("MSIE 6")>=0)&&ua.indexOf("Opera")<0)? 1:0
var Style=[],Text=[],Count=0,sbw=0,move=0,hs="",mx,my,scl,sct,ww,wh,obj,sl,st,ih,iw,vl,hl,sv,evlh,evlw,tbody
var HideTip = "eval(obj+sv+hl+';'+obj+sl+'=0;'+obj+st+'=-800')"
var doc_root = ((ie5&&ua.indexOf("Opera")<0||ie4)&&document.compatMode=="CSS1Compat")? "document.documentElement":"document.body"
var PX = (nn6)? "px" :"" 

if(sNav) {
	window.onresize = ReloadTip
	document.onmousemove = MoveTip
	if(nn4) document.captureEvents(Event.MOUSEMOVE) 
}	
if(nn4||nn6) {
	mx = "e.pageX"
	my = "e.pageY"
	scl = "window.pageXOffset"
	sct = "window.pageYOffset"	
	if(nn4) {
		obj = "document.TipLayer."
		sl = "left"
		st = "top"
		ih = "clip.height"
		iw = "clip.width"
		vl = "'show'"
		hl = "'hide'"
		sv = "visibility="
	}
	else obj = "document.getElementById('TipLayer')."
} 
if(ie4||ie5) {
	obj = "TipLayer."
	mx = "event.x"
	my = "event.y"
	scl = "eval(doc_root).scrollLeft"
	sct = "eval(doc_root).scrollTop"
	if(ie5) {
		mx = mx+"+"+scl 
		my = my+"+"+sct
	}
}
if(ie4||dom){
	sl = "style.left"
	st = "style.top"
	ih = "offsetHeight"
	iw = "offsetWidth"
	vl = "'visible'"
	hl = "'hidden'"
	sv = "style.visibility="
}
if(ie4||ie5||ps>=20020823) {
	ww = "eval(doc_root).clientWidth"
	wh = "eval(doc_root).clientHeight"
}	 
else { 
	ww = "window.innerWidth"
	wh = "window.innerHeight"
	evlh = eval(wh)
	evlw = eval(ww)
	sbw=15
}	

function applyCssFilter(){
	if(cssFilters&&FiltersEnabled) { 
		var dx = " progid:DXImageTransform.Microsoft."
		TipLayer.style.filter = "revealTrans()"+dx+"Fade(Overlap=1.00 enabled=0)"+dx+"Inset(enabled=0)"+dx+"Iris(irisstyle=PLUS,motion=in enabled=0)"+dx+"Iris(irisstyle=PLUS,motion=out enabled=0)"+dx+"Iris(irisstyle=DIAMOND,motion=in enabled=0)"+dx+"Iris(irisstyle=DIAMOND,motion=out enabled=0)"+dx+"Iris(irisstyle=CROSS,motion=in enabled=0)"+dx+"Iris(irisstyle=CROSS,motion=out enabled=0)"+dx+"Iris(irisstyle=STAR,motion=in enabled=0)"+dx+"Iris(irisstyle=STAR,motion=out enabled=0)"+dx+"RadialWipe(wipestyle=CLOCK enabled=0)"+dx+"RadialWipe(wipestyle=WEDGE enabled=0)"+dx+"RadialWipe(wipestyle=RADIAL enabled=0)"+dx+"Pixelate(MaxSquare=35,enabled=0)"+dx+"Slide(slidestyle=HIDE,Bands=25 enabled=0)"+dx+"Slide(slidestyle=PUSH,Bands=25 enabled=0)"+dx+"Slide(slidestyle=SWAP,Bands=25 enabled=0)"+dx+"Spiral(GridSizeX=16,GridSizeY=16 enabled=0)"+dx+"Stretch(stretchstyle=HIDE enabled=0)"+dx+"Stretch(stretchstyle=PUSH enabled=0)"+dx+"Stretch(stretchstyle=SPIN enabled=0)"+dx+"Wheel(spokes=16 enabled=0)"+dx+"GradientWipe(GradientSize=1.00,wipestyle=0,motion=forward enabled=0)"+dx+"GradientWipe(GradientSize=1.00,wipestyle=0,motion=reverse enabled=0)"+dx+"GradientWipe(GradientSize=1.00,wipestyle=1,motion=forward enabled=0)"+dx+"GradientWipe(GradientSize=1.00,wipestyle=1,motion=reverse enabled=0)"+dx+"Zigzag(GridSizeX=8,GridSizeY=8 enabled=0)"+dx+"Alpha(enabled=0)"+dx+"Dropshadow(OffX=3,OffY=3,Positive=true,enabled=0)"+dx+"Shadow(strength=3,direction=135,enabled=0)"
	}
}

function stm(t,s) {
  if(sNav) {
  	if(t.length<2||s.length<25) {
		var ErrorNotice = "DHTML TIP MESSAGE VERSION 1.2 ERROR NOTICE.\n"
		if(t.length<2&&s.length<25) alert(ErrorNotice+"It looks like you removed an entry or more from the Style Array and Text Array of this tip.\nTheir should be 25 entries in every Style Array even though empty and 2 in every Text Array. You defined only "+s.length+" entries in the Style Array and "+t.length+" entry in the Text Array. This tip won't be viewed to avoid errors")
		else if(t.length<2) alert(ErrorNotice+"It looks like you removed an entry or more from the Text Array of this tip.\nTheir should be 2 entries in every Text Array. You defined only "+t.length+" entry. This tip won't be viewed to avoid errors.")
		else if(s.length<25) alert(ErrorNotice+"It looks like you removed an entry or more from the Style Array of this tip.\nTheir should be 25 entries in every Style Array even though empty. You defined only "+s.length+" entries. This tip won't be viewed to avoid errors.")
 	}
  	else {
		var ab = "" ;var ap = ""
		var titCol = (s[0])? "COLOR='"+s[0]+"'" : ""
		var txtCol = (s[1])? "COLOR='"+s[1]+"'" : ""
		var titBgCol = (s[2])? "style='background-color:"+s[2]+";'" : ""
		var txtBgCol = (s[3])? "style='background-color:"+s[3]+";'" : ""
		var titBgImg = (s[4])? "BACKGROUND='"+s[4]+"'" : ""	
		var txtBgImg = (s[5])? "BACKGROUND='"+s[5]+"'" : ""
		var titTxtAli = (s[6] && s[6].toLowerCase()!="left")? "ALIGN='"+s[6]+"'" : ""
		var txtTxtAli = (s[7] && s[7].toLowerCase()!="left")? "ALIGN='"+s[7]+"'" : ""   
		var add_height = (s[15])? "HEIGHT='"+s[15]+"'" : ""
		if(!s[8])  s[8] = "Verdana,Arial,Helvetica"
		if(!s[9])  s[9] = "Verdana,Arial,Helvetica"					
		if(!s[12]) s[12] = 1
		if(!s[13]) s[13] = 1
		if(!s[14]) s[14] = 200
		if(!s[16]) s[16] = 0
		if(!s[17]) s[17] = 0
		if(!s[18]) s[18] = 10
		if(!s[19]) s[19] = 10
		hs = s[11].toLowerCase() 
		if(ps==20001108){
		if(s[2]) ab="STYLE='border:"+s[16]+"px solid"+" "+s[2]+"'"
		ap="STYLE='padding:"+s[17]+"px "+s[17]+"px "+s[17]+"px "+s[17]+"px'"}
		var closeLink=(hs=="sticky")? "<TD ALIGN='right' valign='middle' "+titBgCol+" style='padding:2px;'><FONT SIZE='"+s[12]+"' FACE='"+s[8]+"'><A HREF='javascript:void(0)' ONCLICK='stickyhide()' STYLE='text-decoration:none;color:"+s[0]+"'><B>&nbsp;</B></A></FONT></TD>":""
		var title=(t[0]||hs=="sticky")? "<TABLE WIDTH='100%' BORDER='0' CELLPADDING='0' CELLSPACING='0' "+titBgCol+" ><TR><TD "+titTxtAli+" "+titBgCol+" ><FONT SIZE='"+s[12]+"' FACE='"+s[8]+"' "+titCol+"><B>"+t[0]+"</B></FONT></TD>"+closeLink+"</TR></TABLE>" : ""
		var txt="<TABLE "+titBgImg+" "+ab+" "+titBgCol+"  WIDTH='"+s[14]+"' BORDER='0' CELLPADDING='"+s[16]+"' CELLSPACING='0'><TR><TD style='PADDING: 0px;'>"+title+"<TABLE WIDTH='100%' "+add_height+" BORDER='0' CELLPADDING='"+s[17]+"' CELLSPACING='0' "+txtBgCol+" "+txtBgImg+"><TR><TD "+txtTxtAli+" "+ap+" VALIGN='top' "+txtBgCol+" ><FONT SIZE='"+s[13]+"' FACE='"+s[9]+"' "+txtCol +">"+t[1]+"</FONT></TD></TR></TABLE></TD></TR></TABLE>"
		if(nn4) {
			with(eval(obj+"document")) {
				open()
				write(txt)
				close()
			}
		}
		else eval(obj+"innerHTML=txt")
		tbody = {
			Pos:s[10].toLowerCase(), 
			Xpos:s[18],
			Ypos:s[19], 
			Transition:s[20],
			Duration:s[21], 
			Alpha:s[22],
			ShadowType:s[23].toLowerCase(),
			ShadowColor:s[24],
			Width:parseInt(eval(obj+iw)+3+sbw)
		}
		if(ie4) { 
			TipLayer.style.width = s[14]
	 		tbody.Width = s[14]
		}
		Count=0	
		move=1
 	 }
  }
}

function MoveTip(e) {
	if(move) {
		var X,Y,MouseX = eval(mx),MouseY = eval(my); tbody.Height = parseInt(eval(obj+ih)+3)
		tbody.wiw = parseInt(eval(ww+"+"+scl)); tbody.wih = parseInt(eval(wh+"+"+sct))
		switch(tbody.Pos) {
			case "left" : X=MouseX-tbody.Width-tbody.Xpos; Y=MouseY+tbody.Ypos; break
			case "center": X=MouseX-(tbody.Width/2); Y=MouseY+tbody.Ypos; break
			case "float": X=tbody.Xpos+eval(scl); Y=tbody.Ypos+eval(sct); break	
			case "fixed": X=tbody.Xpos; Y=tbody.Ypos; break		
			default: X=MouseX+tbody.Xpos; Y=MouseY+tbody.Ypos
		}

		if(tbody.wiw<tbody.Width+X) X = tbody.wiw-tbody.Width
		if(tbody.wih<tbody.Height+Y+sbw) {
			if(tbody.Pos=="float"||tbody.Pos=="fixed") Y = tbody.wih-tbody.Height-sbw
			else Y = MouseY-tbody.Height
		}
		if(X<0) X=0 
		eval(obj+sl+"=X+PX;"+obj+st+"=Y+PX")
		ViewTip()
	}
}

function ViewTip() {
  	Count++
	if(Count == 1) {
		if(cssFilters&&FiltersEnabled) {	
			for(Index=28; Index<31; Index++) { TipLayer.filters[Index].enabled = 0 }
			for(s=0; s<28; s++) { if(TipLayer.filters[s].status == 2) TipLayer.filters[s].stop() }
			if(tbody.Transition == 51) tbody.Transition = parseInt(Math.random()*50)
			var applyTrans = (tbody.Transition>-1&&tbody.Transition<24&&tbody.Duration>0)? 1:0
			var advFilters = (tbody.Transition>23&&tbody.Transition<51&&tbody.Duration>0)? 1:0
			var which = (applyTrans)?0:(advFilters)? tbody.Transition-23:0 
			if(tbody.Alpha>0&&tbody.Alpha<100) {
	  			TipLayer.filters[28].enabled = 1
	  			TipLayer.filters[28].opacity = tbody.Alpha
			}
			if(tbody.ShadowColor&&tbody.ShadowType == "simple") {
	  			TipLayer.filters[29].enabled = 1
	  			TipLayer.filters[29].color = tbody.ShadowColor
			}
			else if(tbody.ShadowColor&&tbody.ShadowType == "complex") {
	  			TipLayer.filters[30].enabled = 1
	  			TipLayer.filters[30].color = tbody.ShadowColor
			}
			if(applyTrans||advFilters) {
				eval(obj+sv+hl)
	  			if(applyTrans) TipLayer.filters[0].transition = tbody.Transition
	  			TipLayer.filters[which].duration = tbody.Duration 
	  			TipLayer.filters[which].apply()
			}
		}
 		eval(obj+sv+vl)
		if(cssFilters&&FiltersEnabled&&(applyTrans||advFilters)) TipLayer.filters[which].play()
		if(hs == "sticky") move=0
		
		var sSelects;
		sSelects = document.getElementsByTagName("SELECT");
		
		for (i=0; i < sSelects.length; i++)
		{
			sSelects[i].style.visibility = "hidden";
		}
  	}
}

function stickyhide() {
	eval(HideTip)
		
	var sSelects;
	sSelects = document.getElementsByTagName("SELECT");

	for (i=0; i < sSelects.length; i++)
	{
		sSelects[i].style.visibility = "visible";
	}
}

function ReloadTip() {
	 if(nn4&&(evlw!=eval(ww)||evlh!=eval(wh))) location.reload()
	 else if(hs == "sticky") eval(HideTip)
		
	var sSelects;
	sSelects = document.getElementsByTagName("SELECT");

	for (i=0; i < sSelects.length; i++)
	{
		sSelects[i].style.visibility = "visible";
	}
}

function htm() {
	if(sNav) {
		if(hs!="keep") {
			move=0; 
			//if(hs!="sticky")
			//{
				eval(HideTip)
				var sSelects;
				sSelects = document.getElementsByTagName("SELECT");

				for (i=0; i < sSelects.length; i++)
				{
					sSelects[i].style.visibility = "visible";
				}
			//}
		
		}	
	} 
}

