<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.text.DateFormat,
			java.sql.*,java.net.*,
			java.io.*, java.util.*,
			org.xml.sax.*,javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.w3c.dom.*,javax.xml.parsers.*,
			org.apache.log4j.Logger"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;	

	String formID = request.getParameter("form_id");

	String strURL, sql;
	String nextForm = null, badRecipForm = null, noRecipForm = null;
	String formTypeId = "";
	String sbsFormID = "",formName = "",creator = "",createDate = "",modifier = "",modifyDate = "";
	String prefillFlag = "",prefillNoValidateFlag = "",highPriorityFlag = "",postValidateFlag = "";
	String confirmURL = "",formURL = "",updateIncompleteFlag = "", formSource = "";

	String sUnsubHierarchyId = null;
	String sUpdHierarchyId = null;
	String sUpdRuleId = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();					

		if (formID != null)
		{
			//Retrieve form info from form table
			sql =
				" SELECT f.form_id, f.form_name, f.type_id, " +
				" c1.user_name as creator, fei.create_date, " +
				" c2.user_name as editor, fei.modify_date, " +
				" prefill_flag, prefill_no_validate_flag, high_priority_flag, post_validate_flag, " +
				" confirm_url, form_url, update_incomplete_flag, form_next_success, " +
				" form_alt_prefill_bad_recip, form_alt_prefill_no_recip, form_source, " +
				" unsub_hierarchy_id, upd_hierarchy_id, upd_rule_id" +
				" FROM" +
				"	csbs_form f," +
				"	csbs_form_edit_info fei," +
				"	ccps_user c1," +
				"	ccps_user c2 " +
				" WHERE" +
				"	f.form_id = " + formID + " AND" +
				"	f.cust_id = " + cust.s_cust_id + " AND" +
				"	fei.form_id = f.form_id AND" +
				"	fei.creator_id = c1.user_id AND" +
				"	fei.modifier_id = c2.user_id";
				
			rs = stmt.executeQuery(sql);
			if (!rs.next())
			{
				throw new Exception("Could not find form in cps database.");
			}
			sbsFormID = rs.getString(1);
			formName 				= rs.getString(2);
			formTypeId 				= rs.getString(3);
			creator 				= rs.getString(4);
			createDate				= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(5));
			modifier 				= rs.getString(6);
			modifyDate 				= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(7));
			prefillFlag 			= rs.getString(8);
			prefillNoValidateFlag	= rs.getString(9);
			highPriorityFlag		= rs.getString(10);
			postValidateFlag		= rs.getString(11);
			confirmURL				= rs.getString(12);
			formURL					= rs.getString(13);
			updateIncompleteFlag	= rs.getString(14);
			nextForm				= rs.getString(15);
			badRecipForm			= rs.getString(16);
			noRecipForm				= rs.getString(17);
			byte[] b = rs.getBytes(18);
			formSource				= (b==null)?null:new String(b,"UTF-8");

			sUnsubHierarchyId = rs.getString(19);
			sUpdHierarchyId = rs.getString(20);
			sUpdRuleId = rs.getString(21);
		}
		else
		{
			formName = "New Subscription Form";
		}

//---------- Generate type option list -----------------

		sql = "SELECT type_id, type_name FROM csbs_form_type";
		rs = stmt.executeQuery(sql);
		String htmlTypeOptionList = "";
		String tempTypeID;
		while (rs.next())
		{
			tempTypeID = rs.getString(1);
			htmlTypeOptionList += "<option value="+tempTypeID;
			if (formTypeId.equals(tempTypeID)) htmlTypeOptionList += " selected";
			htmlTypeOptionList += ">"+rs.getString(2)+"</option>\n";
		}

//---------- Generate customer form option list --------

		sql =
			" SELECT form_id, form_name" +
			" FROM csbs_form" +
			" WHERE cust_id = " + cust.s_cust_id+
			" ORDER BY form_name";
			
		rs = stmt.executeQuery(sql);
		String htmlNextFormOptionList = "";
		String htmlBadRecipFormOptionList = "";
		String htmlNoRecipFormOptionList = "";
		String tempID, tempName;
		while (rs.next())
		{
			tempID = rs.getString(1);

			tempName = rs.getString(2);
			htmlNextFormOptionList += "<option value="+tempID;
			htmlBadRecipFormOptionList += "<option value="+tempID;
			htmlNoRecipFormOptionList += "<option value="+tempID;
		
			if (tempID.equals(nextForm)) htmlNextFormOptionList += " selected";
			if (tempID.equals(badRecipForm)) htmlBadRecipFormOptionList += " selected";
			if (tempID.equals(noRecipForm)) htmlNoRecipFormOptionList += " selected";

			htmlNextFormOptionList += ">"+tempName+"</option>\n";
			htmlBadRecipFormOptionList += ">"+tempName+"</option>\n";
			htmlNoRecipFormOptionList += ">"+tempName+"</option>\n";
		}

//--- Prepare list of dropdown boxes ---

		String htmlKeywords = "";

		String htmlPers = "";
		
		String sSql =
			" SELECT a.attr_name, ca.display_name " +
			" FROM ccps_attribute a, ccps_cust_attr ca" +
			" WHERE" + 
			" ca.cust_id = " + cust.s_cust_id + " AND" +
			" a.attr_id = ca.attr_id AND" +
			" display_seq IS NOT NULL " +
			" ORDER BY display_seq";
			
		rs = stmt.executeQuery(sSql);
		while (rs.next())
			htmlPers += "<option value="+rs.getString(1)+">"+rs.getString(2)+"</option>\n";
%>

<html> 
<head> 
<title>Subscription Form</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript" src="../../js/tab_script.js"></script>
</head> 

<!-- XSL Page Image generation -->
<script language="javascript">
// Initialization: XML Root, Male/Female
var MyRoot = 'SubscriptionInfo';
var ErrMsg = 'You have to enter all required fields';

// For XSL page generation
var HTxt2  = '<?xml version="1.0"?>\n';
	 HTxt2 += '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">\n';
	 HTxt2 += '<!-- <xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl"> -->\n';
	 HTxt2 += '<xsl:template match="/">\n';
	 HTxt2 += '<html>\n <head>\n  <title>Subscription</title>\n';
	 HTxt2 += ' </head>\n <body>\n';

//var BTxt2  = '  </xsl:element>\n<!-- [End block] Subscription form element -->\n';
var BTxt2  = '  </form>\n';
	 BTxt2 += ' </body>\n</html>\n';
	 BTxt2 += '</xsl:template>\n';
	 BTxt2 += '</xsl:stylesheet>';

// Common
var Tbl1 = '    <tr>\n     <td>';
var Tbl2 = '</td>\n     <td>';
var Tbl3 = '</td>\n    </tr>\n';

// generate XSL
function GenerateForm(){
var Rq
var Fld
var Txt
var XSLtxt = HTxt2 + AddScript() + XSLForm();

	if(document.all.SelectedFields.length==0 && document.all.type_id.value!=2) return;

	var AskMe = confirm("Do you want to clear existing content of \nSubscription form and create a new one ?");
	if(AskMe){
	}else{ return; }

	XSLtxt  += XSLHide();
	XSLtxt  += '   <table width="100%" border="1">\n';

	for (var i = 0; i < document.all.SelectedFields.length; i++)
	{
		Rq = 'N';
		if(document.all.SelectedFields.options[i].Id == 'Yes') Rq = 'R';

//		if(document.all.SelectedFields.options[i].text.substr(0,1) == '*') Rq = 'R';



// All fields    - <INPUT TYPE="TEXT">
// PGender       - <INPUT TYPE="RADIO">
// CstmKw01..10  - <SELECT></SELECT>
		Fld = document.all.SelectedFields.options[i].value;

		if(Fld == 'pgender'){			
			Txt = XSLGender(Fld, Rq, Fld, document.all.SelectedFields.options[i].text);
		}
		else if(Fld.substr(0,7) == 'keyword'){
			Txt = XSLList(Fld, Rq, Fld, document.all.SelectedFields.options[i].text);
		}
		else{
	      Txt = XSLInput(Fld, Rq, Fld, document.all.SelectedFields.options[i].text);
		}
		XSLtxt += Txt;
		XSLtxt += Tbl3;
	   XSLtxt += '<!-- [end Block] ' + document.all.SelectedFields.options[i].text + ' -->\n\n';
	}

	XSLtxt  += '   </table>\n' + XSLSubmit() + BTxt2;
	document.all.form_source.innerText = XSLtxt;
}

function XSLHide(){
var Txt
	Txt  = '\n<!-- [Begin block] Hidden element RecipientId -->\n';
	Txt += '  <xsl:element name="input">\n';
	Txt += '  <xsl:attribute name="type">hidden</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="name">RecipientId</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="value"><xsl:value-of select="' + MyRoot + '/RecipientId' + '"/></xsl:attribute>\n';
	Txt += '  </xsl:element>\n';
	Txt += '<!-- [End block] Hidden element RecipientID -->\n\n';

	Txt += '<xsl:if test="' + MyRoot + '/SubmitQueueId">'
	Txt += '\n<!-- [Begin block] Hidden element SubmitQueueId -->\n';
	Txt += '  <xsl:element name="input">\n';
	Txt += '  <xsl:attribute name="type">hidden</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="name">SubmitQueueId</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="value"><xsl:value-of select="' + MyRoot + '/SubmitQueueId' + '"/></xsl:attribute>\n';
	Txt += '  </xsl:element>\n';
	Txt += '<!-- [End block] Hidden element SubmitQueueId -->\n';
	Txt += '</xsl:if>\n\n'

	Txt += '<xsl:if test="' + MyRoot + '/InitialQueueId">'
	Txt += '\n<!-- [Begin block] Hidden element InitialQueueId -->\n';
	Txt += '  <xsl:element name="input">\n';
	Txt += '  <xsl:attribute name="type">hidden</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="name">InitialQueueId</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="value"><xsl:value-of select="' + MyRoot + '/InitialQueueId' + '"/></xsl:attribute>\n';
	Txt += '  </xsl:element>\n';
	Txt += '<!-- [End block] Hidden element InitialQueueId -->\n';
	Txt += '</xsl:if>\n\n'

	Txt += '<xsl:if test="' + MyRoot + '/FormId">'
	Txt += '\n<!-- [Begin block] Hidden element FormId -->\n';
	Txt += '  <xsl:element name="input">\n';
	Txt += '  <xsl:attribute name="type">hidden</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="name">FormId</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="value"><xsl:value-of select="' + MyRoot + '/FormId' + '"/></xsl:attribute>\n';
	Txt += '  </xsl:element>\n';
	Txt += '<!-- [End block] Hidden element FormId -->\n';
	Txt += '</xsl:if>\n\n'

var HttpTxt = document.all.confirm_url.value.replace(/(^\s*)|(\s*$)/g, '');

	if (HttpTxt != '')
	Txt += '<input type="hidden" name="confirm_url" id="!*' + HttpTxt + '*!" value="' + HttpTxt + '"/>\n\n';

	return Txt;
}

function XSLForm(){
var Txt = '   <form name="Subscribe" method="Post" Action="SubmitForm">\n';
	return Txt;
}

function XSLSubmit(){
var Txt = '<input type="button" class="subactionbutton" name="Submit" value="Submit" onClick="CheckSubscription()"/>\n';

	if(document.all.type_id.value=='1') Txt = '<input type="button" class="subactionbutton" name="Submit" value="Submit" onClick="CheckSubscription()"/>\n';
	if(document.all.type_id.value=='2') Txt = '<input type="button" class="subactionbutton" name="Submit" value="Unsubscribe me" onClick="CheckSubscription()"/>\n';
	if(document.all.type_id.value=='3') Txt = '<input type="button" class="subactionbutton" name="Submit" value="Send to Friend" onClick="CheckSubscription()"/>\n';

	return Txt;
}

// insert predefined label
function XSLLabel(Lbl, Rq){
var Txt
   Txt  = '<!-- [begin block] ' + Lbl + ' -->\n';
	Txt += Tbl1;
	if(Rq == 'R'){
		Txt += Lbl + ' *';
	} else {
		Txt += Lbl;
	}
	Txt += Tbl2;
	return Txt;
}

function XSLInput(Idx, Rq, Fld, Lbl){
var Txt
	Txt  = XSLLabel(Lbl, Rq);
// insert element
	Txt += '<!-- [begin block] input element -->\n';
	Txt += '  <xsl:element name="input">\n';
	Txt += '  <xsl:attribute name="type">text</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="id">' + Rq + Idx + '</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="name">' + "i_" + Fld + '</xsl:attribute>\n';
	Txt += '  <xsl:if test="not(' + MyRoot + '/Row/' +  Fld + '=\'null\')">\n';
	Txt += '  <xsl:attribute name="value">\n';
	Txt += '  <xsl:value-of select="' + MyRoot + '/Row/' + Fld + '"/>\n';
	Txt += '  </xsl:attribute>\n';
	Txt += '  </xsl:if>\n'

	Txt += '  </xsl:element>\n';
	Txt += '<!-- [end block] input element -->\n\n';
	return Txt;
}

function XSLGender(Idx, Rq, Fld, Lbl){
var Txt

	Txt  = XSLLabel(Lbl, Rq);
// insert element
	Txt += '<!-- [begin block] Gender radio element -->\n';
	Txt += XSLRadio(Fld, Rq, Idx, 'Male', '1');
	Txt += XSLRadio(Fld, Rq, Idx, 'Female', '2');
	Txt += '<!-- [end block] Gender radio element -->\n\n';

	return Txt;
}

function XSLRadio(Fld, Rq, Idx, Nm, Ndx){
var Txt = "";

	Txt += Nm + '\n';
	Txt += '  <xsl:element name="input">\n';
	Txt += '  <xsl:attribute name="type">radio</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="id">' + Rq + Idx + 'F</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="name">' + "i_" + Fld + '</xsl:attribute>\n';
	Txt += '  <xsl:attribute name="value">' + Ndx + '</xsl:attribute>\n';
	Txt += '           <xsl:if test="' + MyRoot + '/Row/' + Fld + '=' + Ndx + '">\n';
	Txt += '           <xsl:attribute name="CHECKED">CHECKED</xsl:attribute>\n';
	Txt += '           </xsl:if>\n';
	Txt += '  </xsl:element>\n';

	return Txt;
}

function XSLList(Idx, Rq, Fld, Lbl){
var Txt

	Txt  = XSLLabel(Lbl, Rq);
	Txt += '<!-- [begin block] Select "keyword..." element -->\n';

	Txt += '<xsl:variable name=\'Trg' + Fld + '\'>\n';
	Txt += '  <xsl:value-of select="' + MyRoot + '/Row/' + Fld + '"/>\n';
	Txt +='</xsl:variable>\n';

	Txt += '  <select size="5" multiple="multiple" style="width: 50%" id="' + Rq + Idx + '" name="' + "i_" +Fld + '">\n';
// option list

	var Ttt = '';
	for (var i=0; i<document.all.keywords.length; i++){
		if(document.all.keywords.options[i].value == Fld){
		Ttt += AddOptions(document.all.keywords.options[i].text, Fld);
		i = document.all.keywords.length;
		}
	}
	Txt += Ttt;
	Txt += '  </select>\n';
	Txt += '<!-- [end block] Select "keyword..." element -->\n\n';
	return Txt;
}

// Add options
function AddOptions(KeyList, Fld){
var IndKey;
var OptVal, OptTxt;
var Opt='';

	while ((IndKey = KeyList.indexOf(';')) != -1){
		Opt += '     <xsl:element name="option">\n';
		Opt += '     <xsl:attribute name="value">' + KeyList.substr(0,IndKey) + '</xsl:attribute>\n';
		Opt += '           <xsl:if test="contains($Trg' + Fld + ',\'' + KeyList.substr(0,IndKey) + ';\')">\n';
		Opt += '           <xsl:attribute name="selected">selected</xsl:attribute>\n';
		Opt += '           </xsl:if>\n';
		Opt += '     ' + KeyList.substr(0,IndKey) + '\n';
		Opt += '     </xsl:element>\n';
		KeyList = KeyList.substr(IndKey+1);
	}
	return Opt;
}

// XSL Java Script code generation
function AddScript(){
var Txt
	Txt  = '<script language="javascript">\n';
	Txt += '  <xsl:value-of select="' + MyRoot + '/JSFunctions"/>\n';
	Txt += '</' + 'script>\n';
	return Txt;
}
</script>

<!-- Page script -->
<script language="javascript">
// Submit the form
function SubmitPrepare(Act){
}

function moveList(Id, Sign, Direction){
	if(Id == -1) return;

var objFrom, objTo
var oOption = new Option;

	if(Direction == 0){
		objFrom = document.subscriptionObject.elements["AllFields"];
		objTo = document.subscriptionObject.elements["SelectedFields"];
		oOption.Id = Sign;
	} else {
		objFrom = document.subscriptionObject.elements["SelectedFields"];
		objTo = document.subscriptionObject.elements["AllFields"];
	}

	oOption.value 	= objFrom.options[Id].value;
	oOption.text 	= objFrom.options[Id].text;
	oOption.type 	= objFrom.options[Id].type;

	objTo.add(oOption);
	objFrom.remove(Id);
}

function shiftList(Id, Direction){
var objObj = document.subscriptionObject.elements["SelectedFields"];

	if(Id == -1) return;
	if(Direction == 0 && Id == 0) return;
	if(Direction == 1 && Id == objObj.length-1 ) return;

	if(Direction == 0){
		objObj.children(Id-1).swapNode(objObj.children(Id));
	} else {
		objObj.children(Id).swapNode(objObj.children(Id+1));
	}
}

// show element button
function ShowElement(){
var Fld
var Txt

	if(document.all.MacroList.selectedIndex == -1) return;
	Fld = document.all.MacroList.options[document.all.MacroList.selectedIndex].value;
	document.all.MacroName.value = Fld;

	if(Fld == 'pgender'){			
		Txt = XSLGender(1, 'N', Fld, document.all.MacroList.options[document.all.MacroList.selectedIndex].text);
	}
	else if(Fld.substr(0,7) == 'keyword'){
		Txt = XSLList(1, 'N', Fld, document.all.MacroList.options[document.all.MacroList.selectedIndex].text);
	}
	else{
	     Txt = XSLInput(1, 'N', Fld, document.all.MacroList.options[document.all.MacroList.selectedIndex].text);
	}
	Txt += '</TD>\n    </TR>\n';
	document.all.XSLElement.value = Txt;
}

function CatchFields(){
var Txt;
var XSLInfo = document.all.form_source.value;
	for(var i=0; i<document.all.AllFields.length; i++){
		Txt = document.all.AllFields.options[i].value;
		if(XSLInfo.indexOf('N' + Txt) != -1){
            moveList(i, 'Yes', 0)
			i=-1;
		}
		if(XSLInfo.indexOf('R' + Txt) != -1){
            moveList(i, 'No', 0)
			i=-1;
		}
	}
CatchHttp()
}

function CatchHttp(){
var Txt = '';
var XSLInfo = document.all.form_source.value;
var i1 = XSLInfo.indexOf('!*');
var i2 = XSLInfo.indexOf('*!');
	if(i1 != -1 && i2 != -1){
	Txt = XSLInfo.substr(i1+2,i2-i1-2);
	document.all.confirm_url.value = Txt;
	}	
}

// preview button
function WinOpen(){
var winl = (screen.width - 600) / 2;
var wint = (screen.height - 400) / 2;

// center & show (600x800)
	winprops = 'height=400,width=600,top='+wint+',left='+winl+',scrollbars=yes,resizable'
	msg=window.open('http://192.168.0.210/jsp/servlet/sbs_showForm?F=3','msg',winprops);
//	msg.document.write('http://192.168.0.210/jsp/servlet/sbs_showForm?F=3');
}

function POpen(){
// document.previewForm.submit();
document.subscriptionObject.action='form_preview.jsp';
document.subscriptionObject.target='_new';
document.subscriptionObject.submit();
}
</script>

     <body onLoad="CatchFields();"> 
          <form name="subscriptionObject" method="post" action="form_save.jsp">

<!-- List of keyword fields: macro_name=Keyword01 a1;a2;a3;a4;a5; -->
          <select name="keywords" style="display:none">
		  <%= htmlKeywords %>
          </select>

<!-- CPS Form ID -->
<% if(formID!=null) { %>
<input type="hidden" name="form_id" value="<%=formID%>">
<% } %>

<!-- SBS Form ID -->

<!-- input type="hidden" name="sbs_form_id" value="<%= sbsFormID %>" -->

<input type="hidden" name="ActionSave" value=""/>

<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onClick="document.all.ActionSave.value='1'; document.subscriptionObject.action='form_save.jsp'; document.subscriptionObject.target='_self';document.subscriptionObject.submit();">Save</a>&nbsp;
		</td>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onClick="document.all.ActionSave.value='2'; document.subscriptionObject.action='form_save.jsp'; document.subscriptionObject.target='_self';document.subscriptionObject.submit();">Clone</a>
		</td>
		<!--
		<td align="left" valign="middle">
			<a class="deletebutton" href="#" onClick="location.href='../jsp/servlet/deleteSubscriptionForm?FormId='">Delete</a>
		</td>
		-->
	</tr>
</table>
<br/><br/>

<!-- Header 1 -->
<table width="95%" class="main" cellpadding="0" cellspacing="0">
	<tr>
		<td class="sectionheader" align="left">
			<b class="sectionheader">Step 1:</b> Define Your Subscription Form
		</td>
	</tr>
</table>
<br/>

<!-- Data 1 -->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=left width=100%>
			<table class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td nowrap>&#x20;Form Name:&#x20;</td>
					<td>
						<input type="text" name="form_name" value="<%=HtmlUtil.escape(formName)%>" size="50">
					</td>
					<td nowrap>&#x20;Update Rule:&#x20;</td>
					<td>
						<SELECT name="upd_rule_id">
							<OPTION></OPTION>			
							<%=UpdateRule.toHtmlOptions(sUpdRuleId)%>
						</SELECT>
					</td>
				<tr>
					<td nowrap>&#x20;Form Type:&#x20;</td>
					<td>
						<select name="type_id" size="1">
							<%= htmlTypeOptionList %>
						</select>
					</td>
					<td nowrap>&#x20;Update Hierarchy:&#x20;</td>
					<td>
						<SELECT name="upd_hierarchy_id">
							<OPTION></OPTION>
							<%=Hierarchy.toHtmlOptions(sUpdHierarchyId)%>
						</SELECT>
					</td>
				</tr>
				<tr>
					<td nowrap>&#x20;Thank You Page URL:&#x20;</td>
					<td>
						<input type="text" name="confirm_url" value="<%=HtmlUtil.escape(confirmURL)%>" size="50">
					</td>
					<td nowrap>&#x20;Unsub Hierarchy:&#x20;</td>
					<td>
						<SELECT name="unsub_hierarchy_id">
							<OPTION></OPTION>
							<%=Hierarchy.toHtmlOptions(sUnsubHierarchyId)%>
						</SELECT>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br/><br/>

<!-- Header 2 -->
<table width="95%" class="main" cellpadding="0" cellspacing="0">
	<tr>
		<td class="sectionheader" align="left">
			<b class="sectionheader">Step 2:</b> Form Attributes</b>
		</td>
	</tr>
</table>
<br/>

<!-- Data 2 -->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EditTabOn id=tab2_Step1 width=150 onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Basic Options</td>
		<td class=EditTabOff id=tab2_Step2 width=150 onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Advanced Options</td>
		<td class=EditTabOff id=tab2_Step3 width=150 onclick="switchSteps('Tabs_Table2', 'tab2_Step3', 'block2_Step3');" valign=center nowrap align=middle>Elements Template</td>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100% colspan=4><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=4>
			<table class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td nowrap>
						Is prefill needed?
					</td>
					<td>
						<select name="prefill_flag">
						<option value="0" <%= prefillFlag.equals("0")?"selected":"" %>>No</option>
						<option value="1" <%= prefillFlag.equals("1")?"selected":"" %>>Yes</option>
						</select>
					</td>
				</tr>
									  
				<tr>
					<td nowrap>
						Is validation when prefilling needed?
					</td>
					<td>
						<select name="prefill_no_validate_flag">
						<option value="1" <%= prefillNoValidateFlag.equals("1")?"selected":"" %>>No</option>
						<option value="0" <%= prefillNoValidateFlag.equals("0")?"selected":"" %>>Yes</option>
						</select>
					</td>
				</tr>

				<tr>
					<td nowrap>
						Should this form post submissions immediately after submitted? (high priority)
					</td>
					<td>
						<select name="high_priority_flag">
							<option value="0" <%= highPriorityFlag.equals("0")?"selected":"" %>>No</option>
							<option value="1" <%= highPriorityFlag.equals("1")?"selected":"" %>>Yes</option>
						</select>
					</td>
				</tr>
				<tr>
					<td nowrap>
						Should recipient validation occur on posting?
					</td>
					<td>
						<select name="post_validate_flag">
							<option value="0" <%= postValidateFlag.equals("0")?"selected":"" %>>No</option>
							<option value="1" <%= postValidateFlag.equals("1")?"selected":"" %>>Yes</option>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block2_Step2 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=4>
			<table class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td nowrap>
						Should incomplete forms be used to update recipients? (Only for multipart forms)
					</td>
					<td>
						<select name="update_incomplete_flag">
							<option value="0" <%= updateIncompleteFlag.equals("0")?"selected":"" %>>No</option>
							<option value="1" <%= updateIncompleteFlag.equals("1")?"selected":"" %>>Yes</option>
						</select>
					</td>
				</tr>

				<!-- Select possible forms -->
				<tr>
					<td nowrap>
						Next form for multi-part forms:
					</td>
					<td>
						<select name="form_next_success">
							<option value="">None</option>
							<%= htmlNextFormOptionList %>
						</select>
					</td>
				</tr>
				<tr>
					<td nowrap>
						Alternate form to show user if recipient is not valid:
					</td>
					<td>
						<select name="form_alt_prefill_bad_recip">
							<option value="">None</option>
							<%= htmlBadRecipFormOptionList %>
						</select>
					</td>
				</tr>
				<tr>
					<td nowrap>
						Alternate form to show user if recipient is not found:
					</td>
					<td>
						<select name="form_alt_prefill_no_recip">
							<option value="">None</option>
							<%= htmlNoRecipFormOptionList %>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block2_Step3 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=4>
			<table class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td><b>Custom Field: </b><input type="text" width="100%" name="MacroName" size="27" disabled="disabled"/></td>
					<td align="center"><b>XSL Element</b></td>
				</tr>
				<tr valign="top">
					<td valign="top" align="left">
						<!-- <SELECT NAME="MacroList" SIZE="5" STYLE="width: 100%"> -->
						<select name="MacroList" Size="5" STYLE="width: 100%" onClick="ShowElement();">
							<%= htmlPers %>
						</select>
					</td>
					<td valign="top" align="left">
						<textarea name="XSLElement" rows="6" cols="100" style="width: 100%; height: 23mm"></textarea>
					</td>
				</tr>
				<tr>
					<td align="right"></td>
					<td align="right"><input type="button" class="subactionbutton" name="btnSelect" value="Select All" onClick="document.all.XSLElement.select();"/></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br/><br/>

<!-- Header 3 -->
<table width="95%" class="main" cellpadding="0" cellspacing="0">
	<tr>
		<td class="sectionheader" align="left">
			<b class="sectionheader">Step 3: </b> Create Your Form
		</td>
	</tr>
</table>
<br/>

<!-- Data 3 -->
<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EditTabOn id=tab3_Step1 width=150 onclick="switchSteps('Tabs_Table3', 'tab3_Step1', 'block3_Step1');" valign=middle nowrap align=center>Enter XSL</td>
		<td class=EditTabOff id=tab3_Step2 width=150 onclick="switchSteps('Tabs_Table3', 'tab3_Step2', 'block3_Step2');" valign=middle nowrap align=center>XSL Builder</td>
		<td class=EmptyTab valign=center nowrap align=middle width=350><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100% colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td class=fillTab valign=top align=left width=100% height=350 colspan=3>
			<table width="100%" class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td colspan="2">
						<textarea name="form_source" rows="20" cols="100" style="width:100%;"><%= HtmlUtil.escape(formSource) %></textarea>
					</td>
				</tr>
				<tr>
					<td align="right"><input type="button" class="subactionbutton" name="btnSelect" value="Select All" onClick="document.all.form_source.select();"/></td>
					<td align="left"><input type="button" class="subactionbutton" name="btnPreview" value="Preview" onClick="POpen()"/></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block3_Step2 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=left width=100% height=350 colspan=3>
			<table class="main" cellpadding="2" cellspacing="1">
				<tr valign="middle">
					<td width="40%" valign="middle" align="center">
						<!-- <SELECT NAME="AllFields" SIZE="20" STYLE="width: 100%"> -->
						<select name="AllFields" Size="20" style="width: 100%">
							<%= htmlPers %>
						</select>
					</td>
					<td width="20%" valign="middle" align="center">
						<input type="button" class="subactionbutton" name="AddR" value="Add Required >>" style="width: 90%" onClick="moveList(document.subscriptionObject.elements['AllFields'].selectedIndex, 'Yes', 0)"/><br/>
						<input type="button" class="subactionbutton" name="AddN" value="Add Non Required >>" style="width: 90%" onClick="moveList(document.subscriptionObject.elements['AllFields'].selectedIndex, 'No', 0)"/>
					</td>
					<td width="40%" valign="middle" align="center">
						<select name="SelectedFields" size="20" style="width: 100%">
						</select>
					</td>
				</tr>
				<tr>
					<td width="40%" align="right">&#x20;</td>
					<td width="20%" align="center"><input type="button" class="subactionbutton" name="btnCreate" value="Create XSL" onClick="GenerateForm();"/></td>
					<td width="40%" align="right">
						<input type="button" class="subactionbutton" name="btnDelete" value="Delete" style="width: 10mm" onClick="moveList(document.subscriptionObject.elements['SelectedFields'].selectedIndex, '', 1);"/>
						<input type="button" class="subactionbutton" name="btnUp" value="Up" style="width: 10mm" onClick="shiftList(document.subscriptionObject.elements['SelectedFields'].selectedIndex, 0);"/>
						<input type="button" class="subactionbutton" name="btnDown" value="Down" style="width: 10mm" onClick="shiftList(document.subscriptionObject.elements['SelectedFields'].selectedIndex, 1);"/>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br/><br/>

<!-- History Info -->
<table width="95%" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader" align="left">
			<b class="sectionheader">History</b>
		</td>
	</tr>
</table>
<BR/>

<!-- History Info  -->
<table class="main" cellpadding="2" cellspacing="1" width="95%">
     <tr>
          <td width="20%">Created by</td>
          <td width="30%"><u><%= creator %></u></td>
          <td width="20%">Modified by</td>
          <td width="30%"><u><%= modifier %></u></td>
     </tr>
     <tr>
          <td width="20%">Creation date</td>
          <td width="30%"><u><%= createDate %></u></td>
          <td width="20%">Modify date</td>
          <td width="30%"><u><%= modifyDate %></u></td>
     </tr>
</table>
<br/><br/>
</form>
</body>
</html>

<%
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>