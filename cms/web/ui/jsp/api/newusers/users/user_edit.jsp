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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

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
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	if(!can.bRead)
	{
		response.sendRedirect("../../access_denied.jsp");
		return;
	}
%>

<%


	try {
		User u = null;
		UserUiSettings uus = null;

		String sCustId = cust.s_cust_id;
		String sUserId = request.getParameter("user_id");


		JsonObject data = new JsonObject();
		JsonArray array = new JsonArray();

		if (sUserId == null) {
			u = new User();
			u.s_cust_id = cust.s_cust_id;
			uus = new UserUiSettings();
		} else {
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
				arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.USER), sUserId);
//          System.out.println("arRequest retrieved from WorkflowUtil is:" + ((arRequest==null)?"null":arRequest.s_approval_request_id));
			}
			if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
				sAprvlRequestId = arRequest.s_approval_request_id;
				isApprover = true;
			}
		}

		if (u.s_cust_id != null) {
			data.put("cust_id", u.s_cust_id);
		} else data.put("cust_id", "");

		if (u.s_user_id != null) {
			data.put("user_id", u.s_user_id);
		}
		data.put("disposition_id", "0");
		data.put("objectType", String.valueOf(ObjectType.USER));
		if (sUserId != null) {
			data.put("objectID", sUserId);
		} else data.put("objectID", sUserId);

		data.put("aprvl_request_id", sAprvlRequestId);
		data.put("save_and_request_approval", "0");

		if (u.s_user_name == null) data.put("userName", "");
		else data.put("userName", u.s_user_name);

		if (u.s_last_name == null) data.put("lastName", "");
		else data.put("lastName", u.s_last_name);

		if (u.s_position == null) data.put("position", "");
		else data.put("position", u.s_position);

		if (u.s_phone == null) data.put("phone", "");
		else data.put("phone", u.s_phone);

		if (u.s_email == null) data.put("email", "");
		else data.put("email", u.s_email);

		if (u.s_descrip == null) data.put("descrip", "");
		else data.put("descrip", u.s_descrip);

		if (u.s_login_name == null) data.put("loginName", "");
		else data.put("loginName", u.s_login_name);

		if (u.s_password == null) data.put("password", "");
		else data.put("password", u.s_password);

		if ((bWorkflow && !can.bApprove)) data.put("status", "disabled");
		else data.put("status", "");

		data.put("statuSID", u.s_status_id);

		UIType uiType = new UIType();
		boolean bHyatt = false;
		int showOption = 1;
		int iSelected = Integer.parseInt(uus.s_ui_type_id);


		bHyatt = ui.getFeatureAccess(Feature.HYATT);

		if (bHyatt) showOption = 2;

		if (bHyatt && (nUIType == UIType.ADVANCED)) showOption = 0;

		if (showOption == 0) {
			if (iSelected == uiType.STANDARD) {
				data.put("checked", "selected");
				data.put("uiType", "Standard");
			} else {
				data.put("checked", "");
				data.put("uiType", "Standard");
			}
			if (iSelected == uiType.ADVANCED) {
				data.put("checked", "selected");
				data.put("uiType", "Advanced");
			} else {
				data.put("checked", "");
				data.put("uiType", "Advanced");
			}
			if (iSelected == uiType.HYATT_USER) {
				data.put("checked", "selected");
				data.put("uiType", "HYATT User");
			} else {
				data.put("checked", "");
				data.put("uiType", "HYATT User");
			}
			if (iSelected == uiType.HYATT_ADMIN) {
				data.put("checked", "selected");
				data.put("uiType", "HYATT Admin");
			} else {
				data.put("checked", "");
				data.put("uiType", "HYATT Admin");
			}
		}
		else if (showOption == 1)
		{
			if (iSelected == uiType.STANDARD) {
				data.put("checked", "selected");
				data.put("uiType", "Standard");
			} else {
				data.put("checked", "");
				data.put("uiType", "Standard");
			}
			if (iSelected == uiType.ADVANCED) {
				data.put("checked", "selected");
				data.put("uiType", "Advanced");
			} else {
				data.put("checked", "");
				data.put("uiType", "Advanced");
			}

		}
		else
		{
			if (iSelected == uiType.HYATT_USER) {
				data.put("checked", "selected");
				data.put("uiType", "HYATT User");
			} else {
				data.put("checked", "");
				data.put("uiType", "HYATT User");
			}
			if (iSelected == uiType.HYATT_ADMIN) {
				data.put("checked", "selected");
				data.put("uiType", "HYATT Admin");
			} else {
				data.put("checked", "");
				data.put("uiType", "HYATT Admin");
			}
		}

		data.put("category_id", CategortiesControl.toHtmlOptions(cust.s_cust_id, uus.s_category_id));

//		PreparedStatement pstmt = null;
//		ResultSet rs = null;
//		try{
//
//
//			String sSql  =
//					" SELECT category_id, category_name" +
//							" FROM ccps_category" +
//							" WHERE cust_id=?"+
//							" ORDER BY category_name";
//
//
//
//				rs = pstmt.executeQuery(sSql);
//				pstmt.setString(1, sCustId);
//
//				String sCategoryId = null;
//				String sCategoryName = null;
//
//				while (rs.next())
//				{
//
//					sCategoryId = rs.getString(1);
//					sCategoryName = new String(rs.getBytes(2), "UTF-8");
//					data.put("category_id",sCategoryId);
//					data.put("category_name",sCategoryName);
//					if(sCategoryId.equals(uus.s_category_id)) data.put("checked","selected");
//				}
//				rs.close();
//			}
//			catch(Exception ex) {throw ex;}
//			finally{if(pstmt != null) pstmt.close();}


		if (uus.s_recip_view_count == null) data.put("recipViewCount", 500);
		else data.put("recipViewCount", uus.s_recip_view_count);

		if ("10".equals(uus.s_default_page_size)) data.put("s_default_page_size", "selected");
		else data.put("s_default_page_size", "");
		if ("25".equals(uus.s_default_page_size)) data.put("s_default_page_size", "selected");
		else data.put("s_default_page_size", "");
		if ("50".equals(uus.s_default_page_size)) data.put("s_default_page_size", "selected");
		else data.put("s_default_page_size", "");
		if ("100".equals(uus.s_default_page_size)) data.put("s_default_page_size", "selected");
		else data.put("s_default_page_size", "");
		if ("1000".equals(uus.s_default_page_size)) data.put("s_default_page_size", "selected");
		else data.put("s_default_page_size", "");


		boolean hasOwnership = ui.getFeatureAccess(Feature.RECIP_OWNERSHIP);
		if (hasOwnership) {

			if ("0".equals(u.s_recip_owner)) data.put("recipOwner", "selected");
			else data.put("recipOwner", "");
			if ("1".equals(u.s_recip_owner)) data.put("recipOwner", "selected");
			else data.put("recipOwner", "");
		} else {
			data.put("recipOwner", "0");
		}

		int showPVtab = 1;
		boolean bFeat = false;
		bFeat = ui.getFeatureAccess(Feature.PV_LOGIN);
		if (!bFeat) showPVtab = 0;
		if (showPVtab == 1) {

			if (u.s_pv_login == null) data.put("pv_login", "");
			else data.put("pv_login", u.s_pv_login);

			if (u.s_pv_password == null) data.put("pv_login", "");
			else data.put("pv_password", u.s_pv_password);
		}
		array.put(data);
		out.println(array);

		u.s_user_name = BriteRequest.getParameter(request, "user_name");
		u.s_last_name = BriteRequest.getParameter(request, "last_name");
		u.s_cust_id = sCustId;
		u.s_login_name = BriteRequest.getParameter(request, "login_name");
		u.s_password = BriteRequest.getParameter(request, "password");
		u.s_position = BriteRequest.getParameter(request, "position");
		u.s_phone = BriteRequest.getParameter(request, "phone");
		u.s_email = BriteRequest.getParameter(request, "email");
		u.s_descrip = BriteRequest.getParameter(request, "descrip");
		u.s_status_id = BriteRequest.getParameter(request, "status_id");
		u.s_recip_owner = BriteRequest.getParameter(request, "recip_owner");
		u.s_pv_login = BriteRequest.getParameter(request,"pv_login");
		u.s_pv_password = BriteRequest.getParameter(request,"pv_password");


		uus.s_user_id = BriteRequest.getParameter(request, "user_id");
		uus.s_cust_id = sCustId;
		uus.s_category_id = BriteRequest.getParameter(request, "category_id");
		uus.s_ui_type_id = BriteRequest.getParameter(request, "ui_type_id");
		uus.s_recip_view_count = BriteRequest.getParameter(request, "recip_view_count");
		uus.s_default_page_size = BriteRequest.getParameter(request, "default_page_size");

		if (uus.s_cust_id == null) uus.s_category_id = null;
		if (uus.s_category_id == null) uus.s_cust_id = null;

		u.m_UserUiSettings = uus;
		u.saveWithSync();
	}
	catch (Exception e){
		out.println(e.getMessage());
	}
	%>



