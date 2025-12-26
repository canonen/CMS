<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.io.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
String	sCampID	= request.getParameter("id");
if ( (sCampID == null) || (sCampID.equals("")) ) throw new Exception ("Campaign ID required");

// === === ===

StringTokenizer st = new StringTokenizer(sCampID,",");

StringWriter swXML = new StringWriter();
swXML.write("<camp_reports>\r\n");
while (st.hasMoreTokens())
{
	swXML.write("<camp_report>\r\n");
	swXML.write("<camp_id>"+st.nextToken()+"</camp_id>\r\n");
	swXML.write("<cust_id>"+cust.s_cust_id+"</cust_id>\r\n");
	swXML.write("</camp_report>\r\n");
}
swXML.write("</camp_reports>\r\n");

String sMsg =
	Service.communicate(ServiceType.RRPT_CAMPAIGN_REPORT_QUEUE, cust.s_cust_id, swXML.toString());

// === === ===

StringTokenizer st2 = new StringTokenizer(sCampID,",");
while (st2.hasMoreTokens())
{
	String sSql =
		" EXEC usp_crpt_camp_report_update" +
		"  @camp_id = " + st2.nextToken() +
		", @cust_id = " + cust.s_cust_id +
		", @status_id = " + ReportStatus.QUEUED;

	BriteUpdate.executeUpdate(sSql);
}
%>
<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Campaign:</b> Report Scheduled</td>
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
						<b>The campaign report has been scheduled.</b>
						<P align="center"><a href="report_list.jsp">Back to List</a>
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
