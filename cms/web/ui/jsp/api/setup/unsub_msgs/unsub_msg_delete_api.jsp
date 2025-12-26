<%@ page
		language="java"
		import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.adm.*,
		java.sql.*,java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"
%>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>

<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	JsonObject message = new JsonObject();

	Statement 		stmt	= null;
	ResultSet 		rs		= null;
	ConnectionPool 	cp		= null;
	Connection 		conn	= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("unsub_msg_delete_api.jsp");
		stmt = conn.createStatement();

		String UnsubMsgId = request.getParameter("msg_id");

		UnsubMsg unsub = new UnsubMsg(UnsubMsgId);
		unsub.delete();

		message.put("message: ", "Unsub message deleted successfully!");

	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_delete.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}

	out.print(message);
%>