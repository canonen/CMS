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
<%! static Logger logger = null;%>
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
	String sFilterId = BriteRequest.getParameter(request, "filter_id");
	String sFilterName = BriteRequest.getParameter(request, "filter_name");
	String sTypeId = BriteRequest.getParameter(request, "type_id");

	String[] sParamNames = BriteRequest.getParameterValues(request, "param_name");
	String[] sIntegerValues = BriteRequest.getParameterValues(request, "integer_value");
	String[] sStringValues = BriteRequest.getParameterValues(request, "string_value");
	String[] sDateValues = BriteRequest.getParameterValues(request, "date_value");

//	com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter(sFilterId);
	com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter();
	filter.s_filter_name = sFilterName;
	filter.s_cust_id = cust.s_cust_id;
	filter.s_filter_name = sFilterName;
	if(filter.s_status_id == null) filter.s_status_id = "10";
	filter.s_type_id = sTypeId;

	FilterParams fps = new FilterParams();

	int l = (sParamNames==null)?0:sParamNames.length;

	for(int i = 0; i<l; i++)
	{
		FilterParam fp = new FilterParam();
		fp.s_param_id = String.valueOf(i);
		fp.s_param_name = sParamNames[i];
		fp.s_integer_value = sIntegerValues[i];
		fp.s_string_value = sStringValues[i];
		fp.s_date_value = sDateValues[i];
		fps.add(fp);
	}

	filter.m_FilterParams = fps;

	filter.s_filter_id = null;
	filter.save();
%>
<HTML>
<title><%= sTargetGroupDisplay %> Edit</title>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<DIV style="display: none">
<%@ include file="prototype_filter_zaf.inc"%>
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
