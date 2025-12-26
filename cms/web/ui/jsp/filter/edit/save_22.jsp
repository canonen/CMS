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
<%! static Logger logger = null; %>
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

	String sAggregateFunction = BriteRequest.getParameter(request, "aggregate_function");
	String sAggregateAttrId = BriteRequest.getParameter(request, "aggregate_attr_id");

	String sCompareOperation = BriteRequest.getParameter(request, "compare_operation");
	String sCompareValue = BriteRequest.getParameter(request, "compare_value");

	String sStartDate = BriteRequest.getParameter(request, "start_date");
	if(sStartDate!=null) sStartDate = sStartDate.toUpperCase();
	
	String sFinishDate = BriteRequest.getParameter(request, "finish_date");
	if(sFinishDate!=null) sFinishDate = sFinishDate.toUpperCase();
	
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

	if(sAggregateFunction != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "aggregate_function";
		fp.s_string_value = sAggregateFunction;
		fps.add(fp);
	}

	if(sAggregateAttrId != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "aggregate_attr_id";
		fp.s_string_value = sAggregateAttrId;
		fp.s_integer_value = sAggregateAttrId;
		fps.add(fp);
	}

	if(sCompareOperation != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "compare_operation";
		fp.s_string_value = sCompareOperation;	
		fps.add(fp);
	}

	if(sCompareValue != null)
	{
		fp = new FilterParam();
		fp.s_param_id = String.valueOf(++nParamId);
		fp.s_param_name = "compare_value";
		fp.s_string_value = sCompareValue;	
		fp.s_integer_value = sCompareValue;
		fps.add(fp);
	}


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
		sMsg = sTargetGroupDisplay + " element was created and saved.";
		%>
		opener.filter_part_add_filter(filter_prototype);
		<%
	}
	else
	{
		sMsg = sTargetGroupDisplay + " element was updated and saved.";
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
