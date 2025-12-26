<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../utilities/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../utilities/header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
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

String sAttrId = request.getParameter("attr_id");
String sSort = request.getParameter("sort");

if( sAttrId == null) return;

Attribute a = new Attribute(sAttrId);
CustAttr ca = new CustAttr(cust.s_cust_id, sAttrId);
JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();

jsonObject.put("display_name", ca.s_display_name);
jsonObject.put("attr_name", a.s_attr_name);
jsonObject.put("attr_id",ca.s_attr_id);

ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
String sSQL = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	sSQL =
		" SELECT attr_value, value_qty" +
		" FROM ccps_attr_value" +
		" WHERE cust_id=" + ca.s_cust_id +
		" AND attr_id=" + ca.s_attr_id;

	if("count".equals(sSort)) sSQL += " ORDER BY value_qty DESC";
	else sSQL += " ORDER BY attr_value";

	rs = stmt.executeQuery(sSQL);

	String sAttrValue = null;
	String sValueQty = null;

	byte[] b = null;
	JsonObject jsonClassAppend = new JsonObject();
	JsonArray  arrayClassAppend = new JsonArray();
	String sClassAppend = "";
	
	for(int i = 0; rs.next(); i++)
	{
		if (i % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";
		
		b = rs.getBytes(1);
		sAttrValue = (b==null)?null:new String(b, "UTF-8");
		sValueQty = rs.getString(2);
		jsonClassAppend.put("b", b);
		jsonClassAppend.put("sAttrValue", sAttrValue);
		jsonClassAppend.put("sValueQty", sValueQty);
		arrayClassAppend.put(jsonClassAppend);		
	}
	jsonObject.put("values", arrayClassAppend);
	jsonArray.put(jsonObject);
	rs.close();
	out.print(jsonArray);
}
catch(Exception ex) { throw ex; }
finally { if(conn!=null) cp.free(conn); }
%>