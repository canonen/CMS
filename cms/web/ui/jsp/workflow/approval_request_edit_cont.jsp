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

     boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.CONTENT);

     // get object (asset) information from request parameters and database if necessary
     // get object ID and type from request
     String sContId = BriteRequest.getParameter(request,"cont_id");
     // get other object info for display
     Content cont = new Content(sContId);
     logger.info("in approval_request_edit_cont.jsp...cont_id:" + sContId);

	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
     // get Approvers for customer, asset
     Hashtable htApprovers = WorkflowUtil.getApprovers(cust.s_cust_id,ObjectType.CONTENT);
     String sSelectedCategoryId = null;
     String sErrors = null;
%>

<html>
<head>
<title>Request Approval for Content</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
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
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="SendRequest()">Send Approval Request</a>
		</td>
	</tr>
</table>
<br>
<input type="hidden" name="object_type" value="<%=ObjectType.CONTENT%>">
<input type="hidden" name="object_id" value="<%=sContId%>">
<!--- Step 0 Campaign Summary information----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;Content Summary Information</td>
	</tr>
</table>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block0_Step1>
	<tr>
				<tr>
					<td width="125" height="25" align="left" valign="middle">Name: </td>
					<td width="425" height="25" align="left" valign="middle"><%=HtmlUtil.escape(cont.s_cont_name)%> </td>
				</tr>
	</tr>
	</tbody>
</table>
<br><br>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b>Select Approver</td>
	</tr>
</table>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650 height="50" colspan=3>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="150">Choose Approver</td>
					<td width="475">
						<select name=approver size=1>
                                   <%
                                   if (htApprovers != null) {
                                        Enumeration eApprovers = htApprovers.keys();
                                        String sApproverId = null;
                                        while (eApprovers.hasMoreElements()) {
                                             sApproverId = (String) eApprovers.nextElement();
                                        %>
                                             <option value=<%=sApproverId%>><%=(String)htApprovers.get(sApproverId)%></option>
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
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b>Add Comments</td>
	</tr>
</table>
<!---Step 2 Info------->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=left width=650 height="160" colspan=3>
			<table class="main" width="100%" cellpadding="2" cellspacing="1">
				<tr>
					<td align="left" valign="top" width="300" colspan="3">
                              Add comments to approver:
                              <br>
                              <textarea  name="aprvl_request_comment" cols="" rows="5"></textarea>
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

