<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../utilities/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../utilities/header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.USER);

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<%
String sUserId = request.getParameter("user_id");
String isNew = request.getParameter("isnew");
boolean newUser = true;

if (isNew == null) newUser = false;

boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.USER);
String sAprvlRequestId = request.getParameter("aprvl_request_id");
boolean isApprover = false;
if (sUserId != null) {
     if (sAprvlRequestId == null)
          sAprvlRequestId = "";
     ApprovalRequest arRequest = null;
     if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
          arRequest = new ApprovalRequest(sAprvlRequestId);
     } else {
          arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.USER),sUserId);
//          System.out.println("arRequest retrieved from WorkflowUtil is:" + ((arRequest==null)?"null":arRequest.s_approval_request_id));
     }
     if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
          sAprvlRequestId = arRequest.s_approval_request_id;
          isApprover = true;
     }
}



User u = new User(sUserId);
Customer c = new Customer(u.s_cust_id);
int iStatusId = Integer.parseInt(u.s_status_id);
if( u.s_user_id == null) throw new Exception(this.getClass().getName() + ": user_id is null");

UserUiSettings uus = new UserUiSettings(sUserId);
int nUIType = Integer.parseInt(uus.s_ui_type_id);

// === === ===

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	%>
<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
	<SCRIPT src="../../../js/scripts.js"></SCRIPT>
	<SCRIPT>
		function check_all(action)
		{
			var n = access_masks.elements.length;
			var obj;
			for(var i=0; i < n; i++)
			{
				obj = access_masks.elements[i];
				if(obj.type == 'checkbox' && obj.disabled == false) obj.checked = action;
			}
		}

          function AccessMasksSubmit() {
               undisable_forms();
               access_masks.submit();
          }


     function RequestApproval() {
          access_masks.save_and_request_approval.value = '1';
          access_masks.submit();
     }

     function workflow_approve() {
          undisable_forms()
          access_masks.action = "../../workflow/approval_send.jsp"
          access_masks.disposition_id.value = "10"     // approve
          access_masks.submit()
     }

     function workflow_reject() {
          undisable_forms()
          access_masks.action = "../../workflow/approval_edit.jsp"
          access_masks.disposition_id.value = "90"     // reject
          access_masks.submit()
     }

     function workflow_approve_w_comments() {
          undisable_forms()
          access_masks.action = "../../workflow/approval_edit.jsp"
          access_masks.disposition_id.value = "10"     // approve
          access_masks.submit()
     }

     function reset_draft_status()
     {
          undisable_forms()
          access_masks.status_id.value = <%=UserStatus.DRAFT%>
          access_masks.submit()
     }

     function undisable_forms()
     {
          var l = document.forms.length;
          for(var i=0; i < l; i++)
          {
               var m = document.forms[i].elements.length;
               for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = false;
          }
     }

     function disable_forms()
     {
          var l = document.forms.length;
          for(var i=0; i < l; i++)
          {
               document.forms[i].action = null;
               var m = document.forms[i].elements.length;
               for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = true;
          }
     }


          
	</SCRIPT>
</HEAD>
<BODY <%=(!can.bWrite || (bWorkflow && iStatusId == UserStatus.PENDING_APPROVAL))?"onload='disable_forms();'":""%>>
<%
if(can.bWrite)
{

          if (!bWorkflow || 
               (bWorkflow && can.bApprove && iStatusId != UserStatus.PENDING_APPROVAL) || 
               (bWorkflow && !can.bApprove && (iStatusId == UserStatus.DRAFT))) {

	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="AccessMasksSubmit()">Save</a>
			</td>
		<%
     }
     if (bWorkflow && !can.bApprove && 
          (iStatusId == UserStatus.DRAFT || iStatusId == UserStatus.ACTIVATED )) {
     %>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="RequestApproval();">Request Approval</a>
			</td>
     <%
     }
     if (bWorkflow && can.bApprove && isApprover && iStatusId == UserStatus.PENDING_APPROVAL) {
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
		if(sUserId != null)
		{
			%>
			<td align="left" valign="middle">
				User Edit: <a class="subactionbutton" href="user_edit.jsp?<%=(sUserId==null)?"":"user_id=" + sUserId %>"><b><%= (sUserId==null)?"New":u.s_user_name %></b></a>
			</td>
			<%
		}
		%>
		</tr>
	</table>
	<br>
	<%
}
%>
<FORM method="POST" action="access_masks_save.jsp" name="access_masks">
<INPUT type="hidden" name="user_id" value="<%=u.s_user_id%>"></TD>
<input type="hidden" name="disposition_id" value="0"/>
<input type="hidden" name="object_type" value="<%=String.valueOf(ObjectType.USER)%>"/>
<input type="hidden" name="object_id" value="<%=(sUserId != null)?sUserId:"0"%>"/>
<INPUT TYPE="hidden" NAME="aprvl_request_id"	value="<%=sAprvlRequestId%>">
<INPUT TYPE="hidden" NAME="save_and_request_approval"	value="0">

<!--- Step 1 Header----->
<table width="500" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> User Access Levels for <%= (sUserId==null)?"New User":u.s_user_name %></td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="500" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="500">
			<table class="main" border="0" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<th align="left" valign="middle" width="100%">Access Type</th>
					<th align="center" valign="middle" nowrap>Read</th>		
					<th align="center" valign="middle" nowrap>Write</th>
					<th align="center" valign="middle" nowrap>Execute</th>
					<th align="center" valign="middle" nowrap>Delete</th>
					<th align="center" valign="middle" nowrap>Approve</th>
				</tr>
		<% 
			int showeDesignOpt = 1;
			boolean bFeat = false;
			bFeat = ui.getFeatureAccess(Feature.PV_DESIGN_OPTIMIZER);
			if (!bFeat) showeDesignOpt = 0;
			
			int showeContentScorer = 1;
			boolean bFeateCntScore = false;
			bFeateCntScore = ui.getFeatureAccess(Feature.PV_CONTENT_SCORER);
			if (!bFeateCntScore) showeContentScorer = 0;
			
			int showeDelTracker = 1;
			boolean bFeateDelTracker = false;
			bFeateDelTracker = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
			if (!bFeateDelTracker) showeDelTracker = 0;	
			
			
			// added as a part of release 6.0 : resubscribe recepient
			int showeRecipResub = 1;
			boolean bshoweRecipResub = false;
			bshoweRecipResub = ui.getFeatureAccess(Feature.RECIP_RESUBSCRIBE);
			if (!bshoweRecipResub) showeRecipResub = 0;	
			
		%>				
		<%
		try
		{
			sSql  = " SELECT ot.type_id, ot.type_name, mask=ISNULL(am.mask, 0)";
			sSql += " FROM ccps_object_type ot";
			sSql += " LEFT OUTER JOIN ccps_access_mask am";
			sSql += " ON ( ot.type_id = am.type_id )";
			sSql += " AND ( am.user_id = ? )";
			sSql += " WHERE ( 1 = 1 )";

			if(Integer.parseInt(uus.s_ui_type_id) != UIType.ADVANCED)
			{
				sSql += " AND (ot.type_id NOT IN (" + ObjectType.FORM + ", " + ObjectType.LOGIC_BLOCK + "))";
			}
			//added for release 5.9 , pviq changes
			if (showeDesignOpt == 0) { 
				sSql += " AND (ot.type_id NOT IN (" + ObjectType.PV_DESIGN_OPTIMIZER + "))";
			}
			if (showeContentScorer == 0) { 
				sSql += " AND (ot.type_id NOT IN (" + ObjectType.PV_CONTENT_SCORER + "))";
			}
			if (showeDelTracker == 0) { 
				sSql += " AND (ot.type_id NOT IN (" + ObjectType.PV_DELIVERY_TRACKER + "))";
			}
			
			// added as a part of release 6.0 : resubscribe reciepient
			if (showeRecipResub == 0) { 
				sSql += " AND (ot.type_id NOT IN (" + ObjectType.RECIP_RESUBSCRIBE + "))";
			}
			
			sSql += " ORDER BY ot.type_name";
			
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1, u.s_user_id);
			rs = pstmt.executeQuery();
			
			String sTypeId = null;
			String sTypeName = null;
			int iMask = 0;
			
			while (rs.next())
			{
				sTypeId = rs.getString(1);
				sTypeName = rs.getString(2);
				iMask = rs.getInt(3);
				%>
				<tr>
					<td align="left" valign="middle">
						<%=sTypeName%>
						<INPUT type="hidden" name=<%=sTypeId%> value=0>
					</td>
					<td align="center" valign="middle" nowrap><INPUT type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.READ%> <%=((AccessRight.READ & iMask) == AccessRight.READ)?"checked":""%>></td>
					<td align="center" valign="middle" nowrap><INPUT type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.WRITE%> <%=((AccessRight.WRITE & iMask) == AccessRight.WRITE)?"checked":""%>></td>
					<td align="center" valign="middle" nowrap><INPUT type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.EXECUTE%> <%=((AccessRight.EXECUTE & iMask) == AccessRight.EXECUTE)?"checked":""%>></td>
					<td align="center" valign="middle" nowrap><INPUT type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.DELETE%> <%=((AccessRight.DELETE & iMask) == AccessRight.DELETE)?"checked":""%>></td>
					<td align="center" valign="middle" nowrap><INPUT type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.APPROVE%> <%=((AccessRight.APPROVE & iMask) == AccessRight.APPROVE)?"checked":""%>></td>
				</tr>
				<%
			}
			rs.close();
		}
		catch(Exception ex)
		{
			throw ex;
		}
		finally
		{
			if(pstmt != null) pstmt.close();
		}
		%>
				<tr>
					<TD colspan="6" align="center">
						<a class="subactionbutton" href="javascript:check_all(true);">Check All</a>&nbsp;&nbsp;
						<a class="subactionbutton" href="javascript:check_all(false);">Uncheck All</a>&nbsp;&nbsp;
					</TD>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</FORM>
<script language="javascript">
	
	var obj;
	
<% if (nUIType == UIType.HYATT_USER) { %>
	
	//USER ACCOUNTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.USER) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//IMPORTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.IMPORT) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//EXPORTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.EXPORT) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//RECIPIENTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.RECIPIENT) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//CUSTOM FIELDS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.RECIPIENT_ATTRIBUTE) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//CATEGORIES
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.CATEGORY) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//CONTENT
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.CONTENT) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//IMAGE LIBRARY
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.IMAGE) %>");
		obj[2].disabled = true;
		obj[3].disabled = true;
		
	var checks = document.getElementsByTagName("INPUT");
	var icount = 0;
	
	for (i=0; i < checks.length; i++)
	{
		if (checks[i].type == "checkbox")
		{
			if (checks[i].value == "32")
			{
				checks[i].disabled = true;
			}
		}
	}

<% } %>

<% if (nUIType == UIType.HYATT_ADMIN) { %>
	
	//IMPORTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.IMPORT) %>");
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//RECIPIENTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.RECIPIENT) %>");
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
		obj[5].disabled = true;
	//CUSTOM FIELDS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.RECIPIENT_ATTRIBUTE) %>");
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
		obj[5].disabled = true;
	
<% } %>
	
</script>
</BODY>
</HTML>
	<%
}
catch(SQLException sqlex)
{
	throw sqlex;
}
finally
{
	if(conn != null) cp.free(conn);
}
%>