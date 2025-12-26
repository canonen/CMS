<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.sql.*,
			java.io.*,
			java.util.*,
			org.apache.log4j.*,
			org.json.JSONObject,
			org.json.JSONArray"
%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());	
	}
	String customerId = null;
	
	if ((session != null) && (request.isRequestedSessionIdValid())) {
		Customer customer = (Customer) session.getAttribute("cust");
		
		customerId = customer.s_cust_id;
	}
	if (customerId == null) {
		throw new RuntimeException("Error: Customer ID couldn't set.");
	}
	ConnectionPool cp = null;
	Connection conn = null;
	
	JSONObject nextObj = new JSONObject();
	JSONArray result = new JSONArray();
	int rowCount = 0;

	String sSql = "SELECT TOP 100 cust_name, user_id, user_name, login_time, last_access_time, last_url" +
			" FROM cadm_session_log" +
			" WHERE cust_id = ?" +
			" ORDER BY last_access_time DESC";

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("session_monitor.jsp");
		
		PreparedStatement ps = conn.prepareStatement(sSql);
		ResultSet rs = null;
		
		ps.setString(1, customerId);
		// ps.setString(1, request.getParameter("cust_id"));
		
		rs = ps.executeQuery();
		
		while (rs.next()) {
			String customerName = rs.getString("cust_name");
			Integer userId = rs.getInt("user_id");
			String userName = rs.getString("user_name");
			Timestamp loginTime = rs.getTimestamp("login_time");
			Timestamp lastAccessTime = rs.getTimestamp("last_access_time");
			String lastUrl = rs.getString("last_url");
			
			nextObj.put("customerName", customerName);
			nextObj.put("userId", userId);
			nextObj.put("userName", userName);
			nextObj.put("loginTime", loginTime);
			nextObj.put("lastAccessTime", lastAccessTime);
			nextObj.put("lastUrl", lastUrl);
			nextObj.put("rowNumber", ++rowCount);
			
			result.put(nextObj);
			
			nextObj = new JSONObject();
		}
		rs.close();
		
		out.println(result);
	}
	catch(Exception ex) { ex.printStackTrace(response.getWriter()); }
	finally { if(conn!=null) cp.free(conn); }
%>
