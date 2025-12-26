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
 String file_id     = request.getParameter("file_id");
 
 if(file_id==null)
	 return;
 
        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null; 
  String refreshToken = null;
  String clientCustomerId = null;
  String audienceName = null;
  
  try{

  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("get_google_refresh_token");
  String sql = "select refresh_token, adaccount_id, audience_name, file_id from cexp_retargeting_export with(nolock) where file_id = ?";
	int x=1;
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(x++, file_id);
	
	rs = pstmt.executeQuery();
	
	if(rs.next()) {
		refreshToken = rs.getString(1);
		clientCustomerId = rs.getString(2);
		audienceName = rs.getString(3);
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
	if(refreshToken != null || clientCustomerId != null || audienceName != null) {
		response.getWriter().write("{\"success\":true,\"refresh_token\":\""+refreshToken+"\",\"client_customer_id\":\""+clientCustomerId+"\",\"audience_name\":\""+audienceName+"\"}");
	} else {
		response.getWriter().write("{\"success\":false}");
	}
  }
  %>