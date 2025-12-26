<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
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

if(!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}
	String sLinkId = request.getParameter("link_id");

	LinkRenaming link = new LinkRenaming();


	if (sLinkId != null) {
		link.s_link_id = sLinkId;
		int nRetrieve = link.retrieve();
		if ((nRetrieve > 0) && !(cust.s_cust_id.equals(link.s_cust_id))) link = new LinkRenaming();
	}


	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;
	ResultSet		rs		= null;

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("ccnt_link_renaming_edit.jsp");
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
	finally{
		if(rs != null) rs.close();
		if(stmt != null) stmt.close();
		if(conn != null) conn.close();
	}
%>
