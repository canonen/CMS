<%@ page
		language="java"
		import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		java.util.*,java.sql.*,
		java.io.*,javax.servlet.*,
		javax.servlet.http.*,org.xml.sax.*,
		javax.xml.transform.*,
		javax.xml.transform.stream.*,org.apache.log4j.*"
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
	JsonObject data = new JsonObject();
	JsonArray array = new JsonArray();

	String custId = request.getParameter("custId");

	String contID = request.getParameter("cont_id");

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	String sSql =
			" SELECT * " +
					" FROM cjtk_link " +
					" WHERE cont_id = "+contID+ 
					" AND cust_id = "+cust.s_cust_id;


	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();
		rs = stmt.executeQuery(sSql);

		//Need to create a hashtable of all current links in order to prefill with names

		while (rs.next()) {
			data.put("link_name",rs.getString("link_name"));
			data.put("href",rs.getString("href"));
			out.print(data);
			//array.put(data);
		}
		//out.print(array);
		rs.close();
	}
	catch (Exception ex) {
		throw ex;
	}
	finally {
		if (rs != null) {
			rs.close();
		}
		if (stmt != null) {
			stmt.close();
		}
		if (conn != null) {
			cp.freeConnection(this, conn);
		}
	}
%>
