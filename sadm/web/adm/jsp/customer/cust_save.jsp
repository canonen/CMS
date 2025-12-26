<%@ page

	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>

<%
Customer cust = new Customer();

cust.s_cust_id = BriteRequest.getParameter(request, "cust_id");
cust.s_cust_name = BriteRequest.getParameter(request, "cust_name");
cust.s_login_name = BriteRequest.getParameter(request, "login_name");
cust.s_status_id = BriteRequest.getParameter(request, "status_id");
cust.s_level_id = BriteRequest.getParameter(request, "level_id");
cust.s_max_bbacks = BriteRequest.getParameter(request, "max_bbacks");
cust.s_max_bback_days = BriteRequest.getParameter(request, "max_bback_days");
cust.s_max_consec_bbacks = BriteRequest.getParameter(request, "max_consec_bbacks");
cust.s_max_consec_bback_days = BriteRequest.getParameter(request, "max_consec_bback_days");
cust.s_descrip = BriteRequest.getParameter(request, "descrip");

cust.s_upd_rule_id = BriteRequest.getParameter(request, "upd_rule_id");

cust.s_parent_cust_id = BriteRequest.getParameter(request, "parent_cust_id");

cust.s_upd_hierarchy_id = BriteRequest.getParameter(request, "upd_hierarchy_id");
cust.s_unsub_hierarchy_id = BriteRequest.getParameter(request, "unsub_hierarchy_id");

cust.s_auto_report_flag = BriteRequest.getParameter(request, "auto_report_flag");

cust.s_pass_expire_interval = BriteRequest.getParameter(request, "pass_expire_interval");
cust.s_pass_notify_days = BriteRequest.getParameter(request, "pass_notify_days");
cust.s_cti_group_id = BriteRequest.getParameter(request, "cti_group_id");

cust.s_auto_report_frequency = BriteRequest.getParameter(request, "auto_report_frequency");
cust.s_auto_report_std_duration = BriteRequest.getParameter(request, "auto_report_std_duration");
cust.s_auto_report_auto_duration = BriteRequest.getParameter(request, "auto_report_auto_duration");
cust.s_max_domains_on_report = BriteRequest.getParameter(request, "max_domains_on_report");

cust.save();
%>

<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<SCRIPT>
		parent.location.href = "cust_edit_frame.jsp?cust_id=<%=cust.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
