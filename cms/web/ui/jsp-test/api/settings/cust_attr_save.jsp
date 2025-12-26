<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			org.apache.log4j.*"
	errorPage="../../utilities/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../utilities/header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
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
JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();

String sAttrId = request.getParameter("attr_id");

// === === ===
try{
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

jsonObject.put("s_attr_id",ca.s_attr_id);
jsonObject.put("display_name",ca.s_display_name);
jsonObject.put("s_sync_flag",ca.s_sync_flag);
jsonObject.put("s_hist_flag",ca.s_hist_flag);
jsonObject.put("s_newsletter_flag",ca.s_newsletter_flag);
jsonArray.put(jsonObject);
out.print(jsonArray);
}
catch(Exception exception){
	ErrLog.put(this, exception, "Problem sending Info to Recipient database.\r\n");
}
%>

