<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.util.*,
			org.w3c.dom.*,org.apache.log4j.*"
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
boolean HYATTUSER = (ui.n_ui_type_id == UIType.HYATT_USER);

if(!can.bRead && !HYATTUSER)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();
String sAttrId = request.getParameter("attr_id");
AttrCalcProps cap = new AttrCalcProps();

cap.s_cust_id = cust.s_cust_id;
cap.s_attr_id = sAttrId;

if( cap.retrieve() < 1) return;

// === === ===

String sResponse = Service.communicate(ServiceType.RRCP_ATTR_VALUES_UPDATE, cust.s_cust_id, cap.toXml());
XmlUtil.getRootElement(sResponse);
jsonObject.put("message","Update is running");
jsonArray.put(jsonObject);
out.print(jsonArray);
%>