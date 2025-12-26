<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String		TYPE_ID		= request.getParameter("type_id");
if ((TYPE_ID == null)||("".equals(TYPE_ID))) TYPE_ID = "2";

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;
if (sSelectedCategoryId == null) sSelectedCategoryId = "0";

boolean showCamp1 = false;
boolean showCamp2 = false;
boolean showCamp3 = false;
boolean showCamp4 = false;

boolean canS2F = ui.getFeatureAccess(Feature.S2F_CAMP);
boolean canAutoCamp = ui.getFeatureAccess(Feature.AUTO_CAMP);
boolean canWebDMCall = ui.getFeatureAccess(Feature.WEB_DM_CALL);
boolean canPrint = ui.getFeatureAccess(Feature.PRINT_ENABLED);

if (canS2F)
{
	showCamp1 = true;
	showCamp2 = true;
}
if (canAutoCamp)
{
	showCamp1 = true;
	showCamp3 = true;
}
if (canWebDMCall)
{
	showCamp1 = true;
	showCamp4 = true;
}
%>

<html>
<head>
<title>New Campaign</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Caching" content="">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<script language="javascript">
	
	var dArgs = window.dialogArguments;
	var media_type = "1";
	var typeID = "2";
	
	function submitNew()
	{		
		var sURL = "camp_edit.jsp?a=b<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>";
		
		if (typeID == "21")
		{
			sURL += "&auto_queue_daily_flag=1";
			typeID = "2";
		}
		
		sURL += "&type_id=" + typeID;
		sURL += "&media_type_id=" + media_type;
		
		dArgs.location.href = sURL;
		self.close();
	}
	
	function selMedia(ord)
	{
		media_type = ord;
		
		if (media_type == "2")
		{
			document.getElementById("t_3").disabled = true;
		
			if (typeID == "3")
			{
				alert("Send To Friend Campaigns can only be delivered via EMail.");
				selMedia("1");
				document.getElementById("mt_1").checked = true;
				document.getElementById("mt_2").checked = false;
			}
		}
		else
		{
			document.getElementById("t_3").disabled = false;
		}
	}
	
	function selType(ord)
	{
		typeID = ord;
		
		if (typeID == "3")
		{
			document.getElementById("medium_table").style.display = "";
			document.getElementById("mt_2").disabled = true;
		
			if (media_type == "2")
			{
				alert("Send To Friend Campaigns can only be delivered via EMail.");
				selMedia("1");
				document.getElementById("mt_1").checked = true;
				document.getElementById("mt_2").checked = false;
			}
		}
		else if (typeID == "5")
		{
			document.getElementById("medium_table").style.display = "none";
		}
		else
		{
			document.getElementById("medium_table").style.display = "";
			document.getElementById("mt_2").disabled = false;
		}
	}
	
</script>
</head>
<body onload="selType('<%= TYPE_ID %>');">
<table cellspacing="0" cellpadding="10" width=100%>
	<tr>
		<td>
			<form name="FT">
			<table cellpadding="3" cellspacing="0" border="0" width="100%">
				<tr>
					<td nowrap align="left" valign="middle"><a class="newbutton" href="#" onclick="submitNew();">Create Campaign</a>&nbsp;&nbsp;&nbsp;</td>
				</tr>
			</table>
			<br>
			<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
				<tr>
					<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block1_Step1>
				<tr>
					<td class=fillTab valign=top align=center width=100%>
						<table class=main cellspacing=1 cellpadding=4 width="100%" id="medium_table">
							<tr>
								<th colspan="2">Delivery Medium</th>
							</tr>
							<tr>
								<td width="20%" align="center" valign="middle"><input type="radio" name="media_type_id" id="mt_1" value="1" checked onclick="selMedia('1');"></td>
								<td width="80%" align="left" valign="middle">
									<label for="mt_1"><b>EMail</b></label><br>
									Provides options for marketing to recipients via electronic content
								</td>
							</tr>
							<tr>
								<td width="20%" align="center" valign="middle"><input type="radio" name="media_type_id" id="mt_2" value="2" onclick="selMedia('2');"></td>
								<td width="80%" align="left" valign="middle">
									<label for="mt_2"><b>Print</b></label><br>
									Provides options for marketing to recipients via traditional print pieces
								</td>
							</tr>
						</table>
						<br>
						<table class=main cellspacing=1 cellpadding=4 width="100%">
							<tr>
								<th colspan="2">Campaign Type</th>
							</tr>
							<tr>
								<td width="20%" align="center" valign="middle"><input type="radio" name="type_id" id="t_2" value="2" onclick="selType('2');"<%= (TYPE_ID.equals("2"))?" checked":"" %>></td>
								<td width="80%" align="left" valign="middle">
									<label for="t_2"><b>Standard</b></label><br>
									Delivered to the entire audience of recipients in a single delivery.
								</td>
							</tr>
							<% if (showCamp2) { %>
							<tr>
								<td width="20%" align="center" valign="middle"><input type="radio" name="type_id" id="t_3" value="3" onclick="selType('3');"<%= (TYPE_ID.equals("3"))?" checked":"" %>></td>
								<td width="80%" align="left" valign="middle">
									<label for="t_3"><b>Send To Friend</b></label><br>
									Allows email recipients to easily "send to a friend"
								</td>
							</tr>
							<% } %>
							<% if (showCamp3) { %>
							<tr>
								<td width="20%" align="center" valign="middle"><input type="radio" name="type_id" id="t_4" value="4" onclick="selType('4');"<%= (TYPE_ID.equals("4"))?" checked":"" %>></td>
								<td width="80%" align="left" valign="middle">
									<label for="t_4"><b>Triggered</b></label><br>
									Events like form submissions or file imports trigger the campaign to send
								</td>
							</tr>
							<tr>
								<td width="20%" align="center" valign="middle"><input type="radio" name="type_id" id="t_2_1" value="21" onclick="selType('21');"></td>
								<td width="80%" align="left" valign="middle">
									<label for="t_2_1"><b>Check Daily</b></label><br>
									Daily calculation of recipients who qualify to recieve the campaign
								</td>
							</tr>
							<% } %>
							<% if (showCamp4) { %>
							<tr>
								<td width="20%" align="center" valign="middle"><input type="radio" name="type_id" id="t_5" value="5" onclick="selType('5');"<%= (TYPE_ID.equals("5"))?" checked":"" %>></td>
								<td width="80%" align="left" valign="middle">
									<label for="t_5"><b>Web / DM / Call</b></label><br>
									Non-executed campaign for use with 3rd party delivery methods
								</td>
							</tr>
							<% } %>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
			</form>
		</td>
	</tr>
</table>
</body>
</html>