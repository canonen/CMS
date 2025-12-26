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
	String config_idlist = request.getParameter("config_idlist");
	String[] configIdList = config_idlist.split(",");
%>
 <%
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null; 
  
  try{
	  
  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("delete_recommendation_config.jsp");
      
  StringBuilder sbSql = new StringBuilder();
  sbSql.append("UPDATE c_recommendation_config set status = 90 WHERE cust_id = ? AND camp_id IN (");
  
  for(int i=0;i<configIdList.length;i++) {
	  if(i!=0)
		  sbSql.append(",");
	  sbSql.append("?");
  }
  sbSql.append(")");
  
  pstmt = conn.prepareStatement(sbSql.toString());
  int x=1;
  pstmt.setLong(x++,Long.parseLong(cust_id));
  for(int i=0;i<configIdList.length;i++) {
	  pstmt.setString(x++,configIdList[i]);
  }
  
  pstmt.executeUpdate();
out.println("200");
  }
 catch(Exception e){
	 System.out.println("CustID :"+cust_id+"->Recommendation config delete error :"+e);
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