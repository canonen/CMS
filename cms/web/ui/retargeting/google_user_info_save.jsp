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
 String user_name   = request.getParameter("user_name");
 String accountIds    = request.getParameter("accountIds");
 String accountNames= request.getParameter("accountNames");
 String revotas_user= request.getParameter("revotas_user");
 String refresh_token=request.getParameter("refresh_token");
 
 if(cust_id==null || user_id==null || accountIds==null || accountNames==null || revotas_user==null || refresh_token==null )
	 return;
 
 

 
 String [] accountIdList = accountIds.split(",");
        
 String [] accountNameList = accountNames.split(",");
        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null; 
  
  try{
	  
  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("google_user_info_save.jsp");
  String sql = "if(not exists(select 1 from z_retargeting_user_info with(nolock) where cust_id=? and user_id=? and ad_accounts=? and revotas_user = ?))"
  +" begin"
  +" insert into z_retargeting_user_info (cust_id,revotas_user,user_id,user_name,ad_accounts,ad_accounts_name,user_type,refresh_token,create_date) values (?,?,?,?,?,?,?,?,getdate())"
  +" end " +
  " else "+
  " begin "+
  " update z_retargeting_user_info set refresh_token=?, create_date = getdate() where cust_id=? AND user_id = ? AND ad_accounts = ?"+
  " end ";
  pstmt = conn.prepareStatement(sql);
  for(int i=0;i<accountIdList.length;i++) {
    int x=1;
	pstmt.setLong(x++,Long.parseLong(cust_id));
	pstmt.setString(x++,user_id);
	pstmt.setString(x++,accountIdList[i]);
	pstmt.setString(x++,revotas_user);
    pstmt.setLong(x++,Long.parseLong(cust_id));
    pstmt.setString(x++,revotas_user);
    pstmt.setString(x++,user_id);
    pstmt.setString(x++,user_name);
    pstmt.setString(x++,accountIdList[i]);
    pstmt.setString(x++,accountNameList[i]);
    pstmt.setString(x++,"google");
    pstmt.setString(x++,refresh_token);
    pstmt.setString(x++,refresh_token);
    pstmt.setLong(x++,Long.parseLong(cust_id));
    pstmt.setString(x++,user_id);
    pstmt.setString(x++,accountIdList[i]);
	pstmt.addBatch();  
  }
	int[] result=pstmt.executeBatch();	
	
	if(result.length>0)
		out.println("200");
	else
		out.println("500");
  }
 catch(Exception e){
	 //System.out.println("CustID :"+cust_id+"->User İnfo save error :"+e);
	 //out.print(e);
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