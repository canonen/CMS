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
 
 String cust_id     = request.getParameter("cust_id");
 String user_id     = request.getParameter("user_id");
 String accounts    = request.getParameter("addAccounts");
 String accountNames= request.getParameter("accountNames");
 
 if(cust_id==null || user_id==null || accounts==null || accountNames==null)
	 return;
 
 String [] addAccounts;
   
        addAccounts=accounts.split(",");
        
 String [] accountName;
 
        accountName=accountNames.split(",");
        
        //System.out.println(cust_id+" "+user_id+" "+accounts);
        
  ConnectionPool cp = null;
  Connection conn = null;
  Statement	stmt = null;
  ResultSet	rs = null; 
  
  try{
	  
  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("user_info_save.jsp");
  stmt = conn.createStatement();
		
  for(int i=0;i<addAccounts.length;i++)
  {

	  String rSql="if(not exists(select 1 from z_retargeting_user_info with(nolock) where ad_accounts='"+addAccounts[i].trim()+"'))"+
		  " begin"+
		  " insert into z_retargeting_user_info (cust_id,user_id,ad_accounts,ad_accounts_name) values ('"+cust_id+"','"+user_id+"','"+addAccounts[i].trim()+"','"+accountName[i].trim()+"')"+
		  " end";
	  stmt.addBatch(rSql);
	 // System.out.println(rSql);	  
  }
	int[] result=stmt.executeBatch();	
	
	if(result.length>0)
		out.println("200");
	else
		out.println("500");
  }
 catch(Exception e){
	 System.out.println("CustID :"+cust_id+"->User İnfo save error :"+e);
  }
  finally{
	  
  try { if ( stmt != null ) stmt.close(); }
  catch (Exception ignore) { }

  if ( conn != null ) {
	       cp.free(conn);
	 } 
	  
  }
  

 

 %>