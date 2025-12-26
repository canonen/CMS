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
		ServletInputStream sis = request.getInputStream();
		BufferedReader in = new BufferedReader(new InputStreamReader(sis,"UTF-8"));

	    String configParam = in.readLine();
		
		if(cust_id == null || camp_id == null || configParam == null)
		 return;
		 
		 String[] parts = configParam.split("<\\|>");
		 String name = parts[0];
		 String camp_title = parts[1];
		 String currencyConfig = parts[2];


 	%>
  <%
  
         
   ConnectionPool cp = null;
   Connection conn = null;
   PreparedStatement	pstmt = null;
   ResultSet	rs = null; 
   
   try{
 	  
   cp = ConnectionPool.getInstance();
   conn = cp.getConnection("save_recommendation_config.jsp");
   

	   
   }
  catch(Exception e){
 	 System.out.println("CustID :"+cust_id+"->Save recommendation config error :"+e);
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