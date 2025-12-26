<%@ page
	language="java"
	import="com.britemoon.*" 
	import="com.britemoon.cps.*" 
	import="java.io.*"
	import="java.sql.*" 
	import="java.util.*" 
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
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
	String query_cust_id = null;
	String query_login_period = null;
	String query_idle_time = null;
	String query_cps = null;
	Element eRoot = XmlUtil.getRootElement(request);
	if (eRoot == null) 
	{
		out.println("<ERROR>Error retrieving XML in session_monitor_report.jsp.  XML did not parse correctly.</ERROR>");
		return;
	}
	else 
	{
		query_cust_id = XmlUtil.getChildTextValue(eRoot,"cust_id");
		query_cps = XmlUtil.getChildTextValue(eRoot, "cps");
		query_login_period = XmlUtil.getChildTextValue(eRoot, "login_period");
		query_idle_time = XmlUtil.getChildTextValue(eRoot, "idle_time");
	}
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("session_monitor_get.jsp");
	stmt = conn.createStatement();
	sql =
	sql = "SELECT s.session_id, s.cust_id, s.cust_name, s.user_id, s.user_name," +
	 	  "       s.login_time, s.last_access_time, DATEDIFF(ss, s.last_access_time, getdate()) as 'idle_time'," +
		  "       s.last_url, u.phone, c.login_name as 'co_login', u.position, u.login_name, u.email, u.password" +
		  "  FROM cadm_session_log s with(nolock)" +
		  " INNER JOIN ccps_user u with(nolock) on s.user_id = u.user_id " +
		  " INNER JOIN ccps_customer c with(nolock) on u.cust_id = c.cust_id " +
		  " WHERE DATEDIFF(hh, login_time, getdate()) <= '" + query_login_period + "'" +
		  "   AND DATEDIFF(ss, last_access_time, getdate()) <= '" + query_idle_time + "'" +
		  "   AND s.cust_id = " + query_cust_id;
	//System.out.println("sql = "+sql);	  
	rs = stmt.executeQuery (sql);
	String children_xml = "";
	while (rs.next()) {
		byte[] bVal = new byte[255];
		children_xml += "  <session>\n";
		children_xml += "    <cps>" + query_cps +"</cps>\n";
		children_xml += "    <session_id>" + rs.getString(1) +"</session_id>\n";
		children_xml += "    <cust_id>" + rs.getString(2) +"</cust_id>\n";
		bVal = rs.getBytes(3);
		children_xml += "    <cust_name><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></cust_name>\n";
		children_xml += "    <user_id>" + rs.getString(4) +"</user_id>\n";
		bVal = rs.getBytes(5);
		children_xml += "    <user_name><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></user_name>\n";
		children_xml += "    <login_time>" + rs.getString(6) +"</login_time>\n";
		children_xml += "    <last_access_time>" + rs.getString(7) +"</last_access_time>\n";
		children_xml += "    <idle_time>" + rs.getString(8) +"</idle_time>\n";
		bVal = rs.getBytes(9);
		children_xml += "    <last_url><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></last_url>\n";
		bVal = rs.getBytes(10);
		children_xml += "    <phone><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></phone>\n";
		bVal = rs.getBytes(11);
		children_xml += "    <co_login><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></co_login>\n";
		bVal = rs.getBytes(12);
		children_xml += "    <position><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></position>\n";
		bVal = rs.getBytes(13);
		children_xml += "    <login_name><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></login_name>\n";
		bVal = rs.getBytes(14);
		children_xml += "    <email><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></email>\n";
		bVal = rs.getBytes(15);
		children_xml += "    <password><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></password>\n";
		children_xml += "  </session>\n";
	}
	rs.close();
	if (children_xml != null) 
	{
		out.println("<sessions>\n"+children_xml+"</sessions>\n");
		//System.out.println("<sessions>\n"+children_xml+"</sessions>\n");
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
