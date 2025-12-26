<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.wfl.*,
		java.sql.*,java.io.*,java.util.*,
		org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

	//Is it the standard ui?
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	boolean canDynCont = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);

	String contID = request.getParameter("cont_id");
	if (!can.bWrite && contID == null)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
     String sAprvlRequestId = request.getParameter("aprvl_request_id");
     boolean isApprover = false;
     if (contID != null) {
          if (sAprvlRequestId == null)
               sAprvlRequestId = "";
          ApprovalRequest arRequest = null;
          if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
               arRequest = new ApprovalRequest(sAprvlRequestId);
          } else {
               logger.info("sAprvlRequestId was null or '', getting Approval Request for contID:" + contID);
               arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.CONTENT),contID);
          }
          if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
               sAprvlRequestId = arRequest.s_approval_request_id;
               isApprover = true;
          }
     }

     boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.CONTENT);
     boolean bContentDraft = false, bContentPending = false, bCampPending = false, bContentReady = false, bContentNew = false;
     if (contID != null) {
          Content cont = new Content(contID);
          bContentDraft = (ContStatus.DRAFT == Integer.parseInt(cont.s_status_id));
          bContentPending = (ContStatus.PENDING_APPROVAL == Integer.parseInt(cont.s_status_id));
          bCampPending = (ContStatus.PENDING_CAMP == Integer.parseInt(cont.s_status_id));
          bContentReady = (ContStatus.READY == Integer.parseInt(cont.s_status_id));
          logger.info("statuses for contID:" + contID + " are draft/pending/ready:" + bContentDraft + "/" + bContentPending + "/" + bContentReady);
     } else if (contID == null) {
          bContentNew = true;
     }

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String contName="New Content",contStatus="",sendType="",contHTML="",contText="",contAOL="";
	String creator="",creationDate="",editor="",modifyDate="",firstPers="",firstBlock="";
	String unsubID="",unsubPosition="",textFlag="",htmlFlag="",aolFlag="";
	
	int contTypeID = ContType.CONTENT;
	String ctiDocID = "";
	boolean isPrint = false;

	String htmlTracking = "";
	String htmlPersonals = "";
	String htmlStatuses = "";
	String htmlCharsets = "";
	String htmlCurPers = "";
	String jsPersonals = "";
	String jsSubmitPers = "";
	String htmlLogicBlocks = "";
	String htmlUnsubs = "";
	String htmlCategories = "";
	String htmlUnsubContent = "";
	String textUnsubContent = "";
	String aolUnsubContent = "";
	String jsUnsubs = "";

	String htmlCurBlocks = getLogicBlockListHtml(contID);

	// === === ===

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;

	String sSql = null;
	byte[] b = null;
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		if (contID!=null)
		{
			rs = stmt.executeQuery("Exec dbo.usp_ccnt_info_get "+contID);
			if (rs.next())
			{
				b = rs.getBytes("Name");
				contName = (b==null)?"":new String(b,"UTF-8");
				contStatus = rs.getString("Status");
				sendType = rs.getString("SendType");
				contTypeID = rs.getInt("TypeID");
				ctiDocID = rs.getString("ctiDocID");
				
				b = rs.getBytes("HTML");				
				contHTML = (b==null)?"":new String(b,"UTF-8");
				b = rs.getBytes("Text");
				contText = (b==null)?"":new String(b,"UTF-8");
				b = rs.getBytes("AOL");
				contAOL = (b==null)?"":new String(b,"UTF-8");
				
				unsubID = rs.getString("unsub_msg_id");
				unsubPosition = rs.getString("unsub_msg_position");
				textFlag = rs.getString("send_text_flag");
				htmlFlag = rs.getString("send_html_flag");
				aolFlag = rs.getString("send_aol_flag");
				creator = rs.getString("creator");
				creationDate = rs.getString("create_date");
				editor = rs.getString("modifier");
				modifyDate = rs.getString("modify_date");
			}
			rs.close();

			sSql =
				" SELECT link_name, href" +
				" From cjtk_link" +
				" WHERE cont_id=" + contID;

			rs = stmt.executeQuery(sSql);
			
			
			boolean bShowButton = (can.bWrite && !(bWorkflow && bContentPending) && !bCampPending);
			while (rs.next())
			{
				htmlTracking += "<tr>\n";
				htmlTracking += (bShowButton?"<td align=\"right\" valign=\"middle\" nowrap><a class=\"subactionbutton\" href=\"#EditLink\" onclick=\"EditLinkTable(event)\">edit</a></td>\n":"");
				b = rs.getBytes(1);
				
				htmlTracking += "<td align=\"left\" valign=\"middle\">"+((b==null)?"":new String(b,"UTF-8"))+"</td>\n";
				htmlTracking += "<td align=\"left\" valign=\"middle\"><div style=\"overflow:hidden; text-overflow:ellipsis;\"><a title=\"Click here to verify that your link is valid.\" href=\"javascript:void(0);\" onclick=\"launchURL();\">"+HtmlUtil.escape(rs.getString(2))+"</a></div></td>\n";
				htmlTracking += (bShowButton?"<td align=\"right\" valign=\"middle\" nowrap><a class=\"resourcebutton\" href=\"#EditLink\" onclick=\"CloneLinkTable(event)\">clone</a></td>\n":"");
				htmlTracking += (bShowButton?"<td align=\"right\" valign=\"middle\" nowrap><a class=\"resourcebutton\" href=\"javascript:void(0);\" onclick=\"DeleteLinkTable(event)\">delete</a></td>\n":"");
				htmlTracking += "</tr>\n";
			}
			rs.close();
		}

		//Unsubscribes
		if (unsubID == null) unsubID = "-1";
		if (unsubPosition == null) unsubPosition = "-1";
		String tmpUnsubID = "";
		
		sSql = 
			" SELECT msg_id, ISNULL(msg_name,''), ISNULL(html_msg,''), ISNULL(text_msg,''), ISNULL(aol_msg,'') " +
			" FROM ccps_unsub_msg WHERE cust_id = "+cust.s_cust_id;
							   
		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			tmpUnsubID = rs.getString(1);
			if (unsubID.equals(tmpUnsubID))
			{
				htmlUnsubs += "<option selected value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
			}
			else
			{
				htmlUnsubs += "<option value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
			}
			
			htmlUnsubContent +=
				"<textarea style=display:none name=UnsubContentHTML"+tmpUnsubID+">"+
				new String(rs.getBytes(3),"UTF-8")+"</textarea>\n";
				
			textUnsubContent +=
				"<textarea style=display:none name=UnsubContentText"+tmpUnsubID+">"+
				new String(rs.getBytes(4),"UTF-8")+"</textarea>\n";
				
			aolUnsubContent +=
				"<textarea style=display:none name=UnsubContentAOL"+tmpUnsubID+">"+
				new String(rs.getBytes(5),"UTF-8")+"</textarea>\n";

			jsUnsubs += "if (document.all.unsubID.value == "+tmpUnsubID+") {\n" +
						"	if (act=='1') unTxt = FT.UnsubContentText"+tmpUnsubID+".value;\n" +
						"	if (act=='2') unTxt = FT.UnsubContentHTML"+tmpUnsubID+".value;\n" +
						"	if (act=='3') unTxt = FT.UnsubContentAOL"+tmpUnsubID+".value;\n" +
						"}\n";
		}
		rs.close();

		//Personalization
		String attrName,attrDisplayName,tmp,defaultValue,attrID;
		int i,j;
		sSql = 
			" SELECT c.attr_id, attr_name, display_name " +
			" FROM ccps_attribute a, ccps_cust_attr c " +
			" WHERE c.cust_id = "+cust.s_cust_id+" AND a.attr_id = c.attr_id " +
			" AND display_seq IS NOT NULL " +
			" ORDER BY display_seq";

		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			attrID = rs.getString(1);
			attrName = rs.getString(2);
			b = rs.getBytes(3);
			attrDisplayName = (b==null)?"":new String(b,"UTF-8");
			if (firstPers.length() == 0) firstPers = attrName;
			htmlPersonals += "<option value=\""+attrName+"\">"+attrDisplayName+"</option>\n";
			
			//Scan the contents for Personalization
			String allConts = contText + contHTML + contAOL;
			if (allConts != null && allConts.length() != 0)
			{
				i = allConts.indexOf("!*"+attrName+";");
				if (i != -1) {
					tmp = allConts.substring(i);
					j = tmp.indexOf("*!");
					if (j != -1) {
						defaultValue = tmp.substring(3+attrName.length(),j);
						htmlCurPers += "<tr><td>"+attrDisplayName+"</td>\n" +
									   "<td><input type=text name=curDefault"+attrID+" value=\""+defaultValue+"\">\n";
//									   "<img src=\"../../images/updateandscan.gif\" style=\"cursor:hand\" onclick=\"scanContentForPers("+attrID+")\"></td></tr>\n";
						jsPersonals += "if (attrID == "+attrID+") {\n" +
									   "	newDefault = FT.curDefault"+attrID+".value;\n" +
									   "	attrName = '"+attrName+"';\n}\n";
						jsSubmitPers += "scanContentForPers("+attrID+");\n";
					}
				}
			}			
		}
		rs.close();

		if (htmlCurPers.length() == 0) htmlCurPers = "<tr><td colspan=2>None</td></tr>\n";

		//Logic Blocks
		String logicBlockID, logicBlockName;
		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
		{
			sSql = 
				" SELECT cont_id, cont_name" +
				" FROM ccnt_content " +
				" WHERE cust_id = " + cust.s_cust_id +
				" AND type_id = 25 " +
				" AND status_id = 20 " +
				" AND origin_cont_id IS NULL " +
				" ORDER BY cont_name";
			
		}
		else
		{
			sSql =
				" SELECT cont_id, cont_name" +
				" FROM ccnt_content b, ccps_object_category oc " +
				" WHERE b.cust_id = " + cust.s_cust_id +
				" AND b.type_id = 25 " +
				" AND b.status_id = 20 " +
				" AND b.cont_id = oc.object_id" +
				" AND origin_cont_id IS NULL " +
				" AND oc.type_id = " + ObjectType.CONTENT +
				" AND oc.cust_id = " + cust.s_cust_id +
				" AND oc.category_id = " + sSelectedCategoryId +
				" ORDER BY cont_name";
		}
		
		rs = stmt.executeQuery(sSql);		
		while (rs.next())
		{
			logicBlockID = rs.getString(1);
			b = rs.getBytes(2);
			logicBlockName = (b==null)?"":new String(b,"UTF-8");
			
			if (firstBlock.length() == 0) firstBlock = logicBlockName+";"+logicBlockID;
			htmlLogicBlocks += "<option value="+logicBlockID+">"+logicBlockName+"</option>\n";
		}
		rs.close();

		//Statuses
		String tmpStatusID = "";
		sSql =
			" SELECT status_id, status_name" +
			" FROM ccnt_cont_status" +
			" WHERE UPPER(status_name) <> 'DELETED' " +
               " AND UPPER(status_name) NOT LIKE '%PENDING%' ";
		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			tmpStatusID = rs.getString(1);
			if (contStatus.equals(tmpStatusID))
				htmlStatuses += "<option selected value="+tmpStatusID+">"+rs.getString(2)+"</option>\n";
			else
				htmlStatuses += "<option value="+tmpStatusID+">"+rs.getString(2)+"</option>\n";
		}
		rs.close();
		
		//Charsets
		String tmpCharsetID = "";
		rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
		while (rs.next())
		{
			tmpCharsetID = rs.getString(1);			
			if (sendType.equals(tmpCharsetID))
				htmlCharsets += "<option selected value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";
			else
				htmlCharsets += "<option value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";			
		}
		rs.close();

		htmlCategories =
			CategortiesControl.toHtmlOptions(cust.s_cust_id, ObjectType.CONTENT, contID, sSelectedCategoryId);
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
	
	if (contTypeID == ContType.PRINT) isPrint = true;
%>

<html>
<head>
<title>Content</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<script language="javascript">
<!--
function ShowHide(val)
{
	if (val[0].style.display == 'none') val[0].style.display = '';
	else val[0].style.display='none';
	if (val[1].style.display == 'none') val[1].style.display = '';
	else val[1].style.display='none';
}
-->
</script>
<SCRIPT LANGUAGE="JAVASCRIPT">
<%@ include file="../../js/scripts.js" %>
<%@ include file="../../js/disable_forms.js" %>



function PreviewURL(freshurl)
{
	SmallWin = window.open(freshurl, 'FormList','scrollbars=yes,resizable=yes,toolbar=no,width=650,height=250');
}

function LibraryURL(imgurl)
{
	SmallWin = window.open(imgurl, 'ImageLibrary','scrollbars=yes,resizable=yes,toolbar=no,width=650,height=500');
}

function DeleteLink()
{
	if (FT.TrackURLs.length==0) return;
	if (FT.TrackURLs.selectedIndex != -1)
		FT.TrackURLs.remove(FT.TrackURLs.selectedIndex);
}

function AddLink()
{
	if (FT.MapFrom.value=='') return;
	if (FT.MapTo.value=='') return;

	var oOption = document.createElement("OPTION");
	oOption.text=FT.MapFrom.value;
	oOption.value=FT.MapTo.value;
	FT.TrackURLs.add(oOption);

	FT.MapFrom.value='';
	FT.MapTo.value='';
}

function CloneLink()
{
	if (FT.TrackURLs.length==0) return;
	if (FT.TrackURLs.selectedIndex != -1)
	{
		FT.MapFrom.value = FT.TrackURLs.options[FT.TrackURLs.selectedIndex].text;
		FT.MapTo.value = FT.TrackURLs.options[FT.TrackURLs.selectedIndex].value;
	}
}

function EditLink(){
	if (FT.TrackURLs.length==0) return;
	if (FT.TrackURLs.selectedIndex != -1)
	{
		FT.MapFrom.value = FT.TrackURLs.options[FT.TrackURLs.selectedIndex].text;
		FT.MapTo.value = FT.TrackURLs.options[FT.TrackURLs.selectedIndex].value;
		FT.TrackURLs.remove(FT.TrackURLs.selectedIndex);
	}
}

function launchURL(event)
{
	var oElem = window.event.srcElement? window.event.srcElement : window.event.target;
	while (oElem.tagName != "A") oElem = oElem.parentElement;
	var newURL = oElem.innerText;
	CheckURLWin = window.open(newURL, "CheckURL","scrollbars=yes,resizable=yes,location=yes,toolbar=yes,status=yes,menubar=yes,height=400,width=600");
}

// optimized for non i.e browsers by zafer 08.09.2011
function DeleteLinkTable(evt)
{
	var rIndex;
	
	var oElem = evt.srcElement? evt.srcElement : evt.target;
	
	while (oElem.tagName != "TR")
	{
		oElem = oElem.parentNode;
	}
	
	rIndex = oElem.rowIndex;
	
	var oTable = oElem;
	while (oTable.tagName != "TABLE")
	{
		oTable = oTable.parentNode;
	}
	
	oTable.deleteRow(rIndex);
}

// optimized for non i.e browsers by zafer 08.09.2011
function AddLinkTable(evt)
{
	var LinkName;
	var LinkURL;
	var newRow;
	var newCell;
	
	FT.EditLinkName.value = FT.EditLinkName.value.replace(/(^\s*)|(\s*$)/g, '');
	FT.EditLinkURL.value = FT.EditLinkURL.value.replace(/(^\s*)|(\s*$)/g, '');

	LinkName = FT.EditLinkName.value;
	LinkURL = FT.EditLinkURL.value;

	if (LinkName=='') return;
	if (LinkURL=='') return;
		
	var oTable = document.getElementById("LinkTable");
	
	try {
		newRow = oTable.insertRow(0);
	}
	catch(ex) {
		newRow = oTable.insertRow();
	}
	
	try {
		newCell = newRow.insertCell(0);
	}
	catch(ex) {
		newCell = newRow.insertCell();
	}
	
	
	newCell.align = "right";
	newCell.vAlign = "middle";
	newCell.noWrap = true;
	newCell.innerHTML = "<a class=\"subactionbutton\" href=\"#EditLink\" onclick=\"EditLinkTable(event)\">edit</a>";
	
	
	try {
		newCell = newRow.insertCell(1);
	}
	catch(ex) {
		newCell = newRow.insertCell();
	}
	
	newCell.align = "left";
	newCell.vAlign = "middle";
	newCell.innerHTML = LinkName;
	
	
	try {
		newCell = newRow.insertCell(2);
	}
	catch(ex) {
		newCell = newRow.insertCell();
	}
	
	newCell.align = "left";
	newCell.vAlign = "middle";
	newCell.innerHTML = "<div style=\"overflow:hidden; text-overflow:ellipsis; width:400px;\"><a title=\"Click here to verify that your link is valid.\" href=\"javascript:void(0);\" onclick=\"launchURL();\">" + LinkURL + "</a></div>";
	
	
	try {
		newCell = newRow.insertCell(3);
	}
	catch(ex) {
		newCell = newRow.insertCell();
	}
	
	newCell.align = "right";
	newCell.vAlign = "middle";
	newCell.noWrap = true;
	newCell.innerHTML = "<a class=\"resourcebutton\" href=\"#EditLink\" onclick=\"CloneLinkTable(event)\">clone</a>";
	
	
	try {
		newCell = newRow.insertCell(4);
	}
	catch(ex) {
		newCell = newRow.insertCell();
	}
	
	newCell.align = "right";
	newCell.vAlign = "middle";
	newCell.noWrap = true;
	newCell.innerHTML = "<a class=\"resourcebutton\" href=\"javascript:void(0);\" onclick=\"DeleteLinkTable(event)\">delete</a>";

	FT.EditLinkName.value = "";
	FT.EditLinkURL.value = "";
}

// optimized for non i.e browsers by zafer 08.09.2011
function CloneLinkTable(evt)
{
	var LinkName;
	var LinkURL;
	
	var oElem = evt.srcElement? evt.srcElement : evt.target;
	
	while (oElem.tagName != "TR")
	{
		oElem = oElem.parentNode;
	}
	
	
	LinkName = oElem.cells[1].textContent? oElem.cells[1].textContent :  oElem.cells[1].innerText;
	LinkURL = oElem.cells[2].textContent? oElem.cells[2].textContent :  oElem.cells[2].innerText;
	
	FT.EditLinkName.value = LinkName;
	FT.EditLinkURL.value = LinkURL;
}

// optimized for non i.e browsers by zafer 08.09.2011
function EditLinkTable(evt)
{
	var LinkName;
	var LinkURL;
	var rIndex;
	
	var oElem = evt.srcElement? evt.srcElement : evt.target;
	
	while (oElem.tagName != "TR")
	{
		oElem = oElem.parentNode;
	}
	
	LinkName = oElem.cells[1].textContent? oElem.cells[1].textContent :  oElem.cells[1].innerText;
	LinkURL = oElem.cells[2].textContent? oElem.cells[2].textContent :  oElem.cells[2].innerText;	
	
	
	FT.EditLinkName.value = LinkName;
	FT.EditLinkURL.value = LinkURL;
	
	rIndex = oElem.rowIndex;
	
	var oTable = oElem;
	while (oTable.tagName != "TABLE")
	{
		oTable = oTable.parentNode;
	}
	
	oTable.deleteRow(rIndex);
}

// Pozitionize after clisk
function ShowBack(Mask){

	for (var i = 0; i < FT.PerzFields.length; i++){
		if(FT.PerzFields.options[i].value == Mask){
			FT.PerzFields.selectedIndex = i;
			FT.DefaultValue.value=FT.PerzDefaults.options[i].text;
			FT.MergeSymbol.value='!*' + Mask + '*!';
			return;
		}
	}
}

function dynamic_popup()
{
	URL = 'cont_preview_frame.jsp?cont_id=<%= contID %>';
	windowName = 'preview_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=650, width=700';
       	SmallWin = window.open(URL, windowName, windowFeatures);
}

function WinOpen(WinTxt, act)
{
	var winl = (screen.width - 650) / 2;
	var wint = (screen.height - 400) / 2;
	
	// center & show (650x800)
	winprops = 'height=400,width=650,top='+wint+',left='+winl+',scrollbars=yes,resizable'
	msg=window.open('','msg',winprops);

	var unTxt = '';
	<%= jsUnsubs %>

	if (FT.unsubPos.value == 1) {
		//Bottom
		if (act=='1') msg.document.write('<textarea cols=65 rows=20 wrap=hard>' + WinTxt + '</textarea><br><br><br>' + unTxt);
		if (act=='2') msg.document.write(WinTxt + '<br><br><br>' + unTxt);
		if (act=='3') msg.document.write(stripPRE(WinTxt + '<br><br><br>' + unTxt));			
	} else if (FT.unsubPos.value == 0) {
		//Top
		if (act=='1') msg.document.write(unTxt +'<br><br><br><textarea cols=65 rows=20 wrap=hard>' + WinTxt + '</textarea>');
		if (act=='2') msg.document.write(unTxt + '<br><br><br>' + WinTxt);
		if (act=='3') msg.document.write(stripPRE(unTxt + '<br><br><br>' + WinTxt));
	} else if (FT.unsubPos.value == -1) {
		//Top and bottom
		if (act=='1') msg.document.write(unTxt +'<br><br><br><textarea cols=65 rows=20 wrap=hard>' + WinTxt + '</textarea><br><br><br>' + unTxt);
		if (act=='2') msg.document.write(unTxt + '<br><br><br>' + WinTxt + '<br><br><br>' + unTxt);
		if (act=='3') msg.document.write(stripPRE(unTxt + '<br><br><br>' + WinTxt + '<br><br><br>' + unTxt));
	}
	msg.document.close();
}

function stripPRE( inString )
{
	var outString = inString;
	while ( outString.indexOf( '<PRE>' ) > - 1 )
		outString = outString.replace( '<PRE>', '' );
	while ( outString.indexOf( '</PRE>' ) > - 1 )
		outString = outString.replace( '</PRE>', '' );
	while ( outString.indexOf( '<pre>' ) > - 1 )
		outString = outString.replace( '<pre>', '' );
	while ( outString.indexOf( '</pre>' ) > - 1 )
		outString = outString.replace( '</pre>', '' );
	return outString;
}

function SubmitLogic(Act,logicID){
	FT.destLogicID.value = logicID;
	SubmitPrepare(Act);
}

// optimized for non i.e browsers by zafer 08.09.2011
function SubmitPrepare(Act)
{
	if(!FT) {
		var FT = document.forms['FT'];
	}
	
	// Check the text
	if(FT.ContentText.value.length == 0)
	{
		alert("Please enter something for the Text Content");
		return;
	}
	
	FT.ContentName.value = FT.ContentName.value.replace(/(^\s*)|(\s*$)/g, '');
	if (FT.ContentName.value.length == 0)
	{
		alert("Please enter a Name for this Content");
		return;
	}
	
	<% if (isPrint) { %>
	if ((Act == "0" || Act == "2") && (FT.ContentName.value == FT.ContentName.defaultValue))
	{
		alert("Please enter a new and different name for the cloned content.");
		return;
	}
	<% } %>

	var oTable = document.getElementById("LinkTable");
		
	for (i=0; i < oTable.rows.length; i++)
	{
		if (oTable.rows[i].cells[0].className != "subsectionheader")
		{

			var optText = oTable.rows[i].cells[2].textContent? oTable.rows[i].cells[2].textContent : oTable.rows[i].cells[2].innerText;
			var optVal =  oTable.rows[i].cells[1].textContent? oTable.rows[i].cells[1].textContent : oTable.rows[i].cells[1].innerText;
	
			var oOption = document.createElement("option");
			oOption.text = optText;
			oOption.value = optVal;
			oOption.value += "\n" + oOption.text;
			oOption.selected = true;
			
			try {
			    FT.TrackURLs.add(oOption,null); // non IE only
			  }
			  catch(ex) {
			    FT.TrackURLs.add(oOption); // IE only
  			}
  
			
		}
	}

	if (Act == '3')
	{
		<%= jsSubmitPers %>
	}
	else if (Act == '3a')
	{
		Act = '3'
	}

	FT.ActionSave.value = Act;
     undisable_forms();
	FT.submit();
}

function replacePers(vtext,attrName,newDefault)
{
	tmp = vtext;
	i = tmp.indexOf('!*'+attrName+';');
	offset = 0;
	while (i != -1) {
		tmp = tmp.substring(i);
		j = tmp.indexOf('*!');
		if (j != -1) {
			vtext = vtext.substring(0,offset+i+3+attrName.length)+newDefault+tmp.substring(j);

			offset += attrName.length+newDefault.length+3+i;
			tmp = tmp.substring(j);
			i = tmp.indexOf('!*'+attrName+';');
		} else {
			i = -1;
		}
	}
	return vtext;
}

//Search each content for personalization symbols - '!*attr_name;default value*!'
function scanContentForPers(attrID)
{
	var newDefault;
	var attrName;
	<%= jsPersonals %>
	
	var vtext = FT.ContentText.value;
	var vhtml = FT.ContentHTML.value;
	var vaol = FT.ContentAOL.value;
	
	if(vtext != null && vtext.length != 0) {
		FT.ContentText.value = replacePers(vtext,attrName,newDefault);
	}
	if(vhtml != null && vhtml.length != 0) {
		FT.ContentHTML.value = replacePers(vhtml,attrName,newDefault);
	}
	if(vaol != null && vaol.length != 0) {
		FT.ContentAOL.value = replacePers(vaol,attrName,newDefault);
	}

}

function RequestApproval() {

     // FT.action="../workflow/approval_request_edit.jsp?object_type=" + <%=ObjectType.CONTENT%> + "&object_id=" + <%=contID%>;
     SubmitPrepare('7');

}

function workflow_approve() {
     undisable_forms()
     FT.action = "../workflow/approval_send.jsp"
     FT.disposition_id.value = "10"     // approve
     FT.submit()
}

function workflow_reject() {
     undisable_forms()
     FT.action = "../workflow/approval_edit.jsp"
     FT.disposition_id.value = "90"     // reject
     FT.submit()
}

function workflow_approve_w_comments() {
     undisable_forms()
     FT.action = "../workflow/approval_edit.jsp"
     FT.disposition_id.value = "10"     // approve
     FT.submit()
}

function undisable_forms()
{
	var l = document.forms.length;
	for(var i=0; i < l; i++)
	{
		var m = document.forms[i].elements.length;
		for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = false;
	}
     FT.action = "cont_save.jsp"      //disable_forms clears this out (I think)
}

function reset_draft_status()
{
     FT.Statuses.value = <%=ContStatus.DRAFT%>
     SubmitPrepare('1')
}


if (1 == <%= (request.getParameter("popup") != null?"1":"0") %>)
	dynamic_popup();

</SCRIPT>
<script language="javascript" src="../../js/tab_script.js"></script>

<body<%= (!can.bWrite || (bWorkflow && bContentPending) || bCampPending)?" onload='disable_forms()'":" " %>>
<form name="FT" method="post" action="cont_save.jsp" style="display:inline;">
<%
String tableWidth = "650px";
String step1Height = "140";
if (isPrint)
{
	tableWidth = "100%";
	step1Height = "110";
}
%>
<table cellpadding="0" cellspacing="0" border="0" class="layout" style="width:<%= tableWidth %>;">
	<col>
<% if (can.bWrite) { %>
	<tr height="30">
		<td valign="middle">
			<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>

			<!-- Content ID -->

			<input type=hidden name=contentID value="<%=((contID!=null)?contID:"")%>">
			<input type=hidden name=ctiDocID value="<%=((ctiDocID!=null)?ctiDocID:"")%>">
			<input type=hidden name=destLogicID value="">

			<input type="hidden" name="disposition_id" value="0"/>
			<input type="hidden" name="object_type" value="<%=String.valueOf(ObjectType.CONTENT)%>"/>
			<input type="hidden" name="object_id" value="<%=(contID != null)?contID:"0"%>"/>
			<INPUT TYPE="hidden" NAME="aprvl_request_id" value="<%=sAprvlRequestId%>">
			<input type="hidden" name="contTypeID" value="<%= String.valueOf(contTypeID) %>"/>

			<!--- Context Help Code -- Do Not Remove //-->
			<DIV id="TipLayer" style="visibility:hidden;position:absolute;z-index:1000;top:-100"></DIV>
			<SCRIPT language="JavaScript1.2" src="../../js/help_style.js" type="text/javascript"></SCRIPT>
			<!--- Context Help Code -- Do Not Remove //-->

			<%= htmlUnsubContent %>
			<%= textUnsubContent %>
			<%= aolUnsubContent %>

			<!-- Unsubscription Text default 
			        <xsl:element name="input">
			        <xsl:attribute name="type">hidden</xsl:attribute>
			        <xsl:attribute name="name">UnsubContentText</xsl:attribute>
			        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentText"/></xsl:attribute>
			        </xsl:element>

			<!-- Unsubscription HTML default 
			        <xsl:element name="input">
			        <xsl:attribute name="type">hidden</xsl:attribute>
			        <xsl:attribute name="name">UnsubContentHTML</xsl:attribute>
			        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentHTML"/></xsl:attribute>
			        </xsl:element>

			<!-- Unsubscription AOL default 
			        <xsl:element name="input">
			        <xsl:attribute name="type">hidden</xsl:attribute>
			        <xsl:attribute name="name">UnsubContentAOL</xsl:attribute>
			        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentAOL"/></xsl:attribute>
			        </xsl:element>
			-->

			<!-- Subscribe URL default
			        <xsl:element name="input">
			        <xsl:attribute name="type">hidden</xsl:attribute>
			        <xsl:attribute name="name">SubscribeURL</xsl:attribute>
			        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/SubscribeURL"/></xsl:attribute>
			        </xsl:element>
			-->
			<input type="hidden" name="ActionSave" value="0"/>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
			     <% 
			     if (((contID == null) || !bWorkflow || (bWorkflow && bContentDraft) || (bWorkflow && bContentReady && can.bApprove)) && !bCampPending) {
			     %>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="SubmitPrepare('1')">Save</a>
					</td>
				<%
			     } 
			     if (bWorkflow && !bContentPending && !can.bApprove && !bContentNew && !bCampPending) {
			     %>
						<td align="left" valign="middle">
							<a class="savebutton" href="#" onClick="RequestApproval();">Request Approval</a>
						</td>
			     <%
			     }
				if (contID != null)
				{
					%>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="SubmitPrepare('2')">Clone</a>
					</td>
					<%
					if(ui.getUIMode() != ui.SINGLE_CUSTOMER)
					{
						%>				
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="SubmitPrepare('0')">Clone to Destination</a>
					</td>
						<%
					}

			          if (bWorkflow && bContentPending && can.bApprove && isApprover) {
						%>				
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="workflow_approve()">Approve</a>
					</td>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="workflow_approve_w_comments()">Approve w/ Comments</a>
					</td>
					<td vAlign="middle" align="left">
						<a class="deletebutton" href="#" onclick="workflow_reject()">Reject</a>
					</td>
						<%
			          }
				
					if (can.bDelete && (!bWorkflow || (bWorkflow && !bContentPending)) && !bCampPending)
					{
						%>
					<td vAlign="middle" align="left">
						<a class="deletebutton" href="#" onclick="if (confirm('Deleting this Content may effect any Draft Campaigns to which the Content is assigned.\n(Ongoing Campaigns will not be effected).\nAre you sure you want to proceed?'))location.href='cont_delete.jsp?cont_id=<%= contID %><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>'">Delete</a>
					</td>
						<%
					}
				}
				%>
				</tr>
			</table>
		</td>
	</tr>
<%
}

String step1Col = " colspan=\"3\"";
if (isPrint) step1Col = "";
%>
	<tr height="30">
		<td valign="middle">
			<!--- Step 1 Header----->
			<table width="100%" class=main cellspacing=0 cellpadding=0>
				<tr>
					<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Name Your Content</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="<%= step1Height %>">
		<td valign="top">
			<!---- Step 1 Info----->
			<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width="100%" border=0>
				<% if (isPrint) { %>
				<tr>
					<td class=EmptyTab valign=top align=left width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<% } else { %>
				<tr>
					<td class=EditTabOn id=tab1_Step1 width=150 onclick="toggleTabs('tab1_Step','block1_Step',1,2,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>General Information</td>
					<td class=EditTabOff id=tab1_Step2 width=150 onclick="toggleTabs('tab1_Step','block1_Step',2,2,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Content Information</td>
					<td class=EmptyTab valign=center nowrap align=middle width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<% } %>
				<tr>
					<td class=fillTabbuffer valign=top align=left width="100%"<%= step1Col %>><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block1_Step1>
				<tr>
					<td class=fillTab valign=top align=center width="100%"<%= step1Col %>>
						<table class=main cellspacing=1 cellpadding=2 width="100%">
							<tr>
								<td width="120">Status</td>
								<td width="50%">
									<!-- Status list -->
									<select name=Statuses size=1 <%=(bWorkflow && !can.bApprove)?"disabled":""%>>
										<%= htmlStatuses %>
									</select>
			                              <% if (bWorkflow && !can.bApprove && bContentReady) {
			                              %>
			                                   <a class="savebutton" href="#" onclick="reset_draft_status()">Set back to Draft status & Save</a> 
			                              <% }
			                              %>
								</td>
								<td<%=!canCat.bRead?" style=\"display:'none'\"":""%> rowspan="2" width="80">Categories</td>
								<td<%=!canCat.bRead?" style=\"display:'none'\"":""%> rowspan="2" width="50%">
									<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="5" style="width:100%;">
										<%= htmlCategories %>
									</SELECT>
									<%=(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
									?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
									:""%>
								</td>
							</tr>
							<tr>
								<td width="120" nowrap>Content Name</td>
								<td width="50%">
									<input type="text"  name="ContentName"  Value="<%= contName %>" size="20" style="width:100%;" maxlength="50">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block1_Step2 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width="100%"<%= step1Col %>>
						<table class=main cellspacing=1 cellpadding=2 width="100%">
							<tr>
								<td width="150">Send Type</td>
								<td width="475">
									<!-- Send type list-->
									<select name=SendTypes size=1>
										<%= htmlCharsets %>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Unsubscribe Message</td>
								<td width="475">
									<select name=unsubID size=1>
										<%= htmlUnsubs %>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Position of Unsubscribe Message</td>
								<td width="475">
									<select name=unsubPos size=1>
										<option <%= (unsubPosition.equals("1")?"selected":"") %> value=1>Bottom</option>
										<option <%= (unsubPosition.equals("0")?"selected":"") %> value=0>Top</option>
										<option <%= (unsubPosition.equals("-1")?"selected":"") %> value=-1>Top and Bottom</option>
									</select>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>

<% if (isPrint) { %>

	<tr height="30">
		<td valign="middle">
			<textarea style="display:none;" name="ContentText">Print Content</textarea>
			<input type="hidden" name="ContentHTML" value="Print Content">
			<input type="hidden" name="ContentAOL" value="Print Content">
			<select name="TrackURLs" style="display:none;" multiple="MULTIPLE"></select>
			<table id="LinkTable" style="display:none;">
				<tr>
					<td class="subsectionheader"></td>
				</tr>
			</table>
			<!--- Step 1 Header----->
			<table width="100%" class=main cellspacing=0 cellpadding=0>
				<tr>
					<td class="sectionheader" width="100%">&nbsp;<b class=sectionheader>Step 2:</b> Edit the Content</td>
					<td align="right" width="75" nowrap>&nbsp;&nbsp;<a href="javascript:dynamic_popup();" class="subactionbutton">Preview</a>&nbsp;&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="600">
		<td valign="top">
			<table id="Tabs_Table2" cellspacing=0 cellpadding=0 border=0 class="layout" style="width:100%; height:100%;">
				<col>
				<tr height="2">
					<td class=EmptyTab valign=top align=left><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr height="2">
					<td class=fillTabbuffer valign=top align=left><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTab valign=top align=center>
						<table cellspacing=1 cellpadding=0 class="main layout" style="width:100%; height:100%;">
							<col>
							<tr>
								<td style="padding:0px;"><iframe name="cont_edit" src="../print/login.jsp?action=EditDocument&cont_id=<%= contID %>" style="width:100%; height:100%;" frameborder="0" border="0" scrolling="auto"></iframe></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>

<% } else { %>

	<tr height="30">
		<td valign="middle">
			<!----Step 2 Header ---->
			<table width="100%" class=main cellspacing=0 cellpadding=0>
				<tr>
					<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Personalize Your Content</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="230">
		<td valign="top">
			<!---Step 2 Info------->
			<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width="100%" border=0>
				<tr>
					<td class=EditTabOn id=tab2_Step1 width=150 onclick="toggleTabs('tab2_Step','block2_Step',1,2,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Available Options</td>
					<td class=EditTabOff id=tab2_Step2 width=150 onclick="toggleTabs('tab2_Step','block2_Step',2,2,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Current Personalization</td>
					<td class=EmptyTab valign=center nowrap align=middle width="350"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTabbuffer valign=top align=left width="100%" colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block2_Step1>
				<tr>
					<td class=fillTab valign=top align=left width="100%" colspan=3>
						<table class="main" width="100%" cellpadding="2" cellspacing="1">
							<tr>
								<td align="left" valign="top" width="50%">
									<table width=100% cellpadding="0" cellspacing="0">
										<tr>
											<td align="left" valign="middle" width="100%" class="subsectionheader"><b>Personalization</b></td>
											<td align="right" class="subsectionheader"><a class="resourcebutton" href="javascript:void(0);" onMouseOver="stm(Text[0],Style[0])" onmouseout="htm()">[?]</a></td>
										</tr>
										<tr>
											<td align="left" valign="middle" width="100%" colspan="2">
												<table cellpadding="2" cellspacing="1" width="100%">
													<tr>
														<td align="left" valign="middle">
															Personalization Field:<br>
															<select name=PerzFields size=1 onchange="FT.MergeSymbol.value='!*'+this.value+';'+FT.DefaultValue.value+'*!';">
																<%= htmlPersonals %>		
															</select>
														</td>
													</tr>
													<tr>
														<td align="left" valign="middle">
															Default Value:<br>
															<!-- Default value -->
															<input type=text name="DefaultValue" size=22 onkeyup="FT.MergeSymbol.value='!*'+FT.PerzFields.options[FT.PerzFields.selectedIndex].value+';'+this.value+'*!';">
														</td>
													</tr>
													<tr>
														<td align="left" valign="middle">
															Merge Symbol:<br>
															<!-- PickUp value -->
															<input type=text name=MergeSymbol size=34 disabled value="!*<%= firstPers %>;*!"><br>
															(copy and paste this into your content)
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
								<% if (canDynCont) { %>
								<td align="left" valign="top" width="50%">
									<table width=100% cellpadding="0" cellspacing="0">
										<tr>
											<td align="left" valign="middle" width="100%" class="subsectionheader"><b>Dynamic Elements</b></td>
											<td align="right" class="subsectionheader"><a class="resourcebutton" href="javascript:void(0);" onMouseOver="stm(Text[1],Style[0])" onmouseout="htm()">[?]</a></td>
										</tr>
										<tr>
											<td align="left" valign="middle" width="100%" colspan="2">
												<br>
												<a class="newbutton" href="#" onclick="SubmitLogic('6','')">New Logic Block</a>
												<br><br>
												<table cellpadding="2" cellspacing="1" width="100%">
													<tr>
														<td valign="middle">
															<table cellpadding="1" cellspacing="1" width="100%">
																<tr>
																	<td valign="middle">Logic Block</td>
																	<td valign="middle">
																		<select name=logicBlocks size=1 onchange="FT.ContMergeSymbol.value='!lb*'+FT.logicBlocks.options[FT.logicBlocks.selectedIndex].text+';'+this.value+'*lb!';">
																			<%= htmlLogicBlocks %>
																		</select>
																	</td>
																</tr>
																<tr>
																	<td valign="middle">Merge Symbol</td>
																	<td valign="middle">
																		<!-- PickUp value -->
																		<input type=text name=ContMergeSymbol size=40 disabled value="!lb*<%= firstBlock %>*lb!">
																	</td>
																</tr>
															</table>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
								<% } %>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block2_Step2 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width="100%" colspan=3>
						<table class="main" width="100%" cellpadding="1" cellspacing="1">
							<tr>
								<td align="left" valign="top" width="50%">
									<table width=100% cellpadding="2" cellspacing="1">
										<tr>
											<td align="left" valign="middle" width="100%" class="subsectionheader"><b>Current Personalization</b></td>
											<td align="right" class="subsectionheader"><a class="resourcebutton" href="javascript:void(0);" onMouseOver="stm(Text[2],Style[0])" onmouseout="htm()">[?]</a></td>
										</tr>
										<tr>
											<td align="left" valign="middle" width="100%" colspan="2">
											<br>
			<% 
					if (can.bWrite && ((contID == null) || !bWorkflow || (bWorkflow && bContentDraft) || (bWorkflow && bContentReady && can.bApprove)) && !bCampPending) {
			%>
											<a class="subactionbutton" href="#"	onclick="SubmitPrepare('3')">Update and Scan</a>
											<br>
			<% 
					}
			%>
											</td>
										</tr>
										<tr>
											<td align="left" valign="middle" width="100%" colspan="2">
												<table width="100%">
													<tr>
														<td>Field</td>
														<td>Default Value</td>			
													</tr>
													<%= htmlCurPers %>
												</table>
											</td>
										</tr>
									</table>
								</td>
								<% if (canDynCont) { %>
								<td align="left" valign="top" width="50%">
									<table width=100% cellpadding="2" cellspacing="1">
										<tr>
											<td align="left" valign="middle" width="100%" class="subsectionheader"><b>Current Logic Blocks</b></td>
											<td align="right" class="subsectionheader"><a class="resourcebutton" href="javascript:void(0);" onMouseOver="stm(Text[3],Style[0])" onmouseout="htm()">[?]</a></td>
										</tr>
										<tr>
											<td align="left" valign="middle" colspan="2">
												<br>
			<% 
					if (can.bWrite && ((contID == null) || !bWorkflow || (bWorkflow && bContentDraft) || (bWorkflow && bContentReady && can.bApprove)) && !bCampPending) {
			%>
												<a class="subactionbutton" href="#"	onclick="SubmitPrepare('3a')">Update and Scan</a>
												<br>
			<% 
					}
			%>
											</td>
										</tr>
										<tr>
											<td align="left" valign="middle" width="100%" colspan="2">
												<table cellpadding="1" cellspacing="1" width="100%">
													<tr>
														<td colspan=4><b>Current Logic Blocks</b></td>
													</tr>
													<%= htmlCurBlocks %>
												</table>
											</td>
										</tr>
									</table>
								</td>
								<% } %>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr height="75">
		<td valign="middle">
			<!----Step 3 Header ---->
			<table width="100%" class=main cellspacing=0 cellpadding=0>
				<tr>
					<td class=sectionheader>&nbsp;<b class=sectionheader>Step 3:</b> Enter Your Content</td>
				</tr>
				<tr>
					<td align="center">
						Link to a Revotas-hosted form: <a class="resourcebutton" href="javascript:PreviewURL('../form/form_list_url.jsp')">Generate Form URL</a>
					</td>
				</tr>
				<tr>
					<td align="center">
						Insert a Revotas-hosted image URL: <a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library URL</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<!---Step 3 Info------->
			<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width="100%" border=0>
				<tr>
					<td class=EditTabOn id=tab3_Step1 width=150 onclick="toggleTabs('tab3_Step','block3_Step',1,2,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Text</td>
					<td class=EditTabOff id=tab3_Step2 width=150 onclick="toggleTabs('tab3_Step','block3_Step',2,2,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>HTML</td>
					<td class=EditTabOff id=tab3_Step3 style="display:none;" width=150 onclick="switchSteps('Tabs_Table3', 'tab3_Step3', 'block3_Step3');" valign=center nowrap align=middle>AOL</td>
					<td class=EmptyTab valign=center nowrap align=middle width="300"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTabbuffer valign=top align=left width="100%" colspan=4><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block3_Step1>
				<tr>
					<td class=fillTab valign=top align=center width="100%" colspan=4>
						<table class=main cellspacing=1 cellpadding=2 width=100%>
							<tr>
								<td align="center">
									<br>Enter Text EMail Content Here<br>
									<textarea rows="11" name="ContentText" cols="60" style="width: 505; height: 231"><%= HtmlUtil.escape(contText) %></textarea>
									<br><br>
									<a class="subactionbutton" href="javascript:WinOpen(FT.ContentText.value, '1');"/>Preview Text</a>
								<%
								if (canDynCont)
								{
									%>
									<a class="subactionbutton" href="#" onclick="<%= ((can.bWrite && ((contID == null) || !bWorkflow || (bWorkflow && bContentDraft) || (bWorkflow && bContentReady && can.bApprove)) && !bCampPending)?"SubmitPrepare('5');":"dynamic_popup();") %>">Dynamic Preview</a>			
									<%
								}
								%>
									<br>
									<br>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block3_Step2 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width="100%" colspan=4>
						<table class=main cellspacing=1 cellpadding=2 width=100%>
							<tr>
								<td align="center">
									<br>Enter HTML EMail Content Here<br>
									<textarea rows="11" name="ContentHTML" cols="60" style="width: 505; height: 231"><%= HtmlUtil.escape(contHTML) %></textarea>
									<br><br>
									<a class="subactionbutton" href="javascript:WinOpen(FT.ContentHTML.value, '2');"/>Preview HTML</a>
								<%
								if (canDynCont)
								{
									%>
									<a class="subactionbutton" href="#" onclick="<%= ((can.bWrite && ((contID == null) || !bWorkflow || (bWorkflow && bContentDraft) || (bWorkflow && bContentReady && can.bApprove)) && !bCampPending)?"SubmitPrepare('5');":"dynamic_popup();") %>">Dynamic Preview</a>			
									<%
								}
								%>
									<br>
									<br>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block3_Step3 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width="100%" colspan=4>
						<table class=main cellspacing=1 cellpadding=2 width=100%>
							<tr>
								<td align="center">
									<br>Enter AOL EMail Content Here<br>
									<textarea rows="11" name="ContentAOL" cols="60" style="width: 505; height: 231"><%= HtmlUtil.escape(contAOL) %></textarea>
									<br><br>
									<a class="subactionbutton" href="javascript:WinOpen(FT.ContentAOL.value, '3');"/>Preview AOL</a>
								<%
								if (canDynCont)
								{
									%>
									<a class="subactionbutton" href="#" onclick="<%= (can.bWrite?"SubmitPrepare('5');":"dynamic_popup();") %>">Dynamic Preview</a>	
									<%
								}
								%>
									<br>
									<br>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr height="30">
		<td valign="middle">
			<!--- Step 4 Header----->
			<table width="100%" class=main cellspacing=0 cellpadding=0>
				<tr>
					<td class=sectionheader>&nbsp;<b class=sectionheader>Step 4:</b> Define Tracking Links</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="375">
		<td valign="top">
			<!---- Step 4 Info----->
			<table id="Tabs_Table4" cellspacing=0 cellpadding=0 border=0 class="layout" style="width:100%; height:100%;">
				<col width="150">
				<col width="150">
				<col>
				<tr height="22">
					<td class=EditTabOn id=tab4_Step1 onclick="toggleTabs('tab4_Step','block4_Step',1,2,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Link Scanning</td>
					<td class=EditTabOff id=tab4_Step2 onclick="toggleTabs('tab4_Step','block4_Step',2,2,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Advanced Options</td>
					<td class=EmptyTab valign=center nowrap align=middle><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr height="2">
					<td class=fillTabbuffer valign=top align=left colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block4_Step1>
				<tr>
					<td class=fillTab valign=top align=left colspan=3>
						<table cellspacing=1 cellpadding=2 class="main layout" style="width:100%; height:100%;">
							<col>
							<tr height="60">
								<td align="left" valign="middle" style="padding:10px;">
									<select name="TrackURLs" style="display:none;" multiple="MULTIPLE"></select>
									Enter Links you wish to track or click on the Scan for Links button to generate a list of potential links
									<br/>
			<% 
					if (can.bWrite && ((contID == null) || !bWorkflow || (bWorkflow && bContentDraft) || (bWorkflow && bContentReady && can.bApprove)) && !bCampPending) {
			%>
									<br/>
									<a class="subactionbutton" href="#" onclick="SubmitPrepare('4')">Scan for Links</a>
			<% 
					}
			%>
								</td>
							</tr>
							<tr>
								<td>
									<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
										<col width="30">
										<col>
										<tr height="24">
											<td align="left" valign="bottom" colspan="2">
												<table cellpadding="3" cellspacing="0" border="0" class="layout" style="width:100%; height:100%;">
			<%		if (can.bWrite && !(bWorkflow && bContentPending) && !bCampPending) { %>
													<col width="40">
													<col>
													<col>
													<col width="40">
													<col width="66">
													<tr height="24">
														<td align="right" valign="middle" class="subsectionheader" nowrap>&nbsp;</td>
														<td align="left" valign="middle" class="subsectionheader" nowrap>Link Name</td>
														<td align="left" valign="middle" class="subsectionheader" nowrap>Link URL</td>
														<td align="right" valign="middle" class="subsectionheader" nowrap>&nbsp;</td>
														<td align="right" valign="middle" class="subsectionheader" nowrap>&nbsp;</td>
													</tr>
			<%		} else { %>
													<col>
													<col>
													<tr height="24">
														<td align="left" valign="middle" class="subsectionheader" nowrap>Link Name</td>
														<td align="left" valign="middle" class="subsectionheader" nowrap>Link URL</td>
													</tr>
			<%		} %>
												</table>
											</td>
										</tr>
										<tr>
											<td align="left" valign="top" colspan="2">
												<div style="width:100%; height:150px; overflow-y:scroll;">
												<table cellpadding="3" cellspacing="0" border="0" class="layout" style="width:100%;" id="LinkTable">
			<%		if (can.bWrite && !(bWorkflow && bContentPending) && !bCampPending) { %>
													<col width="40">
													<col>
													<col>
													<col width="40">
													<col width="50">
													<tr height="1">
														<td colspan="5" class="subsectionheader"></td>
													</tr>
			<%		} else { %>
													<col>
													<col>
													<tr height="1">
														<td colspan="2" class="subsectionheader"></td>
													</tr>
			<%		} %>
													<%= htmlTracking %>
												</table>
												</div>
											</td>
										</tr>
										<tr height="10">
											<td colspan="2" align="left">&nbsp;</td>
										</tr>
										<tr height="20">
											<td colspan="2" align="left" class="subsectionheader"><a name="EditLink"></a>Edit:</td>
										</tr>
										<tr height="25">
											<td nowrap>Name</td>
											<td >
												<input type="text" name="EditLinkName" size="45"/>
											</td>
										</tr>
										<tr height="25">
											<td nowrap>URL</td>
											<td>
												<input type="text" name="EditLinkURL" size="75"/>
											</td>
										</tr>
										<tr height="25">
											<td colspan="2" align="left">
												<a class="subactionbutton" href="javascript:void(0);" onclick="AddLinkTable(event)">add</a>								
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block4_Step2 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width=650 height="250" colspan=3>
						<table class=main cellspacing=1 cellpadding=2 width="100%">
							<tr>
								<td align="right" valign="middle" rowspan="3">
									When scanning for links:
								</td>
								<td align="left" valign="middle">
									<table cellspacing=1 cellpadding=2 width="100%">
										<tr>
											<td width="20"><input type="checkbox" name="use_anchor_name" value="1" checked></td>
											<td width="630">
												Set link name from anchor name<br>
												Example: <span style="font-family:Verdana; font-size:8pt;">&lt;a href=&quot;http://www.mycompany.com&quot; name=&quot;My Company Home&quot;&gt;link&lt;/a&gt;</span><br>
												will be named &quot;My Company Home&quot;
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="left" valign="middle">
									<table cellspacing=1 cellpadding=2 width="100%">
										<tr>
											<td width="20"><input type="checkbox" name="use_link_renaming" value="1" checked></td>
											<td width="630">
												Set link name from Auto Link Names
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="left" valign="middle">
									<table cellspacing=1 cellpadding=2 width="100%">
										<tr>
											<td width="20"><input type="checkbox" name="replace_scanned_links" value="1" checked></td>
											<td width="630">
												Replace all previously scanned links
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	
<% } %>

	<tr height="30">
		<td valign="middle">
			<!-- History Info -->
			<table width=650 class=main cellspacing=0 cellpadding=0>
				<tr>
					<td class=sectionheader>&nbsp;<b class=sectionheader>History</b></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="75">
		<td valign="top">
			<table class="main" cellspacing="1" cellpadding="3" width="650" border="0">
				<tr>
					<td class="CampHeader"><b>Created by</b></td>
					<td><%= creator %></td>
					<td class="CampHeader"><b>Last Modified by</b></td>
					<td><%= editor %></td>
				</tr>
				<tr>
					<td class="CampHeader"><b>Creation date</b></td>
					<td><%= creationDate %></td>
					<td class="CampHeader"><b>Last Modify date</b></td>
					<td><%= modifyDate %></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>

<%!

private String getLogicBlockListHtml(String sContId) throws Exception
{
	ContBody cb = new ContBody(sContId);
	String sText = cb.s_text_part + cb.s_html_part + cb.s_aol_part;
	Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
	
	String htmlCurBlocks = "";
	
	String sLogicBlockId = null;
	Content cont = new Content();
	for (Enumeration e = vLogicBlockIds.elements() ; e.hasMoreElements() ;)
	{
		sLogicBlockId = (String) e.nextElement();
		cont.s_cont_id = sLogicBlockId;
		if(cont.retrieve()< 1) continue;

		htmlCurBlocks +=
			"<tr><td colspan=4>" +
			"<a href=\"#\" onClick=\"SubmitLogic('6','" + cont.s_cont_id + "')\">" + cont.s_cont_name + "</a>" +
			"</td></tr>\n";
	}
	if (htmlCurBlocks.equals("")) htmlCurBlocks = "<tr><td colspan=4>None</td></tr>\n";
	
	return htmlCurBlocks;
}
%>
