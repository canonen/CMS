<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.util.*,
			org.w3c.dom.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);
boolean HYATTUSER = (ui.n_ui_type_id == UIType.HYATT_USER);

if(!can.bRead && !HYATTUSER)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sAttrId = request.getParameter("attr_id");
AttrCalcProps cap = new AttrCalcProps();

cap.s_cust_id = cust.s_cust_id;
cap.s_attr_id = sAttrId;

if( cap.retrieve() < 1) return;

// === === ===

String sResponse = Service.communicate(ServiceType.RRCP_ATTR_VALUES_UPDATE, cust.s_cust_id, cap.toXml());
XmlUtil.getRootElement(sResponse);

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<title>Updating Values</title>
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Custom Fields:</b> Updating</td>
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
						<p align="center"><b>Update is running.</b></p>
						<p align="center">
							(could be time-consuming operation
							<br>
							refresh field screen in several minutes to see updated results)
							<br>
							<br>
							<a href="#1" onClick="self.close()">Close</a>
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