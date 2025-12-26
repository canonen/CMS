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
		String cust_id = request.getParameter("cust_id");
		String filterId = request.getParameter("filter_id");

 	%>
  <%
  
         
   ConnectionPool cp = null;
   Connection conn = null;
   PreparedStatement	pstmt = null;
   ResultSet	rs = null; 
   
   try{
 	  
   cp = ConnectionPool.getInstance();
   conn = cp.getConnection("save_recommendation_filter_all.jsp");
   
  String sql = "UPDATE c_recommendation_config SET filter_id = ? where cust_id = ?";
  
  	 
  	   pstmt = conn.prepareStatement(sql);
  	   int x=1;
  	   
  	   pstmt.setLong(x++,Long.parseLong(filterId));
	   pstmt.setLong(x++,Long.parseLong(cust_id));
  	   
  	   pstmt.executeUpdate();
	   out.print("200");
	   
   }
  catch(Exception e){
 	 System.out.println("CustID :"+cust_id+"->Save recommendation filter all error :"+e);
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