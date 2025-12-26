
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
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	String custId = request.getParameter("custId");
	String popupIdlist = request.getParameter("popupIdlist");
	String[] popupIdList = popupIdlist.split(",");
%>
 <%
 
        
  ConnectionPool connectionPool = null;
  Connection connection = null;
  PreparedStatement preparedStatement = null;
  ResultSet resultSet = null;
  
  try{
	  
  connectionPool = ConnectionPool.getInstance();
  connection = connectionPool.getConnection("save_smartwidget_config.jsp");
      
  StringBuilder sbSql = new StringBuilder();
  sbSql.append("UPDATE c_smart_widget_config set status = 90 WHERE custId = ? AND popup_id IN (");
  
  for(int i=0;i<popupIdList.length;i++) {
	  if(i!=0)
		  sbSql.append(",");
	  sbSql.append("?");
  }
  sbSql.append(")");
  
  preparedStatement = connection.prepareStatement(sbSql.toString());
  int x=1;
  preparedStatement.setLong(x++,Long.parseLong(custId));
  for(int i=0;i<popupIdList.length;i++) {
	  preparedStatement.setString(x++,popupIdList[i]);
  }
  
  preparedStatement.executeUpdate();
out.println("200");
  }
 catch(Exception e){
	 System.out.println("CustID :"+ custId +"->User İnfo save error :"+e);
	 out.print(e);
  }
  finally{
	  
  try { if ( preparedStatement != null ) preparedStatement.close(); }
  catch (Exception ignore) { }

  if ( connection != null ) {
	       connectionPool.free(connection);
	 } 
	  
  }

 %>