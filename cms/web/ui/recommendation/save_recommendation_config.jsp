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
%>
<%@ include file="../validator.jsp" %>
 <%
 response.setHeader("Access-Control-Allow-Origin", "*");
 response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
 response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
  %>
  	<%
 	 	String cust_id = request.getParameter("cust_id");
 	  	ServletInputStream sis = request.getInputStream();
 	    BufferedReader in = new BufferedReader(new InputStreamReader(sis));
 	 
 	    String configParam = String config_param = request.getParameter("object");
 	%>
  <%
  
         
   ConnectionPool cp = null;
   Connection conn = null;
   PreparedStatement	pstmt = null;
   ResultSet	rs = null; 
   
   try{
 	  
   cp = ConnectionPool.getInstance();
   conn = cp.getConnection("save_recommendation_config.jsp");
   
   String sql = "IF (NOT EXISTS(SELECT id FROM c_recommendation_config WHERE cust_id = ?)) " + 
 		"BEGIN " + 
 		"INSERT INTO c_recommendation_config (cust_id,config,create_date,modify_date) VALUES (?,?,getdate(),getdate()) " + 
 		"END " + 
 		"ELSE " + 
 		"BEGIN " + 
 		"UPDATE c_recommendation_config SET config = ?, modify_date = getdate() WHERE cust_id = ? " + 
 		"END ";
   
   pstmt = conn.prepareStatement(sql);
   int x=1;
   if(configParam.contains("Ç")) 
	configParam= configParam.replace("Ç", "&#199;");
   if(configParam.contains("ç")) 
	configParam= configParam.replace("ç", "&#231;");
   if(configParam.contains("Ğ")) 
	configParam= configParam.replace("Ğ", "&#286;");
   if(configParam.contains("ğ")) 
        configParam= configParam.replace("ğ", "&#287;");
  
   if(configParam.contains("Ö")) 
   	configParam= configParam.replace("Ö", "&#214;");
      if(configParam.contains("ö")) 
        configParam= configParam.replace("ö", "&#246;");
    if(configParam.contains("Ü")) 
       	configParam= configParam.replace("Ü", "&#220;");
          if(configParam.contains("ü")) 
        configParam= configParam.replace("ü", "&#252;");
   
   pstmt.setLong(x++,Long.parseLong(cust_id));
   pstmt.setLong(x++,Long.parseLong(cust_id));
   pstmt.setString(x++,configParam);
   pstmt.setString(x++,configParam);
   pstmt.setLong(x++,Long.parseLong(cust_id));
   
   pstmt.executeUpdate();
 out.println("201");
   }
  catch(Exception e){
 	 System.out.println("CustID :"+cust_id+"->User İnfo save error :"+e);
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