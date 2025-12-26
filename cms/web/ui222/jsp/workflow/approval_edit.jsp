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
     String sObjectName = WorkflowUtil.getObjectName(Integer.parseInt(sObjectType),sObjectId);
     String sAprvlRequestId = BriteRequest.getParameter(request,"aprvl_request_id");
     String sDispositionId = BriteRequest.getParameter(request,"disposition_id");
     // get other object info for display
     boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, Integer.parseInt(sObjectType));
     if (!bWorkflow) {
          response.sendRedirect("../access_denied.jsp");
          return;
     }

	// make sure this user has Approval permission for this Object and
     // that they are the approver for this particular ApprovalRequest
     AccessPermission can = user.getAccessPermission(Integer.parseInt(sObjectType));
     if (!can.bApprove) {
          response.sendRedirect("../access_denied.jsp");
          return;
     }
     ApprovalRequest arRequest = new ApprovalRequest(sAprvlRequestId);
     boolean bIsApprover = (user.s_user_id.equals(arRequest.s_approver_id));
//     System.out.println("userID:" + user.s_user_id + " : approver userID:" + arRequest.s_approver_id);
     if (!bIsApprover) {
          response.sendRedirect("../access_denied.jsp");
          return;
     }
     
     String sErrors = null;
%>

<html>
<head>
<title>Approval</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>

<body>
<form name="FT" method="post" action="approval_send.jsp">
<input type="hidden" name="object_type" value="<%=sObjectType%>">
<input type="hidden" name="object_id" value="<%=sObjectId%>">
<input type="hidden" name="object_name" value="<%=sObjectName%>">
<input type="hidden" name="aprvl_request_id" value="<%=sAprvlRequestId%>">

<!--- Step 0 Summary information----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<%= ObjectType.getDisplayName(Integer.parseInt(sObjectType)) %> Information</td>
	</tr>
</table>
<br>
<!---- Step 0 Info----->
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table class=main border="0" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td width="125" align="left" valign="middle">Name:</td>
					<td align="left" valign="middle"><%= sObjectName %></td>
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
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Approval Response</td>
	</tr>
</table>
<br>
<input type="hidden" name="disposition_id" value="<%=sDispositionId%>">
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
					<td width="150">Response:</td>
					<td><%

	int iDispositionID = ApprovalDisposition.APPROVE;
	try
	{
		// Should not be able to reach page with no Disposition, but check anyway
		// throw exception if has null/non-int value
		iDispositionID = Integer.parseInt(sDispositionId);
	}
	catch (Exception e)
	{
		throw new Exception ("Invalid Disposition ID");
	}
	out.print(ApprovalDisposition.getDisplayName(iDispositionID));

%>					</td>
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
		<td class=fillTab>
			<table class=main border="0" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="top">
						Add Comments to Requestor:
						<br>
						<textarea  name="aprvl_comment" cols="60" rows="10" style="width:500px; height:200px;"></textarea>
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
						<a class="actionbutton" href="#" onclick="SendApproval()">Submit Response</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<script>

function SendApproval() {
     FT.submit();
}

</script>
</body>
</html>

