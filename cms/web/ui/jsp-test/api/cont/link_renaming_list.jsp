<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.util.Vector,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
JsonObject data= new JsonObject();
JsonArray array= new JsonArray();
String cust_id = request.getParameter("custd_id");
if (!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;
	ResultSet		rs		= null;
	String sSql =" SELECT lower(link_definition), link_name " + 
			"from ccnt_link_renaming " +
			"  WHERE link_type_id = 1"+
			"    AND cust_id = "+cust.s_cust_id;

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("ccnt_link_renaming.jsp");
		stmt = conn.createStatement();
		rs= stmt.executeQuery(sSql);
		String link_id, link_name, link_type_id, link_type, link_definition;
		while(rs.next())
		{
			data.put("link_id",rs.getString(1));
			data.put("cust_id",rs.getString(2));
			data.put("link_name",rs.getString(3));
			data.put("link_type_id",rs.getString(4));
			data.put("link_definition",rs.getString(5));
			array.put(data);
		}
		out.print(array);
		rs.close();
	}
	catch(Exception ex) {
		throw ex;
	}
%>
