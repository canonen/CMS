<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.tgt.*,
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
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sErrors = null;
// get parameter values from Request
String sObjectType = BriteRequest.getParameter(request,"object_type");
String sObjectId = BriteRequest.getParameter(request,"object_id");
String sApprover = BriteRequest.getParameter(request,"approver");
// the following 7 attributes will only be used for campaign approval
String sSendTest = BriteRequest.getParameter(request,"send_test");
String sTestHtml = BriteRequest.getParameter(request,"test_html");
String sTestText = BriteRequest.getParameter(request,"test_text");
String sTestMultipart = BriteRequest.getParameter(request,"test_multipart");
String sTestDynamic = BriteRequest.getParameter(request,"test_dynamic");
String sDynamicRecipQty = BriteRequest.getParameter(request,"dynamic_recip_qty");
String sUseDynamicFilter = BriteRequest.getParameter(request,"dynamic_filter");
String sTestFilterId = BriteRequest.getParameter(request,"dynamic_test_filter");
String sSampleId = BriteRequest.getParameter(request,"sample_id");
String sComment = BriteRequest.getParameter(request,"aprvl_request_comment");
String sCampSampleFlag = null;

if (sUseDynamicFilter == null || !sUseDynamicFilter.equals("on"))          // if not using dynamic test, ignore value from Dynamic Test Filter
     sTestFilterId = null;

EmailList el = null;

User uApprover = new User(sApprover);
/*System.out.println("ObjectType:" + sObjectType);
System.out.println("ObjectId:" + sObjectId);
System.out.println("sApprover:" + sApprover);
System.out.println("sSendTest:" + sSendTest);
System.out.println("sTestFilterId:" + sTestFilterId);
System.out.println("Requestor name:" + user.s_user_name);
*/

// get  user_id of requestor
String sRequestor = user.s_user_id;

AccessPermission can = user.getAccessPermission(Integer.parseInt(sObjectType));

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sReturnPage = WorkflowUtil.getReturnPage(sObjectType);

// create/update ApprovalTask

// first check to see if this is a campaign, and if so check for sampleset
if (Integer.parseInt(sObjectType) == ObjectType.CAMPAIGN) {
     Campaign camp = new Campaign(sObjectId);
     CampSampleset camp_sampleset = new CampSampleset();
     camp_sampleset.s_camp_id = sObjectId;
     if(camp_sampleset.retrieve() > 0) { 
          if (sSampleId == null || sSampleId.equals("null") || sSampleId.equals("0")) {
//               System.out.println("approving for final campaign");
               sCampSampleFlag = "0";
          } else if (sSampleId.equals("all_samples")) {
//               System.out.println("approving for all samples");
               sCampSampleFlag = "1";
          }
     }
}

// check to see if Approval path exists for this cust (or group)
ApprovalPath apApprovalPath = WorkflowUtil.getCustApprovalPath(cust.s_cust_id);
//System.out.println("after WorkflowUtil.getCustApprovalPath...is apApprovalPath null:" + (apApprovalPath == null));
ApprovalTask atApprovalTask = null;
if (apApprovalPath == null || apApprovalPath.m_vCusts == null) {    //No Approval Path set up for this customer
// get current or create single ApprovalTask
     atApprovalTask = WorkflowUtil.getApprovalTask(cust.s_cust_id, sObjectType, sObjectId, sCampSampleFlag);
//     System.out.println("no approval path set up...got Approval Task");
} else {                      // Approval Path is set up for customer
// check for/ create Approval Tasks for each part of Path
//     System.out.println("approval path exists...get Approval Tasks");
     WorkflowUtil.getCustApprovalTasks(cust.s_cust_id, apApprovalPath, sObjectType, sObjectId,sCampSampleFlag);
     // get current ApprovalTask
//     System.out.println("approval path exists...getting current Task");
     atApprovalTask = WorkflowUtil.getApprovalTask(cust.s_cust_id, sObjectType, sObjectId,sCampSampleFlag);
}
if (atApprovalTask == null)
     logger.info("somehow atApprovalTask is null.");
//else
//     System.out.println("ApprovalTask ID:" + atApprovalTask.s_approval_id);
// if Approval path does not exist, check to see if Approval Tasks have already been created for this object, cust, 
// if not just setup an ApprovalTask with no next_tier_approval
// if Approval path does exist, check to see if Approval Tasks have already been created for this object, cust
// If Approval Tasks don't exist, create Approval Tasks for the entire Approval path (for every tier in the approval path, create an
// Approval Task and create the links among the Tasks with the next_tier_approval id

//set any previous Approval Requests for this Task to inactive
WorkflowUtil.setRequestsInactive(atApprovalTask.s_approval_id);
//System.out.println("after setRequestInactive asATaskID:"+atApprovalTask.s_approval_id);
// create new Approval Request 
ApprovalRequest arRequest = new ApprovalRequest();
arRequest.s_aprvl_id = atApprovalTask.s_approval_id;
arRequest.s_approver_id = sApprover;
arRequest.s_requestor_id = sRequestor;
if (sComment != null)
     arRequest.s_request_comment = sComment;
java.util.Calendar cal = java.util.Calendar.getInstance();
String sNow = "" + cal.get(cal.YEAR) + "-" + (cal.get(cal.MONTH)+1) + "-" + cal.get(cal.DAY_OF_MONTH) + " " + cal.get(cal.HOUR_OF_DAY) + ":" + cal.get(cal.MINUTE);
//System.out.println("Now:" + sNow);
arRequest.s_request_date = sNow;
arRequest.s_active_flag = "1";
arRequest.s_cust_id = cust.s_cust_id;
arRequest.save();
//arRequest.retrieve();


// if not campaign, send approval request email
if (Integer.parseInt(sObjectType) != ObjectType.CAMPAIGN && Integer.parseInt(sObjectType) != ObjectType.FILTER) {
     // change status of object
     WorkflowUtil.setPendingStatus(sObjectType, sObjectId);
     WorkflowEmailUtil.sendApprovalRequestEmail(arRequest.s_approval_request_id,sObjectType,sObjectId);
} else if (Integer.parseInt(sObjectType) == ObjectType.FILTER) {
     // update the filter
     com.britemoon.cps.tgt.Filter filt = new com.britemoon.cps.tgt.Filter(sObjectId);
     if (filt.s_status_id.equals(String.valueOf(FilterStatus.NEW))) {
          filt.setStatus(FilterStatus.QUEUED_FOR_PROCESSING);
          FilterUtil.sendFilterUpdateRequestToRcp(sObjectId);
     }
     filt.setAprvlStatusFlag(0);
     filt.setStatus(FilterStatus.PENDING_APPROVAL);
     // WorkflowEmailUtil.sendApprovalRequestEmail(arRequest.s_approval_request_id,sObjectType,sObjectId);
} else if (Integer.parseInt(sObjectType) == ObjectType.CAMPAIGN) {
     // if campaign, get recip counts --> create test campaign with calculate-only mode and send test
     String sMode = null;
     String sNewCampId = null;
     //Campaign camp = new Campaign(sObjectId);
     // 'send' campaign in order to create campaign to eventually send, and set this campaign to pending
     sMode = "set_pending";
     sendTest(sObjectId, sSampleId, sMode,null, null, null, cust, user);
     // create and 'send' the calculate only test campaign
     sMode = "calc_only";
     sendTest(sObjectId, sSampleId, sMode,null, null, null, cust, user);

     // check if user chose to send test to approver.  If so send the test.
     if (sSendTest != null && sSendTest.equals("on")) {   //  if test send requested, ...
//          System.out.println("Sending test.");
          sMode = "test";
          // create a test list with JUST the approver !!!!!
          // ** Create a new test list EVERY time?  or look for and update the test list?  OR 2 test lists per approval request--1 random, 1 dynamic?

          EmailListItems elis = new EmailListItems();
          String sEmail = uApprover.s_email;
          sEmail = new String (sEmail.trim().getBytes("ISO_8859-1"), "UTF-8");
//          System.out.println("Email of Approver:" + sEmail);
          if(sEmail.equals("")) {
               sErrors = "Approver has no email address.  Cannot send test to Approver.";
               logger.error("approval_request_send.jsp", new Exception(sErrors));
          } else {
               if (sTestHtml != null && !sTestHtml.equals("")) {
                    EmailListItem eli = new EmailListItem();
                    eli.s_email = sEmail;
                    eli.s_email_type_id = "1";
                    elis.add(eli);
               }
               if (sTestText != null && !sTestText.equals("")) {
                    EmailListItem eli = new EmailListItem();
                    eli.s_email = sEmail;
                    eli.s_email_type_id = "2";
                    elis.add(eli);
               }
               if (sTestMultipart != null && !sTestMultipart.equals("")) {
                    EmailListItem eli = new EmailListItem();
                    eli.s_email = sEmail;
                    eli.s_email_type_id = "3";
                    elis.add(eli);
               }
               el = new EmailList();
//               System.out.println("Creating Email List...");

               el.s_cust_id = cust.s_cust_id;
               el.s_list_name = "ApprovalRequest(" + arRequest.s_approval_request_id + ")";
               if (sTestDynamic != null && sTestDynamic.equals("on")) {
//                    System.out.println("going to create dynamic test...");
                    el.s_type_id = "7";   // dynamic content test
                    
               } else {
                    el.s_type_id = "2";   // regular ole random test
               }
               el.m_EmailListItems = elis;
               el.s_status_id = String.valueOf(EmailListStatus.ACTIVE);
               el.save();

               //send test list to RCP
               String sRequest = el.toXml();
//               System.out.println("XML of new Email list:" + sRequest);
               String sResponse = Service.communicate(ServiceType.RQUE_LIST_SETUP, cust.s_cust_id, sRequest);

               if (sResponse.indexOf("OK") == -1)
                    sErrors = "There was a communication problem while saving email list.<BR> " +
                                   "Please return to email list later and resave it even if you see correct email list.<BR>" +
                                   "Otherwise changes you made may not have effect when you send campaign<BR>" +
                                   "Sorry for any inconvenience.";

          }

          if (sErrors == null) {
               // send test
               sendTest(sObjectId, sSampleId, sMode, sTestFilterId, el.s_list_id, sDynamicRecipQty,cust, user);
               el.s_status_id = String.valueOf(EmailListStatus.DELETED);
               el.save();
          }
     }
}


Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null; 
ConnectionPool cp = null;
Connection conn = null;


try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("approval_request.send.jsp");
	stmt = conn.createStatement();


%>
<HTML>

<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Request for Approval sent.</b>
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
						Request for Approval sent
                              <br><br>
						<a href="<%=sReturnPage%>" target="_top">Back to List</a>
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

} catch (Exception ex) {
	logger.error("Exception: ",ex);
     throw ex;
} finally {
	if ( pstmt != null ) pstmt.close ();	
	if ( stmt != null ) stmt.close ();	
	if ( conn != null ) cp.free(conn);
}

%>

<%!
private static String sendTest
	(String sCampId, String sSampleId, String sMode, String sNewFilterId, String sApproverTestListId, String sDynamicRecipQty,
		Customer cust, User user)
			throws Exception
{

     String sNewCampId = null;
//     System.out.println("in sendTest method of approval_request_send...sCampId:" + sCampId + ";mode:"+sMode);
     Campaign camp = new Campaign(sCampId);


     if("all_samples".equals(sSampleId) && !"calc_only".equals(sMode))
     {
//          System.out.println("all_samples is " + sSampleId);
          CampSampleset cs = new CampSampleset();
          cs.s_camp_id = sCampId;

          if(cs.retrieve() > 0)
          {
               int nCampQty = Integer.parseInt(cs.s_camp_qty);

               // === Create super campaign for sampleset ===
		
               SuperCamp super_camp = null;
               SuperCampCamp super_camp_camp = null;
               if("set_pending".equals(sMode))
               {
                    super_camp = new SuperCamp();
                    super_camp.s_super_camp_name = camp.s_camp_name + " ( sampleset)";
                    super_camp.s_cust_id = camp.s_cust_id;
                    super_camp.save();
			
                    super_camp_camp = new SuperCampCamp();					
                    super_camp_camp.s_super_camp_id = super_camp.s_super_camp_id;
                    super_camp_camp.s_camp_id = sCampId;
                    super_camp_camp.save();
               }
		

               // === === ===

               for(int i = 1; i <= nCampQty; i++)
               {
                    sNewCampId =
                         WorkflowUtil.sendCamp(sCampId, i, sMode, sNewFilterId, sApproverTestListId, sDynamicRecipQty, cust.s_cust_id, user.s_user_id, null);
               }
          }
     } else {
//          System.out.println("no samples or there are samples, but calc_only is mode");
          if (sSampleId == null || sSampleId.equals("null"))
               sSampleId = "0";
          if (sSampleId.equals("all_samples"))
               sSampleId = "-1";
          int nSampleId = Integer.parseInt(sSampleId);
          sNewCampId =
               WorkflowUtil.sendCamp(sCampId, nSampleId, sMode, sNewFilterId, sApproverTestListId, sDynamicRecipQty, cust.s_cust_id, user.s_user_id, null);
     }
     return sNewCampId;

}




%>
