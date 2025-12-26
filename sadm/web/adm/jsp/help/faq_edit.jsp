<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%
String sFAQID = request.getParameter("faq_id");

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

String sParentFAQID = null;
String sTypeID = null;
String sDisplayHeading = null;
String sAskQuestion = null;
String sGivenAnswer = null;
String sBritemoonProcess = null;
String sFAQOrder = null;
String sApprovedFlag = null;

String sParentID = null;
String sParentLabel = null;

try
{
	cp = ConnectionPool.getInstance();	
	conn = cp.getConnection(this);

	sSql = "select faq_id, parent_faq_id, type_id, display_heading, ask_question, given_answer, britemoon_process, faq_order, approved_flag" +
		" from shlp_faq with(nolock) where faq_id = " + sFAQID;
	
	try
	{
		if (sFAQID != null)
		{
			pstmt = conn.prepareStatement(sSql);
			rs = pstmt.executeQuery();
	
			byte[] b = null;
			while (rs.next())
			{
				sParentFAQID = rs.getString(2);
				
				sTypeID = rs.getString(3);
				
				b = rs.getBytes(4);
				sDisplayHeading = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(5);
				sAskQuestion = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(6);
				sGivenAnswer = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(7);
				sBritemoonProcess = (b==null)?null:new String(b, "ISO-8859-1");
				
				sBritemoonProcess = sBritemoonProcess.replaceAll("<br>", "\n");
				
				sFAQOrder = rs.getString(8);
				
				sApprovedFlag = rs.getString(9);
			}
			rs.close();
		}
	}
	catch(Exception ex)
	{
		throw new Exception(sSql+"\r\n"+ex.getMessage());
	}
	finally
	{
		if(pstmt != null) pstmt.close();
	}
%>
<html>
<head>
	<title>Help Doc Edit</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
    <script language="Javascript1.2"><!-- // load htmlarea
        _editor_url = "/sadm/ui/js/editor/"; // URL to htmlarea files
        var win_ie_ver = parseFloat(navigator.appVersion.split("MSIE")[1]);
        if (navigator.userAgent.indexOf('Mac')        >= 0) { win_ie_ver = 0; }
        if (navigator.userAgent.indexOf('Windows CE') >= 0) { win_ie_ver = 0; }
        if (navigator.userAgent.indexOf('Opera')      >= 0) { win_ie_ver = 0; }
        if (win_ie_ver >= 5.5) {
            document.write('<script src="' +_editor_url+ 'editor.js"');
            document.write(' language="Javascript1.2"></script>');  
        } 
        else { 
            document.write('<script>function editor_generate() { return false; }</script>'); 
        }// -->
    </script>
	<script language="javascript">
	
	function SubmitCheck()
	{
		var selType = document.faqEdit.type_id[document.faqEdit.type_id.selectedIndex].value
		
		if (document.faqEdit.faq_id.value == "" || document.faqEdit.faq_id.value == "null")
		{
			document.faqEdit.faq_id.value = "0";
		}
		
		if (document.faqEdit.display_heading.value.length == 0) {
			alert("You have to enter a Heading");
			return;
		}
		if (document.faqEdit.ask_question.value.length == 0) {
			alert("You have to enter the Question");
			return;
		}
		if (document.faqEdit.given_answer.value.length == 0) {
			alert("You have to enter the Answer given to customers");
			return;
		}
		if (document.faqEdit.faq_order.value.length == 0) {
			alert("You have to enter an order");
			return;
		}
	
		document.faqEdit.submit();
	}
	
	function loadParentOptions()
	{
		var selType = document.faqEdit.type_id[document.faqEdit.type_id.selectedIndex].value;
		var parentSel = document.faqEdit.parent_faq_id;
		
		for (i=1; i < parentSel.length; i++)
		{
			parentSel.remove(i)
		}
		
		if (selType == "201")
		{
			//hide the list
		}
		else if (selType == "202")
		{
			//show 201s
			var oOption;			
			<%
			try
			{
				sSql = "select faq_id, display_heading from shlp_faq where type_id = 201 order by faq_order";
				pstmt = conn.prepareStatement(sSql);
				rs = pstmt.executeQuery();
				while (rs.next())
				{
					sParentID = rs.getString(1);
					sParentLabel = rs.getString(2);
				%>
					oOption = document.createElement("OPTION");
					parentSel.options.add(oOption);
					oOption.innerText = "<%= sParentLabel %>";
					oOption.value = "<%= sParentID %>";
					oOption.selected = <%=((sParentFAQID != null) && (sParentFAQID.equals(sParentID)))?"true":"false"%>;
				<%
				}
				rs.close();
			}
			catch(SQLException sqlex)
			{
				throw sqlex;
			}
			finally
			{
				if(pstmt != null) pstmt.close();
			}
			%>
		}
		else if (selType == "203")
		{
			<%
			try
			{
				sSql = "select c.faq_id, v.display_heading + ': ' + c.display_heading as 'DisplayHeading'" +
						" from shlp_faq c with(nolock)" +
						" inner join shlp_faq v with(nolock) on c.parent_faq_id = v.faq_id" +
						" where c.type_id = 202" +
						" order by v.faq_order, c.faq_order";
				pstmt = conn.prepareStatement(sSql);
				rs = pstmt.executeQuery();
				while (rs.next())
				{
					sParentID = rs.getString(1);
					sParentLabel = rs.getString(2);
				%>
					oOption = document.createElement("OPTION");
					parentSel.options.add(oOption);
					oOption.innerText = "<%= sParentLabel %>";
					oOption.value = "<%= sParentID %>";
					oOption.selected = <%=((sParentFAQID != null) && (sParentFAQID.equals(sParentID)))?"true":"false"%>;
				<%
				}
				rs.close();
			}
			catch(SQLException sqlex)
			{
				throw sqlex;
			}
			finally
			{
				if(pstmt != null) pstmt.close();
			}
			%>
		}
		else
		{
			//unknown
		}
		
	}

	</script>
	<script language="javascript" src="../../js/tab_script.js"></script>
</head>
<body onload="loadParentOptions();">
<form method="post" action="faq_edit_save.jsp" name="faqEdit">
<input type="hidden" name="faq_id" value="<%=(sFAQID==null)?"0":sFAQID%>">
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="javascript:SubmitCheck();">Save</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left" nowrap>
			<a class="subactionbutton" href="faq_preview.jsp?faq_id=<%= sFAQID %>">Preview</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table cellpadding="0" cellspacing="0" class="main" width="95%">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 1:</b> Enter Information</td>
	</tr>
</table>
<BR>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="left" valign="middle" nowrap>Heading</td>
					<td align="left" valign="middle" nowrap colspan="3" width="100%"><INPUT type="text" name="display_heading" size="50" value="<%=(sDisplayHeading==null)?"":sDisplayHeading%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>Order</td>
					<td align="left" valign="middle" nowrap><input type="text" name="faq_order" size="8" value="<%=(sFAQOrder==null)?"":sFAQOrder%>"></td>
					<td align="left" valign="middle" nowrap>Approved?<br>(show in online support)</td>
					<td align="left" valign="middle" nowrap width="75%">
						<select name="approved_flag">
							<option value="0"<% if((sApprovedFlag!= null) && (sApprovedFlag.compareTo("0") == 0)){%> selected<% } %>>No</option>
							<option value="1"<% if((sApprovedFlag!= null) && (sApprovedFlag.compareTo("1") == 0)){%> selected<% } %>>Yes</option>
						</select>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>Item Type</td>
					<td align="left" valign="middle" nowrap colspan="3" width="100%">
						<select name="type_id" onchange="loadParentOptions();">
							<option value="201"<% if((sTypeID!= null) && (sTypeID.compareTo("201") == 0)){%> selected<% } %>>FAQ: Volume</option>
							<option value="202"<% if((sTypeID!= null) && (sTypeID.compareTo("202") == 0)){%> selected<% } %>>FAQ: Chapter</option>
							<option value="203"<% if((sTypeID!= null) && (sTypeID.compareTo("203") == 0)){%> selected<% } %>>FAQ: Page</option>
							<option value="204"<% if((sTypeID!= null) && (sTypeID.compareTo("204") == 0)){%> selected<% } %>>Revotas Only - Internal Process</option>
						</select>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>Parent FAQ Item</td>
					<td align="left" valign="middle" nowrap colspan="3" width="100%">
						<select size="1" name="parent_faq_id">
							<option value="0">-- Choose a Parent --</option>
							<option value="0" <%=((sParentFAQID != null) && (sParentFAQID.equals("0")))?"selected":""%>>-- Has No Parent --</option>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>
<table cellpadding="0" cellspacing="0" class="main" width="95%">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 2:</b> Enter HTML</td>
	</tr>
</table>
<BR>
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EditTabOn id=tab2_Step1 width=175 onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Question</td>
		<td class=EditTabOff id=tab2_Step2 width=175 onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Answer</td>
		<td class=EditTabOff id=tab2_Step3 width=175 onclick="switchSteps('Tabs_Table2', 'tab2_Step3', 'block2_Step3');" valign=center nowrap align=middle>Internal Info/Steps</td>
		<td class=EmptyTab valign=center nowrap align=middle width=125><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=4><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=4>
			<table width="100%" class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('ask_question');</script>
						<textarea name="ask_question" style="width:100%; height:250px;"><%= (sAskQuestion==null)?"":sAskQuestion %></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block2_Step2" style="display:none;">
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=4>
			<table width="100%" class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('given_answer');</script>
						<textarea name="given_answer" style="width:100%; height:250px;"><%= (sGivenAnswer==null)?"":sGivenAnswer %></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block2_Step3" style="display:none;">
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=4>
			<table width="100%" class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('britemoon_process');</script>
						<textarea name="britemoon_process" style="width:100%; height:250px;"><%= (sBritemoonProcess==null)?"":sBritemoonProcess %></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</form>
</body>
</html>
<%
}
catch(Exception ex)
{
	throw ex;
}
finally
{
	if(conn != null) cp.free(conn);
}
%>