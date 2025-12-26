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
		String camp_id = request.getParameter("camp_id");
		//String name = request.getParameter("camp_name");
		//String camp_title = request.getParameter("camp_title");
		String camp_type = request.getParameter("camp_type");
		String fallback_camp_type = request.getParameter("fallback_camp_type");
		String template_id = request.getParameter("template_id");
		String status = request.getParameter("status");
		String productsNumBlock = request.getParameter("products_num_block");
		String containerSize = request.getParameter("container_size");
		String rcpLink = request.getParameter("rcp_link");
		String cartAddToCart = request.getParameter("camp_add_to_cart");
		String addToCartScript = request.getParameter("add_to_cart_script");
		String productScript = request.getParameter("product_script");
		String filterId = request.getParameter("filter_id");
       String appendUTM = request.getParameter("append_utm");
	   String excludeRecentlyViewed = request.getParameter("exclude_recently_viewed");
	   String excludeRecentlyPurchased = request.getParameter("exclude_recently_purchased");
		if(filterId==null) {
            filterId = "0";
       }
       if(appendUTM==null) {
            appendUTM = "1";
       }
	   
	   if(excludeRecentlyViewed==null) {
            excludeRecentlyViewed = "0";
       }
	   
	   if(excludeRecentlyPurchased==null) {
            excludeRecentlyPurchased = "0";
       }
		
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
   
  String sql = "IF (NOT EXISTS(SELECT id FROM c_recommendation_config WHERE cust_id = ? and camp_id = ?)) " + 
      		"BEGIN " + 
      		"INSERT INTO c_recommendation_config (cust_id,camp_id,camp_name,camp_title,camp_type,fallback_camp_type,template_id,status,products_num_block,container_size,rcp_link,currency_config,camp_add_to_cart,add_to_cart_script,product_script,filter_id,append_utm,exclude_recently_viewed,exclude_recently_purchased,create_date,modify_date) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,getdate(),getdate())" + 
      		"END " + 
      		"ELSE " + 
      		"BEGIN " + 
      		"UPDATE c_recommendation_config SET camp_name = ?, camp_title = ?, camp_type = ?, fallback_camp_type = ?, template_id = ?, status = ?, products_num_block = ?, container_size = ?, rcp_link = ?, currency_config = ?, camp_add_to_cart = ?, add_to_cart_script = ?, product_script = ?, filter_id = ?, append_utm = ?, exclude_recently_viewed = ?, exclude_recently_purchased = ?, modify_date = getdate() WHERE cust_id = ? and camp_id = ? " + 
   		"END ";
  
  	 
  	   pstmt = conn.prepareStatement(sql);
  	   int x=1;
  	   
  	   pstmt.setLong(x++,Long.parseLong(cust_id));
  	   pstmt.setString(x++,camp_id);
  	   
  	   pstmt.setLong(x++,Long.parseLong(cust_id));
  	   pstmt.setString(x++,camp_id);
  	   pstmt.setString(x++,name);
  	   pstmt.setString(x++,camp_title);
  	   pstmt.setString(x++,camp_type);
  	   pstmt.setString(x++,fallback_camp_type);
  	   pstmt.setLong(x++,Long.parseLong(template_id));
  	   pstmt.setLong(x++,Long.parseLong(status));
  	   pstmt.setLong(x++,Long.parseLong(productsNumBlock));
  	   pstmt.setLong(x++,Long.parseLong(containerSize));
	   pstmt.setString(x++,rcpLink);
	   pstmt.setString(x++,currencyConfig);
	   pstmt.setString(x++,cartAddToCart);
   	   pstmt.setString(x++,addToCartScript);
	   pstmt.setString(x++,productScript);
	   pstmt.setLong(x++,Long.parseLong(filterId));
       pstmt.setLong(x++,Long.parseLong(appendUTM));
	   pstmt.setLong(x++,Long.parseLong(excludeRecentlyViewed));
	   pstmt.setLong(x++,Long.parseLong(excludeRecentlyPurchased));
     	   
	   pstmt.setString(x++,name);
  	   pstmt.setString(x++,camp_title);
  	   pstmt.setString(x++,camp_type);
  	   pstmt.setString(x++,fallback_camp_type);
  	   pstmt.setLong(x++,Long.parseLong(template_id));
  	   pstmt.setLong(x++,Long.parseLong(status));
  	   pstmt.setLong(x++,Long.parseLong(productsNumBlock));
  	   pstmt.setLong(x++,Long.parseLong(containerSize));
	   pstmt.setString(x++,rcpLink);
	   pstmt.setString(x++,currencyConfig);
	   pstmt.setString(x++,cartAddToCart);
   	   pstmt.setString(x++,addToCartScript);
	   pstmt.setString(x++,productScript);
	   pstmt.setLong(x++,Long.parseLong(filterId));
       pstmt.setLong(x++,Long.parseLong(appendUTM));
	   pstmt.setLong(x++,Long.parseLong(excludeRecentlyViewed));
	   pstmt.setLong(x++,Long.parseLong(excludeRecentlyPurchased));
     	   
     	   pstmt.setLong(x++,Long.parseLong(cust_id));
  	   pstmt.setString(x++,camp_id);
  	   
  	   pstmt.executeUpdate();
	   out.print("200");
	   
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