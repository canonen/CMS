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

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

boolean HYATTADMIN = (ui.n_ui_type_id == UIType.HYATT_ADMIN);
JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();
String sAttrId = request.getParameter("attr_id");
String showValues = request.getParameter("show");
boolean bVals = true;
if (showValues == null) bVals = false;
if ("".equals(showValues)) bVals = false;

Attribute a = null;
CustAttr ca = null;
AttrCalcProps acp = null;

if( sAttrId == null)
{
	a = new Attribute();
	ca = new CustAttr();
	acp = new AttrCalcProps();
}
else
{
	a = new Attribute(sAttrId);
	ca = new CustAttr(cust.s_cust_id, sAttrId);
	if(ca.s_display_name == null)
	{
		ca = new CustAttr(a.s_cust_id,a.s_attr_id);
		ca.s_display_seq = "1";
		ca.s_sync_flag = null;
	}
	acp = new AttrCalcProps(cust.s_cust_id, sAttrId);	
}

if(a.s_type_id==null) a.s_type_id = String.valueOf(DataType.VARCHAR_255);
if(a.s_scope_id==null) a.s_scope_id = String.valueOf(AttrScope.PUBLIC);

 if(a.s_attr_id != null) { 
	jsonObject.put("attr_id", a.s_attr_id);
} 
if(can.bWrite || HYATTADMIN)
{
	
}
jsonObject.put("attr_name",(a.s_attr_id == null)?"":"disabled");
jsonObject.put("attr_name",(a.s_attr_name==null)?"":a.s_attr_name);
jsonObject.put("display_name",ca.s_display_name);
jsonObject.put("type_id",(a.s_attr_id == null)?"":"disabled");
jsonObject.put("type_id",DataType.toHtmlOptions(a.s_type_id));
jsonObject.put("descrip",((a.s_cust_id==null)||(cust.s_cust_id.equals(a.s_cust_id))?"":" disabled"));
jsonObject.put("descrip",(a.s_descrip==null)?"":a.s_descrip);
if(cust.m_Customers != null) {
   jsonObject.put("scope_id",(a.s_attr_id == null)?"":"disabled");
   jsonObject.put("scope_id",AttrScope.toHtmlOptions(a.s_scope_id));
}
jsonObject.put("value_qty",(a.s_value_qty==null)?"":"checked");
jsonObject.put("fingerprint_seq",(ca.s_fingerprint_seq==null)?"":"checked");
jsonObject.put("newsletter_flag",(ca.s_newsletter_flag!=null)?ca.s_newsletter_flag:"1");
jsonObject.put("ns1",(ca.s_newsletter_flag==null || "1".equals(ca.s_newsletter_flag))?"checked":"");
jsonObject.put("ns2",(ca.s_newsletter_flag!=null && "Y".equals(ca.s_newsletter_flag))?"checked":"");
jsonObject.put("sync_flag",(ca.s_sync_flag==null || ca.s_sync_flag.equals("0"))?"":"checked");
jsonObject.put("hist_flag",(ca.s_hist_flag==null || ca.s_hist_flag.equals("0"))?"":"checked");
if("0".equals(acp.s_filter_usage)){
	jsonObject.put("filter_usage","0");
}
if("1".equals(acp.s_filter_usage)){
	jsonObject.put("filter_usage","1");
}
if("2".equals(acp.s_filter_usage)){
	jsonObject.put("filter_usage","2");
}
if("-1".equals(acp.s_calc_values_flag)) { 
	jsonObject.put("calc_values_flag","-1");
} 
else {
	if("0".equals(acp.s_calc_values_flag)) {
		jsonObject.put("calc_values_flag","0");
	}
	if("1".equals(acp.s_calc_values_flag)) {
		jsonObject.put("calc_values_flag","1");
	}
	if("2".equals(acp.s_calc_values_flag)) {
		jsonObject.put("calc_values_flag","2");
	}
}
if("1".equals(acp.s_calc_values_flag)){
	jsonObject.put("distinct_values_qty",(acp.s_distinct_values_qty==null)?"---":acp.s_distinct_values_qty);
	jsonObject.put("s_last_calc_date",(acp.s_last_calc_date==null)?"---":acp.s_last_calc_date);
}
jsonArray.put(jsonObject);
out.print(jsonArray);
%>
