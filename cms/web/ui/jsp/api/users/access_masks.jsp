<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>

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
	
	JsonObject data=new JsonObject();
	JsonArray arrayData=new JsonArray();
	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sSql = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	
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
			
			int k = 0;
			while (rs.next())
			{
				data=new JsonObject();
				sTypeId = rs.getString(1);
				sTypeName = rs.getString(2);
				iMask = rs.getInt(3);

				data.put("sTypeId" , sTypeId);
				data.put("sTypeName" , sTypeName);
				data.put("iMask" , iMask);
				k++;
				data.put("count",k);
				arrayData.put(data);

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