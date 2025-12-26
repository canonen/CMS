<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			java.net.*,java.sql.*,
			java.util.*,java.io.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="application/x-www-form-urlencoded;charset=UTF-8"
	
	
%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.net.URLEncoder"%>
<%@ page isThreadSafe="false" %>


 <%  response.setHeader("Access-Control-Allow-Origin", "*");  
 	 response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
	 response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
 
   %>
<%!

private static String asciiToHex(String asciiValue)
{
   char[] chars = asciiValue.toCharArray();
   StringBuffer hex = new StringBuffer();
   for (int i = 0; i < chars.length; i++)
   {
      hex.append(Integer.toHexString((int) chars[i]));
   }
    
   return hex.toString();
}

%>
 


<%
                        
 String cust_id=request.getParameter("cust_id");
 String cont_id=request.getParameter("cont_id");
 String stringEncoded=request.getParameter("html"); 
   
 String encode = URLEncoder.encode( stringEncoded   , "UTF-8");
  String html=asciiToHex(encode);
 
 String name=request.getParameter("name");
//  name=URLDecoder.decode(name,"UTF-8");
 
 

boolean DURUM=true;
   
 
 
if(cust_id==null ){ DURUM=false;	out.println("ERROR##CUST_ID Degeri Bos Birakilamaz"); 	   	 return;}
if(cont_id==null ){ DURUM=false;	out.println("ERROR##CONT_ID Degeri Bos Birakilamaz");   	 return;}
if(html==null ){ DURUM=false;		out.println("ERROR##HTML Degeri Bos Birakilamaz");  	 	 return;}
if(name==null ){ DURUM=false;		out.println("ERROR##NAME Degeri Bos Birakilamaz");    		 return;}
 

if(DURUM){
	
ResultSet 		rs = null; 
ConnectionPool  cp = null;
Connection 		conn = null;
Statement 		stmt = null;

	  		try {
 	   
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();
		 	 
		 	java.util.Date date = new java.util.Date();
		    long t = date.getTime();
		    java.sql.Timestamp sqlTimestamp = new java.sql.Timestamp(t);
    	   
    	   String UPDATE="UPDATE z_droptable "
	        			 +"	SET html='"+html+"', "
	        			 +"	name='"+name+"', "
	        		  	 +"	update_date='"+sqlTimestamp+"'          "
	        		     +" WHERE cont_id='"+cont_id+"' and cust_id='"+cust_id+"'";
    	  
		   String INSERT = "INSERT INTO z_droptable "
				 		+"(cust_id,cont_id,html,name)"
		 				+" VALUES ('"+cust_id+"','"+cont_id+"' ,'"+html+"','"+name+"')";
		  
		   String SQL="use brite_ccps_500"
				  	+" IF EXISTS (SELECT 1 FROM z_droptable  WHERE cont_id='"+cont_id+"' and  cust_id='"+cust_id+"'  ) "
    			     +" BEGIN "
    			     +  UPDATE  
    			   	 +" END "
    			  	 +" ELSE "
    			     +"	BEGIN "
    			     +  INSERT  
    			     +" END";
	   	   stmt.executeUpdate(SQL) ;
			
	  // 	TEST.put("SUCCESS", "Islem Basariyla Gerceklesti");  
	   	  
	 //   out.println(TEST);	
	   	out.println("SUCCESS##Islem Basariyla Gerceklesti"); 	  
		 
	  			} catch (Exception e) {
						System.out.println(e);
						 out.println(e);
			 }finally {
					if (stmt != null)
						try {
							stmt.close();
						} catch (SQLException e) {
						    e.printStackTrace();
						}
				 	if (conn != null) {
				           cp.free(conn);
				     }
		 }
	  	
	  		
}
 
 

 %>
  

 
