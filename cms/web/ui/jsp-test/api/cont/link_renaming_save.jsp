<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.io.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
	JsonObject data= new JsonObject();
	JsonArray array= new JsonArray();
if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
int numLinks		= Integer.parseInt(request.getParameter("num_links"));
LinkRenaming link	= null;
int count			= 0;

for (int i = 1; i <= numLinks; i++)
{
	count++;
	
	link = new LinkRenaming();

	link.s_link_id = BriteRequest.getParameter(request, "link_id"+i);
	link.s_cust_id = cust.s_cust_id;
	link.s_link_name = BriteRequest.getParameter(request, "link_name"+i);
	link.s_link_type_id = BriteRequest.getParameter(request, "link_type_id"+i);
	link.s_link_definition = BriteRequest.getParameter(request, "link_definition"+i);
	
	link.save();
}

// === === ===

%>


