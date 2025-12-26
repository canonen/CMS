<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
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

AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);

boolean HYATTADMIN = (ui.n_ui_type_id == UIType.HYATT_ADMIN);

if(!can.bWrite && !HYATTADMIN)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sAttrId = request.getParameter("attr_id");

// === === ===

Attribute a = null;
if(sAttrId==null)
{
	a = new Attribute();
	a.s_cust_id = cust.s_cust_id;
	a.s_attr_name = BriteRequest.getParameter(request,"attr_name");
	a.s_type_id =  BriteRequest.getParameter(request,"type_id");
	a.s_scope_id = BriteRequest.getParameter(request,"scope_id");
	a.s_value_qty = BriteRequest.getParameter(request,"value_qty");
	if(a.s_value_qty!=null) a.s_value_qty = "2";
	a.s_descrip = request.getParameter("descrip");
}
else
{
	a = new Attribute(sAttrId);
	if(a.s_cust_id.equals(cust.s_cust_id))
		a.s_descrip = request.getParameter("descrip");
}

if(a.s_type_id==null) a.s_type_id = String.valueOf(DataType.VARCHAR_255);
if(a.s_scope_id==null) a.s_scope_id = String.valueOf(AttrScope.PUBLIC);

// === === ===

CustAttr ca = new CustAttr();
ca.s_attr_id = sAttrId;
ca.s_cust_id = cust.s_cust_id;

if((sAttrId==null)||(ca.retrieve()<1))
{
	ca.s_display_seq = "1";
	ca.s_fingerprint_seq = null;
}

ca.s_display_name =BriteRequest.getParameter(request, "display_name");
ca.s_sync_flag = BriteRequest.getParameter(request, "sync_flag");
ca.s_hist_flag = BriteRequest.getParameter(request, "hist_flag");
ca.s_newsletter_flag = BriteRequest.getParameter(request, "newsletter_flag");

// === === ===

ca.m_Attribute = a;
ca.saveWithSync();

// === === ===

AttrCalcProps acp = new AttrCalcProps(ca.s_cust_id, ca.s_attr_id);
if(!"-1".equals(acp.s_calc_values_flag))
{
	acp.s_calc_values_flag = BriteRequest.getParameter(request,"calc_values_flag");
	acp.s_filter_usage = BriteRequest.getParameter(request,"filter_usage");
	acp.save();	
}

String showValues = request.getParameter("show");
boolean bVals = true;
if (showValues == null) bVals = false;
if ("".equals(showValues)) bVals = false;

if (bVals) response.sendRedirect("cust_attr_edit.jsp?show=values&attr_id=" + ca.s_attr_id);
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=500 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Custom Field:</b> Saved</th>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=center width=500>
			<table cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p><b>The custom field was saved.</b></p>
						<p><A href="cust_attr_list.jsp">Back to list</A></p>
						<p><A href= "cust_attr_edit.jsp?attr_id=<%=ca.s_attr_id%>">Back to edit</A></p>
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
