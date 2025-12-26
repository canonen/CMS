<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,java.net.*,java.io.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
if (logger == null) {
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if (!can.bWrite) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

logger.info("saving ws campaign impot");
String sCampId = BriteRequest.getParameter(request, "camp_id");
String sWsCampId = BriteRequest.getParameter(request, "ws_camp_id");
String sWsSealId = BriteRequest.getParameter(request, "ws_seal_id");
String sWsFileName = BriteRequest.getParameter(request, "ws_file_name");
String sWsUnsubFileName = BriteRequest.getParameter(request, "ws_unsub_file_name");

String sql = "";
sql = "UPDATE cxcs_ws_campaign " +
      "   SET ws_seal_id = '" + sWsSealId + "'" +
      "       ,list_file_name = '" + sWsFileName + "'" +
      "       ,clickseal_file_name = '" + sWsUnsubFileName + "'" +
      "       ,modify_date = getDate()" +
      "       ,status_id = 2" +
      "       ,error_msg = null" +
      " WHERE cust_id = " + cust.s_cust_id + " AND ws_camp_id = " + sWsCampId;
logger.info("sql=" + sql);
BriteUpdate.executeUpdate(sql);

%>
<HTML>
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>

<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>WS Campaign:</b> Saved</td>
	</tr>
</table>
<br>

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
			<table class=main cellspacing=1 cellpadding=2 width="650">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p>The WS campaign was saved.</p>
						<p align="center">
							<%
							String sHref = "wscamp_list.jsp?type_id=2";
							%>
							<a href="<%=sHref%>">Back to List</a>
						</p>
						<p align="center">
							<a href="wscamp_edit.jsp?ws_camp_id=<%=sWsCampId%>">Back to Edit</a>
						</p>
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

