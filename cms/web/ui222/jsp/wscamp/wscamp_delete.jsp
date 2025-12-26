<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.wfl.WorkflowUtil,
			java.util.*,java.sql.*,java.net.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sSelectedCategoryId = request.getParameter("category_id");

String finalMsg = "The ws campaign and the linked campaign were deleted.";
logger.info("delete camp and ws_camp");
Campaign camp = null;
try	{
	String sql = "";
	String sWsCampId = request.getParameter("ws_camp_id");
	logger.info("delete ws_camp_id = " + sWsCampId);
	if (sWsCampId != null && sWsCampId.length() > 0) {
		sql =
			"DELETE FROM cxcs_ws_campaign" +
			" WHERE cust_id = " + cust.s_cust_id +
			"   AND ws_camp_id = " + sWsCampId;
		BriteUpdate.executeUpdate(sql);
	}
	String sCampId = request.getParameter("camp_id");
	logger.info("delete camp_id = " + sCampId);
	if (sCampId != null && sCampId.length() > 0) {
		camp = new Campaign(sCampId);
        if (camp.s_cust_id.equalsIgnoreCase(cust.s_cust_id)) {
            camp.s_status_id = String.valueOf(CampaignStatus.DELETED);
            camp.save();
     	}
	}
}
catch(Exception ex) { throw ex; }
%>
<HTML>
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<table width=95% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>WS Campaign</b></td>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b><%= finalMsg %></b>
						<br><br>
						<p align="center">
							<a href="wscamp_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">
								Back to List
							</a>
						</p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>