<%@  page language="java" 
              import="java.net.*,
            com.britemoon.*,
            com.britemoon.cps.*, 
			java.sql.*,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			org.json.JSONObject,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
 <%
 response.setHeader("Access-Control-Allow-Origin", "*");
 response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
 response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
  %>
  <%
  
         
   ConnectionPool cp = null;
   Connection conn = null;
   PreparedStatement	pstmt = null;
   ResultSet	rs = null; 
   
   try{
 	  
   cp = ConnectionPool.getInstance();
   conn = cp.getConnection("getAllCustomers.jsp");
   
  String sql = "select cust_id from ccps_customer where cust_id <> 0 order by cust_id asc";

  	   pstmt = conn.prepareStatement(sql);
  	   
  	   rs=pstmt.executeQuery();
	   
	   int counter = 0;
	   out.print("[");
	   while(rs.next()) {
		   if(counter!=0)
		out.print(",");
		out.print(rs.getInt(1));
		   counter++;
	   }
	   out.print("]");
	   
   }
  catch(Exception e){
 	 System.out.println("getAllCustomers error :"+e);
 	 throw e;
   }
   finally{
 	  
   try { if ( pstmt != null ) pstmt.close(); }
   catch (Exception ignore) { }
 
   if ( conn != null ) {
 	       cp.free(conn);
 	 } 
 	  
   }
 
 %>