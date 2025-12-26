<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.util.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
String sSelectedCategoryId = request.getParameter("category_id");
String referer = request.getParameter("referer");
try
{
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String sFilterId = request.getParameter("filter_id");
	FilterUtil.sendFilterUpdateRequestToRcp(sFilterId);
}
catch(Exception ex)
{ 
	// Probably this is CPS - RCP communication problem
	// Do not bother customer by throwing exception
	logger.error("Exception: ",ex);
}
%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		<%if(referer==null){%>
		self.location.href = "filter_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>";
		<%}else{
			
			Service service = null;
			Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
			service = (Service) services.get(0); 
		%> 
			self.location.href = "http://<%=service.getURL().getHost()%>/rrcp/imc/webpush/segment_list.jsp?cust_id=<%=cust.s_cust_id%>";
			//self.location.href = "http://localhost/rrcp/imc/webpush/segment_list.jsp?cust_id=<%=cust.s_cust_id%>";
		<%}%>
	 
	</SCRIPT>
</HEAD>

<BODY>
</BODY>

</HTML>

