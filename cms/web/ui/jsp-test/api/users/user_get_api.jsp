<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.sql.*,
			org.json.JSONException,
            org.json.JSONObject,
			org.json.XML,
			java.util.*,org.apache.log4j.*"
	
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../utilities/header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
// if(logger == null)
// {
	// logger = Logger.getLogger(this.getClass().getName());
// }

// AccessPermission can = user.getAccessPermission(ObjectType.USER);
// int nUIType = ui.n_ui_type_id;

// if(!can.bRead)
// {
	// response.sendRedirect("../../access_denied.jsp");
	// return;
// }
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
// boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.USER);
String sAprvlRequestId = request.getParameter("aprvl_request_id");
boolean isApprover = false;
if (sUserId != null) {
     if (sAprvlRequestId == null)
          sAprvlRequestId = "";
     ApprovalRequest arRequest = null;
     if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
          arRequest = new ApprovalRequest(sAprvlRequestId);
     } else {
          // arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.USER),sUserId);
//          System.out.println("arRequest retrieved from WorkflowUtil is:" + ((arRequest==null)?"null":arRequest.s_approval_request_id));
     }
     if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
          sAprvlRequestId = arRequest.s_approval_request_id;
          isApprover = true;
     }
}
JSONObject data = new JSONObject();

data.put("userName",u.s_user_name);
data.put("lastName",u.s_last_name);
data.put("password",u.s_password);
data.put("loginName",u.s_login_name);
data.put("position",u.s_position);
data.put("phone",u.s_phone);
data.put("email",u.s_email);
data.put("descrip",u.s_descrip);
data.put("categoryId",uus.s_category_id);
data.put("uiTypeId",uus.s_ui_type_id);
data.put("recipViewCount",uus.s_recip_view_count);
data.put("defaultPageSize",uus.s_default_page_size);


data.put("status_id",u.s_status_id);
data.put("pass_exp_date",u.s_pass_exp_date);
data.put("pass_notify_date",u.s_pass_notify_date);
data.put("recip_owner",u.s_recip_owner);
data.put("pv_login",u.s_pv_login);
data.put("pv_password",u.s_pv_password);
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.setHeader("Access-Control-Allow-Origin", "*");

out.print(data);





%>

 