<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.*,
			java.io.*,java.util.*,
			java.sql.*,javax.servlet.http.*,
			javax.servlet.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sErrors = null;
// get parameter values from Request
String sObjectType = BriteRequest.getParameter(request,"object_type");
String sObjectId = BriteRequest.getParameter(request,"object_id");
String sDispositionId = BriteRequest.getParameter(request,"disposition_id");
String sContentId = BriteRequest.getParameter(request,"contentID");
String sComment = BriteRequest.getParameter(request,"aprvl_comment");
String sAprvlRequestId = BriteRequest.getParameter(request,"aprvl_request_id");

AccessPermission can = user.getAccessPermission(Integer.parseInt(sObjectType));

if(!can.bApprove)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sReturnPage = WorkflowUtil.getReturnPage(sObjectType);

// update ApprovalRequest with disposition, aprvl_comment, disposition_date
ApprovalRequest arRequest = new ApprovalRequest(sAprvlRequestId);
arRequest.s_disposition_id = sDispositionId;
java.util.Calendar cal = java.util.Calendar.getInstance();
String sNow = "" + cal.get(cal.YEAR) + "-" + (cal.get(cal.MONTH)+1) + "-" + cal.get(cal.DAY_OF_MONTH) + " " + cal.get(cal.HOUR_OF_DAY) + ":" + cal.get(cal.MINUTE);
arRequest.s_disposition_date = sNow;
if (sComment != null)
     arRequest.s_aprvl_comment = sComment;
arRequest.save();
//System.out.println("saved approval request.");
//System.out.println("calling doDisposition..." + sObjectId);
boolean bSuccess = WorkflowUtil.doDisposition(sObjectType, sObjectId, arRequest);
//System.out.println("after doDisposition...about to sendRequestorEmail...bSuccess:"+ bSuccess);
//if (bSuccess) {
     WorkflowEmailUtil.sendRequestorEmail(arRequest);
//}
//System.out.println("bSuccess:" + bSuccess + "; sObjectType:" + sObjectType + "; sDispositionId:" + sDispositionId);

if (bSuccess) {
     if (sObjectType.equals("190") && sDispositionId.equals("50")) {      // Approver taking over edits for a campaign
          Campaign camp = new Campaign(sObjectId);
          if (camp != null) {
               String sOriginCampId = null;
               if (camp.s_origin_camp_id == null) {
                    sOriginCampId = camp.s_camp_id;
               } else {
                    sOriginCampId = camp.s_origin_camp_id;
               }
               response.sendRedirect("../camp/camp_edit.jsp?camp_id=" + sOriginCampId + "&type_id=" + camp.s_type_id);
               return;
          }
     }
}

/* as of 12/6/04, rejecting an Import does NOT rollback the import, so the following
* code is not used.
*/
/*
if (bSuccess && 
     Integer.parseInt(sObjectType) == ObjectType.IMPORT && 
     Integer.parseInt(arRequest.s_disposition_id) == ApprovalDisposition.REJECT) {
     // for rejected imports, the import gets rolled back (deleted from the database), so we need to send the email
     // first (while the import name, etc. is still in the database), and then roll back the import
     ///
     WorkflowUtil.rollbackImport(sObjectId, arRequest.s_cust_id);
}
*/


%>
<HTML>

<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Approval Response sent.</b>
          </td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
     <% if (sErrors != null) { %>
          <tbody class=EditBlock id=block1_Step0>
          <tr>
               <td class=fillTab valign=top align=center width=650>
                    <table class=main cellspacing=1 cellpadding=2 width="100%">
                         <tr>
                              <td align="center" valign="middle" style="padding:10px;">
                                   <br>
                                   <%=sErrors%>
                              </td>
                         </tr>
                    </table>
               </td>
          </tr>
          </tbody>
     <% } %>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						Approval Response sent
                              <br><br>
						<a href="<%=sReturnPage%>" target="_parent">Back to List</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>
<%


%>

