<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,
			java.util.*,java.net.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
String sFilterName = BriteRequest.getParameter(request, "filter_name");

// === === ===

RecipList rl = new RecipList();

rl.sAction = BriteRequest.getParameter(request, "action");

// rl.sQuery = BriteRequest.getParameter(request, "query");

rl.s_cust_id = cust.s_cust_id; //BriteRequest.getParameter(request, "cust_id");

// rl.s_recip_id = BriteRequest.getParameter(request, "recip_id");

rl.s_camp_id = BriteRequest.getParameter(request, "camp_id");
rl.s_link_id = BriteRequest.getParameter(request, "link_id");
rl.s_content_type = BriteRequest.getParameter(request, "content_type");
rl.s_form_id = BriteRequest.getParameter(request, "form_id");
rl.s_bback_category = BriteRequest.getParameter(request, "bback_category");
rl.s_domain = BriteRequest.getParameter(request, "domain");
rl.s_newsletter_id = BriteRequest.getParameter(request, "newsletter_id");

//rl.s_filter_id = BriteRequest.getParameter(request, "filter_id");
//rl.s_batch_id = BriteRequest.getParameter(request, "batch_id");

rl.s_cache_id = BriteRequest.getParameter(request, "cache_id");

rl.s_cache_start_date = BriteRequest.getParameter(request, "start_date");
rl.s_cache_end_date = BriteRequest.getParameter(request, "end_date");
rl.s_cache_attr_id = BriteRequest.getParameter(request, "attr_id");
rl.s_cache_attr_value1 = BriteRequest.getParameter(request, "attr_value1");
rl.s_cache_attr_value2 = BriteRequest.getParameter(request, "attr_value2");
rl.s_cache_attr_operator = BriteRequest.getParameter(request, "attr_operator");
rl.s_cache_user_id = BriteRequest.getParameter(request, "user_id");

// rl.s_pnmfamily = BriteRequest.getParameter(request, "s_pnmfamily");
// rl.s_email_821 = BriteRequest.getParameter(request, "email_821");
// rl.s_num_recips = BriteRequest.getParameter(request, "num_recips");

rl.s_attr_list = BriteRequest.getParameter(request, "attr_list");
//rl.s_delimiter = BriteRequest.getParameter(request, "delimiter");
	
// rl.n_total_recips = BriteRequest.getParameter(request, "total_recips");
// rl.n_total_returned = BriteRequest.getParameter(request, "total_returned");

logger.info(rl.toRecipRequestXml());
// === === ===

com.britemoon.cps.tgt.Filter f = rl.createFilter(sFilterName);

CategortiesControl.saveCategories(f.s_cust_id, ObjectType.FILTER, f.s_filter_id, request);

%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<%@ include file="../header.html" %>
<script>

function gotoParent(url)
{
	if( opener != null )
	{
		opener.top.parent.location.href = url;
		self.close();
	}
	else
	{
		top.parent.location.href = url;
	}
}

</script>
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Target Group:</b> Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p><b>Saved</b></p>
						<A href="javascript:gotoParent('../index.jsp?tab=Data&sec=2');">Go to target group list</A>
						<BR><BR>
						<A href="javascript:gotoParent('../index.jsp?tab=Data&sec=2&url=<%= URLEncoder.encode("filter/filter_edit.jsp?filter_id=" + f.s_filter_id, "UTF-8") %>');">Edit New Target Group</A>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>
