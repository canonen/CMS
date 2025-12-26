<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
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

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<%
String[] sVisibleAttrs = request.getParameterValues("vis");
String[] sInvisibleAttrs = request.getParameterValues("invis");

CustAttr ca = null;

int l = ( sVisibleAttrs == null )?0:sVisibleAttrs.length;

for(int i = 0; i < l; i++)
{
	ca = new CustAttr(cust.s_cust_id, sVisibleAttrs[i]);
	ca.s_display_seq = String.valueOf(10*(i+1));
	ca.saveWithSync();
}

l = ( sInvisibleAttrs == null )?0:sInvisibleAttrs.length;

for(int i = 0; i < l; i++)
{
	ca = new CustAttr(cust.s_cust_id, sInvisibleAttrs[i]);
	ca.s_display_seq = null;
	ca.saveWithSync();
}

%>
<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Custom Fields:</b> Sequence Saved</td>
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
						<b>Saved</b>
						<BR><BR>
						<A href="cust_attr_list.jsp">Back to list</A>
						<BR><BR>
						<A href="cust_attr_seq.jsp">Back to edit</A>
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
