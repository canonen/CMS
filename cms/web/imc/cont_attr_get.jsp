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
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
String cust_id = null;
String attr_name = null;

ConnectionPool cp   = null;
Connection	   conn = null;
Statement	   stmt	= null;
ResultSet      rs	= null; 	
String         sql  = "";
try 
{
	Element eRoot = XmlUtil.getRootElement(request);
	if (eRoot == null) 
	{
		out.println("<ERROR>Error retrieving XML in cont_attr_get.jsp.  XML did not parse correctly.</ERROR>");
		return;
	}
	else 
	{
		cust_id = XmlUtil.getChildTextValue(eRoot,"cust_id");
		attr_name = XmlUtil.getChildTextValue(eRoot,"attr_name");
	}
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("cont_attr_get.jsp");
	stmt = conn.createStatement();
	sql =
		"SELECT v.attr_value " + 
		"  FROM ccps_cont_attr_value v WITH(NOLOCK)," +
		"       ccps_cont_attr a WITH(NOLOCK) " +
		" WHERE v.cust_id = " + cust_id +
		"   AND v.attr_id = a.attr_id" +
		"   AND UPPER(a.attr_name) = '" + attr_name.toUpperCase() + "'";
	rs = stmt.executeQuery (sql);
	if (rs.next()) 
	{
		byte[] bVal = new byte[255];
		bVal = rs.getBytes(1);
		out.println("<ContAttr>");
		out.println("  <cust_id>"+cust_id+"</cust_id>");
		out.println("  <attr_name>"+attr_name+"</attr_name>");
		out.println("  <attr_value><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></attr_value>");
		out.println("</ContAttr>");
	}
	rs.close();
}
catch (Exception ex) 
{
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
