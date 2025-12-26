<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,java.net.*,
			java.io.*,java.text.DateFormat,
			org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
CampSampleset cs = new CampSampleset();

cs.s_camp_id = BriteRequest.getParameter(request, "camp_id");
cs.s_camp_qty = BriteRequest.getParameter(request, "camp_qty");
cs.s_from_name_flag = BriteRequest.getParameter(request, "from_name_flag");
cs.s_from_address_flag = BriteRequest.getParameter(request, "from_address_flag");
cs.s_subject_flag = BriteRequest.getParameter(request, "subject_flag");
cs.s_cont_flag = BriteRequest.getParameter(request, "cont_flag");
cs.s_send_date_flag = BriteRequest.getParameter(request, "send_date_flag");
cs.s_final_camp_flag = BriteRequest.getParameter(request, "final_camp_flag");
cs.s_recip_qty = BriteRequest.getParameter(request, "recip_qty");
cs.s_recip_percentage = BriteRequest.getParameter(request, "recip_percentage");
cs.s_reply_to_flag = BriteRequest.getParameter(request, "reply_to_flag");
cs.s_filter_flag = BriteRequest.getParameter(request, "filter_flag");
cs.save();

// === === ===

response.sendRedirect("camp_edit_with_samples.jsp?camp_id=" + cs.s_camp_id);
%>