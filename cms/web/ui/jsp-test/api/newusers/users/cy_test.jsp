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
<%@ include file="../../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.USER);
int nUIType = ui.n_ui_type_id;
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


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
12346
<%
 out.print("<s_cust_id>" + u.s_cust_id + "</s_cust_id>");
out.print("<user_name>" + u.s_user_name + "</user_name>");
 out.print("<login_name>" + u.s_login_name + "</login_name>");

%>
 