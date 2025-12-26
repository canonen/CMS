<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.USER);
int nUIType = ui.n_ui_type_id;

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<%
String sUserId = request.getParameter("user_id");

User u = null;
UserUiSettings uus = null;

if( sUserId == null)
{
	u = new User();
	u.s_cust_id = cust.s_cust_id;
	uus = new UserUiSettings();
}
else
{
	u = new User(sUserId);
	uus = new UserUiSettings(sUserId);	
}

int iStatusId = 0;
if (u.s_status_id != null)
     iStatusId = Integer.parseInt(u.s_status_id);
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
%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
	<SCRIPT src="../../../js/scripts.js"></SCRIPT>
</HEAD>

<SCRIPT LANGUAGE="JAVASCRIPT">

function SubmitCheck()
{
     undisable_forms();       //just in case
// Check the text
	var Frm = document.user;
	var errCount;
	
	if(isBlank(Frm.user_name, "User Name")) return;
	else if(isBlank(Frm.last_name, "Last Name")) return;	
	else if(isBlank(Frm.login_name, "LogIn Name")) return;
	else if(isBlank(Frm.password, "Password")) return;
	else if(isBlank(Frm.position, "Position"))return;
	else if(isBlank(Frm.phone, "Phone")) return;
	else if(isBlank(Frm.email, "Email Address")) return;
	else if(isBlank(Frm.recip_view_count, "Recipient View Record Count")) return;
	else if(!isEmail(Frm.email.value))
	{
		alert("Please enter a valid email address.");
		return;
	}
	//else if(!validPhone(Frm.phone.value))
	//{
		//alert("Please enter a valid phone number.");
		//return;
	//}
	else
	{
		Frm.submit();
	}
}

function isBlank(field, strBodyHeader)
{
	strTrimmed = trim(field.value);
	if (strTrimmed.length > 0)
	{
		return false;
	}
	alert("\"" + strBodyHeader + "\" is a required field. Please type a value.");
	field.focus();
	return true;
}

function validPhone(str)
{
    v=str.split("-").join("");
    if(isNaN(v)||str.length!=12||str.split("-").length!=3)
    {
       return false;
    }
    return true;
}


function isEmail(str)
{
	var supported = 0;
	if (window.RegExp)
	{
		var tempStr = "a";
		var tempReg = new RegExp(tempStr);
		if (tempReg.test(tempStr)) supported = 1;
	}
	
	if (!supported) 
	  return (str.indexOf(".") > 2) && (str.indexOf("@") > 0);
	var r1 = new RegExp("(@.*@)|(\\.\\.)|(@\\.)|(^\\.)");
	var r2 = new RegExp("^.+\\@(\\[?)[a-zA-Z0-9\\-\\.]+\\.([a-zA-Z]{2,3}|[0-9]{1,3})(\\]?)$");
	return (!r1.test(str) && r2.test(str)); 
}

function trimLeft(s)
{
	var whitespaces = " \t\n\r";
	for(n = 0; n < s.length; n++)
	{
		if (whitespaces.indexOf(s.charAt(n)) == -1) return (n > 0) ? s.substring(n, s.length) : s;
	}
	return("");
}

function trimRight(s)
{
	var whitespaces = " \t\n\r";
	for(n = s.length - 1; n  > -1; n--)
	{
		if (whitespaces.indexOf(s.charAt(n)) == -1) return (n < (s.length - 1)) ? s.substring(0, n+1) : s;
	}
	return("");
}

function trim(s)
{
	return ((s == null) ? "" : trimRight(trimLeft(s)));
}

function UserDelete(sUserId) {

     if (confirm('Are you sure you want to delete this User?')) {
          if (sUserId == null) {       // user was never saved
               alert("New User cancelled.");
               location.href='user_list.jsp';
          } else {
               user.action="user_delete.jsp";
               user.submit();
          }
     }

}
     function RequestApproval() {

          user.save_and_request_approval.value = '1';
          SubmitCheck();
          // user.action="../../workflow/approval_request_edit.jsp?object_type=" + <%=ObjectType.USER%>+ "&object_id=" + <%=sUserId%>;

     }

     function workflow_approve() {
          undisable_forms()
          user.action = "../../workflow/approval_send.jsp"
          user.disposition_id.value = "10"     // approve
          user.submit()
     }

     function workflow_reject() {
          undisable_forms()
          user.action = "../../workflow/approval_edit.jsp"
          user.disposition_id.value = "90"     // reject
          user.submit()
     }

     function workflow_approve_w_comments() {
          undisable_forms()
          user.action = "../../workflow/approval_edit.jsp"
          user.disposition_id.value = "10"     // approve
          user.submit()
     }

     function reset_draft_status()
     {
          undisable_forms()
          document.user.status_id.value = <%=UserStatus.DRAFT%>
          document.user.submit()
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
<BODY <%=(!can.bWrite || (bWorkflow && iStatusId == UserStatus.PENDING_APPROVAL))?"onload='disable_forms();'":""%>>
<%
if(can.bWrite)
{ 
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
     <%
          if (!bWorkflow || 
               (bWorkflow && can.bApprove && iStatusId != UserStatus.PENDING_APPROVAL) || 
               (bWorkflow && !can.bApprove && (iStatusId == UserStatus.DRAFT || iStatusId == 0))) {
     %>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="SubmitCheck();">Save</a>
			</td>
		<%
     } 
     if (bWorkflow && !can.bApprove && 
          (iStatusId == UserStatus.DRAFT || iStatusId == UserStatus.ACTIVATED || iStatusId == 0)) {
     %>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="RequestApproval();">Request Approval</a>
			</td>
     <%
     }
     if (bWorkflow && !can.bApprove && 
          (iStatusId == UserStatus.ACTIVATED)) {
     %>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="reset_draft_status();">Set status back to Draft & Save</a>
			</td>
     <%
     }
//     System.out.println("workflow/canapprove/isapprover/pending:  " + bWorkflow + "/" + can.bApprove + "/" + isApprover +
//                                        "/" + (iStatusId == UserStatus.PENDING_APPROVAL));
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

		if(can.bDelete)
		{
			%>
			<td align="left" valign="middle">
				<a class="deletebutton" href="#" onClick="UserDelete(<%=sUserId%>);">Delete</a> <!--  <IMG STYLE="cursor:hand" SRC="../../../images/deletebutton.gif" onClick="UserDelete(<%=sUserId%>);"> -->
			</td>
			<%
		}
		
		if(sUserId != null)
		{
			%>
			<td align="left" valign="middle">
				View: <A class="subactionbutton" href="access_masks.jsp?user_id=<%=sUserId%>"><B>Access Rights</B></A>
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
<FORM method="POST" action="user_save.jsp" name="user">
<INPUT type="hidden" name="cust_id" size="50" readonly value="<%=(u.s_cust_id==null)?"":u.s_cust_id%>">
<% if(u.s_user_id != null) { %><INPUT type="hidden" name="user_id" size="50" readonly value=<%=u.s_user_id%>><% } %>
<input type="hidden" name="disposition_id" value="0"/>
<input type="hidden" name="object_type" value="<%=String.valueOf(ObjectType.USER)%>"/>
<input type="hidden" name="object_id" value="<%=(sUserId != null)?sUserId:"0"%>"/>
<INPUT TYPE="hidden" NAME="aprvl_request_id"	value="<%=sAprvlRequestId%>">
<INPUT TYPE="hidden" NAME="save_and_request_approval"	value="0">

<!--- Step 1 Header----->
<table width="500" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Contact Information</td>
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
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">First Name</td>
					<td align="left" valign="middle"><INPUT type="text" name="user_name" size="50" value="<%=(u.s_user_name==null)?"":u.s_user_name%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Last Name</td>
					<td align="left" valign="middle"><INPUT type="text" name="last_name" size="50" value="<%=(u.s_last_name==null)?"":u.s_last_name%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Position</td>
					<td align="left" valign="middle"><INPUT type="text" name="position" size="50" value="<%=(u.s_position==null)?"":u.s_position%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Phone</td>
					<td align="left" valign="middle"><INPUT type="text" name="phone" size="50" value="<%=(u.s_phone==null)?"":u.s_phone%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Email</td>
					<td align="left" valign="middle"><INPUT type="text" name="email" size="50" value="<%=(u.s_email==null)?"":u.s_email%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Comments</td>
					<td align="left" valign="middle"><TEXTAREA rows="5" name="descrip" cols="40"><%=(u.s_descrip==null)?"":u.s_descrip%></TEXTAREA></td>
				</tr>
				<tr>
					<td align="left" valign="middle" colspan="2">* Please enter proper contact information to enable the most efficient technical support process.</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width="500" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Login Information</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="500" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="500">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Login</td>
					<td align="left" valign="middle"><INPUT type="text" name="login_name" size="50" value="<%=(u.s_login_name==null)?"":u.s_login_name%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Password</td>
					<td align="left" valign="middle"><INPUT type="password" name="password" size="50" value="<%=(u.s_password==null)?"":u.s_password%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Status</td>
					<td align="left" valign="middle">
						<select size="1" name="status_id" <%=((bWorkflow && !can.bApprove)?"disabled":"")%>>
						<%=UserStatus.toHtmlOptions(u.s_status_id)%>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 3 Header----->
<table width="500" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Interface Settings</td>
	</tr>
</table>
<br>
<!---- Step 3 Info----->
<table id="Tabs_Table3" cellspacing="0" cellpadding="0" width="500" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block3_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="500">
			<table class="main" cellspacing="1" cellpadding="2" width="100%"<%=(nUIType != UIType.ADVANCED && nUIType != UIType.HYATT_ADMIN)?" style=\"display: none\"":""%>>
				<tr>
					<td align="left" valign="middle" width="100">User Interface type:</td>					
					<td align="left" valign="middle">
						<select name="ui_type_id">
						<%
						boolean bHyatt = false;
						int showOption = 1;
						
						bHyatt = ui.getFeatureAccess(Feature.HYATT);
						
						if (bHyatt) showOption = 2;
						
						if (bHyatt && (nUIType == UIType.ADVANCED)) showOption = 0;
						%>
						<%= UIType.toHtmlOptions(uus.s_ui_type_id, showOption) %>
						</select>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Default Category:</td>
					<td align="left" valign="middle">
						<select name="category_id">
							<option value="">All</option>
							<%=CategortiesControl.toHtmlOptions(cust.s_cust_id, uus.s_category_id)%>
						</select>
					</td>
				</tr>
				<tr>
					<td width="75">Recipient View Record Count</td>					
					<td>
						<input type="text" name="recip_view_count" size="20" value="<%= (uus.s_recip_view_count == null)?"500":uus.s_recip_view_count %>">
					</td>
				</tr>
				<tr>
					<td width="75">Default Page Size</td>					
					<td>
						<select name="default_page_size">
							<option value="10"<%=("10".equals(uus.s_default_page_size))?" selected":""%>>10</option>
							<option value="25"<%=(("25".equals(uus.s_default_page_size)) || (uus.s_default_page_size == null))?" selected":""%>>25</option>
							<option value="50"<%=("50".equals(uus.s_default_page_size))?" selected":""%>>50</option>
							<option value="100"<%=("100".equals(uus.s_default_page_size))?" selected":""%>>100</option>
							<option value="1000"<%=("1000".equals(uus.s_default_page_size))?" selected":""%>>ALL</option>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<%
boolean hasOwnership = ui.getFeatureAccess(Feature.RECIP_OWNERSHIP);
if (hasOwnership)
{
	%>
<br><br>
<!--- Step 4 Header----->
<table width="500" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 4:</b> Recipient Ownership</td>
	</tr>
</table>
<br>
<!---- Step 4 Info----->
<table id="Tabs_Table3" cellspacing="0" cellpadding="0" width="500" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block3_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="500">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Recipient Record Owner?</td>					
					<td align="left" valign="middle">
						<select size="1" name="recip_owner">
							<option value="0"<%=("0".equals(u.s_recip_owner))?" selected":""%>>NO</option>
							<option value="1"<%=("1".equals(u.s_recip_owner))?" selected":""%>>YES</option>			
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
	<%
}
else
{
	%>
	<input type="hidden" name="recip_owner" value="0">
	<%
}
%>
<br><br>
<!-- added for release 5.9 , reporting changes -->
<% 
int showPVtab = 1;
boolean bFeat = false;
bFeat = ui.getFeatureAccess(Feature.PV_LOGIN);
if (!bFeat) showPVtab = 0;
if (showPVtab == 1) { 
%>				
<!--- Step 5 Header----->
<table width="500" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 4:</b> PV Login Settings</td>
	</tr>
</table>
<br>
<!---- Step 5 Info----->
<table id="Tabs_Table5" cellspacing="0" cellpadding="0" width="500" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="500"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block5_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="500">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">PV Login</td>
					<td align="left" valign="middle"><INPUT type="text" name="pv_login" size="50" value="<%=(u.s_pv_login==null)?"":u.s_pv_login%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">PV Password</td>
					<td align="left" valign="middle"><INPUT type="password" name="pv_password" size="50" value="<%=(u.s_pv_password==null)?"":u.s_pv_password%>"></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<% } %>
<br><br>

</FORM>
</BODY>
</HTML>
