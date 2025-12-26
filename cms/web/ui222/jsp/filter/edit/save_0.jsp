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
	String sOldFilterId = BriteRequest.getParameter(request, "old_filter_id");
	String sNewFilterId = BriteRequest.getParameter(request, "new_filter_id");
	com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter(sNewFilterId);
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
	if(sOldFilterId==null)
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

