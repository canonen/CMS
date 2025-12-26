<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
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

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<%
String sUserId = request.getParameter("user_id");
String sSaveAndRequestApproval = request.getParameter("save_and_request_approval");
User u = new User(sUserId);

AccessMasks ams = new AccessMasks();
AccessMask am = null;
int iMask = 0;
String sTypeId = null;

for (Enumeration eTypeIds = request.getParameterNames(); eTypeIds.hasMoreElements();)
{
     sTypeId = (String)eTypeIds.nextElement();
     if (sTypeId.equals("disposition_id")) continue;
     if (sTypeId.equals("object_type")) continue;
     if (sTypeId.equals("object_id")) continue;
     if (sTypeId.equals("aprvl_request_id")) continue;
     if (sTypeId.equals("save_and_request_approval")) continue;

	am = new AccessMask();
	am.s_user_id = u.s_user_id;
	am.s_type_id = sTypeId;

	if("user_id".equals(am.s_type_id)) continue;


	String[] sValues = request.getParameterValues(am.s_type_id);
	int l = ( sValues == null )?0:sValues.length;

	iMask = 0;
	for (int i = 0; i < l; i++)
	{
		iMask = iMask | Integer.parseInt(sValues[i]);
	}

	am.s_mask = String.valueOf(iMask);
	ams.add(am);
}

ams.saveWithSync();

if (sSaveAndRequestApproval.equals("1")) {
     u.retrieve();
     String sRedirUrl = "../../workflow/approval_request_edit.jsp?object_type=" + ObjectType.USER+ "&object_id=" + u.s_user_id;
     response.sendRedirect(sRedirUrl);
     return;
}

%>
