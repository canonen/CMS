
<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			javax.xml.parsers.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			java.io.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
 <%
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
 %>
<%
	String cust_id = request.getParameter("cust_id");
	String popup_idlist = request.getParameter("popup_idlist");
	String[] popupIdList = popup_idlist.split(",");
%>
 <%
 
        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null; 
  
  try{
	  
  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("save_smartwidget_config.jsp");
      
  StringBuilder sbSql = new StringBuilder();
  sbSql.append("UPDATE c_smart_widget_config set status = 90 WHERE cust_id = ? AND popup_id IN (");
  
  for(int i=0;i<popupIdList.length;i++) {
	  if(i!=0)
		  sbSql.append(",");
	  sbSql.append("?");
  }
  sbSql.append(")");
  
  pstmt = conn.prepareStatement(sbSql.toString());
  int x=1;
  pstmt.setLong(x++,Long.parseLong(cust_id));
  for(int i=0;i<popupIdList.length;i++) {
	  pstmt.setString(x++,popupIdList[i]);
  }
  
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