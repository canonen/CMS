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
 String cust_id     = request.getParameter("cust_id");
 
 if(cust_id==null)
	 return;
 
        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null;
  StringBuilder jsonSb = new StringBuilder();
  
  try{

  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("get_account_list");
  
  
  String sql = "select user_id, user_name, user_type, refresh_token, min(create_date),DATEDIFF(DAY, min(create_date), getdate()) from z_retargeting_user_info where cust_id = ? group by user_id, user_name, user_type, refresh_token";
  
  int x=1;
  pstmt = conn.prepareStatement(sql);
  pstmt.setString(x++, cust_id);

  rs = pstmt.executeQuery();
  int i = 0;
  jsonSb.append("[");
  while(rs.next()) {
  	String userId = rs.getString(1);
  	String userName = rs.getString(2);
  	String userType = rs.getString(3);
  	String refreshToken = rs.getString(4);
  	String createDate = rs.getString(5);
  	String days = rs.getString(6);
  	
  	if(i!=0)
  		jsonSb.append(",");
  	jsonSb.append("{\"userId\":\""+userId+"\",\"userName\":\""+userName+"\",\"userType\":\""+userType+"\",\"refreshToken\":\""+refreshToken+"\",\"createDate\":\""+createDate+"\",\"days\":"+days+"}");
  	i++;
  }
  jsonSb.append("]");
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
	response.getWriter().write(jsonSb.toString());
  }
  %>