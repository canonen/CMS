<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			java.sql.*,java.io.*,
			java.util.*,org.apache.log4j.*"
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

     // get object (asset) information from request parameters and database if necessary
     // get object ID and type from request
     String sObjectType = BriteRequest.getParameter(request,"object_type");
     String sObjectId = BriteRequest.getParameter(request,"object_id");
     // get other object info for display
     boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id,Integer.parseInt(sObjectType));

	AccessPermission can = user.getAccessPermission(Integer.parseInt(sObjectType));
     // get Approvers for customer, asset
     Hashtable htApprovers = WorkflowUtil.getApprovers(cust.s_cust_id,Integer.parseInt(sObjectType));
     String sSelectedCategoryId = null;
     String sErrors = null;

     String sObjectTypeName = ObjectType.getDisplayName(Integer.parseInt(sObjectType));
     String sObjectName = WorkflowUtil.getObjectName(Integer.parseInt(sObjectType),sObjectId);
%>

<html>
<head>
<title>Request Approval for <%= sObjectTypeName %></title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
</head>

<body>
<form name="FT" method="post" action="approval_request_send.jsp">

<%
	if(!can.bWrite || !bWorkflow)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

%>
<input type="hidden" name="object_type" value="<%=sObjectType%>">
<input type="hidden" name="object_id" value="<%=sObjectId%>">

<!--- Step 0 Campaign Summary information----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<%= sObjectTypeName %> Summary Information</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab>
			<table class=main border="0" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td width="125" align="left" valign="middle">Name: </td>
					<td align="left" valign="middle"><%= HtmlUtil.escape(sObjectName) %> </td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Select Approver</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="150">Choose Approver</td>
					<td>
						<select name=approver size=1>
					<%
					if (htApprovers != null)
					{
						Enumeration eApprovers = htApprovers.keys();
						String sApproverId = null;
						while (eApprovers.hasMoreElements())
						{
							sApproverId = (String) eApprovers.nextElement();
							%>
							<option value=<%= sApproverId %>><%= (String)htApprovers.get(sApproverId) %></option>
							<%
						}
					}
					%>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!----Step 2 Header ---->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Add Comments</td>
	</tr>
</table>
<br>
<!---Step 2 Info------->
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab valign=top align=left width=650>
			<table class="main" width="100%" cellpadding="2" cellspacing="1">
				<tr>
					<td align="left" valign="top" colspan="3">
						Add comments to approver:
						<br>
						<textarea  name="aprvl_request_comment" cols="60" rows="10" style="width:500px; height:200px;"></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab>
			<table class=main border="0" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<a class="actionbutton" href="#" onclick="SendRequest()">Send Approval Request</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<script>

function SendRequest() {
     FT.submit();
}

</script>
</body>
</html>

