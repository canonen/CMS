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

private static String hexToASCII(String hexValue)
{
    StringBuilder output = new StringBuilder("");
    for (int i = 0; i < hexValue.length(); i += 2)
    {
       String str = hexValue.substring(i, i + 2);
       output.append((char) Integer.parseInt(str, 16));
    }
    return output.toString();
 }

%>

<%
                        
String cust_id=request.getParameter("cust_id");
String cont_id=request.getParameter("cont_id");
 
boolean DURUM=true;
   
 
 
if(cust_id==null ){ DURUM=false;	out.println("ERROR##CUST_ID Degeri Bos Birakilamaz"); 	   	 return;}
if(cont_id==null ){ DURUM=false;	out.println("ERROR##CONT_ID Degeri Bos Birakilamaz");   	 return;}
 
 

if(DURUM){
	
ResultSet 		rs = null; 
ConnectionPool  cp = null;
Connection 		conn = null;
Statement 		stmt = null;

	  		try {
 	   
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();
		   
			int count=0;
			
		   String html=null;
		   String SELECT = "use brite_ccps_500 SELECT html FROM z_droptable "
				 		+" where cust_id='"+cust_id+"' and cont_id='"+ cont_id +"' " ;
		   	rs = stmt.executeQuery(SELECT);
		 	
	  		while(rs.next()){
	  			 count++;
	  			 String deger=hexToASCII(rs.getString(1));
	  			
	  			 html =  URLDecoder.decode(deger,"UTF-8");
	  			// html = URLEncoder.decode(rs.getString(1) , "UTF-8");
	  		 
	  			
		      }
			rs.close();
			 
			if(count==0){
				
				out.println("ERROR##DATA BULUNAMADI"); 
				
			}else{
				//out.println(hexToASCII(html)); 
				out.println(html); 
			}
	  	 	   
		 
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
  

 
