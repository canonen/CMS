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
String sOriginTicketID = request.getParameter("ticket_id");

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

String sTicketID = null;
String sCustID = null;
String sCustName = null;
String sUserID = null;
String sUserName = null;
String sStatusID = null;
String sStatusName = null;
String sLevelID = null;
String sSourceID = null;
String sSubject = null;
String sOriginalIssue = null;
String sFurtherInfo = null;
String sSupportDiary = null;
String sIssueType = null;
String sResolutionTime = null;
String sResolutionWhat = null;
String sResolutionSolve = null;
String sResolutionPrevent = null;
String sCreateDate = null;
String sCreateDateTxt = null;
String sModifyDate = null;
String sModifyDateTxt = null;
													
sSql = "EXEC usp_shlp_support_ticket_get '" + sOriginTicketID + "'";
		
try
{
	cp = ConnectionPool.getInstance();	
	conn = cp.getConnection(this);	
	
	try
	{
		if (sOriginTicketID != null)
		{
			pstmt = conn.prepareStatement(sSql);
			rs = pstmt.executeQuery();
	
			byte[] b = null;
			while (rs.next())
			{
				sTicketID = null;
				sCustID = null;
				sCustName = null;
				sUserID = null;
				sUserName = null;
				sStatusID = null;
				sStatusName = null;
				sLevelID = null;
				sSourceID = null;
				sSubject = null;
				sOriginalIssue = null;
				sFurtherInfo = null;
				sSupportDiary = null;
				sIssueType = null;
				sResolutionTime = null;
				sResolutionWhat = null;
				sResolutionSolve = null;
				sResolutionPrevent = null;
				sCreateDate = null;
				sCreateDateTxt = null;
				sModifyDate = null;
				sModifyDateTxt = null;
				
				sTicketID = rs.getString(1);
				sCustID = rs.getString(2);
				
				b = rs.getBytes(3);
				sCustName = (b==null)?"":new String(b, "ISO-8859-1");
				
				sUserID = rs.getString(4);
				
				b = rs.getBytes(5);
				sUserName = (b==null)?"":new String(b, "ISO-8859-1");
				
				sStatusID = rs.getString(6);
				
				b = rs.getBytes(7);
				sStatusName = (b==null)?"":new String(b, "ISO-8859-1");
				
				sLevelID = rs.getString(8);
				sSourceID = rs.getString(9);
				
				b = rs.getBytes(10);
				sSubject = (b==null)?"":new String(b, "ISO-8859-1");
				
				b = rs.getBytes(11);
				sOriginalIssue = (b==null)?"":new String(b, "ISO-8859-1");
				
				b = rs.getBytes(12);
				sFurtherInfo = (b==null)?"":new String(b, "ISO-8859-1");
				
				b = rs.getBytes(13);
				sSupportDiary = (b==null)?"":new String(b, "ISO-8859-1");
				
				sIssueType = rs.getString(14);
				sResolutionTime = rs.getString(15);
				
				b = rs.getBytes(16);
				sResolutionWhat = (b==null)?"":new String(b, "ISO-8859-1");
				
				b = rs.getBytes(17);
				sResolutionSolve = (b==null)?"":new String(b, "ISO-8859-1");
				
				b = rs.getBytes(18);
				sResolutionPrevent = (b==null)?"":new String(b, "ISO-8859-1");
				
				sCreateDate = rs.getString(19);
				
				b = rs.getBytes(20);
				sCreateDateTxt = (b==null)?"":new String(b, "ISO-8859-1");
				
				sModifyDate = rs.getString(21);
				
				b = rs.getBytes(22);
				sModifyDateTxt = (b==null)?"":new String(b, "ISO-8859-1");
				
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
	<title>Support Item Edit</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
	<SCRIPT LANGUAGE="JAVASCRIPT">
	
	function SubmitCheck(){
	// Check the text
		if (FT.subject.value.length == 0) {
			alert("You have to enter a Subject");
			return;
		}
	
		FT.submit();
	}

	</SCRIPT>
	<script language="javascript" src="../../js/tab_script.js"></script>
</head>
<body>
<form method="post" action="support_ticket_save.jsp" name="FT" style="display:inline;">
<input type="hidden" name="ticket_id" value="<%=(sTicketID==null)?"":sTicketID%>">
<input type="hidden" name="origin_ticket_id" value="<%=(sOriginTicketID==null)?"0":sOriginTicketID%>">
<!--<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="javascript:SubmitCheck();">Save</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>//-->
<table cellpadding="0" cellspacing="0" class="main" width="95%">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 1:</b> Ticket Information</td>
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
			<table class="main layout" cellspacing="1" cellpadding="2" style="width:100%;">
				<col width="60">
				<col width="125">
				<col width="70">
				<col>
				<tr>
					<td align="left" valign="middle" nowrap>Ticket #</td>
					<td align="left" valign="middle" nowrap><%= sCustID %>-<%= sTicketID %></td>
					<td align="left" valign="middle" nowrap>Subject</td>
					<td align="left" valign="middle" nowrap width="100%"><INPUT type="text" name="subject" size="50" style="width:100%;" value="<%= (sSubject==null)?"":sSubject %>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>Customer</td>
					<td align="left" valign="middle" nowrap width="100%"><%= (sCustName==null)?"":sCustName %> (<%= (sCustID==null)?"":sCustID %>)</td>
					<td align="left" valign="middle" nowrap>Created Date</td>
					<td align="left" valign="middle" nowrapwidth="100%"><INPUT type="text" name="create_date" size="30" value="<%= (sCreateDateTxt==null)?"-- NO DATE --":sCreateDateTxt %>" disabled></td>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>User</td>
					<td align="left" valign="middle" nowrap width="100%"><%= (sUserName==null)?"":sUserName %> (<%= (sUserID==null)?"":sUserID %>)</td>
					<td align="left" valign="middle" nowrap>Modified Date</td>
					<td align="left" valign="middle" nowrapwidth="100%"><INPUT type="text" name="modify_date" size="30" value="<%= (sModifyDateTxt==null)?"-- NO DATE --":sModifyDateTxt %>" disabled></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>
<table cellpadding="0" cellspacing="0" class="main" width="95%">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 2:</b> Ticket Details</td>
	</tr>
</table>
<BR>

<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EditTabOn id=tab2_Step1 width=175 onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Original Issue</td>
		<td class=EditTabOff id=tab2_Step2 width=175 onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Further Info</td>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=3>
			<table width="100%" class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td>
						<div id="original_issue" style="overflow:auto; padding:4px; width:100%; height:250px;"><%= (sOriginalIssue==null)?"":sOriginalIssue.replaceAll("\n", "<br>") %></div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block2_Step2" style="display:none;">
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=3>
			<table width="100%" class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td>
						<div id="further_info" style="overflow:auto; padding:4px; width:100%; height:250px;"><%= (sFurtherInfo==null)?"":sFurtherInfo.replaceAll("\n", "<br>") %></div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<textarea name="further_info" style="display:none;"><%= (sFurtherInfo==null)?"":sFurtherInfo %></textarea>
<textarea name="original_issue" style="display:none;"><%= (sOriginalIssue==null)?"":sOriginalIssue %></textarea>
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