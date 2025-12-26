<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;  %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

//KU: Added for content logic ui
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
}
else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Report Filter";
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}
	
%>
<%
	int nParamId = 0;

	String sFilterId = BriteRequest.getParameter(request, "filter_id");
	String sFilterName = BriteRequest.getParameter(request, "filter_name");
	String sTypeId = BriteRequest.getParameter(request, "type_id");

	String sMainCountCompareOperation = BriteRequest.getParameter(request, "main_count_compare_operation");
	String sMainCount = BriteRequest.getParameter(request, "main_count");
	
	// for filter of type 23 CAMP_SENT_WITHIN_TIME_INTERVAL	
	String sCampId = BriteRequest.getParameter(request, "camp_id");

	String sMode = BriteRequest.getParameter(request, "mode");
	
	String sStartDate = BriteRequest.getParameter(request, "start_date");
	if(sStartDate!=null) sStartDate = sStartDate.toUpperCase();
	
	String sFinishDate = BriteRequest.getParameter(request, "finish_date");
	if(sFinishDate!=null) sFinishDate = sFinishDate.toUpperCase();
	
	String sDiffDate = BriteRequest.getParameter(request, "diff_date");
	if(sDiffDate!=null) sDiffDate = sDiffDate.toUpperCase();
	
	String sDayCountCompareOperation = BriteRequest.getParameter(request, "day_count_compare_operation");
	String sDayCount = BriteRequest.getParameter(request, "day_count");

	String sStartFinishAttrId = BriteRequest.getParameter(request, "start_finish_attr_id");
	String sDiffDateAttrId = BriteRequest.getParameter(request, "diff_date_attr_id");
	
	String sFormId = BriteRequest.getParameter(request, "form_id");

	// === === ===
	
	//com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter(sFilterId);
	com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter();
	filter.s_filter_name = sFilterName;
	if(filter.s_cust_id == null) filter.s_cust_id = cust.s_cust_id;
	if(filter.s_status_id == null) filter.s_status_id = "10";
	filter.s_type_id = sTypeId;

	FilterParams fps = new FilterParams();

	// === === ===
	
	FilterParam fp = null;

	if(sFormId != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "form_id";
		fp.s_string_value = sFormId;
		fp.s_integer_value = sFormId;
		fps.add(fp);
	}
	
	if(sMainCountCompareOperation != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "main_count_compare_operation";
		fp.s_string_value = sMainCountCompareOperation;	
		fps.add(fp);
	}
	

	if(sMainCount != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "main_count";
		fp.s_string_value = sMainCount;	
		fp.s_integer_value = sMainCount;
		fps.add(fp);
	}

	// for filter of type 23 CAMP_SENT_WITHIN_TIME_INTERVAL
	if(sCampId != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "camp_id";
		fp.s_string_value = sCampId;
		fp.s_integer_value = sCampId;
		fps.add(fp);
	}

	if(sMode != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "mode";
		fp.s_string_value = sMode;
		fps.add(fp);
	}

	if("date_diff".equals(sMode))
	{
		if(sDayCountCompareOperation != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "day_count_compare_operation";
			fp.s_string_value = sDayCountCompareOperation;	
			fps.add(fp);
		}

		if(sDayCount != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "day_count";
			fp.s_string_value = sDayCount;	
			fp.s_integer_value = sDayCount;
			fps.add(fp);
		}

		if(sDiffDate != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "diff_date";
			fp.s_string_value = sDiffDate;	
			if(!"TODAY".equals(sDiffDate)) fp.s_date_value = sDiffDate;
			fps.add(fp);
		}

		// for type_id = 21
		if(sDiffDateAttrId != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "diff_date_attr_id";
			fp.s_string_value = sDiffDateAttrId;
			fp.s_integer_value = sDiffDateAttrId;
			fps.add(fp);
		}
		
	}
	else if("start_finish".equals(sMode))
	{
		if(sStartDate != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "start_date";
			fp.s_string_value = sStartDate;	
			if(!"TODAY".equals(sStartDate)) fp.s_date_value = sStartDate;
			fps.add(fp);
		}

		if(sFinishDate != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "finish_date";
			fp.s_string_value = sFinishDate;
			if(!"TODAY".equals(sFinishDate)) fp.s_date_value = sFinishDate;
			fps.add(fp);
		}

		// for type_id = 21
		if(sStartFinishAttrId != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "start_finish_attr_id";
			fp.s_string_value = sStartFinishAttrId;
			fp.s_integer_value = sStartFinishAttrId;
			fps.add(fp);
		}
	}
	else if(sMode == null)
	{
		if(sStartDate != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "start_date";
			fp.s_string_value = sStartDate;	
			if(!"TODAY".equals(sStartDate)) fp.s_date_value = sStartDate;
			fps.add(fp);
		}

		if(sFinishDate != null)
		{
			fp = new FilterParam();
			fp.s_param_id = String.valueOf(++nParamId);
			fp.s_param_name = "finish_date";
			fp.s_string_value = sFinishDate;
			if(!"TODAY".equals(sFinishDate)) fp.s_date_value = sFinishDate;
			fps.add(fp);
		}
	}
	else
	{
		throw new Exception("Unknown filter mode");
	}

	// === === ===
	
	filter.m_FilterParams = fps;
	filter.s_filter_id = null;
	filter.save();
%>
<HTML>
<HEAD>
<title><%= sTargetGroupDisplay %> Edit</title>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<DIV style="display: none">
<%@ include file="prototype_filter.inc"%>
</DIV>
<script>
	if( opener != null )
	{
	<%
	String sMsg = null;
	if(sFilterId==null)
	{
		sMsg = "Target group element was created and saved.";
		%>
		opener.filter_part_add_filter(filter_prototype);
		<%
	}
	else
	{
		sMsg = "Target group element was updated and saved.";
		%>
		opener.filter_part_replace_filter(filter_prototype);
		<%
	}
	%>
	}
	//self.close();
	location.href = '../select/select.jsp?saved=true&usage_type_id=<%= sUsageTypeId %>';
</script>
<!--- Step 1 Header----->
<table width=100% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader><%= sTargetGroupDisplay %>:</b> Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p><b><%=sMsg%></b></p>
						<p><a href="../select/select.jsp">Add Another <%= sTargetGroupDisplay %> Criteria</a></p>
						<p><a href="javascript:self.close();">Close Window &amp; Return to <%= sTargetGroupDisplay %> Edit</a></P>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
</BODY>
</HTML>
