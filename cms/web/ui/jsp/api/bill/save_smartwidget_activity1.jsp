<%@  page language="java" 
              import="java.net.*,
            com.britemoon.*,
            com.britemoon.aps.*,
            com.britemoon.aps.sbs.*,
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
		String popup_id = request.getParameter("popup_id");
 	 	String form_id = request.getParameter("form_id");
		String user_id = request.getParameter("user_id");
		String email = request.getParameter("email");
		String user_agent = request.getParameter("user_agent");
		String activity_type = request.getParameter("activity_type");
 	 	String url = request.getParameter("url");
 	 	String session_id = request.getParameter("session_id");
		String device = request.getParameter("device");
 	%>
  <%
  
         
   ConnectionPool cp = null;
   Connection conn = null;
   PreparedStatement	pstmt = null;
   ResultSet	rs = null; 
   String deviceStr = "";
   if(device.equals("1")){
         deviceStr = "mobile";
   }else if(device.equals("2")) {
       deviceStr = "desktop";
   }
   
   try{
 	  
   cp = ConnectionPool.getInstance();
   conn = cp.getConnection("save_smartwidget_activity.jsp");
       
   
   
   String sql = "INSERT INTO asbs_smart_widget_activity (session_id,type,cust_id,popup_id,form_id,first_popup_open_time,url,remote_ip"+(user_id != null ? ",user_id" : "")+",user_agent,activity_type"+(email != null ? ",email" : "")+" , device_type) VALUES(?,'0',?,?,?,getdate(),?,?"+(user_id != null ? ",?" : "")+",?,?"+(email != null ? ",?" : "")+" ,?)";

   
   pstmt = conn.prepareStatement(sql);
   int x=1;
   pstmt.setString(x++,session_id);
   pstmt.setLong(x++,Long.parseLong(cust_id));
   pstmt.setString(x++,popup_id);
   pstmt.setLong(x++,Long.parseLong(form_id));
   pstmt.setString(x++,url);
   pstmt.setString(x++,request.getRemoteAddr());
if(user_id != null)pstmt.setString(x++,user_id);
pstmt.setString(x++,user_agent);
pstmt.setString(x++,activity_type);
if(email != null)pstmt.setString(x++,email);
pstmt.setString(x++,deviceStr);

  
   pstmt.executeUpdate();
 out.println("200");
   }
  catch(Exception e){
  System.out.println("CustID: " + cust_id + "SmartWidget Activity error: " + user_agent + "," + user_id + "," + session_id + "," + url + "," + request.getRemoteAddr() + "," + popup_id + "," + form_id);
 	 System.out.println("CustID :"+cust_id+"->SmartWidget Activity save error :"+e);
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