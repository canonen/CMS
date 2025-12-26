<%@ page

	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,
			java.util.*,java.sql.*,
			java.net.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>

<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

Customer c = new Customer(cust.s_cust_id);
c.s_max_bbacks = BriteRequest.getParameter(request,"max_bbacks");
c.s_max_bback_days = BriteRequest.getParameter(request,"max_bback_days");
c.s_max_consec_bbacks = BriteRequest.getParameter(request,"max_consec_bbacks");
c.s_max_consec_bback_days = BriteRequest.getParameter(request,"max_consec_bback_days");

c.save();

String [] sHardBBacks = BriteRequest.getParameterValues(request,"bback_category_id");
BriteUpdate.executeUpdate("DELETE ccps_cust_hard_bback WHERE cust_id = "+cust.s_cust_id);

if (sHardBBacks != null) {
	for (int i=0; i<sHardBBacks.length; i++) {
		if (sHardBBacks[i] != null) {
			String sSql = "INSERT ccps_cust_hard_bback (cust_id, bback_category_id)"
				+ " VALUES ("+cust.s_cust_id+", "+sHardBBacks[i]+")";
			BriteUpdate.executeUpdate(sSql);
		}
	}
}

String sXml = "<cust_bback_settings>\r\n";
sXml += c.toXml();
sXml += "\r\n<cust_hard_bbacks>\r\n";
if (sHardBBacks != null) {
	for (int i=0; i<sHardBBacks.length; i++) {
		if (sHardBBacks[i] != null)
			sXml += "<cust_hard_bback><bback_category_id>"+sHardBBacks[i]+"</bback_category_id></cust_hard_bback>\r\n";
	}
}
sXml += "</cust_hard_bbacks>\r\n";
sXml += "</cust_bback_settings>";

String sResponse = Service.communicate(ServiceType.SADM_CUST_BBACK_SETUP, cust.s_cust_id, sXml);
Element eResponse = XmlUtil.getRootElement(sResponse);
				
sResponse = Service.communicate(ServiceType.RRCP_CUST_BBACK_SETUP, cust.s_cust_id, sXml);
eResponse = XmlUtil.getRootElement(sResponse);

%>
<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Bounceback Settings:</b> Saved</td>
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
						<p><b>The bounceback settings were saved.</b></p>
						<p>Note: any changes to these settings will only affect future campaigns.</p>
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
<%


%>
