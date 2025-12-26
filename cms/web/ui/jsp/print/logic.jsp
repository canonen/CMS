<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
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

String logicID = request.getParameter("id");
if (logicID == null) logicID = "";
%>
<html>
<head>
<title>Logic Element Edit</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
<script language="javascript" src="../../js/tab_script.js"></script>
</head>
<body>
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 border=0 style="width:100%; height:100%;">
	<tr height="22">
		<td class=EditTabOn id=tab2_Step1 width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Edit Logic</td>
		<td class=EditTabOff id=tab2_Step2 width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Edit SQL</td>
		<td class=EmptyTab valign=center nowrap align=middle width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr height="2">
		<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100% colspan=3>
			<table cellspacing="1" cellpadding="3" border="0" class="main layout" style="width:100%; height:100%;">
				<col>
				<tr>
					<td align="left" valign="top">
						<iframe src="../filter/filter_edit.jsp?usage_type_id=700&filter_id=<%= logicID %>" style="width:100%; height:100%;" frameborder="0" border="0" scroll="auto"></iframe>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block2_Step2 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=center width=100% colspan=3>
			<form name="FT">
			<table class="main" cellpadding="2" cellspacing="1" style="width:100%; height:100%;">
				<tr>
					<td width="100%" align="left" valign="middle">
						<textarea cols="40" rows="15" style="width:100%; height:100%;">
SELECT count(*)
FROM #recips r
WHERE r.last_purchase = 'Electronics'
						</textarea>
					</td>
				</tr>
			</table>
			</form>
		</td>
	</tr>
	</tbody>
</table>
</body>
</html>