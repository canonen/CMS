<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,
			java.util.*,java.sql.*,
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

boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);

String sSelectedCategoryId = request.getParameter("category_id");
%>

<%
String sAction = BriteRequest.getParameter(request, "save_type");

String sFilterId = BriteRequest.getParameter(request, "filter_id");
String sFilterName = BriteRequest.getParameter(request, "filter_name");
String sFilterXml = BriteRequest.getParameter(request, "filter_xml");
if(sFilterXml== null) throw new Exception("No filter xml found");

// KO: Added for content filter support
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");
String sLogicId = BriteRequest.getParameter(request, "logic_id");
String sParentContId = BriteRequest.getParameter(request, "parent_cont_id");

if ( sUsageTypeId == null ) sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);

// === === ===

Element eFilter = XmlUtil.getRootElement(sFilterXml);
com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(eFilter);

// === === ===

f.s_filter_id = sFilterId;
f.s_filter_name = sFilterName;
f.s_cust_id = cust.s_cust_id;
f.s_type_id = String.valueOf(FilterType.MULTIPART);
f.s_status_id = String.valueOf(FilterStatus.NEW);
f.s_usage_type_id = sUsageTypeId;

if (bWorkflow && can.bApprove) {
     f.s_aprvl_status_flag = "1";
} else if (bWorkflow && !can.bApprove) {
     f.s_aprvl_status_flag = "0";
}


if( "clone".equals(sAction) || "clone2destination".equals(sAction) ) setFilterIdsToNull(f);
if( "clone2destination".equals(sAction) ) f.s_cust_id = ui.getDestinationCustomer().s_cust_id;

f.save();

// === === ===

FilterStatistic fs = new FilterStatistic();
fs.s_filter_id = f.s_filter_id;
fs.delete();

// === === ===

FilterEditInfo fei = new FilterEditInfo();
fei.s_filter_id = f.s_filter_id;
fei.s_modifier_id = user.s_user_id;
fei.save();

// === === ===

if(!"clone2destination".equals(sAction))
	CategortiesControl.saveCategories(f.s_cust_id, ObjectType.FILTER, f.s_filter_id, request);

// === === ===

boolean bIsLogic = String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId);
boolean bIsReport = String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId); 
String sTargetGroupDisplay = "Target Group";
if (bIsLogic) sTargetGroupDisplay = "Logic Element";
if (bIsReport) sTargetGroupDisplay = "Report Filter";

if("save_and_update".equals(sAction))
{
	try { FilterUtil.sendFilterUpdateRequestToRcp(f.s_filter_id); }
	catch (Exception ex) { logger.error("Exception: ",ex); }
}

if ("save_and_request_approval".equals(sAction)) {
     String sRedirUrl = "../workflow/approval_request_edit.jsp?object_type=" + ObjectType.FILTER + "&object_id=" + f.s_filter_id;
     response.sendRedirect(sRedirUrl);
}

%>

<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<%@ include file="../header.html" %>
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader><%= sTargetGroupDisplay %>:</b> Saved</td>
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
<!-- === === === -->
<p><b>Saved</b></p>
<%
	if ( (sLogicId == null) && (sParentContId == null) && (bIsReport) )
	{
%>
	<p><A href="../report/filter_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to list</A></p>
	<p><A href="filter_edit.jsp?filter_id=<%=f.s_filter_id%><%=(sUsageTypeId!=null)?"&usage_type_id="+sUsageTypeId:""%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Back to edit</A></p>
<%
	}
	else if ( (sLogicId == null) && (sParentContId == null) && (!bIsLogic) )
	{
%>
	<p><A href="filter_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to list</A></p>
	<p><A href="filter_edit.jsp?filter_id=<%=f.s_filter_id%><%=(sUsageTypeId!=null)?"&usage_type_id="+sUsageTypeId:""%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Back to edit</A></p>
<%
	}
	else
	{
%> 	
	<p><a href="../cont/filter_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a></p>
	<p><A href="filter_edit.jsp?filter_id=<%=f.s_filter_id%><%=(sUsageTypeId!=null)?"&usage_type_id="+sUsageTypeId:""%><%=(sLogicId!=null)?"&logic_id="+sLogicId:""%><%=(sParentContId!=null)?"&parent_cont_id="+sParentContId:""%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Back to Logic Element</A></p>
<%
		if (sLogicId != null)
		{
%>
	<p><a href="../cont/logic_block_edit.jsp?logic_id=<%= sLogicId %><%=(sParentContId!=null)?"&parent_cont_id="+sParentContId:""%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Back to Logic Block</a></p>
<%
		}
		if (sParentContId != null)
		{
%>
		<p><a href="../cont/cont_edit.jsp?cont_id=<%= sParentContId %><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Back to Content</a></p>
<%
		}
	}
%>
<!-- === === === -->						
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

<%!
private static void setFilterIdsToNull(com.britemoon.cps.tgt.Filter f)
{
	if(f == null) return;

	int nTypeId = -1;
	try { nTypeId = Integer.parseInt(f.s_type_id); }
	catch(Exception ex) { return; }

	f.s_filter_id = null;
		
	if(nTypeId == FilterType.FORMULA)
	{
		if(f.m_Formula != null) f.m_Formula.s_filter_id = null;
		return;
	}

	if(nTypeId == FilterType.MULTIPART)
	{	
		FilterParts fps = f.m_FilterParts;
		if(fps == null) return;
		
		FilterPart fp = null;
		for (Enumeration e = fps.elements() ; e.hasMoreElements() ;)
		{
			fp = (FilterPart)e.nextElement();
			setFilterIdsToNull(fp.m_ChildFilter);
		}
		return;
	}
}
%>