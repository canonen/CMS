<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
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

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sFilterId = request.getParameter("filter_id");
if( sFilterId == null) return;

PreviewAttrs pas = new PreviewAttrs();
pas.s_filter_id = sFilterId;
if(pas.retrieve() < 1)
{
%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<title>Target Group: Preview</title>
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=95% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Target Group:</b> Preview</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=95% border=0>
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
						<b>Preview fields were not specified</b>
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
	return;
}

PreviewAttr pa = null;
String sAttrList = "";

for (Enumeration e = pas.elements() ; e.hasMoreElements() ;)
{
	pa = (PreviewAttr)e.nextElement();
	if(!"".equals(sAttrList)) sAttrList +=",";
	sAttrList += pa.s_attr_id;
}

RecipList rl = new RecipList();
rl.sAction = "TgtPreview";
rl.s_cust_id = cust.s_cust_id;
rl.s_filter_id = sFilterId;
rl.s_num_recips = "25";
rl.s_attr_list = sAttrList;

String sRequestXml = rl.toRecipRequestXml();
String sResponse = Service.communicate(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id, sRequestXml);
%>

<HTML>
<HEAD>
	<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<title>Target Group: Preview</title>
</HEAD>

<BODY>
<table width="95%" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Target Group:</b> Preview</td>
	</tr>
</table>
<br>

<table class="listTable" width="95%" cellpadding="2" cellspacing="0">
	<tr>
	<%
	CustAttr ca = null;
	Attribute a = null;
	for (Enumeration e = pas.elements() ; e.hasMoreElements() ;)
	{
		pa = (PreviewAttr)e.nextElement();
		ca = new CustAttr(cust.s_cust_id, pa.s_attr_id);
		%>
		<th><%=ca.s_display_name%></th>
		<%
	}			
	%>
	</tr>
	<%
	Element eRecipList = XmlUtil.getRootElement(sResponse);
	Element eRecipient = null;
	NodeList nl = XmlUtil.getChildrenByName(eRecipList, "recipient");
	int iLength = nl.getLength();

	String sClassAppend = "";

	for(int i = 0; i < iLength; i++)
	{
		if (i % 2 != 0)
		{
			sClassAppend = "_Alt";
		}
		else
		{
			sClassAppend = "";
		}
		%>
	<tr>
		<%
		eRecipient = (Element)nl.item(i);
		for (Enumeration e = pas.elements() ; e.hasMoreElements() ;)
		{
			pa = (PreviewAttr)e.nextElement();
			a = new Attribute(pa.s_attr_id);
			%>
		<td class="listItem_Data<%= sClassAppend %>"><%=XmlUtil.getChildCDataValue(eRecipient, a.s_attr_name)%></td>
			<%
		}
		%>
	</tr>
		<%
	}
	%>
</table>
<br><br>
</BODY>
</HTML>
