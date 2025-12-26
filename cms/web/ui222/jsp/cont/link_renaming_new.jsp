<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
			org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

LinkRenaming link = new LinkRenaming();
%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript">
		
		function launchURL()
		{
			if (!FT.link_type_id[0].checked) {
				alert("Preview is allowed for exact match only");
				return;
			}
    		var newURL = FT.link_definition.value;
    		CheckURLWin = window.open(newURL, "CheckURL","scrollbars=yes,resizable=yes,location=yes,toolbar=yes,status=yes,menubar=yes,height=400,width=600");
		}
		
		function saveLinks()
		{
			var tTable = document.getElementById("linkTable");
			var hDiv = document.getElementById("hiddenInputs");
			
			var sLinks = "";
			
			var sLinkName = "";
			var sLinkTypeID = "";
			var sLinkURL = "";
			var obj;
			
			var y = 1;
			
			for (i=1; i < tTable.rows.length; i++)
			{
				sLinkName = "";
				sLinkName = tTable.rows[i].cells[0].children[0].value;
				
				sLinkTypeID = "";
				obj = tTable.rows[i].cells[1].children[0]
				sLinkTypeID = obj[obj.selectedIndex].value;
				
				sLinkURL = "";
				sLinkURL = tTable.rows[i].cells[2].children[0].value;
				
				if ((sLinkName != "") || (sLinkURL != ""))
				{
					sLinks += "<input type=hidden name=link_id" + y + " value=\"\">";
					sLinks += "<input type=hidden name=link_name" + y + " value=\"" + sLinkName + "\">";
					sLinks += "<input type=hidden name=link_type_id" + y + " value=\"" + sLinkTypeID + "\">";
					sLinks += "<input type=hidden name=link_definition" + y + " value=\"" + sLinkURL + "\">";
					y++;
				}
				else
				{
					alert("You have added a link with out entering the required information.\n\nPlease enter the link information or delete the row by clicking the 'X' button.");
					return;
				}
			}
			
			hDiv.innerHTML = sLinks;
			FT.num_links.value = (y - 1);
			FT.submit();
		}
		
		var tabIndex = 4;
	
		function addLink()
		{
			var tTable = document.getElementById("linkTable");
			var oRow, oCell;
			
			oRow = tTable.insertRow();
			
			tabIndex++;
			
			oCell = oRow.insertCell();
			oCell.align = "left";
			oCell.vAlign = "middle";
			oCell.innerHTML = "<input type=\"text\" name=\"link_name\" id=\"link_name\" tabindex=\"" + tabIndex + "\" size=\"15\" value=\"\" style=\"width:100%;\">";
			
			tabIndex++;
			
			oCell = oRow.insertCell();
			oCell.align = "left";
			oCell.vAlign = "middle";
			oCell.innerHTML = "<select name=\"link_type_id\" id=\"link_type_id\" tabindex=\"" + tabIndex + "\"><option value=\"1\">Exact Match</option><option value=\"2\">Partial Match</option></select>";
			
			tabIndex++;
			
			oCell = oRow.insertCell();
			oCell.align = "left";
			oCell.vAlign = "middle";
			oCell.innerHTML = "<input type=\"text\" name=\"link_definition\" id=\"link_definition\" tabindex=\"" + tabIndex + "\" size=\"15\" value=\"\" style=\"width:100%;\">";
			
			oCell = oRow.insertCell();
			oCell.align = "left";
			oCell.vAlign = "middle";
			oCell.innerHTML = "<a href=\"#\" onclick=\"removeLink();\" class=\"subactionbutton\">X</a>"
		}
		
		function removeLink()
		{
			var srcElem = window.event.srcElement;
			var trElem = srcElem;
			var tTable = document.getElementById("linkTable");
			
			while (trElem.tagName != "TR")
			{
				trElem = trElem.parentElement;
			}
			
			tTable.deleteRow(trElem.rowIndex);
		}
		
	</script>
</HEAD>
<BODY>
<FORM METHOD="POST" NAME="FT" ACTION="link_renaming_save.jsp" TARGET="_self">
<%
if( can.bWrite )
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="javascript:saveLinks();">Save</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>

<input type="hidden" name="num_links" value="1">
<div style="display:none;" id="hiddenInputs">
</div>

<!--- Step 1 Header----->
<table width="95%" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Auto Link Name Information</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100" nowrap>Link Name: </td>
					<td align="left" valign="middle">Enter the name of the link to auto-name during Scan for Links</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100" nowrap>Match Criteria: </td>
					<td align="left" valign="middle">
						<table cellspacing="1" cellpadding="2" width="100%">
							<tr>
								<td align="left" valign="middle">
									Exact Match - URL in content must match exactly what is entered
								</td>
							</tr>
							<tr>
								<td align="left" valign="middle">
									Partial Match - URL in content must only contain what is entered<br>
									(i.e. http://www.mycompany.com/about in the content will match if link entered below is just www.mycompany.com)
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100" nowrap>Link URL: </td>
					<td align="left" valign="middle">The URL (or part of the URL) to find during Scan for Links</td>
				</tr>
			</table>
			<br>
			<table class="listTable layout" cellspacing="0" cellpadding="3" id="linkTable" style="width:100%;">
				<col width="200">
				<col width="100">
				<col>
				<col width="100">
				<tr>
					<th>Link Name</th>
					<th>Match Criteria</th>
					<th colspan="2">Link URL</th>
				</tr>
				<tr>
					<td align="left" valign="middle"><input type="text" name="link_name" id="link_name" tabindex="1" size="15" value="" style="width:100%;"></td>
					<td align="left" valign="middle"><select name="link_type_id" id="link_type_id" tabindex="2"><option value="1">Exact Match</option><option value="2">Partial Match</option></select></td>
					<td align="left" valign="middle"><input type="text" name="link_definition" id="link_definition" tabindex="3" size="15" value="" style="width:100%;"></td>
					<td><a href="javascript:addLink();" class="subactionbutton">Additional Link</a></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>

</FORM>
</BODY>
</HTML>
