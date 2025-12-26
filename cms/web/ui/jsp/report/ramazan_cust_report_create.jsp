<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.util.Date,java.io.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

StringWriter swXML = new StringWriter();
String sReportID = request.getParameter("report_id");

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("cust_report_create.jsp");
	stmt = conn.createStatement();

	String sTime = null;
	rs = stmt.executeQuery("SELECT CONVERT(varchar(25), getdate(), 0)");
	if (rs.next()) sTime = rs.getString(1);
	rs.close();
	sTime = (sTime == null)?"":sTime;

%>
<HTML>
<HEAD>
<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</HEAD>
<BODY ONLOAD="getYears(document.all,0);getYears(document.all,1);SetDateTime(document.all);">
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="trySubmit();">Save</a>
		</td>
	</tr>
</table>
<br>

<FORM  METHOD="POST" NAME="FT" ACTION="cust_report_save.jsp" TARGET="_self">

<INPUT TYPE="hidden" NAME="report_id"	value="<%=(sReportID!=null)?sReportID:""%>">
<INPUT TYPE="hidden" NAME="start_date"	value="">
<INPUT TYPE="hidden" NAME="end_date"	value="">
<INPUT TYPE="hidden" NAME="current_time"	value="<%=sTime%>">

<table width=550 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Enter Variables</th>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=left width=550>
			<table cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<td width="150" valign="middle"><input name="sd1" type="checkbox" onclick="setDateFlag(this,0,this.form.start_date);">
						Start Date </td>
					<td width="400">
						<select name="year"  onchange="populate(this.form,this.form.month(0).selectedIndex,0);"></select>
						<select name="month" onchange="populate(this.form,this.selectedIndex,0);"></select>
						<select name="day"></select>
					</td>
				</tr>
				<tr>
					<td width="150"><input name="sd2" type="checkbox" onclick="setDateFlag(this,1,this.form.end_date);">
						End Date </td>
					<td width="400">
						<select name="year"  onchange="populate(this.form,this.form.month(1).selectedIndex,1);"></select>
						<select name="month" onchange="populate(this.form,this.selectedIndex,1);"></select>
						<select name="day"></select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<SCRIPT LANGUAGE="JavaScript">
// Calculate number of days
function populate(objForm,selectIndex,Ind) {
	timeA = new Date(objForm.year(Ind).options[objForm.year(Ind).selectedIndex].text, objForm.month(Ind).options[objForm.month(Ind).selectedIndex].value,1);
	timeDifference = timeA - 86400000;
	timeB = new Date(timeDifference);
	var daysInMonth = timeB.getDate();
	for (var i = 0; i < objForm.day(Ind).length; i++) objForm.day(Ind).options[0] = null;
	for (var i = 0; i < daysInMonth; i++) objForm.day(Ind).options[i] = new Option(i+1);
	objForm.day(Ind).options[0].selected = true;
}
// Fill time
function getTime(objForm,Ind) {
var timeT = new Array("Midnight","1:00 AM","2:00 AM","3:00 AM","4:00 AM","5:00 AM",
                     "6:00 AM","7:00 AM","8:00 AM","9:00 AM","10:00 AM","11:00 AM", 
		"Noon","1:00 PM","2:00 PM","3:00 PM","4:00 PM","5:00 PM",
                     "6:00 PM","7:00 PM","8:00 PM","9:00 PM","10:00 PM","11:00 PM")
	for (var i = 0; i < timeT.length; i++) {
		objForm.time(Ind).options[i] = new Option(timeT[i]);
		objForm.time(Ind).options[i].value = i;
	}
}
// Fill month
function getMonths(objForm,Ind) {
var months = new Array("January","February","March","April","May","June","July","August","September","October","November","December")
	timeC = new Date(Date.parse(objForm.current_time.value));

	for (var i = 0; i < months.length; i++) {
		objForm.month(Ind).options[i] = new Option(months[i]);
		objForm.month(Ind).options[i].value = i+1;
	}
	objForm.month(Ind).options[timeC.getMonth()].selected=true;
}
// Fill years: Start with current year and next 5 years
function getYears(objForm, Ind) {
	timeC = new Date(Date.parse(objForm.current_time.value));
	currYear = timeC.getFullYear();
	for (var i = -2; i < 3; i++) {
		objForm.year(Ind).options[i+2] = new Option(currYear + i);
		objForm.year(Ind).options[i+2].value = currYear + i;
	}
	objForm.year(Ind).options[3].selected=true;
	getMonths(objForm,Ind);
	populate(objForm,1,Ind);
	objForm.day(Ind).options[timeC.getDate()-1].selected = true;
}

function GetDateTime(objForm) {
	if (objForm.sd1.checked == true) {
		var dateStart = objForm.month(0).options[objForm.month(0).selectedIndex].text + " " +
				objForm.day(0).options[objForm.day(0).selectedIndex].text + " " +
				objForm.year(0).options[objForm.year(0).selectedIndex].value;
		document.all.start_date.value = dateStart;
	}
	if (objForm.sd2.checked == true) {
		var dateEnd = objForm.month(1).options[objForm.month(1).selectedIndex].text + " " +
				objForm.day(1).options[objForm.day(1).selectedIndex].text + " " +
				objForm.year(1).options[objForm.year(1).selectedIndex].value;
		document.all.end_date.value = dateEnd;
	}
}

function SetDateTime(objForm) {
	var timeC = new Date(Date.parse(objForm.current_time.value));
		
	var dateStart = new Date(Date.parse(objForm.start_date.value));
	if(objForm.start_date.value == "") {
		dateStart = new Date(Date.parse(objForm.current_time.value));
	} else {
		objForm.sd1.checked=true;
	}
	if( dateStart.getFullYear() - timeC.getFullYear() >= -1 ) {
		objForm.month(0).options[dateStart.getMonth()].selected = true;
		populate(objForm,dateStart.getMonth(),0)
		objForm.day(0).options[dateStart.getDate()-1].selected = true;
		objForm.year(0).options[dateStart.getFullYear()-timeC.getFullYear()+2].selected = true;
	}
	setDateFlag(objForm.sd1,0,objForm.start_date)

	var dateEnd = new Date(Date.parse(objForm.end_date.value));
	if(objForm.end_date.value == "") {
		dateEnd = new Date(Date.parse(objForm.current_time.value));
	} else {
		objForm.sd2.checked=true;
	}
	if( dateEnd.getFullYear() - timeC.getFullYear() >= -1 ) {
		objForm.month(1).options[dateEnd.getMonth()].selected = true;
		populate(objForm,dateEnd.getMonth(),1)
		objForm.day(1).options[dateEnd.getDate()-1].selected = true;
		objForm.year(1).options[dateEnd.getFullYear()-timeC.getFullYear()+2].selected = true;
	} 
	setDateFlag(objForm.sd2,1,objForm.end_date)
}

function setDateFlag(obj1,ind,obj2) {
	if (obj1.checked == true) {
		FT.month(ind).disabled = false;
		FT.day(ind).disabled = false;
		FT.year(ind).disabled = false;
		obj2.value = FT.month(ind).options[FT.month(ind).selectedIndex].text + " " +
				  FT.day(ind).options[FT.day(ind).selectedIndex].text + " " +
				  FT.year(ind).options[FT.year(ind).selectedIndex].value;
	} else {
		FT.month(ind).disabled = true;
		FT.day(ind).disabled = true;
		FT.year(ind).disabled = true;
		obj2.value = "";
	}
}


function trySubmit()
{
	GetDateTime(document.all); 

	var dateStr = new Date(Date.parse(FT.start_date.value));
	var dateEnd = new Date(Date.parse(FT.end_date.value));
	if (dateEnd < dateStr) { alert("The <End Date> specified is before the <Start Date> ..."); return false; }

//	alert(FT.start_date.value);
//	alert(FT.end_date.value);

	FT.submit();
}



</SCRIPT>
</BODY>
</HTML>
<%

} catch(Exception ex) { 
	ErrLog.put(this, ex, "Report Error.",out,1);
} finally {

	try { 	
		if( stmt != null ) stmt.close(); 
	} catch (Exception ex2) {}
	if( conn != null ) cp.free(conn); 
}
%>
