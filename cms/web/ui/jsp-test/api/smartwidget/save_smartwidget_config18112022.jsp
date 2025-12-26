<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			java.text.DateFormat,
			org.json.JSONObject,
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../utilities/validator.jsp"%>
<%@ include file="../header.jsp" %>
 	<%
	 	String popup_id = request.getParameter("popup_id");
		String isOrder = request.getParameter("is_order");
	 	String order_number = request.getParameter("order_number");
        String s_cust_id = cust.s_cust_id;
	  	ServletInputStream sis = request.getInputStream();
	       BufferedReader in = new BufferedReader(new InputStreamReader(sis));
	 
	       String configParam = in.readLine();
	 
	       //configParam = java.net.URLEncoder.encode(configParam);
	%>
 <%
 
        
  ConnectionPool cp = null;
  Connection conn = null;
  PreparedStatement	pstmt = null;
  ResultSet	rs = null; 
  
  try{
	  
  cp = ConnectionPool.getInstance();
  conn = cp.getConnection("save_smartwidget_config.jsp");
	if(isOrder != null && isOrder.equals("1")) {
     	//String[] orderArray = orderString.split(",");
     	String sql = "UPDATE c_smart_widget_config SET order_number = ? WHERE popup_id = ?";
     	pstmt = conn.prepareStatement(sql);
         pstmt.setString(1,order_number);
         pstmt.setString(2,popup_id);
        pstmt.executeUpdate();

}
}
 catch(Exception e){
	 System.out.println("CustID :"+s_cust_id+"->User İnfo save error :"+e);
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
