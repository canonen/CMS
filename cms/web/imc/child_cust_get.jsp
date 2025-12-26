<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.io.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

ConnectionPool cp   = null;
Connection	   conn = null;
Statement	   stmt	= null;
ResultSet      rs	= null; 	
String         sql  = "";
try 
{
	String cust_id = null;
	Element eRoot = XmlUtil.getRootElement(request);
	if (eRoot == null) 
	{
		out.println("<ERROR>Error retrieving XML in child_cust_get.jsp.  XML did not parse correctly.</ERROR>");
		return;
	}
	else 
	{
		cust_id = XmlUtil.getChildTextValue(eRoot,"cust_id");
	}
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("child_cust_get.jsp");
	stmt = conn.createStatement();
	sql =
		"SELECT c.cust_id, c.cust_name " + 
		"  FROM ccps_customer c" +
		" WHERE c.parent_cust_id = " + cust_id;
	rs = stmt.executeQuery (sql);
	String children_xml = "";
	while (rs.next()) {
		String child_id = rs.getString(1);
		byte[] bVal = new byte[255];
		bVal = rs.getBytes(2);
		children_xml += "  <child>\n";
		children_xml += "    <cust_id>"+child_id+"</cust_id>\n";
		children_xml += "    <cust_name><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></cust_name>\n";
		children_xml += "  </child>\n";
	}
	rs.close();
	if (children_xml != null) 
	{
		out.println("<children>\n"+children_xml+"</children>\n");
	}
}
catch (Exception ex) {
	ex.printStackTrace(new PrintWriter(out));
}
finally 
{
	try	
	{
		if ( stmt != null ) stmt.close();
	}
	catch (SQLException se) { }
	if ( conn != null ) cp.free(conn); 
}

%>
