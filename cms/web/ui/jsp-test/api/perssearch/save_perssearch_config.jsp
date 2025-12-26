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
 
<%@ include file="../../utilities/validator.jsp"%><%
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
 %>
 	<%
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

		String custID =cust.s_cust_id;
 		String enabled = request.getParameter("enabled");
	 	String cust_id = custID;
	 	String rcp_link = request.getParameter("rcp_link");
		String filter_id = request.getParameter("filter_id");
		String exclude_recently_viewed = request.getParameter("exclude_recently_viewed");
		String exclude_recently_purchased = request.getParameter("exclude_recently_purchased");
	  	ServletInputStream sis = request.getInputStream();
	       BufferedReader in = new BufferedReader(new InputStreamReader(sis,"UTF-8"));
	 
	       String configParam = in.readLine();
	       //configParam = java.net.URLEncoder.encode(configParam);

        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null; 
  
  try{
	  
  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("save_smartwidget_config.jsp");
  
  String sql = "IF (NOT EXISTS(SELECT id FROM c_personal_search_config WHERE cust_id = ?)) " + 
		"BEGIN " + 
		"INSERT INTO c_personal_search_config (cust_id,config_param,status,create_date,modify_date,rcp_link,filter_id,exclude_recently_viewed,exclude_recently_purchased) VALUES (?,?,?,getdate(),getdate(),?,?,?,?) " + 
		"END " + 
		"ELSE " + 
		"BEGIN " + 
		"UPDATE c_personal_search_config SET config_param = ?, status = ?, modify_date = getdate(), rcp_link = ?, filter_id = ?, exclude_recently_viewed = ?, exclude_recently_purchased = ? WHERE cust_id = ? " + 
		"END ";
  
	pstmt = conn.prepareStatement(sql);
	int x=1;
	pstmt.setLong(x++,Long.parseLong(cust_id));
	pstmt.setLong(x++,Long.parseLong(cust_id));
	pstmt.setString(x++,configParam);
	pstmt.setLong(x++,Long.parseLong(enabled));
	pstmt.setString(x++,rcp_link);
	pstmt.setString(x++,filter_id);
    pstmt.setString(x++,exclude_recently_viewed);
    pstmt.setString(x++,exclude_recently_purchased);
	pstmt.setString(x++,configParam);
	pstmt.setLong(x++,Long.parseLong(enabled));
	pstmt.setString(x++,rcp_link);
	pstmt.setString(x++,filter_id);
   pstmt.setString(x++,exclude_recently_viewed);
   pstmt.setString(x++,exclude_recently_purchased);
	pstmt.setLong(x++,Long.parseLong(cust_id));
  
  pstmt.executeUpdate();
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
