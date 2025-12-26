<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.util.Vector,
			org.w3c.dom.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="header.jsp"%>
<%@ include file="validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

if (!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}



ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null;
	JsonObject data = new JsonObject();
	JsonArray  array = new JsonArray();
	String custid = cust.s_cust_id;
	System.out.println(custid);

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("ccnt_link_renaming.jsp");
	stmt = conn.createStatement();
	String link_id, link_name, link_type_id, link_type, link_definition;



			String sSql = "EXEC usp_ccnt_link_renaming_list_get " + custid;

			rs = stmt.executeQuery(sSql);

			while( rs.next() ) {



				link_id = rs.getString(1);
				link_name = new String(rs.getBytes(2),"UTF-8");
				link_type_id = rs.getString(3);
				link_type = new String(rs.getBytes(4),"UTF-8");
				link_definition = new String(rs.getBytes(5),"UTF-8");

				data=new JsonObject();

				data.put("link_id",link_id);
				data.put("link_name",link_name);
				data.put("link_type_id",link_type_id);
				data.put("link_type",link_type);
				data.put("link_definition",link_definition);

				array.put(data);



			}
			rs.close();




}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn  != null) cp.free(conn);
}
out.println(array.toString());
%>
