<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,
			java.net.*,
			java.io.*,
			java.text.DateFormat, 
			java.text.SimpleDateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../wvalidator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sCampId = request.getParameter("camp_id");
String sMode = request.getParameter("mode");
if (sMode == null) sMode = "send";
String sSampleId = request.getParameter("sample_id");
String sCategoryId = BriteRequest.getParameter(request, "category_id");
String sPvTestListIds = BriteRequest.getParameter(request, "pv_test_list_ids");

Campaign camp = new Campaign(sCampId);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<HEAD>
	<BASE target="_self">
	<%@ include file="../header.html"%>
	<link rel="stylesheet" href="../mini/default.css" TYPE="text/css">
</HEAD>
<BODY>
	
	<div id="wrapper">
	
		<ul id="tabnav">
				<li>
					<a class="" href="home.jsp?a=home">Hesap Özeti</a>
				</li>
				<li>
					<a class="active" href="campaigns.jsp?a=campaigns">Kampanyalar</a>
				</li>
				<li>
					<a class="" href="reports.jsp?a=reports">Raporlar</a>
				</li>
				<li>
					<a class="" href="help.jsp?a=help">Yardım</a>
				</li>
			</ul>
			<div style="clear:both"></div>
		<div id="container">
			
			
			<div id="main-container" style="padding:30px">
		
			<div style="margin-bottom:10px;font-size:13px;font-weight:bold">Lütfen bekleyin kampanyanız hazırlanıyor.</div>
			<img src="../mini/images/campstartloader.gif"/>

<FORM method="POST" name="confirmation_form" action="" style="display:inline;">
<INPUT type=hidden name="camp_id" value="<%= HtmlUtil.escape(camp.s_camp_id) %>">
<INPUT type=hidden name="sample_id" value="<%= HtmlUtil.escape(sSampleId) %>">
<INPUT type=hidden name="mode" value="<%= HtmlUtil.escape(sMode) %>">
<INPUT type=hidden name="type_id" value="<%= HtmlUtil.escape(camp.s_type_id) %>">
<% if(sCategoryId != null) { %>
	<INPUT TYPE="hidden" NAME="category_id" value="<%=sCategoryId%>">
<% } %>
<% if(sPvTestListIds != null) { %>
	<INPUT TYPE="hidden" NAME="pv_test_list_ids" value="<%=sPvTestListIds%>">
<% } %>
<INPUT type="hidden" name="approval_flag" value="0">
</FORM>				

</div>
</div>
</div>
<SCRIPT>

var nSubmitOnce = 0;

function doSend(parm)
{

	if(nSubmitOnce > 0) return;
	nSubmitOnce = 1;

	switch( parm )
	{
		case 0:
		{
			confirmation_form.action="../mini/wizard.jsp";
			confirmation_form.method = "get";
			break;
		}
		case 1:
		{
			confirmation_form.approval_flag.value="0";
			confirmation_form.action="bnet_camp_send.jsp?wizard_mode=true";
			break;
		}
		case 2:
		{
			confirmation_form.approval_flag.value="1";
			confirmation_form.action="bnet_camp_send.jsp?wizard_mode=true";
			break;
		}
	}

	confirmation_form.submit();
}
setTimeout("doSend(2)", 2000);

</SCRIPT>

</BODY>
</HTML>