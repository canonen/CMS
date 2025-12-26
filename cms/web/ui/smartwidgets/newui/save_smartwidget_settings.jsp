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
 <%
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
 %>
 	<%
	 	String cust_id = request.getParameter("cust_id");
	 	if(cust_id == null)
	 	    return;
	 	ServletInputStream sis = request.getInputStream();
		BufferedReader in = new BufferedReader(new InputStreamReader(sis,"UTF-8"));
		String configParam = in.readLine();
		
		String[] parts = configParam.split("(<\\|>)",-1);
        String web_page = parts[0];
        String register_page = parts[1];
        String cart_page = parts[2];
        String order_page = parts[3];
	  	
	%>
 <%
 
        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null; 
  
  try{
	  
  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("save_smartwidget_settings.jsp");
  
  String sql = "IF (NOT EXISTS(SELECT id FROM c_smart_widget_settings WHERE cust_id = ?)) " + 
   		"BEGIN " + 
   		"INSERT INTO c_smart_widget_settings (cust_id,web_page,register_page,cart_page,order_page,create_date,modify_date) VALUES (?,?,?,?,?,getdate(),getdate()) " + 
   		"END " + 
   		"ELSE " + 
   		"BEGIN " + 
   		"UPDATE c_smart_widget_settings SET web_page = ?, register_page = ?, cart_page = ?, order_page = ?, modify_date = getdate() WHERE cust_id = ? " + 
   		"END ";
     
   	pstmt = conn.prepareStatement(sql);
   	int x=1;
   	pstmt.setLong(x++,Long.parseLong(cust_id));
   	pstmt.setLong(x++,Long.parseLong(cust_id));
   	pstmt.setString(x++,web_page);
   	pstmt.setString(x++,register_page);
   	pstmt.setString(x++,cart_page);
   	pstmt.setString(x++,order_page);
   	pstmt.setString(x++,web_page);
   	pstmt.setString(x++,register_page);
   	pstmt.setString(x++,cart_page);
   	pstmt.setString(x++,order_page);
	pstmt.setLong(x++,Long.parseLong(cust_id));
	
  
  pstmt.executeUpdate();
out.println("200");

  }
 catch(Exception e){
	 System.out.println("CustID :"+cust_id+"->User İnfo save error :"+e);
	 out.print(e);
  }
  finally{
	  
  try { if ( pstmt != null ) pstmt.close(); }
  catch (Exception ignore) { }

  if ( conn != null ) {
	       cp.free(conn);
	 } 
	  
  }

 %>