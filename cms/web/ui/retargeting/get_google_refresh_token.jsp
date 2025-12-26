<%@  page language="java" 
              import="java.net.*,
            com.britemoon.*,
            com.britemoon.cps.*, 
			java.sql.*,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%><%
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
 %><%
 String user_id     = request.getParameter("user_id");
 String account_id     = request.getParameter("account_id");
 
 if(user_id==null && account_id==null)
	 return;
 
        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null; 
  String refreshToken = null;
  
  try{

  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("get_google_refresh_token");
  String sql = "select distinct refresh_token from z_retargeting_user_info(nolock)";
  if(user_id != null) {
  	sql += " where user_id = ? ";
  } else if(account_id != null) {
  	sql += " where ad_accounts = ? ";
  }
	int x=1;
	pstmt = conn.prepareStatement(sql);
	if(user_id != null) {
	  	pstmt.setString(x++, user_id);
	} else if(account_id != null) {
	  	pstmt.setString(x++, account_id);
  	}
	
	rs = pstmt.executeQuery();
	
	if(rs.next()) {
		refreshToken = rs.getString(1);
	}
  }
 catch(Exception e){
	 System.out.println("User İnfo save error :"+e);
	
  }
  finally{
	  
  try { if ( pstmt != null ) pstmt.close(); }
  catch (Exception ignore) { }

  if ( conn != null ) {
	       cp.free(conn);
	 }
	//response.setContentType("application/json");
	//response.setCharacterEncoding("UTF-8");
	if(refreshToken != null) {
		response.getWriter().write("{\"success\":true,\"refresh_token\":\""+refreshToken+"\"}");
	} else {
		response.getWriter().write("{\"success\":false}");
	}
  }
  %>