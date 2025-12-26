<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, com.britemoon.sas.adm.*, java.io.*,java.sql.*,java.util.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
String sAttrId = BriteRequest.getParameter(request, "attr_id");

// === === ===

Attribute a = null;

if(sAttrId==null)
{
	a = new Attribute();
	a.s_cust_id = sCustId;
	a.s_attr_name = BriteRequest.getParameter(request,"attr_name");
	a.s_type_id =  BriteRequest.getParameter(request,"type_id");
	a.s_scope_id = BriteRequest.getParameter(request,"scope_id");
	a.s_value_qty = BriteRequest.getParameter(request,"value_qty");
	if(a.s_value_qty!=null) a.s_value_qty = "2";
	a.s_descrip = BriteRequest.getParameter(request,"descrip");
}
else
{
	a = new Attribute(sAttrId);
	if(a.s_cust_id.equals(sCustId))
		a.s_descrip = BriteRequest.getParameter(request,"descrip");
}

a.s_internal_flag = BriteRequest.getParameter(request, "internal_flag");

// === === ===

CustAttr ca = new CustAttr();
ca.s_attr_id = sAttrId;
ca.s_cust_id = sCustId;

if((sAttrId==null)||(ca.retrieve()<1))
{
	ca.s_display_seq = "1";
	ca.s_fingerprint_seq = null;
}

ca.s_display_name = BriteRequest.getParameter(request, "display_name");
ca.s_display_seq = BriteRequest.getParameter(request, "display_seq");
ca.s_sync_flag = BriteRequest.getParameter(request, "sync_flag");
ca.s_hist_flag = BriteRequest.getParameter(request, "hist_flag");

if(a.s_internal_flag!=null) ca.s_display_seq = null;

// === === ===

ca.m_Attribute = a;
ca.save();

// === === ===
/*
AttrCalcProps acp = new AttrCalcProps(ca.s_cust_id, ca.s_attr_id);
if(!"-1".equals(acp.s_calc_values_flag))
{
	acp.s_calc_values_flag = BriteRequest.getParameter(request,"calc_values_flag");
	acp.save();	
}
*/
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		parent.location.href = "cust_attr_frame.jsp?cust_id=<%=ca.s_cust_id%>&attr_id=<%=ca.s_attr_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
